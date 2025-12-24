-- Racing Configuration
Config = Config or {}

Config.Racing = {
    -- General Settings
    General = {
        useTarget = true,                -- Use qb-target for interactions
        requireLicense = false,          -- Require racing license
        maxParticipants = 16,            -- Maximum participants per race
        minParticipants = 2,             -- Minimum participants to start
        countdownTime = 10,              -- Race countdown in seconds
        checkpointRadius = 15.0,         -- Checkpoint trigger radius
        maxRaceTime = 1800,              -- Maximum race time (30 minutes)
        enableBetting = true,            -- Enable betting on races
        enableSpectating = true          -- Enable spectator mode
    },
    
    -- Race Types
    RaceTypes = {
        ['circuit'] = {
            label = 'Circuit Race',
            description = 'Multi-lap race around a closed circuit',
            minCheckpoints = 5,
            maxLaps = 10,
            allowedVehicles = { 'sports', 'super', 'muscle' }
        },
        ['sprint'] = {
            label = 'Sprint Race',
            description = 'Point-to-point race',
            minCheckpoints = 3,
            maxLaps = 1,
            allowedVehicles = { 'sports', 'super', 'muscle', 'compacts' }
        },
        ['drag'] = {
            label = 'Drag Race',
            description = 'Straight line acceleration race',
            minCheckpoints = 2,
            maxLaps = 1,
            allowedVehicles = { 'muscle', 'sports', 'super' }
        },
        ['rally'] = {
            label = 'Rally Race',
            description = 'Off-road racing through varied terrain',
            minCheckpoints = 4,
            maxLaps = 3,
            allowedVehicles = { 'off_road', 'suvs' }
        },
        ['street'] = {
            label = 'Street Race',
            description = 'Urban street racing',
            minCheckpoints = 4,
            maxLaps = 2,
            allowedVehicles = { 'sports', 'muscle', 'tuner' }
        },
        ['drift'] = {
            label = 'Drift Competition',
            description = 'Judged on style and technique',
            minCheckpoints = 6,
            maxLaps = 3,
            allowedVehicles = { 'sports', 'muscle', 'tuner' }
        }
    },
    
    -- Vehicle Classes
    VehicleClasses = {
        ['compacts'] = { label = 'Compacts', class = 0 },
        ['sedans'] = { label = 'Sedans', class = 1 },
        ['suvs'] = { label = 'SUVs', class = 2 },
        ['coupes'] = { label = 'Coupes', class = 3 },
        ['muscle'] = { label = 'Muscle', class = 4 },
        ['sports_classics'] = { label = 'Sports Classics', class = 5 },
        ['sports'] = { label = 'Sports', class = 6 },
        ['super'] = { label = 'Super', class = 7 },
        ['motorcycles'] = { label = 'Motorcycles', class = 8 },
        ['off_road'] = { label = 'Off-road', class = 9 },
        ['industrial'] = { label = 'Industrial', class = 10 },
        ['utility'] = { label = 'Utility', class = 11 },
        ['vans'] = { label = 'Vans', class = 12 },
        ['cycles'] = { label = 'Cycles', class = 13 },
        ['boats'] = { label = 'Boats', class = 14 },
        ['helicopters'] = { label = 'Helicopters', class = 15 },
        ['planes'] = { label = 'Planes', class = 16 },
        ['service'] = { label = 'Service', class = 17 },
        ['emergency'] = { label = 'Emergency', class = 18 },
        ['military'] = { label = 'Military', class = 19 },
        ['commercial'] = { label = 'Commercial', class = 20 },
        ['tuner'] = { label = 'Tuner', class = 21 }
    },
    
    -- Racing Tracks (Predefined)
    Tracks = {
        ['downtown_circuit'] = {
            name = 'Downtown Circuit',
            type = 'circuit',
            difficulty = 'medium',
            laps = 3,
            vehicleClass = 'sports',
            entryFee = 500,
            startCoords = vector3(-543.67, -195.55, 38.22),
            checkpoints = {
                vector3(-543.67, -195.55, 38.22),
                vector3(-692.57, -238.64, 36.77),
                vector3(-827.08, -368.39, 35.16),
                vector3(-934.95, -478.93, 37.05),
                vector3(-1027.11, -419.15, 35.42),
                vector3(-1087.52, -256.35, 37.76),
                vector3(-1023.75, -114.29, 38.20),
                vector3(-854.32, -46.93, 38.93),
                vector3(-651.42, -116.88, 37.91),
                vector3(-543.67, -195.55, 38.22)
            },
            rewards = {
                [1] = 2500, -- 1st place
                [2] = 1500, -- 2nd place
                [3] = 1000  -- 3rd place
            }
        },
        ['highway_sprint'] = {
            name = 'Highway Sprint',
            type = 'sprint',
            difficulty = 'easy',
            laps = 1,
            vehicleClass = 'super',
            entryFee = 1000,
            startCoords = vector3(-2547.95, 2327.11, 33.06),
            checkpoints = {
                vector3(-2547.95, 2327.11, 33.06),
                vector3(-2158.32, 2531.78, 29.54),
                vector3(-1654.87, 2654.91, 3.16),
                vector3(-1079.25, 2712.50, 18.79),
                vector3(-564.11, 2827.42, 17.80),
                vector3(62.89, 2894.79, 41.67),
                vector3(692.15, 2950.78, 40.69),
                vector3(1285.34, 3025.11, 40.33)
            },
            rewards = {
                [1] = 5000,
                [2] = 3000,
                [3] = 2000
            }
        },
        ['mountain_rally'] = {
            name = 'Mount Chiliad Rally',
            type = 'rally',
            difficulty = 'hard',
            laps = 2,
            vehicleClass = 'off_road',
            entryFee = 750,
            startCoords = vector3(-1577.14, 4458.70, 23.31),
            checkpoints = {
                vector3(-1577.14, 4458.70, 23.31),
                vector3(-1398.77, 4671.25, 62.34),
                vector3(-1082.45, 4920.15, 218.65),
                vector3(-741.23, 5148.89, 151.86),
                vector3(-351.45, 5289.12, 82.45),
                vector3(145.67, 5312.89, 83.67),
                vector3(432.11, 5156.78, 152.34),
                vector3(689.23, 4834.56, 201.45),
                vector3(845.67, 4512.34, 156.78),
                vector3(967.89, 4234.56, 89.23)
            },
            rewards = {
                [1] = 4000,
                [2] = 2500,
                [3] = 1500
            }
        },
        ['airport_drag'] = {
            name = 'Airport Drag Strip',
            type = 'drag',
            difficulty = 'easy',
            laps = 1,
            vehicleClass = 'muscle',
            entryFee = 300,
            startCoords = vector3(-1267.0, -3013.0, 13.94),
            checkpoints = {
                vector3(-1267.0, -3013.0, 13.94),
                vector3(-1267.0, -2713.0, 13.94)
            },
            rewards = {
                [1] = 1500,
                [2] = 900,
                [3] = 600
            }
        }
    },
    
    -- Performance Tuning
    Performance = {
        enabled = true,
        categories = {
            ['engine'] = {
                label = 'Engine',
                upgrades = {
                    [1] = { label = 'Stock', modifier = 1.0, price = 0 },
                    [2] = { label = 'Stage 1', modifier = 1.05, price = 5000 },
                    [3] = { label = 'Stage 2', modifier = 1.10, price = 10000 },
                    [4] = { label = 'Stage 3', modifier = 1.15, price = 20000 }
                }
            },
            ['transmission'] = {
                label = 'Transmission',
                upgrades = {
                    [1] = { label = 'Stock', modifier = 1.0, price = 0 },
                    [2] = { label = 'Street', modifier = 1.03, price = 3000 },
                    [3] = { label = 'Sport', modifier = 1.06, price = 6000 },
                    [4] = { label = 'Race', modifier = 1.09, price = 12000 }
                }
            },
            ['turbo'] = {
                label = 'Turbo',
                upgrades = {
                    [1] = { label = 'None', modifier = 1.0, price = 0 },
                    [2] = { label = 'Turbo', modifier = 1.12, price = 15000 }
                }
            }
        }
    },
    
    -- Betting System
    Betting = {
        enabled = true,
        minBet = 100,
        maxBet = 10000,
        houseEdge = 0.05, -- 5% house edge
        payoutRates = {
            [1] = 2.0,  -- 1st place odds
            [2] = 3.0,  -- 2nd place odds
            [3] = 5.0,  -- 3rd place odds
            [4] = 10.0, -- 4th place odds
            [5] = 20.0  -- 5th+ place odds
        }
    },
    
    -- Racing License
    License = {
        required = false,
        price = 5000,
        testTrack = 'downtown_circuit',
        passingTime = 180, -- 3 minutes
        renewalTime = 2592000 -- 30 days
    },
    
    -- Statistics
    Statistics = {
        trackRecords = true,
        personalBests = true,
        seasonalLeaderboards = true,
        achievements = true
    },
    
    -- Rewards and Prizes
    Rewards = {
        participation = 50,    -- Base participation reward
        positionMultiplier = { -- Multiplier based on position
            [1] = 3.0,
            [2] = 2.0,
            [3] = 1.5,
            [4] = 1.2,
            [5] = 1.0
        },
        newRecord = 1000,     -- Bonus for setting new record
        perfectRace = 500,    -- Bonus for no collisions
        reputation = {        -- Reputation points per race
            participation = 1,
            win = 5,
            podium = 3,
            record = 10
        }
    }
}

