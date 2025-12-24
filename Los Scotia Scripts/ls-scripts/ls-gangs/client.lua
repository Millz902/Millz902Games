local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isInGangTerritory = false
local currentGang = nil

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerData.gang = GangInfo
end)

-- Gang Territory System
CreateThread(function()
    while true do
        Wait(1000)
        if PlayerData and PlayerData.gang then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local inTerritory = false
            local territoryGang = nil
            
            for gangName, gangData in pairs(Config.Gangs) do
                local distance = #(playerCoords - gangData.territory)
                if distance <= gangData.radius then
                    inTerritory = true
                    territoryGang = gangName
                    break
                end
            end
            
            if inTerritory and not isInGangTerritory then
                isInGangTerritory = true
                currentGang = territoryGang
                if territoryGang == PlayerData.gang.name then
                    QBCore.Functions.Notify('You entered your gang territory', 'success')
                else
                    QBCore.Functions.Notify('You entered ' .. Config.Gangs[territoryGang].name .. ' territory', 'error')
                end
            elseif not inTerritory and isInGangTerritory then
                isInGangTerritory = false
                currentGang = nil
                QBCore.Functions.Notify('You left gang territory', 'primary')
            end
        end
    end
end)

-- Gang Commands
RegisterCommand('gang', function(source, args)
    if not PlayerData.gang or PlayerData.gang.name == 'none' then
        QBCore.Functions.Notify('You are not in a gang', 'error')
        return
    end
    
    if not args[1] then
        QBCore.Functions.Notify('Available commands: invite, kick, promote, demote, members', 'primary')
        return
    end
    
    local action = args[1]:lower()
    
    if action == 'invite' then
        if PlayerData.gang.grade.level < 3 then
            QBCore.Functions.Notify('You dont have permission to invite members', 'error')
            return
        end
        
        local targetId = tonumber(args[2])
        if not targetId then
            QBCore.Functions.Notify('Invalid player ID', 'error')
            return
        end
        
        TriggerServerEvent('ls-gangs:server:invitePlayer', targetId)
        
    elseif action == 'kick' then
        if PlayerData.gang.grade.level < 4 then
            QBCore.Functions.Notify('You dont have permission to kick members', 'error')
            return
        end
        
        local targetId = tonumber(args[2])
        if not targetId then
            QBCore.Functions.Notify('Invalid player ID', 'error')
            return
        end
        
        TriggerServerEvent('ls-gangs:server:kickPlayer', targetId)
        
    elseif action == 'promote' then
        if PlayerData.gang.grade.level < 4 then
            QBCore.Functions.Notify('You dont have permission to promote members', 'error')
            return
        end
        
        local targetId = tonumber(args[2])
        if not targetId then
            QBCore.Functions.Notify('Invalid player ID', 'error')
            return
        end
        
        TriggerServerEvent('ls-gangs:server:promotePlayer', targetId)
        
    elseif action == 'demote' then
        if PlayerData.gang.grade.level < 4 then
            QBCore.Functions.Notify('You dont have permission to demote members', 'error')
            return
        end
        
        local targetId = tonumber(args[2])
        if not targetId then
            QBCore.Functions.Notify('Invalid player ID', 'error')
            return
        end
        
        TriggerServerEvent('ls-gangs:server:demotePlayer', targetId)
        
    elseif action == 'members' then
        TriggerServerEvent('ls-gangs:server:getMembers')
    end
end)

-- Drug Dealing
RegisterNetEvent('ls-gangs:client:startDrugDeal', function()
    if not Config.DrugDealing.enabled then return end
    
    if not PlayerData.gang or PlayerData.gang.name == 'none' then
        QBCore.Functions.Notify('You need to be in a gang to deal drugs', 'error')
        return
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearLocation = false
    
    for _, location in pairs(Config.DrugDealing.locations) do
        if #(playerCoords - location) <= 5.0 then
            nearLocation = true
            break
        end
    end
    
    if not nearLocation then
        QBCore.Functions.Notify('You need to be at a drug dealing location', 'error')
        return
    end
    
    TriggerServerEvent('ls-gangs:server:dealDrugs')
end)

-- Gang War Events
RegisterNetEvent('ls-gangs:client:gangWarStarted', function(attackingGang, defendingGang)
    QBCore.Functions.Notify('Gang war started: ' .. attackingGang .. ' vs ' .. defendingGang, 'error')
end)

RegisterNetEvent('ls-gangs:client:gangWarEnded', function(winner)
    QBCore.Functions.Notify('Gang war ended. Winner: ' .. winner, 'success')
end)

-- Export functions
exports('IsInGangTerritory', function()
    return isInGangTerritory
end)

exports('GetCurrentTerritory', function()
    return currentGang
end)