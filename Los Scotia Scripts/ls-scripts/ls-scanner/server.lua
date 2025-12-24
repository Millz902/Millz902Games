local QBCore = exports['qb-core']:GetCoreObject()
local debug = false -- Set to true for verbose logging

-- Configuration
local Config = {
    scanDelay = 1000, -- Delay between scanning resources (ms)
    checkSQL = true,  -- Check SQL files for integrity
    checkDependencies = true, -- Check for missing dependencies
    checkScriptHooks = true,  -- Check for script hook conflicts
    scanWebhooks = true,      -- Check for webhook conflicts
    checkTextures = true,     -- Check for texture dictionary conflicts
    checkEvents = true,       -- Check for duplicate registered events
    ignoreResources = {       -- Resources to ignore in conflict checks
        "yarn",
        "webpack",
        "runcode",
        "monitor",
        "screenshot-basic",
    },
    knownConflicts = {        -- Known conflicting resource pairs
        {"qb-banking", "rl-banking"},
        {"qb-banking", "ls-bank-advanced"},
        {"rl-banking", "ls-bank-advanced"},
        {"smartphone-pro", "phone-for-everyone"},
        {"webhook_fix", "Discordhooks"},
        {"webhook_fix", "ls-discord-webhooks"},
        {"Discordhooks", "ls-discord-webhooks"}
    },
    requiredResources = {     -- Core resources that should be present
        "qb-core",
        "oxmysql",
        "qb-inventory",
        "illenium-appearance",
        "qb-multicharacter"
    }
}

-- Global storage for scan results
local scanResults = {
    conflicts = {},
    missingDependencies = {},
    sqlIssues = {},
    webhookIssues = {},
    scriptHookIssues = {},
    textureIssues = {},
    eventIssues = {},
    missingRequiredResources = {},
    resourceErrors = {}
}

-- Helper function to log with timestamp
local function logMessage(message, type)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local prefix = "[LS-SCANNER]"
    local colorCode = "^7" -- Default white
    
    if type == "error" then
        colorCode = "^1" -- Red
    elseif type == "warning" then
        colorCode = "^3" -- Yellow
    elseif type == "success" then
        colorCode = "^2" -- Green
    elseif type == "info" then
        colorCode = "^5" -- Blue
    end
    
    print(colorCode .. prefix .. " " .. timestamp .. " - " .. message .. "^7")
    
    -- If debug mode, also log to server console
    if debug then
        if type == "error" then
            print("^1[DEBUG] " .. message .. "^7")
        elseif type == "warning" then
            print("^3[DEBUG] " .. message .. "^7")
        else
            print("^7[DEBUG] " .. message .. "^7")
        end
    end
end

-- Check if a resource should be ignored
local function shouldIgnoreResource(resourceName)
    for _, ignoredResource in ipairs(Config.ignoreResources) do
        if resourceName == ignoredResource then
            return true
        end
    end
    return false
end

-- Check for known conflicts between resources
local function checkKnownConflicts()
    logMessage("Checking for known resource conflicts...", "info")
    local startedResources = {}
    local enabledResources = {}
    
    -- Get list of all resources
    local numResources = GetNumResources()
    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        
        -- Check if the resource is started or enabled
        if GetResourceState(resource) == "started" then
            table.insert(startedResources, resource)
        elseif GetResourceState(resource) == "starting" then
            table.insert(enabledResources, resource)
        end
    end
    
    -- Check for known conflicts in started resources
    for _, conflictPair in ipairs(Config.knownConflicts) do
        local resource1 = conflictPair[1]
        local resource2 = conflictPair[2]
        
        local resource1Started = false
        local resource2Started = false
        
        for _, resource in ipairs(startedResources) do
            if resource == resource1 then resource1Started = true end
            if resource == resource2 then resource2Started = true end
        end
        
        if resource1Started and resource2Started then
            local conflictEntry = {
                resources = {resource1, resource2},
                type = "known_conflict",
                description = "Known conflict between " .. resource1 .. " and " .. resource2
            }
            table.insert(scanResults.conflicts, conflictEntry)
            logMessage("Found known conflict: " .. resource1 .. " and " .. resource2, "warning")
        end
    end
    
    return #scanResults.conflicts
end

-- Check if required resources are present
local function checkRequiredResources()
    logMessage("Checking for required resources...", "info")
    local numResources = GetNumResources()
    local foundResources = {}
    
    -- Get list of all resources
    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        if GetResourceState(resource) == "started" then
            foundResources[resource] = true
        end
    end
    
    -- Check if all required resources are present
    for _, requiredResource in ipairs(Config.requiredResources) do
        if not foundResources[requiredResource] then
            table.insert(scanResults.missingRequiredResources, requiredResource)
            logMessage("Missing required resource: " .. requiredResource, "error")
        end
    end
    
    return #scanResults.missingRequiredResources
end

-- Check for resource errors
local function checkResourceErrors()
    logMessage("Checking for resource errors...", "info")
    local numResources = GetNumResources()
    
    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        if not shouldIgnoreResource(resource) then
            local state = GetResourceState(resource)
            
            if state == "failed" or state == "missing" or state == "unloaded" then
                local errorInfo = {
                    resource = resource,
                    state = state,
                    description = "Resource is in " .. state .. " state"
                }
                table.insert(scanResults.resourceErrors, errorInfo)
                logMessage("Resource error: " .. resource .. " is in state: " .. state, "error")
            end
        end
    end
    
    return #scanResults.resourceErrors
end

