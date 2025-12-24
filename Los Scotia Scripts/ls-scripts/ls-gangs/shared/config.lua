local QBShared = exports['qb-core']:GetCoreObject().Shared

-- Gang Configuration
QBShared.Gangs = {
    ['ballas'] = {
        label = 'Ballas',
        grades = {
            [0] = { name = 'Recruit', payment = 50 },
            [1] = { name = 'Member', payment = 100 },
            [2] = { name = 'Lieutenant', payment = 150 },
            [3] = { name = 'Boss', payment = 200, isboss = true }
        }
    },
    ['families'] = {
        label = 'Families',
        grades = {
            [0] = { name = 'Recruit', payment = 50 },
            [1] = { name = 'Member', payment = 100 },
            [2] = { name = 'Lieutenant', payment = 150 },
            [3] = { name = 'Boss', payment = 200, isboss = true }
        }
    },
    ['vagos'] = {
        label = 'Vagos',
        grades = {
            [0] = { name = 'Recruit', payment = 50 },
            [1] = { name = 'Member', payment = 100 },
            [2] = { name = 'Lieutenant', payment = 150 },
            [3] = { name = 'Boss', payment = 200, isboss = true }
        }
    },
    ['bloods'] = {
        label = 'Bloods',
        grades = {
            [0] = { name = 'Recruit', payment = 50 },
            [1] = { name = 'Member', payment = 100 },
            [2] = { name = 'Lieutenant', payment = 150 },
            [3] = { name = 'Boss', payment = 200, isboss = true }
        }
    }
}

-- Gang Territory Configuration
Config = Config or {}

Config.Gangs = {
    -- Gang Colors
    Colors = {
        ['ballas'] = { r = 128, g = 0, b = 128 },    -- Purple
        ['families'] = { r = 0, g = 128, b = 0 },    -- Green
        ['vagos'] = { r = 255, g = 255, b = 0 },     -- Yellow
        ['bloods'] = { r = 255, g = 0, b = 0 }       -- Red
    },
    
    -- Gang Territories
    Territories = {
        ['grove_street'] = {
            name = 'Grove Street',
            coords = vector3(-127.7, -1739.1, 29.3),
            radius = 150.0,
            gang = 'ballas',
            blip = {
                sprite = 84,
                scale = 0.8,
                color = 27
            }
        },
        ['chamberlain_hills'] = {
            name = 'Chamberlain Hills',
            coords = vector3(-1396.8, -669.5, 27.9),
            radius = 120.0,
            gang = 'families',
            blip = {
                sprite = 84,
                scale = 0.8,
                color = 25
            }
        },
        ['rancho'] = {
            name = 'Rancho',
            coords = vector3(489.9, -1536.5, 29.3),
            radius = 130.0,
            gang = 'vagos',
            blip = {
                sprite = 84,
                scale = 0.8,
                color = 5
            }
        },
        ['strawberry'] = {
            name = 'Strawberry',
            coords = vector3(252.5, -1746.8, 29.7),
            radius = 140.0,
            gang = 'bloods',
            blip = {
                sprite = 84,
                scale = 0.8,
                color = 1
            }
        }
    },
    
    -- Gang War Settings
    Wars = {
        duration = 3600, -- 1 hour in seconds
        minMembers = 3,  -- Minimum members online to start war
        killReward = 100, -- Money reward per kill
        winReward = 5000, -- Money reward for winning gang
        cooldown = 7200   -- 2 hours cooldown between wars
    },
    
    -- Drug Dealing Settings
    Drugs = {
        sellChance = 70,     -- 70% chance of successful sale
        policeAlertChance = 30, -- 30% chance of police alert on failed sale
        prices = {
            ['weed_brick'] = { min = 80, max = 120 },
            ['coke_brick'] = { min = 250, max = 350 },
            ['meth'] = { min = 150, max = 250 }
        },
        reputation = {
            sellSuccess = 1,
            sellFail = -1,
            warKill = 5,
            warWin = 20
        }
    },
    
    -- Gang Stash Settings
    Stash = {
        maxWeight = 1000000, -- 1000kg
        slots = 50
    },
    
    -- Gang Vehicle Settings
    Vehicles = {
        ['ballas'] = {
            spawn = vector4(-132.0, -1750.0, 29.0, 140.0),
            vehicles = { 'oracle', 'oracle2', 'sultan', 'sultan2' }
        },
        ['families'] = {
            spawn = vector4(-1400.0, -675.0, 27.5, 210.0),
            vehicles = { 'buccaneer', 'buccaneer2', 'voodoo', 'voodoo2' }
        },
        ['vagos'] = {
            spawn = vector4(495.0, -1540.0, 29.0, 50.0),
            vehicles = { 'tornado', 'tornado2', 'tornado3', 'tornado4' }
        },
        ['bloods'] = {
            spawn = vector4(258.0, -1750.0, 29.0, 340.0),
            vehicles = { 'faction', 'faction2', 'faction3', 'virgo' }
        }
    }
}

