local QBCore = exports['qb-core']:GetCoreObject()
local k9Unit = nil
local k9Following = false

-- K9 Unit Events
RegisterNetEvent('ls-police:client:SpawnK9', function()
    if not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You must be on duty to request K9 unit", "error")
        return
    end
    
    if k9Unit ~= nil then
        QBCore.Functions.Notify("You already have a K9 unit deployed", "error")
        return
    end
    
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local station, distance = exports['ls-police']:GetNearestPoliceStation()
    
    if distance > 100.0 then
        QBCore.Functions.Notify("You must be near a police station to request K9 unit", "error")
        return
    end
    
    local spawnData = Config.K9Spawns[station]
    if not spawnData then
        QBCore.Functions.Notify("K9 unit not available at this station", "error")
        return
    end
    
    QBCore.Functions.Progressbar("spawn_k9", "Requesting K9 unit...", 5000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        local modelHash = GetHashKey(spawnData.model)
        RequestModel(modelHash)
        
        while not HasModelLoaded(modelHash) do
            Wait(100)
        end
        
        k9Unit = CreatePed(28, modelHash, spawnData.coords.x, spawnData.coords.y, spawnData.coords.z, 0.0, true, false)
        SetEntityAsMissionEntity(k9Unit, true, true)
        SetPedFleeAttributes(k9Unit, 0, 0)
        SetPedCombatAttributes(k9Unit, 17, 1)
        SetPedCombatAttributes(k9Unit, 46, 1)
        SetPedSeeingRange(k9Unit, 0.0)
        SetPedHearingRange(k9Unit, 0.0)
        SetPedAlertness(k9Unit, 3)
        SetPedKeepTask(k9Unit, true)
        
        -- Follow player
        TaskFollowToOffsetOfEntity(k9Unit, ped, 0.0, -1.0, 0.0, 5.0, -1, 1.0, 1)
        k9Following = true
        
        QBCore.Functions.Notify("K9 unit deployed", "success")
        SetModelAsNoLongerNeeded(modelHash)
    end, function() -- Cancel
        QBCore.Functions.Notify("K9 request cancelled", "error")
    end)
end)

RegisterNetEvent('ls-police:client:DismissK9', function()
    if k9Unit == nil then
        QBCore.Functions.Notify("No K9 unit to dismiss", "error")
        return
    end
    
    DeleteEntity(k9Unit)
    k9Unit = nil
    k9Following = false
    QBCore.Functions.Notify("K9 unit dismissed", "success")
end)

RegisterNetEvent('ls-police:client:K9Search', function()
    if k9Unit == nil then
        QBCore.Functions.Notify("No K9 unit available", "error")
        return
    end
    
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local searchTarget = nil
    
    if vehicle ~= 0 then
        searchTarget = vehicle
    else
        -- Search nearby players for drugs
        local players = QBCore.Functions.GetPlayersFromCoords(GetEntityCoords(ped), 10.0)
        if #players > 0 then
            searchTarget = GetPlayerPed(GetPlayerFromServerId(players[1].value))
        end
    end
    
    if searchTarget == nil then
        QBCore.Functions.Notify("No search target found", "error")
        return
    end
    
    -- K9 animation and search
    local targetPos = GetEntityCoords(searchTarget)
    TaskGoToCoordAnyMeans(k9Unit, targetPos.x, targetPos.y, targetPos.z, 3.0, 0, 0, 786603, 0xbf800000)
    
    QBCore.Functions.Progressbar("k9_search", "K9 unit searching...", 15000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        -- Random chance to find drugs
        local foundDrugs = math.random(1, 100) <= 30
        
        if foundDrugs then
            QBCore.Functions.Notify("K9 unit detected narcotics!", "error")
            -- Alert animation
            TaskPlayAnim(k9Unit, "creatures@rottweiler@amb@world_dog_barking@idle_a", "idle_a", 8.0, 8.0, -1, 1, 0, false, false, false)
            
            if GetEntityType(searchTarget) == 1 then -- Player
                TriggerServerEvent('ls-police:server:K9Alert', GetPlayerServerId(NetworkGetPlayerIndexFromPed(searchTarget)))
            end
        else
            QBCore.Functions.Notify("K9 unit found nothing suspicious", "primary")
        end
        
        -- Return to follow
        TaskFollowToOffsetOfEntity(k9Unit, ped, 0.0, -1.0, 0.0, 5.0, -1, 1.0, 1)
    end, function() -- Cancel
        QBCore.Functions.Notify("K9 search cancelled", "error")
        TaskFollowToOffsetOfEntity(k9Unit, ped, 0.0, -1.0, 0.0, 5.0, -1, 1.0, 1)
    end)
end)

