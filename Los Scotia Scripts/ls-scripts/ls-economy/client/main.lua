local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

-- Economy system initialization
CreateThread(function()
    print("^2[LS-Economy]^7 Client initialized")
end)