-- Gang Utilities
GangUtils = {}

function GangUtils.IsPlayerInGang(citizenid, gangName)
    -- This would typically check the database or player data
    return false
end

function GangUtils.GetGangColor(gangName)
    return Config.Gangs.Colors[gangName] or { r = 255, g = 255, b = 255 }
end

function GangUtils.GetGangMembers(gangName)
    -- This would typically query the database
    return {}
end

function GangUtils.GetGangReputation(gangName)
    -- This would typically query the database
    return 0
end

function GangUtils.CalculateDistance(coords1, coords2)
    return #(coords1 - coords2)
end

function GangUtils.IsInTerritory(coords, territoryName)
    local territory = Config.Gangs.Territories[territoryName]
    if not territory then return false end
    
    local distance = GangUtils.CalculateDistance(coords, territory.coords)
    return distance <= territory.radius
end

function GangUtils.GetTerritoryByCoords(coords)
    for territoryName, territory in pairs(Config.Gangs.Territories) do
        if GangUtils.IsInTerritory(coords, territoryName) then
            return territoryName, territory
        end
    end
    return nil, nil
end

-- Gang Events
GangEvents = {
    -- Client Events
    Client = {
        UpdateGangData = 'ls-gangs:client:UpdateGangData',
        EnterTerritory = 'ls-gangs:client:EnterTerritory',
        ExitTerritory = 'ls-gangs:client:ExitTerritory',
        StartGangWar = 'ls-gangs:client:StartGangWar',
        EndGangWar = 'ls-gangs:client:EndGangWar',
        RefreshTerritories = 'ls-gangs:client:RefreshTerritories',
        ShowGangInfo = 'ls-gangs:client:ShowGangInfo',
        ShowGangMembers = 'ls-gangs:client:ShowGangMembers',
        ShowTerritories = 'ls-gangs:client:ShowTerritories',
        ReceiveRecruitmentOffer = 'ls-gangs:client:ReceiveRecruitmentOffer'
    },
    
    -- Server Events
    Server = {
        GetGangData = 'ls-gangs:server:GetGangData',
        GetGangTerritories = 'ls-gangs:server:GetGangTerritories',
        DeclareWar = 'ls-gangs:server:DeclareWar',
        GetGangStatus = 'ls-gangs:server:GetGangStatus',
        SellDrugs = 'ls-gangs:server:SellDrugs',
        RecruitPlayer = 'ls-gangs:server:RecruitPlayer',
        AcceptRecruitment = 'ls-gangs:server:AcceptRecruitment',
        GetGangInfo = 'ls-gangs:server:GetGangInfo',
        GetGangMembers = 'ls-gangs:server:GetGangMembers',
        GetTerritories = 'ls-gangs:server:GetTerritories'
    }
}

-- Export gang configuration for other resources
exports('GetGangConfig', function()
    return Config.Gangs
end)

exports('GetGangUtils', function()
    return GangUtils
end)

exports('GetGangEvents', function()
    return GangEvents
end)