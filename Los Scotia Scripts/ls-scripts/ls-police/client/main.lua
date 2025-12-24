local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local onDuty = false
local currentStation = nil

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job and PlayerData.job.name and table.contains(Config.PoliceJobs, PlayerData.job.name) then
        CreatePoliceBlips()
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    if PlayerData.job and PlayerData.job.name and table.contains(Config.PoliceJobs, PlayerData.job.name) then
        CreatePoliceBlips()
    else
        RemovePoliceBlips()
    end
end)

RegisterNetEvent('ls-police:client:ToggleDuty', function()
    onDuty = not onDuty
    TriggerServerEvent('ls-police:server:UpdateDutyStatus', onDuty)
    
    if onDuty then
        QBCore.Functions.Notify("You are now on duty", "success")
    else
        QBCore.Functions.Notify("You are now off duty", "error")
    end
end)

-- Functions
function CreatePoliceBlips()
    for k, v in pairs(Config.PoliceStations) do
        local blip = AddBlipForCoord(v.blipCoords.x, v.blipCoords.y, v.blipCoords.z)
        SetBlipSprite(blip, v.blipSprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.blipScale)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, v.blipColor)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.label)
        EndTextCommandSetBlipName(blip)
    end
end

function RemovePoliceBlips()
    for k, v in pairs(Config.PoliceStations) do
        local blip = GetFirstBlipInfoId(v.blipSprite)
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
end

function IsPoliceJob()
    return PlayerData.job and PlayerData.job.name and table.contains(Config.PoliceJobs, PlayerData.job.name)
end

function IsOnDuty()
    return onDuty and IsPoliceJob()
end

-- Exports
exports('IsPoliceJob', IsPoliceJob)
exports('IsOnDuty', IsOnDuty)

-- Utility function
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Initialize
CreateThread(function()
    Wait(1000)
    if QBCore.Functions.GetPlayerData() and QBCore.Functions.GetPlayerData().job then
        PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.job and PlayerData.job.name and table.contains(Config.PoliceJobs, PlayerData.job.name) then
            CreatePoliceBlips()
        end
    end
end)