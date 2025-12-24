local QBCore = exports['qb-core']:GetCoreObject()

-- Nightlife server initialization
CreateThread(function()
    print("^2[LS-Nightlife]^7 Server initialized")
end)

-- Club management functions
RegisterNetEvent('ls-nightlife:server:buyDrink', function(drinkType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Nightlife logic here
    TriggerClientEvent('QBCore:Notify', src, "Drink purchased", "success")
end)