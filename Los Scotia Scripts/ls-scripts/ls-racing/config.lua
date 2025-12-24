-- Los Scotia Racing System Configuration
Config = {}

-- Racing Settings
Config.MinRacers = 2
Config.MaxRacers = 8
Config.CountdownTime = 10
Config.CheckpointRadius = 15.0
Config.FinishRadius = 20.0

-- Race Types
Config.RaceTypes = {
    ['street'] = {
        name = 'Street Racing',
        buyIn = 1000,
        firstPlace = 5000,
        secondPlace = 2000,
        thirdPlace = 1000
    },
    ['drift'] = {
        name = 'Drift Racing',
        buyIn = 1500,
        firstPlace = 7500,
        secondPlace = 3000,
        thirdPlace = 1500
    },
    ['drag'] = {
        name = 'Drag Racing', 
        buyIn = 2000,
        firstPlace = 10000,
        secondPlace = 4000,
        thirdPlace = 2000
    },
    ['circuit'] = {
        name = 'Circuit Racing',
        buyIn = 2500,
        firstPlace = 12500,
        secondPlace = 5000,
        thirdPlace = 2500
    }
}

-- Predefined Race Tracks
Config.Tracks = {
    ['downtown_circuit'] = {
        name = 'Downtown Circuit',
        type = 'circuit',
        laps = 3,
        checkpoints = {
            vector3(215.11, -809.65, 30.31),
            vector3(402.52, -974.23, 29.42),
            vector3(434.78, -1017.56, 28.75),
            vector3(219.87, -1047.93, 29.21),
            vector3(-25.43, -1089.74, 26.42),
            vector3(-280.15, -1035.87, 30.21),
            vector3(-423.78, -683.45, 33.21),
            vector3(-265.43, -612.87, 33.21),
            vector3(104.87, -743.21, 45.75)
        }
    },
    ['highway_sprint'] = {
        name = 'Highway Sprint',
        type = 'street',
        laps = 1,
        checkpoints = {
            vector3(1161.12, -3350.43, 5.87),
            vector3(1738.45, -3285.67, 5.87),
            vector3(2487.89, -3269.12, 5.87),
            vector3(2715.34, -3453.78, 5.87),
            vector3(2789.67, -3789.23, 5.87)
        }
    },
    ['mountain_drift'] = {
        name = 'Mountain Drift',
        type = 'drift',
        laps = 2,
        checkpoints = {
            vector3(-1651.23, 4746.87, 25.34),
            vector3(-1489.67, 4978.45, 65.87),
            vector3(-1278.34, 5123.67, 89.23),
            vector3(-987.56, 5234.89, 145.67),
            vector3(-743.21, 5398.45, 187.34),
            vector3(-456.78, 5567.89, 234.67)
        }
    },
    ['airport_drag'] = {
        name = 'Airport Drag',
        type = 'drag',
        laps = 1,
        checkpoints = {
            vector3(-1286.45, -3387.67, 13.94),
            vector3(-1678.89, -3387.67, 13.94)
        }
    }
}

-- Vehicle Classes
Config.VehicleClasses = {
    [0] = 'Compacts',
    [1] = 'Sedans',
    [2] = 'SUVs',
    [3] = 'Coupes',
    [4] = 'Muscle',
    [5] = 'Sports Classics',
    [6] = 'Sports',
    [7] = 'Super',
    [8] = 'Motorcycles',
    [9] = 'Off-road',
    [10] = 'Industrial',
    [11] = 'Utility',
    [12] = 'Vans',
    [13] = 'Cycles',
    [14] = 'Boats',
    [15] = 'Helicopters',
    [16] = 'Planes',
    [17] = 'Service',
    [18] = 'Emergency',
    [19] = 'Military',
    [20] = 'Commercial',
    [21] = 'Trains'
}

-- Tuning Shop Locations
Config.TuningShops = {
    {
        name = 'Los Santos Customs',
        coords = vector3(-373.71, -124.33, 38.68),
        blip = true
    },
    {
        name = 'Benny\'s Motorworks', 
        coords = vector3(-205.68, -1307.95, 31.29),
        blip = true
    }
}

-- Racing Reputation System
Config.Reputation = {
    enabled = true,
    races_per_level = 5,
    max_level = 50,
    bonuses = {
        [10] = {money = 500, message = 'Racing Novice - $500 bonus!'},
        [25] = {money = 1000, message = 'Racing Expert - $1000 bonus!'},
        [50] = {money = 2500, message = 'Racing Legend - $2500 bonus!'}
    }
}