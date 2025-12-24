-- Los Scotia Resource Verification Script
-- This script checks if all required resources are present and properly configured

local QBCore = exports['qb-core']:GetCoreObject()

-- Resource list with their expected status
local LSResources = {
    -- Core Systems
    ['ls-scripts'] = {required = true, type = 'core', description = 'Master command and permission system'},
    ['ls-heists'] = {required = true, type = 'core', description = 'Comprehensive heist system'},
    ['ls-police'] = {required = true, type = 'core', description = 'Advanced police system'},
    ['ls-gym'] = {required = true, type = 'core', description = 'Fitness and training system'},
    
    -- Business & Economy
    ['ls-bank-advanced'] = {required = false, type = 'business', description = 'Advanced banking system'},
    ['ls-economy'] = {required = false, type = 'business', description = 'Economic management system'},
    ['ls-dealership'] = {required = false, type = 'business', description = 'Vehicle dealership system'},
    ['ls-garage'] = {required = false, type = 'business', description = 'Garage management system'},
    ['ls-insurance'] = {required = false, type = 'business', description = 'Insurance system'},
    ['ls-realestate'] = {required = false, type = 'business', description = 'Real estate system'},
    ['ls-rental'] = {required = false, type = 'business', description = 'Vehicle rental system'},
    
    -- Jobs & Services
    ['ls-medical'] = {required = false, type = 'job', description = 'Medical and EMS system'},
    ['ls-fire'] = {required = false, type = 'job', description = 'Fire department system'},
    ['ls-government'] = {required = false, type = 'job', description = 'Government and mayor system'},
    ['ls-lawyers'] = {required = false, type = 'job', description = 'Legal profession system'},
    ['ls-taxi'] = {required = false, type = 'job', description = 'Taxi service system'},
    ['ls-towing'] = {required = false, type = 'job', description = 'Towing service system'},
    ['ls-farming'] = {required = false, type = 'job', description = 'Farming and agriculture system'},
    
    -- Entertainment & Social
    ['ls-nightlife'] = {required = false, type = 'entertainment', description = 'Nightclub and bar system'},
    ['ls-racing-advanced'] = {required = false, type = 'entertainment', description = 'Advanced racing system'},
    ['ls-social'] = {required = false, type = 'entertainment', description = 'Social media system'},
    ['ls-phone-apps'] = {required = false, type = 'entertainment', description = 'Phone applications'},
    ['ls-radio'] = {required = false, type = 'entertainment', description = 'Radio station system'},
    ['ls-weather'] = {required = false, type = 'utility', description = 'Weather control system'},
    
    -- Enhanced Systems
    ['ls-police-enhanced'] = {required = false, type = 'enhanced', description = 'Enhanced police features'}
}

-- Dependencies that should be present
local Dependencies = {
    'qb-core',
    'qb-target', 
    'qb-inventory',
    'qb-menu',
    'ox_lib',
    'PolyZone',
    'progressbar',
    'interact-sound'
}

-- Verification functions
local function CheckResource(resourceName)
    local state = GetResourceState(resourceName)
    return {
        name = resourceName,
        state = state,
        running = state == 'started',
        exists = state ~= 'missing'
    }
end

local function VerifyDependencies()
    local missing = {}
    local running = {}
    local stopped = {}
    
    for _, dep in ipairs(Dependencies) do
        local result = CheckResource(dep)
        if not result.exists then
            table.insert(missing, dep)
        elseif not result.running then
            table.insert(stopped, dep)
        else
            table.insert(running, dep)
        end
    end
    
    return {
        missing = missing,
        stopped = stopped,
        running = running
    }
end

local function VerifyLSResources()
    local results = {
        core = {running = {}, stopped = {}, missing = {}},
        business = {running = {}, stopped = {}, missing = {}},
        job = {running = {}, stopped = {}, missing = {}},
        entertainment = {running = {}, stopped = {}, missing = {}},
        enhanced = {running = {}, stopped = {}, missing = {}},
        utility = {running = {}, stopped = {}, missing = {}}
    }
    
    for resourceName, info in pairs(LSResources) do
        local result = CheckResource(resourceName)
        local category = info.type
        
        if not result.exists then
            table.insert(results[category].missing, {name = resourceName, required = info.required, desc = info.description})
        elseif not result.running then
            table.insert(results[category].stopped, {name = resourceName, required = info.required, desc = info.description})
        else
            table.insert(results[category].running, {name = resourceName, required = info.required, desc = info.description})
        end
    end
    
    return results
end

