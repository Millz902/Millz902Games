local QBCore = exports['qb-core']:GetCoreObject()
local LSCore = {}
local PlayerData = {}

-- Core initialization
Citizen.CreateThread(function()
    while true do
        if QBCore then
            TriggerEvent('LSCore:Client:OnCoreReady')
            break
        end
        Citizen.Wait(100)
    end
end)

-- Events
RegisterNetEvent('LSCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerEvent('LSCore:Client:PlayerDataUpdated', PlayerData)
end)

RegisterNetEvent('LSCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('LSCore:Client:OnPlayerLoaded')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('LSCore:Client:OnPlayerUnload')
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
    TriggerEvent('LSCore:Client:PlayerDataUpdated', PlayerData)
end)

-- Exports
exports('GetCore', function()
    return LSCore
end)

exports('GetPlayerData', function()
    return PlayerData
end)