-- Racing Utilities
RacingUtils = {}

function RacingUtils.GetVehicleClass(vehicle)
    local model = GetEntityModel(vehicle)
    local class = GetVehicleClass(model)
    
    for className, classData in pairs(Config.Racing.VehicleClasses) do
        if classData.class == class then
            return className
        end
    end
    
    return 'unknown'
end

function RacingUtils.IsVehicleAllowed(vehicle, allowedClasses)
    local vehicleClass = RacingUtils.GetVehicleClass(vehicle)
    
    for _, allowedClass in pairs(allowedClasses) do
        if vehicleClass == allowedClass then
            return true
        end
    end
    
    return false
end

function RacingUtils.CalculateDistance(coords1, coords2)
    return #(coords1 - coords2)
end

function RacingUtils.GetTrackDistance(checkpoints)
    local totalDistance = 0
    
    for i = 1, #checkpoints - 1 do
        totalDistance = totalDistance + RacingUtils.CalculateDistance(checkpoints[i], checkpoints[i + 1])
    end
    
    return totalDistance
end

function RacingUtils.FormatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    local ms = math.floor((secs % 1) * 1000)
    secs = math.floor(secs)
    
    return string.format('%02d:%02d.%03d', minutes, secs, ms)
end

function RacingUtils.CalculateSpeed(distance, time)
    if time <= 0 then return 0 end
    return (distance / time) * 3.6 -- Convert m/s to km/h
