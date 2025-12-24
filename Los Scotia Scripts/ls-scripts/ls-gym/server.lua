local QBCore = exports['qb-core']:GetCoreObject()

-- ================================================
-- VARIABLES
-- ================================================

local GymMembers = {}
local PlayerStats = {}
local ActiveCompetitions = {}

-- ================================================
-- UTILITY FUNCTIONS
-- ================================================

local function LoadPlayerStats(citizenid)
    local result = MySQL.Sync.fetchAll('SELECT * FROM gym_stats WHERE citizenid = ?', {citizenid})
    if result[1] then
        return json.decode(result[1].stats)
    else
        -- Create default stats
        local defaultStats = {
            strength = 0,
            stamina = 0,
            endurance = 0,
            totalWorkouts = 0,
            favoriteEquipment = 'none'
        }
        MySQL.Async.insert('INSERT INTO gym_stats (citizenid, stats) VALUES (?, ?)', {
            citizenid,
            json.encode(defaultStats)
        })
        return defaultStats
    end
end

local function SavePlayerStats(citizenid, stats)
    MySQL.Async.execute('UPDATE gym_stats SET stats = ? WHERE citizenid = ?', {
        json.encode(stats),
        citizenid
    })
end

local function LoadMembershipData(citizenid)
    local result = MySQL.Sync.fetchAll('SELECT * FROM gym_memberships WHERE citizenid = ?', {citizenid})
    if result[1] then
        return {
            type = result[1].membership_type,
            expires = result[1].expires_at,
            active = os.time() < result[1].expires_at
        }
    end
    return nil
end

-- ================================================
-- PLAYER LOADING
-- ================================================

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    local citizenid = Player.PlayerData.citizenid
    PlayerStats[Player.PlayerData.source] = LoadPlayerStats(citizenid)
    
    local membership = LoadMembershipData(citizenid)
    if membership and membership.active then
        GymMembers[Player.PlayerData.source] = membership
    end
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    PlayerStats[src] = nil
    GymMembers[src] = nil
end)

-- ================================================
-- MEMBERSHIP SYSTEM
-- ================================================

QBCore.Functions.CreateCallback('ls-gym:server:HasMembership', function(source, cb)
    cb(GymMembers[source] ~= nil)
end)

QBCore.Functions.CreateCallback('ls-gym:server:PurchaseMembership', function(source, cb, membershipType, price, duration)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb(false)
        return
    end
    
    -- Check if player has enough money
    if Player.PlayerData.money.bank < price then
        cb(false)
        return
    end
    
    -- Remove money
    Player.Functions.RemoveMoney('bank', price, 'Gym membership purchase')
    
    -- Calculate expiration date
    local expiresAt = os.time() + (duration * 24 * 60 * 60) -- Convert days to seconds
    
    -- Update or insert membership
    local citizenid = Player.PlayerData.citizenid
    local existingMembership = LoadMembershipData(citizenid)
    
    if existingMembership then
        MySQL.Async.execute('UPDATE gym_memberships SET membership_type = ?, expires_at = ? WHERE citizenid = ?', {
            membershipType,
            expiresAt,
            citizenid
        })
    else
        MySQL.Async.insert('INSERT INTO gym_memberships (citizenid, membership_type, expires_at) VALUES (?, ?, ?)', {
            citizenid,
            membershipType,
            expiresAt
        })
    end
    
    -- Update server data
    GymMembers[src] = {
        type = membershipType,
        expires = expiresAt,
        active = true
    }
    
    cb(true)
end)

RegisterNetEvent('ls-gym:server:GetMembershipStatus', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local membership = LoadMembershipData(Player.PlayerData.citizenid)
    if membership and membership.active then
        GymMembers[src] = membership
        TriggerClientEvent('QBCore:Notify', src, 'Your gym membership is active!', 'success')
    elseif membership and not membership.active then
        TriggerClientEvent('QBCore:Notify', src, 'Your gym membership has expired!', 'error')
    end
end)

-- ================================================
-- WORKOUT SYSTEM
-- ================================================

