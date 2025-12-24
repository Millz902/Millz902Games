local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentRace = nil
local inRace = false
local racePosition = 0
local checkpointsPassed = 0
local raceBlips = {}
local raceProps = {}

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Race Commands
RegisterCommand('createrace', function(source, args)
    if not args[1] or not Config.RaceTypes[args[1]] then
        QBCore.Functions.Notify('Usage: /createrace [street/drift/drag/circuit]', 'primary')
        return
    end
    
    local raceType = args[1]
    local buyIn = tonumber(args[2]) or Config.RaceTypes[raceType].buyIn
    
    TriggerServerEvent('ls-racing:server:createRace', raceType, buyIn)
end)

RegisterCommand('joinrace', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /joinrace [race_id]', 'primary')
        return
    end
    
    local raceId = tonumber(args[1])
    TriggerServerEvent('ls-racing:server:joinRace', raceId)
end)

RegisterCommand('startrace', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /startrace [race_id]', 'primary')
        return
    end
    
    local raceId = tonumber(args[1])
    TriggerServerEvent('ls-racing:server:startRace', raceId)
end)

RegisterCommand('leaverace', function()
    if not inRace then
        QBCore.Functions.Notify('You are not in a race', 'error')
        return
    end
    
    TriggerServerEvent('ls-racing:server:leaveRace')
end)

RegisterCommand('racelist', function()
    TriggerServerEvent('ls-racing:server:getRaceList')
end)

-- Racing Events
RegisterNetEvent('ls-racing:client:raceCreated', function(raceData)
    QBCore.Functions.Notify('Race created! ID: ' .. raceData.id .. ' | Type: ' .. raceData.type .. ' | Buy-in: $' .. raceData.buyIn, 'success')
end)

RegisterNetEvent('ls-racing:client:joinedRace', function(raceData)
    QBCore.Functions.Notify('Joined race: ' .. raceData.name .. ' | Buy-in: $' .. raceData.buyIn, 'success')
    currentRace = raceData
end)

RegisterNetEvent('ls-racing:client:raceStarted', function(raceData)
    if not currentRace or currentRace.id ~= raceData.id then return end
    
    inRace = true
    checkpointsPassed = 0
    racePosition = 0
    
    QBCore.Functions.Notify('Race started! Get to the first checkpoint!', 'success')
    
    -- Create race blips and checkpoints
    CreateRaceCheckpoints(raceData.checkpoints)
    
    -- Start race timer
    CreateThread(function()
        local startTime = GetGameTimer()
        while inRace do
            Wait(100)
            if currentRace then
                CheckRaceProgress()
            end
        end
    end)
end)

RegisterNetEvent('ls-racing:client:raceFinished', function(results)
    inRace = false
    currentRace = nil
    
    ClearRaceElements()
    
    local resultsText = 'Race Results:\n'
    for i, result in ipairs(results) do
        resultsText = resultsText .. i .. '. ' .. result.name .. ' - ' .. result.time .. 's\n'
    end
    
    QBCore.Functions.Notify(resultsText, 'primary')
end)

RegisterNetEvent('ls-racing:client:leftRace', function()
    inRace = false
    currentRace = nil
    ClearRaceElements()
    QBCore.Functions.Notify('Left the race', 'primary')
end)

RegisterNetEvent('ls-racing:client:showRaceList', function(races)
    if #races == 0 then
        QBCore.Functions.Notify('No active races', 'primary')
        return
    end
    
    local raceList = 'Active Races:\n'
    for _, race in pairs(races) do
        raceList = raceList .. 'ID: ' .. race.id .. ' | ' .. race.name .. ' | Players: ' .. #race.participants .. '/' .. Config.MaxRacers .. '\n'
    end
    
    QBCore.Functions.Notify(raceList, 'primary')
end)

-- Race Functions
function CreateRaceCheckpoints(checkpoints)
    ClearRaceElements()
    
    for i, checkpoint in ipairs(checkpoints) do
        local blip = AddBlipForCoord(checkpoint.x, checkpoint.y, checkpoint.z)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Checkpoint ' .. i)
        EndTextCommandSetBlipName(blip)
        table.insert(raceBlips, blip)
        
        -- Create checkpoint prop
        local prop = CreateObject(GetHashKey('prop_beachflag_01'), checkpoint.x, checkpoint.y, checkpoint.z, false, false, false)
        table.insert(raceProps, prop)
    end
    
    -- Highlight first checkpoint
    if raceBlips[1] then
        SetBlipRoute(raceBlips[1], true)
        SetBlipRouteColour(raceBlips[1], 5)
    end
end)

function CheckRaceProgress()
    if not currentRace or not inRace then return end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nextCheckpoint = checkpointsPassed + 1
    
    if nextCheckpoint <= #currentRace.checkpoints then
        local checkpoint = currentRace.checkpoints[nextCheckpoint]
        local distance = #(playerCoords - vector3(checkpoint.x, checkpoint.y, checkpoint.z))
        
        if distance <= Config.CheckpointRadius then
            checkpointsPassed = checkpointsPassed + 1
            QBCore.Functions.Notify('Checkpoint ' .. checkpointsPassed .. ' passed!', 'success')
            
            -- Update blip routing
            if raceBlips[nextCheckpoint] then
                SetBlipRoute(raceBlips[nextCheckpoint], false)
                RemoveBlip(raceBlips[nextCheckpoint])
            end
            
            if checkpointsPassed < #currentRace.checkpoints then
                local nextBlip = raceBlips[checkpointsPassed + 1]
                if nextBlip then
                    SetBlipRoute(nextBlip, true)
                    SetBlipRouteColour(nextBlip, 5)
                end
            else
                -- Race finished
                TriggerServerEvent('ls-racing:server:finishRace', GetGameTimer())
            end
        end
    end
end)

function ClearRaceElements()
    for _, blip in pairs(raceBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    
    for _, prop in pairs(raceProps) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    
    raceBlips = {}
    raceProps = {}
end)

-- Tuning Shop Blips
CreateThread(function()
    for _, shop in pairs(Config.TuningShops) do
        if shop.blip then
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
            SetBlipSprite(blip, 72)
            SetBlipColour(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(shop.name)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Export functions
exports('IsInRace', function()
    return inRace
end)

exports('GetCurrentRace', function()
    return currentRace
end)