local function PrintResults(depResults, lsResults)
    print('^3========================================')
    print('^2LOS SCOTIA RESOURCE VERIFICATION')
    print('^3========================================')
    
    -- Dependencies check
    print('^6DEPENDENCIES CHECK:')
    print(string.format('^2Running: %d | ^1Stopped: %d | ^1Missing: %d', 
        #depResults.running, #depResults.stopped, #depResults.missing))
    
    if #depResults.missing > 0 then
        print('^1MISSING DEPENDENCIES:')
        for _, dep in ipairs(depResults.missing) do
            print('^1  - ' .. dep)
        end
    end
    
    if #depResults.stopped > 0 then
        print('^3STOPPED DEPENDENCIES:')
        for _, dep in ipairs(depResults.stopped) do
            print('^3  - ' .. dep)
        end
    end
    
    print('')
    
    -- Los Scotia resources check
    for category, data in pairs(lsResults) do
        local total = #data.running + #data.stopped + #data.missing
        if total > 0 then
            print(string.format('^6%s SYSTEMS (%d total):', category:upper(), total))
            print(string.format('^2  Running: %d | ^3Stopped: %d | ^1Missing: %d', 
                #data.running, #data.stopped, #data.missing))
            
            -- Show missing required resources
            for _, resource in ipairs(data.missing) do
                if resource.required then
                    print(string.format('^1  MISSING REQUIRED: %s - %s', resource.name, resource.desc))
                end
            end
            
            -- Show stopped required resources
            for _, resource in ipairs(data.stopped) do
                if resource.required then
                    print(string.format('^3  STOPPED REQUIRED: %s - %s', resource.name, resource.desc))
                end
            end
        end
    end
    
    print('^3========================================')
    
    -- Summary
    local totalRunning = 0
    local totalStopped = 0
    local totalMissing = 0
    local requiredMissing = 0
    
    for _, data in pairs(lsResults) do
        totalRunning = totalRunning + #data.running
        totalStopped = totalStopped + #data.stopped
        totalMissing = totalMissing + #data.missing
        
        for _, resource in ipairs(data.missing) do
            if resource.required then
                requiredMissing = requiredMissing + 1
            end
        end
    end
    
    print('^2SUMMARY:')
    print(string.format('^2  Total LS Resources Running: %d', totalRunning))
    print(string.format('^3  Total LS Resources Stopped: %d', totalStopped))
    print(string.format('^1  Total LS Resources Missing: %d', totalMissing))
    
    if requiredMissing > 0 then
        print(string.format('^1  CRITICAL: %d required resources are missing!', requiredMissing))
        print('^1  Server may not function properly!')
    else
        print('^2  All required Los Scotia resources are available!')
    end
    
    print('^3========================================')
end

-- Commands for manual verification
if QBCore then
    QBCore.Commands.Add('lsverify', 'Verify Los Scotia resources', {}, false, function(source, args)
        local src = source
        
        if not QBCore.Functions.HasPermission(src, 'admin') then
            TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
            return
        end
        
        local depResults = VerifyDependencies()
        local lsResults = VerifyLSResources()
        
        PrintResults(depResults, lsResults)
        TriggerClientEvent('QBCore:Notify', src, 'Resource verification complete - check console', 'success')
    end, 'admin')
end

-- Auto-verification on resource start
CreateThread(function()
    Wait(10000) -- Wait 10 seconds after server start
    
    print('^3[LS-VERIFY] Starting automatic resource verification...')
    
    local depResults = VerifyDependencies()
    local lsResults = VerifyLSResources()
    
    PrintResults(depResults, lsResults)
    
    -- Check for critical issues
    if #depResults.missing > 0 then
        print('^1[LS-VERIFY] CRITICAL: Missing core dependencies! Server may not work correctly!')
    end
    
    -- Check for missing required LS resources
    local requiredMissing = false
    for _, data in pairs(lsResults) do
        for _, resource in ipairs(data.missing) do
            if resource.required then
                requiredMissing = true
                break
            end
        end
        if requiredMissing then break end
    end
    
    if requiredMissing then
        print('^1[LS-VERIFY] CRITICAL: Missing required Los Scotia resources!')
    else
        print('^2[LS-VERIFY] All required Los Scotia resources are properly loaded!')
    end
end)

-- Export verification functions
exports('VerifyDependencies', VerifyDependencies)
exports('VerifyLSResources', VerifyLSResources)
exports('CheckResource', CheckResource)

print('^2[LS-VERIFY] Resource verification system loaded!')