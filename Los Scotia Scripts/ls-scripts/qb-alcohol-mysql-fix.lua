-- QBCore Alcohol MySQL Compatibility Fix
-- This script fixes the MySQL compatibility issues in qb-alcohol resource
-- Error: attempt to index a function value (field 'query')
-- Lines: server.lua:465 and server.lua:479

-- Modern oxmysql exports table, not function
-- This is a compatibility layer to fix old MySQL usage patterns

local QBCore = exports['qb-core']:GetCoreObject()

-- Backup the original MySQL exports if they exist
local originalMySQL = MySQL or {}

-- Create compatibility layer for old MySQL syntax
if not MySQL or type(MySQL) == 'function' then
    MySQL = {}
end

-- Map old MySQL.Async methods to new oxmysql exports
if not MySQL.Async then
    MySQL.Async = {
        fetchAll = function(query, params, cb)
            if cb then
                exports.oxmysql:execute(query, params, cb)
            else
                return exports.oxmysql:executeSync(query, params)
            end
        end,
        
        execute = function(query, params, cb)
            if cb then
                exports.oxmysql:execute(query, params, cb)
            else
                return exports.oxmysql:executeSync(query, params)
            end
        end,
        
        fetchScalar = function(query, params, cb)
            if cb then
                exports.oxmysql:scalar(query, params, cb)
            else
                return exports.oxmysql:scalarSync(query, params)
            end
        end,
        
        insert = function(query, params, cb)
            if cb then
                exports.oxmysql:insert(query, params, cb)
            else
                return exports.oxmysql:insertSync(query, params)
            end
        end
    }
end

-- Fix direct MySQL.query usage (common in older resources)
if not MySQL.query then
    MySQL.query = MySQL.Async.execute
end

-- Ensure MySQL table is properly exported for other resources
_G.MySQL = MySQL

print("^2[LS-Scripts] QBCore Alcohol MySQL compatibility fix loaded^7")
print("^3[LS-Scripts] Fixed MySQL.Async and MySQL.query compatibility issues^7")