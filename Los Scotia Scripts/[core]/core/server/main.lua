local QBCore = exports['qb-core']:GetCoreObject()
local LSCore = {}

-- Core initialization
CreateThread(function()
    Wait(100)
    if Config.EnableLogging then
        print('^2Los Scotia Core Framework Initialized^7')
    end
end)

-- Player functions
function LSCore.GetPlayer(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    
    return Player
end

-- Database functions
function LSCore.ExecuteSQL(query, params, callback)
    return MySQL.query(query, params, callback)
end

-- Events
RegisterNetEvent('LSCore:Server:Initialize', function()
    local src = source
    local Player = LSCore.GetPlayer(src)
    
    if Player then
        TriggerClientEvent('LSCore:Client:OnPlayerLoaded', src)
    end
end)

-- Callbacks
QBCore.Functions.CreateCallback('LSCore:Server:GetPlayerData', function(source, cb)
    local Player = LSCore.GetPlayer(source)
    if Player then
        cb(Player)
    else
        cb(nil)
    end
end)

-- Exports
exports('GetCore', function()
    return LSCore
end)