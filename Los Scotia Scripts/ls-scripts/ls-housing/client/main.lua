local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

-- Variables
local currentHouse = nil
local insideHouse = false
local houseBlips = {}
local houseObjects = {}

-- Initialize
CreateThread(function()
    while not QBCore do
        Wait(10)
    end
    
    PlayerData = QBCore.Functions.GetPlayerData()
    
    -- Load house system
    LoadHouseSystem()
    
    -- Create house blips
    CreateHouseBlips()
end)

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    LoadHouseSystem()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    RemoveHouseBlips()
end)

RegisterNetEvent('ls-housing:client:UpdateHouseData', function(houseData)
    currentHouse = houseData
    UpdateHouseInterface()
end)

RegisterNetEvent('ls-housing:client:EnterHouse', function(houseId)
    TriggerServerEvent('ls-housing:server:EnterHouse', houseId)
end)

RegisterNetEvent('ls-housing:client:ExitHouse', function()
    TriggerServerEvent('ls-housing:server:ExitHouse')
end)

RegisterNetEvent('ls-housing:client:SetInside', function(houseId, coords)
    insideHouse = true
    currentHouse = houseId
    
    -- Teleport player inside
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(PlayerPedId(), coords.w or 0.0)
    Wait(100)
    DoScreenFadeIn(500)
    
    -- Load house interior
    LoadHouseInterior(houseId)
end)

RegisterNetEvent('ls-housing:client:SetOutside', function(coords)
    insideHouse = false
    currentHouse = nil
    
    -- Teleport player outside
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(PlayerPedId(), coords.w or 0.0)
    Wait(100)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('ls-housing:client:RefreshHouses', function(houses)
    RemoveHouseBlips()
    CreateHouseBlipsFromData(houses)
end)

RegisterNetEvent('ls-housing:client:HousePurchased', function(houseData)
    QBCore.Functions.Notify('House purchased successfully!', 'success')
    CreateHouseBlip(houseData)
end)

RegisterNetEvent('ls-housing:client:HouseSold', function(houseId)
    QBCore.Functions.Notify('House sold successfully!', 'success')
    RemoveHouseBlip(houseId)
end)

-- Functions
function LoadHouseSystem()
    -- Request house data from server
    TriggerServerEvent('ls-housing:server:GetHouses')
    
    -- Setup house interactions
    SetupHouseInteractions()
    
    -- Setup house commands
    SetupHouseCommands()
end

function SetupHouseCommands()
    -- House management commands
    RegisterCommand('house', function(source, args, rawCommand)
        if not insideHouse then
            QBCore.Functions.Notify('You must be inside a house to use this command', 'error')
            return
        end
        
        OpenHouseMenu()
    end, false)
    
    RegisterCommand('houseteleport', function(source, args, rawCommand)
        if not PlayerData.metadata.house then
            QBCore.Functions.Notify('You do not own a house', 'error')
            return
        end
        
        TriggerServerEvent('ls-housing:server:TeleportToHouse')
    end, false)
    
    RegisterCommand('houseguests', function(source, args, rawCommand)
        if not insideHouse then
            QBCore.Functions.Notify('You must be inside a house to manage guests', 'error')
            return
        end
        
        OpenGuestMenu()
    end, false)
end

function SetupHouseInteractions()
    -- House entrance interaction
    exports['qb-target']:AddGlobalObject({
        options = {
            {
                type = "client",
                event = "ls-housing:client:HouseDoorAction",
                icon = "fas fa-door-open",
                label = "House Door",
                canInteract = function(entity)
                    return GetEntityModel(entity) == GetHashKey('prop_door_01') or 
                           GetEntityModel(entity) == GetHashKey('v_ilev_fh_frontdoor')
                end,
            },
        },
        distance = 2.0
    })
    
    -- Garage interaction
    exports['qb-target']:AddBoxZone("house_garage", vector3(0, 0, 0), 3.0, 3.0, {
        name = "house_garage",
        heading = 0,
        debugPoly = false,
        minZ = -1.0,
        maxZ = 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "ls-housing:client:GarageMenu",
                icon = "fas fa-car",
                label = "Access Garage",
            },
        },
        distance = 2.0
    })
    
    -- Storage interaction
    exports['qb-target']:AddBoxZone("house_storage", vector3(0, 0, 0), 2.0, 2.0, {
        name = "house_storage",
        heading = 0,
        debugPoly = false,
        minZ = -1.0,
        maxZ = 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "ls-housing:client:AccessStorage",
                icon = "fas fa-box",
                label = "Access Storage",
            },
        },
        distance = 2.0
    })
