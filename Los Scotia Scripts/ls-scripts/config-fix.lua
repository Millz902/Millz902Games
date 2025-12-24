-- Config Validation and Nil Check Fix for Los Scotia Scripts
-- This file ensures all configs are properly initialized and dynamically loads existing config files

-- Enhanced loader with granular diagnostics (file missing / compile error / runtime error)
local function TryLoadConfig(configPath, configName, metrics)
    local resourceName = GetCurrentResourceName()
    local configContent = LoadResourceFile(resourceName, configPath)

    if not configContent then
        print(('[LS-CONFIG-FIX] Config %s missing (path: %s)'):format(configName, configPath))
        return false, 'missing'
    end

    -- Strip UTF-8 BOM if present (0xEF 0xBB 0xBF)
    if configContent:sub(1,3) == '\239\187\191' then
        configContent = configContent:sub(4)
    end

    local tStart = GetGameTimer() or 0
    print(('[LS-CONFIG-FIX] Loading %s config...'):format(configName))

    local chunk, compileErr = load(configContent, ('@%s/%s'):format(resourceName, configPath))
    if not chunk then
        print(('[LS-CONFIG-FIX] Config %s compile error: %s'):format(configName, tostring(compileErr)))
        return false, compileErr
    end

    local ok, runtimeErr = pcall(chunk)
    if not ok then
        print(('[LS-CONFIG-FIX] Config %s runtime error: %s'):format(configName, tostring(runtimeErr)))
        return false, runtimeErr
    end

    local elapsed = (GetGameTimer() or tStart) - tStart
    if metrics then
        metrics[configName] = elapsed
    end
    print(('[LS-CONFIG-FIX] Successfully loaded %s (%.1f ms)'):format(configName, elapsed))
    return true
end

-- Try to load all config files
local configFiles = {
    {'ls-heists/config.lua', 'LS-HEISTS'},
    {'ls-police/config.lua', 'LS-POLICE'},
    {'ls-medical/config.lua', 'LS-MEDICAL'},
    {'ls-gym/config.lua', 'LS-GYM'},
    {'ls-business/config.lua', 'LS-BUSINESS'},
    {'ls-gangs/config.lua', 'LS-GANGS'},
    {'ls-racing/config.lua', 'LS-RACING'},
    {'ls-housing/config.lua', 'LS-HOUSING'},
    {'ls-government/config.lua', 'LS-GOVERNMENT'},
    {'ls-bank-advanced/config.lua', 'LS-BANK-ADVANCED'},
    {'ls-dealership/config.lua', 'LS-DEALERSHIP'},
    {'ls-economy/config.lua', 'LS-ECONOMY'},
    {'ls-farming/config.lua', 'LS-FARMING'},
    {'ls-fire/config.lua', 'LS-FIRE'},
    {'ls-insurance/config.lua', 'LS-INSURANCE'},
    {'ls-lawyers/config.lua', 'LS-LAWYERS'},
    {'ls-nightlife/config.lua', 'LS-NIGHTLIFE'},
    {'ls-phone-apps/config.lua', 'LS-PHONE-APPS'},
    {'ls-racing-advanced/config.lua', 'LS-RACING-ADVANCED'},
    {'ls-radio/config.lua', 'LS-RADIO'},
    {'ls-realestate/config.lua', 'LS-REALESTATE'},
    {'ls-rental/config.lua', 'LS-RENTAL'},
    {'ls-social/config.lua', 'LS-SOCIAL'},
    {'ls-taxi/config.lua', 'LS-TAXI'},
    {'ls-towing/config.lua', 'LS-TOWING'},
    {'ls-verify/config.lua', 'LS-VERIFY'},
    {'ls-weather/config.lua', 'LS-WEATHER'}
}

