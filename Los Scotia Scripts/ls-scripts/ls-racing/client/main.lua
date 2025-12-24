local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

-- Variables
local currentRace = nil
local inRace = false
local raceCheckpoints = {}
local raceBlips = {}
local raceRoute = {}

-- Initialize
CreateThread(function()
    while not QBCore do
        Wait(10)
    end
    
    PlayerData = QBCore.Functions.GetPlayerData()
    
    -- Load racing system
    LoadRacingSystem()
    
    -- Create race blips
    CreateRaceBlips()
end)

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    LoadRacingSystem()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    RemoveRaceBlips()
end)

RegisterNetEvent('ls-racing:client:UpdateRaceData', function(raceData)
    currentRace = raceData
    UpdateRaceInterface()
end)

RegisterNetEvent('ls-racing:client:JoinRace', function(raceId)
    TriggerServerEvent('ls-racing:server:JoinRace', raceId)
end)

RegisterNetEvent('ls-racing:client:LeaveRace', function()
    if currentRace then
        TriggerServerEvent('ls-racing:server:LeaveRace', currentRace.id)
        currentRace = nil
        inRace = false
        ClearRaceData()
    end
end)

RegisterNetEvent('ls-racing:client:StartRace', function(raceData)
    currentRace = raceData
    inRace = true
    
    QBCore.Functions.Notify('Race is starting! Get ready!', 'primary', 5000)
    
    -- Setup race checkpoints
    SetupRaceCheckpoints(raceData.checkpoints)
    
    -- Start race countdown
    StartRaceCountdown()
end)

RegisterNetEvent('ls-racing:client:EndRace', function(results)
    inRace = false
    currentRace = nil
    
    -- Show race results
    ShowRaceResults(results)
    
    -- Clear race data
    ClearRaceData()
end)

RegisterNetEvent('ls-racing:client:RaceCountdown', function(count)
    if count > 0 then
        QBCore.Functions.Notify('Race starts in: ' .. count, 'primary', 1000)
        PlaySoundFrontend(-1, "CHECKPOINT_NORMAL", "HUD_MINI_GAME_SOUNDSET", 1)
    else
        QBCore.Functions.Notify('GO! GO! GO!', 'success', 3000)
        PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", 1)
    end
end)

RegisterNetEvent('ls-racing:client:CheckpointPassed', function(checkpointId, position)
    QBCore.Functions.Notify('Checkpoint ' .. checkpointId .. ' passed! Position: ' .. position, 'success', 2000)
    PlaySoundFrontend(-1, "CHECKPOINT_NORMAL", "HUD_MINI_GAME_SOUNDSET", 1)
    
    -- Remove passed checkpoint
    RemoveCheckpoint(checkpointId)
    
    -- Add next checkpoint if exists
    if checkpointId < #raceCheckpoints then
        AddCheckpoint(checkpointId + 1)
    end
end)

RegisterNetEvent('ls-racing:client:RefreshRaces', function(races)
    RemoveRaceBlips()
    CreateRaceBlipsFromData(races)
end)

RegisterNetEvent('ls-racing:client:CreateRace', function(raceData)
    QBCore.Functions.Notify('New race created: ' .. raceData.name, 'success')
    CreateRaceBlip(raceData)
end)

-- Functions
function LoadRacingSystem()
    -- Request race data from server
    TriggerServerEvent('ls-racing:server:GetRaces')
    
    -- Setup racing commands
    SetupRacingCommands()
    
    -- Setup racing interactions
    SetupRacingInteractions()
end

