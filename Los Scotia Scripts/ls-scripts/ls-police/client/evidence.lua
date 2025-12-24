local QBCore = exports['qb-core']:GetCoreObject()
local evidenceList = {}

-- Evidence Collection
RegisterNetEvent('ls-police:client:CollectEvidence', function()
    if not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You must be on duty to collect evidence", "error")
        return
    end
    
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local evidenceId = "evidence_" .. math.random(10000, 99999)
    
    -- Animation
    RequestAnimDict("amb@world_human_janitor@male@idle_a")
    while not HasAnimDictLoaded("amb@world_human_janitor@male@idle_a") do
        Wait(100)
    end
    
    TaskPlayAnim(ped, "amb@world_human_janitor@male@idle_a", "idle_a", 8.0, 8.0, -1, 1, 0, false, false, false)
    
    QBCore.Functions.Progressbar("collect_evidence", "Collecting evidence...", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(ped)
        
        local evidenceData = {
            id = evidenceId,
            type = "physical",
            location = pos,
            collector = QBCore.Functions.GetPlayerData().citizenid,
            timestamp = os.time(),
            description = "Physical evidence collected at scene"
        }
        
        TriggerServerEvent('ls-police:server:CreateEvidence', evidenceData)
        QBCore.Functions.Notify("Evidence collected: " .. evidenceId, "success")
    end, function() -- Cancel
        ClearPedTasks(ped)
        QBCore.Functions.Notify("Evidence collection cancelled", "error")
    end)
end)

-- DNA Evidence
RegisterNetEvent('ls-police:client:CollectDNA', function(targetId)
    if not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You must be on duty to collect DNA", "error")
        return
    end
    
    local ped = PlayerPedId()
    local target = GetPlayerPed(GetPlayerFromServerId(targetId))
    
    if #(GetEntityCoords(ped) - GetEntityCoords(target)) > 3.0 then
        QBCore.Functions.Notify("Target is too far away", "error")
        return
    end
    
    QBCore.Functions.Progressbar("collect_dna", "Collecting DNA sample...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        local evidenceId = "dna_" .. math.random(10000, 99999)
        local evidenceData = {
            id = evidenceId,
            type = "dna",
            targetId = targetId,
            collector = QBCore.Functions.GetPlayerData().citizenid,
            timestamp = os.time(),
            description = "DNA sample collected from suspect"
        }
        
        TriggerServerEvent('ls-police:server:CreateEvidence', evidenceData)
        QBCore.Functions.Notify("DNA sample collected: " .. evidenceId, "success")
    end, function() -- Cancel
        QBCore.Functions.Notify("DNA collection cancelled", "error")
    end)
end)

-- Fingerprint Evidence
RegisterNetEvent('ls-police:client:TakeFingerprints', function(targetId)
    if not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You must be on duty to take fingerprints", "error")
        return
    end
    
    local ped = PlayerPedId()
    local target = GetPlayerPed(GetPlayerFromServerId(targetId))
    
    if #(GetEntityCoords(ped) - GetEntityCoords(target)) > 3.0 then
        QBCore.Functions.Notify("Target is too far away", "error")
        return
    end
    
    -- Animation
    RequestAnimDict("mp_arresting")
    while not HasAnimDictLoaded("mp_arresting") do
        Wait(100)
    end
    
    TaskPlayAnim(ped, "mp_arresting", "a_uncuff", 8.0, 8.0, -1, 1, 0, false, false, false)
    
    QBCore.Functions.Progressbar("fingerprints", "Taking fingerprints...", 7500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(ped)
        
        local evidenceId = "prints_" .. math.random(10000, 99999)
        local evidenceData = {
            id = evidenceId,
            type = "fingerprints",
            targetId = targetId,
            collector = QBCore.Functions.GetPlayerData().citizenid,
            timestamp = os.time(),
            description = "Fingerprints taken from suspect"
        }
        
        TriggerServerEvent('ls-police:server:CreateEvidence', evidenceData)
        QBCore.Functions.Notify("Fingerprints taken: " .. evidenceId, "success")
    end, function() -- Cancel
        ClearPedTasks(ped)
        QBCore.Functions.Notify("Fingerprint collection cancelled", "error")
    end)
end)

-- Evidence Photos
RegisterNetEvent('ls-police:client:TakeEvidencePhoto', function()
    if not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You must be on duty to take evidence photos", "error")
        return
    end
    
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    -- Create camera
    CreateMobilePhone(0)
    CellCamActivate(true, true)
    
    QBCore.Functions.Notify("Take a photo of the evidence, press ENTER to capture", "primary", 5000)
    
    CreateThread(function()
        while true do
            Wait(0)
            if IsControlJustPressed(0, 176) then -- ENTER
                local evidenceId = "photo_" .. math.random(10000, 99999)
                local evidenceData = {
                    id = evidenceId,
                    type = "photo",
                    location = pos,
                    collector = QBCore.Functions.GetPlayerData().citizenid,
                    timestamp = os.time(),
                    description = "Crime scene photograph"
                }
                
                TriggerServerEvent('ls-police:server:CreateEvidence', evidenceData)
                QBCore.Functions.Notify("Evidence photo taken: " .. evidenceId, "success")
                
                CellCamActivate(false, false)
                DestroyMobilePhone()
                break
            elseif IsControlJustPressed(0, 177) then -- BACKSPACE
                QBCore.Functions.Notify("Photo cancelled", "error")
                CellCamActivate(false, false)
                DestroyMobilePhone()
                break
            end
        end
    end)
end)

-- Evidence Commands
RegisterCommand('evidence', function()
    if not exports['ls-police']:IsPoliceJob() or not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You don't have access to this command", "error")
        return
    end
    
    local evidenceMenu = {
        {
            header = "Evidence Collection",
            isMenuHeader = true,
        },
        {
            header = "🔍 Collect Physical Evidence",
            txt = "Collect evidence from the scene",
            params = {
                event = "ls-police:client:CollectEvidence"
            }
        },
        {
            header = "📸 Take Evidence Photo",
            txt = "Photograph crime scene evidence",
            params = {
                event = "ls-police:client:TakeEvidencePhoto"
            }
        },
        {
            header = "🧬 Collect DNA Sample",
            txt = "Collect DNA from nearby player",
            params = {
                event = "ls-police:client:GetNearbyPlayers",
                args = { action = "dna" }
            }
        },
        {
            header = "👆 Take Fingerprints",
            txt = "Take fingerprints from nearby player",
            params = {
                event = "ls-police:client:GetNearbyPlayers",
                args = { action = "fingerprints" }
            }
        },
        {
            header = "⬅️ Close",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }
    
    exports['qb-menu']:openMenu(evidenceMenu)
end, false)

-- Get Nearby Players for Evidence Collection
RegisterNetEvent('ls-police:client:GetNearbyPlayers', function(data)
    local players = QBCore.Functions.GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), 5.0)
    
    if #players == 0 then
        QBCore.Functions.Notify("No players nearby", "error")
        return
    end
    
    local playerMenu = {
        {
            header = "Select Player",
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
                event = data.action == "dna" and "ls-police:client:CollectDNA" or "ls-police:client:TakeFingerprints",
                args = player.value
            }
        }
    end
    
    playerMenu[#playerMenu + 1] = {
        header = "⬅️ Back",
        params = {
            event = "evidence"
        }
    }
    
    exports['qb-menu']:openMenu(playerMenu)
end)

-- Exports
exports('GetEvidenceList', function() return evidenceList end)