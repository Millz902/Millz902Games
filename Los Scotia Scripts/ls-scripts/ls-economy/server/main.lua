local QBCore = exports['qb-core']:GetCoreObject()

-- Economy server initialization
CreateThread(function()
    print("^2[LS-Economy]^7 Server initialized")
end)

-- Stock market functions
RegisterNetEvent('ls-economy:server:buyStock', function(stockSymbol, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Stock buying logic here
    TriggerClientEvent('QBCore:Notify', src, "Stock purchase processed", "success")
end)