function SetupRacingCommands()
    -- Racing commands
    RegisterCommand('race', function(source, args, rawCommand)
        OpenRacingMenu()
    end, false)
    
    RegisterCommand('joinrace', function(source, args, rawCommand)
        if args[1] then
            TriggerServerEvent('ls-racing:server:JoinRace', tonumber(args[1]))
        else
            QBCore.Functions.Notify('Usage: /joinrace [race_id]', 'error')
        end
    end, false)
    
    RegisterCommand('leaverace', function(source, args, rawCommand)
        if currentRace then
            TriggerServerEvent('ls-racing:server:LeaveRace', currentRace.id)
            currentRace = nil
            inRace = false
            ClearRaceData()
        else
            QBCore.Functions.Notify('You are not in a race', 'error')
        end
    end, false)
    
    RegisterCommand('createrace', function(source, args, rawCommand)
        if args[1] then
            StartRaceCreation(args[1])
        else
            QBCore.Functions.Notify('Usage: /createrace [race_name]', 'error')
        end
    end, false)
    
    RegisterCommand('racestats', function(source, args, rawCommand)
        TriggerServerEvent('ls-racing:server:GetRaceStats')
    end, false)
end

function SetupRacingInteractions()
    -- Race start line interaction
    exports['qb-target']:AddBoxZone("race_start", vector3(0, 0, 0), 10.0, 10.0, {
        name = "race_start",
        heading = 0,
        debugPoly = false,
        minZ = -2.0,
        maxZ = 2.0,
    }, {
        options = {
            {
                type = "client",
                event = "ls-racing:client:RaceStartInteraction",
                icon = "fas fa-flag-checkered",
                label = "Race Controls",
            },
        },
        distance = 5.0
    })
    
    -- Vehicle setup area
    exports['qb-target']:AddBoxZone("race_setup", vector3(0, 0, 0), 15.0, 15.0, {
        name = "race_setup",
        heading = 0,
        debugPoly = false,
        minZ = -2.0,
        maxZ = 2.0,
    }, {
        options = {
            {
                type = "client",
                event = "ls-racing:client:VehicleSetup",
                icon = "fas fa-wrench",
                label = "Vehicle Setup",
            },
        },
        distance = 5.0
    })
end

function CreateRaceBlips()
    TriggerServerEvent('ls-racing:server:GetRaces')
end

function CreateRaceBlipsFromData(races)
    for raceId, raceData in pairs(races) do
        CreateRaceBlip(raceData)
    end
end

function CreateRaceBlip(raceData)
    local blip = AddBlipForCoord(raceData.startCoords.x, raceData.startCoords.y, raceData.startCoords.z)
    SetBlipSprite(blip, 315)  -- Race flag
    SetBlipColour(blip, 1)    -- Red
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(raceData.name .. ' Race')
    EndTextCommandSetBlipName(blip)
    
    raceBlips[raceData.id] = blip
end

function RemoveRaceBlips()
    for _, blip in pairs(raceBlips) do
        RemoveBlip(blip)
    end
    raceBlips = {}
end

function SetupRaceCheckpoints(checkpoints)
    raceCheckpoints = checkpoints
    
    -- Add first checkpoint
    if #checkpoints > 0 then
        AddCheckpoint(1)
    end
end

function AddCheckpoint(checkpointId)
    local checkpoint = raceCheckpoints[checkpointId]
    if not checkpoint then return end
    
    local checkpointBlip = AddBlipForCoord(checkpoint.x, checkpoint.y, checkpoint.z)
    SetBlipSprite(checkpointBlip, 1)  -- Checkpoint
    SetBlipColour(checkpointBlip, 5)  -- Yellow
    SetBlipScale(checkpointBlip, 1.0)
    SetBlipRoute(checkpointBlip, true)
    SetBlipRouteColour(checkpointBlip, 5)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Checkpoint ' .. checkpointId)
    EndTextCommandSetBlipName(checkpointBlip)
    
    -- Create checkpoint marker
    local checkpointMarker = CreateCheckpoint(
        1, -- type
        checkpoint.x, checkpoint.y, checkpoint.z, -- pos
        checkpoint.x, checkpoint.y, checkpoint.z + 10.0, -- next pos
        10.0, -- radius
        255, 255, 0, 100, -- rgba
        0 -- reserved
    )
    
    raceRoute[checkpointId] = {
        blip = checkpointBlip,
        marker = checkpointMarker
    }
end

