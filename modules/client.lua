local GangBlips = {}
local BossBlips = {}
local PromptKey = QRCore.Shared.GetKey(Config.PromptKey)
PlayerJob = QRCore.Functions.GetPlayerData().job
PlayerGang = QRCore.Functions.GetPlayerData().gang

local qrc = {}

function qrc.comma_value(amount)
    local formatted = amount
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then break end
    end
    return formatted
end

function qrc.Blip(text, coords, icon, scale)
    local NewBlip = N_0x554d9d53f696d002(1664425300, coords)
    SetBlipSprite(NewBlip, icon, 1)
    SetBlipScale(NewBlip, scale)
    Citizen.InvokeNative(0x9CB1A1623062F402, NewBlip, text)
    return NewBlip
end

function qrc.GangLocations()
    for q, r in pairs(Config.GangLocations) do
        if (PlayerGang.name == q) and PlayerGang.isboss then
            local coords = r.location.coords
            if r.blip.showBlip then GangBlips[q] = qrc.Blip(r.blip.text, coords, r.blip.icon, r.blip.size) end
            if not Config.UseTarget then
                exports['qr-core']:createPrompt('gang_'..q, coords, PromptKey, 'Open '..r.blip.text, {
                    type = 'client',
                    event = 'qr-gangmenu:client:OpenMenu',
                    args = {},
                })
            else
                exports['qr-target']:AddCircleZone("gang_"..q, vector3(coords.x, coords.y, coords.z), r.location.radius, {
                    name = "gang_"..q,
                    debugPoly = Config.DebugPoly,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "qr-gangmenu:client:OpenMenu",
                            icon = 'fas fa-briefcase',
                            label = 'Gang Menu',
                            canInteract = function()
                                if (PlayerGang.name == q) and PlayerGang.isboss then return true else return false end
                            end,
                        }
                    },
                    distance = 2.5,
                })
            end
        else
            qrc.CleanupGangLocations()
        end
    end
end

function qrc.CleanupGangLocations()
    for q, r in pairs(Config.GangLocations) do
        if DoesBlipExist(GangBlips[q]) then RemoveBlip(GangBlips[q]) end
        if not Config.UseTarget then
            local prompt = exports['qr-core']:getPrompt()['gang_'..q]
            if prompt then exports['qr-core']:deletePrompt('gang_'..q) end
        else
            exports['qr-target']:RemoveZone("gang_"..q)
        end
    end
end

function qrc.BossLocations()
    for q, r in pairs(Config.BossLocations) do
        if (PlayerJob.name == q) and PlayerJob.isboss then
            local coords = r.location.coords
            if r.blip.showBlip then BossBlips[q] = qrc.Blip(r.blip.text, coords, r.blip.icon, r.blip.size) end
            if not Config.UseTarget then
                exports['qr-core']:createPrompt('boss_'..q, coords, PromptKey, 'Open '..r.blip.text, {
                    type = 'client',
                    event = 'qr-bossmenu:client:OpenMenu',
                    args = {},
                })
            else
                exports['qr-target']:AddCircleZone("boss_"..q, vector3(coords.x, coords.y, coords.z), r.location.radius, {
                    name = "boss_"..q,
                    debugPoly = Config.DebugPoly,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "qr-bossmenu:client:OpenMenu",
                            icon = 'fas fa-briefcase',
                            label = 'Boss Menu',
                            canInteract = function()
                                if (PlayerJob.name == q) and PlayerJob.isboss then return true else return false end
                            end,
                        }
                    },
                    distance = 2.5,
                })
            end
        else
            qrc.CleanupBossLocations()
        end
    end
end

function qrc.CleanupBossLocations()
    for q, r in pairs(Config.BossLocations) do
        if DoesBlipExist(BossBlips[q]) then RemoveBlip(BossBlips[q]) end
        if not Config.UseTarget then
            local prompt = exports['qr-core']:getPrompt()['boss_'..q]
            if prompt then exports['qr-core']:deletePrompt('boss_'..q) end
        else
            exports['qr-target']:RemoveZone("boss_"..q)
        end
    end
end

return qrc