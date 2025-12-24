local QBCore = exports['qb-core']:GetCoreObject()

-- ================================================
-- VARIABLES
-- ================================================

local OnDutyPlayers = {}
local HandcuffedPlayers = {}
local JailedPlayers = {}

-- ================================================
-- UTILITY FUNCTIONS
-- ================================================

local function IsPoliceJob(Player)
    if not Player or not Player.PlayerData.job then return false end
    for _, job in pairs(Config.PoliceJobs) do
        if Player.PlayerData.job.name == job then
            return true
        end
    end
    return false
end

local function GetPoliceCallsign(Player)
    local rank = Player.PlayerData.job.grade.name or 'Officer'
    local badge = Player.PlayerData.metadata.callsign or Player.PlayerData.citizenid:sub(-3)
    return string.format('%s-%s', rank:sub(1, 3):upper(), badge)
end

-- ================================================
-- DUTY SYSTEM
-- ================================================

RegisterNetEvent('ls-police:server:UpdateDutyStatus', function(onDuty)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not IsPoliceJob(Player) then return end
    
    if onDuty then
        OnDutyPlayers[src] = {
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            callsign = GetPoliceCallsign(Player),
            rank = Player.PlayerData.job.grade.name,
            coords = GetEntityCoords(GetPlayerPed(src))
        }
        
        -- Notify all police
        for playerId, _ in pairs(OnDutyPlayers) do
            TriggerClientEvent('QBCore:Notify', playerId, string.format('%s is now on duty', OnDutyPlayers[src].callsign), 'primary')
        end
    else
        if OnDutyPlayers[src] then
            local callsign = OnDutyPlayers[src].callsign
            OnDutyPlayers[src] = nil
            
            -- Notify all police
            for playerId, _ in pairs(OnDutyPlayers) do
                TriggerClientEvent('QBCore:Notify', playerId, string.format('%s is now off duty', callsign), 'primary')
            end
        end
    end
end)

-- ================================================
-- HANDCUFF SYSTEM
-- ================================================

RegisterNetEvent('ls-police:server:CuffPlayer', function(targetId, isSoftcuff)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then return end
    if not IsPoliceJob(Player) or not Player.PlayerData.job.onduty then
        return
    end
    
    -- Check if player has handcuffs
    local hasHandcuffs = Player.Functions.GetItemByName('handcuffs')
    if not hasHandcuffs then
        TriggerClientEvent('QBCore:Notify', src, 'You need handcuffs!', 'error')
        return
    end
    
    TriggerClientEvent('ls-police:client:GetCuffed', targetId, src, isSoftcuff)
    HandcuffedPlayers[targetId] = src
end)

RegisterNetEvent('ls-police:server:UnCuffPlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then return end
    if not IsPoliceJob(Player) or not Player.PlayerData.job.onduty then
        return
    end
    
    TriggerClientEvent('ls-police:client:GetCuffed', targetId, src, false)
    HandcuffedPlayers[targetId] = nil
end)

RegisterNetEvent('ls-police:server:SetHandcuffStatus', function(isHandcuffed)
    local src = source
    if isHandcuffed then
        HandcuffedPlayers[src] = true
    else
        HandcuffedPlayers[src] = nil
    end
end)

-- ================================================
-- DRAGGING SYSTEM
-- ================================================

RegisterNetEvent('ls-police:server:DragPlayer', function(targetId, isDragging)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then return end
    if not IsPoliceJob(Player) or not Player.PlayerData.job.onduty then
        return
    end
    
    -- Check if target is handcuffed
    if not HandcuffedPlayers[targetId] then
        TriggerClientEvent('QBCore:Notify', src, 'Player must be handcuffed first!', 'error')
        return
    end
    
    if isDragging then
        TriggerClientEvent('ls-police:client:GetDragged', targetId, src)
    else
        TriggerClientEvent('ls-police:client:GetDragged', targetId, nil)
    end
end)

-- ================================================
-- JAIL SYSTEM
-- ================================================

