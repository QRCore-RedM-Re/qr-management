-- Zones for Menues
Config = Config or {}

Config.UseTarget = false -- Use qr-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.BossMenus = {
    ['police'] = {
        vector3(-275.03, 805.57, 119.38),
    },
    -- ['ambulance'] = {
    --     vector3(-1850.79, -337.78, 49.45),
    -- },
    -- ['realestate'] = {
    --     vector3(-716.11, 261.21, 84.14),
    -- },
    -- ['taxi'] = {
    --     vector3(907.24, -150.19, 74.17),
    -- },
    -- ['cardealer'] = {
    --     vector3(-27.47, -1107.13, 27.27),
    -- },
    -- ['mechanic'] = {
    --     vector3(-339.53, -156.44, 44.59),
    -- },
}

Config.BossMenuZones = {
    ['police'] = {
        { coords = vector3(-275.03, 805.57, 119.38), length = 0, width = 0, heading = 0, minZ = 0, maxZ = 0 } ,
    },
    -- ['ambulance'] = {
    --     { coords = vector3(-1850.79, -337.78, 49.45), length = 1.2, width = 0.6, heading = 341.0, minZ = 43.13, maxZ = 43.73 },
    -- },
    -- ['realestate'] = {
    --     { coords = vector3(-716.11, 261.21, 84.14), length = 0.6, width = 1.0, heading = 25.0, minZ = 83.943, maxZ = 84.74 },
    -- },
    -- ['taxi'] = {
    --     { coords = vector3(907.24, -150.19, 74.17), length = 1.0, width = 3.4, heading = 327.0, minZ = 73.17, maxZ = 74.57 },
    -- },
    -- ['cardealer'] = {
    --     { coords = vector3(-27.47, -1107.13, 27.27), length = 2.4, width = 1.05, heading = 340.0, minZ = 27.07, maxZ = 27.67 },
    -- },
    -- ['mechanic'] = {
    --     { coords = vector3(-339.53, -156.44, 44.59), length = 1.15, width = 2.6, heading = 353.0, minZ = 43.59, maxZ = 44.99 },
    -- },
}

Config.GangMenus = {
    ['odriscoll'] = {
        vector3(-4787.05, -2751.66, -14.56),
    },
    ['ballas'] = {
        vector3(0,0, 0),
    },
    ['vagos'] = {
        vector3(0, 0, 0),
    },
    ['cartel'] = {
        vector3(0, 0, 0),
    },
    ['families'] = {
        vector3(0, 0, 0),
    },
}

Config.GangMenuZones = {

    ['odriscoll'] = {
        { coords = vector3(-4787.05, -2751.66, -14.56), length = 0.0, width = 0.0, heading = 0.0, minZ = 0.0, maxZ = 0.0 },
    },

}
