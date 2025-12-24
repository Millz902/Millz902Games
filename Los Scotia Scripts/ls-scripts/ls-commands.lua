-- Los Scotia Server Commands and Permissions Setup
-- This file contains all commands and permissions for the Los Scotia server scripts

local QBCore = exports['qb-core']:GetCoreObject()

-- ================================================
-- HEISTS SYSTEM COMMANDS
-- ================================================

-- Admin Commands for Heists
QBCore.Commands.Add('startheist', 'Start a heist (Admin Only)', {
    {name = 'type', help = 'Heist type (bank_robbery, jewelry_heist, art_gallery)'},
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player is admin
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
        return
    end
    
    local heistType = args[1]
    TriggerClientEvent('ls-heists:client:StartHeist', src, heistType, GetEntityCoords(GetPlayerPed(src)))
end, 'admin')

QBCore.Commands.Add('resetheists', 'Reset all heist cooldowns (Admin Only)', {}, false, function(source, args)
    local src = source
    
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
        return
    end
    
    TriggerEvent('ls-heists:server:ResetCooldowns')
    TriggerClientEvent('QBCore:Notify', src, 'All heist cooldowns have been reset!', 'success')
end, 'admin')

QBCore.Commands.Add('giveheistitem', 'Give heist items to player (Admin Only)', {
    {name = 'id', help = 'Player ID'},
    {name = 'item', help = 'Item name'},
    {name = 'amount', help = 'Amount (optional)'}
}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    local itemName = args[2]
    local amount = tonumber(args[3]) or 1
    
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found!', 'error')
        return
    end
    
    targetPlayer.Functions.AddItem(itemName, amount)
    TriggerClientEvent('QBCore:Notify', src, string.format('Gave %dx %s to %s', amount, itemName, targetPlayer.PlayerData.name), 'success')
    TriggerClientEvent('QBCore:Notify', targetId, string.format('You received %dx %s from admin', amount, itemName), 'success')
end, 'admin')

-- ================================================
-- POLICE SYSTEM COMMANDS
-- ================================================

-- Duty Commands
QBCore.Commands.Add('duty', 'Toggle police duty', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has police job
    local hasPoliceJob = false
    for _, job in pairs(Config.PoliceJobs or {'police', 'sheriff'}) do
        if Player.PlayerData.job.name == job then
            hasPoliceJob = true
            break
        end
    end
    
    if not hasPoliceJob then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a police officer!', 'error')
        return
    end
    
    TriggerServerEvent('QBCore:ToggleDuty')
end)

-- Police Commands
QBCore.Commands.Add('cuff', 'Handcuff closest player', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.type ~= 'leo' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a police officer!', 'error')
        return
    end
    
    TriggerClientEvent('ls-police:client:CuffPlayer', src)
end, 'police')

QBCore.Commands.Add('uncuff', 'Remove handcuffs from closest player', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.type ~= 'leo' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a police officer!', 'error')
        return
    end
    
    TriggerClientEvent('ls-police:client:UnCuffPlayer', src)
end, 'police')

QBCore.Commands.Add('drag', 'Drag closest player', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.type ~= 'leo' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a police officer!', 'error')
        return
    end
    
    TriggerClientEvent('ls-police:client:DragPlayer', src)
end, 'police')

QBCore.Commands.Add('jail', 'Send player to jail', {
    {name = 'id', help = 'Player ID'},
    {name = 'time', help = 'Time in minutes'}
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local targetId = tonumber(args[1])
    local time = tonumber(args[2])
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.type ~= 'leo' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a police officer!', 'error')
        return
    end
    
    if not targetId or not time then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid arguments!', 'error')
        return
    end
    
    TriggerServerEvent('ls-police:server:JailPlayer', targetId, time)
end, 'police')

QBCore.Commands.Add('unjail', 'Release player from jail', {
    {name = 'id', help = 'Player ID'}
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local targetId = tonumber(args[1])
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.type ~= 'leo' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a police officer!', 'error')
        return
    end
    
    if not targetId then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid player ID!', 'error')
        return
    end
    
    TriggerServerEvent('ls-police:server:UnJailPlayer', targetId)
end, 'police')

QBCore.Commands.Add('fine', 'Issue fine to player', {
    {name = 'id', help = 'Player ID'},
    {name = 'amount', help = 'Fine amount'},
    {name = 'reason', help = 'Reason for fine'}
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    local reason = table.concat(args, ' ', 3)
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.type ~= 'leo' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a police officer!', 'error')
        return
    end
    
    if not targetId or not amount or not reason then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid arguments!', 'error')
        return
    end
    
    TriggerServerEvent('ls-police:server:IssueFine', targetId, amount, reason)
end, 'police')

-- Backup Commands
QBCore.Commands.Add('backup', 'Request backup', {
    {name = 'code', help = 'Priority code (1, 2, or 3)'}
}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local code = tonumber(args[1]) or 2
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.type ~= 'leo' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a police officer!', 'error')
        return
    end
    
    TriggerServerEvent('ls-police:server:RequestBackup', code, GetEntityCoords(GetPlayerPed(src)))
end, 'police')

-- ================================================
-- MEDICAL SYSTEM COMMANDS
-- ================================================

QBCore.Commands.Add('heal', 'Heal closest player', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.name ~= 'ambulance' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a paramedic!', 'error')
        return
    end
    
    TriggerClientEvent('ls-medical:client:HealPlayer', src)
end, 'ambulance')

QBCore.Commands.Add('revive', 'Revive closest player', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.name ~= 'ambulance' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a paramedic!', 'error')
        return
    end
    
    TriggerClientEvent('ls-medical:client:RevivePlayer', src)
end, 'ambulance')

-- ================================================
-- MECHANIC SYSTEM COMMANDS
-- ================================================

QBCore.Commands.Add('repair', 'Repair closest vehicle', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not Player.PlayerData.job or Player.PlayerData.job.name ~= 'mechanic' then
        TriggerClientEvent('QBCore:Notify', src, 'You are not a mechanic!', 'error')
        return
    end
    
    TriggerClientEvent('ls-garage:client:RepairVehicle', src)
end, 'mechanic')

-- ================================================
-- ADMIN COMMANDS
-- ================================================

-- General Admin Commands
QBCore.Commands.Add('giveitem', 'Give item to player', {
    {name = 'id', help = 'Player ID'},
    {name = 'item', help = 'Item name'},
    {name = 'amount', help = 'Amount'}
}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    local itemName = args[2]
    local amount = tonumber(args[3]) or 1
    
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found!', 'error')
        return
    end
    
    targetPlayer.Functions.AddItem(itemName, amount)
    TriggerClientEvent('QBCore:Notify', src, string.format('Gave %dx %s to %s', amount, itemName, targetPlayer.PlayerData.name), 'success')
end, 'admin')

QBCore.Commands.Add('setjob', 'Set player job', {
    {name = 'id', help = 'Player ID'},
    {name = 'job', help = 'Job name'},
    {name = 'grade', help = 'Job grade'}
}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    local jobName = args[2]
    local grade = tonumber(args[3]) or 0
    
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found!', 'error')
        return
    end
    
    targetPlayer.Functions.SetJob(jobName, grade)
    TriggerClientEvent('QBCore:Notify', src, string.format('Set %s job to %s grade %d', targetPlayer.PlayerData.name, jobName, grade), 'success')
end, 'admin')

QBCore.Commands.Add('givemoney', 'Give money to player', {
    {name = 'id', help = 'Player ID'},
    {name = 'type', help = 'Money type (cash, bank, crypto)'},
    {name = 'amount', help = 'Amount'}
}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    local moneyType = args[2]
    local amount = tonumber(args[3])
    
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission!', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found!', 'error')
        return
    end
    
    targetPlayer.Functions.AddMoney(moneyType, amount)
    TriggerClientEvent('QBCore:Notify', src, string.format('Gave $%d %s to %s', amount, moneyType, targetPlayer.PlayerData.name), 'success')
end, 'admin')

-- ================================================
-- GANG SYSTEM COMMANDS
-- ================================================

QBCore.Commands.Add('gangwar', 'Start gang war (Gang Leader Only)', {
    {name = 'target_gang', help = 'Target gang name'}
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local targetGang = args[1]
    
    if not Player or not Player.PlayerData.gang or Player.PlayerData.gang.grade.level < 3 then
        TriggerClientEvent('QBCore:Notify', src, 'You are not authorized to start gang wars!', 'error')
        return
    end
    
    TriggerServerEvent('ls-gangs:server:StartGangWar', targetGang)
end)

-- ================================================
-- BUSINESS SYSTEM COMMANDS
-- ================================================

QBCore.Commands.Add('managebusiness', 'Open business management menu', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    TriggerClientEvent('ls-business:client:OpenManagementMenu', src)
end)

-- ================================================
-- RACING SYSTEM COMMANDS  
-- ================================================

QBCore.Commands.Add('race', 'Racing commands', {
    {name = 'action', help = 'create, join, leave, start'}
}, true, function(source, args)
    local src = source
    local action = args[1]
    
    if not action then
        TriggerClientEvent('QBCore:Notify', src, 'Usage: /race [create/join/leave/start]', 'error')
        return
    end
    
    TriggerClientEvent('ls-racing:client:HandleCommand', src, action, args)
end)

-- ================================================
-- HOUSING SYSTEM COMMANDS
-- ================================================

QBCore.Commands.Add('buyhouse', 'Buy the house you are standing at', {}, false, function(source, args)
    local src = source
    TriggerClientEvent('ls-housing:client:BuyHouse', src)
end)

QBCore.Commands.Add('sellhouse', 'Sell your house', {}, false, function(source, args)
    local src = source
    TriggerClientEvent('ls-housing:client:SellHouse', src)
end)

QBCore.Commands.Add('housekey', 'Give house key to player', {
    {name = 'id', help = 'Player ID'}
}, true, function(source, args)
    local src = source
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid player ID!', 'error')
        return
    end
    
    TriggerServerEvent('ls-housing:server:GiveHouseKey', targetId)
end)

-- ================================================
-- UTILITY COMMANDS
-- ================================================

-- Vehicle Commands
QBCore.Commands.Add('dv', 'Delete closest vehicle', {}, false, function(source, args)
    local src = source
    TriggerClientEvent('QBCore:Command:DeleteVehicle', src)
end)

QBCore.Commands.Add('fix', 'Fix your vehicle', {}, false, function(source, args)
    local src = source
    TriggerClientEvent('QBCore:Command:FixVehicle', src)
end)

-- General Utility
QBCore.Commands.Add('coords', 'Get your coordinates', {}, false, function(source, args)
    local src = source
    TriggerClientEvent('QBCore:Command:GetCoords', src)
end)

QBCore.Commands.Add('heading', 'Get your heading', {}, false, function(source, args)
    local src = source
    TriggerClientEvent('QBCore:Command:GetHeading', src)
end)

-- ================================================
-- EMOTE COMMANDS (if using dpemotes)
-- ================================================

QBCore.Commands.Add('e', 'Play emote', {
    {name = 'emote', help = 'Emote name'}
}, true, function(source, args)
    local src = source
    local emoteName = args[1]
    
    if not emoteName then
        TriggerClientEvent('QBCore:Notify', src, 'You need to specify an emote!', 'error')
        return
    end
    
    TriggerClientEvent('dpemotes:CommandStart', src, args)
end)

QBCore.Commands.Add('walk', 'Change walking style', {
    {name = 'style', help = 'Walking style'}
}, true, function(source, args)
    local src = source
    local walkStyle = args[1]
    
    if not walkStyle then
        TriggerClientEvent('QBCore:Notify', src, 'You need to specify a walking style!', 'error')
        return
    end
    
    TriggerClientEvent('dpemotes:WalkCommandStart', src, args)
end)

-- ================================================
-- LOAD ALL SCRIPTS PERMISSIONS
-- ================================================

-- Ensure all Los Scotia scripts have proper permissions
CreateThread(function()
    Wait(5000) -- Wait for all resources to load
    
    -- Register permissions for all scripts
    QBCore.Functions.AddPermission('police', 'Police Officer')
    QBCore.Functions.AddPermission('ambulance', 'Paramedic')
    QBCore.Functions.AddPermission('mechanic', 'Mechanic')
    QBCore.Functions.AddPermission('admin', 'Administrator')
    QBCore.Functions.AddPermission('mod', 'Moderator')
    QBCore.Functions.AddPermission('god', 'God')
    
    -- Job-specific permissions
    for _, job in pairs({'police', 'sheriff', 'fbi', 'swat'}) do
        QBCore.Functions.AddPermission(job, string.upper(job) .. ' Officer')
    end
    
    print('[LS-COMMANDS] All commands and permissions have been loaded successfully!')
end)