RegisterNetEvent('ls-police:server:JailPlayer', function(targetId, time)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then return end
    if not IsPoliceJob(Player) or not Player.PlayerData.job.onduty then
        return
    end
    
    -- Minimum rank check for jailing
    if Player.PlayerData.job.grade.level < 2 then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission to jail players!', 'error')
        return
    end
    
    time = math.max(1, math.min(time, Config.MaxJailTime or 60)) -- Max 60 minutes
    
    -- Set player to jail location
    local jailCoords = Config.JailLocation or vector3(1641.5, 2571.3, 45.56)
    SetEntityCoords(GetPlayerPed(targetId), jailCoords.x, jailCoords.y, jailCoords.z)
    
    -- Store jail data
    JailedPlayers[targetId] = {
        time = time * 60, -- Convert to seconds
        jailedBy = GetPoliceCallsign(Player),
        reason = 'Criminal activities'
    }
    
    -- Remove weapons and handcuffs
    TriggerClientEvent('QBCore:Client:SetWeaponAmmo', targetId, 'all', 0)
    if HandcuffedPlayers[targetId] then
        TriggerClientEvent('ls-police:client:GetCuffed', targetId, src, false)
        HandcuffedPlayers[targetId] = nil
    end
    
    TriggerClientEvent('QBCore:Notify', src, string.format('Jailed %s for %d minutes', TargetPlayer.PlayerData.charinfo.firstname, time), 'success')
    TriggerClientEvent('QBCore:Notify', targetId, string.format('You have been jailed for %d minutes', time), 'error')
end)

RegisterNetEvent('ls-police:server:UnJailPlayer', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then return end
    if not IsPoliceJob(Player) or not Player.PlayerData.job.onduty then
        return
    end
    
    if not JailedPlayers[targetId] then
        TriggerClientEvent('QBCore:Notify', src, 'Player is not jailed!', 'error')
        return
    end
    
    -- Release player
    local releaseCoords = Config.JailReleaseLocation or vector3(1850.5, 2604.8, 45.56)
    SetEntityCoords(GetPlayerPed(targetId), releaseCoords.x, releaseCoords.y, releaseCoords.z)
    
    JailedPlayers[targetId] = nil
    
    TriggerClientEvent('QBCore:Notify', src, string.format('Released %s from jail', TargetPlayer.PlayerData.charinfo.firstname), 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 'You have been released from jail', 'success')
end)

-- Jail timer system
CreateThread(function()
    while true do
        for playerId, jailData in pairs(JailedPlayers) do
            if QBCore.Functions.GetPlayer(playerId) then
                jailData.time = jailData.time - 60
                
                if jailData.time <= 0 then
                    -- Auto release
                    local releaseCoords = Config.JailReleaseLocation or vector3(1850.5, 2604.8, 45.56)
                    SetEntityCoords(GetPlayerPed(playerId), releaseCoords.x, releaseCoords.y, releaseCoords.z)
                    
                    JailedPlayers[playerId] = nil
                    TriggerClientEvent('QBCore:Notify', playerId, 'You have been released from jail', 'success')
                elseif jailData.time % 300 == 0 then -- Every 5 minutes
                    local minutes = math.ceil(jailData.time / 60)
                    TriggerClientEvent('QBCore:Notify', playerId, string.format('Time remaining: %d minutes', minutes), 'primary')
                end
            else
                JailedPlayers[playerId] = nil
            end
        end
        Wait(60000) -- Check every minute
    end
end)

-- ================================================
-- FINE SYSTEM
-- ================================================