end

function CreateHouseBlips()
    TriggerServerEvent('ls-housing:server:GetHouses')
end

function CreateHouseBlipsFromData(houses)
    for houseId, houseData in pairs(houses) do
        CreateHouseBlip(houseData)
    end
end

function CreateHouseBlip(houseData)
    local blip = AddBlipForCoord(houseData.coords.enter.x, houseData.coords.enter.y, houseData.coords.enter.z)
    
    if houseData.owned then
        SetBlipSprite(blip, 40)  -- House owned
        SetBlipColour(blip, 2)   -- Green
    else
        SetBlipSprite(blip, 374) -- House for sale
        SetBlipColour(blip, 5)   -- Yellow
    end
    
    SetBlipScale(blip, 0.6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    
    if houseData.owned then
        AddTextComponentString(houseData.label .. ' (Owned)')
    else
        AddTextComponentString(houseData.label .. ' ($' .. houseData.price .. ')')
    end
    
    EndTextCommandSetBlipName(blip)
    
    houseBlips[houseData.id] = blip
end

function RemoveHouseBlips()
    for _, blip in pairs(houseBlips) do
        RemoveBlip(blip)
    end
    houseBlips = {}
end

function RemoveHouseBlip(houseId)
    if houseBlips[houseId] then
        RemoveBlip(houseBlips[houseId])
        houseBlips[houseId] = nil
    end
end

function LoadHouseInterior(houseId)
    -- Load furniture and decorations
    TriggerServerEvent('ls-housing:server:GetHouseFurniture', houseId)
    
    -- Setup interior interactions
    SetupInteriorInteractions(houseId)
end

function SetupInteriorInteractions(houseId)
    -- Furniture placement zones
    for i = 1, 10 do
        exports['qb-target']:AddBoxZone("furniture_zone_" .. i, vector3(0, 0, 0), 2.0, 2.0, {
            name = "furniture_zone_" .. i,
            heading = 0,
            debugPoly = false,
            minZ = -1.0,
            maxZ = 3.0,
        }, {
            options = {
                {
                    type = "client",
                    event = "ls-housing:client:PlaceFurniture",
                    icon = "fas fa-chair",
                    label = "Place Furniture",
                    action = function()
                        OpenFurnitureMenu(i)
                    end
                },
            },
            distance = 2.0
        })
    end
end

function OpenHouseMenu()
    if not currentHouse then return end
    
    local houseMenu = {
        {
            header = 'House Management',
            isMenuHeader = true
        },
        {
            header = 'House Information',
            txt = 'View house details',
            icon = 'fas fa-info-circle',
            params = {
                event = 'ls-housing:client:ViewHouseInfo'
            }
        },
        {
            header = 'Furniture Store',
            txt = 'Browse and purchase furniture',
            icon = 'fas fa-couch',
            params = {
                event = 'ls-housing:client:OpenFurnitureStore'
            }
        },
        {
            header = 'Security System',
            txt = 'Manage house security',
            icon = 'fas fa-shield-alt',
            params = {
                event = 'ls-housing:client:SecurityMenu'
            }
        },
        {
            header = 'Guest Management',
            txt = 'Manage house guests',
            icon = 'fas fa-users',
            params = {
                event = 'ls-housing:client:GuestMenu'
            }
        },
        {
            header = 'Sell House',
            txt = 'Put house up for sale',
            icon = 'fas fa-dollar-sign',
            params = {
                event = 'ls-housing:client:SellHouse'
            }
        },
        {
            header = 'Close Menu',
            txt = '',
            icon = 'fas fa-times',
            params = {
                event = 'qb-menu:client:closeMenu'
            }
        }
    }
    
    exports['qb-menu']:openMenu(houseMenu)
end

function OpenGuestMenu()
    TriggerServerEvent('ls-housing:server:GetHouseGuests', currentHouse)
end

function OpenFurnitureMenu(zoneId)
    local furnitureMenu = {
        {
            header = 'Furniture Placement - Zone ' .. zoneId,
            isMenuHeader = true
        },
        {
            header = 'Chair',
            txt = 'Place a chair',
            icon = 'fas fa-chair',
            params = {
                event = 'ls-housing:client:PlaceFurnitureItem',
                args = { type = 'chair', zone = zoneId }
            }
        },
        {
            header = 'Table',
            txt = 'Place a table',
            icon = 'fas fa-table',
            params = {
                event = 'ls-housing:client:PlaceFurnitureItem',
                args = { type = 'table', zone = zoneId }
            }
        },
        {
            header = 'Bed',
            txt = 'Place a bed',
            icon = 'fas fa-bed',
            params = {
                event = 'ls-housing:client:PlaceFurnitureItem',
                args = { type = 'bed', zone = zoneId }
            }
        },
        {
            header = 'Remove Furniture',
            txt = 'Remove furniture from this zone',
            icon = 'fas fa-trash',
            params = {
                event = 'ls-housing:client:RemoveFurniture',
                args = { zone = zoneId }
            }
        },
        {
            header = 'Close Menu',
            txt = '',
            icon = 'fas fa-times',
            params = {
                event = 'qb-menu:client:closeMenu'
            }
        }
    }
    
    exports['qb-menu']:openMenu(furnitureMenu)
end

-- House Events
RegisterNetEvent('ls-housing:client:HouseDoorAction', function(data)
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('ls-housing:server:CheckHouseEntry', coords)
end)

RegisterNetEvent('ls-housing:client:ViewHouseInfo', function()
    if not currentHouse then return end
    TriggerServerEvent('ls-housing:server:GetHouseInfo', currentHouse)
end)

RegisterNetEvent('ls-housing:client:OpenFurnitureStore', function()
    TriggerEvent('ls-housing:client:OpenFurnitureShop')
end)

RegisterNetEvent('ls-housing:client:SecurityMenu', function()
    if not currentHouse then return end
    TriggerServerEvent('ls-housing:server:GetSecurityData', currentHouse)
end)

RegisterNetEvent('ls-housing:client:GuestMenu', function()
    if not currentHouse then return end
    OpenGuestMenu()
end)

RegisterNetEvent('ls-housing:client:SellHouse', function()
    if not currentHouse then return end
    
    local input = exports['qb-input']:ShowInput({
        header = "Sell House",
        submitText = "Confirm Sale",
        inputs = {
            {
                text = "Sale Price ($)",
                name = "price",
                type = "number",
                isRequired = true,
            }
        },
    })
    
    if input and input.price then
        TriggerServerEvent('ls-housing:server:SellHouse', currentHouse, tonumber(input.price))
    end
end)

RegisterNetEvent('ls-housing:client:GarageMenu', function()
    if not currentHouse then return end
    TriggerServerEvent('ls-housing:server:GetGarageVehicles', currentHouse)
end)

RegisterNetEvent('ls-housing:client:AccessStorage', function()
    if not currentHouse then return end
    
    TriggerEvent('inventory:client:SetCurrentStash', 'house_' .. currentHouse)
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'house_' .. currentHouse, {
        maxweight = 4000000,
        slots = 50,
    })
end)

RegisterNetEvent('ls-housing:client:PlaceFurnitureItem', function(data)
    local furnitureType = data.type
    local zone = data.zone
    
    -- Get furniture model and placement logic
    TriggerServerEvent('ls-housing:server:PlaceFurniture', currentHouse, furnitureType, zone)
end)

RegisterNetEvent('ls-housing:client:RemoveFurniture', function(data)
    TriggerServerEvent('ls-housing:server:RemoveFurniture', currentHouse, data.zone)
end)