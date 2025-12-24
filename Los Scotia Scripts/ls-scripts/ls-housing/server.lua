local QBCore = exports['qb-core']:GetCoreObject()

-- Property Management
RegisterNetEvent('ls-housing:server:buyProperty', function(propertyId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local property = nil
    for _, prop in pairs(Config.Properties) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    if not property then
        TriggerClientEvent('QBCore:Notify', src, 'Property not found', 'error')
        return
    end
    
    if property.owned then
        TriggerClientEvent('QBCore:Notify', src, 'Property is already owned', 'error')
        return
    end
    
    -- Check player money
    if Player.PlayerData.money.bank < property.price then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money in bank', 'error')
        return
    end
    
    -- Check if player owns too many properties
    local ownedProperties = MySQL.query.await('SELECT COUNT(*) as count FROM player_houses WHERE citizenid = ?', {
        Player.PlayerData.citizenid
    })
    
    if ownedProperties[1].count >= Config.MaxHousesPerPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'You own too many properties (max: ' .. Config.MaxHousesPerPlayer .. ')', 'error')
        return
    end
    
    -- Remove money and create property
    Player.Functions.RemoveMoney('bank', property.price)
    
    MySQL.insert('INSERT INTO player_houses (citizenid, house_id, house_name, house_type, owned, rent_due) VALUES (?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.citizenid,
        property.id,
        property.name,
        property.type,
        1,
        os.time() + Config.RentDueTime
    })
    
    property.owned = true
    
    TriggerClientEvent('ls-housing:client:propertyPurchased', src, property)
end)

RegisterNetEvent('ls-housing:server:sellProperty', function(propertyId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local propertyData = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ? AND house_id = ?', {
        Player.PlayerData.citizenid,
        propertyId
    })
    
    if not propertyData[1] then
        TriggerClientEvent('QBCore:Notify', src, 'You dont own this property', 'error')
        return
    end
    
    local property = nil
    for _, prop in pairs(Config.Properties) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    if not property then return end
    
    -- Calculate sale price (80% of original)
    local salePrice = math.floor(property.price * 0.8)
    
    -- Remove property and give money
    MySQL.execute('DELETE FROM player_houses WHERE citizenid = ? AND house_id = ?', {
        Player.PlayerData.citizenid,
        propertyId
    })
    
    -- Clear storage
    MySQL.execute('DELETE FROM house_storage WHERE house_id = ?', {propertyId})
    
    Player.Functions.AddMoney('bank', salePrice)
    property.owned = false
    
    TriggerClientEvent('ls-housing:client:propertySold', src, property, salePrice)
end)

RegisterNetEvent('ls-housing:server:rentProperty', function(propertyId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local property = nil
    for _, prop in pairs(Config.Properties) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    if not property then
        TriggerClientEvent('QBCore:Notify', src, 'Property not found', 'error')
        return
    end
    
    -- Check if property is owned by someone else
    local ownerData = MySQL.query.await('SELECT * FROM player_houses WHERE house_id = ?', {propertyId})
    
    if not ownerData[1] then
        TriggerClientEvent('QBCore:Notify', src, 'Property is not available for rent', 'error')
        return
    end
    
    -- Check if already renting
    local existingRent = MySQL.query.await('SELECT * FROM house_rentals WHERE citizenid = ? AND house_id = ?', {
        Player.PlayerData.citizenid,
        propertyId
    })
    
    if existingRent[1] then
        TriggerClientEvent('QBCore:Notify', src, 'You are already renting this property', 'error')
        return
    end
    
    if Player.PlayerData.money.bank < property.rent then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money for rent', 'error')
        return
    end
    
    -- Create rental agreement
    Player.Functions.RemoveMoney('bank', property.rent)
    
    MySQL.insert('INSERT INTO house_rentals (citizenid, house_id, rent_amount, rent_due) VALUES (?, ?, ?, ?)', {
        Player.PlayerData.citizenid,
        propertyId,
        property.rent,
        os.time() + Config.RentDueTime
    })
    
    TriggerClientEvent('ls-housing:client:propertyRented', src, property)
end)

RegisterNetEvent('ls-housing:server:getPropertyInfo', function(propertyId)
    local src = source
    
    local property = nil
    for _, prop in pairs(Config.Properties) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    if not property then return end
    
    local ownerData = MySQL.query.await('SELECT * FROM player_houses WHERE house_id = ?', {propertyId})
    
    local ownerInfo = nil
    if ownerData[1] then
        local ownerPlayer = MySQL.query.await('SELECT charinfo FROM players WHERE citizenid = ?', {ownerData[1].citizenid})
        if ownerPlayer[1] then
            local charinfo = json.decode(ownerPlayer[1].charinfo)
            ownerInfo = {
                name = charinfo.firstname .. ' ' .. charinfo.lastname,
                roommates = {}
            }
            
            -- Get roommates
            local roommates = MySQL.query.await('SELECT * FROM house_rentals WHERE house_id = ?', {propertyId})
            for _, roommate in pairs(roommates) do
                local roommatePlayer = MySQL.query.await('SELECT charinfo FROM players WHERE citizenid = ?', {roommate.citizenid})
                if roommatePlayer[1] then
                    local roommateInfo = json.decode(roommatePlayer[1].charinfo)
                    table.insert(ownerInfo.roommates, roommateInfo.firstname .. ' ' .. roommateInfo.lastname)
                end
            end
        end
    end
    
    TriggerClientEvent('ls-housing:client:showPropertyInfo', src, property, ownerInfo)
end)

RegisterNetEvent('ls-housing:server:inviteRoommate', function(propertyId, targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
        return
    end
    
    -- Check if player owns the property
    local ownerData = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ? AND house_id = ?', {
        Player.PlayerData.citizenid,
        propertyId
    })
    
    if not ownerData[1] then
        TriggerClientEvent('QBCore:Notify', src, 'You dont own this property', 'error')
        return
    end
    
    -- Check roommate limit
    local currentRoommates = MySQL.query.await('SELECT COUNT(*) as count FROM house_rentals WHERE house_id = ?', {propertyId})
    
    if currentRoommates[1].count >= Config.MaxRoomates then
        TriggerClientEvent('QBCore:Notify', src, 'Maximum roommates reached', 'error')
        return
    end
    
    local property = nil
    for _, prop in pairs(Config.Properties) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    -- Add roommate
    MySQL.insert('INSERT INTO house_rentals (citizenid, house_id, rent_amount, rent_due) VALUES (?, ?, ?, ?)', {
        TargetPlayer.PlayerData.citizenid,
        propertyId,
        0, -- Roommates don't pay rent directly
        os.time() + Config.RentDueTime
    })
    
    TriggerClientEvent('ls-housing:client:roommateInvited', targetId, property.name, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname)
    TriggerClientEvent('QBCore:Notify', src, 'Roommate invited successfully', 'success')
end)

