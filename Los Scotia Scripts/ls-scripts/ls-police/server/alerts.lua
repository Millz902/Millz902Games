local QBCore = exports['qb-core']:GetCoreObject()
local activeAlerts = {}

-- Alert Creation and Management
RegisterNetEvent('ls-police:server:CreateAlert', function(alertData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not alertData or not alertData.type then
        return
    end
    
    -- Generate unique alert ID
    local alertId = "alert_" .. math.random(10000, 99999)
    alertData.id = alertId
    alertData.source = src
    alertData.timestamp = os.time()
    
    if Player then
        alertData.reporter = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        alertData.citizenid = Player.PlayerData.citizenid
    end
    
    -- Add to active alerts
    activeAlerts[alertId] = alertData
    
    -- Send to all on-duty officers
    local officers = exports['ls-police']:GetOnDutyOfficers()
    for officerId, officer in pairs(officers) do
        TriggerClientEvent('ls-police:client:ReceiveAlert', officerId, alertData)
    end
    
    -- Log in database
    MySQL.Async.insert('INSERT INTO police_alerts (alert_id, type, location, description, created_by, reporter_name, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        alertId,
        alertData.type,
        json.encode(alertData.location or {}),
        alertData.description or '',
        src,
        alertData.reporter or 'Unknown',
        os.time()
    })
    
    -- Auto-remove alert after configured time
    SetTimeout(Config.Alerts.fadeTime, function()
        if activeAlerts[alertId] then
            activeAlerts[alertId] = nil
            TriggerClientEvent('ls-police:client:RemoveAlert', -1, alertId)
        end
    end)
end)

-- Panic Button Alert
RegisterNetEvent('ls-police:server:PanicButton', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    
    local alertData = {
        type = 'panic',
        location = coords,
        description = 'OFFICER DOWN - EMERGENCY ASSISTANCE REQUIRED',
        priority = 'HIGH',
        officer = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
        callsign = GetOfficerCallsign(src),
        blipColor = 1, -- Red
        blipSprite = 161
    }
    
    TriggerEvent('ls-police:server:CreateAlert', alertData)
    
    -- Send emergency notification to all officers
    local officers = exports['ls-police']:GetOnDutyOfficers()
    for officerId, officer in pairs(officers) do
        if officerId ~= src then
            TriggerClientEvent('QBCore:Notify', officerId, '🚨 OFFICER DOWN: ' .. alertData.officer, 'error', 10000)
            TriggerClientEvent('ls-police:client:PlayPanicSound', officerId)
        end
    end
end)

-- Robbery Alerts
RegisterNetEvent('ls-police:server:RobberyAlert', function(location, business)
    local alertData = {
        type = 'robbery',
        location = location,
        description = 'Armed robbery in progress at ' .. (business or 'unknown location'),
        priority = 'HIGH',
        blipColor = 1, -- Red
        blipSprite = 161,
        automatic = true
    }
    
    TriggerEvent('ls-police:server:CreateAlert', alertData)
end)

-- Shooting Alerts
RegisterNetEvent('ls-police:server:ShootingAlert', function(location, weapon)
    local alertData = {
        type = 'shooting',
        location = location,
        description = 'Shots fired - ' .. (weapon and QBCore.Shared.Weapons[weapon].label or 'Unknown weapon'),
        priority = 'HIGH',
        blipColor = 1, -- Red
        blipSprite = 110,
        automatic = true
    }
    
    TriggerEvent('ls-police:server:CreateAlert', alertData)
end)

-- Vehicle Theft Alerts
RegisterNetEvent('ls-police:server:VehicleTheftAlert', function(location, vehicle, plate)
    local alertData = {
        type = 'vehicle_theft',
        location = location,
        description = 'Vehicle theft reported - ' .. (vehicle or 'Unknown vehicle') .. ' | Plate: ' .. (plate or 'Unknown'),
        priority = 'MEDIUM',
        blipColor = 17, -- Orange
        blipSprite = 225,
        vehicleData = {
            model = vehicle,
            plate = plate
        }
    }
    
    TriggerEvent('ls-police:server:CreateAlert', alertData)
end)

-- Drug Activity Alerts
RegisterNetEvent('ls-police:server:DrugAlert', function(location, activity)
    local alertData = {
        type = 'drug_activity',
        location = location,
        description = 'Suspicious drug activity reported - ' .. (activity or 'Unknown activity'),
        priority = 'MEDIUM',
        blipColor = 5, -- Yellow
        blipSprite = 514,
        automatic = false
    }
    
    TriggerEvent('ls-police:server:CreateAlert', alertData)
end)

