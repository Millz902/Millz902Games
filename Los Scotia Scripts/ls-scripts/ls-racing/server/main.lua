local QBCore = exports['qb-core']:GetCoreObject()

-- Variables
local races = {}
local activeRaces = {}
local raceParticipants = {}
local raceResults = {}
local raceStats = {}

-- Initialize racing system
CreateThread(function()
    LoadRaces()
    LoadRaceStats()
end)

-- Events
RegisterNetEvent('ls-racing:server:GetRaces', function()
    local src = source
    TriggerClientEvent('ls-racing:client:RefreshRaces', src, races)
end)

RegisterNetEvent('ls-racing:server:CreateRace', function(raceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Generate unique race ID
    local raceId = 'race_' .. math.random(10000, 99999)
    
    local newRace = {
        id = raceId,
        name = raceData.name,
        host = Player.PlayerData.citizenid,
        hostName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        startCoords = raceData.startCoords,
        checkpoints = raceData.checkpoints,
        entryFee = raceData.fee or 0,
        maxParticipants = raceData.maxParticipants or 8,
        laps = raceData.laps or 1,
        vehicleClass = raceData.vehicleClass or 'any',
        created = os.time(),
        status = 'waiting' -- waiting, active, finished
    }
    
    races[raceId] = newRace
    activeRaces[raceId] = {
        participants = {},
        started = false,
        startTime = nil,
        results = {}
    }
    
    -- Save to database
    SaveRaceData(raceId, newRace)
    
    TriggerClientEvent('QBCore:Notify', src, 'Race created successfully! ID: ' .. raceId, 'success')
    TriggerClientEvent('ls-racing:client:CreateRace', -1, newRace)
end)

RegisterNetEvent('ls-racing:server:JoinRace', function(raceId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local race = races[raceId]
    if not race then
        TriggerClientEvent('QBCore:Notify', src, 'Race not found', 'error')
        return
    end
    
    local activeRace = activeRaces[raceId]
    if not activeRace then
        TriggerClientEvent('QBCore:Notify', src, 'Race is not active', 'error')
        return
    end
    
    if activeRace.started then
        TriggerClientEvent('QBCore:Notify', src, 'Race has already started', 'error')
        return
    end
    
    -- Check if player is already in race
    for _, participant in pairs(activeRace.participants) do
        if participant.citizenid == Player.PlayerData.citizenid then
            TriggerClientEvent('QBCore:Notify', src, 'You are already in this race', 'error')
            return
        end
    end
    
    -- Check participant limit
    if #activeRace.participants >= race.maxParticipants then
        TriggerClientEvent('QBCore:Notify', src, 'Race is full', 'error')
        return
    end
    
    -- Check entry fee
    if race.entryFee > 0 then
        if Player.PlayerData.money.cash < race.entryFee then
            TriggerClientEvent('QBCore:Notify', src, 'Insufficient funds for entry fee', 'error')
            return
        end
        Player.Functions.RemoveMoney('cash', race.entryFee)
    end
    
    -- Add participant
    table.insert(activeRace.participants, {
        src = src,
        citizenid = Player.PlayerData.citizenid,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        vehicle = GetEntityModel(GetVehiclePedIsIn(GetPlayerPed(src), false)),
        position = 0,
        checkpoints = 0,
        finished = false,
        finishTime = nil
    })
    
    TriggerClientEvent('QBCore:Notify', src, 'Joined race: ' .. race.name, 'success')
    TriggerClientEvent('ls-racing:client:JoinRace', src, raceId)
    
    -- Notify other participants
    for _, participant in pairs(activeRace.participants) do
        if participant.src ~= src then
            TriggerClientEvent('QBCore:Notify', participant.src, Player.PlayerData.charinfo.firstname .. ' joined the race', 'primary')
        end
    end
end)

RegisterNetEvent('ls-racing:server:LeaveRace', function(raceId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local activeRace = activeRaces[raceId]
    if not activeRace then return end
    
    -- Remove participant
    for i, participant in pairs(activeRace.participants) do
        if participant.src == src then
            table.remove(activeRace.participants, i)
            break
        end
    end
    
    TriggerClientEvent('QBCore:Notify', src, 'Left the race', 'primary')
    TriggerClientEvent('ls-racing:client:LeaveRace', src)
    
    -- Notify other participants
    for _, participant in pairs(activeRace.participants) do
        TriggerClientEvent('QBCore:Notify', participant.src, Player.PlayerData.charinfo.firstname .. ' left the race', 'error')
    end
end)

RegisterNetEvent('ls-racing:server:StartRace', function(raceId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local race = races[raceId]
    local activeRace = activeRaces[raceId]
    
    if not race or not activeRace then
        TriggerClientEvent('QBCore:Notify', src, 'Race not found', 'error')
        return
    end
    
    -- Check if player is host
    if race.host ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'Only the host can start the race', 'error')
        return
    end
    
    if activeRace.started then
        TriggerClientEvent('QBCore:Notify', src, 'Race has already started', 'error')
        return
    end
    
    -- Check minimum participants
    if #activeRace.participants < 2 then
        TriggerClientEvent('QBCore:Notify', src, 'Need at least 2 participants to start', 'error')
        return
    end
    
    -- Start race
    activeRace.started = true
    activeRace.startTime = os.time()
    race.status = 'active'
    
    -- Notify all participants
    for _, participant in pairs(activeRace.participants) do
        TriggerClientEvent('ls-racing:client:StartRace', participant.src, race)
    end
    
    TriggerClientEvent('QBCore:Notify', src, 'Race started!', 'success')
    
    -- Auto-end race after 30 minutes
    SetTimeout(1800000, function()
        if activeRaces[raceId] and activeRaces[raceId].started then
            EndRace(raceId, 'timeout')
        end
    end)
end)

RegisterNetEvent('ls-racing:server:CancelRace', function(raceId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local race = races[raceId]
    local activeRace = activeRaces[raceId]
    
    if not race or not activeRace then
        TriggerClientEvent('QBCore:Notify', src, 'Race not found', 'error')
        return
    end
    
    -- Check if player is host
    if race.host ~= Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, 'Only the host can cancel the race', 'error')
        return
    end
    
    -- Refund entry fees
    if race.entryFee > 0 then
        for _, participant in pairs(activeRace.participants) do
            local ParticipantPlayer = QBCore.Functions.GetPlayer(participant.src)
            if ParticipantPlayer then
                ParticipantPlayer.Functions.AddMoney('cash', race.entryFee)
            end
        end
    end
    
    -- Notify all participants
    for _, participant in pairs(activeRace.participants) do
        TriggerClientEvent('QBCore:Notify', participant.src, 'Race has been cancelled', 'error')
        TriggerClientEvent('ls-racing:client:LeaveRace', participant.src)
    end
    
    -- Clean up
    races[raceId] = nil
    activeRaces[raceId] = nil
    
    TriggerClientEvent('QBCore:Notify', src, 'Race cancelled', 'success')
end)

RegisterNetEvent('ls-racing:server:CheckpointPassed', function(raceId, checkpointId)
    local src = source
    local activeRace = activeRaces[raceId]
    if not activeRace or not activeRace.started then return end
    
    -- Find participant
    local participant = nil
    for _, p in pairs(activeRace.participants) do
        if p.src == src then
            participant = p
            break
        end
    end
    
    if not participant then return end
    
    -- Update checkpoint count
    participant.checkpoints = checkpointId
    
    -- Calculate position
    local position = CalculateRacePosition(activeRace, participant)
    participant.position = position
    
    TriggerClientEvent('ls-racing:client:CheckpointPassed', src, checkpointId, position)
    
    -- Check if finished
    local race = races[raceId]
    if checkpointId >= #race.checkpoints then
        FinishParticipant(raceId, participant)
    end
end)

RegisterNetEvent('ls-racing:server:GetAvailableRaces', function()
    local src = source
    local availableRaces = {}
    
    for raceId, race in pairs(races) do
        if race.status == 'waiting' then
            local activeRace = activeRaces[raceId]
            if activeRace then
                race.participants = #activeRace.participants
                table.insert(availableRaces, race)
            end
        end
    end
    
    TriggerClientEvent('ls-racing:client:ShowAvailableRaces', src, availableRaces)
end)

RegisterNetEvent('ls-racing:server:GetRaceStats', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local playerStats = GetPlayerRaceStats(Player.PlayerData.citizenid)
    TriggerClientEvent('ls-racing:client:ShowRaceStats', src, playerStats)
end)

RegisterNetEvent('ls-racing:server:GetRaceHistory', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local playerHistory = GetPlayerRaceHistory(Player.PlayerData.citizenid)
    TriggerClientEvent('ls-racing:client:ShowRaceHistory', src, playerHistory)
end)

RegisterNetEvent('ls-racing:server:GetLeaderboards', function()
    local src = source
    local leaderboards = GetRaceLeaderboards()
    TriggerClientEvent('ls-racing:client:ShowLeaderboards', src, leaderboards)
end)

-- Functions
function LoadRaces()
    -- Load predefined races
    races = {
        ['downtown_circuit'] = {
            id = 'downtown_circuit',
            name = 'Downtown Circuit',
            host = 'system',
            hostName = 'System',
            startCoords = vector3(-543.67, -195.55, 38.22),
            checkpoints = {
                vector3(-543.67, -195.55, 38.22),
                vector3(-692.57, -238.64, 36.77),
                vector3(-827.08, -368.39, 35.16),
                vector3(-934.95, -478.93, 37.05),
                vector3(-1027.11, -419.15, 35.42),
                vector3(-1087.52, -256.35, 37.76),
                vector3(-1023.75, -114.29, 38.20),
                vector3(-854.32, -46.93, 38.93),
                vector3(-651.42, -116.88, 37.91),
                vector3(-543.67, -195.55, 38.22)
            },
            entryFee = 500,
            maxParticipants = 8,
            laps = 3,
            vehicleClass = 'sports',
            created = os.time(),
            status = 'waiting'
        },
        ['highway_sprint'] = {
            id = 'highway_sprint',
            name = 'Highway Sprint',
            host = 'system',
            hostName = 'System',
            startCoords = vector3(-2547.95, 2327.11, 33.06),
            checkpoints = {
                vector3(-2547.95, 2327.11, 33.06),
                vector3(-2158.32, 2531.78, 29.54),
                vector3(-1654.87, 2654.91, 3.16),
                vector3(-1079.25, 2712.50, 18.79),
                vector3(-564.11, 2827.42, 17.80),
                vector3(62.89, 2894.79, 41.67),
                vector3(692.15, 2950.78, 40.69),
                vector3(1285.34, 3025.11, 40.33)
            },
            entryFee = 1000,
            maxParticipants = 6,
            laps = 1,
            vehicleClass = 'super',
            created = os.time(),
            status = 'waiting'
        },
        ['mountain_run'] = {
            id = 'mountain_run',
            name = 'Mountain Run',
            host = 'system',
            hostName = 'System',
            startCoords = vector3(-1577.14, 4458.70, 23.31),
            checkpoints = {
                vector3(-1577.14, 4458.70, 23.31),
                vector3(-1398.77, 4671.25, 62.34),
                vector3(-1082.45, 4920.15, 218.65),
                vector3(-741.23, 5148.89, 151.86),
                vector3(-351.45, 5289.12, 82.45),
                vector3(145.67, 5312.89, 83.67),
                vector3(432.11, 5156.78, 152.34),
                vector3(689.23, 4834.56, 201.45),
                vector3(845.67, 4512.34, 156.78),
                vector3(967.89, 4234.56, 89.23)
            },
            entryFee = 750,
            maxParticipants = 8,
            laps = 2,
            vehicleClass = 'off_road',
            created = os.time(),
            status = 'waiting'
        }
    }
    
    -- Initialize active races
    for raceId, race in pairs(races) do
        activeRaces[raceId] = {
            participants = {},
            started = false,
            startTime = nil,
            results = {}
        }
    end
    
    -- Load custom races from database
    LoadRacesFromDB()
end

function LoadRaceStats()
    -- Load race statistics from database
    raceStats = {}
    LoadRaceStatsFromDB()
end

function CalculateRacePosition(activeRace, participant)
    local position = 1
    
    for _, other in pairs(activeRace.participants) do
        if other.src ~= participant.src then
            if other.checkpoints > participant.checkpoints then
                position = position + 1
            elseif other.checkpoints == participant.checkpoints and other.finishTime and participant.finishTime then
                if other.finishTime < participant.finishTime then
                    position = position + 1
                end
            end
        end
    end
    
    return position
end

function FinishParticipant(raceId, participant)
    local race = races[raceId]
    local activeRace = activeRaces[raceId]
    
    if participant.finished then return end
    
    participant.finished = true
    participant.finishTime = os.time() - activeRace.startTime
    
    -- Calculate final position
    participant.position = CalculateRacePosition(activeRace, participant)
    
    -- Add to results
    table.insert(activeRace.results, {
        position = participant.position,
        name = participant.name,
        time = participant.finishTime,
        vehicle = participant.vehicle,
        citizenid = participant.citizenid
    })
    
    -- Notify participant
    TriggerClientEvent('QBCore:Notify', participant.src, 'Race finished! Position: ' .. participant.position, 'success')
    
    -- Update race stats
    UpdatePlayerRaceStats(participant.citizenid, {
        racesCompleted = 1,
        position = participant.position,
        time = participant.finishTime
    })
    
    -- Check if all participants finished
    local allFinished = true
    for _, p in pairs(activeRace.participants) do
        if not p.finished then
            allFinished = false
            break
        end
    end
    
    if allFinished then
        EndRace(raceId, 'completed')
    end
end

function EndRace(raceId, reason)
    local race = races[raceId]
    local activeRace = activeRaces[raceId]
    
    if not race or not activeRace then return end
    
    race.status = 'finished'
    
    -- Sort results by position
    table.sort(activeRace.results, function(a, b) return a.position < b.position end)
    
    -- Distribute prizes
    if race.entryFee > 0 and #activeRace.results > 0 then
        local totalPrize = race.entryFee * #activeRace.participants
        local prizes = {
            [1] = math.floor(totalPrize * 0.6), -- 60% for 1st place
            [2] = math.floor(totalPrize * 0.3), -- 30% for 2nd place
            [3] = math.floor(totalPrize * 0.1)  -- 10% for 3rd place
        }
        
        for i, result in ipairs(activeRace.results) do
            if prizes[i] then
                local participant = nil
                for _, p in pairs(activeRace.participants) do
                    if p.citizenid == result.citizenid then
                        participant = p
                        break
                    end
                end
                
                if participant then
                    local Player = QBCore.Functions.GetPlayer(participant.src)
                    if Player then
                        Player.Functions.AddMoney('cash', prizes[i])
                        TriggerClientEvent('QBCore:Notify', participant.src, 'Prize won: $' .. prizes[i], 'success')
                    end
                end
            end
        end
    end
    
    -- Show results to all participants
    for _, participant in pairs(activeRace.participants) do
        TriggerClientEvent('ls-racing:client:EndRace', participant.src, activeRace.results)
    end
    
    -- Save race results
    SaveRaceResults(raceId, activeRace.results)
    
    -- Clean up non-permanent races
    if race.host ~= 'system' then
        races[raceId] = nil
        activeRaces[raceId] = nil
    else
        -- Reset system races
        activeRaces[raceId] = {
            participants = {},
            started = false,
            startTime = nil,
            results = {}
        }
        race.status = 'waiting'
    end
end

function GetPlayerRaceStats(citizenid)
    return raceStats[citizenid] or {
        racesCompleted = 0,
        racesWon = 0,
        bestTime = nil,
        totalWinnings = 0
    }
end

function UpdatePlayerRaceStats(citizenid, data)
    if not raceStats[citizenid] then
        raceStats[citizenid] = {
            racesCompleted = 0,
            racesWon = 0,
            bestTime = nil,
            totalWinnings = 0
        }
    end
    
    local stats = raceStats[citizenid]
    stats.racesCompleted = stats.racesCompleted + (data.racesCompleted or 0)
    
    if data.position == 1 then
        stats.racesWon = stats.racesWon + 1
    end
    
    if data.time and (not stats.bestTime or data.time < stats.bestTime) then
        stats.bestTime = data.time
    end
    
    -- Save to database
    SavePlayerRaceStats(citizenid, stats)
end

function GetPlayerRaceHistory(citizenid)
    -- This would typically load from database
    return {}
end

function GetRaceLeaderboards()
    local leaderboards = {
        mostWins = {},
        bestTimes = {},
        mostRaces = {}
    }
    
    -- Sort by wins
    local winsList = {}
    for citizenid, stats in pairs(raceStats) do
        table.insert(winsList, {citizenid = citizenid, wins = stats.racesWon})
    end
    table.sort(winsList, function(a, b) return a.wins > b.wins end)
    leaderboards.mostWins = winsList
    
    -- Sort by best times
    local timesList = {}
    for citizenid, stats in pairs(raceStats) do
        if stats.bestTime then
            table.insert(timesList, {citizenid = citizenid, time = stats.bestTime})
        end
    end
    table.sort(timesList, function(a, b) return a.time < b.time end)
    leaderboards.bestTimes = timesList
    
    -- Sort by most races
    local racesList = {}
    for citizenid, stats in pairs(raceStats) do
        table.insert(racesList, {citizenid = citizenid, races = stats.racesCompleted})
    end
    table.sort(racesList, function(a, b) return a.races > b.races end)
    leaderboards.mostRaces = racesList
    
    return leaderboards
end

-- Database functions (placeholder - implement with your database system)
function SaveRaceData(raceId, raceData)
    -- Save race data to database
end

function SaveRaceResults(raceId, results)
    -- Save race results to database
end

function SavePlayerRaceStats(citizenid, stats)
    -- Save player race stats to database
end

function LoadRacesFromDB()
    -- Load custom races from database
end

function LoadRaceStatsFromDB()
    -- Load race stats from database
end

-- Player disconnect handling
AddEventHandler('playerDropped', function(reason)
    local src = source
    
    -- Remove player from any active races
    for raceId, activeRace in pairs(activeRaces) do
        for i, participant in pairs(activeRace.participants) do
            if participant.src == src then
                table.remove(activeRace.participants, i)
                
                -- Notify other participants
                for _, otherParticipant in pairs(activeRace.participants) do
                    TriggerClientEvent('QBCore:Notify', otherParticipant.src, participant.name .. ' disconnected from the race', 'error')
                end
                
                break
            end
        end
    end
end)

-- Callbacks
QBCore.Functions.CreateCallback('ls-racing:server:GetRaceData', function(source, cb, raceId)
    cb(races[raceId])
end)

QBCore.Functions.CreateCallback('ls-racing:server:GetActiveRaces', function(source, cb)
    local activeRacesList = {}
    for raceId, race in pairs(races) do
        if race.status == 'waiting' or race.status == 'active' then
            local activeRace = activeRaces[raceId]
            if activeRace then
                race.participants = #activeRace.participants
                race.started = activeRace.started
                table.insert(activeRacesList, race)
            end
        end
    end
    cb(activeRacesList)
end)

QBCore.Functions.CreateCallback('ls-racing:server:IsInRace', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(false) return end
    
    for raceId, activeRace in pairs(activeRaces) do
        for _, participant in pairs(activeRace.participants) do
            if participant.citizenid == Player.PlayerData.citizenid then
                cb(true, raceId)
                return
            end
        end
    end
    
    cb(false)
end)