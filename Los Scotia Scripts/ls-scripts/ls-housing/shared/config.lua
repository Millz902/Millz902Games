-- Housing Configuration
Config = Config or {}

Config.Housing = {
    -- General Settings
    General = {
        useTarget = true,                -- Use qb-target for interactions
        useKeys = true,                  -- Use qb-keys for house keys
        doorLockDistance = 5.0,          -- Distance to lock/unlock doors
        garageDistance = 10.0,           -- Distance to access garage
        storageDistance = 3.0,           -- Distance to access storage
        maxHousesPerPlayer = 1,          -- Maximum houses per player
        houseTaxRate = 0.1,              -- 10% tax rate for house sales
        defaultInterior = 'small_apartment'
    },
    
    -- House Types
    HouseTypes = {
        ['apartment'] = {
            label = 'Apartment',
            price = { min = 50000, max = 150000 },
            interior = 'small_apartment',
            garage = false,
            storage = { weight = 1000000, slots = 25 }
        },
        ['house'] = {
            label = 'House',
            price = { min = 150000, max = 400000 },
            interior = 'medium_apartment',
            garage = true,
            storage = { weight = 2000000, slots = 50 }
        },
        ['mansion'] = {
            label = 'Mansion',
            price = { min = 400000, max = 1000000 },
            interior = 'luxury_apartment',
            garage = true,
            storage = { weight = 5000000, slots = 100 }
        },
        ['trailer'] = {
            label = 'Trailer',
            price = { min = 25000, max = 75000 },
            interior = 'trailer',
            garage = false,
            storage = { weight = 500000, slots = 15 }
        },
        ['cabin'] = {
            label = 'Cabin',
            price = { min = 100000, max = 250000 },
            interior = 'cabin',
            garage = true,
            storage = { weight = 1500000, slots = 35 }
        }
    },
    
    -- Interior Templates
    Interiors = {
        ['small_apartment'] = {
            label = 'Small Apartment',
            coords = vector4(-2.0, -6.0, 0.0, 0.0),
            furnitureZones = {
                { id = 1, label = 'Living Room', coords = vector3(0.0, 0.0, 0.0) },
                { id = 2, label = 'Bedroom', coords = vector3(3.0, 0.0, 0.0) },
                { id = 3, label = 'Kitchen', coords = vector3(-3.0, 0.0, 0.0) }
            },
            storage = vector3(-1.0, -3.0, 0.0),
            wardrobe = vector3(3.0, -2.0, 0.0),
            logout = vector3(0.0, -4.0, 0.0)
        },
        ['medium_apartment'] = {
            label = 'Medium Apartment',
            coords = vector4(-5.0, -10.0, 0.0, 0.0),
            furnitureZones = {
                { id = 1, label = 'Living Room', coords = vector3(0.0, 0.0, 0.0) },
                { id = 2, label = 'Bedroom', coords = vector3(5.0, 0.0, 0.0) },
                { id = 3, label = 'Kitchen', coords = vector3(-5.0, 0.0, 0.0) },
                { id = 4, label = 'Dining Room', coords = vector3(0.0, 5.0, 0.0) }
            },
            storage = vector3(-3.0, -5.0, 0.0),
            wardrobe = vector3(5.0, -3.0, 0.0),
            logout = vector3(0.0, -8.0, 0.0)
        },
        ['luxury_apartment'] = {
            label = 'Luxury Apartment',
            coords = vector4(-10.0, -15.0, 0.0, 0.0),
            furnitureZones = {
                { id = 1, label = 'Living Room', coords = vector3(0.0, 0.0, 0.0) },
                { id = 2, label = 'Master Bedroom', coords = vector3(8.0, 0.0, 0.0) },
                { id = 3, label = 'Kitchen', coords = vector3(-8.0, 0.0, 0.0) },
                { id = 4, label = 'Dining Room', coords = vector3(0.0, 8.0, 0.0) },
                { id = 5, label = 'Guest Bedroom', coords = vector3(8.0, 8.0, 0.0) },
                { id = 6, label = 'Office', coords = vector3(-8.0, 8.0, 0.0) }
            },
            storage = vector3(-5.0, -8.0, 0.0),
            wardrobe = vector3(8.0, -5.0, 0.0),
            logout = vector3(0.0, -12.0, 0.0)
        },
        ['trailer'] = {
            label = 'Trailer',
            coords = vector4(0.0, -2.0, 0.0, 0.0),
            furnitureZones = {
                { id = 1, label = 'Living Area', coords = vector3(0.0, 0.0, 0.0) },
                { id = 2, label = 'Bedroom', coords = vector3(2.0, 0.0, 0.0) }
            },
            storage = vector3(-1.0, -1.0, 0.0),
            wardrobe = vector3(2.0, -1.0, 0.0),
            logout = vector3(0.0, -1.5, 0.0)
        },
        ['cabin'] = {
            label = 'Cabin',
            coords = vector4(-3.0, -8.0, 0.0, 0.0),
            furnitureZones = {
                { id = 1, label = 'Living Room', coords = vector3(0.0, 0.0, 0.0) },
                { id = 2, label = 'Bedroom', coords = vector3(4.0, 0.0, 0.0) },
                { id = 3, label = 'Kitchen', coords = vector3(-4.0, 0.0, 0.0) }
            },
            storage = vector3(-2.0, -4.0, 0.0),
            wardrobe = vector3(4.0, -2.0, 0.0),
            logout = vector3(0.0, -6.0, 0.0)
        }
    },
    
    -- Furniture Configuration
    Furniture = {
        categories = {
            ['seating'] = {
                label = 'Seating',
                items = {
                    ['chair'] = { label = 'Chair', price = 150, model = 'v_club_officechair' },
                    ['couch'] = { label = 'Couch', price = 500, model = 'v_res_tre_sofa' },
                    ['armchair'] = { label = 'Armchair', price = 300, model = 'v_res_fh_armchair' }
                }
            },
            ['tables'] = {
                label = 'Tables',
                items = {
                    ['coffee_table'] = { label = 'Coffee Table', price = 200, model = 'v_res_tre_coffeetable' },
                    ['dining_table'] = { label = 'Dining Table', price = 400, model = 'v_res_tre_dinetable' },
                    ['desk'] = { label = 'Desk', price = 350, model = 'v_res_fh_desk' }
                }
            },
            ['bedroom'] = {
                label = 'Bedroom',
                items = {
                    ['bed'] = { label = 'Bed', price = 800, model = 'v_res_tre_bed2' },
                    ['dresser'] = { label = 'Dresser', price = 250, model = 'v_res_tre_wardrobe' },
                    ['nightstand'] = { label = 'Nightstand', price = 150, model = 'v_res_tre_bedsidetable' }
                }
            },
            ['decoration'] = {
                label = 'Decoration',
                items = {
                    ['plant'] = { label = 'Plant', price = 50, model = 'v_res_tre_plant' },
                    ['lamp'] = { label = 'Lamp', price = 100, model = 'v_res_tre_lamp' },
                    ['tv'] = { label = 'TV', price = 800, model = 'v_res_tre_tv' }
                }
            }
        }
    },
    
    -- Security System
    Security = {
        alarmLevels = {
            [1] = { label = 'Basic Alarm', price = 5000, protection = 25 },
            [2] = { label = 'Advanced Alarm', price = 10000, protection = 50 },
            [3] = { label = 'Professional Alarm', price = 20000, protection = 75 }
        },
        lockLevels = {
            [1] = { label = 'Standard Lock', price = 1000, protection = 10 },
            [2] = { label = 'Security Lock', price = 2500, protection = 25 },
            [3] = { label = 'High-Security Lock', price = 5000, protection = 50 }
        },
        cameras = {
            maxCameras = 4,
            cameraPrice = 2500,
            viewDistance = 50.0
        }
    },
    
    -- Garage Configuration
    Garage = {
        maxVehicles = {
            ['apartment'] = 1,
            ['house'] = 2,
            ['mansion'] = 4,
            ['trailer'] = 1,
            ['cabin'] = 2
        },
        impoundPrice = 1000,
        repairPrice = 500
    },
    
    -- Utility Bills
    Bills = {
        enabled = true,
        frequency = 24, -- Hours between bills
        rates = {
            ['apartment'] = 100,
            ['house'] = 250,
            ['mansion'] = 500,
            ['trailer'] = 50,
            ['cabin'] = 150
        }
    }
}

