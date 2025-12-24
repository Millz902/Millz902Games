local QBCore = exports['qb-core']:GetCoreObject()
local currentVehicle = nil

-- Police Vehicle Spawning
CreateThread(function()
    for stationName, spawns in pairs(Config.VehicleSpawns) do
        for i, spawn in ipairs(spawns) do
            exports['qb-target']:AddBoxZone("police_vehicle_" .. stationName .. "_" .. i, spawn.coords.xyz, 3.0, 6.0, {
                name = "police_vehicle_" .. stationName .. "_" .. i,
                heading = spawn.coords.w,
                debugPoly = false,
                minZ = spawn.coords.z - 1,
                maxZ = spawn.coords.z + 3,
            }, {
                options = {
                    {
                        type = "client",
                        event = "ls-police:client:SpawnVehicle",
                        icon = "fas fa-car",
                        label = "Take Vehicle",
                        job = Config.PoliceJobs,
                        canInteract = function()
                            return exports['ls-police']:IsOnDuty()
                        end,
                        spawn = spawn
                    },
                    {
                        type = "client",
                        event = "ls-police:client:DeleteVehicle",
                        icon = "fas fa-times",
                        label = "Store Vehicle",
                        job = Config.PoliceJobs,
                        canInteract = function()
                            return exports['ls-police']:IsOnDuty() and IsPedInAnyVehicle(PlayerPedId(), false)
                        end
                    }
                },
                distance = 3.0
            })
        end
    end
end)

-- Vehicle Events
RegisterNetEvent('ls-police:client:SpawnVehicle', function(data)
    if not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You must be on duty to take a vehicle", "error")
        return
    end

    local spawn = data.spawn
    local isSpawnClear = IsSpawnPointClear(spawn.coords.xyz, 3.0)
    
    if not isSpawnClear then
        QBCore.Functions.Notify("Spawn point is blocked", "error")
        return
    end

    QBCore.Functions.SpawnVehicle(spawn.model, function(veh)
        SetVehicleNumberPlateText(veh, "LSPD" .. math.random(1000, 9999))
        SetEntityHeading(veh, spawn.coords.w)
        exports['qb-fuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true, false)
        currentVehicle = veh
        
        -- Add police equipment
        SetVehicleLivery(veh, 0)
        SetVehicleExtra(veh, 1, 0) -- Light bar
        SetVehicleExtra(veh, 2, 0) -- Push bar
        
        QBCore.Functions.Notify("Vehicle spawned", "success")
    end, spawn.coords.xyz, true)
end)

RegisterNetEvent('ls-police:client:DeleteVehicle', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    
    if veh == 0 then
        QBCore.Functions.Notify("You are not in a vehicle", "error")
        return
    end
    
    if not IsPoliceVehicle(veh) then
        QBCore.Functions.Notify("This is not a police vehicle", "error")
        return
    end
    
    QBCore.Functions.DeleteVehicle(veh)
    currentVehicle = nil
    QBCore.Functions.Notify("Vehicle stored", "success")
end)

-- Vehicle Functions
function IsSpawnPointClear(coords, radius)
    local vehicles = GetGamePool('CVehicle')
    for i = 1, #vehicles do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(coords - vehicleCoords)
        if distance < radius then
            return false
        end
    end
    return true
end

function IsPoliceVehicle(vehicle)
    local model = GetEntityModel(vehicle)
    local policeModels = {
        `police`, `police2`, `police3`, `police4`,
        `sheriff`, `sheriff2`, `fbi`, `fbi2`
    }
    
    for i = 1, #policeModels do
        if model == policeModels[i] then
            return true
        end
    end
    return false
end

-- ALPR System
CreateThread(function()
    while true do
        Wait(Config.ALPR.scanInterval)
        
        if exports['ls-police']:IsOnDuty() then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle ~= 0 and IsPoliceVehicle(vehicle) then
                ScanNearbyVehicles()
            end
        end
    end
end)

function ScanNearbyVehicles()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicles = GetGamePool('CVehicle')
    
    for i = 1, #vehicles do
        local veh = vehicles[i]
        local vehPos = GetEntityCoords(veh)
        local distance = #(pos - vehPos)
        
        if distance < Config.ALPR.scanDistance and veh ~= GetVehiclePedIsIn(ped, false) then
            local plate = QBCore.Functions.GetPlate(veh)
            TriggerServerEvent('ls-police:server:CheckVehicle', plate, vehPos)
        end
    end
end

-- Exports
exports('GetCurrentVehicle', function() return currentVehicle end)
exports('IsPoliceVehicle', IsPoliceVehicle)