Config = {}

-- Business Management Configuration
Config.Debug = false
Config.Framework = 'qb-core' -- 'qb-core' or 'esx'

-- Database Configuration
Config.UseOxMySQL = true

-- Business Settings
Config.DefaultBusinessType = 'general'
Config.MaxEmployees = 10
Config.DefaultTaxRate = 5.0

-- Business Types
Config.BusinessTypes = {
    ['general'] = { label = 'General Store', category = 'retail' },
    ['restaurant'] = { label = 'Restaurant', category = 'food' },
    ['garage'] = { label = 'Auto Shop', category = 'automotive' },
    ['clothing'] = { label = 'Clothing Store', category = 'retail' },
    ['electronics'] = { label = 'Electronics Store', category = 'retail' }
}

-- Employee Ranks
Config.EmployeeRanks = {
    ['employee'] = { label = 'Employee', grade = 0, salary = 50 },
    ['supervisor'] = { label = 'Supervisor', grade = 1, salary = 75 },
    ['manager'] = { label = 'Manager', grade = 2, salary = 100 },
    ['owner'] = { label = 'Owner', grade = 3, salary = 0 }
}

-- Business Commands
Config.Commands = {
    ['business'] = 'business',
    ['business_hire'] = 'businesshire',
    ['business_fire'] = 'businessfire',
    ['business_promote'] = 'businesspromote'
}

-- Keybind Settings
Config.Keybinds = {
    ['open_business_menu'] = 'F6'
}