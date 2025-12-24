-- Los Scotia Gang Management Configuration
Config = {}

-- Gang Settings
Config.Gangs = {
    ['ballas'] = {
        name = 'Ballas',
        color = '#663399',
        territory = vector3(84.91, -1961.14, 21.12),
        radius = 150.0,
        blip = 84,
        vehicles = {'panto', 'sultan'},
        weapons = {'weapon_pistol', 'weapon_knife'},
        ranks = {
            [1] = 'Prospect',
            [2] = 'Member', 
            [3] = 'Enforcer',
            [4] = 'Lieutenant',
            [5] = 'Boss'
        }
    },
    ['vagos'] = {
        name = 'Vagos',
        color = '#FFFF00',
        territory = vector3(334.65, -2039.23, 21.35),
        radius = 150.0,
        blip = 84,
        vehicles = {'tornado', 'peyote'},
        weapons = {'weapon_pistol', 'weapon_knife'},
        ranks = {
            [1] = 'Prospect',
            [2] = 'Member',
            [3] = 'Enforcer', 
            [4] = 'Lieutenant',
            [5] = 'Boss'
        }
    },
    ['families'] = {
        name = 'Families',
        color = '#00FF00',
        territory = vector3(-179.21, -1618.85, 33.18),
        radius = 150.0,
        blip = 84,
        vehicles = {'greenwood', 'voodoo'},
        weapons = {'weapon_pistol', 'weapon_knife'},
        ranks = {
            [1] = 'Prospect',
            [2] = 'Member',
            [3] = 'Enforcer',
            [4] = 'Lieutenant', 
            [5] = 'Boss'
        }
    }
}

-- Territory Settings
Config.TerritoryContest = true
Config.ContestTime = 300 -- 5 minutes
Config.MinMembersForContest = 3

-- Drug Dealing
Config.DrugDealing = {
    enabled = true,
    locations = {
        vector3(85.44, -1959.73, 21.12),
        vector3(334.12, -2041.55, 21.35),
        vector3(-181.44, -1620.12, 33.18)
    },
    drugs = {
        ['weed'] = {price = 150, rep = 1},
        ['coke'] = {price = 300, rep = 2},
        ['meth'] = {price = 250, rep = 2}
    }
}

-- Gang Wars
Config.GangWars = {
    enabled = true,
    cooldown = 3600, -- 1 hour
    duration = 1800, -- 30 minutes
    rewards = {
        money = {min = 5000, max = 15000},
        rep = {min = 10, max = 25}
    }
}