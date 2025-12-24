local QBCore = exports['qb-core']:GetCoreObject()

-- ================================================
-- VARIABLES
-- ================================================

local PlayerData = {}
local isOnDuty = false
local isHandcuffed = false
local draggedBy = nil
local dragging = nil
local currentGarage = nil
local currentArmory = nil
local backupBlips = {}

-- ================================================
-- EVENTS
-- ================================================

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job and PlayerData.job.type == 'leo' then
        isOnDuty = PlayerData.job.onduty
        TriggerServerEvent('ls-police:server:UpdateDutyStatus', isOnDuty)
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    if JobInfo.type == 'leo' then
        isOnDuty = JobInfo.onduty
        TriggerServerEvent('ls-police:server:UpdateDutyStatus', isOnDuty)
    else
        isOnDuty = false
    end
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    isOnDuty = duty
    TriggerServerEvent('ls-police:server:UpdateDutyStatus', isOnDuty)
end)

-- ================================================
-- POLICE STATIONS
-- ================================================

CreateThread(function()
    for _, station in pairs(Config.PoliceStations) do
        -- Create blip
        local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
        SetBlipSprite(blip, 60)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(station.label)
        EndTextCommandSetBlipName(blip)
        
        -- Duty toggle target
        exports['qb-target']:AddBoxZone('police_duty_' .. station.name, station.coords, 2.0, 2.0, {
            name = 'police_duty_' .. station.name,
            heading = station.heading,
            debugPoly = false,
        }, {
            options = {
                {
                    type = 'client',
                    event = 'ls-police:client:ToggleDuty',
                    icon = 'fas fa-clipboard',
                    label = 'Toggle Duty',
                    job = Config.PoliceJobs,
                }
            },
            distance = 2.0
        })
        
        -- Garage target
        if station.garage then
            exports['qb-target']:AddBoxZone('police_garage_' .. station.name, station.garage.coords, 3.0, 3.0, {
                name = 'police_garage_' .. station.name,
                heading = station.garage.heading,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'ls-police:client:OpenGarage',
                        icon = 'fas fa-car',
                        label = 'Police Garage',
                        job = Config.PoliceJobs,
                        garage = station.name
                    }
                },
                distance = 3.0
            })
        end
        
        -- Armory target
        if station.armory then
            exports['qb-target']:AddBoxZone('police_armory_' .. station.name, station.armory.coords, 2.0, 2.0, {
                name = 'police_armory_' .. station.name,
                heading = station.armory.heading,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'ls-police:client:OpenArmory',
                        icon = 'fas fa-gun',
                        label = 'Armory',
                        job = Config.PoliceJobs,
                        armory = station.name
                    }
                },
                distance = 2.0
            })
        end
    end
end)

-- ================================================
-- HANDCUFF SYSTEM
-- ================================================

RegisterNetEvent('ls-police:client:GetCuffed', function(playerId, isSoftcuff)
    local ped = PlayerPedId()
    if not isHandcuffed then
        isHandcuffed = true
        TriggerServerEvent('ls-police:server:SetHandcuffStatus', true)
        ClearPedTasksImmediately(ped)
        if GetSelectedPedWeapon(ped) ~= `WEAPON_UNARMED` then
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        end
        if not isSoftcuff then
            SetEnableHandcuffs(ped, true)
            SetPedCanPlayGestureAnims(ped, false)
            FreezeEntityPosition(ped, true)
        else
            SetEnableHandcuffs(ped, false)
            SetPedCanPlayGestureAnims(ped, true)
            FreezeEntityPosition(ped, false)
        end
        DisablePlayerFiring(ped, true)
        SetPedPathCanUseLadders(ped, false)
        SetPedPathCanDropFromHeight(ped, false)
        SetPedPathAvoidFire(ped, true)
    else
        isHandcuffed = false
        TriggerServerEvent('ls-police:server:SetHandcuffStatus', false)
        ClearPedTasksImmediately(ped)
        SetEnableHandcuffs(ped, false)
        SetPedCanPlayGestureAnims(ped, true)
        FreezeEntityPosition(ped, false)
        SetPedPathCanUseLadders(ped, true)
        SetPedPathCanDropFromHeight(ped, true)
        SetPedPathAvoidFire(ped, false)
    end
end)

RegisterNetEvent('ls-police:client:CuffPlayer', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local player, distance = QBCore.Functions.GetClosestPlayer(coords)
    
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if not QBCore.Functions.HasItem('handcuffs') then
            QBCore.Functions.Notify('You need handcuffs!', 'error')
            return
        end
        TriggerServerEvent('ls-police:server:CuffPlayer', playerId, false)
    else
        QBCore.Functions.Notify('No player nearby!', 'error')
    end
end)

RegisterNetEvent('ls-police:client:UnCuffPlayer', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local player, distance = QBCore.Functions.GetClosestPlayer(coords)
    
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        TriggerServerEvent('ls-police:server:UnCuffPlayer', playerId)
    else
        QBCore.Functions.Notify('No player nearby!', 'error')
    end
end)

-- ================================================
-- DRAGGING SYSTEM
-- ================================================

RegisterNetEvent('ls-police:client:GetDragged', function(playerId)
    draggedBy = playerId
end)