-- Speed Camera Alerts
RegisterNetEvent('ls-police:server:SpeedCameraAlert', function(location, speed, limit, plate)
    local alertData = {
        type = 'speeding',
        location = location,
        description = 'Speed violation detected - ' .. speed .. ' MPH in ' .. limit .. ' MPH zone | Plate: ' .. plate,
        priority = 'LOW',
        blipColor = 5, -- Yellow
        blipSprite = 380,
        automatic = true,
        vehicleData = {
            plate = plate,
            speed = speed,
            limit = limit
        }
    }
    
    TriggerEvent('ls-police:server:CreateAlert', alertData)
end)

-- Alert Response
RegisterNetEvent('ls-police:server:RespondToAlert', function(alertId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    if activeAlerts[alertId] then
        local alert = activeAlerts[alertId]
        alert.respondingOfficer = src
        alert.respondingOfficerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        alert.responseTime = os.time()
        
        -- Notify all officers
        local officers = exports['ls-police']:GetOnDutyOfficers()
        for officerId, officer in pairs(officers) do
            TriggerClientEvent('ls-police:client:UpdateAlert', officerId, alert)
        end
        
        -- Update database
        MySQL.Async.execute('UPDATE police_alerts SET responding_officer = ?, response_time = ? WHERE alert_id = ?', {
            src,
            os.time(),
            alertId
        })
        
        TriggerClientEvent('QBCore:Notify', src, 'Responding to alert: ' .. alert.description, 'primary')
    end
end)

-- Clear Alert
RegisterNetEvent('ls-police:server:ClearAlert', function(alertId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    if activeAlerts[alertId] then
        activeAlerts[alertId] = nil
        
        -- Remove from all clients
        TriggerClientEvent('ls-police:client:RemoveAlert', -1, alertId)
        
        -- Update database
        MySQL.Async.execute('UPDATE police_alerts SET cleared_by = ?, cleared_at = ? WHERE alert_id = ?', {
            src,
            os.time(),
            alertId
        })
        
        TriggerClientEvent('QBCore:Notify', src, 'Alert cleared', 'success')
    end
end)

-- Get Active Alerts
QBCore.Functions.CreateCallback('ls-police:server:GetActiveAlerts', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        cb({})
        return
    end
    
    cb(activeAlerts)
end)

-- Alert History
QBCore.Functions.CreateCallback('ls-police:server:GetAlertHistory', function(source, cb, filters)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        cb({})
        return
    end
    
    local query = 'SELECT * FROM police_alerts'
    local params = {}
    
    if filters then
        local conditions = {}
        
        if filters.type then
            table.insert(conditions, 'type = ?')
            table.insert(params, filters.type)
        end
        
        if filters.dateFrom then
            table.insert(conditions, 'created_at >= ?')
            table.insert(params, filters.dateFrom)
        end
        
        if filters.dateTo then
            table.insert(conditions, 'created_at <= ?')
            table.insert(params, filters.dateTo)
        end
        
        if #conditions > 0 then
            query = query .. ' WHERE ' .. table.concat(conditions, ' AND ')
        end
    end
    
    query = query .. ' ORDER BY created_at DESC LIMIT 100'
    
    MySQL.Async.fetchAll(query, params, function(result)
        cb(result)
    end)
end)

-- Utility Functions
function GetOfficerCallsign(playerId)
    local officers = exports['ls-police']:GetOnDutyOfficers()
    if officers[playerId] then
        return officers[playerId].callsign
    end
    return "Unknown"
end

-- Commands
QBCore.Commands.Add('panic', 'Send emergency panic alert', {}, false, function(source, args)
    TriggerEvent('ls-police:server:PanicButton', source)
end)

QBCore.Commands.Add('alerts', 'View active police alerts', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        TriggerClientEvent('ls-police:client:OpenAlertsMenu', source)
    else
        TriggerClientEvent('QBCore:Notify', source, 'You are not a police officer', 'error')
    end
end)

-- Update database schema
CreateThread(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `police_alerts` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `alert_id` varchar(100) NOT NULL,
            `type` varchar(50) NOT NULL,
            `location` text,
            `description` text,
            `priority` varchar(20) DEFAULT 'MEDIUM',
            `created_by` int(11),
            `reporter_name` varchar(100),
            `responding_officer` int(11),
            `cleared_by` int(11),
            `created_at` int(11),
            `response_time` int(11),
            `cleared_at` int(11),
            PRIMARY KEY (`id`),
            UNIQUE KEY `alert_id` (`alert_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)