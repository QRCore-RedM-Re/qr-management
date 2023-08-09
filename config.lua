Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'

Config.DebugPoly = false

Config.PromptKey = 'J'

Config.BossLocations = {
    ['police'] = {
        blip = { showBlip = true, text = 'Boss Menu', icon = 1321928545, size = 0.5 },
        location = { coords = vec3(-276.76, 804.58, 119.34), radius = 0.3 }
    }
}

Config.GangLocations = {
    ['example'] = {
        blip = { showBlip = true, text = 'Gang Menu', icon = 1321928545, size = 0.5 },
        location = { coords = vec3(-63.73, -392.59, 72.22), radius = 0.3 }
    }
}

---------------------------------------------

QRCore = exports['qr-core']:GetCoreObject()
SharedJobs = QRCore.Shared.GetJobs()
SharedGangs = QRCore.Shared.GetGangs()