-- Housing Utilities
HousingUtils = {}

function HousingUtils.GetHouseType(houseData)
    for houseType, config in pairs(Config.Housing.HouseTypes) do
        if houseData.type == houseType then
            return config
        end
    end
    return Config.Housing.HouseTypes['apartment'] -- Default
end

function HousingUtils.GetInteriorConfig(interiorType)
    return Config.Housing.Interiors[interiorType] or Config.Housing.Interiors['small_apartment']
end

function HousingUtils.CalculateHousePrice(houseType, location)
    local houseConfig = Config.Housing.HouseTypes[houseType]
    if not houseConfig then return 100000 end
    
    -- Base price calculation with location modifier
    local basePrice = math.random(houseConfig.price.min, houseConfig.price.max)
    
    -- Location modifiers (you can expand this)
    local locationModifiers = {
        ['vinewood'] = 1.5,
        ['downtown'] = 1.3,
        ['beach'] = 1.4,
        ['suburb'] = 1.0,
        ['industrial'] = 0.8,
        ['desert'] = 0.7
    }
    
    local modifier = locationModifiers[location] or 1.0
    return math.floor(basePrice * modifier)
end

function HousingUtils.GetFurnitureByCategory(category)
    return Config.Housing.Furniture.categories[category] or {}
end

