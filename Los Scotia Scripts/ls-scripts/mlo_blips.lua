-- MLO Blips Configuration for Los Scotia Server
-- This file contains blip configurations for all MLOs that don't currently have blips
-- Add these configurations to your ef-blips system

Config = Config or {}
Config.MLOBlips = {
    -- Gang Territory MLOs
    {
        name = "Aztecas Territory",
        coords = vector3(2396.69, 3089.89, 48.15),
        sprite = 378, -- Gang icon
        color = 46, -- Orange
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    {
        name = "Ballas Territory", 
        coords = vector3(105.28, -1884.84, 24.32),
        sprite = 378,
        color = 27, -- Purple
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    {
        name = "Families Territory",
        coords = vector3(-165.96, -1618.49, 33.65),
        sprite = 378,
        color = 25, -- Green
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    {
        name = "Marabunta Territory",
        coords = vector3(1436.93, -1492.54, 63.63),
        sprite = 378,
        color = 3, -- Blue
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    {
        name = "Lost MC Compound",
        coords = vector3(985.11, -129.35, 74.06),
        sprite = 226, -- Motorcycle
        color = 1, -- Red
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    {
        name = "Gang Underground",
        coords = vector3(1273.89, -1711.66, 54.77),
        sprite = 378,
        color = 0, -- White
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },

    -- Police Stations
    {
        name = "BCPD Station",
        coords = vector3(-258.99, 6068.34, 31.19),
        sprite = 60, -- Police
        color = 38, -- Dark Blue
        scale = 0.9,
        shortRange = false,
        category = "police"
    },
    {
        name = "Davis Police Department",
        coords = vector3(379.78, -1594.01, 29.29),
        sprite = 60,
        color = 38,
        scale = 0.9,
        shortRange = false,
        category = "police"
    },
    {
        name = "LSPD Headquarters",
        coords = vector3(640.89, 1.69, 82.79),
        sprite = 60,
        color = 38,
        scale = 1.0,
        shortRange = false,
        category = "police"
    },
    {
        name = "Mesa Police Department",
        coords = vector3(-832.58, -1290.18, 5.15),
        sprite = 60,
        color = 38,
        scale = 0.9,
        shortRange = false,
        category = "police"
    },
    {
        name = "MRPD Legion Square",
        coords = vector3(218.89, -889.12, 30.69),
        sprite = 60,
        color = 38,
        scale = 1.0,
        shortRange = false,
        category = "police"
    },
    {
        name = "FDNY Station",
        coords = vector3(201.89, -1645.12, 29.8),
        sprite = 60, -- Fire department uses police sprite too
        color = 1, -- Red for fire department
        scale = 0.9,
        shortRange = false,
        category = "emergency"
    },

    -- Restaurants & Food
    {
        name = "Burger Shot",
        coords = vector3(-1195.32, -885.9, 13.99),
        sprite = 106, -- Food
        color = 46, -- Orange
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Tequi-la-la",
        coords = vector3(-565.87, 276.93, 83.14),
        sprite = 93, -- Bar
        color = 5, -- Yellow
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Dominos Pizza",
        coords = vector3(542.89, 101.12, 96.54),
        sprite = 106,
        color = 1, -- Red
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Dunkin Donuts",
        coords = vector3(-635.67, 234.56, 81.89),
        sprite = 106,
        color = 46, -- Orange
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Breze Inn-Out",
        coords = vector3(-1185.78, -1456.12, 4.89),
        sprite = 106,
        color = 46,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Wing Stop",
        coords = vector3(145.67, -1469.78, 29.36),
        sprite = 106,
        color = 1, -- Red
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Cool Beans Coffee",
        coords = vector3(-628.45, 234.12, 81.89),
        sprite = 106,
        color = 17, -- Brown
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Jollibee",
        coords = vector3(-1156.89, -1425.67, 4.95),
        sprite = 106,
        color = 1, -- Red
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Milos ChickFilA",
        coords = vector3(-512.34, -695.78, 33.18),
        sprite = 106,
        color = 1, -- Red
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Goody's Burger",
        coords = vector3(-1456.78, -234.56, 49.89),
        sprite = 106,
        color = 46, -- Orange
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    {
        name = "Japanese Restaurant",
        coords = vector3(-1456.12, -378.90, 38.52),
        sprite = 106,
        color = 0, -- White
        scale = 0.7,
        shortRange = true,
        category = "food"
    },

    -- Automotive
    {
        name = "Audi Dealership",
        coords = vector3(-56.45, -1097.34, 26.42),
        sprite = 523, -- Car dealer
        color = 4, -- Dark Blue
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    {
        name = "Bennys Customs",
        coords = vector3(-212.12, -1324.56, 30.89),
        sprite = 446, -- Mechanic
        color = 46, -- Orange
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    {
        name = "Tuner Shop",
        coords = vector3(134.56, -3051.23, 7.04),
        sprite = 446,
        color = 5, -- Yellow
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    {
        name = "LS Customs",
        coords = vector3(-365.12, -131.45, 38.25),
        sprite = 446,
        color = 46, -- Orange
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    {
        name = "Vehicle Impound",
        coords = vector3(409.78, -1623.45, 29.29),
        sprite = 68, -- Impound
        color = 1, -- Red
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },

    -- Entertainment & Casinos
    {
        name = "Casino",
        coords = vector3(924.45, 47.89, 81.11),
        sprite = 679, -- Casino chip
        color = 5, -- Yellow
        scale = 0.9,
        shortRange = false,
        category = "entertainment"
    },
    {
        name = "Fight Club",
        coords = vector3(-1274.56, -1234.67, 6.89),
        sprite = 311, -- Fighting
        color = 1, -- Red
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    {
        name = "Bowling Alley",
        coords = vector3(756.78, -775.23, 26.89),
        sprite = 103, -- Sports
        color = 3, -- Blue
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    {
        name = "Basketball Court",
        coords = vector3(-1045.67, -234.78, 37.89),
        sprite = 103,
        color = 46, -- Orange
        scale = 0.7,
        shortRange = true,
        category = "entertainment"
    },
    {
        name = "Arcade",
        coords = vector3(-1654.23, -1063.45, 12.16),
        sprite = 740, -- Arcade
        color = 27, -- Purple
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    {
        name = "Cinema",
        coords = vector3(298.67, 180.12, 104.39),
        sprite = 135, -- Cinema
        color = 1, -- Red
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    {
        name = "Medusa Club",
        coords = vector3(234.67, -1234.78, 29.89),
        sprite = 136, -- Nightclub
        color = 27, -- Purple
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    {
        name = "Hookah Lounge",
        coords = vector3(-1234.56, -567.89, 30.78),
        sprite = 93, -- Bar
        color = 46, -- Orange
        scale = 0.7,
        shortRange = true,
        category = "entertainment"
    },
    {
        name = "Car Auction",
        coords = vector3(1134.67, -3451.23, 5.89),
        sprite = 523, -- Car
        color = 5, -- Yellow
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    {
        name = "Drift Track",
        coords = vector3(1178.89, -3113.45, 5.89),
        sprite = 315, -- Racing
        color = 1, -- Red
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },

    -- Retail & Shopping
    {
        name = "Binco Clothing",
        coords = vector3(425.23, -806.78, 29.49),
        sprite = 73, -- Clothing
        color = 3, -- Blue
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    {
        name = "Ponsonby Clothing",
        coords = vector3(-703.45, -151.23, 37.42),
        sprite = 73,
        color = 27, -- Purple
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    {
        name = "Ammunition",
        coords = vector3(252.89, -50.12, 69.94),
        sprite = 110, -- Gun shop
        color = 1, -- Red
        scale = 0.8,
        shortRange = true,
        category = "shopping"
    },
    {
        name = "Corner Store",
        coords = vector3(25.67, -1347.23, 29.50),
        sprite = 52, -- Shop
        color = 2, -- Green
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    {
        name = "Liquor Store",
        coords = vector3(-1487.23, -378.45, 40.16),
        sprite = 52,
        color = 46, -- Orange
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    {
        name = "Nail Studio",
        coords = vector3(-1234.56, -823.45, 16.89),
        sprite = 71, -- Beauty
        color = 8, -- Pink
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    {
        name = "Florist",
        coords = vector3(-1345.67, -1234.89, 4.89),
        sprite = 140, -- Flower
        color = 25, -- Green
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },

    -- Housing & Residential
    {
        name = "Mansion",
        coords = vector3(-2589.34, 1912.45, 167.89),
        sprite = 40, -- House
        color = 5, -- Yellow
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Breze Mansion",
        coords = vector3(-1567.89, 23.45, 58.89),
        sprite = 40,
        color = 5,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Modern House",
        coords = vector3(-2034.56, 445.78, 103.16),
        sprite = 40,
        color = 3, -- Blue
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Chalet",
        coords = vector3(-1756.89, 234.67, 89.23),
        sprite = 40,
        color = 17, -- Brown
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Sandy Motel",
        coords = vector3(1142.34, 2654.78, 38.89),
        sprite = 475, -- Hotel
        color = 46, -- Orange
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Alta Towers",
        coords = vector3(-234.56, -978.12, 29.45),
        sprite = 475,
        color = 3, -- Blue
        scale = 0.9,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Beach Resort",
        coords = vector3(-1645.78, -1089.34, 13.15),
        sprite = 475,
        color = 3,
        scale = 0.9,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Tinsel Lobby",
        coords = vector3(-623.45, 234.67, 97.89),
        sprite = 475,
        color = 5, -- Yellow
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },

    -- Special Locations
    {
        name = "Airport",
        coords = vector3(-1037.89, -2738.12, 20.17),
        sprite = 90, -- Airport
        color = 3, -- Blue
        scale = 1.0,
        shortRange = false,
        category = "transport"
    },
    {
        name = "Alcatraz Prison",
        coords = vector3(1689.23, 2605.67, 45.56),
        sprite = 188, -- Prison
        color = 46, -- Orange
        scale = 1.0,
        shortRange = false,
        category = "special"
    },
    {
        name = "Church",
        coords = vector3(-1678.89, -456.78, 40.12),
        sprite = 108, -- Church
        color = 0, -- White
        scale = 0.8,
        shortRange = true,
        category = "special"
    },
    {
        name = "Fish Hut",
        coords = vector3(-1845.67, -1234.56, 8.89),
        sprite = 356, -- Fishing
        color = 3, -- Blue
        scale = 0.7,
        shortRange = true,
        category = "special"
    },
    {
        name = "Laundry",
        coords = vector3(15.67, -1534.78, 29.89),
        sprite = 439, -- Laundry
        color = 3, -- Blue
        scale = 0.7,
        shortRange = true,
        category = "business"
    },
    {
        name = "Hub Building",
        coords = vector3(-75.23, -818.45, 326.17),
        sprite = 475, -- Building
        color = 0, -- White
        scale = 0.9,
        shortRange = true,
        category = "business"
    },

    -- Crime & Underground
    {
        name = "Hacker Compound",
        coords = vector3(2155.67, 3408.12, 45.23),
        sprite = 521, -- Computer
        color = 2, -- Green
        scale = 0.8,
        shortRange = true,
        category = "crime"
    },
    {
        name = "Haitian Compound",
        coords = vector3(-234.56, -1567.89, 31.89),
        sprite = 378, -- Gang
        color = 3, -- Blue
        scale = 0.8,
        shortRange = true,
        category = "crime"
    },
    {
        name = "Italian Compound",
        coords = vector3(-1234.67, -834.56, 16.89),
        sprite = 378,
        color = 25, -- Green
        scale = 0.8,
        shortRange = true,
        category = "crime"
    },
    {
        name = "Narcos Island",
        coords = vector3(4445.67, 4567.89, 45.23),
        sprite = 469, -- Drugs
        color = 1, -- Red
        scale = 0.9,
        shortRange = true,
        category = "crime"
    },
    {
        name = "Container Facility",
        coords = vector3(1134.56, -3234.78, 5.89),
        sprite = 478, -- Container
        color = 46, -- Orange
        scale = 0.8,
        shortRange = true,
        category = "business"
    },

    -- Hoods & Projects
    {
        name = "Grove Mega Hood",
        coords = vector3(-156.78, -1654.23, 33.25),
        sprite = 40, -- House
        color = 25, -- Green
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Kelly Park Projects",
        coords = vector3(234.56, -1876.45, 25.78),
        sprite = 40,
        color = 1, -- Red
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Little Seoul",
        coords = vector3(-634.78, -1456.23, 34.56),
        sprite = 40,
        color = 5, -- Yellow
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Mandem Hood",
        coords = vector3(345.67, -2034.89, 22.34),
        sprite = 40,
        color = 27, -- Purple
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Redline Hood",
        coords = vector3(1456.78, -2234.56, 33.89),
        sprite = 40,
        color = 1, -- Red
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    {
        name = "Stab City",
        coords = vector3(56.78, 3723.45, 39.67),
        sprite = 40,
        color = 46, -- Orange
        scale = 0.8,
        shortRange = true,
        category = "residential"
    }
}

-- Function to add MLO blips
function AddMLOBlips()
    for _, blip in pairs(Config.MLOBlips) do
        local blipHandle = AddBlipForCoord(blip.coords.x, blip.coords.y, blip.coords.z)
        
        SetBlipSprite(blipHandle, blip.sprite)
        SetBlipColour(blipHandle, blip.color)
        SetBlipScale(blipHandle, blip.scale)
        SetBlipAsShortRange(blipHandle, blip.shortRange)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blip.name)
        EndTextCommandSetBlipName(blipHandle)
    end
end

-- Auto-execute when script loads
CreateThread(function()
    Wait(1000) -- Wait for other resources to load
    AddMLOBlips()
    print("^2[MLO Blips]^7 Loaded " .. #Config.MLOBlips .. " MLO blips successfully!")
end)