-- Check for missing dependencies between resources
local function checkMissingDependencies()
    if not Config.checkDependencies then return 0 end
    
    logMessage("Checking for missing dependencies...", "info")
    local numResources = GetNumResources()
    local allResources = {}
    local resourceDependencyMap = {}
    local resourceState = {}
    local commonFrameworkDependencies = {
        ["qb-core"] = {"qb-", "rl-", "ls-"},
        ["ox_lib"] = {"ox_", "ox-"},
        ["es_extended"] = {"esx-", "esx_"}
    }
    
    -- First, gather all available resources and their states
    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        allResources[resource] = true
        resourceState[resource] = GetResourceState(resource)
    end
    
    -- Then check each resource's dependencies
    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        
        if not shouldIgnoreResource(resource) then
            resourceDependencyMap[resource] = {}
            
            local resourceManifest = LoadResourceFile(resource, "fxmanifest.lua")
            if not resourceManifest then
                resourceManifest = LoadResourceFile(resource, "__resource.lua")
            end
            
            if resourceManifest then
                -- Look for explicit dependencies in the manifest file
                for dependency in string.gmatch(resourceManifest, "dependency%s+['\"]([^'\"]+)['\"]") do
                    table.insert(resourceDependencyMap[resource], dependency)
                    if not allResources[dependency] then
                        local dependencyInfo = {
                            resource = resource,
                            dependency = dependency,
                            description = "Resource " .. resource .. " depends on missing resource " .. dependency,
                            type = "explicit_missing"
                        }
                        table.insert(scanResults.missingDependencies, dependencyInfo)
                        logMessage("Missing dependency: " .. resource .. " requires " .. dependency, "error")
                    elseif resourceState[dependency] ~= "started" then
                        local dependencyInfo = {
                            resource = resource,
                            dependency = dependency,
                            description = "Resource " .. resource .. " depends on resource " .. dependency .. " which is not started (state: " .. resourceState[dependency] .. ")",
                            type = "explicit_not_started"
                        }
                        table.insert(scanResults.missingDependencies, dependencyInfo)
                        logMessage("Dependency not started: " .. resource .. " requires " .. dependency .. " (state: " .. resourceState[dependency] .. ")", "warning")
                    end
                end
                
                -- Check for implicit dependencies based on resource prefixes and exports usage
                for framework, prefixes in pairs(commonFrameworkDependencies) do
                    -- Skip if the framework itself or it's already an explicit dependency
                    if resource ~= framework and not resourceDependencyMap[resource][framework] then
                        local usesFramework = false
                        
                        -- Check if resource name starts with a framework prefix
                        for _, prefix in ipairs(prefixes) do
                            if resource:sub(1, #prefix) == prefix then
                                usesFramework = true
                                break
                            end
                        end
                        
                        -- Check if resource code uses exports from the framework
                        if not usesFramework and resourceManifest:find("exports%s*%[%s*['\"]" .. framework .. "['\"]%s*%]") then
                            usesFramework = true
                        end
                        
                        -- Also check client and server files for exports usage
                        if not usesFramework then
                            local clientFiles = {"client.lua", "client/main.lua", "cl_main.lua", "cl.lua"}
                            local serverFiles = {"server.lua", "server/main.lua", "sv_main.lua", "sv.lua"}
                            
                            for _, file in ipairs(clientFiles) do
                                local content = LoadResourceFile(resource, file)
                                if content and content:find("exports%s*%[%s*['\"]" .. framework .. "['\"]%s*%]") then
                                    usesFramework = true
                                    break
                                end
                            end
                            
                            if not usesFramework then
                                for _, file in ipairs(serverFiles) do
                                    local content = LoadResourceFile(resource, file)
                                    if content and content:find("exports%s*%[%s*['\"]" .. framework .. "['\"]%s*%]") then
                                        usesFramework = true
                                        break
                                    end
                                end
                            end
                        end
                        
                        -- Add implicit dependency if we found framework usage
                        if usesFramework then
                            table.insert(resourceDependencyMap[resource], framework)
                            
                            -- Check if the implicit dependency exists and is started
                            if not allResources[framework] then
                                local dependencyInfo = {
                                    resource = resource,
                                    dependency = framework,
                                    description = "Resource " .. resource .. " implicitly depends on missing framework " .. framework,
                                    type = "implicit_missing"
                                }
                                table.insert(scanResults.missingDependencies, dependencyInfo)
                                logMessage("Missing implicit dependency: " .. resource .. " implicitly requires " .. framework, "error")
                            elseif resourceState[framework] ~= "started" then
                                local dependencyInfo = {
                                    resource = resource,
                                    dependency = framework,
                                    description = "Resource " .. resource .. " implicitly depends on framework " .. framework .. " which is not started (state: " .. resourceState[framework] .. ")",
                                    type = "implicit_not_started"
                                }
                                table.insert(scanResults.missingDependencies, dependencyInfo)
                                logMessage("Framework not started: " .. resource .. " implicitly requires " .. framework .. " (state: " .. resourceState[framework] .. ")", "warning")
                            end
                        end
                    end
                end
                
                -- Check loading order for dependencies
                for _, dependency in ipairs(resourceDependencyMap[resource]) do
                    if allResources[dependency] and resourceState[dependency] == "started" and resourceState[resource] == "started" then
                        -- Check if dependency is loaded before the resource that depends on it
                        local dependencyIndex = GetResourceMetadata(dependency, "resource_load_index")
                        local resourceIndex = GetResourceMetadata(resource, "resource_load_index")
                        
                        if dependencyIndex and resourceIndex and tonumber(dependencyIndex) > tonumber(resourceIndex) then
                            local dependencyInfo = {
                                resource = resource,
                                dependency = dependency,
                                description = "Resource " .. resource .. " loads before its dependency " .. dependency .. " - incorrect load order",
                                type = "incorrect_order"
                            }
                            table.insert(scanResults.missingDependencies, dependencyInfo)
                            logMessage("Incorrect load order: " .. resource .. " loads before its dependency " .. dependency, "warning")
                        end
                    end
                end
            end
        end
    end
    
    -- Detect circular dependencies
    local function checkCircularDependencies(resourceName, visited, path)
        if not resourceDependencyMap[resourceName] then return false end
        
        visited[resourceName] = true
        path[resourceName] = true
        
        for _, dependency in ipairs(resourceDependencyMap[resourceName]) do
            if path[dependency] then
                -- Found a circular dependency
                local cycle = dependency
                local circularPath = {dependency}
                local current = resourceName
                
                while current ~= dependency do
                    table.insert(circularPath, 1, current)
                    for res, deps in pairs(resourceDependencyMap) do
                        if not path[res] then goto continue end
                        
                        for _, dep in ipairs(deps) do
                            if dep == current then
                                current = res
                                break
                            end
                        end
                        ::continue::
                    end
                end
                
                local dependencyInfo = {
                    resource = resourceName,
                    dependency = dependency,
                    description = "Circular dependency detected: " .. table.concat(circularPath, " -> "),
                    type = "circular"
                }
                table.insert(scanResults.missingDependencies, dependencyInfo)
                logMessage("Circular dependency: " .. table.concat(circularPath, " -> "), "error")
                return true
            elseif not visited[dependency] and resourceDependencyMap[dependency] then
                if checkCircularDependencies(dependency, visited, path) then
                    return true
                end
            end
        end
        
        path[resourceName] = false
        return false
    end
    
    -- Check for circular dependencies in all resources
    local visited = {}
    for resource, _ in pairs(resourceDependencyMap) do
        if not visited[resource] then
            checkCircularDependencies(resource, visited, {})
        end
    end
    
    return #scanResults.missingDependencies
end

-- Check for webhook conflicts and issues
local function checkWebhookIssues()
    if not Config.scanWebhooks then return 0 end
    
    logMessage("Checking for webhook issues...", "info")
    local webhooks = {}
    local numResources = GetNumResources()
    
    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        
        if not shouldIgnoreResource(resource) then
            -- Load server files to check for webhook definitions
            local serverFiles = {
                "server.lua",
                "server/main.lua",
                "server/server.lua",
                "sv_main.lua",
                "sv.lua"
            }
            
            for _, file in ipairs(serverFiles) do
                local fileContent = LoadResourceFile(resource, file)
                
                if fileContent then
                    -- Look for webhook URL definitions
                    for webhook in string.gmatch(fileContent, "https://discord.com/api/webhooks/[^\"'%s]+") do
                        if webhooks[webhook] then
                            table.insert(webhooks[webhook].resources, resource)
                        else
                            webhooks[webhook] = {
                                webhook = webhook,
                                resources = {resource}
                            }
                        end
                    end
                end
            end
        end
    end
    
    -- Check for duplicate webhook usage
    for webhook, info in pairs(webhooks) do
        if #info.resources > 1 then
            local webhookIssue = {
                webhook = webhook,
                resources = info.resources,
                description = "Webhook used by multiple resources: " .. table.concat(info.resources, ", ")
            }
            table.insert(scanResults.webhookIssues, webhookIssue)
            logMessage("Webhook conflict found: " .. webhook .. " used by " .. table.concat(info.resources, ", "), "warning")
        end
    end
    
    return #scanResults.webhookIssues
end

-- Run SQL integrity check
local function checkSQLIntegrity()
    if not Config.checkSQL then return 0 end
    
    logMessage("Checking for SQL integrity issues...", "info")
    local numResources = GetNumResources()
    local sqlTablesFound = {}
    local sqlResourceFiles = {}
    
    -- First pass: gather all SQL files and table definitions
    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)
        
        if not shouldIgnoreResource(resource) then
            -- Look for SQL files in common locations
            local sqlFiles = {
                "sql/table.sql",
                "sql/tables.sql",
                "sql/install.sql", 
                "sql/setup.sql",
                "install.sql",
                "database.sql",
                "setup.sql",
                "sql/init.sql",
                "init.sql"
            }
            
            sqlResourceFiles[resource] = {}
            
            for _, file in ipairs(sqlFiles) do
                local sqlContent = LoadResourceFile(resource, file)
                
                if sqlContent then
                    table.insert(sqlResourceFiles[resource], {
                        file = file,
                        content = sqlContent
                    })
                    
                    -- Extract table names from CREATE TABLE statements
                    for tableName in string.gmatch(sqlContent, "CREATE%s+TABLE%s+[IF%s+NOT%s+EXISTS%s+]*[`'\"]?([%w_]+)[`'\"]?") do
                        sqlTablesFound[tableName] = sqlTablesFound[tableName] or {}
                        table.insert(sqlTablesFound[tableName], {
                            resource = resource,
                            file = file
                        })
                    end
                end
            end
        end
    end
    
    -- Second pass: analyze SQL files for issues
    for resource, files in pairs(sqlResourceFiles) do
        for _, fileInfo in ipairs(files) do
            local file = fileInfo.file
            local sqlContent = fileInfo.content
            local issues = {}
            
            -- Check 1: Basic SQL command existence check
            if not string.match(sqlContent, "CREATE TABLE") and
               not string.match(sqlContent, "INSERT INTO") and
               not string.match(sqlContent, "ALTER TABLE") then
                table.insert(issues, "SQL file found but no SQL commands detected")
            end
            
            -- Check 2: Check for potentially dangerous operations
            if string.match(sqlContent, "DROP DATABASE") then
                table.insert(issues, "Potentially dangerous SQL command: DROP DATABASE found")
            end
            
            -- Check 3: Check for table truncation
            if string.match(sqlContent, "TRUNCATE TABLE") or string.match(sqlContent, "DELETE FROM [^W]+ WHERE 1=1") then
                table.insert(issues, "Table truncation command found")
            end
            
            -- Check 4: Check for common SQL syntax errors
            if string.match(sqlContent, ",[%s\n]*%)") then
                table.insert(issues, "Potential SQL syntax error: trailing comma in column definition")
            end
            
            if string.match(sqlContent, "CREATE%s+TABLE[^;]+%([^%)]+%)%s*[^;]*[^;]*$") then 
                table.insert(issues, "Potential SQL syntax error: Missing semicolon after CREATE TABLE")
            end
            
            -- Check 5: Check for default credentials
            if string.match(sqlContent, "INSERT[^;]+VALUES[^;]*'admin'[^;]*'admin'") or
               string.match(sqlContent, "INSERT[^;]+VALUES[^;]*'password'") or
               string.match(sqlContent, "INSERT[^;]+VALUES[^;]*'123456'") then
                table.insert(issues, "Default or weak credentials found in SQL inserts")
            end
            
            -- Check 6: Check for SQL comment indicators that might cause issues
            if string.match(sqlContent, "--[^\n]*\n") or string.match(sqlContent, "/%*.*%*/") then
                -- This is just a warning to review comments
                table.insert(issues, "SQL comments found - verify they're not breaking statements")
            end
            
            -- Check 7: Check for potentially problematic character sets
            if string.match(sqlContent, "CHARACTER SET latin1") then
                table.insert(issues, "Using latin1 character set instead of recommended utf8mb4")
            end
            
            -- Check 8: Check for missing primary keys
            if string.match(sqlContent, "CREATE TABLE[^;]+%(([^)]+)%)[^;]*;") and
               not string.match(sqlContent, "CREATE TABLE[^;]+%([^)]*PRIMARY KEY[^)]*%)") and
               not string.match(sqlContent, "CREATE TABLE[^;]+%([^)]*KEY[^)]*%)") then
                table.insert(issues, "Table created without PRIMARY KEY definition")
            end
            
            -- Report all issues for this file
            for _, issueDesc in ipairs(issues) do
                local sqlIssue = {
                    resource = resource,
                    file = file,
                    description = issueDesc
                }
                table.insert(scanResults.sqlIssues, sqlIssue)
                logMessage("SQL issue in " .. resource .. "/" .. file .. ": " .. issueDesc, "warning")
            end
        end
    end
    
    -- Check for duplicate table definitions across resources
    for tableName, resources in pairs(sqlTablesFound) do
        if #resources > 1 then
            local resourceList = {}
            for _, res in ipairs(resources) do
                table.insert(resourceList, res.resource)
            end
            
            local uniqueResources = {}
            local duplicateFound = false
            
            -- Check if the table is defined in multiple distinct resources
            for _, res in ipairs(resources) do
                if not uniqueResources[res.resource] then
                    uniqueResources[res.resource] = true
                    if next(uniqueResources, next(uniqueResources)) then
                        duplicateFound = true
                        break
                    end
                end
            end
            
            if duplicateFound then
                local sqlIssue = {
                    table = tableName,
                    resources = resourceList,
                    description = "Table '" .. tableName .. "' is defined in multiple resources: " .. table.concat(resourceList, ", ")
                }
                table.insert(scanResults.sqlIssues, sqlIssue)
                logMessage("SQL table conflict: Table '" .. tableName .. "' defined in multiple resources: " .. table.concat(resourceList, ", "), "error")
            end
        end
    end
    
    -- If possible, attempt to connect to database and validate tables
    if GetResourceState('oxmysql') == 'started' then
        local connectionString = GetConvar('mysql_connection_string', '')
        if connectionString and connectionString ~= '' then
            -- Note: We can't execute direct SQL queries using the scanner
            -- This would require database permission setup which is beyond
            -- the scope of this tool. We'll check for oxmysql connection at least
            logMessage("MySQL configuration detected. Database validation would require direct DB access.", "info")
        end
    end
    
    return #scanResults.sqlIssues
