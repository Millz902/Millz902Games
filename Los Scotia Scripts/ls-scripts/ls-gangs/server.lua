local QBCore = exports['qb-core']:GetCoreObject()

-- Gang Management Functions
RegisterNetEvent('ls-gangs:server:invitePlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
        return
    end
    
    if TargetPlayer.PlayerData.gang.name ~= 'none' then
        TriggerClientEvent('QBCore:Notify', src, 'Player is already in a gang', 'error')
        return
    end
    
    TargetPlayer.Functions.SetGang(Player.PlayerData.gang.name, 1)
    TriggerClientEvent('QBCore:Notify', src, 'Player invited to gang', 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 'You have been invited to ' .. Player.PlayerData.gang.label, 'success')
end)

RegisterNetEvent('ls-gangs:server:kickPlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
        return
    end
    
    if TargetPlayer.PlayerData.gang.name ~= Player.PlayerData.gang.name then
        TriggerClientEvent('QBCore:Notify', src, 'Player is not in your gang', 'error')
        return
    end
    
    if TargetPlayer.PlayerData.gang.grade.level >= Player.PlayerData.gang.grade.level then
        TriggerClientEvent('QBCore:Notify', src, 'You cannot kick someone of equal or higher rank', 'error')
        return
    end
    
    TargetPlayer.Functions.SetGang('none', 0)
    TriggerClientEvent('QBCore:Notify', src, 'Player kicked from gang', 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 'You have been kicked from the gang', 'error')
end)

RegisterNetEvent('ls-gangs:server:promotePlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
        return
    end
    
    if TargetPlayer.PlayerData.gang.name ~= Player.PlayerData.gang.name then
        TriggerClientEvent('QBCore:Notify', src, 'Player is not in your gang', 'error')
        return
    end
    
    local newGrade = TargetPlayer.PlayerData.gang.grade.level + 1
    if newGrade > 5 then
        TriggerClientEvent('QBCore:Notify', src, 'Player is already at maximum rank', 'error')
        return
    end
    
    if newGrade >= Player.PlayerData.gang.grade.level then
        TriggerClientEvent('QBCore:Notify', src, 'You cannot promote someone to your rank or higher', 'error')
        return
    end
    
    TargetPlayer.Functions.SetGang(Player.PlayerData.gang.name, newGrade)
    TriggerClientEvent('QBCore:Notify', src, 'Player promoted', 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 'You have been promoted', 'success')
end)

RegisterNetEvent('ls-gangs:server:demotePlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
        return
    end
    
    if TargetPlayer.PlayerData.gang.name ~= Player.PlayerData.gang.name then
        TriggerClientEvent('QBCore:Notify', src, 'Player is not in your gang', 'error')
        return
    end
    
    local newGrade = TargetPlayer.PlayerData.gang.grade.level - 1
    if newGrade < 1 then
        TriggerClientEvent('QBCore:Notify', src, 'Player is already at minimum rank', 'error')
        return
    end
    
    if TargetPlayer.PlayerData.gang.grade.level >= Player.PlayerData.gang.grade.level then
        TriggerClientEvent('QBCore:Notify', src, 'You cannot demote someone of equal or higher rank', 'error')
        return
    end
    
    TargetPlayer.Functions.SetGang(Player.PlayerData.gang.name, newGrade)
    TriggerClientEvent('QBCore:Notify', src, 'Player demoted', 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 'You have been demoted', 'error')
end)

RegisterNetEvent('ls-gangs:server:getMembers', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local gangName = Player.PlayerData.gang.name
    if gangName == 'none' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not in a gang', 'error')
        return
    end
    
    local members = {}
    for k, v in pairs(QBCore.Functions.GetPlayers()) do
        local targetPlayer = QBCore.Functions.GetPlayer(v)
        if targetPlayer.PlayerData.gang.name == gangName then
            table.insert(members, {
                name = targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname,
                rank = targetPlayer.PlayerData.gang.grade.name,
                level = targetPlayer.PlayerData.gang.grade.level
            })
        end
    end
    
    local membersList = 'Gang Members:\n'
    for _, member in pairs(members) do
        membersList = membersList .. member.name .. ' - ' .. member.rank .. '\n'
    end
    
    TriggerClientEvent('QBCore:Notify', src, membersList, 'primary')
end)

-- Drug Dealing System
RegisterNetEvent('ls-gangs:server:dealDrugs', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local gangName = Player.PlayerData.gang.name
    if gangName == 'none' then
        TriggerClientEvent('QBCore:Notify', src, 'You need to be in a gang to deal drugs', 'error')
        return
    end
    
    -- Simple drug dealing mechanic
    local drugTypes = {'weed', 'coke', 'meth'}
    local randomDrug = drugTypes[math.random(#drugTypes)]
    local drugData = Config.DrugDealing.drugs[randomDrug]
    
    if Player.Functions.GetItemByName(randomDrug) then
        Player.Functions.RemoveItem(randomDrug, 1)
        Player.Functions.AddMoney('cash', drugData.price)
        
        TriggerClientEvent('QBCore:Notify', src, 'Sold ' .. randomDrug .. ' for $' .. drugData.price, 'success')
        
        -- Add gang reputation (if you have a reputation system)
        -- Player.Functions.AddGangRep(drugData.rep)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You dont have any drugs to sell', 'error')
    end
end)

-- Gang War System
local activeWars = {}

RegisterCommand('startgangwar', function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player is admin or gang leader
    if not QBCore.Functions.HasPermission(src, 'admin') and Player.PlayerData.gang.grade.level < 5 then
        TriggerClientEvent('QBCore:Notify', src, 'You dont have permission', 'error')
        return
    end
    
    local targetGang = args[1]
    if not targetGang or not Config.Gangs[targetGang] then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid gang name', 'error')
        return
    end
    
    local attackingGang = Player.PlayerData.gang.name
    if attackingGang == targetGang then
        TriggerClientEvent('QBCore:Notify', src, 'You cannot war against your own gang', 'error')
        return
    end
    
    if activeWars[attackingGang] or activeWars[targetGang] then
        TriggerClientEvent('QBCore:Notify', src, 'One of the gangs is already in a war', 'error')
        return
    end
    
    -- Start gang war
    activeWars[attackingGang] = {
        target = targetGang,
        startTime = os.time(),
        attackerScore = 0,
        defenderScore = 0
    }
    
    activeWars[targetGang] = {
        target = attackingGang,
        startTime = os.time(),
        attackerScore = 0,
        defenderScore = 0
    }
    
    TriggerClientEvent('ls-gangs:client:gangWarStarted', -1, Config.Gangs[attackingGang].name, Config.Gangs[targetGang].name)
    
    -- End war after duration
    SetTimeout(Config.GangWars.duration * 1000, function()
        local winner = activeWars[attackingGang].attackerScore > activeWars[attackingGang].defenderScore and attackingGang or targetGang
        
        TriggerClientEvent('ls-gangs:client:gangWarEnded', -1, Config.Gangs[winner].name)
        
        activeWars[attackingGang] = nil
        activeWars[targetGang] = nil
    end)
end, true)

print("^2[LS-GANGS]^7 Gang Management System loaded successfully!")