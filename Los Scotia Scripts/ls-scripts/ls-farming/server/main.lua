local QBCore = exports['qb-core']:GetCoreObject()

-- Database check and initialization
CreateThread(function()
    -- Check if farming tables exist
    local result = MySQL.query.await('SHOW TABLES LIKE "ls_farms"')
    if not result or #result == 0 then
        print("^3[LS-Farming]^7 Database tables not found. Please run LS_FARMING_DATABASE_SCHEMA.sql")
        return
    end
    print("^2[LS-Farming]^7 Server initialized with database support")
end)

-- Farm Management Functions
local function GetPlayerFarms(citizenid)
    return MySQL.query.await('SELECT * FROM ls_farms WHERE owner_citizenid = ?', {citizenid})
end

local function GetFarmDetails(farmId)
    return MySQL.single.await('SELECT * FROM ls_farms WHERE farm_id = ?', {farmId})
end

local function PurchaseFarm(citizenid, farmId)
    local farm = GetFarmDetails(farmId)
    if not farm then return false, "Farm not found" end
    if farm.owner_citizenid then return false, "Farm already owned" end
    
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if not Player then return false, "Player not found" end
    
    local playerMoney = Player.PlayerData.money.bank
    if playerMoney < farm.purchase_price then

        return false, "Insufficient funds"
    end
    
    -- Remove money and assign ownership
    Player.Functions.RemoveMoney('bank', farm.purchase_price, 'farm-purchase')
    MySQL.update.await('UPDATE ls_farms SET owner_citizenid = ? WHERE farm_id = ?', {citizenid, farmId})
    
    -- Initialize player farming record
    MySQL.insert.await('INSERT IGNORE INTO ls_farming_players (citizenid) VALUES (?)', {citizenid})
    
    return true, "Farm purchased successfully"
end

-- Crop Management Functions
local function PlantCrop(plotId, cropType, citizenid)
    local cropConfig = Config.Crops[cropType]
    if not cropConfig then return false, "Invalid crop type" end
    
    local plot = MySQL.single.await('SELECT * FROM ls_farm_plots WHERE id = ? AND (renter_citizenid = ? OR (SELECT owner_citizenid FROM ls_farms WHERE farm_id = ls_farm_plots.farm_id) = ?)', 
        {plotId, citizenid, citizenid})
    
    if not plot then return false, "Plot not accessible" end
    if plot.current_crop then return false, "Plot already has a crop" end
    
    local playerLevel = GetPlayerFarmingLevel(citizenid)
    if playerLevel < cropConfig.required_level then
        return false, "Insufficient farming level"
    end
    
    local expectedHarvest = os.date('%Y-%m-%d %H:%M:%S', os.time() + (cropConfig.grow_time * 60))
    
    -- Plant the crop
    MySQL.update.await('UPDATE ls_farm_plots SET current_crop = ?, planted_at = NOW(), growth_stage = ? WHERE id = ?', 
        {cropType, 'planted', plotId})
    
    -- Track crop growth
    MySQL.insert.await([[
        INSERT INTO ls_crop_tracking (plot_id, crop_type, planted_by, expected_harvest, expected_yield) 
        VALUES (?, ?, ?, ?, ?)
    ]], {plotId, cropType, citizenid, expectedHarvest, math.random(cropConfig.yield_per_plot.min, cropConfig.yield_per_plot.max)})
    
    -- Update player stats
    MySQL.update.await('UPDATE ls_farming_players SET crops_planted = crops_planted + 1, total_experience = total_experience + ? WHERE citizenid = ?', 
        {cropConfig.experience_gain, citizenid})
    
    return true, "Crop planted successfully"
end

local function HarvestCrop(plotId, citizenid)
    local crop = MySQL.single.await([[
        SELECT ct.*, fp.farm_id, c.crop_type as current_crop FROM ls_crop_tracking ct 
        JOIN ls_farm_plots fp ON ct.plot_id = fp.id 
        JOIN ls_farm_plots c ON c.id = fp.id
        WHERE ct.plot_id = ? AND ct.harvested_at IS NULL
        AND (fp.renter_citizenid = ? OR (SELECT owner_citizenid FROM ls_farms WHERE farm_id = fp.farm_id) = ?)
    ]], {plotId, citizenid, citizenid})
    
    if not crop then return false, "No crop to harvest or no access" end
    if crop.growth_stage ~= 'ready' then return false, "Crop not ready for harvest" end
    
    local cropConfig = Config.Crops[crop.crop_type]
    local harvestYield = math.min(crop.expected_yield, math.random(cropConfig.yield_per_plot.min, cropConfig.yield_per_plot.max))
    
    -- Mark as harvested
    MySQL.update.await('UPDATE ls_crop_tracking SET actual_yield = ?, harvested_at = NOW(), harvested_by = ? WHERE id = ?', 
        {harvestYield, citizenid, crop.id})
    
    -- Clear the plot
    MySQL.update.await('UPDATE ls_farm_plots SET current_crop = NULL, planted_at = NULL, growth_stage = NULL WHERE id = ?', {plotId})
    
    -- Add to farm storage
    MySQL.insert.await([[
        INSERT INTO ls_farm_storage (farm_id, item_type, item_name, quantity, quality) 
        VALUES (?, 'crop', ?, ?, 'good')
        ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)
    ]], {crop.farm_id, crop.crop_type, harvestYield})
    
    -- Update player stats and experience
    local experienceGain = cropConfig.experience_gain * 2 -- Double XP for harvesting
    MySQL.update.await([[
        UPDATE ls_farming_players 
        SET crops_harvested = crops_harvested + 1, total_experience = total_experience + ? 
        WHERE citizenid = ?
    ]], {experienceGain, citizenid})
    
    return true, string.format("Harvested %d kg of %s", harvestYield, cropConfig.name)
