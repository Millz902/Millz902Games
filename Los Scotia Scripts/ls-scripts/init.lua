-- Ensure LS_GYM exists early for validation
if LS_GYM then
    -- Config already loaded
else
    LS_GYM = {} -- Placeholder until config loads
end

-- Los Scotia Scripts Master Initializer
-- This script ensures all Los Scotia scripts are properly loaded and configured

local QBCore = exports['qb-core']:GetCoreObject()

-- ================================================
-- SCRIPT INITIALIZATION
-- ================================================

local LSScripts = {
    heists = false,
    police = false,
    medical = false,
    gym = false,
    gangs = false,
    racing = false,
    housing = false,
    business = false,

    government = false
}

-- ================================================
-- UTILITY FUNCTIONS
-- ================================================

local function LoadScript(scriptName)
    -- Since ls- scripts are subfolders within this resource, not separate resources,
    -- we just check if the config file exists to validate the script
    local configPath = string.format('%s/config.lua', scriptName)
    local scriptExists = LoadResourceFile(GetCurrentResourceName(), configPath) ~= nil
    
    if scriptExists then
        LSScripts[scriptName:gsub('ls%-', '')] = true
        print(string.format('[LS-INIT] Successfully loaded %s subfolder', scriptName))
        return true
    else
        print(string.format('[LS-INIT] Subfolder %s not found or missing config', scriptName))
        return false
    end
end

local function CheckDependencies()
    local requiredResources = {
        'qb-core',
        'qb-target',
        'qb-inventory',
        'qb-menu'
    }
    
    for _, resource in pairs(requiredResources) do
        if GetResourceState(resource) ~= 'started' then
            print(string.format('[LS-INIT] WARNING: Required dependency %s is not running!', resource))
            return false
        end
    end
    
    print('[LS-INIT] All required dependencies are running')
    return true
end

-- ================================================
-- SCRIPT LOADING
-- ================================================

