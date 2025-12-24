local QBCore = exports['qb-core']:GetCoreObject()

-- MDT Server Functions
QBCore.Functions.CreateCallback('ls-police:server:SearchCitizen', function(source, cb, search)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        cb({})
        return
    end
    
    local searchTerm = '%' .. search .. '%'
    
    MySQL.Async.fetchAll([[
        SELECT 
            citizenid,
            charinfo,
            job,
            metadata
        FROM players 
        WHERE JSON_EXTRACT(charinfo, '$.firstname') LIKE ? 
           OR JSON_EXTRACT(charinfo, '$.lastname') LIKE ?
           OR citizenid LIKE ?
        LIMIT 10
    ]], {searchTerm, searchTerm, searchTerm}, function(result)
        local citizens = {}
        
        for i = 1, #result do
            local row = result[i]
            local charinfo = json.decode(row.charinfo)
            local metadata = json.decode(row.metadata or '{}')
            
            table.insert(citizens, {
                citizenid = row.citizenid,
                firstname = charinfo.firstname,
                lastname = charinfo.lastname,
                birthdate = charinfo.birthdate,
                gender = charinfo.gender,
                phone = charinfo.phone,
                nationality = charinfo.nationality,
                job = row.job,
                mugshot = metadata.mugshot or nil,
                fingerprint = metadata.fingerprint or nil
            })
        end
        
        cb(citizens)
    end)
end)

QBCore.Functions.CreateCallback('ls-police:server:SearchVehicle', function(source, cb, plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        cb({})
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM player_vehicles WHERE plate = ?', {plate}, function(result)
        if result[1] then
            local vehicle = result[1]
            
            -- Get owner information
            MySQL.Async.fetchAll('SELECT charinfo FROM players WHERE citizenid = ?', {vehicle.citizenid}, function(ownerResult)
                local vehicleData = {
                    plate = vehicle.plate,
                    vehicle = vehicle.vehicle,
                    garage = vehicle.garage,
                    state = vehicle.state,
                    owner = 'Unknown'
                }
                
                if ownerResult[1] then
                    local charinfo = json.decode(ownerResult[1].charinfo)
                    vehicleData.owner = charinfo.firstname .. ' ' .. charinfo.lastname
                    vehicleData.ownerCitizenid = vehicle.citizenid
                end
                
                -- Check for BOLOs or reports
                MySQL.Async.fetchAll('SELECT * FROM police_bolos WHERE plate = ? AND active = 1', {plate}, function(boloResult)
                    if boloResult[1] then
                        vehicleData.bolo = {
                            title = boloResult[1].title,
                            description = boloResult[1].description,
                            officer = boloResult[1].officer
                        }
                    end
                    
                    cb(vehicleData)
                end)
            end)
        else
            cb(nil)
        end
    end)
end)

-- BOLO System
RegisterNetEvent('ls-police:server:CreateBOLO', function(boloData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    local boloId = "bolo_" .. math.random(10000, 99999)
    
    MySQL.Async.insert('INSERT INTO police_bolos (bolo_id, type, title, description, plate, person_id, officer, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        boloId,
        boloData.type,
        boloData.title,
        boloData.description,
        boloData.plate,
        boloData.person_id,
        Player.PlayerData.citizenid,
        os.time()
    }, function(insertId)
        if insertId then
            TriggerClientEvent('QBCore:Notify', src, 'BOLO created successfully', 'success')
            
            -- Notify all officers
            local officers = exports['ls-police']:GetOnDutyOfficers()
            for officerId, officer in pairs(officers) do
                TriggerClientEvent('QBCore:Notify', officerId, 'New BOLO: ' .. boloData.title, 'primary')
                TriggerClientEvent('ls-police:client:NewBOLO', officerId, {
                    id = boloId,
                    type = boloData.type,
                    title = boloData.title,
                    description = boloData.description,
                    plate = boloData.plate,
                    person_id = boloData.person_id,
                    officer = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    created_at = os.time()
                })
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to create BOLO', 'error')
        end
    end)
end)

RegisterNetEvent('ls-police:server:RemoveBOLO', function(boloId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    MySQL.Async.execute('UPDATE police_bolos SET active = 0 WHERE bolo_id = ?', {boloId}, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'BOLO removed', 'success')
            
            -- Notify all officers
            local officers = exports['ls-police']:GetOnDutyOfficers()
            for officerId, officer in pairs(officers) do
                TriggerClientEvent('ls-police:client:RemoveBOLO', officerId, boloId)
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to remove BOLO', 'error')
        end
    end)
end)

