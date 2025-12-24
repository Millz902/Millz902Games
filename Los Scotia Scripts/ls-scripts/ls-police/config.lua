Config = {}

-- Police Station Locations
Config.PoliceStations = {
    ["LSPD"] = {
        coords = vector3(428.23, -984.28, 29.76),
        blipCoords = vector3(428.23, -984.28, 29.76),
        blipSprite = 60,
        blipScale = 1.0,
        blipColor = 29,
        label = "Los Santos Police Department"
    },
    ["BCSO"] = {
        coords = vector3(1853.04, 3682.86, 34.26),
        blipCoords = vector3(1853.04, 3682.86, 34.26),
        blipSprite = 60,
        blipScale = 1.0,
        blipColor = 29,
        label = "Blaine County Sheriff's Office"
    },
    ["PBPD"] = {
        coords = vector3(-448.80, 6014.25, 31.71),
        blipCoords = vector3(-448.80, 6014.25, 31.71),
        blipSprite = 60,
        blipScale = 1.0,
        blipColor = 29,
        label = "Paleto Bay Police Department"
    }
}

-- Police Vehicle Spawns
Config.VehicleSpawns = {
    ["LSPD"] = {
        {coords = vector4(454.6, -1017.4, 28.4, 90.0), model = "police"},
        {coords = vector4(441.0, -1024.2, 28.3, 0.0), model = "police2"},
        {coords = vector4(438.4, -1018.3, 27.7, 180.0), model = "police3"}
    },
    ["BCSO"] = {
        {coords = vector4(1867.5, 3696.0, 33.5, 210.0), model = "sheriff"},
        {coords = vector4(1875.0, 3692.0, 33.5, 210.0), model = "sheriff2"}
    },
    ["PBPD"] = {
        {coords = vector4(-455.39, 6002.42, 31.34, 315.0), model = "police"}
    }
}

-- Armory Locations
Config.Armory = {
    ["LSPD"] = {
        coords = vector3(462.23, -981.12, 30.69),
        weapons = {
            {name = "weapon_pistol", price = 0, amount = 250},
            {name = "weapon_combatpistol", price = 0, amount = 250},
            {name = "weapon_nightstick", price = 0, amount = 1},
            {name = "weapon_flashlight", price = 0, amount = 1},
            {name = "weapon_stungun", price = 0, amount = 1},
            {name = "weapon_carbinerifle", price = 0, amount = 250},
            {name = "weapon_pumpshotgun", price = 0, amount = 200}
        },
        items = {
            {name = "radio", price = 0, amount = 1},
            {name = "armor", price = 0, amount = 5},
            {name = "handcuffs", price = 0, amount = 5},
            {name = "mdt", price = 0, amount = 1}
        }
    }
}

-- Evidence Storage
Config.EvidenceStorage = {
    ["LSPD"] = {
        coords = vector3(475.9, -996.4, 26.27),
        maxSlots = 100,
        maxWeight = 5000
    }
}

-- K9 Unit Spawns
Config.K9Spawns = {
    ["LSPD"] = {
        coords = vector3(447.5, -974.1, 25.7),
        model = "rottweiler"
    }
}

-- MDT Configuration
Config.MDT = {
    ipAddress = "127.0.0.1",
    port = 3000,
    enableFingerprint = true,
    enableMugshot = true,
    enableReports = true
}

-- Alert System
Config.Alerts = {
    blipTime = 60000, -- 1 minute
    fadeTime = 180000, -- 3 minutes
    showDispatcher = true,
    enableGPS = true
}

-- ALPR System
Config.ALPR = {
    scanDistance = 25.0,
    scanInterval = 2000,
    enableBOLO = true,
    enableAutoBOLO = true
}

-- Required Police Jobs
Config.PoliceJobs = {
    "police",
    "bcso",
    "state",
    "marshal"
}

-- Minimum Police Count for certain actions
Config.MinPolice = {
    arrest = 0,
    fine = 0,
    impound = 1,
    raid = 2
}