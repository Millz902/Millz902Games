-- Los Scotia Vehicle Fix - Client Side
-- Fixes vehicle changing issues and enhances DLC vehicle integration

local QBCore = exports['qb-core']:GetCoreObject()

-- DLC Vehicles that should spawn in traffic
local dlcVehicles = {
    -- Sports Cars
    'adder', 'banshee2', 'bullet', 'cheetah', 'entityxf', 'infernus', 'jester', 'kuruma', 'massacro', 'turismo2',
    'zentorno', 'osiris', 't20', 'tyrus', 'reaper', 'sheava', 're7b', 'penetrator', 'tempesta', 'gp1',
    'nero', 'nero2', 'diabolus', 'specter', 'specter2', 'ruston', 'turismo2', 'infernus2', 'ruston',
    
    -- Super Cars
    'pfister811', 'prototipo', 'lynx', 'seven70', 'brioso', 'xa21', 'vagner', 'cheetah2', 'torero', 'visione',
    'sc1', 'autarch', 'entity2', 'cheburek', 'hotring', 'tyrant', 'entity3', 'jester3', 'flashgt', 'ellie',
    'michelli', 'fagaloa', 'swinger', 'patriot2', 'stafford', 'freecrawler', 'caracara', 'seasparrow',
    
    -- Luxury/Executive
    'cognoscenti', 'cognoscenti2', 'limo2', 'schafter2', 'schafter3', 'schafter4', 'schafter5', 'schafter6',
    'cog55', 'cog552', 'windsor', 'windsor2', 'feltzer3', 'luxor', 'luxor2', 'swift', 'swift2',
    
    -- Motorcycles  
    'akuma', 'bagger', 'bati', 'bati2', 'bf400', 'carbonrs', 'cliffhanger', 'daemon', 'daemon2', 'defiler',
    'enduro', 'esskey', 'faggio', 'faggio2', 'gargoyle', 'hakuchou', 'hakuchou2', 'hexer', 'innovation',
    'lectro', 'nemesis', 'nightblade', 'pcj', 'ruffian', 'sanchez', 'sanchez2', 'sovereign', 'thrust',
    'vader', 'vindicator', 'vortex', 'wolfsbane', 'zombiea', 'zombieb', 'diablous', 'diablous2', 'fcr',
    'fcr2', 'manchez', 'ratbike', 'shotaro', 'chimera', 'sanctus', 'avarus', 'deathbike', 'deathbike2'
}

-- Enhanced traffic vehicles (mix of base + DLC)
local trafficVehicles = {
    -- Base Game Traffic Enhanced
    'adder', 'bullet', 'cheetah', 'entityxf', 'infernus', 'vacca', 'voltic', 'monroe', 'ninef', 'ninef2',
    'alpha', 'banshee', 'bestiagts', 'blista2', 'buffalo', 'buffalo2', 'carbonizzare', 'comet2', 'coquette',
    'feltzer2', 'fusilade', 'futo', 'jester', 'khamelion', 'kuruma', 'massacro', 'penumbra', 'rapidgt',
    'rapidgt2', 'surano', 'tropos', 'verlierer2', 'sultan', 'sultanrs', 'elegy2', 'jester2', 'massacro2',
    
    -- DLC Additions
    'osiris', 't20', 'tyrus', 'reaper', 'sheava', 're7b', 'penetrator', 'tempesta', 'gp1', 'nero', 'nero2',
    'specter', 'specter2', 'ruston', 'turismo2', 'infernus2', 'pfister811', 'prototipo', 'lynx', 'seven70',
    'xa21', 'vagner', 'cheetah2', 'torero', 'visione', 'sc1', 'autarch', 'entity2', 'tyrant', 'entity3',
    'jester3', 'flashgt', 'ellie', 'michelli', 'fagaloa', 'swinger'
}

-- Fix vehicle changing/switching issues
local function FixVehicleIssues()
    -- Prevent vehicles from changing models randomly
    SetVehicleModelIsSuppressed(`POLICE`, false)
    SetVehicleModelIsSuppressed(`POLICE2`, false) 
    SetVehicleModelIsSuppressed(`POLICE3`, false)
    SetVehicleModelIsSuppressed(`POLICEB`, false)
    
    -- Enable all DLC vehicles
    for _, vehicle in pairs(dlcVehicles) do
        local hash = GetHashKey(vehicle)
        if IsModelValid(hash) then
            SetVehicleModelIsSuppressed(hash, false)
        end
    end
    
    -- Ensure proper vehicle streaming
    SetVehicleDensityMultiplierThisFrame(1.2)
    SetPedDensityMultiplierThisFrame(1.1)
    SetRandomVehicleDensityMultiplierThisFrame(1.3)
    SetParkedVehicleDensityMultiplierThisFrame(1.3)
    SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)
