Config = Config or {}

LS_BUSINESS = LS_BUSINESS or {
    Framework = 'QBCore',
    Debug = false,
    Locale = 'en',
    Enabled = false,
    Finance = {
        StartingMoney = 10000,
        TaxRate = 0.05,
        MaxBusinesses = 5
    },
    Types = {
        restaurant = { name = 'Restaurant', cost = 50000 },
        shop = { name = 'Shop', cost = 25000 },
        garage = { name = 'Garage', cost = 75000 }
    }
}

Config.Business = LS_BUSINESS
return LS_BUSINESS