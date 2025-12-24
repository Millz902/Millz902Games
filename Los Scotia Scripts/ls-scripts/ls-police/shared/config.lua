-- Police Shared Configuration
Config = Config or {}

Config.Police = {
    -- General Settings
    General = {
        useTarget = true,                -- Use qb-target for interactions
        requireDuty = true,              -- Require on-duty status for police actions
        maxOfficers = 20,                -- Maximum officers online at once
        minOfficersForHeist = 4,         -- Minimum officers for heist alerts
        evidenceExpireTime = 3600,       -- Evidence expires after 1 hour
        jailReleaseTime = 300,           -- Default jail time (5 minutes)
        fineMultiplier = 1.0             -- Fine amount multiplier
    },
    
    -- Police Ranks and Permissions
    Ranks = {
        [1] = { 
            name = 'Cadet', 
            payment = 75,
            permissions = {
                arrest = false,
                search = false,
                impound = false,
                evidence = false,
                mdt = false
            }
        },
        [2] = { 
            name = 'Officer', 
            payment = 100,
            permissions = {
                arrest = true,
                search = true,
                impound = false,
                evidence = true,
                mdt = true
            }
        },
        [3] = { 
            name = 'Senior Officer', 
            payment = 125,
            permissions = {
                arrest = true,
                search = true,
                impound = true,
                evidence = true,
                mdt = true
            }
        },
        [4] = { 
            name = 'Corporal', 
            payment = 150,
            permissions = {
                arrest = true,
                search = true,
                impound = true,
                evidence = true,
                mdt = true,
                hire = false
            }
        },
        [5] = { 
            name = 'Sergeant', 
            payment = 175,
            permissions = {
                arrest = true,
                search = true,
                impound = true,
                evidence = true,
                mdt = true,
                hire = true,
                fire = false
            }
        },
        [6] = { 
            name = 'Lieutenant', 
            payment = 200,
            permissions = {
                arrest = true,
                search = true,
                impound = true,
                evidence = true,
                mdt = true,
                hire = true,
                fire = true,
                promote = false
            }
        },
        [7] = { 
            name = 'Captain', 
            payment = 225,
            permissions = {
                arrest = true,
                search = true,
                impound = true,
                evidence = true,
                mdt = true,
                hire = true,
                fire = true,
                promote = true
            }
        },
        [8] = { 
            name = 'Chief', 
            payment = 250,
            isboss = true,
            permissions = {
                arrest = true,
                search = true,
                impound = true,
                evidence = true,
                mdt = true,
                hire = true,
                fire = true,
                promote = true,
                budget = true
            }
        }
    },
    
    -- Police Stations
    Stations = {
        ['mission_row'] = {
            label = 'Mission Row Police Station',
            coords = vector3(428.23, -984.28, 29.76),
            blip = {
                sprite = 60,
                color = 29,
                scale = 0.8
            },
            garage = vector3(454.6, -1017.4, 28.4),
            armory = vector3(462.23, -981.12, 30.68),
            evidence = vector3(475.45, -996.32, 30.68),
            cells = {
                vector3(477.91, -1012.45, 26.27),
                vector3(480.91, -1012.45, 26.27),
                vector3(483.91, -1012.45, 26.27)
            }
        },
        ['vespucci'] = {
            label = 'Vespucci Police Station',
            coords = vector3(-1096.62, -809.99, 19.00),
            blip = {
                sprite = 60,
                color = 29,
                scale = 0.7
            },
            garage = vector3(-1120.0, -845.0, 13.0),
            armory = vector3(-1106.8, -826.8, 14.28),
            evidence = vector3(-1109.8, -829.8, 14.28),
            cells = {
                vector3(-1115.0, -827.0, 14.28)
            }
        },
        ['sandy_shores'] = {
            label = 'Sandy Shores Sheriff Station',
            coords = vector3(1835.51, 3677.59, 34.28),
            blip = {
                sprite = 60,
                color = 29,
                scale = 0.7
            },
            garage = vector3(1855.0, 3678.0, 33.5),
            armory = vector3(1841.2, 3691.1, 34.28),
            evidence = vector3(1844.2, 3694.1, 34.28),
            cells = {
                vector3(1847.0, 3690.0, 34.28)
            }
        },
        ['paleto'] = {
            label = 'Paleto Bay Sheriff Station',
            coords = vector3(-448.63, 6008.25, 31.72),
            blip = {
                sprite = 60,
                color = 29,
                scale = 0.7
            },
            garage = vector3(-455.0, 6002.0, 31.0),
            armory = vector3(-461.6, 6015.2, 31.72),
            evidence = vector3(-464.6, 6018.2, 31.72),
            cells = {
                vector3(-467.0, 6014.0, 31.72)
            }
        }
    },
    
    -- Police Vehicles
    Vehicles = {
        ['police'] = { label = 'Police Cruiser', category = 'patrol' },
        ['police2'] = { label = 'Police Buffalo', category = 'patrol' },
        ['police3'] = { label = 'Police Interceptor', category = 'patrol' },
        ['police4'] = { label = 'Police Unmarked', category = 'unmarked' },
        ['policeb'] = { label = 'Police Bike', category = 'motorcycle' },
        ['policet'] = { label = 'Police Transport', category = 'transport' },
        ['fbi'] = { label = 'Unmarked SUV', category = 'unmarked' },
        ['fbi2'] = { label = 'Unmarked Buffalo', category = 'unmarked' },
        ['sheriff'] = { label = 'Sheriff Cruiser', category = 'patrol' },
        ['sheriff2'] = { label = 'Sheriff SUV', category = 'patrol' }
    },
    
    -- Evidence Types
    Evidence = {
        ['bullet'] = {
            label = 'Bullet Casing',
            model = 'w_pistol_clip',
            deleteTime = 600, -- 10 minutes
            requiresAnalysis = true
        },
        ['blood'] = {
            label = 'Blood Sample',
            model = 'prop_blood_bag',
            deleteTime = 900, -- 15 minutes
            requiresAnalysis = true
        },
        ['fingerprint'] = {
            label = 'Fingerprint',
            model = 'prop_cs_police_torch',
            deleteTime = 1200, -- 20 minutes
            requiresAnalysis = true
        },
        ['weapon'] = {
            label = 'Weapon Evidence',
            model = nil, -- Uses actual weapon model
            deleteTime = 1800, -- 30 minutes
            requiresAnalysis = false
        },
        ['drugs'] = {
            label = 'Drug Evidence',
            model = nil, -- Uses actual drug model
            deleteTime = 1800, -- 30 minutes
            requiresAnalysis = false
        }
    },
    
    -- Crime Codes and Fines
    Crimes = {
        ['reckless_driving'] = { label = 'Reckless Driving', fine = 500, jailTime = 0 },
        ['speeding'] = { label = 'Speeding', fine = 200, jailTime = 0 },
        ['running_red_light'] = { label = 'Running Red Light', fine = 300, jailTime = 0 },
        ['illegal_parking'] = { label = 'Illegal Parking', fine = 100, jailTime = 0 },
        ['dui'] = { label = 'Driving Under Influence', fine = 1000, jailTime = 10 },
        ['hit_and_run'] = { label = 'Hit and Run', fine = 2000, jailTime = 15 },
        ['theft'] = { label = 'Theft', fine = 1500, jailTime = 20 },
        ['burglary'] = { label = 'Burglary', fine = 3000, jailTime = 30 },
        ['robbery'] = { label = 'Robbery', fine = 5000, jailTime = 45 },
        ['assault'] = { label = 'Assault', fine = 2000, jailTime = 25 },
        ['battery'] = { label = 'Battery', fine = 2500, jailTime = 30 },
        ['murder'] = { label = 'Murder', fine = 10000, jailTime = 120 },
        ['drug_possession'] = { label = 'Drug Possession', fine = 1000, jailTime = 15 },
        ['drug_distribution'] = { label = 'Drug Distribution', fine = 5000, jailTime = 60 },
        ['weapons_possession'] = { label = 'Illegal Weapons', fine = 3000, jailTime = 45 },
        ['resisting_arrest'] = { label = 'Resisting Arrest', fine = 1500, jailTime = 20 },
        ['evading'] = { label = 'Evading Police', fine = 2000, jailTime = 25 },
        ['public_disturbance'] = { label = 'Public Disturbance', fine = 500, jailTime = 5 },
        ['vandalism'] = { label = 'Vandalism', fine = 800, jailTime = 10 },
        ['trespassing'] = { label = 'Trespassing', fine = 600, jailTime = 8 }
    },
    
    -- Alert Types
    Alerts = {
        ['shooting'] = { label = 'Shots Fired', color = 1, blipTime = 300 },
        ['robbery'] = { label = 'Robbery in Progress', color = 1, blipTime = 600 },
        ['assault'] = { label = 'Assault in Progress', color = 3, blipTime = 300 },
        ['vandalism'] = { label = 'Vandalism Report', color = 5, blipTime = 180 },
        ['speeding'] = { label = 'Speeding Vehicle', color = 5, blipTime = 120 },
        ['suspicious'] = { label = 'Suspicious Activity', color = 2, blipTime = 240 },
        ['drug_dealing'] = { label = 'Drug Activity', color = 1, blipTime = 300 },
        ['vehicle_theft'] = { label = 'Vehicle Theft', color = 1, blipTime = 450 },
        ['break_in'] = { label = 'Break In', color = 1, blipTime = 600 },
        ['officer_down'] = { label = 'Officer Down', color = 1, blipTime = 900 }
    },
    
    -- BOLO (Be On Lookout) Types
    BOLO = {
        ['person'] = { label = 'Person BOLO', duration = 3600 },
        ['vehicle'] = { label = 'Vehicle BOLO', duration = 3600 },
        ['property'] = { label = 'Property BOLO', duration = 7200 }
    }
}

