local QRCore = exports['qr-core']:GetCoreObject()
local PlayerJob = QRCore.Functions.GetPlayerData().job
local shownBossMenu = false
local DynamicMenuItems = {}
local bossmenu

Citizen.CreateThread(function()
     for bossmenu, v in pairs(Config.BossLocations) do
         exports['qr-core']:createPrompt(v.bossname, v.coords, QRCore.Shared.Keybinds['J'], 'Open ' .. v.name, {
             type = 'client',
             event = 'qr-bossmenu:client:OpenMenu',
             args = { },
         })
         if v.showblip == true then
             local BossBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
			 SetBlipSprite(BossBlip, GetHashKey("blip_honor_good"), true)
             SetBlipScale(BossBlip, 0.2)
			 Citizen.InvokeNative(0x9CB1A1623062F402, BossBlip, v.name)
         end
     end
end)

-- UTIL
local function CloseMenuFull()
    exports['qr-menu']:closeMenu()
    exports['qr-core']:HideText()
    shownBossMenu = false
end

local function comma_value(amount)
    local formatted = amount
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

local function AddBossMenuItem(data, id)
    local menuID = id or (#DynamicMenuItems + 1)
    DynamicMenuItems[menuID] = deepcopy(data)
    return menuID
end

exports("AddBossMenuItem", AddBossMenuItem)

local function RemoveBossMenuItem(id)
    DynamicMenuItems[id] = nil
end

exports("RemoveBossMenuItem", RemoveBossMenuItem)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerJob = QRCore.Functions.GetPlayerData().job
    end
end)

RegisterNetEvent('QRCore:Client:OnPlayerLoaded', function()
    PlayerJob = QRCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QRCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('qr-bossmenu:client:OpenMenu', function()
    if not PlayerJob.name or not PlayerJob.isboss then return end

    local bossMenu = {
        {
            header = "Boss Menu - " .. string.upper(PlayerJob.label),
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        },
        {
            header = "Manage Employees",
            txt = "Check your Employees List",
            icon = "fa-solid fa-list",
            params = {
                event = "qr-bossmenu:client:employeelist",
            }
        },
        {
            header = "Hire Employees",
            txt = "Hire Nearby Civilians",
            icon = "fa-solid fa-hand-holding",
            params = {
                event = "qr-bossmenu:client:HireMenu",
            }
        },
        {
            header = "Storage Access",
            txt = "Open Storage",
            icon = "fa-solid fa-box-open",
            params = {
                event = "qr-bossmenu:client:Stash",
            }
        },
        {
            header = "Outfits",
            txt = "See Saved Outfits",
            icon = "fa-solid fa-shirt",
            params = {
                event = "qr-bossmenu:client:Wardrobe",
            }
        },
        {
            header = "Money Management",
            txt = "Check your Company Balance",
            icon = "fa-solid fa-sack-dollar",
            params = {
                event = "qr-bossmenu:client:SocietyMenu",
            }
        },
    }

    for _, v in pairs(DynamicMenuItems) do
        bossMenu[#bossMenu + 1] = v
    end

    bossMenu[#bossMenu + 1] = {
        header = "Exit",
        icon = "fa-solid fa-angle-left",
        params = {
            event = "qr-menu:closeMenu",
        }
    }

    exports['qr-menu']:openMenu(bossMenu)
end)

RegisterNetEvent('qr-bossmenu:client:employeelist', function()
    local EmployeesMenu = {
        {
            header = "Manage Employees - " .. string.upper(PlayerJob.label),
            isMenuHeader = true,
            icon = "fa-solid fa-circle-info",
        },
    }
    QRCore.Functions.TriggerCallback('qr-bossmenu:server:GetEmployees', function(cb)
        for _, v in pairs(cb) do
            EmployeesMenu[#EmployeesMenu + 1] = {
                header = v.name,
                txt = v.grade.name,
                icon = "fa-solid fa-circle-user",
                params = {
                    event = "qr-bossmenu:client:ManageEmployee",
                    args = {
                        player = v,
                        work = PlayerJob
                    }
                }
            }
        end
        EmployeesMenu[#EmployeesMenu + 1] = {
            header = "Return",
            icon = "fa-solid fa-angle-left",
            params = {
                event = "qr-bossmenu:client:OpenMenu",
            }
        }
        exports['qr-menu']:openMenu(EmployeesMenu)
    end, PlayerJob.name)
end)

RegisterNetEvent('qr-bossmenu:client:ManageEmployee', function(data)
    local EmployeeMenu = {
        {
            header = "Manage " .. data.player.name .. " - " .. string.upper(PlayerJob.label),
            isMenuHeader = true,
            icon = "fa-solid fa-circle-info"
        },
    }
    for k, v in pairs(QRCore.Shared.Jobs[data.work.name].grades) do
        EmployeeMenu[#EmployeeMenu + 1] = {
            header = v.name,
            txt = "Grade: " .. k,
            params = {
                isServer = true,
                event = "qr-bossmenu:server:GradeUpdate",
                icon = "fa-solid fa-file-pen",
                args = {
                    cid = data.player.empSource,
                    grade = tonumber(k),
                    gradename = v.name
                }
            }
        }
    end
    EmployeeMenu[#EmployeeMenu + 1] = {
        header = "Fire Employee",
        icon = "fa-solid fa-user-large-slash",
        params = {
            isServer = true,
            event = "qr-bossmenu:server:FireEmployee",
            args = data.player.empSource
        }
    }
    EmployeeMenu[#EmployeeMenu + 1] = {
        header = "Return",
        icon = "fa-solid fa-angle-left",
        params = {
            event = "qr-bossmenu:client:OpenMenu",
        }
    }
    exports['qr-menu']:openMenu(EmployeeMenu)
end)

RegisterNetEvent('qr-bossmenu:client:Stash', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "boss_" .. PlayerJob.name, {
        maxweight = 4000000,
        slots = 25,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "boss_" .. PlayerJob.name)
end)

RegisterNetEvent('qr-bossmenu:client:Wardrobe', function()
    TriggerEvent('qr-clothing:client:openOutfitMenu')
end)

RegisterNetEvent('qr-bossmenu:client:HireMenu', function()
    local HireMenu = {
        {
            header = "Hire Employees - " .. string.upper(PlayerJob.label),
            isMenuHeader = true,
            icon = "fa-solid fa-circle-info",
        },
    }
    QRCore.Functions.TriggerCallback('qr-bossmenu:getplayers', function(players)
        for _, v in pairs(players) do
            if v and v ~= PlayerId() then
                HireMenu[#HireMenu + 1] = {
                    header = v.name,
                    txt = "Citizen ID: " .. v.citizenid .. " - ID: " .. v.sourceplayer,
                    icon = "fa-solid fa-user-check",
                    params = {
                        isServer = true,
                        event = "qr-bossmenu:server:HireEmployee",
                        args = v.sourceplayer
                    }
                }
            end
        end
        HireMenu[#HireMenu + 1] = {
            header = "Return",
            icon = "fa-solid fa-angle-left",
            params = {
                event = "qr-bossmenu:client:OpenMenu",
            }
        }
        exports['qr-menu']:openMenu(HireMenu)
    end)
end)

RegisterNetEvent('qr-bossmenu:client:SocietyMenu', function()
    QRCore.Functions.TriggerCallback('qr-bossmenu:server:GetAccount', function(cb)
        local SocietyMenu = {
            {
                header = "Balance: $" .. comma_value(cb) .. " - " .. string.upper(PlayerJob.label),
                isMenuHeader = true,
                icon = "fa-solid fa-circle-info",
            },
            {
                header = "Deposit",
                icon = "fa-solid fa-money-bill-transfer",
                txt = "Deposit Money into account",
                params = {
                    event = "qr-bossmenu:client:SocetyDeposit",
                    args = comma_value(cb)
                }
            },
            {
                header = "Withdraw",
                icon = "fa-solid fa-money-bill-transfer",
                txt = "Withdraw Money from account",
                params = {
                    event = "qr-bossmenu:client:SocetyWithDraw",
                    args = comma_value(cb)
                }
            },
            {
                header = "Return",
                icon = "fa-solid fa-angle-left",
                params = {
                    event = "qr-bossmenu:client:OpenMenu",
                }
            },
        }
        exports['qr-menu']:openMenu(SocietyMenu)
    end, PlayerJob.name)
end)

RegisterNetEvent('qr-bossmenu:client:SocetyDeposit', function(money)
    local deposit = exports['qr-input']:ShowInput({
        header = "Deposit Money <br> Available Balance: $" .. money,
        submitText = "Confirm",
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = 'Amount'
            }
        }
    })
    if deposit then
        if not deposit.amount then return end
        TriggerServerEvent("qr-bossmenu:server:depositMoney", tonumber(deposit.amount))
    end
end)

