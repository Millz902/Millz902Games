local QBCore = exports['qb-core']:GetCoreObject()
local onDutyOfficers = {}

-- Player Events
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData.job and table.contains(Config.PoliceJobs, Player.PlayerData.job.name) then
        -- Initialize police officer
    end
end)

RegisterNetEvent('QBCore:Server:OnJobUpdate', function(source, job)
    local src = source
    if job and table.contains(Config.PoliceJobs, job.name) then
        -- Player joined police force
    else
        -- Player left police force
        onDutyOfficers[src] = nil
    end
end)

-- Duty System
RegisterNetEvent('ls-police:server:UpdateDutyStatus', function(onDuty)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if onDuty then
        onDutyOfficers[src] = {
            citizenid = Player.PlayerData.citizenid,
            name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
            callsign = Player.PlayerData.job.grade.level .. "-" .. string.upper(string.sub(Player.PlayerData.charinfo.firstname, 1, 1)) .. string.upper(string.sub(Player.PlayerData.charinfo.lastname, 1, 1)),
            rank = Player.PlayerData.job.grade.name
        }
    else
        onDutyOfficers[src] = nil
    end
    
    -- Update all clients with duty status
    TriggerClientEvent('ls-police:client:UpdateDutyList', -1, onDutyOfficers)
end)

-- Armory System
RegisterNetEvent('ls-police:server:GiveWeapon', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    local weapon = data.weapon
    local ammo = data.ammo
    
    if Player.Functions.AddItem(weapon, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[weapon], "add")
        if ammo > 0 then
            Player.Functions.AddItem(weapon .. "_ammo", ammo)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[weapon .. "_ammo"], "add")
        end
    end
end)

RegisterNetEvent('ls-police:server:GiveItem', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    local item = data.item
    local amount = data.amount
    
    if Player.Functions.AddItem(item, amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
    end
end)

-- Vehicle System
RegisterNetEvent('ls-police:server:CheckVehicle', function(plate, position)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    -- Check for stolen vehicles, BOLOs, etc.
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?', {plate}, function(result)
        if result[1] then
            local vehicle = result[1]
            -- Check if vehicle is reported stolen
            MySQL.Async.fetchAll('SELECT * FROM police_reports WHERE vehicle_plate = ? AND report_type = ?', {plate, 'stolen_vehicle'}, function(reports)
                if reports[1] then
                    TriggerClientEvent('ls-police:client:VehicleAlert', src, {
                        plate = plate,
                        status = 'stolen',
                        owner = vehicle.owner,
                        position = position
                    })
                end
            end)
        end
    end)
end)

-- Alert System
RegisterNetEvent('ls-police:server:CreateAlert', function(alertData)
    local src = source
    
    -- Send alert to all on-duty officers
    for officerId, officer in pairs(onDutyOfficers) do
        TriggerClientEvent('ls-police:client:ReceiveAlert', officerId, alertData)
    end
    
    -- Log alert in database
    MySQL.Async.insert('INSERT INTO police_alerts (type, location, description, created_by, created_at) VALUES (?, ?, ?, ?, ?)', {
        alertData.type,
        json.encode(alertData.location),
        alertData.description,
        src,
        os.time()
    })
end)