end

-- Check critical system functionality
local function checkCriticalSystems()
    logMessage("Checking critical system functionality...", "info")
    
    -- Define critical systems we want to check
    local criticalSystems = {
        {
            name = "Banking System",
            resources = {"ls-bank-advanced", "qb-banking", "rl-banking"},
            maxActive = 1,
            minActive = 1,
            requiredActive = "ls-bank-advanced", -- Preferred banking system
            category = "banking"
        },
        {
            name = "Phone System",
            resources = {"smartphone-pro", "phone-for-everyone", "qb-phone", "npwd"},
            maxActive = 1, 
            minActive = 1,
            requiredActive = "smartphone-pro", -- Preferred phone system
            category = "phone"
        },
        {
            name = "Inventory System",
            resources = {"qb-inventory", "ox_inventory", "lj-inventory"},
            maxActive = 1,
            minActive = 1,
            category = "inventory"
        },
        {
            name = "Character System",
            resources = {"illenium-appearance", "qb-multicharacter", "qb-spawn"},
            minActive = 2, -- Need at least appearance and multicharacter
            category = "character"
        },
        {
            name = "Vehicle System",
            resources = {"qb-vehiclekeys", "qb-vehiclesales", "rl-vehicleshop"},
            minActive = 1,
            category = "vehicles"
        },
        {
            name = "Job System",
            resources = {"qb-jobs", "qb-management", "qb-bossmenu"},
            minActive = 1,
            category = "jobs"
        },
        {
            name = "Database Connector",
            resources = {"oxmysql", "mysql-async", "ghmattimysql"},
            maxActive = 1,
            minActive = 1,
            requiredActive = "oxmysql", -- Preferred database connector
            category = "database"
        },
        {
            name = "Discord Integration",
            resources = {"discord_perms", "Discordhooks", "ls-discord-webhooks", "webhook_fix"},
            minActive = 1,
            category = "discord"
        }
    }
    
    local systemIssues = 0
    scanResults.systemIssues = {}
    
    -- Helper function to get active resources in a system
    local function getActiveResources(system)
        local activeResources = {}
        for _, resource in ipairs(system.resources) do
            if GetResourceState(resource) == "started" then
                table.insert(activeResources, resource)
            end
        end
        return activeResources
    end
    
    -- Check each critical system
    for _, system in ipairs(criticalSystems) do
        local activeResources = getActiveResources(system)
        local activeCount = #activeResources
        local systemIssue = false
        local issueDesc = ""
        
        -- Check 1: Minimum required resources
        if system.minActive and activeCount < system.minActive then
            systemIssue = true
            if activeCount == 0 then
                issueDesc = "No " .. system.name .. " resources are active. System may not function."
                logMessage(issueDesc, "error")
            else
                issueDesc = "Only " .. activeCount .. " " .. system.name .. " resources are active. Minimum required: " .. system.minActive
                logMessage(issueDesc, "warning")
            end
        end
        
        -- Check 2: Maximum resources (check for conflicts)
        if system.maxActive and activeCount > system.maxActive then
            systemIssue = true
            issueDesc = "Multiple " .. system.name .. " resources are active: " .. table.concat(activeResources, ", ") .. 
                       ". This will cause conflicts."
            logMessage(issueDesc, "error")
        end
        
        -- Check 3: Specific required resources
        if system.requiredActive and not table.contains(activeResources, system.requiredActive) then
            local alternativeActive = activeCount > 0
            
            if alternativeActive then
                issueDesc = "Preferred " .. system.name .. " resource '" .. system.requiredActive .. 
                           "' is not active. Using alternative: " .. table.concat(activeResources, ", ")
                logMessage(issueDesc, "warning")
            else
                systemIssue = true
                issueDesc = "Required " .. system.name .. " resource '" .. system.requiredActive .. 
                           "' is not active and no alternatives are running."
                logMessage(issueDesc, "error")
            end
        end
        
        -- Store issue information if any found
        if systemIssue or issueDesc ~= "" then
            table.insert(scanResults.systemIssues, {
                system = system.name,
                category = system.category,
                activeResources = activeResources,
                description = issueDesc,
                isError = systemIssue
            })
            
            if systemIssue then
                systemIssues = systemIssues + 1
            end
        else
            -- Log success for the system
            logMessage(system.name .. " check passed. Active: " .. table.concat(activeResources, ", "), "success")
        end
    end
    
    -- Check for specific system integrations
    -- Check if banking is integrated with phone system
    local bankingActive = false
    local phoneActive = false
    local bankingResources = {"ls-bank-advanced", "qb-banking", "rl-banking"}
    local phoneResources = {"smartphone-pro", "phone-for-everyone", "qb-phone"}
    
    for _, resource in ipairs(bankingResources) do
        if GetResourceState(resource) == "started" then
            bankingActive = resource
            break
        end
    end
    
    for _, resource in ipairs(phoneResources) do
        if GetResourceState(resource) == "started" then
            phoneActive = resource
            break
        end
    end
    
    -- Check for banking-phone integration issues
    if bankingActive and phoneActive then
        -- Integration check for smartphone-pro and ls-bank-advanced
        if bankingActive == "ls-bank-advanced" and phoneActive == "smartphone-pro" then
            -- Check for smartphone_bank_active setting
            local bankIntegration = GetResourceMetadata("smartphone-pro", "smartphone_bank_active", 0)
            if bankIntegration and string.lower(bankIntegration) == "true" then
                -- Verify ls-bank-advanced has smartphone integration
                local bankFile = LoadResourceFile("ls-bank-advanced", "config.lua")
                if bankFile and not string.match(bankFile, "Config%.EnableSmartphoneIntegration%s*=%s*true") then
                    table.insert(scanResults.systemIssues, {
                        system = "Banking-Phone Integration",
                        category = "integration",
                        description = "smartphone-pro has banking enabled but ls-bank-advanced doesn't have smartphone integration enabled",
                        isError = true
                    })
                    logMessage("Banking-Phone integration issue: ls-bank-advanced needs Config.EnableSmartphoneIntegration = true", "error")
                    systemIssues = systemIssues + 1
                end
            end
        end
    end
    
    return systemIssues
