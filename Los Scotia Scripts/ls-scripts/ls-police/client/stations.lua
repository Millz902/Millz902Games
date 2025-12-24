local QBCore = exports['qb-core']:GetCoreObject()

-- Police Station Interactions
CreateThread(function()
    for stationName, station in pairs(Config.PoliceStations) do
        -- Duty Toggle Point
        exports['qb-target']:AddBoxZone("police_duty_" .. stationName, station.coords, 2.0, 2.0, {
            name = "police_duty_" .. stationName,
            heading = 0,
            debugPoly = false,
            minZ = station.coords.z - 1,
            maxZ = station.coords.z + 3,
        }, {
            options = {
                {
                    type = "client",
                    event = "ls-police:client:ToggleDuty",
                    icon = "fas fa-sign-in-alt",
                    label = "Toggle Duty Status",
                    job = Config.PoliceJobs,
                },
            },
            distance = 2.5
        })

        -- Evidence Storage
        if Config.EvidenceStorage[stationName] then
            local evidenceCoords = Config.EvidenceStorage[stationName].coords
            exports['qb-target']:AddBoxZone("evidence_storage_" .. stationName, evidenceCoords, 2.0, 2.0, {
                name = "evidence_storage_" .. stationName,
                heading = 0,
                debugPoly = false,
                minZ = evidenceCoords.z - 1,
                maxZ = evidenceCoords.z + 3,
            }, {
                options = {
                    {
                        type = "client",
                        event = "ls-police:client:OpenEvidenceStorage",
                        icon = "fas fa-archive",
                        label = "Evidence Storage",
                        job = Config.PoliceJobs,
                        station = stationName
                    },
                },
                distance = 2.5
            })
        end

        -- Armory Access
        if Config.Armory[stationName] then
            local armoryCoords = Config.Armory[stationName].coords
            exports['qb-target']:AddBoxZone("police_armory_" .. stationName, armoryCoords, 2.0, 2.0, {
                name = "police_armory_" .. stationName,
                heading = 0,
                debugPoly = false,
                minZ = armoryCoords.z - 1,
                maxZ = armoryCoords.z + 3,
            }, {
                options = {
                    {
                        type = "client",
                        event = "ls-police:client:OpenArmory",
                        icon = "fas fa-shield-alt",
                        label = "Police Armory",
                        job = Config.PoliceJobs,
                        station = stationName
                    },
                },
                distance = 2.5
            })
        end
    end
end)

-- Evidence Storage Event
RegisterNetEvent('ls-police:client:OpenEvidenceStorage', function(data)
    if not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You must be on duty to access evidence storage", "error")
        return
    end
    
    local stash = "police_evidence_" .. data.station
    TriggerServerEvent("inventory:server:OpenInventory", "stash", stash, {
        maxweight = Config.EvidenceStorage[data.station].maxWeight,
        slots = Config.EvidenceStorage[data.station].maxSlots,
    })
    TriggerEvent("inventory:client:SetCurrentStash", stash)
end)

-- Station Helper Functions
function GetNearestPoliceStation()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local closestStation = nil
    local closestDistance = math.huge
    
    for stationName, station in pairs(Config.PoliceStations) do
        local distance = #(pos - station.coords)
        if distance < closestDistance then
            closestDistance = distance
            closestStation = stationName
        end
    end
    
    return closestStation, closestDistance
end

function IsNearPoliceStation()
    local _, distance = GetNearestPoliceStation()
    return distance < 50.0
end

-- Exports
exports('GetNearestPoliceStation', GetNearestPoliceStation)
exports('IsNearPoliceStation', IsNearPoliceStation)