end

-- Utility Functions
function GetPlayerFarmingLevel(citizenid)
    local result = MySQL.single.await('SELECT farming_level FROM ls_farming_players WHERE citizenid = ?', {citizenid})
    return result and result.farming_level or 1
end

-- Crop Growth System
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        -- Update crop growth stages
        local growingCrops = MySQL.query.await([[
            SELECT ct.id, ct.crop_type, ct.planted_at, ct.growth_stage, ct.expected_harvest
            FROM ls_crop_tracking ct 
            WHERE ct.harvested_at IS NULL AND ct.growth_stage != 'ready'
        ]])
        
        for _, crop in pairs(growingCrops) do
            local cropConfig = Config.Crops[crop.crop_type]
            if cropConfig then
                local plantedTime = os.time{year=string.sub(crop.planted_at,1,4), month=string.sub(crop.planted_at,6,7), day=string.sub(crop.planted_at,9,10), hour=string.sub(crop.planted_at,12,13), min=string.sub(crop.planted_at,15,16), sec=string.sub(crop.planted_at,18,19)}
                local currentTime = os.time()
                local timeElapsed = (currentTime - plantedTime) / 60 -- minutes
                
                local totalGrowTime = cropConfig.grow_time
                local progressPercent = timeElapsed / totalGrowTime
                
                local newStage = crop.growth_stage
                if progressPercent >= 1.0 then
                    newStage = 'ready'
                elseif progressPercent >= 0.8 then
                    newStage = 'mature'
                elseif progressPercent >= 0.6 then
                    newStage = 'growing'
                elseif progressPercent >= 0.2 then
                    newStage = 'sprouting'
                end
                
                if newStage ~= crop.growth_stage then
                    MySQL.update.await('UPDATE ls_crop_tracking SET growth_stage = ? WHERE id = ?', {newStage, crop.id})
                    MySQL.update.await('UPDATE ls_farm_plots SET growth_stage = ? WHERE id = (SELECT plot_id FROM ls_crop_tracking WHERE id = ?)', {newStage, crop.id})
                end
            end
        end
    end
end)

-- Network Events
RegisterNetEvent('ls-farming:server:purchaseFarm', function(farmId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local success, message = PurchaseFarm(Player.PlayerData.citizenid, farmId)
    TriggerClientEvent('QBCore:Notify', src, message, success and "success" or "error")
    
    if success then
        TriggerClientEvent('ls-farming:client:updateFarms', src)
    end
end)

RegisterNetEvent('ls-farming:server:plantCrop', function(plotId, cropType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local success, message = PlantCrop(plotId, cropType, Player.PlayerData.citizenid)
    TriggerClientEvent('QBCore:Notify', src, message, success and "success" or "error")
    
    if success then
        TriggerClientEvent('ls-farming:client:updatePlot', src, plotId)
    end
end)

RegisterNetEvent('ls-farming:server:harvestCrop', function(plotId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local success, message = HarvestCrop(plotId, Player.PlayerData.citizenid)
    TriggerClientEvent('QBCore:Notify', src, message, success and "success" or "error")
    
    if success then
        TriggerClientEvent('ls-farming:client:updatePlot', src, plotId)
    end
end)

-- Server Callbacks
QBCore.Functions.CreateCallback('ls-farming:server:getPlayerFarms', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb({}) return end
    
    local farms = GetPlayerFarms(Player.PlayerData.citizenid)
    cb(farms)
end)

QBCore.Functions.CreateCallback('ls-farming:server:getFarmDetails', function(source, cb, farmId)
    local farm = GetFarmDetails(farmId)
    cb(farm)
end)

QBCore.Functions.CreateCallback('ls-farming:server:getPlayerStats', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb({}) return end
    
    local stats = MySQL.single.await('SELECT * FROM ls_farming_players WHERE citizenid = ?', {Player.PlayerData.citizenid})
    cb(stats or {farming_level = 1, total_experience = 0})
end)