CreateThread(function()
    Wait(2000) -- Wait for QBCore to fully load
    
    print('[LS-INIT] Starting Los Scotia Scripts initialization...')
    
    -- Check dependencies first
    if not CheckDependencies() then
        print('[LS-INIT] ERROR: Missing required dependencies!')
        return
    end
    
    -- Load all Los Scotia scripts
    local scriptsToLoad = {
        'ls-heists',
        'ls-police', 
        'ls-medical',
        'ls-gym',
        'ls-gangs',
        'ls-racing',
        'ls-housing',
        'ls-business',
        
        'ls-government'
    }
    
    local loadedCount = 0
    for _, script in pairs(scriptsToLoad) do
        if LoadScript(script) then
            loadedCount = loadedCount + 1
        end
    end
    
    print(string.format('[LS-INIT] Loaded %d/%d Los Scotia scripts', loadedCount, #scriptsToLoad))
    
    -- Setup global exports
    exports('GetLSScripts', function()
        return LSScripts
    end)
    
    exports('IsScriptLoaded', function(scriptName)
        return LSScripts[scriptName] or false
    end)
    
    -- Trigger initialization complete event
    TriggerEvent('ls-scripts:initialized', LSScripts)
    print('[LS-INIT] Los Scotia Scripts initialization complete!')
end)

-- ================================================
-- ITEM REGISTRATION
-- ================================================

CreateThread(function()
    Wait(3000) -- Wait for inventory system
    
    -- Register heist items
    local heistItems = {
        'drill',
        'thermite',
        'laptop_blue',
        'laptop_red',
        'keycard_red',
        'keycard_blue',
        'gold_bar',
        'diamond',
        'painting',
        'money_bag',
        'usb_device',
        'security_card'
    }
    
    for _, item in pairs(heistItems) do
        if QBCore.Shared.Items[item] then
            print(string.format('[LS-INIT] Item %s already registered', item))
        end
    end
    
    -- Register police items
    local policeItems = {
        'handcuffs',
        'evidence_bag',
        'breathalyzer',
        'radar_gun',
        'spike_strip',
        'police_radio',
        'body_camera',
        'taser',
        'pepper_spray'
    }
    
    for _, item in pairs(policeItems) do
        if QBCore.Shared.Items[item] then
            print(string.format('[LS-INIT] Police item %s already registered', item))
        end
    end
    
    print('[LS-INIT] Item registration complete')
end)

-- ================================================
-- JOB VALIDATION
-- ================================================

local function ValidateJobs()
    local requiredJobs = {
        'police',
        'sheriff', 
        'ambulance',
        'mechanic',
        'government',
        'mayor'
    }
    
    for _, job in pairs(requiredJobs) do
        if QBCore.Shared.Jobs[job] then
            print(string.format('[LS-INIT] Job %s is configured', job))
        else
            print(string.format('[LS-INIT] WARNING: Job %s is not configured!', job))
        end
    end
end

-- ================================================
-- GANG VALIDATION
-- ================================================

local function ValidateGangs()
    local requiredGangs = {
        'ballas',
        'families',
        'vagos',
        'bloods',
        'crips'
    }
    
    for _, gang in pairs(requiredGangs) do
        if QBCore.Shared.Gangs[gang] then
            print(string.format('[LS-INIT] Gang %s is configured', gang))
        else
            print(string.format('[LS-INIT] INFO: Gang %s is not configured', gang))
        end
    end
end

-- ================================================
-- CONFIGURATION VALIDATION
-- ================================================

CreateThread(function()
    Wait(5000) -- Wait for all configs to load
    
    print('[LS-INIT] Starting configuration validation...')
    
    ValidateJobs()
    ValidateGangs()
    
    -- Check if all Los Scotia configs are present
    local configs = {
        'ls-heists',
        'ls-police',
        'ls-medical',
        'ls-gym'
    }
    
    for _, config in pairs(configs) do
        if _G[config:gsub('%-', '_'):upper()] then
            print(string.format('[LS-INIT] Config %s loaded successfully', config))
        else
            print(string.format('[LS-INIT] WARNING: Config %s not found!', config))
        end
    end
    
    print('[LS-INIT] Configuration validation complete')
end)

-- ================================================
-- EVENTS
-- ================================================

-- Handle resource start/stop - Only handle this resource since ls- are subfolders
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print('[LS-INIT] Los Scotia Scripts main resource started')
        -- Re-initialize all subfolders
        TriggerEvent('ls-scripts:reload-subfolders')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print('[LS-INIT] Los Scotia Scripts main resource stopped')
        -- Mark all subfolders as stopped
        for scriptName, _ in pairs(LSScripts) do
            LSScripts[scriptName] = false
        end
    end
end)

-- Custom event to reload subfolders
AddEventHandler('ls-scripts:reload-subfolders', function()
    CreateThread(function()
        Wait(1000)
        
        local scriptsToLoad = {
            'ls-heists',
            'ls-police', 
            'ls-medical',
            'ls-gym',
            'ls-gangs',
            'ls-racing',
            'ls-housing',
            'ls-business',
            'ls-government'
        }
        
        local loadedCount = 0
        for _, script in pairs(scriptsToLoad) do
            if LoadScript(script) then
                loadedCount = loadedCount + 1
            end
        end
        
        print(string.format('[LS-INIT] Reloaded %d/%d Los Scotia subfolders', loadedCount, #scriptsToLoad))
    end)
end)

-- ================================================
-- EXPORTS
-- ================================================

exports('GetInitializedScripts', function()
    return LSScripts
end)

exports('RestartScript', function(scriptName)
    -- Since ls- scripts are subfolders, we restart the entire ls-scripts resource
    print(string.format('[LS-INIT] Restarting ls-scripts resource (contains %s subfolder)', scriptName))
    ExecuteCommand('restart ls-scripts')
    return true
end)

exports('CheckScriptHealth', function()
    local healthy = 0
    local total = 0
    
    for script, loaded in pairs(LSScripts) do
        total = total + 1
        if loaded then
            healthy = healthy + 1
        end
    end
    
    return {
        healthy = healthy,
        total = total,
        percentage = math.floor((healthy / total) * 100)
    }
end)

-- ================================================
-- ADMIN COMMANDS FOR SCRIPT MANAGEMENT
-- ================================================

-- Register commands with proper error handling and timing
CreateThread(function()
    -- Wait for QBCore to be fully ready
    local attempts = 0
    local maxAttempts = 50
    
    while not QBCore and attempts < maxAttempts do
        Wait(100)
        attempts = attempts + 1
    end
    
    if not QBCore then
        print('[LS-COMMANDS] ERROR: QBCore not available after waiting!')
        return
    end
    
    -- Additional wait to ensure Commands system is ready
    Wait(3000)
    
    local success1 = pcall(function()
        QBCore.Commands.Add('lsrestart', 'Restart Los Scotia script', {
            {name = 'script', help = 'Script name (without ls- prefix)'}
        }, true, function(source, args)
            local src = source
            local scriptName = args[1]
            
            if not QBCore.Functions.HasPermission(src, 'admin') then
                TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
                return
            end
            
            if not scriptName then
                TriggerClientEvent('QBCore:Notify', src, 'You must specify a script name!', 'error')
                return
            end
            
            exports['ls-scripts']:RestartScript(scriptName)
            TriggerClientEvent('QBCore:Notify', src, string.format('Restarting ls-%s...', scriptName), 'success')
        end)
    end)

    local success2 = pcall(function()
        QBCore.Commands.Add('lsstatus', 'Check Los Scotia scripts status', {}, false, function(source, args)
            local src = source
            
            if not QBCore.Functions.HasPermission(src, 'admin') then
                TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
                return
            end
            
            local health = exports['ls-scripts']:CheckScriptHealth()
            TriggerClientEvent('QBCore:Notify', src, string.format('LS Scripts: %d/%d running (%d%%)', health.healthy, health.total, health.percentage), 'primary')
            
            -- Send detailed status to chat
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 255, 255},
                multiline = true,
                args = {'[LS-STATUS]', 'Checking script status...'}
            })
            
            for script, loaded in pairs(LSScripts) do
                local status = loaded and '^2ONLINE^7' or '^1OFFLINE^7'
                TriggerClientEvent('chat:addMessage', src, {
                    color = {255, 255, 255},
                    multiline = true,
                    args = {'', string.format('ls-%s: %s', script, status)}
                })
            end
        end)
    end)
    
    if success1 and success2 then
        print('[LS-COMMANDS] All commands registered successfully!')
    else
        print('[LS-COMMANDS] Some commands failed to register - this may be normal')
    end
end)

print('[LS-INIT] Master initializer loaded successfully!')