-- Evidence System
RegisterNetEvent('ls-police:server:CreateEvidence', function(evidenceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    MySQL.Async.insert('INSERT INTO police_evidence (evidence_id, type, data, collector, location, created_at) VALUES (?, ?, ?, ?, ?, ?)', {
        evidenceData.id,
        evidenceData.type,
        json.encode(evidenceData),
        Player.PlayerData.citizenid,
        json.encode(evidenceData.location or {}),
        os.time()
    }, function(insertId)
        TriggerClientEvent('QBCore:Notify', src, 'Evidence logged in database', 'success')
    end)
end)

-- K9 System
RegisterNetEvent('ls-police:server:K9Alert', function(targetId)
    local target = QBCore.Functions.GetPlayer(targetId)
    if target then
        TriggerClientEvent('QBCore:Notify', targetId, 'K9 unit is alerting on you!', 'error')
    end
end)

RegisterNetEvent('ls-police:server:K9Attack', function(targetId)
    local target = QBCore.Functions.GetPlayer(targetId)
    if target then
        TriggerClientEvent('QBCore:Notify', targetId, 'K9 unit is attacking you!', 'error')
        TriggerClientEvent('ls-police:client:K9AttackEffect', targetId)
    end
end)

-- Callbacks
QBCore.Functions.CreateCallback('ls-police:server:GetOnDutyOfficers', function(source, cb)
    cb(onDutyOfficers)
end)

QBCore.Functions.CreateCallback('ls-police:server:GetPoliceCount', function(source, cb)
    local count = 0
    for k, v in pairs(onDutyOfficers) do
        count = count + 1
    end
    cb(count)
end)

-- Commands
QBCore.Commands.Add('duty', 'Toggle police duty status', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and IsPoliceJob(Player.PlayerData.job.name) then
        TriggerClientEvent('ls-police:client:ToggleDuty', source)
    else
        TriggerClientEvent('QBCore:Notify', source, 'You are not a police officer', 'error')
    end
end)

QBCore.Commands.Add('backup', 'Request police backup', {{name = 'code', help = 'Backup code (1-3)'}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and IsPoliceJob(Player.PlayerData.job.name) then
        local code = tonumber(args[1]) or 2
        local pos = GetEntityCoords(GetPlayerPed(source))
        
        local alertData = {
            type = 'backup',
            code = code,
            location = pos,
            description = 'Officer requesting backup - Code ' .. code,
            officer = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
            callsign = onDutyOfficers[source] and onDutyOfficers[source].callsign or "Unknown"
        }
        
        TriggerEvent('ls-police:server:CreateAlert', alertData)
        TriggerClientEvent('QBCore:Notify', source, 'Backup requested - Code ' .. code, 'primary')
    else
        TriggerClientEvent('QBCore:Notify', source, 'You are not a police officer', 'error')
    end
end)

-- Utility Functions
function IsPoliceJob(job)
    return table.contains(Config.PoliceJobs, job)
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Database Tables Creation
CreateThread(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `police_alerts` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `type` varchar(50) NOT NULL,
            `location` text,
            `description` text,
            `created_by` int(11),
            `created_at` int(11),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `police_evidence` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `evidence_id` varchar(100) NOT NULL,
            `type` varchar(50) NOT NULL,
            `data` text,
            `collector` varchar(50),
            `location` text,
            `created_at` int(11),
            PRIMARY KEY (`id`),
            UNIQUE KEY `evidence_id` (`evidence_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `police_reports` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `report_id` varchar(100) NOT NULL,
            `report_type` varchar(50) NOT NULL,
            `title` varchar(255),
            `description` text,
            `officer` varchar(50),
            `suspects` text,
            `evidence` text,
            `vehicle_plate` varchar(10),
            `created_at` int(11),
            `updated_at` int(11),
            PRIMARY KEY (`id`),
            UNIQUE KEY `report_id` (`report_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `police_bolos` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `bolo_id` varchar(100) NOT NULL,
            `type` varchar(50) NOT NULL,
            `title` varchar(255),
            `description` text,
            `plate` varchar(10),
            `person_id` varchar(50),
            `officer` varchar(50),
            `active` tinyint(1) DEFAULT 1,
            `created_at` int(11),
            PRIMARY KEY (`id`),
            UNIQUE KEY `bolo_id` (`bolo_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

-- Exports
exports('GetOnDutyOfficers', function() return onDutyOfficers end)
exports('GetPoliceCount', function() 
    local count = 0
    for k, v in pairs(onDutyOfficers) do
        count = count + 1
    end
    return count
end)
exports('IsPoliceJob', IsPoliceJob)