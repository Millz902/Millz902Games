local QBCore = exports['qb-core']:GetCoreObject()

-- Banking functions
RegisterNetEvent('ls-bank:client:openBanking', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openBanking",
        playerData = QBCore.Functions.GetPlayerData()
    })
end)

-- NUI Callbacks
RegisterNUICallback('closeBanking', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('ls-bank:server:withdraw', data.amount)
    cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('ls-bank:server:deposit', data.amount)
    cb('ok')
end)