function RemoveCheckpoint(checkpointId)
    if raceRoute[checkpointId] then
        RemoveBlip(raceRoute[checkpointId].blip)
        DeleteCheckpoint(raceRoute[checkpointId].marker)
        raceRoute[checkpointId] = nil
    end
end

function ClearRaceData()
    -- Remove all checkpoints and blips
    for checkpointId, _ in pairs(raceRoute) do
        RemoveCheckpoint(checkpointId)
    end
    raceRoute = {}
    raceCheckpoints = {}
end

function StartRaceCountdown()
    local countdown = 5
    
    CreateThread(function()
        while countdown > 0 do
            TriggerEvent('ls-racing:client:RaceCountdown', countdown)
            countdown = countdown - 1
            Wait(1000)
        end
        
        TriggerEvent('ls-racing:client:RaceCountdown', 0)
    end)
end

function ShowRaceResults(results)
    local resultsMenu = {
        {
            header = 'Race Results',
            isMenuHeader = true
        }
    }
    
    for i, result in ipairs(results) do
        table.insert(resultsMenu, {
            header = i .. '. ' .. result.name,
            txt = 'Time: ' .. result.time .. 's | Vehicle: ' .. result.vehicle,
            icon = 'fas fa-trophy',
            isMenuHeader = true
        })
    end
    
    table.insert(resultsMenu, {
        header = 'Close Results',
        txt = '',
        icon = 'fas fa-times',
        params = {
            event = 'qb-menu:client:closeMenu'
        }
    })
    
    exports['qb-menu']:openMenu(resultsMenu)
end

