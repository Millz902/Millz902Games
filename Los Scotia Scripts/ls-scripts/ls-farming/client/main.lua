local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local playerFarms = {}
local nearbyFarms = {}
local isNearFarm = false

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    LoadPlayerFarms()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    playerFarms = {}
end)

-- Load player's farms
function LoadPlayerFarms()
    QBCore.Functions.TriggerCallback('ls-farming:server:getPlayerFarms', function(farms)
        playerFarms = farms
    end)
end

-- Farm proximity detection
CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local wasNearFarm = isNearFarm
        isNearFarm = false
        nearbyFarms = {}
        
        -- Check proximity to all farms
        for farmId, farmData in pairs(Config.Farms) do
            local farmCoords = vector3(farmData.coords.x, farmData.coords.y, farmData.coords.z)
            local distance = #(playerCoords - farmCoords)
            
            if distance < 100.0 then -- Within 100 meters
                isNearFarm = true
                nearbyFarms[farmId] = {
                    data = farmData,
                    distance = distance,
                    coords = farmCoords
                }
                
                -- Show farm blip if not owned
                if not farmData.owner then
                    DrawFarmBlip(farmId, farmCoords, farmData.name)
                end
                
                -- Show interaction if close enough
                if distance < 5.0 then
                    ShowFarmInteraction(farmId, farmData)
                end
            end
        end
        
        -- Update UI if farm status changed
        if wasNearFarm ~= isNearFarm then
            if isNearFarm then
                TriggerEvent('ls-farming:client:enterFarmArea')
            else
                TriggerEvent('ls-farming:client:exitFarmArea')
            end
        end
        
        Wait(1000)
    end
end)

-- Draw farm blips
local farmBlips = {}
function DrawFarmBlip(farmId, coords, name)
    if farmBlips[farmId] then return end
    
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 140) -- Farm icon
    SetBlipColour(blip, 2) -- Green
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    
    farmBlips[farmId] = blip
end

-- Show farm interaction
function ShowFarmInteraction(farmId, farmData)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local farmCoords = vector3(farmData.coords.x, farmData.coords.y, farmData.coords.z)
    
    -- Draw 3D text
    DrawText3D(farmCoords.x, farmCoords.y, farmCoords.z + 1.0, farmData.name)
    
    if not farmData.owner then
        DrawText3D(farmCoords.x, farmCoords.y, farmCoords.z + 0.5, 
            string.format("~g~[E]~w~ Purchase Farm - ~g~$%s", ESX.Math.GroupDigits(farmData.purchase_price)))
        
        if IsControlJustPressed(0, 38) then -- E key
            ShowFarmPurchaseMenu(farmId, farmData)
        end
    else
        -- Show farm management options for owners
        local isOwner = false
        for _, farm in pairs(playerFarms) do
            if farm.farm_id == farmId then
                isOwner = true
                break
            end
        end
        
        if isOwner then
            DrawText3D(farmCoords.x, farmCoords.y, farmCoords.z + 0.5, "~g~[E]~w~ Manage Farm")
            if IsControlJustPressed(0, 38) then -- E key
                ShowFarmManagementMenu(farmId, farmData)
            end
        end
    end
end

-- Farm purchase menu
function ShowFarmPurchaseMenu(farmId, farmData)
    local menu = {}
    
    table.insert(menu, {
        header = farmData.name,
        txt = string.format("Purchase this farm for $%s", ESX.Math.GroupDigits(farmData.purchase_price)),
        isMenuHeader = true
    })
    
    table.insert(menu, {
        header = "📊 Farm Details",
        txt = string.format("Area: %s sqm | Plots: %d | Storage: %s kg", 
            ESX.Math.GroupDigits(farmData.total_area), 
            farmData.available_plots,
            ESX.Math.GroupDigits(farmData.storage_capacity)),
        isMenuHeader = true
    })
    
    table.insert(menu, {
        header = "💰 Purchase Farm",
        txt = string.format("Cost: $%s | Daily Upkeep: $%s", 
            ESX.Math.GroupDigits(farmData.purchase_price),
            ESX.Math.GroupDigits(farmData.daily_upkeep)),
        params = {
            event = "ls-farming:client:confirmPurchase",
            args = {farmId = farmId}
        }
    })
    
    table.insert(menu, {
        header = "❌ Cancel",
        txt = "Go back",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    })
    
    exports['qb-menu']:openMenu(menu)