-- Load configs that exist
local loadSummary = { total = 0, ok = 0, failed = 0, failures = {}, timings = {} }
for _, configInfo in ipairs(configFiles) do
    loadSummary.total = loadSummary.total + 1
    local ok, err = TryLoadConfig(configInfo[1], configInfo[2], loadSummary.timings)
    if ok then
        loadSummary.ok = loadSummary.ok + 1
    else
        loadSummary.failed = loadSummary.failed + 1
        table.insert(loadSummary.failures, { name = configInfo[2], error = err })
    end
end

if loadSummary.failed > 0 then
    print(('[LS-CONFIG-FIX] Summary: %d/%d configs loaded, %d failed'):
        format(loadSummary.ok, loadSummary.total, loadSummary.failed))
    for _, f in ipairs(loadSummary.failures) do
        print(('[LS-CONFIG-FIX]   -> %s failed: %s'):format(f.name, tostring(f.error)))
    end
else
    print(('[LS-CONFIG-FIX] All %d configs loaded successfully'):format(loadSummary.total))
end

-- Print timing summary (top 5 slowest)
do
    local sortable = {}
    for name, ms in pairs(loadSummary.timings) do
        table.insert(sortable, {name = name, ms = ms})
    end
    table.sort(sortable, function(a,b) return a.ms > b.ms end)
    print('[LS-CONFIG-FIX] Load time (ms) top modules:')
    for i=1, math.min(5, #sortable) do
        print(('  #%d %s: %.1f ms'):format(i, sortable[i].name, sortable[i].ms))
    end
end
if not LS_HEISTS then LS_HEISTS = {} end
if not LS_POLICE then LS_POLICE = {} end
if not LS_MEDICAL then LS_MEDICAL = {} end
if not LS_GYM then LS_GYM = {} end
if not LS_BUSINESS then LS_BUSINESS = {} end
if not LS_GANGS then LS_GANGS = {} end
if not LS_RACING then LS_RACING = {} end
if not LS_HOUSING then LS_HOUSING = {} end
if not LS_GOVERNMENT then LS_GOVERNMENT = {} end
if not LS_BANK_ADVANCED then LS_BANK_ADVANCED = {} end
if not LS_DEALERSHIP then LS_DEALERSHIP = {} end
if not LS_ECONOMY then LS_ECONOMY = {} end
if not LS_FARMING then LS_FARMING = {} end
if not LS_FIRE then LS_FIRE = {} end
if not LS_INSURANCE then LS_INSURANCE = {} end
if not LS_LAWYERS then LS_LAWYERS = {} end
if not LS_NIGHTLIFE then LS_NIGHTLIFE = {} end
if not LS_PHONE_APPS then LS_PHONE_APPS = {} end
if not LS_RACING_ADVANCED then LS_RACING_ADVANCED = {} end
if not LS_RADIO then LS_RADIO = {} end
if not LS_REALESTATE then LS_REALESTATE = {} end
if not LS_RENTAL then LS_RENTAL = {} end
if not LS_SOCIAL then LS_SOCIAL = {} end
if not LS_TAXI then LS_TAXI = {} end
if not LS_TOWING then LS_TOWING = {} end
if not LS_VERIFY then LS_VERIFY = {} end
if not LS_WEATHER then LS_WEATHER = {} end

-- Safe iteration function to prevent nil table errors
function SafeIteratePairs(tbl)
    if not tbl or type(tbl) ~= 'table' then
        return pairs({})
    end
    return pairs(tbl)
end

function SafeIterateIpairs(tbl)
    if not tbl or type(tbl) ~= 'table' then
        return ipairs({})
    end
    return ipairs(tbl)
end

-- Safe table access functions
function SafeTableGet(tbl, key, default)
    if not tbl or type(tbl) ~= 'table' then
        return default
    end
    return tbl[key] or default
end

function SafeTableSet(tbl, key, value)
    if not tbl or type(tbl) ~= 'table' then
        return false
    end
    tbl[key] = value
    return true
end

-- Initialize common config structures
local function InitializeCommonConfigs()
    -- Initialize gym config if empty
    if not LS_GYM.Memberships then
        LS_GYM.Memberships = {
            basic = { name = "Basic", price = 50, duration = 7 },
            premium = { name = "Premium", price = 100, duration = 14 },
            vip = { name = "VIP", price = 200, duration = 30 }
        }
    end
    
    if not LS_GYM.Exercises then
        LS_GYM.Exercises = {
            treadmill = { name = "Treadmill", stamina = 5 },
            weights = { name = "Weight Lifting", strength = 5 },
            boxing = { name = "Boxing Bag", stamina = 3, strength = 2 }
        }
    end
    
    -- Initialize business config if empty
    if not LS_BUSINESS then
        LS_BUSINESS = {
            Finance = {
                StartingMoney = 10000,
                TaxRate = 0.05,
                MaxBusinesses = 5
            },
            Types = {
                restaurant = { name = "Restaurant", cost = 50000 },
                shop = { name = "Shop", cost = 25000 },
                garage = { name = "Garage", cost = 75000 }
            }
        }
    elseif not LS_BUSINESS.Finance then
        LS_BUSINESS.Finance = {
            StartingMoney = 10000,
            TaxRate = 0.05,
            MaxBusinesses = 5
        }
    end
    
    -- Initialize housing config if empty
    if not LS_HOUSING.Properties then
        LS_HOUSING.Properties = {}
    end
    
    if not LS_HOUSING.Settings then
        LS_HOUSING.Settings = {
            MaxProperties = 3,
            TaxRate = 0.02,
            RentMultiplier = 0.1
        }
    end
end

-- Run initialization
-- Basic schema expectations (lightweight; extendable)
local SCHEMA = {
    ['LS-GYM'] = { 'Gyms', 'Memberships' },
    ['LS-FARMING'] = { 'Farms', 'Market' },
    ['LS-ECONOMY'] = { 'StockMarket', 'Businesses' },
}

local function RunSchemaValidation()
    for label, required in pairs(SCHEMA) do
        local globalName = label:gsub('%-', '_') -- crude map LS-GYM -> LS_GYM
        local tbl = _G[globalName]
        if type(tbl) == 'table' then
            for _, key in ipairs(required) do
                if tbl[key] == nil then
                    print(('[LS-CONFIG-FIX] [SCHEMA] %s missing key: %s'):format(label, key))
                end
            end
        end
    end
end

-- Hot reload logic
local function ReloadConfig(label)
    for _, cfg in ipairs(configFiles) do
        if cfg[2] == label then
            print(('[LS-RELOAD] Reloading %s ...'):format(label))
            local ok, err = TryLoadConfig(cfg[1], cfg[2], loadSummary.timings)
            if ok then
                print(('[LS-RELOAD] %s reloaded successfully'):format(label))
            else
                print(('[LS-RELOAD] %s reload failed: %s'):format(label, tostring(err)))
            end
            return
        end
    end
    print(('[LS-RELOAD] Unknown label: %s'):format(label))
end

RegisterCommand('ls_reload', function(source, args)
    if source ~= 0 then
        -- Add permission checks here if needed
    end
    local label = args[1]
    if not label then
        print('Usage: /ls_reload LS-GYM')
        return
    end
    ReloadConfig(label)
end, true)

RegisterCommand('ls_reload_all', function(source)
    if source ~= 0 then
        -- Add permission checks here if needed
    end
    print('[LS-RELOAD] Reloading all configs...')
    for _, cfg in ipairs(configFiles) do
        TryLoadConfig(cfg[1], cfg[2], loadSummary.timings)
    end
    print('[LS-RELOAD] All reload attempts complete.')
end, true)

CreateThread(function()
    Wait(1000)
    InitializeCommonConfigs()
    RunSchemaValidation()
    print('[LS-CONFIG-FIX] All Los Scotia configs initialized safely!')
end)

-- Make globals available
_G.SafeIteratePairs = SafeIteratePairs
_G.SafeIterateIpairs = SafeIterateIpairs
_G.SafeTableGet = SafeTableGet
_G.SafeTableSet = SafeTableSet

print('[LS-CONFIG-FIX] Config validation and nil check system loaded!')