RegisterNetEvent('ls-gym:server:CompleteWorkout', function(equipmentId, strengthGain, staminaGain)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not GymMembers[src] then return end
    
    local stats = PlayerStats[src] or LoadPlayerStats(Player.PlayerData.citizenid)
    
    -- Update stats
    stats.strength = math.min(100, stats.strength + strengthGain)
    stats.stamina = math.min(100, stats.stamina + staminaGain)
    stats.totalWorkouts = stats.totalWorkouts + 1
    
    -- Track favorite equipment
    if not stats.equipmentUsage then
        stats.equipmentUsage = {}
    end
    stats.equipmentUsage[equipmentId] = (stats.equipmentUsage[equipmentId] or 0) + 1
    
    -- Find favorite equipment
    local maxUsage = 0
    local favoriteEquipment = 'none'
    for equipment, usage in pairs(stats.equipmentUsage) do
        if usage > maxUsage then
            maxUsage = usage
            favoriteEquipment = equipment
        end
    end
    stats.favoriteEquipment = favoriteEquipment
    
    -- Save to database
    SavePlayerStats(Player.PlayerData.citizenid, stats)
    PlayerStats[src] = stats
    
    -- Apply QBCore stat bonuses (if available)
    if Player.PlayerData.metadata then
        Player.PlayerData.metadata.strength = stats.strength
        Player.PlayerData.metadata.stamina = stats.stamina
        Player.Functions.SetMetaData('strength', stats.strength)
        Player.Functions.SetMetaData('stamina', stats.stamina)
    end
    
    -- Check for achievements
    CheckAchievements(src, stats)
end)

-- ================================================
-- NUTRITION SYSTEM
-- ================================================

