-- MySQL/OxMySQL Fix for Los Scotia Scripts
-- This file provides compatibility for scripts using old MySQL syntax

-- Set up MySQL global if it doesn't exist
if not MySQL then
    MySQL = {}
end

-- Create compatibility functions for old MySQL syntax
MySQL.ready = function(callback)
    CreateThread(function()
        local success = pcall(function()
            exports.oxmysql:ready(callback)
        end)
        if not success then
            -- Fallback if oxmysql isn't available
            print('[LS-MYSQL-FIX] WARNING: oxmysql not available, using fallback')
            callback()
        end
    end)
end

-- Query function compatibility
MySQL.query = function(query, parameters, callback)
    if not callback and type(parameters) == 'function' then
        callback = parameters
        parameters = {}
    end
    
    parameters = parameters or {}
    
    local success = pcall(function()
        exports.oxmysql:execute(query, parameters, callback)
    end)
    
    if not success then
        print('[LS-MYSQL-FIX] ERROR: Failed to execute query: ' .. tostring(query))
        if callback then callback(false) end
    end
end

-- Fetch functions
MySQL.fetchAll = function(query, parameters, callback)
    if not callback and type(parameters) == 'function' then
        callback = parameters
        parameters = {}
    end
    
    parameters = parameters or {}
    
    local success = pcall(function()
        exports.oxmysql:fetchAll(query, parameters, callback)
    end)
    
    if not success then
        print('[LS-MYSQL-FIX] ERROR: Failed to fetchAll: ' .. tostring(query))
        if callback then callback({}) end
    end
end

MySQL.fetchSingle = function(query, parameters, callback)
    if not callback and type(parameters) == 'function' then
        callback = parameters
        parameters = {}
    end
    
    parameters = parameters or {}
    
    local success = pcall(function()
        exports.oxmysql:fetchSingle(query, parameters, callback)
    end)
    
    if not success then
        print('[LS-MYSQL-FIX] ERROR: Failed to fetchSingle: ' .. tostring(query))
        if callback then callback(nil) end
    end
end

-- Sync versions
MySQL.Sync = MySQL.Sync or {}

MySQL.Sync.execute = function(query, parameters)
    parameters = parameters or {}
    
    local success, result = pcall(function()
        return exports.oxmysql:execute_sync(query, parameters)
    end)
    
    if success then
        return result
    else
        print('[LS-MYSQL-FIX] ERROR: Failed to execute sync: ' .. tostring(query))
        return false
    end
end

MySQL.Sync.fetchAll = function(query, parameters)
    parameters = parameters or {}
    
    local success, result = pcall(function()
        return exports.oxmysql:fetch_sync(query, parameters)
    end)
    
    if success then
        return result or {}
    else
        print('[LS-MYSQL-FIX] ERROR: Failed to fetchAll sync: ' .. tostring(query))
        return {}
    end
end

MySQL.Sync.fetchSingle = function(query, parameters)
    parameters = parameters or {}
    
    local success, result = pcall(function()
        local results = exports.oxmysql:fetch_sync(query, parameters)
        return results and results[1] or nil
    end)
    
    if success then
        return result
    else
        print('[LS-MYSQL-FIX] ERROR: Failed to fetchSingle sync: ' .. tostring(query))
        return nil
    end
end

-- Make MySQL global available
_G.MySQL = MySQL

print('[LS-MYSQL-FIX] MySQL compatibility layer loaded successfully!')