end

-- Helper function to check if a table contains a value
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Run the full server scan
local function runServerScan()
    logMessage("Starting Los Scotia server scan...", "success")
    
    -- Reset previous scan results
    scanResults = {
        conflicts = {},
        missingDependencies = {},
        sqlIssues = {},
        webhookIssues = {},
        scriptHookIssues = {},
        textureIssues = {},
        eventIssues = {},
        missingRequiredResources = {},
        resourceErrors = {},
        systemIssues = {}
    }
    
    -- Run all scan checks
    local conflictCount = checkKnownConflicts()
    local missingResourcesCount = checkRequiredResources()
    local resourceErrorsCount = checkResourceErrors()
    local dependencyCount = checkMissingDependencies()
    local webhookCount = checkWebhookIssues()
    local sqlCount = checkSQLIntegrity()
    local systemIssueCount = checkCriticalSystems()
    
    -- Compile summary
    local totalIssues = conflictCount + missingResourcesCount + resourceErrorsCount +
                       dependencyCount + webhookCount + sqlCount + systemIssueCount
    
    logMessage("Los Scotia server scan complete!", "success")
    logMessage("Total issues found: " .. totalIssues, totalIssues > 0 and "warning" or "success")
    logMessage("Resource conflicts: " .. conflictCount, conflictCount > 0 and "warning" or "info")
    logMessage("Missing required resources: " .. missingResourcesCount, missingResourcesCount > 0 and "error" or "info")
    logMessage("Resource errors: " .. resourceErrorsCount, resourceErrorsCount > 0 and "error" or "info")
    logMessage("Missing dependencies: " .. dependencyCount, dependencyCount > 0 and "warning" or "info")
    logMessage("Webhook issues: " .. webhookCount, webhookCount > 0 and "warning" or "info")
    logMessage("SQL issues: " .. sqlCount, sqlCount > 0 and "warning" or "info")
    logMessage("System functionality issues: " .. systemIssueCount, systemIssueCount > 0 and "error" or "info")
    
    return totalIssues
end

-- Register server events
RegisterNetEvent('ls-scanner:server:runScan')
AddEventHandler('ls-scanner:server:runScan', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.metadata.admin then
        -- Run the full scan
        local totalIssues = runServerScan()
        
        -- Notify the player
        TriggerClientEvent('ls-scanner:client:notify', src, "Scan complete! Found " .. totalIssues .. " issues.", totalIssues > 0 and "error" or "success")
        
        -- Send detailed results to authorized players
        local detailedResults = json.encode(scanResults)
        TriggerClientEvent('QBCore:Notify', src, "Check server console for detailed results", "primary", 7500)
        
        -- Print detailed results to server console
        logMessage("=== DETAILED SCAN RESULTS ===", "info")
        
        if #scanResults.conflicts > 0 then
            logMessage("Resource Conflicts:", "warning")
            for i, conflict in ipairs(scanResults.conflicts) do
                logMessage(i .. ". " .. conflict.description, "warning")
            end
        end
        
        if #scanResults.missingRequiredResources > 0 then
            logMessage("Missing Required Resources:", "error")
            for i, resource in ipairs(scanResults.missingRequiredResources) do
                logMessage(i .. ". " .. resource, "error")
            end
        end
        
        if #scanResults.resourceErrors > 0 then
            logMessage("Resource Errors:", "error")
            for i, err in ipairs(scanResults.resourceErrors) do
                logMessage(i .. ". " .. err.resource .. ": " .. err.description, "error")
            end
        end
        
        if #scanResults.missingDependencies > 0 then
            logMessage("Missing Dependencies:", "warning")
            for i, dep in ipairs(scanResults.missingDependencies) do
                local messageType = "warning"
                if dep.type == "explicit_missing" or dep.type == "implicit_missing" or dep.type == "circular" then
                    messageType = "error"
                end
                logMessage(i .. ". " .. dep.description, messageType)
            end
        end
        
        if #scanResults.webhookIssues > 0 then
            logMessage("Webhook Issues:", "warning")
            for i, issue in ipairs(scanResults.webhookIssues) do
                logMessage(i .. ". " .. issue.description, "warning")
            end
        end
        
        if #scanResults.sqlIssues > 0 then
            logMessage("SQL Issues:", "warning")
            for i, issue in ipairs(scanResults.sqlIssues) do
                if issue.table then
                    logMessage(i .. ". Table '" .. issue.table .. "': " .. issue.description, "warning")
                else
                    logMessage(i .. ". " .. issue.resource .. "/" .. issue.file .. ": " .. issue.description, "warning")
                end
            end
        end
        
        if #scanResults.systemIssues > 0 then
            logMessage("System Functionality Issues:", "error")
            for i, issue in ipairs(scanResults.systemIssues) do
                local messageType = issue.isError and "error" or "warning"
                local activeText = ""
                if issue.activeResources and #issue.activeResources > 0 then
                    activeText = " (Active: " .. table.concat(issue.activeResources, ", ") .. ")"
                end
                logMessage(i .. ". " .. issue.system .. activeText .. ": " .. issue.description, messageType)
            end
            
            -- Add additional guidance for fixing system issues
            logMessage("\nSystem Issue Resolution Recommendations:", "info")
            for _, issue in ipairs(scanResults.systemIssues) do
                if issue.category == "banking" then
                    logMessage("- Banking: Ensure only ls-bank-advanced is active in server.cfg, disable qb-banking and rl-banking", "info")
                elseif issue.category == "phone" then
                    logMessage("- Phone: Ensure only smartphone-pro is active in server.cfg, disable phone-for-everyone", "info")
                elseif issue.category == "integration" then
                    logMessage("- Integration: Check config.lua in each resource to ensure proper integration settings", "info")
                end
            end
        end
    end
end)

