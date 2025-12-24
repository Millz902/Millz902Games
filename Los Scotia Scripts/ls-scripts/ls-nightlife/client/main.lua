local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

-- Nightlife system initialization
CreateThread(function()
    print("^2[LS-Nightlife]^7 Client initialized")
end)