RegisterNetEvent('ls-police:client:DragPlayer', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local player, distance = QBCore.Functions.GetClosestPlayer(coords)
    
    if player ~= -1 and distance < 2.5 then
        local playerId = GetPlayerServerId(player)
        if dragging then
            dragging = nil
            TriggerServerEvent('ls-police:server:DragPlayer', playerId, false)
        else
            dragging = playerId
            TriggerServerEvent('ls-police:server:DragPlayer', playerId, true)
        end
    else
        QBCore.Functions.Notify('No player nearby!', 'error')
    end
end)

CreateThread(function()
    while true do
        if draggedBy then
            local ped = PlayerPedId()
            local dragger = GetPlayerPed(GetPlayerFromServerId(draggedBy))
            local coords = GetEntityCoords(dragger)
            
            if #(GetEntityCoords(ped) - coords) > 50 then
                draggedBy = nil
            end
            
            SetEntityCoords(ped, coords.x, coords.y, coords.z)
        end
        Wait(draggedBy and 16 or 1000)
    end
end)

-- ================================================
-- GARAGE SYSTEM
-- ================================================

RegisterNetEvent('ls-police:client:OpenGarage', function(data)
    local stationName = data.garage
    local station = Config.PoliceStations[stationName]
    
    if not station or not station.garage then
        QBCore.Functions.Notify('Garage not available!', 'error')
        return
    end
    
    local vehicles = {}
    for vehicle, data in pairs(Config.Vehicles) do
        if data.rank <= PlayerData.job.grade.level then
            table.insert(vehicles, {
                header = data.label,
                txt = string.format('Rank Required: %d | Top Speed: %d mph', data.rank, data.topSpeed or 120),
                params = {
                    event = 'ls-police:client:SpawnVehicle',
                    args = {
                        vehicle = vehicle,
                        coords = station.garage.spawn,
                        heading = station.garage.heading
                    }
                }
            })
        end
    end
    
    exports['qb-menu']:openMenu(vehicles)
end)

RegisterNetEvent('ls-police:client:SpawnVehicle', function(data)
    local vehicle = data.vehicle
    local coords = data.coords
    local heading = data.heading
    
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        SetVehicleNumberPlateText(veh, 'LSPD'..tostring(math.random(1000, 9999)))
        exports['qb-fuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetVehicleEngineOn(veh, true, true, false)
        SetVehicleDirtLevel(veh, 0.0)
        TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
    end, coords, true)
end)

-- ================================================
-- ARMORY SYSTEM
-- ================================================

RegisterNetEvent('ls-police:client:OpenArmory', function(data)
    local stationName = data.armory
    local station = Config.PoliceStations[stationName]
    
    if not station or not station.armory then
        QBCore.Functions.Notify('Armory not available!', 'error')
        return
    end
    
    local weapons = {}
    for weapon, data in pairs(Config.Weapons) do
        if data.rank <= PlayerData.job.grade.level then
            table.insert(weapons, {
                header = data.label,
                txt = string.format('Rank Required: %d | Ammo: %d', data.rank, data.ammo or 250),
                params = {
                    event = 'ls-police:client:GiveWeapon',
                    args = {
                        weapon = weapon,
                        ammo = data.ammo or 250
                    }
                }
            })
        end
    end
    
    exports['qb-menu']:openMenu(weapons)
end)

RegisterNetEvent('ls-police:client:GiveWeapon', function(data)
    local weapon = data.weapon
    local ammo = data.ammo
    
    TriggerServerEvent('QBCore:Server:AddItem', weapon, 1)
    TriggerServerEvent('QBCore:Server:AddItem', 'pistol_ammo', math.floor(ammo / 50))
end)

-- ================================================
-- DUTY SYSTEM
-- ================================================

RegisterNetEvent('ls-police:client:ToggleDuty', function()
    TriggerServerEvent('QBCore:ToggleDuty')
end)

-- ================================================
-- BACKUP SYSTEM
-- ================================================

RegisterNetEvent('ls-police:client:ShowBackupRequest', function(coords, code, callsign)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 60)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, code == 1 and 1 or code == 2 and 5 or 3)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(string.format('Code %d Backup - %s', code, callsign))
    EndTextCommandSetBlipName(blip)
    
    table.insert(backupBlips, blip)
    
    -- Remove blip after 5 minutes
    SetTimeout(300000, function()
        RemoveBlip(blip)
        for i, b in ipairs(backupBlips) do
            if b == blip then
                table.remove(backupBlips, i)
                break
            end
        end
    end)
    
    -- Send dispatch notification
    local priorityText = code == 1 and 'EMERGENCY' or code == 2 and 'HIGH PRIORITY' or 'ROUTINE'
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {'[DISPATCH]', string.format('%s backup requested by %s', priorityText, callsign)}
    })
end)

-- ================================================
-- UTILITY FUNCTIONS
-- ================================================

local function IsPoliceJob()
    if not PlayerData.job then return false end
    for _, job in pairs(Config.PoliceJobs) do
        if PlayerData.job.name == job then
            return true
        end
    end
    return false
end

local function IsOnDuty()
    return isOnDuty and IsPoliceJob()
end

-- ================================================
-- EXPORTS
-- ================================================

exports('IsPoliceJob', IsPoliceJob)
exports('IsOnDuty', IsOnDuty)
exports('IsHandcuffed', function() return isHandcuffed end)
exports('IsDragging', function() return dragging ~= nil end)
exports('IsDragged', function() return draggedBy ~= nil end)