RegisterNetEvent('ls-scanner:server:runConflictScan')
AddEventHandler('ls-scanner:server:runConflictScan', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.metadata.admin then
        -- Reset conflict results
        scanResults.conflicts = {}
        
        -- Run conflict checks
        local conflictCount = checkKnownConflicts()
        
        -- Notify the player
        TriggerClientEvent('ls-scanner:client:notify', src, "Conflict scan complete! Found " .. conflictCount .. " conflicts.", conflictCount > 0 and "error" or "success")
        
        -- Print results to server console
        if #scanResults.conflicts > 0 then
            logMessage("=== CONFLICT SCAN RESULTS ===", "warning")
            for i, conflict in ipairs(scanResults.conflicts) do
                logMessage(i .. ". " .. conflict.description, "warning")
            end
        else
            logMessage("No conflicts found!", "success")
        end
    end
end)

RegisterNetEvent('ls-scanner:server:runSQLCheck')
AddEventHandler('ls-scanner:server:runSQLCheck', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.metadata.admin then
        -- Reset SQL results
        scanResults.sqlIssues = {}
        
        -- Run SQL checks
        local sqlCount = checkSQLIntegrity()
        
        -- Notify the player
        TriggerClientEvent('ls-scanner:client:notify', src, "SQL integrity check complete! Found " .. sqlCount .. " issues.", sqlCount > 0 and "error" or "success")
        
        -- Print results to server console
        if #scanResults.sqlIssues > 0 then
            logMessage("=== SQL INTEGRITY RESULTS ===", "warning")
            for i, issue in ipairs(scanResults.sqlIssues) do
                if issue.table then
                    logMessage(i .. ". Table '" .. issue.table .. "': " .. issue.description, "warning")
                else
                    logMessage(i .. ". " .. issue.resource .. "/" .. issue.file .. ": " .. issue.description, "warning")
                end
            end
        else
            logMessage("No SQL issues found!", "success")
        end
    end
end)

RegisterNetEvent('ls-scanner:server:runDependencyCheck')
AddEventHandler('ls-scanner:server:runDependencyCheck', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.metadata.admin then
        -- Reset dependency results
        scanResults.missingDependencies = {}
        
        -- Run dependency checks
        local dependencyCount = checkMissingDependencies()
        
        -- Notify the player
        TriggerClientEvent('ls-scanner:client:notify', src, "Dependency check complete! Found " .. dependencyCount .. " issues.", dependencyCount > 0 and "error" or "success")
        
        -- Print results to server console
        if #scanResults.missingDependencies > 0 then
            logMessage("=== DEPENDENCY CHECK RESULTS ===", "warning")
            
            -- Group by dependency type for better readability
            local dependencyTypes = {
                ["explicit_missing"] = "Missing Explicit Dependencies",
                ["implicit_missing"] = "Missing Implicit Dependencies",
                ["explicit_not_started"] = "Dependencies Not Started",
                ["implicit_not_started"] = "Framework Dependencies Not Started",
                ["incorrect_order"] = "Incorrect Load Order",
                ["circular"] = "Circular Dependencies"
            }
            
            for typeName, typeLabel in pairs(dependencyTypes) do
                local typeIssues = {}
                for _, dep in ipairs(scanResults.missingDependencies) do
                    if dep.type == typeName then
                        table.insert(typeIssues, dep)
                    end
                end
                
                if #typeIssues > 0 then
                    local messageType = (typeName == "explicit_missing" or typeName == "implicit_missing" or typeName == "circular") and "error" or "warning"
                    logMessage("\n" .. typeLabel .. ":", messageType)
                    for i, dep in ipairs(typeIssues) do
                        logMessage(i .. ". " .. dep.description, messageType)
                    end
                end
            end
        else
            logMessage("No dependency issues found!", "success")
        end
    end
end)

RegisterNetEvent('ls-scanner:server:runSystemsCheck')
AddEventHandler('ls-scanner:server:runSystemsCheck', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.metadata.admin then
        -- Reset system results
        scanResults.systemIssues = {}
        
        -- Run system checks
        local systemIssueCount = checkCriticalSystems()
        
        -- Notify the player
        TriggerClientEvent('ls-scanner:client:notify', src, "System validation complete! Found " .. systemIssueCount .. " issues.", systemIssueCount > 0 and "error" or "success")
        
        -- Print results to server console
        if #scanResults.systemIssues > 0 then
            logMessage("=== SYSTEM FUNCTIONALITY RESULTS ===", "warning")
            
            -- Group by category for better readability
            local categories = {}
            for _, issue in ipairs(scanResults.systemIssues) do
                categories[issue.category] = categories[issue.category] or {}
                table.insert(categories[issue.category], issue)
            end
            
            for category, issues in pairs(categories) do
                logMessage("\n" .. string.upper(category) .. " System Issues:", "warning")
                for i, issue in ipairs(issues) do
                    local messageType = issue.isError and "error" or "warning"
                    local activeText = ""
                    if issue.activeResources and #issue.activeResources > 0 then
                        activeText = " (Active: " .. table.concat(issue.activeResources, ", ") .. ")"
                    end
                    logMessage(i .. ". " .. issue.system .. activeText .. ": " .. issue.description, messageType)
                end
            end
            
            -- Add recommendations for fixing issues
            logMessage("\nRecommendations:", "info")
            if categories["banking"] then
                logMessage("- Banking: Ensure only ls-bank-advanced is active in server.cfg, disable qb-banking and rl-banking", "info")
            end
            if categories["phone"] then
                logMessage("- Phone: Ensure only smartphone-pro is active in server.cfg, disable phone-for-everyone", "info")
            end
            if categories["integration"] then
                logMessage("- Integration: Check config.lua in each resource to ensure proper integration settings", "info")
            end
        else
            logMessage("All core systems are functioning correctly!", "success")
        end
    end
end)