-- Police Utilities
PoliceUtils = {}

function PoliceUtils.HasPermission(rank, permission)
    local rankData = Config.Police.Ranks[rank]
    if not rankData then return false end
    
    return rankData.permissions[permission] == true
end

function PoliceUtils.GetRankData(rank)
    return Config.Police.Ranks[rank]
end

function PoliceUtils.CalculateFine(crimeCode, multiplier)
    local crime = Config.Police.Crimes[crimeCode]
    if not crime then return 0 end
    
    multiplier = multiplier or Config.Police.General.fineMultiplier
    return math.floor(crime.fine * multiplier)
end

function PoliceUtils.CalculateJailTime(crimeCode, multiplier)
    local crime = Config.Police.Crimes[crimeCode]
    if not crime then return 0 end
    
    multiplier = multiplier or 1.0
    return math.floor(crime.jailTime * multiplier)
end

function PoliceUtils.IsPoliceVehicle(model)
    for vehicleModel, _ in pairs(Config.Police.Vehicles) do
        if GetHashKey(vehicleModel) == model then
            return true
        end
    end
    return false
end

function PoliceUtils.GetNearestStation(coords)
    local nearestStation = nil
    local nearestDistance = math.huge
    
    for stationId, station in pairs(Config.Police.Stations) do
        local distance = #(coords - station.coords)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestStation = { id = stationId, data = station, distance = distance }
        end
    end
    
    return nearestStation
