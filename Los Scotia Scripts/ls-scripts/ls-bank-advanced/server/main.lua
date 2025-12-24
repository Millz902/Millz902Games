local QBCore = exports['qb-core']:GetCoreObject()

-- Server events
RegisterNetEvent('ls-bank:server:withdraw', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end
    
    if Player.PlayerData.money["bank"] >= amount then
        Player.Functions.RemoveMoney("bank", amount)
        Player.Functions.AddMoney("cash", amount)
        TriggerClientEvent('QBCore:Notify', src, "Withdrew $" .. amount, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Insufficient funds", "error")
    end
end)

RegisterNetEvent('ls-bank:server:deposit', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end
    
    if Player.PlayerData.money["cash"] >= amount then
        Player.Functions.RemoveMoney("cash", amount)
        Player.Functions.AddMoney("bank", amount)
        TriggerClientEvent('QBCore:Notify', src, "Deposited $" .. amount, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Insufficient cash", "error")
    end
end)