RegisterNetEvent('ls-police:client:K9Attack', function()
    if k9Unit == nil then
        QBCore.Functions.Notify("No K9 unit available", "error")
        return
    end
    
    local players = QBCore.Functions.GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), 20.0)
    
    if #players == 0 then
        QBCore.Functions.Notify("No targets in range", "error")
        return
    end
    
    local playerMenu = {
        {
            header = "K9 Attack Target",
            isMenuHeader = true,
        }
    }
    
    for i = 1, #players do
        local player = players[i]
        local playerData = QBCore.Functions.GetPlayerData(player.value)
        local name = playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname
        
        playerMenu[#playerMenu + 1] = {
            header = name .. " (" .. player.value .. ")",
            txt = "Distance: " .. math.floor(player.distance) .. "m",
            params = {
                event = "ls-police:client:ExecuteK9Attack",
                args = {
                    targetId = player.value
                }
            }
        }
    end
    
    playerMenu[#playerMenu + 1] = {
        header = "⬅️ Cancel",
        params = {
            event = "qb-menu:closeMenu"
        }
    }
    
    exports['qb-menu']:openMenu(playerMenu)
end)

RegisterNetEvent('ls-police:client:ExecuteK9Attack', function(data)
    local target = GetPlayerPed(GetPlayerFromServerId(data.targetId))
    local targetPos = GetEntityCoords(target)
    
    TaskCombatPed(k9Unit, target, 0, 16)
    QBCore.Functions.Notify("K9 unit attacking target", "primary")
    
    -- Notify target
    TriggerServerEvent('ls-police:server:K9Attack', data.targetId)
end)

-- K9 Commands
RegisterCommand('k9', function()
    if not exports['ls-police']:IsPoliceJob() or not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You don't have access to this command", "error")
        return
    end
    
    local k9Menu = {
        {
            header = "K9 Unit Control",
            isMenuHeader = true,
        }
    }
    
    if k9Unit == nil then
        k9Menu[#k9Menu + 1] = {
            header = "🐕 Deploy K9 Unit",
            txt = "Request K9 unit from station",
            params = {
                event = "ls-police:client:SpawnK9"
            }
        }
    else
        k9Menu[#k9Menu + 1] = {
            header = "🔍 Search",
            txt = "Command K9 to search for narcotics",
            params = {
                event = "ls-police:client:K9Search"
            }
        }
        
        k9Menu[#k9Menu + 1] = {
            header = "⚔️ Attack",
            txt = "Command K9 to attack target",
            params = {
                event = "ls-police:client:K9Attack"
            }
        }
        
        k9Menu[#k9Menu + 1] = {
            header = "📞 Recall",
            txt = "Call K9 back to your position",
            params = {
                event = "ls-police:client:RecallK9"
            }
        }
        
        k9Menu[#k9Menu + 1] = {
            header = "❌ Dismiss",
            txt = "Dismiss the K9 unit",
            params = {
                event = "ls-police:client:DismissK9"
            }
        }
    end
    
    k9Menu[#k9Menu + 1] = {
        header = "⬅️ Close",
        params = {
            event = "qb-menu:closeMenu"
        }
    }
    
    exports['qb-menu']:openMenu(k9Menu)
end, false)

RegisterNetEvent('ls-police:client:RecallK9', function()
    if k9Unit == nil then
        QBCore.Functions.Notify("No K9 unit to recall", "error")
        return
    end
    
    local ped = PlayerPedId()
    TaskFollowToOffsetOfEntity(k9Unit, ped, 0.0, -1.0, 0.0, 5.0, -1, 1.0, 1)
    QBCore.Functions.Notify("K9 unit recalled", "success")
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and k9Unit ~= nil then
        DeleteEntity(k9Unit)
        k9Unit = nil
    end
end)

-- Exports
exports('GetK9Unit', function() return k9Unit end)
exports('HasK9Unit', function() return k9Unit ~= nil end)