local QBCore = exports['qb-core']:GetCoreObject()

-- Variables
local gangData = {}
local gangWars = {}
local gangTerritories = {}
local gangMembers = {}

-- Initialize gang data
CreateThread(function()
    LoadGangData()
    LoadGangTerritories()
end)

-- Events
RegisterNetEvent('ls-gangs:server:GetGangData', function(gangName)
    local src = source
    if gangData[gangName] then
        TriggerClientEvent('ls-gangs:client:UpdateGangData', src, gangData[gangName])
    end
end)

RegisterNetEvent('ls-gangs:server:GetGangTerritories', function()
    local src = source
    TriggerClientEvent('ls-gangs:client:RefreshTerritories', src, gangTerritories)
end)

RegisterNetEvent('ls-gangs:server:DeclareWar', function(targetGang)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local playerGang = Player.PlayerData.gang.name
    
    if not gangData[targetGang] then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid gang name', 'error')
        return
    end
    
    if playerGang == targetGang then
        TriggerClientEvent('QBCore:Notify', src, 'You cannot declare war on your own gang', 'error')
        return
    end
    
    -- Check if war already exists
    local warKey = playerGang .. '_vs_' .. targetGang
    local reverseWarKey = targetGang .. '_vs_' .. playerGang
    
    if gangWars[warKey] or gangWars[reverseWarKey] then
        TriggerClientEvent('QBCore:Notify', src, 'War already exists between these gangs', 'error')
        return
    end
    
    -- Create gang war
    gangWars[warKey] = {
        attacker = playerGang,
        defender = targetGang,
        startTime = os.time(),
        kills = {
            [playerGang] = 0,
            [targetGang] = 0
        },
        active = true
    }
    
    -- Notify all gang members
    NotifyGangMembers(playerGang, 'War declared against ' .. targetGang .. '!', 'error')
    NotifyGangMembers(targetGang, playerGang .. ' has declared war on you!', 'error')
    
    -- Trigger client events for war effects
    TriggerClientEvent('ls-gangs:client:StartGangWar', -1, {
        gang1 = playerGang,
        gang2 = targetGang
    })
    
    -- Auto-end war after 1 hour
    SetTimeout(3600000, function()
        EndGangWar(warKey)
    end)
end)

RegisterNetEvent('ls-gangs:server:GetGangStatus', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local playerGang = Player.PlayerData.gang.name
    local status = GetGangStatus(playerGang)
    
    TriggerClientEvent('QBCore:Notify', src, status, 'primary')
end)

RegisterNetEvent('ls-gangs:server:SellDrugs', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then return end
    
    -- Check if player has drugs
    local hasDrugs = false
    local drugItem = nil
    local drugPrice = 0
    
    local drugs = {'weed_brick', 'coke_brick', 'meth'}
    local prices = {weed_brick = 100, coke_brick = 300, meth = 200}
    
    for _, drug in pairs(drugs) do
        if Player.Functions.GetItemByName(drug) then
            hasDrugs = true
            drugItem = drug
            drugPrice = prices[drug]
            break
        end
    end
    
    if not hasDrugs then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have any drugs to sell', 'error')
        return
    end
    
    -- Check if target player accepts
    local chance = math.random(1, 100)
    if chance <= 70 then -- 70% success rate
        Player.Functions.RemoveItem(drugItem, 1)
        Player.Functions.AddMoney('cash', drugPrice)
        
        TriggerClientEvent('QBCore:Notify', src, 'Drugs sold for $' .. drugPrice, 'success')
        TriggerClientEvent('QBCore:Notify', targetId, 'Someone tried to sell you drugs', 'error')
        
        -- Add reputation to gang
        AddGangReputation(Player.PlayerData.gang.name, 1)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Drug sale failed', 'error')
        
        -- Chance of police being called
        if math.random(1, 100) <= 30 then
            TriggerEvent('police:server:policeAlert', 'Drug dealing reported', GetEntityCoords(GetPlayerPed(src)))
        end
    end
end)

RegisterNetEvent('ls-gangs:server:RecruitPlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then return end
    
    if TargetPlayer.PlayerData.gang.name ~= 'none' then
        TriggerClientEvent('QBCore:Notify', src, 'Player is already in a gang', 'error')
        return
    end
    
    -- Send recruitment offer to target player
    TriggerClientEvent('ls-gangs:client:ReceiveRecruitmentOffer', targetId, {
        gangName = Player.PlayerData.gang.name,
        recruiterName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        recruiterId = src
    })
    
    TriggerClientEvent('QBCore:Notify', src, 'Recruitment offer sent', 'success')
end)