end

function RacingUtils.GetRaceTypeConfig(raceType)
    return Config.Racing.RaceTypes[raceType]
end

function RacingUtils.GetTrackData(trackId)
    return Config.Racing.Tracks[trackId]
end

function RacingUtils.CalculatePayout(entryFee, participants, position)
    local totalPrize = entryFee * participants
    local multiplier = Config.Racing.Rewards.positionMultiplier[position] or 0.5
    
    return math.floor(totalPrize * multiplier)
end

function RacingUtils.CalculateBettingOdds(participants, favoritePosition)
    local baseOdds = Config.Racing.Betting.payoutRates
    local odds = {}
    
    for i = 1, participants do
        if i == favoritePosition then
            odds[i] = baseOdds[1] or 2.0
        else
            odds[i] = baseOdds[math.min(i, #baseOdds)] or 20.0
        end
    end
    
    return odds
end

-- Racing Events
RacingEvents = {
    -- Client Events
    Client = {
        UpdateRaceData = 'ls-racing:client:UpdateRaceData',
        StartRace = 'ls-racing:client:StartRace',
        EndRace = 'ls-racing:client:EndRace',
        RaceCountdown = 'ls-racing:client:RaceCountdown',
        CheckpointPassed = 'ls-racing:client:CheckpointPassed',
        RefreshRaces = 'ls-racing:client:RefreshRaces',
        CreateRace = 'ls-racing:client:CreateRace',
        ShowAvailableRaces = 'ls-racing:client:ShowAvailableRaces',
        ShowRaceStats = 'ls-racing:client:ShowRaceStats',
        ShowRaceHistory = 'ls-racing:client:ShowRaceHistory',
        ShowLeaderboards = 'ls-racing:client:ShowLeaderboards',
        RepairVehicle = 'ls-racing:client:RepairVehicle',
        RefuelVehicle = 'ls-racing:client:RefuelVehicle',
        TuneVehicle = 'ls-racing:client:TuneVehicle'
    },
    
    -- Server Events
    Server = {
        GetRaces = 'ls-racing:server:GetRaces',
        CreateRace = 'ls-racing:server:CreateRace',
        JoinRace = 'ls-racing:server:JoinRace',
        LeaveRace = 'ls-racing:server:LeaveRace',
        StartRace = 'ls-racing:server:StartRace',
        CancelRace = 'ls-racing:server:CancelRace',
        CheckpointPassed = 'ls-racing:server:CheckpointPassed',
        GetAvailableRaces = 'ls-racing:server:GetAvailableRaces',
        GetRaceStats = 'ls-racing:server:GetRaceStats',
        GetRaceHistory = 'ls-racing:server:GetRaceHistory',
        GetLeaderboards = 'ls-racing:server:GetLeaderboards',
        PlaceBet = 'ls-racing:server:PlaceBet',
        PayoutBets = 'ls-racing:server:PayoutBets',
        GetLicense = 'ls-racing:server:GetLicense',
        RenewLicense = 'ls-racing:server:RenewLicense'
    }
}

-- Export racing configuration for other resources
exports('GetRacingConfig', function()
    return Config.Racing
end)

exports('GetRacingUtils', function()
    return RacingUtils
end)

exports('GetRacingEvents', function()
    return RacingEvents
end)