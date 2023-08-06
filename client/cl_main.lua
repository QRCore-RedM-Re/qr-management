local qrc = require('modules.client')

RegisterNetEvent('qr-management:client:Wardrobe', function()
    TriggerEvent('qr_clothes:OpenOutfits')
end)

local function PlayerLoad()
    PlayerGang = QRCore.Functions.GetPlayerData().gang
    PlayerJob = QRCore.Functions.GetPlayerData().job
    qrc.GangLocations()
    qrc.BossLocations()
end

local function PlayerUnload()
    PlayerGang = {}
    PlayerJob = {}
    qrc.CleanupGangLocations()
    qrc.CleanupBossLocations()
end

-- Resource / Player Events --
AddEventHandler('onResourceStart', function(resource) if resource == GetCurrentResourceName() then PlayerLoad() end end)
AddEventHandler('onResourceStop', function(resource) if resource == GetCurrentResourceName() then PlayerUnload() end end)
RegisterNetEvent('QRCore:Client:OnPlayerLoaded', function() PlayerLoad() end)
RegisterNetEvent('QRCore:Client:OnGangUpdate', function(InfoGang) PlayerGang = InfoGang qrc.GangLocations() end)
RegisterNetEvent('QRCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo qrc.BossLocations() end)