-- Reports System
RegisterNetEvent('ls-police:server:CreateReport', function(reportData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    local reportId = "report_" .. math.random(100000, 999999)
    
    MySQL.Async.insert('INSERT INTO police_reports (report_id, report_type, title, description, officer, suspects, evidence, vehicle_plate, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        reportId,
        reportData.type,
        reportData.title,
        reportData.description,
        Player.PlayerData.citizenid,
        json.encode(reportData.suspects or {}),
        json.encode(reportData.evidence or {}),
        reportData.vehicle_plate,
        os.time(),
        os.time()
    }, function(insertId)
        if insertId then
            TriggerClientEvent('QBCore:Notify', src, 'Report created: ' .. reportId, 'success')
            
            -- Add to player's report history
            local reports = Player.PlayerData.metadata.reports or {}
            table.insert(reports, reportId)
            Player.Functions.SetMetaData('reports', reports)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to create report', 'error')
        end
    end)
end)

RegisterNetEvent('ls-police:server:UpdateReport', function(reportData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    MySQL.Async.execute('UPDATE police_reports SET title = ?, description = ?, suspects = ?, evidence = ?, vehicle_plate = ?, updated_at = ? WHERE report_id = ?', {
        reportData.title,
        reportData.description,
        json.encode(reportData.suspects or {}),
        json.encode(reportData.evidence or {}),
        reportData.vehicle_plate,
        os.time(),
        reportData.id
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Report updated', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to update report', 'error')
        end
    end)
end)

-- Get Reports
QBCore.Functions.CreateCallback('ls-police:server:GetReports', function(source, cb, filters)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        cb({})
        return
    end
    
    local query = 'SELECT * FROM police_reports'
    local params = {}
    
    if filters then
        local conditions = {}
        
        if filters.type then
            table.insert(conditions, 'report_type = ?')
            table.insert(params, filters.type)
        end
        
        if filters.officer then
            table.insert(conditions, 'officer = ?')
            table.insert(params, filters.officer)
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
    
    query = query .. ' ORDER BY created_at DESC LIMIT 50'
    
    MySQL.Async.fetchAll(query, params, function(result)
        local reports = {}
        
        for i = 1, #result do
            local row = result[i]
            table.insert(reports, {
                id = row.report_id,
                type = row.report_type,
                title = row.title,
                description = row.description,
                officer = row.officer,
                suspects = json.decode(row.suspects or '[]'),
                evidence = json.decode(row.evidence or '[]'),
                vehicle_plate = row.vehicle_plate,
                created_at = row.created_at,
                updated_at = row.updated_at
            })
        end
        
        cb(reports)
    end)
end)

-- Get BOLOs
QBCore.Functions.CreateCallback('ls-police:server:GetBOLOs', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        cb({})
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM police_bolos WHERE active = 1 ORDER BY created_at DESC', {}, function(result)
        local bolos = {}
        
        for i = 1, #result do
            local row = result[i]
            table.insert(bolos, {
                id = row.bolo_id,
                type = row.type,
                title = row.title,
                description = row.description,
                plate = row.plate,
                person_id = row.person_id,
                officer = row.officer,
                created_at = row.created_at
            })
        end
        
        cb(bolos)
    end)
end)

-- Warrant System
RegisterNetEvent('ls-police:server:CreateWarrant', function(warrantData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    -- Check rank requirement for warrants
    if Player.PlayerData.job.grade.level < 2 then
        TriggerClientEvent('QBCore:Notify', src, 'Insufficient rank to issue warrants', 'error')
        return
    end
    
    local warrantId = "warrant_" .. math.random(100000, 999999)
    
    MySQL.Async.insert('INSERT INTO police_warrants (warrant_id, person_id, charges, bail_amount, officer, created_at, active) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        warrantId,
        warrantData.person_id,
        json.encode(warrantData.charges),
        warrantData.bail_amount or 0,
        Player.PlayerData.citizenid,
        os.time(),
        1
    }, function(insertId)
        if insertId then
            TriggerClientEvent('QBCore:Notify', src, 'Warrant issued: ' .. warrantId, 'success')
            
            -- Notify target player if online
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(warrantData.person_id)
            if targetPlayer then
                TriggerClientEvent('QBCore:Notify', targetPlayer.PlayerData.source, 'A warrant has been issued for your arrest', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to issue warrant', 'error')
        end
    end)
end)

-- Create warrant table
CreateThread(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `police_warrants` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `warrant_id` varchar(100) NOT NULL,
            `person_id` varchar(50) NOT NULL,
            `charges` text,
            `bail_amount` int(11) DEFAULT 0,
            `officer` varchar(50),
            `created_at` int(11),
            `served_at` int(11),
            `served_by` varchar(50),
            `active` tinyint(1) DEFAULT 1,
            PRIMARY KEY (`id`),
            UNIQUE KEY `warrant_id` (`warrant_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)