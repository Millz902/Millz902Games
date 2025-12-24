-- Los Scotia Scripts - Minimal Test Init
-- This version is minimal to isolate command argument issues

print('[LS-INIT] Starting minimal Los Scotia Scripts initialization...')

local QBCore = exports['qb-core']:GetCoreObject()

-- Initialize basic LSScripts table
LSScripts = {
    heists = true,
    police = true,
    medical = true,
    gym = true,
    gangs = true,
    racing = true,
    housing = true,
    business = true,
    government = true
}

-- Basic exports
exports('GetLSScripts', function()
    return LSScripts
end)

exports('IsScriptLoaded', function(scriptName)
    return LSScripts[scriptName] or false
end)

exports('CheckScriptHealth', function()
    return {
        healthy = 9,
        total = 9,
        percentage = 100
    }
end)

exports('RestartScript', function(scriptName)
    print(string.format('[LS-INIT] Restart requested for %s', scriptName))
    return true
end)

print('[LS-INIT] Minimal initialization complete - NO COMMANDS REGISTERED')