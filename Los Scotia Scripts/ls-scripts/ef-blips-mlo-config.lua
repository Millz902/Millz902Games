-- EF-Blips MLO Configuration for Los Scotia Server
-- This file contains blip configurations formatted for ef-blips system
-- Add these configurations to your ef-blips config.lua file

Config = Config or {}
Config.MLOBlips = {
    -- Gang Territory MLOs
    ["aztecas_territory"] = {
        name = "Aztecas Territory",
        x = 2396.69,
        y = 3089.89,
        z = 48.15,
        sprite = 378,
        color = 46,
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    ["ballas_territory"] = {
        name = "Ballas Territory",
        x = 105.28,
        y = -1884.84,
        z = 24.32,
        sprite = 378,
        color = 27,
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    ["families_territory"] = {
        name = "Families Territory",
        x = -165.96,
        y = -1618.49,
        z = 33.65,
        sprite = 378,
        color = 25,
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    ["marabunta_territory"] = {
        name = "Marabunta Territory",
        x = 1436.93,
        y = -1492.54,
        z = 63.63,
        sprite = 378,
        color = 3,
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    ["lost_mc_compound"] = {
        name = "Lost MC Compound",
        x = 985.11,
        y = -129.35,
        z = 74.06,
        sprite = 226,
        color = 1,
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },
    ["gang_underground"] = {
        name = "Gang Underground",
        x = 1273.89,
        y = -1711.66,
        z = 54.77,
        sprite = 378,
        color = 0,
        scale = 0.8,
        shortRange = true,
        category = "gang"
    },

    -- Police Stations
    ["bcpd_station"] = {
        name = "BCPD Station",
        x = -258.99,
        y = 6068.34,
        z = 31.19,
        sprite = 60,
        color = 38,
        scale = 0.9,
        shortRange = false,
        category = "police"
    },
    ["davis_police"] = {
        name = "Davis Police Department",
        x = 379.78,
        y = -1594.01,
        z = 29.29,
        sprite = 60,
        color = 38,
        scale = 0.9,
        shortRange = false,
        category = "police"
    },
    ["lspd_headquarters"] = {
        name = "LSPD Headquarters",
        x = 640.89,
        y = 1.69,
        z = 82.79,
        sprite = 60,
        color = 38,
        scale = 1.0,
        shortRange = false,
        category = "police"
    },
    ["mesa_police"] = {
        name = "Mesa Police Department",
        x = -832.58,
        y = -1290.18,
        z = 5.15,
        sprite = 60,
        color = 38,
        scale = 0.9,
        shortRange = false,
        category = "police"
    },
    ["mrpd_legion"] = {
        name = "MRPD Legion Square",
        x = 218.89,
        y = -889.12,
        z = 30.69,
        sprite = 60,
        color = 38,
        scale = 1.0,
        shortRange = false,
        category = "police"
    },
    ["fdny_station"] = {
        name = "FDNY Station",
        x = 201.89,
        y = -1645.12,
        z = 29.8,
        sprite = 60,
        color = 1,
        scale = 0.9,
        shortRange = false,
        category = "emergency"
    },

    -- Restaurants & Food
    ["burger_shot"] = {
        name = "Burger Shot",
        x = -1195.32,
        y = -885.9,
        z = 13.99,
        sprite = 106,
        color = 46,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["tequila_la"] = {
        name = "Tequi-la-la",
        x = -565.87,
        y = 276.93,
        z = 83.14,
        sprite = 93,
        color = 5,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["dominos_pizza"] = {
        name = "Dominos Pizza",
        x = 542.89,
        y = 101.12,
        z = 96.54,
        sprite = 106,
        color = 1,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["dunkin_donuts"] = {
        name = "Dunkin Donuts",
        x = -635.67,
        y = 234.56,
        z = 81.89,
        sprite = 106,
        color = 46,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["breze_inn_out"] = {
        name = "Breze Inn-Out",
        x = -1185.78,
        y = -1456.12,
        z = 4.89,
        sprite = 106,
        color = 46,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["wing_stop"] = {
        name = "Wing Stop",
        x = 145.67,
        y = -1469.78,
        z = 29.36,
        sprite = 106,
        color = 1,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["cool_beans_coffee"] = {
        name = "Cool Beans Coffee",
        x = -628.45,
        y = 234.12,
        z = 81.89,
        sprite = 106,
        color = 17,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["jollibee"] = {
        name = "Jollibee",
        x = -1156.89,
        y = -1425.67,
        z = 4.95,
        sprite = 106,
        color = 1,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["milos_chickfila"] = {
        name = "Milos ChickFilA",
        x = -512.34,
        y = -695.78,
        z = 33.18,
        sprite = 106,
        color = 1,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["goodys_burger"] = {
        name = "Goody's Burger",
        x = -1456.78,
        y = -234.56,
        z = 49.89,
        sprite = 106,
        color = 46,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },
    ["japanese_restaurant"] = {
        name = "Japanese Restaurant",
        x = -1456.12,
        y = -378.90,
        z = 38.52,
        sprite = 106,
        color = 0,
        scale = 0.7,
        shortRange = true,
        category = "food"
    },

    -- Automotive
    ["audi_dealership"] = {
        name = "Audi Dealership",
        x = -56.45,
        y = -1097.34,
        z = 26.42,
        sprite = 523,
        color = 4,
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    ["bennys_customs"] = {
        name = "Bennys Customs",
        x = -212.12,
        y = -1324.56,
        z = 30.89,
        sprite = 446,
        color = 46,
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    ["tuner_shop"] = {
        name = "Tuner Shop",
        x = 134.56,
        y = -3051.23,
        z = 7.04,
        sprite = 446,
        color = 5,
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    ["ls_customs"] = {
        name = "LS Customs",
        x = -365.12,
        y = -131.45,
        z = 38.25,
        sprite = 446,
        color = 46,
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    ["vehicle_impound"] = {
        name = "Vehicle Impound",
        x = 409.78,
        y = -1623.45,
        z = 29.29,
        sprite = 68,
        color = 1,
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },

    -- Entertainment & Casinos
    ["casino"] = {
        name = "Casino",
        x = 924.45,
        y = 47.89,
        z = 81.11,
        sprite = 679,
        color = 5,
        scale = 0.9,
        shortRange = false,
        category = "entertainment"
    },
    ["fight_club"] = {
        name = "Fight Club",
        x = -1274.56,
        y = -1234.67,
        z = 6.89,
        sprite = 311,
        color = 1,
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    ["bowling_alley"] = {
        name = "Bowling Alley",
        x = 756.78,
        y = -775.23,
        z = 26.89,
        sprite = 103,
        color = 3,
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    ["basketball_court"] = {
        name = "Basketball Court",
        x = -1045.67,
        y = -234.78,
        z = 37.89,
        sprite = 103,
        color = 46,
        scale = 0.7,
        shortRange = true,
        category = "entertainment"
    },
    ["arcade"] = {
        name = "Arcade",
        x = -1654.23,
        y = -1063.45,
        z = 12.16,
        sprite = 740,
        color = 27,
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    ["cinema"] = {
        name = "Cinema",
        x = 298.67,
        y = 180.12,
        z = 104.39,
        sprite = 135,
        color = 1,
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    ["medusa_club"] = {
        name = "Medusa Club",
        x = 234.67,
        y = -1234.78,
        z = 29.89,
        sprite = 136,
        color = 27,
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },
    ["hookah_lounge"] = {
        name = "Hookah Lounge",
        x = -1234.56,
        y = -567.89,
        z = 30.78,
        sprite = 93,
        color = 46,
        scale = 0.7,
        shortRange = true,
        category = "entertainment"
    },
    ["car_auction"] = {
        name = "Car Auction",
        x = 1134.67,
        y = -3451.23,
        z = 5.89,
        sprite = 523,
        color = 5,
        scale = 0.8,
        shortRange = true,
        category = "automotive"
    },
    ["drift_track"] = {
        name = "Drift Track",
        x = 1178.89,
        y = -3113.45,
        z = 5.89,
        sprite = 315,
        color = 1,
        scale = 0.8,
        shortRange = true,
        category = "entertainment"
    },

    -- Retail & Shopping
    ["binco_clothing"] = {
        name = "Binco Clothing",
        x = 425.23,
        y = -806.78,
        z = 29.49,
        sprite = 73,
        color = 3,
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    ["ponsonby_clothing"] = {
        name = "Ponsonby Clothing",
        x = -703.45,
        y = -151.23,
        z = 37.42,
        sprite = 73,
        color = 27,
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    ["ammunition"] = {
        name = "Ammunition",
        x = 252.89,
        y = -50.12,
        z = 69.94,
        sprite = 110,
        color = 1,
        scale = 0.8,
        shortRange = true,
        category = "shopping"
    },
    ["corner_store"] = {
        name = "Corner Store",
        x = 25.67,
        y = -1347.23,
        z = 29.50,
        sprite = 52,
        color = 2,
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    ["liquor_store"] = {
        name = "Liquor Store",
        x = -1487.23,
        y = -378.45,
        z = 40.16,
        sprite = 52,
        color = 46,
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    ["nail_studio"] = {
        name = "Nail Studio",
        x = -1234.56,
        y = -823.45,
        z = 16.89,
        sprite = 71,
        color = 8,
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },
    ["florist"] = {
        name = "Florist",
        x = -1345.67,
        y = -1234.89,
        z = 4.89,
        sprite = 140,
        color = 25,
        scale = 0.7,
        shortRange = true,
        category = "shopping"
    },

    -- Housing & Residential
    ["mansion"] = {
        name = "Mansion",
        x = -2589.34,
        y = 1912.45,
        z = 167.89,
        sprite = 40,
        color = 5,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["breze_mansion"] = {
        name = "Breze Mansion",
        x = -1567.89,
        y = 23.45,
        z = 58.89,
        sprite = 40,
        color = 5,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["modern_house"] = {
        name = "Modern House",
        x = -2034.56,
        y = 445.78,
        z = 103.16,
        sprite = 40,
        color = 3,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["chalet"] = {
        name = "Chalet",
        x = -1756.89,
        y = 234.67,
        z = 89.23,
        sprite = 40,
        color = 17,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["sandy_motel"] = {
        name = "Sandy Motel",
        x = 1142.34,
        y = 2654.78,
        z = 38.89,
        sprite = 475,
        color = 46,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["alta_towers"] = {
        name = "Alta Towers",
        x = -234.56,
        y = -978.12,
        z = 29.45,
        sprite = 475,
        color = 3,
        scale = 0.9,
        shortRange = true,
        category = "residential"
    },
    ["beach_resort"] = {
        name = "Beach Resort",
        x = -1645.78,
        y = -1089.34,
        z = 13.15,
        sprite = 475,
        color = 3,
        scale = 0.9,
        shortRange = true,
        category = "residential"
    },
    ["tinsel_lobby"] = {
        name = "Tinsel Lobby",
        x = -623.45,
        y = 234.67,
        z = 97.89,
        sprite = 475,
        color = 5,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },

    -- Special Locations
    ["airport"] = {
        name = "Airport",
        x = -1037.89,
        y = -2738.12,
        z = 20.17,
        sprite = 90,
        color = 3,
        scale = 1.0,
        shortRange = false,
        category = "transport"
    },
    ["alcatraz_prison"] = {
        name = "Alcatraz Prison",
        x = 1689.23,
        y = 2605.67,
        z = 45.56,
        sprite = 188,
        color = 46,
        scale = 1.0,
        shortRange = false,
        category = "special"
    },
    ["church"] = {
        name = "Church",
        x = -1678.89,
        y = -456.78,
        z = 40.12,
        sprite = 108,
        color = 0,
        scale = 0.8,
        shortRange = true,
        category = "special"
    },
    ["fish_hut"] = {
        name = "Fish Hut",
        x = -1845.67,
        y = -1234.56,
        z = 8.89,
        sprite = 356,
        color = 3,
        scale = 0.7,
        shortRange = true,
        category = "special"
    },
    ["laundry"] = {
        name = "Laundry",
        x = 15.67,
        y = -1534.78,
        z = 29.89,
        sprite = 439,
        color = 3,
        scale = 0.7,
        shortRange = true,
        category = "business"
    },
    ["hub_building"] = {
        name = "Hub Building",
        x = -75.23,
        y = -818.45,
        z = 326.17,
        sprite = 475,
        color = 0,
        scale = 0.9,
        shortRange = true,
        category = "business"
    },

    -- Crime & Underground
    ["hacker_compound"] = {
        name = "Hacker Compound",
        x = 2155.67,
        y = 3408.12,
        z = 45.23,
        sprite = 521,
        color = 2,
        scale = 0.8,
        shortRange = true,
        category = "crime"
    },
    ["haitian_compound"] = {
        name = "Haitian Compound",
        x = -234.56,
        y = -1567.89,
        z = 31.89,
        sprite = 378,
        color = 3,
        scale = 0.8,
        shortRange = true,
        category = "crime"
    },
    ["italian_compound"] = {
        name = "Italian Compound",
        x = -1234.67,
        y = -834.56,
        z = 16.89,
        sprite = 378,
        color = 25,
        scale = 0.8,
        shortRange = true,
        category = "crime"
    },
    ["narcos_island"] = {
        name = "Narcos Island",
        x = 4445.67,
        y = 4567.89,
        z = 45.23,
        sprite = 469,
        color = 1,
        scale = 0.9,
        shortRange = true,
        category = "crime"
    },
    ["container_facility"] = {
        name = "Container Facility",
        x = 1134.56,
        y = -3234.78,
        z = 5.89,
        sprite = 478,
        color = 46,
        scale = 0.8,
        shortRange = true,
        category = "business"
    },

    -- Hoods & Projects
    ["grove_mega_hood"] = {
        name = "Grove Mega Hood",
        x = -156.78,
        y = -1654.23,
        z = 33.25,
        sprite = 40,
        color = 25,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["kelly_park_projects"] = {
        name = "Kelly Park Projects",
        x = 234.56,
        y = -1876.45,
        z = 25.78,
        sprite = 40,
        color = 1,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["little_seoul"] = {
        name = "Little Seoul",
        x = -634.78,
        y = -1456.23,
        z = 34.56,
        sprite = 40,
        color = 5,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["mandem_hood"] = {
        name = "Mandem Hood",
        x = 345.67,
        y = -2034.89,
        z = 22.34,
        sprite = 40,
        color = 27,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["redline_hood"] = {
        name = "Redline Hood",
        x = 1456.78,
        y = -2234.56,
        z = 33.89,
        sprite = 40,
        color = 1,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    },
    ["stab_city"] = {
        name = "Stab City",
        x = 56.78,
        y = 3723.45,
        z = 39.67,
        sprite = 40,
        color = 46,
        scale = 0.8,
        shortRange = true,
        category = "residential"
    }
}

return Config.MLOBlips