function HousingUtils.CalculateDistance(coords1, coords2)
    return #(coords1 - coords2)
end

function HousingUtils.IsNearHouse(playerCoords, houseCoords, distance)
    distance = distance or 5.0
    return HousingUtils.CalculateDistance(playerCoords, houseCoords) <= distance
end

-- Housing Events
HousingEvents = {
    -- Client Events
    Client = {
        UpdateHouseData = 'ls-housing:client:UpdateHouseData',
        SetInside = 'ls-housing:client:SetInside',
        SetOutside = 'ls-housing:client:SetOutside',
        RefreshHouses = 'ls-housing:client:RefreshHouses',
        HousePurchased = 'ls-housing:client:HousePurchased',
        HouseSold = 'ls-housing:client:HouseSold',
        ShowHouseInfo = 'ls-housing:client:ShowHouseInfo',
        ShowHouseGuests = 'ls-housing:client:ShowHouseGuests',
        ShowGarageVehicles = 'ls-housing:client:ShowGarageVehicles',
        LoadFurniture = 'ls-housing:client:LoadFurniture',
        ShowSecurityData = 'ls-housing:client:ShowSecurityData'
    },
    
    -- Server Events
    Server = {
        GetHouses = 'ls-housing:server:GetHouses',
        EnterHouse = 'ls-housing:server:EnterHouse',
        ExitHouse = 'ls-housing:server:ExitHouse',
        CheckHouseEntry = 'ls-housing:server:CheckHouseEntry',
        PurchaseHouse = 'ls-housing:server:PurchaseHouse',
        SellHouse = 'ls-housing:server:SellHouse',
        TeleportToHouse = 'ls-housing:server:TeleportToHouse',
        GetHouseInfo = 'ls-housing:server:GetHouseInfo',
        GetHouseGuests = 'ls-housing:server:GetHouseGuests',
        AddGuest = 'ls-housing:server:AddGuest',
        RemoveGuest = 'ls-housing:server:RemoveGuest',
        GetGarageVehicles = 'ls-housing:server:GetGarageVehicles',
        GetHouseFurniture = 'ls-housing:server:GetHouseFurniture',
        PlaceFurniture = 'ls-housing:server:PlaceFurniture',
        RemoveFurniture = 'ls-housing:server:RemoveFurniture',
        GetSecurityData = 'ls-housing:server:GetSecurityData'
    }
}

-- Export housing configuration for other resources
exports('GetHousingConfig', function()
    return Config.Housing
end)

exports('GetHousingUtils', function()
    return HousingUtils
end)

exports('GetHousingEvents', function()
    return HousingEvents
end)