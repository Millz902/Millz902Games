local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

-- Social media system initialization
CreateThread(function()
    print("^2[LS-Social]^7 Client initialized")
end)