-- Function to generate an HTML report
local function generateHTMLReport(scanResults)
    local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
    local filename = "ls_scanner_report_" .. timestamp .. ".html"
    
    local totalIssues = #scanResults.conflicts + #scanResults.missingDependencies +
                       #scanResults.sqlIssues + #scanResults.webhookIssues +
                       #scanResults.missingRequiredResources + #scanResults.resourceErrors +
                       #scanResults.systemIssues
    
    local severity = "green"
    if totalIssues > 20 then
        severity = "red"
    elseif totalIssues > 5 then
        severity = "orange"
    end
    
    local html = [[
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Los Scotia Server Scanner Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            color: #333;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 5px;
        }
        h1 {
            color: #2c3e50;
            text-align: center;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #2c3e50;
            border-bottom: 1px solid #ddd;
            padding-bottom: 5px;
            margin-top: 30px;
        }
        .summary {
            background-color: #f8f9fa;
            border-left: 5px solid #3498db;
            padding: 15px;
            margin-bottom: 20px;
        }
        .summary-title {
            font-weight: bold;
            font-size: 18px;
            margin-bottom: 10px;
        }
        .issue-count {
            font-size: 24px;
            font-weight: bold;
            color: ]]..severity..[[;
        }
        .issue {
            padding: 10px;
            margin-bottom: 5px;
            border-left: 4px solid #e74c3c;
            background-color: #fdedec;
        }
        .warning {
            border-left-color: #f39c12;
            background-color: #fef9e7;
        }
        .error {
            border-left-color: #e74c3c;
            background-color: #fdedec;
        }
        .section {
            margin-bottom: 30px;
        }
        .recommendations {
            background-color: #eafaf1;
            border-left: 5px solid #2ecc71;
            padding: 15px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            font-size: 12px;
            color: #7f8c8d;
        }
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }
        .stat-box {
            background-color: #fff;
            border-radius: 5px;
            padding: 15px;
            box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        .stat-label {
            font-size: 14px;
            color: #7f8c8d;
        }
        .stat-value {
            font-size: 22px;
            font-weight: bold;
            margin: 10px 0;
            color: #3498db;
        }
        .stat-value.warning {
            color: #f39c12;
        }
        .stat-value.error {
            color: #e74c3c;
        }
        .collapse-btn {
            background-color: #f1f1f1;
            color: #333;
            cursor: pointer;
            padding: 10px;
            width: 100%;
            text-align: left;
            border: none;
            outline: none;
            font-size: 16px;
            transition: 0.4s;
            border-radius: 5px;
            margin-bottom: 5px;
        }
        .collapse-btn:hover {
            background-color: #ddd;
        }
        .collapse-btn:after {
            content: '\002B';
            font-weight: bold;
            float: right;
        }
        .collapse-btn.active:after {
            content: "\2212";
        }
        .collapse-content {
            padding: 0 18px;
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.2s ease-out;
            background-color: #f9f9f9;
            border-radius: 0 0 5px 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        th, td {
            padding: 8px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Los Scotia Server Scanner Report</h1>
        
        <div class="summary">
            <p><strong>Generated:</strong> ]]..os.date("%Y-%m-%d %H:%M:%S")..[[</p>
            <p><strong>Server Name:</strong> ]]..GetConvar("sv_hostname", "Unknown")..[[</p>
            <div class="summary-title">Total Issues Found: <span class="issue-count">]]..totalIssues..[[</span></div>
        </div>
        
        <div class="stat-grid">
            <div class="stat-box">
                <div class="stat-label">Resource Conflicts</div>
                <div class="stat-value ]]..getColorClass(#scanResults.conflicts)..[[">]]..#scanResults.conflicts..[[</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">Missing Dependencies</div>
                <div class="stat-value ]]..getColorClass(#scanResults.missingDependencies)..[[">]]..#scanResults.missingDependencies..[[</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">SQL Issues</div>
                <div class="stat-value ]]..getColorClass(#scanResults.sqlIssues)..[[">]]..#scanResults.sqlIssues..[[</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">Webhook Issues</div>
                <div class="stat-value ]]..getColorClass(#scanResults.webhookIssues)..[[">]]..#scanResults.webhookIssues..[[</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">Missing Required Resources</div>
                <div class="stat-value ]]..getColorClass(#scanResults.missingRequiredResources)..[[">]]..#scanResults.missingRequiredResources..[[</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">Resource Errors</div>
                <div class="stat-value ]]..getColorClass(#scanResults.resourceErrors)..[[">]]..#scanResults.resourceErrors..[[</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">System Issues</div>
                <div class="stat-value ]]..getColorClass(#scanResults.systemIssues)..[[">]]..#scanResults.systemIssues..[[</div>
            </div>
        </div>
]]

    -- Resource conflicts section
    if #scanResults.conflicts > 0 then
        html = html .. [[
        <div class="section">
            <button class="collapse-btn">Resource Conflicts (]]..#scanResults.conflicts..[[)</button>
            <div class="collapse-content">
                <table>
                    <tr>
                        <th>#</th>
                        <th>Description</th>
                        <th>Resources</th>
                    </tr>
]]
        for i, conflict in ipairs(scanResults.conflicts) do
            local resources = table.concat(conflict.resources, ", ")
            html = html .. [[
                <tr>
                    <td>]]..i..[[</td>
                    <td>]]..conflict.description..[[</td>
                    <td>]]..resources..[[</td>
                </tr>
]]
        end
        html = html .. [[
                </table>
            </div>
        </div>
]]
    end
    
    -- Missing dependencies section
    if #scanResults.missingDependencies > 0 then
        html = html .. [[
        <div class="section">
            <button class="collapse-btn">Dependency Issues (]]..#scanResults.missingDependencies..[[)</button>
            <div class="collapse-content">
                <table>
                    <tr>
                        <th>#</th>
                        <th>Resource</th>
                        <th>Missing Dependency</th>
                        <th>Type</th>
                        <th>Description</th>
                    </tr>
]]
        for i, dep in ipairs(scanResults.missingDependencies) do
            html = html .. [[
                <tr>
                    <td>]]..i..[[</td>
                    <td>]]..dep.resource..[[</td>
                    <td>]]..dep.dependency..[[</td>
                    <td>]]..dep.type..[[</td>
                    <td>]]..dep.description..[[</td>
                </tr>
]]
        end
        html = html .. [[
                </table>
            </div>
        </div>
]]
    end
    
    -- SQL issues section
    if #scanResults.sqlIssues > 0 then
        html = html .. [[
        <div class="section">
            <button class="collapse-btn">SQL Issues (]]..#scanResults.sqlIssues..[[)</button>
            <div class="collapse-content">
                <table>
                    <tr>
                        <th>#</th>
                        <th>Resource</th>
                        <th>File/Table</th>
                        <th>Description</th>
                    </tr>
]]
        for i, issue in ipairs(scanResults.sqlIssues) do
            local resource = issue.resource or "Multiple"
            local fileOrTable = issue.file or issue.table or "N/A"
            html = html .. [[
                <tr>
                    <td>]]..i..[[</td>
                    <td>]]..resource..[[</td>
                    <td>]]..fileOrTable..[[</td>
                    <td>]]..issue.description..[[</td>
                </tr>
]]
        end
        html = html .. [[
                </table>
            </div>
        </div>
]]
    end
    
    -- Webhook issues section
    if #scanResults.webhookIssues > 0 then
        html = html .. [[
        <div class="section">
            <button class="collapse-btn">Webhook Issues (]]..#scanResults.webhookIssues..[[)</button>
            <div class="collapse-content">
                <table>
                    <tr>
                        <th>#</th>
                        <th>Resources</th>
                        <th>Description</th>
                    </tr>
]]
        for i, issue in ipairs(scanResults.webhookIssues) do
            local resources = table.concat(issue.resources, ", ")
            html = html .. [[
                <tr>
                    <td>]]..i..[[</td>
                    <td>]]..resources..[[</td>
                    <td>]]..issue.description..[[</td>
                </tr>
]]
        end
        html = html .. [[
                </table>
            </div>
        </div>
]]
    end
    
    -- System issues section
    if #scanResults.systemIssues > 0 then
        html = html .. [[
        <div class="section">
            <button class="collapse-btn">System Functionality Issues (]]..#scanResults.systemIssues..[[)</button>
            <div class="collapse-content">
                <table>
                    <tr>
                        <th>#</th>
                        <th>System</th>
                        <th>Category</th>
                        <th>Active Resources</th>
                        <th>Description</th>
                    </tr>
]]
        for i, issue in ipairs(scanResults.systemIssues) do
            local activeResources = "None"
            if issue.activeResources and #issue.activeResources > 0 then
                activeResources = table.concat(issue.activeResources, ", ")
            end
            html = html .. [[
                <tr>
                    <td>]]..i..[[</td>
                    <td>]]..issue.system..[[</td>
                    <td>]]..issue.category..[[</td>
                    <td>]]..activeResources..[[</td>
                    <td>]]..issue.description..[[</td>
                </tr>
]]
        end
        html = html .. [[
                </table>
            </div>
        </div>
]]
    end
    
    -- Recommendations section
    html = html .. [[
        <div class="section recommendations">
            <h2>Recommendations</h2>
]]
    
    if #scanResults.conflicts > 0 then
        html = html .. [[
            <p><strong>Resource Conflicts:</strong></p>
            <ul>
                <li>Ensure only one resource providing each functionality is active.</li>
                <li>Check server.cfg and disable conflicting resources.</li>
            </ul>
]]
    end
    
    if #scanResults.missingDependencies > 0 then
        html = html .. [[
            <p><strong>Dependency Issues:</strong></p>
            <ul>
                <li>Ensure all required resources are installed and enabled.</li>
                <li>Check load order to make sure dependencies are loaded before resources that need them.</li>
                <li>Address circular dependencies by refactoring the resources.</li>
            </ul>
]]
    end
    
    if #scanResults.sqlIssues > 0 then
        html = html .. [[
            <p><strong>SQL Issues:</strong></p>
            <ul>
                <li>Review SQL files for syntax errors and potential conflicts.</li>
                <li>Ensure table definitions are not duplicated across resources.</li>
                <li>Check for proper primary keys and indexing on tables.</li>
            </ul>
]]
    end
    
    if #scanResults.systemIssues > 0 then
        html = html .. [[
            <p><strong>System Functionality Issues:</strong></p>
            <ul>
]]
        
        if hasCategory(scanResults.systemIssues, "banking") then
            html = html .. [[
                <li>Banking: Ensure only ls-bank-advanced is active in server.cfg.</li>
]]
        end
        
        if hasCategory(scanResults.systemIssues, "phone") then
            html = html .. [[
                <li>Phone: Ensure only smartphone-pro is active in server.cfg.</li>
]]
        end
        
        if hasCategory(scanResults.systemIssues, "integration") then
            html = html .. [[
                <li>Check config files for proper integration between systems.</li>
]]
        end
        
        html = html .. [[
            </ul>
]]
    end
    
    -- Footer
    html = html .. [[
        </div>
        
        <div class="footer">
            <p>Report generated by Los Scotia Server Scanner v1.0</p>
            <p>Developed by Los Scotia Development Team</p>
        </div>
    </div>

    <script>
        // Add JavaScript for collapsible sections
        var coll = document.getElementsByClassName("collapse-btn");
        for (var i = 0; i < coll.length; i++) {
            coll[i].addEventListener("click", function() {
                this.classList.toggle("active");
                var content = this.nextElementSibling;
                if (content.style.maxHeight) {
                    content.style.maxHeight = null;
                } else {
                    content.style.maxHeight = content.scrollHeight + "px";
                }
            });
        }
    </script>
</body>
</html>
]]

    return {
        html = html,
        filename = filename
    }