RegisterNetEvent('ls-housing:server:kickRoommate', function(propertyId, targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
        return
    end
    
    -- Check if player owns the property
    local ownerData = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ? AND house_id = ?', {
        Player.PlayerData.citizenid,
        propertyId
    })
    
    if not ownerData[1] then
        TriggerClientEvent('QBCore:Notify', src, 'You dont own this property', 'error')
        return
    end
    
    local property = nil
    for _, prop in pairs(Config.Properties) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    -- Remove roommate
    MySQL.execute('DELETE FROM house_rentals WHERE citizenid = ? AND house_id = ?', {
        TargetPlayer.PlayerData.citizenid,
        propertyId
    })
    
    TriggerClientEvent('ls-housing:client:roommateKicked', targetId, property.name)
    TriggerClientEvent('QBCore:Notify', src, 'Roommate removed successfully', 'success')
end)

RegisterNetEvent('ls-housing:server:getPlayerProperties', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local properties = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ?', {
        Player.PlayerData.citizenid
    })
    
    local propertyList = {}
    for _, property in pairs(properties) do
        table.insert(propertyList, {
            id = property.house_id,
            name = property.house_name,
            type = property.house_type
        })
    end
    
    TriggerClientEvent('ls-housing:client:showPlayerProperties', src, propertyList)
end)

-- Storage System
RegisterNetEvent('ls-housing:server:openStorage', function(propertyId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has access to this property
    local hasAccess = false
    
    -- Check ownership
    local ownerData = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ? AND house_id = ?', {
        Player.PlayerData.citizenid,
        propertyId
    })
    
    if ownerData[1] then
        hasAccess = true
    else
        -- Check roommate access
        local roommateData = MySQL.query.await('SELECT * FROM house_rentals WHERE citizenid = ? AND house_id = ?', {
            Player.PlayerData.citizenid,
            propertyId
        })
        
        if roommateData[1] then
            hasAccess = true
        end
    end
    
    if not hasAccess then
        TriggerClientEvent('QBCore:Notify', src, 'You dont have access to this storage', 'error')
        return
    end
    
    -- Open storage (simplified - you would integrate with your inventory system)
    local stashName = 'house_' .. propertyId
    TriggerClientEvent('QBCore:Notify', src, 'Storage opened', 'success')
    -- exports['qb-inventory']:OpenInventory(src, stashName, Config.StorageSize)
end)

-- Furniture System
RegisterNetEvent('ls-housing:server:buyFurniture', function(propertyId, furnitureData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check ownership
    local ownerData = MySQL.query.await('SELECT * FROM player_houses WHERE citizenid = ? AND house_id = ?', {
        Player.PlayerData.citizenid,
        propertyId
    })
    
    if not ownerData[1] then
        TriggerClientEvent('QBCore:Notify', src, 'You dont own this property', 'error')
        return
    end
    
    if Player.PlayerData.money.cash < furnitureData.price then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough cash', 'error')
        return
    end
    
    Player.Functions.RemoveMoney('cash', furnitureData.price)
    
    -- Save furniture to database
    MySQL.insert('INSERT INTO house_furniture (house_id, furniture_name, furniture_prop, x, y, z, heading) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        propertyId,
        furnitureData.name,
        furnitureData.prop,
        0.0, 0.0, 0.0, 0.0 -- Default position, player can move it
    })
    
    TriggerClientEvent('QBCore:Notify', src, 'Furniture purchased: ' .. furnitureData.name, 'success')
end)

-- Rent Collection (automated)
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        local overdueRentals = MySQL.query.await('SELECT * FROM house_rentals WHERE rent_due < ?', {os.time()})
        
        for _, rental in pairs(overdueRentals) do
            local Player = QBCore.Functions.GetPlayerByCitizenId(rental.citizenid)
            
            if Player then
                if Player.PlayerData.money.bank >= rental.rent_amount then
                    Player.Functions.RemoveMoney('bank', rental.rent_amount)
                    MySQL.execute('UPDATE house_rentals SET rent_due = ? WHERE citizenid = ? AND house_id = ?', {
                        os.time() + Config.RentDueTime,
                        rental.citizenid,
                        rental.house_id
                    })
                    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'Rent automatically paid: $' .. rental.rent_amount, 'primary')
                else
                    -- Evict for non-payment
                    MySQL.execute('DELETE FROM house_rentals WHERE citizenid = ? AND house_id = ?', {
                        rental.citizenid,
                        rental.house_id
                    })
                    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'Evicted for non-payment of rent', 'error')
                end
            end
        end
    end
end)

print("^2[LS-HOUSING]^7 Housing System loaded successfully!")