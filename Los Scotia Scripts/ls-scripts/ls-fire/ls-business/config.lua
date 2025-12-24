-- Los Scotia Business Management Configuration
Config = {}

-- Business Settings
Config.MaxBusinessesPerPlayer = 3
Config.TaxRate = 0.05 -- 5% tax on revenue
Config.EmployeePayInterval = 3600 -- 1 hour in seconds
Config.MaxEmployees = 20

-- Business Types
Config.BusinessTypes = {
    ['restaurant'] = {
        name = 'Restaurant',
        price = 250000,
        dailyCost = 500,
        maxEmployees = 15,
        products = {'burger', 'fries', 'cola', 'coffee'}
    },
    ['shop'] = {
        name = 'Convenience Store',
        price = 150000,
        dailyCost = 300,
        maxEmployees = 8,
        products = {'cigarettes', 'snacks', 'drinks', 'newspapers'}
    },
    ['garage'] = {
        name = 'Auto Repair Shop',
        price = 400000,
        dailyCost = 800,
        maxEmployees = 12,
        products = {'repair_kit', 'tires', 'engine_oil', 'car_parts'}
    },
    ['clothing'] = {
        name = 'Clothing Store',
        price = 200000,
        dailyCost = 400,
        maxEmployees = 10,
        products = {'tshirt', 'jeans', 'shoes', 'hat'}
    },
    ['bar'] = {
        name = 'Bar/Nightclub',
        price = 300000,
        dailyCost = 600,
        maxEmployees = 12,
        products = {'beer', 'whiskey', 'vodka', 'cocktail'}
    },
    ['electronics'] = {
        name = 'Electronics Store',
        price = 350000,
        dailyCost = 700,
        maxEmployees = 8,
        products = {'phone', 'laptop', 'radio', 'camera'}
    }
}

-- Available Businesses
Config.Businesses = {
    {
        id = 1,
        name = 'Burger Shot',
        type = 'restaurant',
        coords = vector3(-1193.05, -885.09, 13.8),
        owned = false,
        price = 250000
    },
    {
        id = 2,
        name = 'Bean Machine Coffee',
        type = 'restaurant',
        coords = vector3(119.23, -1037.12, 29.28),
        owned = false,
        price = 200000
    },
    {
        id = 3,
        name = '24/7 Supermarket',
        type = 'shop',
        coords = vector3(373.96, 326.91, 103.57),
        owned = false,
        price = 150000
    },
    {
        id = 4,
        name = 'Los Santos Customs',
        type = 'garage',
        coords = vector3(-356.33, -134.77, 39.01),
        owned = false,
        price = 400000
    },
    {
        id = 5,
        name = 'Suburban Clothing',
        type = 'clothing',
        coords = vector3(72.3, -1399.1, 29.38),
        owned = false,
        price = 200000
    },
    {
        id = 6,
        name = 'Tequi-la-la',
        type = 'bar',
        coords = vector3(-565.91, 276.62, 83.14),
        owned = false,
        price = 300000
    },
    {
        id = 7,
        name = 'Digital Den',
        type = 'electronics',
        coords = vector3(1135.66, -982.73, 46.42),
        owned = false,
        price = 350000
    },
    {
        id = 8,
        name = 'Up-n-Atom Burger',
        type = 'restaurant',
        coords = vector3(1580.09, 6450.46, 25.32),
        owned = false,
        price = 220000
    },
    {
        id = 9,
        name = 'Ponsonbys Clothing',
        type = 'clothing',
        coords = vector3(-703.78, -152.3, 37.42),
        owned = false,
        price = 250000
    },
    {
        id = 10,
        name = 'Benny\'s Motorworks',
        type = 'garage',
        coords = vector3(-205.68, -1307.95, 31.29),
        owned = false,
        price = 450000
    }
}

-- Employee Positions
Config.Positions = {
    ['owner'] = {
        name = 'Owner',
        salary = 0,
        permissions = {
            hire = true,
            fire = true,
            manage_stock = true,
            manage_money = true,
            set_prices = true
        }
    },
    ['manager'] = {
        name = 'Manager',
        salary = 1000,
        permissions = {
            hire = true,
            fire = false,
            manage_stock = true,
            manage_money = false,
            set_prices = true
        }
    },
    ['supervisor'] = {
        name = 'Supervisor',
        salary = 750,
        permissions = {
            hire = false,
            fire = false,
            manage_stock = true,
            manage_money = false,
            set_prices = false
        }
    },
    ['employee'] = {
        name = 'Employee',
        salary = 500,
        permissions = {
            hire = false,
            fire = false,
            manage_stock = false,
            manage_money = false,
            set_prices = false
        }
    }
}