end

-- Helper function to determine color class based on issue count
function getColorClass(count)
    if count == 0 then
        return ""
    elseif count <= 2 then
        return "warning"
    else
        return "error"
    end
end

RegisterNetEvent('ls-scanner:server:generateReport')
AddEventHandler('ls-scanner:server:generateReport', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.metadata.admin then
        -- First run a full scan to gather all data
        runServerScan()
        
        -- Generate a text report first for backwards compatibility
        local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
        local txtFilename = "ls_scanner_report_" .. timestamp .. ".txt"
        
        local reportContent = "=================================================\n"
        reportContent = reportContent .. "LOS SCOTIA SERVER SCANNER - COMPREHENSIVE REPORT\n"
        reportContent = reportContent .. "=================================================\n"
        reportContent = reportContent .. "Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
        reportContent = reportContent .. "Server Name: " .. GetConvar("sv_hostname", "Unknown") .. "\n\n"
        
        -- Summary section
        reportContent = reportContent .. "SUMMARY\n"
        reportContent = reportContent .. "-------\n"
        local totalIssues = #scanResults.conflicts + #scanResults.missingDependencies +
                          #scanResults.sqlIssues + #scanResults.webhookIssues +
                          #scanResults.missingRequiredResources + #scanResults.resourceErrors +
                          #scanResults.systemIssues
        
        reportContent = reportContent .. "Total Issues Found: " .. totalIssues .. "\n"
        reportContent = reportContent .. "- Resource Conflicts: " .. #scanResults.conflicts .. "\n"
        reportContent = reportContent .. "- Missing Dependencies: " .. #scanResults.missingDependencies .. "\n"
        reportContent = reportContent .. "- SQL Issues: " .. #scanResults.sqlIssues .. "\n"
        reportContent = reportContent .. "- Webhook Issues: " .. #scanResults.webhookIssues .. "\n"
        reportContent = reportContent .. "- Missing Required Resources: " .. #scanResults.missingRequiredResources .. "\n"
        reportContent = reportContent .. "- Resource Errors: " .. #scanResults.resourceErrors .. "\n"
        reportContent = reportContent .. "- System Functionality Issues: " .. #scanResults.systemIssues .. "\n\n"
        
        -- Resource conflict details
        if #scanResults.conflicts > 0 then
            reportContent = reportContent .. "RESOURCE CONFLICTS\n"
            reportContent = reportContent .. "-----------------\n"
            for i, conflict in ipairs(scanResults.conflicts) do
                reportContent = reportContent .. i .. ". " .. conflict.description .. "\n"
            end
            reportContent = reportContent .. "\n"
        end
        
        -- Missing dependencies details
        if #scanResults.missingDependencies > 0 then
            reportContent = reportContent .. "DEPENDENCY ISSUES\n"
            reportContent = reportContent .. "----------------\n"
            for i, dep in ipairs(scanResults.missingDependencies) do
                reportContent = reportContent .. i .. ". " .. dep.description .. " (Type: " .. dep.type .. ")\n"
            end
            reportContent = reportContent .. "\n"
        end
        
        -- SQL issues details
        if #scanResults.sqlIssues > 0 then
            reportContent = reportContent .. "SQL ISSUES\n"
            reportContent = reportContent .. "----------\n"
            for i, issue in ipairs(scanResults.sqlIssues) do
                if issue.table then
                    reportContent = reportContent .. i .. ". Table '" .. issue.table .. "': " .. issue.description .. "\n"
                else
                    reportContent = reportContent .. i .. ". " .. issue.resource .. "/" .. issue.file .. ": " .. issue.description .. "\n"
                end
            end
            reportContent = reportContent .. "\n"
        end
        
        -- Webhook issues
        if #scanResults.webhookIssues > 0 then
            reportContent = reportContent .. "WEBHOOK ISSUES\n"
            reportContent = reportContent .. "--------------\n"
            for i, issue in ipairs(scanResults.webhookIssues) do
                reportContent = reportContent .. i .. ". " .. issue.description .. "\n"
            end
            reportContent = reportContent .. "\n"
        end
        
        -- System issues
        if #scanResults.systemIssues > 0 then
            reportContent = reportContent .. "SYSTEM FUNCTIONALITY ISSUES\n"
            reportContent = reportContent .. "-------------------------\n"
            for i, issue in ipairs(scanResults.systemIssues) do
                local activeText = ""
                if issue.activeResources and #issue.activeResources > 0 then
                    activeText = " (Active: " .. table.concat(issue.activeResources, ", ") .. ")"
                end
                reportContent = reportContent .. i .. ". " .. issue.system .. activeText .. ": " .. issue.description .. "\n"
            end
            reportContent = reportContent .. "\n"
        end
        
        -- Recommendations section
        reportContent = reportContent .. "RECOMMENDATIONS\n"
        reportContent = reportContent .. "--------------\n"
        
        if #scanResults.conflicts > 0 then
            reportContent = reportContent .. "- For resource conflicts, ensure only one resource providing each functionality is active.\n"
            reportContent = reportContent .. "  Check server.cfg and disable conflicting resources.\n"
        end
        
        if #scanResults.missingDependencies > 0 then
            reportContent = reportContent .. "- For missing dependencies, ensure all required resources are installed and enabled.\n"
            reportContent = reportContent .. "  Check load order to make sure dependencies are loaded before resources that need them.\n"
        end
        
        if #scanResults.sqlIssues > 0 then
            reportContent = reportContent .. "- For SQL issues, review your SQL files for syntax errors and potential conflicts.\n"
            reportContent = reportContent .. "  Ensure table definitions are not duplicated across resources.\n"
        end
        
        if #scanResults.systemIssues > 0 then
            reportContent = reportContent .. "- For system functionality issues:\n"
            if hasCategory(scanResults.systemIssues, "banking") then
                reportContent = reportContent .. "  * Banking: Ensure only ls-bank-advanced is active in server.cfg.\n"
            end
            if hasCategory(scanResults.systemIssues, "phone") then
                reportContent = reportContent .. "  * Phone: Ensure only smartphone-pro is active in server.cfg.\n"
            end
            if hasCategory(scanResults.systemIssues, "integration") then
                reportContent = reportContent .. "  * Check config files for proper integration between systems.\n"
            end
        end
        
        reportContent = reportContent .. "\n=================================================\n"
        reportContent = reportContent .. "Report generated by Los Scotia Server Scanner v1.0\n"
        reportContent = reportContent .. "Developed by Los Scotia Development Team\n"
        
        -- Generate HTML report
        local htmlReport = generateHTMLReport(scanResults)
        
        -- Ensure reports directory exists
        local reportsDir = GetResourcePath(GetCurrentResourceName()) .. "/reports"
        os.execute("mkdir -p " .. reportsDir)
        
        -- Write the text report file
        local txtReportFile = reportsDir .. "/" .. txtFilename
        local txtFile = io.open(txtReportFile, "w")
        
        if txtFile then
            txtFile:write(reportContent)
            txtFile:close()
            logMessage("Text report generated: " .. txtReportFile, "success")
        else
            logMessage("Failed to create text report file. Check directory permissions.", "error")
        end
        
        -- Write the HTML report file
        local htmlReportFile = reportsDir .. "/" .. htmlReport.filename
        local htmlFile = io.open(htmlReportFile, "w")
        
        if htmlFile then
            htmlFile:write(htmlReport.html)
            htmlFile:close()
            logMessage("HTML report generated: " .. htmlReportFile, "success")
            TriggerClientEvent('ls-scanner:client:notify', src, "Reports generated: " .. txtFilename .. " and " .. htmlReport.filename, "success")
        else
            logMessage("Failed to create HTML report file. Check directory permissions.", "error")
            TriggerClientEvent('ls-scanner:client:notify', src, "Failed to generate HTML report. Check console.", "error")
        end
    end
end)