RegisterNetEvent('ls-gangs:server:AcceptRecruitment', function(recruiterId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local RecruiterPlayer = QBCore.Functions.GetPlayer(recruiterId)
    
    if not Player or not RecruiterPlayer then return end
    
    local gangName = RecruiterPlayer.PlayerData.gang.name
    
    -- Add player to gang
    Player.Functions.SetGang(gangName, 1)
    
    TriggerClientEvent('QBCore:Notify', src, 'You have joined ' .. gangName, 'success')
    TriggerClientEvent('QBCore:Notify', recruiterId, 'Player has joined your gang', 'success')
    
    -- Notify gang members
    NotifyGangMembers(gangName, 'New member joined the gang', 'success')
end)

RegisterNetEvent('ls-gangs:server:GetGangInfo', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local gangName = Player.PlayerData.gang.name
    local info = GetGangInfo(gangName)
    
    TriggerClientEvent('ls-gangs:client:ShowGangInfo', src, info)
end)

RegisterNetEvent('ls-gangs:server:GetGangMembers', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local gangName = Player.PlayerData.gang.name
    local members = GetGangMembers(gangName)
    
    TriggerClientEvent('ls-gangs:client:ShowGangMembers', src, members)
end)

RegisterNetEvent('ls-gangs:server:GetTerritories', function()
    local src = source
    TriggerClientEvent('ls-gangs:client:ShowTerritories', src, gangTerritories)
end)

-- Functions
function LoadGangData()
    gangData = {
        ['ballas'] = {
            name = 'ballas',
            label = 'Ballas',
            color = 3, -- Purple
            reputation = 0,
            territory = 'grove_street'
        },
        ['families'] = {
            name = 'families',
            label = 'Families',
            color = 2, -- Green
            reputation = 0,
            territory = 'chamberlain_hills'
        },
        ['vagos'] = {
            name = 'vagos',
            label = 'Vagos',
            color = 5, -- Yellow
            reputation = 0,
            territory = 'rancho'
        },
        ['bloods'] = {
            name = 'bloods',
            label = 'Bloods',
            color = 1, -- Red
            reputation = 0,
            territory = 'strawberry'
        }
    }
end

function LoadGangTerritories()
    gangTerritories = {
        ['grove_street'] = {
            name = 'Grove Street',
            coords = vector3(-127.7, -1739.1, 29.3),
            radius = 150.0,
            owner = 'ballas',
            contested = false
        },
        ['chamberlain_hills'] = {
            name = 'Chamberlain Hills',
            coords = vector3(-1396.8, -669.5, 27.9),
            radius = 120.0,
            owner = 'families',
            contested = false
        },
        ['rancho'] = {
            name = 'Rancho',
            coords = vector3(489.9, -1536.5, 29.3),
            radius = 130.0,
            owner = 'vagos',
            contested = false
        },
        ['strawberry'] = {
            name = 'Strawberry',
            coords = vector3(252.5, -1746.8, 29.7),
            radius = 140.0,
            owner = 'bloods',
            contested = false
        }
    }
end

function NotifyGangMembers(gangName, message, type)
    local Players = QBCore.Functions.GetQBPlayers()
    
    for k, v in pairs(Players) do
        if v.PlayerData.gang.name == gangName then
            TriggerClientEvent('QBCore:Notify', k, message, type or 'primary')
        end
    end
end

function GetGangStatus(gangName)
    if not gangData[gangName] then
        return 'Gang not found'
    end
    
    local gang = gangData[gangName]
    local members = GetGangMemberCount(gangName)
    local activeWars = GetActiveWars(gangName)
    
    return string.format('Gang: %s | Members: %d | Reputation: %d | Active Wars: %d', 
        gang.label, members, gang.reputation, activeWars)
end

function GetGangMemberCount(gangName)
    local count = 0
    local Players = QBCore.Functions.GetQBPlayers()
    
    for k, v in pairs(Players) do
        if v.PlayerData.gang.name == gangName then
            count = count + 1
        end
    end
    
    return count
end

function GetActiveWars(gangName)
    local count = 0
    
    for warKey, war in pairs(gangWars) do
        if war.active and (war.attacker == gangName or war.defender == gangName) then
            count = count + 1
        end
    end
    
    return count
end

function AddGangReputation(gangName, amount)
    if gangData[gangName] then
        gangData[gangName].reputation = gangData[gangName].reputation + amount
    end
end

function EndGangWar(warKey)
    local war = gangWars[warKey]
    if not war then return end
    
    war.active = false
    
    -- Determine winner
    local winner = war.kills[war.attacker] > war.kills[war.defender] and war.attacker or war.defender
    
    -- Notify gang members
    NotifyGangMembers(war.attacker, 'Gang war ended. Winner: ' .. winner, 'primary')
    NotifyGangMembers(war.defender, 'Gang war ended. Winner: ' .. winner, 'primary')
    
    -- Trigger client events
    TriggerClientEvent('ls-gangs:client:EndGangWar', -1, {
        gang1 = war.attacker,
        gang2 = war.defender,
        winner = winner
    })
    
    -- Add reputation to winner
    AddGangReputation(winner, 10)
end

function GetGangInfo(gangName)
    if not gangData[gangName] then return nil end
    
    local gang = gangData[gangName]
    local members = GetGangMemberCount(gangName)
    local activeWars = GetActiveWars(gangName)
    
    return {
        name = gang.name,
        label = gang.label,
        reputation = gang.reputation,
        members = members,
        activeWars = activeWars,
        territory = gang.territory
    }
end

function GetGangMembers(gangName)
    local members = {}
    local Players = QBCore.Functions.GetQBPlayers()
    
    for k, v in pairs(Players) do
        if v.PlayerData.gang.name == gangName then
            table.insert(members, {
                citizenid = v.PlayerData.citizenid,
                name = v.PlayerData.charinfo.firstname .. ' ' .. v.PlayerData.charinfo.lastname,
                grade = v.PlayerData.gang.grade.level,
                online = true
            })
        end
    end
    
    return members
end

-- Territory system
CreateThread(function()
    while true do
        CheckTerritoryControl()
        Wait(30000) -- Check every 30 seconds
    end
end)

function CheckTerritoryControl()
    for territoryId, territory in pairs(gangTerritories) do
        local playersInTerritory = {}
        local Players = QBCore.Functions.GetQBPlayers()
        
        for k, v in pairs(Players) do
            local playerCoords = GetEntityCoords(GetPlayerPed(k))
            local distance = #(playerCoords - territory.coords)
            
            if distance <= territory.radius then
                local gangName = v.PlayerData.gang.name
                if gangName ~= 'none' then
                    if not playersInTerritory[gangName] then
                        playersInTerritory[gangName] = 0
                    end
                    playersInTerritory[gangName] = playersInTerritory[gangName] + 1
                    
                    -- Notify player they're in territory
                    TriggerClientEvent('ls-gangs:client:EnterTerritory', k, territory.owner)
                end
            end
        end
        
        -- Check for territory contests
        local dominantGang = nil
        local maxPlayers = 0
        
        for gangName, playerCount in pairs(playersInTerritory) do
            if playerCount > maxPlayers then
                maxPlayers = playerCount
                dominantGang = gangName
            end
        end
        
        if dominantGang and dominantGang ~= territory.owner and maxPlayers >= 3 then
            if not territory.contested then
                territory.contested = true
                NotifyGangMembers(territory.owner, 'Your territory ' .. territory.name .. ' is being contested!', 'error')
                NotifyGangMembers(dominantGang, 'You are contesting ' .. territory.name .. '!', 'primary')
            end
        else
            territory.contested = false
        end
    end
end

-- Player death handling for gang wars
AddEventHandler('playerDropped', function(reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player and Player.PlayerData.gang.name ~= 'none' then
        -- Handle gang war kill if applicable
        HandleGangWarKill(Player.PlayerData.gang.name, src)
    end
end)

function HandleGangWarKill(victimGang, killerId)
    local killerPlayer = QBCore.Functions.GetPlayer(killerId)
    if not killerPlayer then return end
    
    local killerGang = killerPlayer.PlayerData.gang.name
    if killerGang == 'none' or killerGang == victimGang then return end
    
    -- Find active war between these gangs
    for warKey, war in pairs(gangWars) do
        if war.active and 
           ((war.attacker == killerGang and war.defender == victimGang) or
            (war.attacker == victimGang and war.defender == killerGang)) then
            
            war.kills[killerGang] = war.kills[killerGang] + 1
            
            -- Notify gangs
            NotifyGangMembers(killerGang, 'Gang war kill! Score: ' .. war.kills[killerGang], 'success')
            NotifyGangMembers(victimGang, 'Member killed in gang war! Enemy score: ' .. war.kills[killerGang], 'error')
            
            break
        end
    end
end

-- Database functions (placeholder - implement with your database system)
function SaveGangData()
    -- Save gang data to database
end

function LoadGangDataFromDB()
    -- Load gang data from database
end

-- Callbacks
QBCore.Functions.CreateCallback('ls-gangs:server:GetGangData', function(source, cb, gangName)
    cb(gangData[gangName])
end)

QBCore.Functions.CreateCallback('ls-gangs:server:GetTerritories', function(source, cb)
    cb(gangTerritories)
end)

QBCore.Functions.CreateCallback('ls-gangs:server:IsInGang', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        cb(Player.PlayerData.gang.name ~= 'none')
    else
        cb(false)
    end
end)