-- Business Products
Config.Products = {
    -- Restaurant Items
    ['burger'] = {name = 'Burger', buyPrice = 5, sellPrice = 15, category = 'food'},
    ['fries'] = {name = 'Fries', buyPrice = 2, sellPrice = 8, category = 'food'},
    ['cola'] = {name = 'Cola', buyPrice = 1, sellPrice = 5, category = 'drink'},
    ['coffee'] = {name = 'Coffee', buyPrice = 1, sellPrice = 6, category = 'drink'},
    
    -- Shop Items
    ['cigarettes'] = {name = 'Cigarettes', buyPrice = 8, sellPrice = 20, category = 'misc'},
    ['snacks'] = {name = 'Snacks', buyPrice = 2, sellPrice = 8, category = 'food'},
    ['drinks'] = {name = 'Energy Drink', buyPrice = 3, sellPrice = 10, category = 'drink'},
    ['newspapers'] = {name = 'Newspaper', buyPrice = 1, sellPrice = 3, category = 'misc'},
    
    -- Garage Items
    ['repair_kit'] = {name = 'Repair Kit', buyPrice = 50, sellPrice = 150, category = 'tool'},
    ['tires'] = {name = 'Tires', buyPrice = 200, sellPrice = 500, category = 'part'},
    ['engine_oil'] = {name = 'Engine Oil', buyPrice = 25, sellPrice = 75, category = 'fluid'},
    ['car_parts'] = {name = 'Car Parts', buyPrice = 100, sellPrice = 300, category = 'part'},
    
    -- Clothing Items
    ['tshirt'] = {name = 'T-Shirt', buyPrice = 10, sellPrice = 35, category = 'clothing'},
    ['jeans'] = {name = 'Jeans', buyPrice = 25, sellPrice = 80, category = 'clothing'},
    ['shoes'] = {name = 'Shoes', buyPrice = 40, sellPrice = 120, category = 'clothing'},
    ['hat'] = {name = 'Hat', buyPrice = 15, sellPrice = 45, category = 'clothing'},
    
    -- Bar Items
    ['beer'] = {name = 'Beer', buyPrice = 3, sellPrice = 12, category = 'alcohol'},
    ['whiskey'] = {name = 'Whiskey', buyPrice = 15, sellPrice = 45, category = 'alcohol'},
    ['vodka'] = {name = 'Vodka', buyPrice = 12, sellPrice = 40, category = 'alcohol'},
    ['cocktail'] = {name = 'Cocktail', buyPrice = 8, sellPrice = 25, category = 'alcohol'},
    
    -- Electronics Items
    ['phone'] = {name = 'Phone', buyPrice = 200, sellPrice = 600, category = 'electronics'},
    ['laptop'] = {name = 'Laptop', buyPrice = 800, sellPrice = 2000, category = 'electronics'},
    ['radio'] = {name = 'Radio', buyPrice = 50, sellPrice = 150, category = 'electronics'},
    ['camera'] = {name = 'Camera', buyPrice = 300, sellPrice = 800, category = 'electronics'}
}

-- Financial Settings
Config.Finance = {
    taxCollectionTime = 24 * 60 * 60, -- Daily tax collection
    payrollTime = 7 * 24 * 60 * 60, -- Weekly payroll
    bankruptcyThreshold = -50000, -- Business closes if debt exceeds this
    loanInterestRate = 0.1, -- 10% annual interest
    maxLoanAmount = 100000
}

-- Business Upgrades
Config.Upgrades = {
    ['security'] = {
        name = 'Security System',
        price = 50000,
        benefit = 'Reduces theft chance by 50%'
    },
    ['advertising'] = {
        name = 'Advertising Campaign',
        price = 25000,
        benefit = 'Increases customer flow by 25%'
    },
    ['efficiency'] = {
        name = 'Efficiency Upgrade',
        price = 75000,
        benefit = 'Reduces operating costs by 20%'
    },
    ['expansion'] = {
        name = 'Business Expansion',
        price = 100000,
        benefit = 'Increases max employees by 5'
    }
}