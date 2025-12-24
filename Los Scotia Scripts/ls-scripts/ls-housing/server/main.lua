local QBCore = exports['qb-core']:GetCoreObject()

-- Variables
local houses = {}
local playerHouses = {}
local houseInteriors = {}
local houseFurniture = {}

-- Initialize housing system
CreateThread(function()
    LoadHouses()
    LoadHouseInteriors()
end)

-- Events
RegisterNetEvent('ls-housing:server:GetHouses', function()
    local src = source
    TriggerClientEvent('ls-housing:client:RefreshHouses', src, houses)
end)

RegisterNetEvent('ls-housing:server:EnterHouse', function(houseId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local house = houses[houseId]
    if not house then return end
    
    -- Check if player has access
    if house.owned and house.owner ~= Player.PlayerData.citizenid and not IsPlayerGuest(houseId, Player.PlayerData.citizenid) then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have access to this house', 'error')
        return
    end
    
    -- Set player inside house
    local interior = houseInteriors[house.interior] or houseInteriors['default']
    TriggerClientEvent('ls-housing:client:SetInside', src, houseId, interior.coords)
    
    -- Track player location
    playerHouses[src] = houseId
end)

RegisterNetEvent('ls-housing:server:ExitHouse', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local houseId = playerHouses[src]
    if not houseId then return end
    
    local house = houses[houseId]
    if not house then return end
    
    -- Set player outside house
    TriggerClientEvent('ls-housing:client:SetOutside', src, house.coords.enter)
    
    -- Remove player tracking
    playerHouses[src] = nil
end)

RegisterNetEvent('ls-housing:server:CheckHouseEntry', function(coords)
    local src = source
    
    -- Find nearest house
    local nearestHouse = nil
    local nearestDistance = 999.0
    
    for houseId, house in pairs(houses) do
        local distance = #(coords - house.coords.enter)
        if distance < nearestDistance and distance <= 3.0 then
            nearestDistance = distance
            nearestHouse = houseId
        end
    end
    
    if nearestHouse then
        TriggerEvent('ls-housing:server:EnterHouse', nearestHouse)
    else
        TriggerClientEvent('QBCore:Notify', src, 'No house entrance found', 'error')
    end
end)

RegisterNetEvent('ls-housing:server:PurchaseHouse', function(houseId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local house = houses[houseId]
    if not house then
        TriggerClientEvent('QBCore:Notify', src, 'House not found', 'error')
        return
    end
    
    if house.owned then
        TriggerClientEvent('QBCore:Notify', src, 'House is already owned', 'error')
        return
    end
    
    -- Check if player has enough money
    if Player.PlayerData.money.bank < house.price then
        TriggerClientEvent('QBCore:Notify', src, 'Insufficient funds', 'error')
        return
    end
    
    -- Check if player already owns a house
    if Player.PlayerData.metadata.house then
        TriggerClientEvent('QBCore:Notify', src, 'You already own a house', 'error')
        return
    end
    
    -- Purchase house
    Player.Functions.RemoveMoney('bank', house.price)
    house.owned = true
    house.owner = Player.PlayerData.citizenid
    house.purchaseDate = os.date('%Y-%m-%d %H:%M:%S')
    
    -- Update player metadata
    Player.Functions.SetMetaData('house', houseId)
    
    -- Save to database
    SaveHouseData(houseId, house)
    
    TriggerClientEvent('QBCore:Notify', src, 'House purchased successfully!', 'success')
    TriggerClientEvent('ls-housing:client:HousePurchased', src, house)
    
    -- Refresh houses for all players
    TriggerClientEvent('ls-housing:client:RefreshHouses', -1, houses)
end)

RegisterNetEvent('ls-housing:server:SellHouse', function(houseId, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local house = houses[houseId]
    if not house then
        TriggerClientEvent('QBCore:Notify', src, 'House not found', 'error')
        return
    end
    
    if not house.owned or house.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'You do not own this house', 'error')
        return
    end
    
    -- Sell house
    local salePrice = price or math.floor(house.price * 0.8) -- 80% of original price if no price specified
    Player.Functions.AddMoney('bank', salePrice)
    
    house.owned = false
    house.owner = nil
    house.purchaseDate = nil
    house.guests = {}
    
    -- Clear furniture
    houseFurniture[houseId] = {}
    
    -- Update player metadata
    Player.Functions.SetMetaData('house', nil)
    
    -- Save to database
    SaveHouseData(houseId, house)
    
    TriggerClientEvent('QBCore:Notify', src, 'House sold for $' .. salePrice, 'success')
    TriggerClientEvent('ls-housing:client:HouseSold', src, houseId)
    
    -- Refresh houses for all players
    TriggerClientEvent('ls-housing:client:RefreshHouses', -1, houses)
end)

RegisterNetEvent('ls-housing:server:TeleportToHouse', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local houseId = Player.PlayerData.metadata.house
    if not houseId then
        TriggerClientEvent('QBCore:Notify', src, 'You do not own a house', 'error')
        return
    end
    
    local house = houses[houseId]
    if not house then
        TriggerClientEvent('QBCore:Notify', src, 'House not found', 'error')
        return
    end
    
    -- Teleport player to house entrance
    SetEntityCoords(GetPlayerPed(src), house.coords.enter.x, house.coords.enter.y, house.coords.enter.z)
    TriggerClientEvent('QBCore:Notify', src, 'Teleported to your house', 'success')
end)

RegisterNetEvent('ls-housing:server:GetHouseInfo', function(houseId)
    local src = source
    local house = houses[houseId]
    if not house then return end
    
    local houseInfo = {
        id = houseId,
        label = house.label,
        price = house.price,
        owned = house.owned,
        owner = house.owner,
        purchaseDate = house.purchaseDate,
        interior = house.interior,
        guests = house.guests or {}
    }
    
    TriggerClientEvent('ls-housing:client:ShowHouseInfo', src, houseInfo)
end)

RegisterNetEvent('ls-housing:server:GetHouseGuests', function(houseId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local house = houses[houseId]
    if not house or house.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'You do not own this house', 'error')
        return
    end
    
    local guests = house.guests or {}
    TriggerClientEvent('ls-housing:client:ShowHouseGuests', src, guests)
end)

RegisterNetEvent('ls-housing:server:AddGuest', function(houseId, targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then return end
    
    local house = houses[houseId]
    if not house or house.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'You do not own this house', 'error')
        return
    end
    
    if not house.guests then house.guests = {} end
    
    -- Check if already a guest
    for _, guest in pairs(house.guests) do
        if guest.citizenid == TargetPlayer.PlayerData.citizenid then
            TriggerClientEvent('QBCore:Notify', src, 'Player is already a guest', 'error')
            return
        end
    end
    
    -- Add guest
    table.insert(house.guests, {
        citizenid = TargetPlayer.PlayerData.citizenid,
        name = TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname,
        addedDate = os.date('%Y-%m-%d %H:%M:%S')
    })
    
    -- Save to database
    SaveHouseData(houseId, house)
    
    TriggerClientEvent('QBCore:Notify', src, 'Guest added successfully', 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 'You have been added as a guest to a house', 'success')
end)

RegisterNetEvent('ls-housing:server:RemoveGuest', function(houseId, guestCitizenId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local house = houses[houseId]
    if not house or house.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'You do not own this house', 'error')
        return
    end
    
    if not house.guests then return end
    
    -- Remove guest
    for i, guest in pairs(house.guests) do
        if guest.citizenid == guestCitizenId then
            table.remove(house.guests, i)
            break
        end
    end
    
    -- Save to database
    SaveHouseData(houseId, house)
    
    TriggerClientEvent('QBCore:Notify', src, 'Guest removed successfully', 'success')
end)

RegisterNetEvent('ls-housing:server:GetGarageVehicles', function(houseId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local house = houses[houseId]
    if not house then return end
    
    -- Check access
    if house.owned and house.owner ~= Player.PlayerData.citizenid and not IsPlayerGuest(houseId, Player.PlayerData.citizenid) then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have access to this garage', 'error')
        return
    end
    
    -- Get player's vehicles
    local vehicles = {}
    -- This would typically query the database for player vehicles
    -- For now, return empty array as placeholder
    
    TriggerClientEvent('ls-housing:client:ShowGarageVehicles', src, vehicles)
end)

RegisterNetEvent('ls-housing:server:GetHouseFurniture', function(houseId)
    local src = source
    local furniture = houseFurniture[houseId] or {}
    TriggerClientEvent('ls-housing:client:LoadFurniture', src, furniture)
end)

RegisterNetEvent('ls-housing:server:PlaceFurniture', function(houseId, furnitureType, zone)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local house = houses[houseId]
    if not house or house.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'You do not own this house', 'error')
        return
    end
    
    if not houseFurniture[houseId] then
        houseFurniture[houseId] = {}
    end
    
    -- Remove existing furniture in zone
    for i = #houseFurniture[houseId], 1, -1 do
        if houseFurniture[houseId][i].zone == zone then
            table.remove(houseFurniture[houseId], i)
        end
    end
    
    -- Add new furniture
    table.insert(houseFurniture[houseId], {
        type = furnitureType,
        zone = zone,
        coords = GetEntityCoords(GetPlayerPed(src)),
        rotation = GetEntityHeading(GetPlayerPed(src))
    })
    
    -- Save to database
    SaveFurnitureData(houseId, houseFurniture[houseId])
    
    TriggerClientEvent('QBCore:Notify', src, 'Furniture placed successfully', 'success')
    TriggerClientEvent('ls-housing:client:LoadFurniture', src, houseFurniture[houseId])
end)

RegisterNetEvent('ls-housing:server:RemoveFurniture', function(houseId, zone)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local house = houses[houseId]
    if not house or house.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'You do not own this house', 'error')
        return
    end
    
    if not houseFurniture[houseId] then return end
    
    -- Remove furniture in zone
    for i = #houseFurniture[houseId], 1, -1 do
        if houseFurniture[houseId][i].zone == zone then
            table.remove(houseFurniture[houseId], i)
        end
    end
    
    -- Save to database
    SaveFurnitureData(houseId, houseFurniture[houseId])
    
    TriggerClientEvent('QBCore:Notify', src, 'Furniture removed successfully', 'success')
    TriggerClientEvent('ls-housing:client:LoadFurniture', src, houseFurniture[houseId])
end)

RegisterNetEvent('ls-housing:server:GetSecurityData', function(houseId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local house = houses[houseId]
    if not house or house.owner ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'You do not own this house', 'error')
        return
    end
    
    local securityData = {
        alarmActive = house.alarmActive or false,
        cameras = house.cameras or {},
        lockLevel = house.lockLevel or 1
    }
    
    TriggerClientEvent('ls-housing:client:ShowSecurityData', src, securityData)
end)

-- Functions
function LoadHouses()
    houses = {
        ['house_1'] = {
            id = 'house_1',
            label = 'Grove Street House',
            price = 150000,
            coords = {
                enter = vector4(-127.7, -1739.1, 29.3, 140.0),
                garage = vector4(-130.0, -1745.0, 29.0, 140.0)
            },
            interior = 'small_apartment',
            owned = false,
            owner = nil,
            guests = {}
        },
        ['house_2'] = {
            id = 'house_2',
            label = 'Vinewood Hills Mansion',
            price = 500000,
            coords = {
                enter = vector4(-1396.8, -669.5, 27.9, 210.0),
                garage = vector4(-1400.0, -665.0, 27.5, 210.0)
            },
            interior = 'luxury_apartment',
            owned = false,
            owner = nil,
            guests = {}
        },
        ['house_3'] = {
            id = 'house_3',
            label = 'Sandy Shores Trailer',
            price = 75000,
            coords = {
                enter = vector4(1661.0, 4776.0, 42.0, 90.0),
                garage = vector4(1665.0, 4780.0, 42.0, 90.0)
            },
            interior = 'trailer',
            owned = false,
            owner = nil,
            guests = {}
        },
        ['house_4'] = {
            id = 'house_4',
            label = 'Del Perro Beach House',
            price = 300000,
            coords = {
                enter = vector4(-1308.0, -1264.0, 4.6, 110.0),
                garage = vector4(-1305.0, -1270.0, 4.5, 110.0)
            },
            interior = 'medium_apartment',
            owned = false,
            owner = nil,
            guests = {}
        },
        ['house_5'] = {
            id = 'house_5',
            label = 'Paleto Bay Cabin',
            price = 120000,
            coords = {
                enter = vector4(-596.0, 5089.0, 220.0, 70.0),
                garage = vector4(-590.0, 5085.0, 220.0, 70.0)
            },
            interior = 'cabin',
            owned = false,
            owner = nil,
            guests = {}
        }
    }
    
    -- Load from database if available
    LoadHousesFromDB()
end

function LoadHouseInteriors()
    houseInteriors = {
        ['small_apartment'] = {
            coords = vector4(-2.0, -6.0, 0.0, 0.0),
            furniture_zones = {
                {coords = vector3(0.0, 0.0, 0.0), type = 'living_room'},
                {coords = vector3(3.0, 0.0, 0.0), type = 'bedroom'},
                {coords = vector3(-3.0, 0.0, 0.0), type = 'kitchen'}
            }
        },
        ['medium_apartment'] = {
            coords = vector4(-5.0, -10.0, 0.0, 0.0),
            furniture_zones = {
                {coords = vector3(0.0, 0.0, 0.0), type = 'living_room'},
                {coords = vector3(5.0, 0.0, 0.0), type = 'bedroom'},
                {coords = vector3(-5.0, 0.0, 0.0), type = 'kitchen'},
                {coords = vector3(0.0, 5.0, 0.0), type = 'dining_room'}
            }
        },
        ['luxury_apartment'] = {
            coords = vector4(-10.0, -15.0, 0.0, 0.0),
            furniture_zones = {
                {coords = vector3(0.0, 0.0, 0.0), type = 'living_room'},
                {coords = vector3(8.0, 0.0, 0.0), type = 'master_bedroom'},
                {coords = vector3(-8.0, 0.0, 0.0), type = 'kitchen'},
                {coords = vector3(0.0, 8.0, 0.0), type = 'dining_room'},
                {coords = vector3(8.0, 8.0, 0.0), type = 'guest_bedroom'}
            }
        },
        ['trailer'] = {
            coords = vector4(0.0, -2.0, 0.0, 0.0),
            furniture_zones = {
                {coords = vector3(0.0, 0.0, 0.0), type = 'living_area'},
                {coords = vector3(2.0, 0.0, 0.0), type = 'bedroom'}
            }
        },
        ['cabin'] = {
            coords = vector4(-3.0, -8.0, 0.0, 0.0),
            furniture_zones = {
                {coords = vector3(0.0, 0.0, 0.0), type = 'living_room'},
                {coords = vector3(4.0, 0.0, 0.0), type = 'bedroom'},
                {coords = vector3(-4.0, 0.0, 0.0), type = 'kitchen'}
            }
        },
        ['default'] = {
            coords = vector4(0.0, 0.0, 0.0, 0.0),
            furniture_zones = {
                {coords = vector3(0.0, 0.0, 0.0), type = 'main_room'}
            }
        }
    }
end

function IsPlayerGuest(houseId, citizenid)
    local house = houses[houseId]
    if not house or not house.guests then return false end
    
    for _, guest in pairs(house.guests) do
        if guest.citizenid == citizenid then
            return true
        end
    end
    
    return false
end

function SaveHouseData(houseId, houseData)
    -- Implement database save
    -- This would typically save to your database
    -- Example: exports.oxmysql:execute('UPDATE houses SET owned = ?, owner = ? WHERE id = ?', {houseData.owned, houseData.owner, houseId})
end

function SaveFurnitureData(houseId, furnitureData)
    -- Implement database save for furniture
    -- This would typically save to your database
end

function LoadHousesFromDB()
    -- Implement database load
    -- This would typically load from your database and update the houses table
end

function LoadFurnitureFromDB()
    -- Implement database load for furniture
    -- This would typically load from your database and update the houseFurniture table
end

-- Player disconnect handling
AddEventHandler('playerDropped', function(reason)
    local src = source
    if playerHouses[src] then
        playerHouses[src] = nil
    end
end)

-- Callbacks
QBCore.Functions.CreateCallback('ls-housing:server:GetHouseData', function(source, cb, houseId)
    cb(houses[houseId])
end)

QBCore.Functions.CreateCallback('ls-housing:server:GetPlayerHouses', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb({}) return end
    
    local playerHouseList = {}
    for houseId, house in pairs(houses) do
        if house.owner == Player.PlayerData.citizenid then
            table.insert(playerHouseList, house)
        end
    end
    
    cb(playerHouseList)
end)

QBCore.Functions.CreateCallback('ls-housing:server:CanAccessHouse', function(source, cb, houseId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false) return end
    
    local house = houses[houseId]
    if not house then cb(false) return end
    
    if not house.owned then
        cb(true) -- Unowned houses can be entered
        return
    end
    
    if house.owner == Player.PlayerData.citizenid then
        cb(true) -- Owner can access
        return
    end
    
    if IsPlayerGuest(houseId, Player.PlayerData.citizenid) then
        cb(true) -- Guests can access
        return
    end
    
    cb(false) -- No access
end)