local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentProperty = nil
local insideProperty = false

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    CreatePropertyBlips()
    CreateRealEstateBlips()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Property Commands
RegisterCommand('buyhouse', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /buyhouse [property_id]', 'primary')
        return
    end
    
    local propertyId = tonumber(args[1])
    TriggerServerEvent('ls-housing:server:buyProperty', propertyId)
end)

RegisterCommand('sellhouse', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /sellhouse [property_id]', 'primary')
        return
    end
    
    local propertyId = tonumber(args[1])
    TriggerServerEvent('ls-housing:server:sellProperty', propertyId)
end)

RegisterCommand('renthouse', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /renthouse [property_id]', 'primary')
        return
    end
    
    local propertyId = tonumber(args[1])
    TriggerServerEvent('ls-housing:server:rentProperty', propertyId)
end)

RegisterCommand('houseinfo', function()
    if not currentProperty then
        QBCore.Functions.Notify('You are not near any property', 'error')
        return
    end
    
    TriggerServerEvent('ls-housing:server:getPropertyInfo', currentProperty.id)
end)

RegisterCommand('inviteroommate', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /inviteroommate [player_id]', 'primary')
        return
    end
    
    if not currentProperty then
        QBCore.Functions.Notify('You must be at your property', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    TriggerServerEvent('ls-housing:server:inviteRoommate', currentProperty.id, targetId)
end)

RegisterCommand('kickroommate', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /kickroommate [player_id]', 'primary')
        return
    end
    
    if not currentProperty then
        QBCore.Functions.Notify('You must be at your property', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    TriggerServerEvent('ls-housing:server:kickRoommate', currentProperty.id, targetId)
end)

RegisterCommand('myhouses', function()
    TriggerServerEvent('ls-housing:server:getPlayerProperties')
end)

-- Property Interaction
CreateThread(function()
    while true do
        Wait(1000)
        if PlayerData then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local nearProperty = nil
            
            for _, property in pairs(Config.Properties) do
                local distance = #(playerCoords - property.coords)
                if distance <= 5.0 then
                    nearProperty = property
                    break
                end
            end
            
            if nearProperty and not currentProperty then
                currentProperty = nearProperty
                QBCore.Functions.Notify('Near ' .. nearProperty.name .. ' | Use /houseinfo for details', 'primary')
            elseif not nearProperty and currentProperty then
                currentProperty = nil
            end
        end
    end
end)

-- Property Events
RegisterNetEvent('ls-housing:client:propertyPurchased', function(propertyData)
    QBCore.Functions.Notify('Successfully purchased ' .. propertyData.name .. ' for $' .. propertyData.price, 'success')
    UpdatePropertyBlip(propertyData.id, true)
end)

RegisterNetEvent('ls-housing:client:propertySold', function(propertyData, salePrice)
    QBCore.Functions.Notify('Successfully sold ' .. propertyData.name .. ' for $' .. salePrice, 'success')
    UpdatePropertyBlip(propertyData.id, false)
end)

RegisterNetEvent('ls-housing:client:propertyRented', function(propertyData)
    QBCore.Functions.Notify('Successfully rented ' .. propertyData.name .. ' for $' .. propertyData.rent .. '/week', 'success')
end)

RegisterNetEvent('ls-housing:client:showPropertyInfo', function(propertyData, ownerData)
    local infoText = 'Property: ' .. propertyData.name .. '\n'
    infoText = infoText .. 'Type: ' .. Config.PropertyTypes[propertyData.type].name .. '\n'
    infoText = infoText .. 'Price: $' .. propertyData.price .. '\n'
    infoText = infoText .. 'Rent: $' .. propertyData.rent .. '/week\n'
    
    if ownerData then
        infoText = infoText .. 'Owner: ' .. ownerData.name .. '\n'
        if ownerData.roommates and #ownerData.roommates > 0 then
            infoText = infoText .. 'Roommates: ' .. #ownerData.roommates .. '\n'
        end
    else
        infoText = infoText .. 'Status: Available\n'
    end
    
    QBCore.Functions.Notify(infoText, 'primary')
end)

RegisterNetEvent('ls-housing:client:roommateInvited', function(propertyName, inviterName)
    QBCore.Functions.Notify(inviterName .. ' invited you to be a roommate at ' .. propertyName, 'success')
end)

RegisterNetEvent('ls-housing:client:roommateKicked', function(propertyName)
    QBCore.Functions.Notify('You have been removed as a roommate from ' .. propertyName, 'error')
end)

RegisterNetEvent('ls-housing:client:showPlayerProperties', function(properties)
    if #properties == 0 then
        QBCore.Functions.Notify('You dont own any properties', 'primary')
        return
    end
    
    local propertyList = 'Your Properties:\n'
    for _, property in pairs(properties) do
        propertyList = propertyList .. property.name .. ' (' .. property.type .. ')\n'
    end
    
    QBCore.Functions.Notify(propertyList, 'primary')
end)

RegisterNetEvent('ls-housing:client:enterProperty', function(propertyId)
    local property = nil
    for _, prop in pairs(Config.Properties) do
        if prop.id == propertyId then
            property = prop
            break
        end
    end
    
    if not property then return end
    
    insideProperty = true
    
    -- Teleport to interior (simplified - you might want to use proper interior system)
    local interior = Config.Interiors[property.type]
    if interior then
        SetEntityCoords(PlayerPedId(), interior.exit.x, interior.exit.y, interior.exit.z)
    end
    
    QBCore.Functions.Notify('Entered ' .. property.name, 'success')
end)

RegisterNetEvent('ls-housing:client:exitProperty', function()
    if not insideProperty then return end
    
    insideProperty = false
    
    if currentProperty then
        SetEntityCoords(PlayerPedId(), currentProperty.coords.x, currentProperty.coords.y, currentProperty.coords.z)
        QBCore.Functions.Notify('Exited property', 'primary')
    end
end)

-- Blip Functions
function CreatePropertyBlips()
    for _, property in pairs(Config.Properties) do
        local blip = AddBlipForCoord(property.coords.x, property.coords.y, property.coords.z)
        SetBlipSprite(blip, 40)
        SetBlipColour(blip, property.owned and 2 or 1)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(property.name)
        EndTextCommandSetBlipName(blip)
        
        property.blip = blip
    end
end

function CreateRealEstateBlips()
    for _, office in pairs(Config.RealEstateOffices) do
        if office.blip then
            local blip = AddBlipForCoord(office.coords.x, office.coords.y, office.coords.z)
            SetBlipSprite(blip, 374)
            SetBlipColour(blip, 3)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(office.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end

function UpdatePropertyBlip(propertyId, owned)
    for _, property in pairs(Config.Properties) do
        if property.id == propertyId and property.blip then
            SetBlipColour(property.blip, owned and 2 or 1)
            property.owned = owned
            break
        end
    end
end

-- Property Storage
RegisterCommand('storage', function()
    if not insideProperty or not currentProperty then
        QBCore.Functions.Notify('You must be inside your property', 'error')
        return
    end
    
    TriggerServerEvent('ls-housing:server:openStorage', currentProperty.id)
end)

-- Furniture System
RegisterCommand('buyfurniture', function()
    if not insideProperty or not currentProperty then
        QBCore.Functions.Notify('You must be inside your property', 'error')
        return
    end
    
    -- Open furniture menu (simplified)
    local furnitureMenu = {}
    for category, items in pairs(Config.Furniture) do
        for _, item in pairs(items) do
            table.insert(furnitureMenu, {
                header = item.name,
                txt = 'Price: $' .. item.price,
                params = {
                    event = 'ls-housing:client:buyFurniture',
                    args = {
                        prop = item.prop,
                        price = item.price,
                        name = item.name
                    }
                }
            })
        end
    end
    
    exports['qb-menu']:openMenu(furnitureMenu)
end)

RegisterNetEvent('ls-housing:client:buyFurniture', function(data)
    TriggerServerEvent('ls-housing:server:buyFurniture', currentProperty.id, data)
end)

-- Export functions
exports('IsInsideProperty', function()
    return insideProperty
end)

exports('GetCurrentProperty', function()
    return currentProperty
end)