-- Helper function to check if any system issues belong to a certain category
function hasCategory(issuesArray, categoryName)
    for _, issue in ipairs(issuesArray) do
        if issue.category == categoryName then
            return true
        end
    end
    return false
end

-- Report handling functions
RegisterNetEvent('ls-scanner:server:getReportsList')
AddEventHandler('ls-scanner:server:getReportsList', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.metadata.admin then
        local reportsDir = GetResourcePath(GetCurrentResourceName()) .. "/reports"
        local reports = {}
        
        -- Check if directory exists
        local dir = io.popen('dir "' .. reportsDir .. '" /b')
        
        if dir then
            for file in dir:lines() do
                if file:match("ls_scanner_report_.+%.html$") or file:match("ls_scanner_report_.+%.txt$") then
                    table.insert(reports, file)
                end
            end
            dir:close()
            
            -- Sort reports by date (newest first)
            table.sort(reports, function(a, b)
                return a > b
            end)
            
            TriggerClientEvent('ls-scanner:client:showReportsList', src, reports)
        else
            TriggerClientEvent('ls-scanner:client:notify', src, "Failed to access reports directory", "error")
        end
    end
end)

RegisterNetEvent('ls-scanner:server:openReport')
AddEventHandler('ls-scanner:server:openReport', function(filename)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.metadata.admin then
        -- Validate filename to prevent directory traversal
        if filename:find("%.%.") or filename:find("[\\/]") then
            TriggerClientEvent('ls-scanner:client:notify', src, "Invalid report filename", "error")
            return
        end
        
        local reportsDir = GetResourcePath(GetCurrentResourceName()) .. "/reports"
        local reportPath = reportsDir .. "/" .. filename
        
        -- Check if file exists
        local file = io.open(reportPath, "r")
        if file then
            file:close()
            
            -- If it's an HTML report, provide a URL to view it
            if filename:match("%.html$") then
                local reportUrl = "https://" .. GetCurrentServerEndpoint() .. "/ls-scanner/reports/" .. filename
                TriggerClientEvent('ls-scanner:client:notify', src, "Opening HTML report in browser", "success")
                
                -- Create a temporary HTML file that redirects to the real report
                local tempHtmlPath = reportsDir .. "/view_report_" .. os.time() .. ".html"
                local tempHtml = io.open(tempHtmlPath, "w")
                if tempHtml then
                    tempHtml:write([[
<!DOCTYPE html>
<html>
<head>
    <title>Redirecting to Report</title>
    <meta http-equiv="refresh" content="0;URL=']] .. reportUrl .. [['" />
</head>
<body>
    <p>Redirecting to the report...</p>
    <p>If you are not redirected automatically, <a href="]] .. reportUrl .. [[">click here</a>.</p>
</body>
</html>
]])
                    tempHtml:close()
                    
                    -- Provide the URL to the client
                    TriggerClientEvent('ls-scanner:client:openUrl', src, "nui://" .. GetCurrentResourceName() .. "/reports/view_report_" .. os.time() .. ".html")
                else
                    TriggerClientEvent('ls-scanner:client:notify', src, "Failed to create viewer for HTML report", "error")
                end
            else
                -- For text reports, read and display content in chat
                local file = io.open(reportPath, "r")
                if file then
                    local content = file:read("*all")
                    file:close()
                    
                    -- Truncate if needed
                    if #content > 5000 then
                        content = content:sub(1, 5000) .. "\n\n[Report truncated due to size. See full report in file.]"
                    end
                    
                    -- Send content to client in chunks to avoid message size limits
                    local chunkSize = 1000
                    for i = 1, #content, chunkSize do
                        local chunk = content:sub(i, i + chunkSize - 1)
                        TriggerClientEvent('ls-scanner:client:displayReportChunk', src, chunk, i == 1)
                    end
                else
                    TriggerClientEvent('ls-scanner:client:notify', src, "Failed to read report file", "error")
                end
            end
        else
            TriggerClientEvent('ls-scanner:client:notify', src, "Report file not found", "error")
        end
    end
end)

-- Register command for console use
RegisterCommand("server_scan", function(source, args)
    if source == 0 then -- Console
        runServerScan()
    else
        local Player = QBCore.Functions.GetPlayer(source)
        if Player.PlayerData.metadata.admin then
            -- Player is admin, run scan
            TriggerEvent('ls-scanner:server:runScan')
        else
            -- Not an admin
            TriggerClientEvent('QBCore:Notify', source, "You don't have permission to use this command", "error")
        end
    end
end, true)

-- Check for updates
local function checkVersion()
    local currentVersion = "1.1.0"
    logMessage("Current version: " .. currentVersion, "info")
    
    -- In a real implementation, we would check against a remote version
    -- For this local implementation, just show the current version
    logMessage("Los Scotia Server Scanner is up to date", "success")
end

-- Create reports directory on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Create reports directory
        local reportsDir = GetResourcePath(GetCurrentResourceName()) .. "/reports"
        os.execute('mkdir "' .. reportsDir .. '" 2>nul')
        
        logMessage("Los Scotia Server Scanner v1.1.0 initialized", "success")
        logMessage("Reports directory: " .. reportsDir, "info")
        
        -- Check for updates
        Citizen.SetTimeout(5000, function()
            checkVersion()
        end)
    end
end)