QBCore.Functions.CreateCallback('ls-gym:server:PurchaseNutrition', function(source, cb, item, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb(false)
        return
    end
    
    -- Check if player has enough money
    if Player.PlayerData.money.cash < price then
        cb(false)
        return
    end
    
    -- Remove money and give item
    Player.Functions.RemoveMoney('cash', price, 'Nutrition purchase')
    Player.Functions.AddItem(item, 1)
    
    cb(true)
end)

-- Register nutrition items as usable
CreateThread(function()
    for itemId, itemData in pairs(Config.NutritionItems) do
        QBCore.Functions.CreateUseableItem(itemId, function(source, item)
            local Player = QBCore.Functions.GetPlayer(source)
            if not Player.Functions.GetItemBySlot(item.slot) then return end
            
            Player.Functions.RemoveItem(itemId, 1, item.slot)
            TriggerClientEvent('ls-gym:client:ConsumeNutrition', source, itemId)
        end)
    end
end)

-- ================================================
-- COMPETITION SYSTEM
-- ================================================

local function StartCompetition()
    if #ActiveCompetitions > 0 then return end
    
    local competition = {
        id = math.random(100000, 999999),
        type = 'bodybuilding',
        startTime = os.time(),
        duration = 3600, -- 1 hour
        participants = {},
        prizes = {5000, 3000, 1500, 1000, 500} -- Top 5 prizes
    }
    
    table.insert(ActiveCompetitions, competition)
    
    -- Notify all gym members
    for playerId, _ in pairs(GymMembers) do
        TriggerClientEvent('QBCore:Notify', playerId, 'Bodybuilding competition starting! Visit the gym to participate!', 'primary')
    end
    
    print(string.format('[LS-GYM] Competition %d started', competition.id))
end

local function EndCompetition(competitionId)
    for i, competition in ipairs(ActiveCompetitions) do
        if competition.id == competitionId then
            -- Calculate results based on participant stats
            local results = {}
            
            for playerId, participant in pairs(competition.participants) do
                local stats = PlayerStats[playerId]
                if stats then
                    local score = (stats.strength * 0.4) + (stats.stamina * 0.3) + (stats.totalWorkouts * 0.3)
                    table.insert(results, {
                        playerId = playerId,
                        name = participant.name,
                        score = math.floor(score),
                        stats = stats
                    })
                end
            end
            
            -- Sort by score (highest first)
            table.sort(results, function(a, b) return a.score > b.score end)
            
            -- Award prizes
            for j, result in ipairs(results) do
                if j <= #competition.prizes then
                    local Player = QBCore.Functions.GetPlayer(result.playerId)
                    if Player then
                        local prize = competition.prizes[j]
                        Player.Functions.AddMoney('bank', prize, 'Gym competition prize')
                        TriggerClientEvent('QBCore:Notify', result.playerId, string.format('Congratulations! You placed #%d and won $%d!', j, prize), 'success')
                        result.prize = prize
                    end
                else
                    result.prize = 0
                end
            end
            
            -- Send results to all participants
            for playerId, _ in pairs(competition.participants) do
                TriggerClientEvent('ls-gym:client:ShowCompetitionResults', playerId, results)
            end
            
            table.remove(ActiveCompetitions, i)
            print(string.format('[LS-GYM] Competition %d ended with %d participants', competitionId, #results))
            break
        end
    end
end

-- Start competitions every 2 hours
CreateThread(function()
    while true do
        Wait(7200000) -- 2 hours
        
        -- Only start if there are enough gym members online
        local memberCount = 0
        for _ in pairs(GymMembers) do
            memberCount = memberCount + 1
        end
        
        if memberCount >= 3 then
            StartCompetition()
        end
    end
end)

-- End competitions automatically
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        local currentTime = os.time()
        for _, competition in ipairs(ActiveCompetitions) do
            if currentTime >= competition.startTime + competition.duration then
                EndCompetition(competition.id)
            end
        end
    end
end)

-- ================================================
-- ACHIEVEMENTS SYSTEM
-- ================================================

local Achievements = {
    {
        id = 'first_workout',
        name = 'Getting Started',
        description = 'Complete your first workout',
        condition = function(stats) return stats.totalWorkouts >= 1 end,
        reward = 500
    },
    {
        id = 'strength_25',
        name = 'Getting Strong',
        description = 'Reach 25 strength',
        condition = function(stats) return stats.strength >= 25 end,
        reward = 1000
    },
    {
        id = 'strength_50',
        name = 'Strong',
        description = 'Reach 50 strength',
        condition = function(stats) return stats.strength >= 50 end,
        reward = 2000
    },
    {
        id = 'strength_75',
        name = 'Very Strong',
        description = 'Reach 75 strength',
        condition = function(stats) return stats.strength >= 75 end,
        reward = 3500
    },
    {
        id = 'strength_100',
        name = 'Maximum Strength',
        description = 'Reach maximum strength (100)',
        condition = function(stats) return stats.strength >= 100 end,
        reward = 5000
    },
    {
        id = 'workout_50',
        name = 'Dedicated',
        description = 'Complete 50 workouts',
        condition = function(stats) return stats.totalWorkouts >= 50 end,
        reward = 2500
    },
    {
        id = 'workout_100',
        name = 'Gym Rat',
        description = 'Complete 100 workouts',
        condition = function(stats) return stats.totalWorkouts >= 100 end,
        reward = 5000
    }
}

function CheckAchievements(src, stats)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Get player achievements from metadata
    local playerAchievements = Player.PlayerData.metadata.gym_achievements or {}
    
    for _, achievement in ipairs(Achievements) do
        if not playerAchievements[achievement.id] and achievement.condition(stats) then
            -- Award achievement
            playerAchievements[achievement.id] = true
            Player.Functions.SetMetaData('gym_achievements', playerAchievements)
            
            -- Give reward
            Player.Functions.AddMoney('bank', achievement.reward, 'Gym achievement: ' .. achievement.name)
            
            -- Notify player
            TriggerClientEvent('QBCore:Notify', src, string.format('Achievement Unlocked: %s - $%d', achievement.name, achievement.reward), 'success')
        end
    end
end

-- ================================================
-- DATABASE SETUP
-- ================================================

CreateThread(function()
    -- Create tables if they don't exist
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS gym_memberships (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL UNIQUE,
            membership_type VARCHAR(50) NOT NULL,
            expires_at INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS gym_stats (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL UNIQUE,
            stats TEXT NOT NULL,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
    
    print('[LS-GYM] Database tables created/verified')
end)

-- ================================================
-- COMMANDS
-- ================================================

QBCore.Commands.Add('gymstats', 'Check your gym statistics', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local stats = PlayerStats[src] or LoadPlayerStats(Player.PlayerData.citizenid)
    
    TriggerClientEvent('chat:addMessage', src, {
        color = {255, 255, 255},
        multiline = true,
        args = {'[GYM STATS]', string.format('Strength: %d | Stamina: %d | Total Workouts: %d | Favorite Equipment: %s', 
            stats.strength, stats.stamina, stats.totalWorkouts, stats.favoriteEquipment)}
    })
end)

QBCore.Commands.Add('startgymcomp', 'Start gym competition (Admin)', {}, false, function(source, args)
    local src = source
    
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
        return
    end
    
    StartCompetition()
    TriggerClientEvent('QBCore:Notify', src, 'Gym competition started!', 'success')
end, 'admin')

-- ================================================
-- EXPORTS
-- ================================================

exports('GetPlayerStats', function(src)
    return PlayerStats[src]
end)

exports('HasMembership', function(src)
    return GymMembers[src] ~= nil
end)

exports('GetActiveCompetitions', function()
    return ActiveCompetitions
end)