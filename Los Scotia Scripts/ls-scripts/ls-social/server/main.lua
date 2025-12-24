local QBCore = exports['qb-core']:GetCoreObject()

-- Social media server initialization
CreateThread(function()
    print("^2[LS-Social]^7 Server initialized")
end)

-- Social media functions
RegisterNetEvent('ls-social:server:createPost', function(postData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Social media logic here
    TriggerClientEvent('QBCore:Notify', src, "Post created successfully", "success")
end)