function OpenRacingMenu()
    local racingMenu = {
        {
            header = 'Racing Menu',
            isMenuHeader = true
        },
        {
            header = 'Available Races',
            txt = 'View and join available races',
            icon = 'fas fa-list',
            params = {
                event = 'ls-racing:client:ViewAvailableRaces'
            }
        },
        {
            header = 'Create Race',
            txt = 'Create a new race',
            icon = 'fas fa-plus',
            params = {
                event = 'ls-racing:client:CreateRaceMenu'
            }
        },
        {
            header = 'Race History',
            txt = 'View your racing statistics',
            icon = 'fas fa-history',
            params = {
                event = 'ls-racing:client:ViewRaceHistory'
            }
        },
        {
            header = 'Leaderboards',
            txt = 'View racing leaderboards',
            icon = 'fas fa-trophy',
            params = {
                event = 'ls-racing:client:ViewLeaderboards'
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
    
    exports['qb-menu']:openMenu(racingMenu)
end

function StartRaceCreation(raceName)
    QBCore.Functions.Notify('Race creation started. Drive to set checkpoints. Use /addcheckpoint when ready.', 'primary', 8000)
    
    -- Initialize race creation data
    CreateThread(function()
        local raceData = {
            name = raceName,
            checkpoints = {},
            startCoords = GetEntityCoords(PlayerPedId())
        }
        
        -- Setup race creation commands
        RegisterCommand('addcheckpoint', function()
            local coords = GetEntityCoords(PlayerPedId())
            table.insert(raceData.checkpoints, {x = coords.x, y = coords.y, z = coords.z})
            QBCore.Functions.Notify('Checkpoint ' .. #raceData.checkpoints .. ' added', 'success')
        end, false)
        
        RegisterCommand('finishrace', function()
            if #raceData.checkpoints < 3 then
                QBCore.Functions.Notify('Race must have at least 3 checkpoints', 'error')
                return
            end
            
            TriggerServerEvent('ls-racing:server:CreateRace', raceData)
            QBCore.Functions.Notify('Race created successfully!', 'success')
        end, false)
        
        RegisterCommand('cancelrace', function()
            QBCore.Functions.Notify('Race creation cancelled', 'error')
        end, false)
    end)
end

-- Race Events
RegisterNetEvent('ls-racing:client:RaceStartInteraction', function()
    if currentRace and PlayerData.citizenid == currentRace.host then
        OpenRaceHostMenu()
    else
        OpenRaceParticipantMenu()
    end
end)

RegisterNetEvent('ls-racing:client:VehicleSetup', function()
    OpenVehicleSetupMenu()
end)

RegisterNetEvent('ls-racing:client:ViewAvailableRaces', function()
    TriggerServerEvent('ls-racing:server:GetAvailableRaces')
end)

RegisterNetEvent('ls-racing:client:CreateRaceMenu', function()
    local input = exports['qb-input']:ShowInput({
        header = "Create New Race",
        submitText = "Start Creation",
        inputs = {
            {
                text = "Race Name",
                name = "name",
                type = "text",
                isRequired = true,
            },
            {
                text = "Entry Fee ($)",
                name = "fee",
                type = "number",
                isRequired = false,
            }
        },
    })
    
    if input and input.name then
        StartRaceCreation(input.name)
    end
end)

RegisterNetEvent('ls-racing:client:ViewRaceHistory', function()
    TriggerServerEvent('ls-racing:server:GetRaceHistory')
end)

RegisterNetEvent('ls-racing:client:ViewLeaderboards', function()
    TriggerServerEvent('ls-racing:server:GetLeaderboards')
end)

function OpenRaceHostMenu()
    local hostMenu = {
        {
            header = 'Race Host Controls',
            isMenuHeader = true
        },
        {
            header = 'Start Race',
            txt = 'Begin the race countdown',
            icon = 'fas fa-play',
            params = {
                event = 'ls-racing:server:StartRace',
                args = { raceId = currentRace.id }
            }
        },
        {
            header = 'Cancel Race',
            txt = 'Cancel the current race',
            icon = 'fas fa-times',
            params = {
                event = 'ls-racing:server:CancelRace',
                args = { raceId = currentRace.id }
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
    
    exports['qb-menu']:openMenu(hostMenu)
end

function OpenRaceParticipantMenu()
    local participantMenu = {
        {
            header = 'Race Participant Menu',
            isMenuHeader = true
        },
        {
            header = 'Leave Race',
            txt = 'Leave the current race',
            icon = 'fas fa-sign-out-alt',
            params = {
                event = 'ls-racing:client:LeaveRace'
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
    
    exports['qb-menu']:openMenu(participantMenu)
end

function OpenVehicleSetupMenu()
    local vehicleMenu = {
        {
            header = 'Vehicle Setup',
            isMenuHeader = true
        },
        {
            header = 'Repair Vehicle',
            txt = 'Fully repair your vehicle',
            icon = 'fas fa-wrench',
            params = {
                event = 'ls-racing:client:RepairVehicle'
            }
        },
        {
            header = 'Refuel Vehicle',
            txt = 'Fill up your tank',
            icon = 'fas fa-gas-pump',
            params = {
                event = 'ls-racing:client:RefuelVehicle'
            }
        },
        {
            header = 'Tune Vehicle',
            txt = 'Optimize performance',
            icon = 'fas fa-tachometer-alt',
            params = {
                event = 'ls-racing:client:TuneVehicle'
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
    
    exports['qb-menu']:openMenu(vehicleMenu)
end

RegisterNetEvent('ls-racing:client:RepairVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SetVehicleFixed(vehicle)
        QBCore.Functions.Notify('Vehicle repaired!', 'success')
    else
        QBCore.Functions.Notify('You must be in a vehicle', 'error')
    end
end)

RegisterNetEvent('ls-racing:client:RefuelVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SetVehicleFuelLevel(vehicle, 100.0)
        QBCore.Functions.Notify('Vehicle refueled!', 'success')
    else
        QBCore.Functions.Notify('You must be in a vehicle', 'error')
    end
end)

RegisterNetEvent('ls-racing:client:TuneVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        -- Apply max upgrades
        SetVehicleModKit(vehicle, 0)
        for i = 0, 49 do
            local modCount = GetNumVehicleMods(vehicle, i)
            if modCount > 0 then
                SetVehicleMod(vehicle, i, modCount - 1, false)
            end
        end
        QBCore.Functions.Notify('Vehicle tuned!', 'success')
    else
        QBCore.Functions.Notify('You must be in a vehicle', 'error')
    end
end)