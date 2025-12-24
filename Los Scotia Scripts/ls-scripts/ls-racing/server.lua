local QBCore = exports['qb-core']:GetCoreObject()

local activeRaces = {}
local raceIdCounter = 1

-- Create Race
RegisterNetEvent('ls-racing:server:createRace', function(raceType, buyIn)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if Player.PlayerData.money.cash < buyIn then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough cash for buy-in', 'error')
        return
    end
    
    -- Create new race
    local raceId = raceIdCounter
    raceIdCounter = raceIdCounter + 1
    
    -- Select a track based on race type
    local availableTracks = {}
    for trackName, trackData in pairs(Config.Tracks) do
        if trackData.type == raceType then
            table.insert(availableTracks, {name = trackName, data = trackData})
        end
    end
    
    if #availableTracks == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'No tracks available for this race type', 'error')
        return
    end
    
    local selectedTrack = availableTracks[math.random(#availableTracks)]
    
    activeRaces[raceId] = {
        id = raceId,
        creator = src,
        name = selectedTrack.data.name,
        type = raceType,
        track = selectedTrack.name,
        buyIn = buyIn,
        participants = {},
        started = false,
        checkpoints = selectedTrack.data.checkpoints,
        laps = selectedTrack.data.laps or 1,
        results = {}
    }
    
    TriggerClientEvent('ls-racing:client:raceCreated', src, activeRaces[raceId])
end)

-- Join Race
RegisterNetEvent('ls-racing:server:joinRace', function(raceId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not activeRaces[raceId] then
        TriggerClientEvent('QBCore:Notify', src, 'Race not found', 'error')
        return
    end
    
    local race = activeRaces[raceId]
    
    if race.started then
        TriggerClientEvent('QBCore:Notify', src, 'Race already started', 'error')
        return
    end
    
    if #race.participants >= Config.MaxRacers then
        TriggerClientEvent('QBCore:Notify', src, 'Race is full', 'error')
        return
    end
    
    -- Check if player already in race
    for _, participant in pairs(race.participants) do
        if participant.source == src then
            TriggerClientEvent('QBCore:Notify', src, 'You are already in this race', 'error')
            return
        end
    end
    
    if Player.PlayerData.money.cash < race.buyIn then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough cash for buy-in', 'error')
        return
    end
    
    -- Remove buy-in money
    Player.Functions.RemoveMoney('cash', race.buyIn)
    
    -- Add participant
    table.insert(race.participants, {
        source = src,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        finished = false,
        position = 0,
        time = 0
    })
    
    TriggerClientEvent('ls-racing:client:joinedRace', src, race)
    
    -- Notify all participants
    for _, participant in pairs(race.participants) do
        TriggerClientEvent('QBCore:Notify', participant.source, Player.PlayerData.charinfo.firstname .. ' joined the race', 'primary')
    end
end)

-- Start Race
RegisterNetEvent('ls-racing:server:startRace', function(raceId)
    local src = source
    local race = activeRaces[raceId]
    
    if not race then
        TriggerClientEvent('QBCore:Notify', src, 'Race not found', 'error')
        return
    end
    
    if race.creator ~= src then
        TriggerClientEvent('QBCore:Notify', src, 'Only the race creator can start the race', 'error')
        return
    end
    
    if #race.participants < Config.MinRacers then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough racers (minimum: ' .. Config.MinRacers .. ')', 'error')
        return
    end
    
    if race.started then
        TriggerClientEvent('QBCore:Notify', src, 'Race already started', 'error')
        return
    end
    
    race.started = true
    race.startTime = os.time()
    
    -- Start countdown
    for i = Config.CountdownTime, 1, -1 do
        for _, participant in pairs(race.participants) do
            TriggerClientEvent('QBCore:Notify', participant.source, 'Race starts in ' .. i, 'primary')
        end
        Wait(1000)
    end
    
    -- Start race
    for _, participant in pairs(race.participants) do
        TriggerClientEvent('ls-racing:client:raceStarted', participant.source, race)
    end
end)

-- Finish Race
RegisterNetEvent('ls-racing:server:finishRace', function(finishTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Find the race the player is in
    local playerRace = nil
    local participantIndex = nil
    
    for raceId, race in pairs(activeRaces) do
        if race.started then
            for i, participant in pairs(race.participants) do
                if participant.source == src and not participant.finished then
                    playerRace = race
                    participantIndex = i
                    break
                end
            end
        end
    end
    
    if not playerRace or not participantIndex then return end
    
    -- Mark participant as finished
    playerRace.participants[participantIndex].finished = true
    playerRace.participants[participantIndex].time = finishTime
    playerRace.participants[participantIndex].position = #playerRace.results + 1
    
    table.insert(playerRace.results, {
        source = src,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        time = finishTime,
        position = #playerRace.results + 1
    })
    
    -- Check if race is complete
    local allFinished = true
    for _, participant in pairs(playerRace.participants) do
        if not participant.finished then
            allFinished = false
            break
        end
    end
    
    if allFinished or #playerRace.results >= 3 then
        -- End race and distribute rewards
        EndRace(playerRace)
    else
        -- Notify other participants of finish
        for _, participant in pairs(playerRace.participants) do
            if participant.source ~= src then
                TriggerClientEvent('QBCore:Notify', participant.source, Player.PlayerData.charinfo.firstname .. ' finished in position ' .. #playerRace.results, 'primary')
            end
        end
    end
end)

-- Leave Race
RegisterNetEvent('ls-racing:server:leaveRace', function()
    local src = source
    
    -- Find and remove player from any active race
    for raceId, race in pairs(activeRaces) do
        for i, participant in pairs(race.participants) do
            if participant.source == src then
                table.remove(race.participants, i)
                TriggerClientEvent('ls-racing:client:leftRace', src)
                
                -- Notify other participants
                for _, otherParticipant in pairs(race.participants) do
                    TriggerClientEvent('QBCore:Notify', otherParticipant.source, participant.name .. ' left the race', 'error')
                end
                
                -- If race creator left, cancel race
                if race.creator == src and not race.started then
                    CancelRace(raceId)
                end
                
                return
            end
        end
    end
end)

-- Get Race List
RegisterNetEvent('ls-racing:server:getRaceList', function()
    local src = source
    local raceList = {}
    
    for raceId, race in pairs(activeRaces) do
        if not race.started then
            table.insert(raceList, {
                id = race.id,
                name = race.name,
                type = race.type,
                buyIn = race.buyIn,
                participants = race.participants
            })
        end
    end
    
    TriggerClientEvent('ls-racing:client:showRaceList', src, raceList)
end)

-- Helper Functions
function EndRace(race)
    -- Calculate and distribute rewards
    local totalPrize = race.buyIn * #race.participants
    local raceTypeData = Config.RaceTypes[race.type]
    
    for _, result in pairs(race.results) do
        local Player = QBCore.Functions.GetPlayer(result.source)
        if Player then
            local reward = 0
            
            if result.position == 1 then
                reward = raceTypeData.firstPlace
            elseif result.position == 2 then
                reward = raceTypeData.secondPlace
            elseif result.position == 3 then
                reward = raceTypeData.thirdPlace
            end
            
            if reward > 0 then
                Player.Functions.AddMoney('cash', reward)
                TriggerClientEvent('QBCore:Notify', result.source, 'You won $' .. reward .. ' for finishing ' .. GetOrdinal(result.position) .. '!', 'success')
            end
            
            -- Add racing reputation if enabled
            if Config.Reputation.enabled then
                local currentRep = Player.PlayerData.metadata.racing_rep or 0
                Player.Functions.SetMetaData('racing_rep', currentRep + 1)
                
                local newLevel = math.floor(currentRep / Config.Reputation.races_per_level)
                if Config.Reputation.bonuses[newLevel] then
                    local bonus = Config.Reputation.bonuses[newLevel]
                    Player.Functions.AddMoney('cash', bonus.money)
                    TriggerClientEvent('QBCore:Notify', result.source, bonus.message, 'success')
                end
            end
        end
    end
    
    -- Notify all participants of final results
    for _, participant in pairs(race.participants) do
        TriggerClientEvent('ls-racing:client:raceFinished', participant.source, race.results)
    end
    
    -- Remove race from active races
    activeRaces[race.id] = nil
end

function CancelRace(raceId)
    local race = activeRaces[raceId]
    if not race then return end
    
    -- Refund buy-ins
    for _, participant in pairs(race.participants) do
        local Player = QBCore.Functions.GetPlayer(participant.source)
        if Player then
            Player.Functions.AddMoney('cash', race.buyIn)
            TriggerClientEvent('QBCore:Notify', participant.source, 'Race cancelled - buy-in refunded', 'error')
            TriggerClientEvent('ls-racing:client:leftRace', participant.source)
        end
    end
    
    activeRaces[raceId] = nil
end

function GetOrdinal(number)
    local suffix = 'th'
    if number % 10 == 1 and number % 100 ~= 11 then
        suffix = 'st'
    elseif number % 10 == 2 and number % 100 ~= 12 then
        suffix = 'nd'
    elseif number % 10 == 3 and number % 100 ~= 13 then
        suffix = 'rd'
    end
    return number .. suffix
end

print("^2[LS-RACING]^7 Racing System loaded successfully!")