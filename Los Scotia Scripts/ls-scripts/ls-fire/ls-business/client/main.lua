local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isBusinessMenuOpen = false

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Business Menu Functions
function OpenBusinessMenu()
    if isBusinessMenuOpen then return end
    
    isBusinessMenuOpen = true
    SetNuiFocus(true, true)
    
    QBCore.Functions.TriggerCallback('ls-business:server:getBusinessData', function(businessData)
        SendNUIMessage({
            action = 'show',
            businessData = businessData
        })
    end)
end

function CloseBusinessMenu()
    isBusinessMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hide'
    })
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    CloseBusinessMenu()
    cb('ok')
end)

RegisterNUICallback('hireEmployee', function(data, cb)
    TriggerServerEvent('ls-business:server:hireEmployee', data)
    cb('ok')
end)

RegisterNUICallback('fireEmployee', function(data, cb)
    TriggerServerEvent('ls-business:server:fireEmployee', data)
    cb('ok')
end)

RegisterNUICallback('updateSettings', function(data, cb)
    TriggerServerEvent('ls-business:server:updateSettings', data)
    cb('ok')
end)

-- Commands
RegisterCommand(Config.Commands['business'], function()
    if PlayerData.job and PlayerData.job.grade.level >= 2 then
        OpenBusinessMenu()
    else
        QBCore.Functions.Notify('You do not have permission to access business management', 'error')
    end
end)

-- Key Mapping
RegisterKeyMapping(Config.Commands['business'], 'Open Business Menu', 'keyboard', Config.Keybinds['open_business_menu'])

-- Exports
exports('OpenBusinessMenu', OpenBusinessMenu)
exports('CloseBusinessMenu', CloseBusinessMenu)