end

function PoliceUtils.GetStationById(stationId)
    return Config.Police.Stations[stationId]
end

function PoliceUtils.CalculateDistance(coords1, coords2)
    return #(coords1 - coords2)
end

-- Police Events
PoliceEvents = {
    -- Client Events
    Client = {
        DutyToggle = 'ls-police:client:ToggleDuty',
        ShowBadge = 'ls-police:client:ShowBadge',
        Cuff = 'ls-police:client:CuffPlayer',
        Escort = 'ls-police:client:EscortPlayer',
        Search = 'ls-police:client:SearchPlayer',
        JailPlayer = 'ls-police:client:JailPlayer',
        CreateAlert = 'ls-police:client:CreateAlert',
        UpdateAlert = 'ls-police:client:UpdateAlert',
        RemoveAlert = 'ls-police:client:RemoveAlert',
        SpawnVehicle = 'ls-police:client:SpawnVehicle',
        OpenMDT = 'ls-police:client:OpenMDT',
        PlaceEvidence = 'ls-police:client:PlaceEvidence',
        CollectEvidence = 'ls-police:client:CollectEvidence'
    },
    
    -- Server Events
    Server = {
        DutyToggle = 'ls-police:server:ToggleDuty',
        CuffPlayer = 'ls-police:server:CuffPlayer',
        EscortPlayer = 'ls-police:server:EscortPlayer',
        SearchPlayer = 'ls-police:server:SearchPlayer',
        JailPlayer = 'ls-police:server:JailPlayer',
        FinePlayer = 'ls-police:server:FinePlayer',
        CreateAlert = 'ls-police:server:CreateAlert',
        SpawnVehicle = 'ls-police:server:SpawnVehicle',
        ImpoundVehicle = 'ls-police:server:ImpoundVehicle',
        PlaceEvidence = 'ls-police:server:PlaceEvidence',
        CollectEvidence = 'ls-police:server:CollectEvidence',
        AnalyzeEvidence = 'ls-police:server:AnalyzeEvidence',
        CreateBOLO = 'ls-police:server:CreateBOLO',
        RemoveBOLO = 'ls-police:server:RemoveBOLO',
        GetActiveOfficers = 'ls-police:server:GetActiveOfficers'
    }
}

-- Export police configuration for other resources
exports('GetPoliceConfig', function()
    return Config.Police
end)

exports('GetPoliceUtils', function()
    return PoliceUtils
end)

exports('GetPoliceEvents', function()
    return PoliceEvents
end)