local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Main banking interface
CreateThread(function()
    -- Banking system initialization
    print("^2[LS-Bank-Advanced]^7 Client initialized")
end)