end

-- Enhanced DLC vehicle spawning in traffic
local function EnhanceDLCTraffic()
    CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            -- Spawn DLC vehicles in traffic around player
            for i = 1, 3 do -- Spawn 3 vehicles per cycle
                local randomVehicle = trafficVehicles[math.random(#trafficVehicles)]
                local hash = GetHashKey(randomVehicle)
                
                if IsModelValid(hash) then
                    RequestModel(hash)
                    local timeout = 0
                    while not HasModelLoaded(hash) and timeout < 100 do
                        Wait(10)
                        timeout = timeout + 1
                    end
                    
                    if HasModelLoaded(hash) then
                        -- Find a suitable spawn position
                        local spawnCoords = GetEntityCoords(playerPed)
                        local found, spawnPos, spawnHeading = GetNthClosestVehicleNodeWithHeading(spawnCoords.x + math.random(-200, 200), spawnCoords.y + math.random(-200, 200), spawnCoords.z, math.random(1, 10), 0, 0, 0)
                        
                        if found then
                            -- Create vehicle with driver
                            local vehicle = CreateVehicle(hash, spawnPos.x, spawnPos.y, spawnPos.z, spawnHeading, true, false)
                            if DoesEntityExist(vehicle) then
                                SetEntityAsNoLongerNeeded(vehicle)
                                
                                -- Create NPC driver
                                local driverModel = `s_m_y_business_01` -- Default business ped
                                RequestModel(driverModel)
                                local driverTimeout = 0
                                while not HasModelLoaded(driverModel) and driverTimeout < 50 do
                                    Wait(10)
                                    driverTimeout = driverTimeout + 1
                                end
                                
                                if HasModelLoaded(driverModel) then
                                    local driver = CreatePed(4, driverModel, spawnPos.x, spawnPos.y, spawnPos.z, spawnHeading, true, false)
                                    if DoesEntityExist(driver) then
                                        SetPedIntoVehicle(driver, vehicle, -1)
                                        SetEntityAsNoLongerNeeded(driver)
                                        TaskVehicleDriveWander(driver, vehicle, 25.0, 786603)
                                        SetModelAsNoLongerNeeded(driverModel)
                                    end
                                end
                            end
                        end
                        SetModelAsNoLongerNeeded(hash)
                    end
                end
            end
            
            Wait(15000) -- Spawn new vehicles every 15 seconds
        end
    end)
end

-- Main vehicle system initialization
CreateThread(function()
    Wait(5000) -- Wait for everything to load
    
    print("^2[LS-VEHICLE] Initializing vehicle fix system...^7")
    
    -- Apply vehicle fixes
    FixVehicleIssues()
    
    -- Start enhanced DLC traffic system
    EnhanceDLCTraffic()
    
    print("^2[LS-VEHICLE] Vehicle fix and DLC integration loaded!^7")
end)

-- Continuous vehicle fixes
CreateThread(function()
    while true do
        FixVehicleIssues()
        Wait(30000) -- Apply fixes every 30 seconds
    end
end)

-- Commands for vehicle management
RegisterCommand('fixvehicles', function()
    FixVehicleIssues()
    if QBCore then
        QBCore.Functions.Notify('Vehicle system reset!', 'success')
    else
        print("^2Vehicle system has been reset!^7")
    end
end, false)

RegisterCommand('spawntraffic', function()
    -- Force spawn some traffic vehicles
    for i = 1, 5 do
        local randomVehicle = trafficVehicles[math.random(#trafficVehicles)]
        local hash = GetHashKey(randomVehicle)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        if IsModelValid(hash) then
            RequestModel(hash)
            while not HasModelLoaded(hash) do Wait(10) end
            
            local found, spawnPos, spawnHeading = GetNthClosestVehicleNodeWithHeading(playerCoords.x + math.random(-100, 100), playerCoords.y + math.random(-100, 100), playerCoords.z, i, 0, 0, 0)
            if found then
                local vehicle = CreateVehicle(hash, spawnPos.x, spawnPos.y, spawnPos.z, spawnHeading, true, false)
                SetEntityAsNoLongerNeeded(vehicle)
            end
            SetModelAsNoLongerNeeded(hash)
        end
    end
    
    if QBCore then
        QBCore.Functions.Notify('Traffic vehicles spawned!', 'success')
    else
        print("^2Traffic vehicles spawned!^7")
    end
end, false)

print("^2[LS-VEHICLE] Vehicle fix system loaded - Use /fixvehicles or /spawntraffic^7")