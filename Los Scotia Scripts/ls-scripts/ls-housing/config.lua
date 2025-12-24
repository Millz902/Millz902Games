-- Los Scotia Housing System Configuration
Config = {}

-- Housing Settings
Config.MaxHousesPerPlayer = 3
Config.RentDueTime = 7 * 24 * 60 * 60 -- 7 days in seconds
Config.MaxRoomates = 4
Config.StorageSize = 100 -- inventory slots

-- Property Types
Config.PropertyTypes = {
    ['apartment'] = {
        name = 'Apartment',
        rentPrice = 500,
        buyPrice = 50000,
        storage = 50,
        garage = false
    },
    ['house'] = {
        name = 'House',
        rentPrice = 1000,
        buyPrice = 150000,
        storage = 100,
        garage = true
    },
    ['mansion'] = {
        name = 'Mansion',
        rentPrice = 2500,
        buyPrice = 500000,
        storage = 200,
        garage = true
    },
    ['penthouse'] = {
        name = 'Penthouse',
        rentPrice = 3000,
        buyPrice = 750000,
        storage = 150,
        garage = true
    }
}

-- Property Locations
Config.Properties = {
    -- Apartments
    {
        id = 1,
        name = 'Tinsel Towers Apt 42',
        type = 'apartment',
        coords = vector3(-618.29, 37.36, 43.59),
        owned = false,
        price = 50000,
        rent = 500
    },
    {
        id = 2,
        name = 'Eclipse Towers Apt 5',
        type = 'apartment', 
        coords = vector3(-773.89, 341.73, 196.68),
        owned = false,
        price = 75000,
        rent = 750
    },
    {
        id = 3,
        name = 'Richards Majestic Apt 51',
        type = 'apartment',
        coords = vector3(-936.19, -378.2, 113.67),
        owned = false,
        price = 65000,
        rent = 650
    },
    
    -- Houses
    {
        id = 4,
        name = 'Franklin\'s House',
        type = 'house',
        coords = vector3(-14.33, -1441.1, 31.1),
        owned = false,
        price = 200000,
        rent = 1500
    },
    {
        id = 5,
        name = 'Grove Street House',
        type = 'house',
        coords = vector3(-174.22, -1579.54, 34.21),
        owned = false,
        price = 175000,
        rent = 1250
    },
    {
        id = 6,
        name = 'Vinewood Hills House',
        type = 'house',
        coords = vector3(1259.14, -606.07, 69.65),
        owned = false,
        price = 350000,
        rent = 2000
    },
    
    -- Mansions
    {
        id = 7,
        name = 'Richman Mansion',
        type = 'mansion',
        coords = vector3(-1289.23, 459.86, 97.02),
        owned = false,
        price = 800000,
        rent = 4000
    },
    {
        id = 8,
        name = 'Vinewood Hills Mansion',
        type = 'mansion',
        coords = vector3(-174.35, 497.86, 137.65),
        owned = false,
        price = 1000000,
        rent = 5000
    },
    
    -- Penthouses
    {
        id = 9,
        name = 'Eclipse Towers Penthouse',
        type = 'penthouse',
        coords = vector3(-786.84, 315.77, 217.64),
        owned = false,
        price = 1200000,
        rent = 6000
    },
    {
        id = 10,
        name = 'Lombank West Penthouse',
        type = 'penthouse',
        coords = vector3(-1579.77, -566.89, 108.52),
        owned = false,
        price = 900000,
        rent = 4500
    }
}

-- Real Estate Offices
Config.RealEstateOffices = {
    {
        name = 'Dynasty 8 Real Estate',
        coords = vector3(-716.09, 261.21, 84.14),
        blip = true,
        ped = 's_m_m_highsec_01'
    },
    {
        name = 'Maze Bank Foreclosures',
        coords = vector3(-1210.77, -330.78, 37.78),
        blip = true,
        ped = 's_f_y_airhostess_01'
    }
}

-- Interior Shells (if using custom interiors)
Config.Interiors = {
    ['apartment'] = {
        shell = 'shell_apartment1',
        exit = vector3(-618.29, 37.36, 43.59)
    },
    ['house'] = {
        shell = 'shell_house1',
        exit = vector3(-14.33, -1441.1, 31.1)
    },
    ['mansion'] = {
        shell = 'shell_mansion1', 
        exit = vector3(-1289.23, 459.86, 97.02)
    },
    ['penthouse'] = {
        shell = 'shell_penthouse1',
        exit = vector3(-786.84, 315.77, 217.64)
    }
}

-- Furniture Categories
Config.Furniture = {
    ['living_room'] = {
        {name = 'Leather Sofa', price = 2500, prop = 'prop_couch_01'},
        {name = 'Coffee Table', price = 800, prop = 'prop_coffee_table_01'},
        {name = 'TV Stand', price = 1200, prop = 'prop_tv_stand_01'},
        {name = 'Bookshelf', price = 1500, prop = 'prop_bookshelf_01'}
    },
    ['bedroom'] = {
        {name = 'Double Bed', price = 3000, prop = 'prop_bed_01'},
        {name = 'Wardrobe', price = 2000, prop = 'prop_wardrobe_01'},
        {name = 'Nightstand', price = 600, prop = 'prop_nightstand_01'},
        {name = 'Dresser', price = 1800, prop = 'prop_dresser_01'}
    },
    ['kitchen'] = {
        {name = 'Dining Table', price = 2200, prop = 'prop_table_01'},
        {name = 'Kitchen Counter', price = 3500, prop = 'prop_counter_01'},
        {name = 'Refrigerator', price = 4000, prop = 'prop_fridge_01'},
        {name = 'Microwave', price = 800, prop = 'prop_microwave_01'}
    }
}

-- Utility Settings
Config.Utilities = {
    electricity = {
        baseRate = 50,
        perHour = 2
    },
    water = {
        baseRate = 30,
        perHour = 1
    },
    internet = {
        baseRate = 75,
        unlimited = true
    }
}