RegisterNetEvent('ls-police:server:IssueFine', function(targetId, amount, reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then return end
    if not IsPoliceJob(Player) or not Player.PlayerData.job.onduty then
        return
    end
    
    amount = math.max(50, math.min(amount, Config.MaxFineAmount or 10000))
    
    -- Remove money from target
    if TargetPlayer.PlayerData.money.bank >= amount then
        TargetPlayer.Functions.RemoveMoney('bank', amount, 'Police fine: ' .. reason)
    elseif TargetPlayer.PlayerData.money.cash >= amount then
        TargetPlayer.Functions.RemoveMoney('cash', amount, 'Police fine: ' .. reason)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player doesn\'t have enough money!', 'error')
        return
    end
    
    -- Add to society fund (if available)
    if exports['qb-management'] then
        exports['qb-management']:AddMoney(Player.PlayerData.job.name, amount)
    end
    
    TriggerClientEvent('QBCore:Notify', src, string.format('Issued $%d fine to %s', amount, TargetPlayer.PlayerData.charinfo.firstname), 'success')
    TriggerClientEvent('QBCore:Notify', targetId, string.format('You received a $%d fine for: %s', amount, reason), 'error')
end)

-- ================================================
-- BACKUP SYSTEM
-- ================================================

RegisterNetEvent('ls-police:server:RequestBackup', function(code, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not IsPoliceJob(Player) or not Player.PlayerData.job.onduty then
        return
    end
    
    local callsign = GetPoliceCallsign(Player)
    
    -- Send to all on-duty police
    for playerId, playerData in pairs(OnDutyPlayers) do
        if playerId ~= src then
            TriggerClientEvent('ls-police:client:ShowBackupRequest', playerId, coords, code, callsign)
        end
    end
    
    TriggerClientEvent('QBCore:Notify', src, string.format('Code %d backup requested', code), 'success')
end)

-- ================================================
-- EVIDENCE SYSTEM
-- ================================================

RegisterNetEvent('ls-police:server:CollectEvidence', function(evidenceType, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not IsPoliceJob(Player) or not Player.PlayerData.job.onduty then
        return
    end
    
    -- Check if player has evidence bags
    local hasEvidenceBag = Player.Functions.GetItemByName('evidence_bag')
    if not hasEvidenceBag then
        TriggerClientEvent('QBCore:Notify', src, 'You need evidence bags!', 'error')
        return
    end
    
    -- Remove evidence bag and add evidence
    Player.Functions.RemoveItem('evidence_bag', 1)
    
    local evidenceItem = string.format('evidence_%s', evidenceType)
    Player.Functions.AddItem(evidenceItem, 1, false, {
        collected_by = GetPoliceCallsign(Player),
        location = coords,
        time = os.date('%Y-%m-%d %H:%M:%S')
    })
    
    TriggerClientEvent('QBCore:Notify', src, string.format('Collected %s evidence', evidenceType), 'success')
end)

-- ================================================
-- VEHICLE SYSTEM
-- ================================================

RegisterNetEvent('ls-police:server:ImpoundVehicle', function(plate, reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not IsPoliceJob(Player) or not Player.PlayerData.job.onduty then
        return
    end
    
    -- Add to impound database (requires qb-vehicleshop or similar)
    if exports['qb-vehicleshop'] then
        exports['qb-vehicleshop']:ImpoundVehicle(plate, reason, Player.PlayerData.citizenid)
    end
    
    TriggerClientEvent('QBCore:Notify', src, string.format('Vehicle %s has been impounded', plate), 'success')
end)

-- ================================================
-- CLEAN UP ON DISCONNECT
-- ================================================

AddEventHandler('playerDropped', function()
    local src = source
    OnDutyPlayers[src] = nil
    HandcuffedPlayers[src] = nil
    JailedPlayers[src] = nil
end)

-- ================================================
-- EXPORTS
-- ================================================

exports('IsPlayerOnDuty', function(playerId)
    return OnDutyPlayers[playerId] ~= nil
end)

exports('IsPlayerHandcuffed', function(playerId)
    return HandcuffedPlayers[playerId] ~= nil
end)

exports('IsPlayerJailed', function(playerId)
    return JailedPlayers[playerId] ~= nil
end)

exports('GetOnDutyPlayers', function()
    return OnDutyPlayers
end)

exports('GetPoliceCallsign', GetPoliceCallsign)