end

-- Farm management menu
function ShowFarmManagementMenu(farmId, farmData)
    local menu = {}
    
    table.insert(menu, {
        header = farmData.name,
        txt = "Farm Management",
        isMenuHeader = true
    })
    
    table.insert(menu, {
        header = "🌱 Crop Management",
        txt = "Plant and harvest crops",
        params = {
            event = "ls-farming:client:openCropMenu",
            args = {farmId = farmId}
        }
    })
    
    table.insert(menu, {
        header = "🐄 Livestock Management",
        txt = "Manage animals",
        params = {
            event = "ls-farming:client:openLivestockMenu",
            args = {farmId = farmId}
        }
    })
    
    table.insert(menu, {
        header = "📦 Storage Management",
        txt = "View farm inventory",
        params = {
            event = "ls-farming:client:openStorageMenu",
            args = {farmId = farmId}
        }
    })
    
    table.insert(menu, {
        header = "💼 Business Operations",
        txt = "Contracts and sales",
        params = {
            event = "ls-farming:client:openBusinessMenu",
            args = {farmId = farmId}
        }
    })
    
    table.insert(menu, {
        header = "❌ Close",
        txt = "Exit menu",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    })
    
    exports['qb-menu']:openMenu(menu)
end

-- Crop management
RegisterNetEvent('ls-farming:client:openCropMenu', function(data)
    -- Get available crops for player level
    QBCore.Functions.TriggerCallback('ls-farming:server:getPlayerStats', function(playerStats)
        local availableCrops = {}
        
        for cropType, cropData in pairs(Config.Crops) do
            if playerStats.farming_level >= cropData.required_level then
                table.insert(availableCrops, {
                    type = cropType,
                    data = cropData
                })
            end
        end
        
        ShowCropSelectionMenu(data.farmId, availableCrops)
    end)
end)

function ShowCropSelectionMenu(farmId, availableCrops)
    local menu = {}
    
    table.insert(menu, {
        header = "🌱 Select Crop to Plant",
        txt = "Choose what to grow",
        isMenuHeader = true
    })
    
    for _, crop in pairs(availableCrops) do
        table.insert(menu, {
            header = crop.data.name,
            txt = string.format("Grow Time: %dm | Yield: %d-%d kg | Seed Cost: $%d", 
                crop.data.grow_time, 
                crop.data.yield_per_plot.min, 
                crop.data.yield_per_plot.max,
                crop.data.seed_cost),
            params = {
                event = "ls-farming:client:selectCropLocation",
                args = {farmId = farmId, cropType = crop.type}
            }
        })
    end
    
    table.insert(menu, {
        header = "❌ Back",
        txt = "Return to farm menu",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    })
    
    exports['qb-menu']:openMenu(menu)
end

-- Utility functions
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Network events
RegisterNetEvent('ls-farming:client:confirmPurchase', function(data)
    TriggerServerEvent('ls-farming:server:purchaseFarm', data.farmId)
end)

RegisterNetEvent('ls-farming:client:updateFarms', function()
    LoadPlayerFarms()
end)

RegisterNetEvent('ls-farming:client:updatePlot', function(plotId)
    -- Refresh farm data
    LoadPlayerFarms()
end)

-- Initialize on resource start
CreateThread(function()
    print("^2[LS-Farming]^7 Client initialized with enterprise features")
    
    -- Load farms when player is already loaded (resource restart)
    if PlayerData and PlayerData.citizenid then
        LoadPlayerFarms()
    end
end)