RegisterNetEvent('qr-bossmenu:client:SocetyWithDraw', function(money)
    local withdraw = exports['qr-input']:ShowInput({
        header = "Withdraw Money <br> Available Balance: $" .. money,
        submitText = "Confirm",
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = 'Amount'
            }
        }
    })
    if withdraw then
        if not withdraw.amount then return end
        TriggerServerEvent("qr-bossmenu:server:withdrawMoney", tonumber(withdraw.amount))
    end
end)

--[[
-- MAIN THREAD
CreateThread(function()
    if Config.UseTarget then
        for job, zones in pairs(Config.BossMenuZones) do
            for index, data in ipairs(zones) do
                exports['qr-target']:AddBoxZone(job.."-BossMenu-"..index, data.coords, data.length, data.width, {
                    name = job.."-BossMenu-"..index,
                    heading = data.heading,
                    -- debugPoly = true,
                    minZ = data.minZ,
                    maxZ = data.maxZ,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "qr-bossmenu:client:OpenMenu",
                            icon = "fas fa-sign-in-alt",
                            label = "Boss Menu",
                            canInteract = function() return job == PlayerJob.name and PlayerJob.isboss end,
                        },
                    },
                    distance = 2.5
                })
            end
        end
    else
        while true do
            local wait = 2500
            local pos = GetEntityCoords(PlayerPedId())
            local inRangeBoss = false
            local nearBossmenu = false
            if PlayerJob then
                wait = 0
                for k, menus in pairs(Config.BossMenus) do
                    for _, coords in ipairs(menus) do
                        if k == PlayerJob.name and PlayerJob.isboss then
                            if #(pos - coords) < 5.0 then
                                inRangeBoss = true
                                if #(pos - coords) <= 1.5 then
                                    nearBossmenu = true
                                    if not shownBossMenu then
                                        exports['qr-core']:DrawText('[E] Open Job Management', 'left')
                                        shownBossMenu = true
                                    end
                                    if IsControlJustReleased(0, 38) then
                                        exports['qr-core']:HideText()
                                        TriggerEvent("qr-bossmenu:client:OpenMenu")
                                    end
                                end

                                if not nearBossmenu and shownBossMenu then
                                    CloseMenuFull()
                                    shownBossMenu = false
                                end
                            end
                        end
                    end
                end
                if not inRangeBoss then
                    Wait(1500)
                    if shownBossMenu then
                        CloseMenuFull()
                        shownBossMenu = false
                    end
                end
            end
            Wait(wait)
        end
    end
end)
--]]