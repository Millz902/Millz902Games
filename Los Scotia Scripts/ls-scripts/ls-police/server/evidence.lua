local QBCore = exports['qb-core']:GetCoreObject()

-- Evidence Server Functions
RegisterNetEvent('ls-police:server:AddEvidence', function(evidenceData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
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
        if insertId then
            TriggerClientEvent('QBCore:Notify', src, 'Evidence added to database', 'success')
            
            -- Notify all on-duty officers
            local officers = exports['ls-police']:GetOnDutyOfficers()
            for officerId, officer in pairs(officers) do
                if officerId ~= src then
                    TriggerClientEvent('QBCore:Notify', officerId, 'New evidence logged by ' .. officer.name, 'primary')
                end
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to add evidence', 'error')
        end
    end)
end)

-- Evidence Search and Retrieval
QBCore.Functions.CreateCallback('ls-police:server:GetEvidence', function(source, cb, filters)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        cb({})
        return
    end
    
    local query = 'SELECT * FROM police_evidence'
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
        
        if filters.collector then
            table.insert(conditions, 'collector = ?')
            table.insert(params, filters.collector)
        end
        
        if #conditions > 0 then
            query = query .. ' WHERE ' .. table.concat(conditions, ' AND ')
        end
    end
    
    query = query .. ' ORDER BY created_at DESC'
    
    MySQL.Async.fetchAll(query, params, function(result)
        local evidence = {}
        for i = 1, #result do
            local row = result[i]
            table.insert(evidence, {
                id = row.evidence_id,
                type = row.type,
                data = json.decode(row.data),
                collector = row.collector,
                location = json.decode(row.location or '{}'),
                created_at = row.created_at
            })
        end
        cb(evidence)
    end)
end)

-- Evidence Analysis
RegisterNetEvent('ls-police:server:AnalyzeEvidence', function(evidenceId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM police_evidence WHERE evidence_id = ?', {evidenceId}, function(result)
        if result[1] then
            local evidence = result[1]
            local evidenceData = json.decode(evidence.data)
            
            -- Simulate analysis time
            local analysisTime = 30000 -- 30 seconds
            
            if evidenceData.type == 'dna' then
                analysisTime = 60000 -- 1 minute for DNA
            elseif evidenceData.type == 'fingerprints' then
                analysisTime = 45000 -- 45 seconds for prints
            end
            
            TriggerClientEvent('QBCore:Notify', src, 'Evidence analysis started...', 'primary')
            
            SetTimeout(analysisTime, function()
                -- Generate analysis results
                local analysisResult = {
                    evidenceId = evidenceId,
                    type = evidenceData.type,
                    results = GenerateAnalysisResults(evidenceData),
                    analyst = Player.PlayerData.citizenid,
                    completed_at = os.time()
                }
                
                -- Update database with results
                MySQL.Async.execute('UPDATE police_evidence SET data = ? WHERE evidence_id = ?', {
                    json.encode(analysisResult),
                    evidenceId
                }, function(affectedRows)
                    if affectedRows > 0 then
                        TriggerClientEvent('QBCore:Notify', src, 'Evidence analysis completed', 'success')
                        TriggerClientEvent('ls-police:client:AnalysisComplete', src, analysisResult)
                    end
                end)
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Evidence not found', 'error')
        end
    end)
end)

-- Evidence Chain of Custody
RegisterNetEvent('ls-police:server:TransferEvidence', function(evidenceId, targetOfficer)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetOfficer)
    
    if not Player or not Target or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) or not exports['ls-police']:IsPoliceJob(Target.PlayerData.job.name) then
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM police_evidence WHERE evidence_id = ?', {evidenceId}, function(result)
        if result[1] then
            local evidence = result[1]
            local evidenceData = json.decode(evidence.data)
            
            -- Add chain of custody entry
            if not evidenceData.custody_chain then
                evidenceData.custody_chain = {}
            end
            
            table.insert(evidenceData.custody_chain, {
                from = Player.PlayerData.citizenid,
                to = Target.PlayerData.citizenid,
                timestamp = os.time(),
                reason = 'Evidence transfer'
            })
            
            -- Update database
            MySQL.Async.execute('UPDATE police_evidence SET data = ?, collector = ? WHERE evidence_id = ?', {
                json.encode(evidenceData),
                Target.PlayerData.citizenid,
                evidenceId
            }, function(affectedRows)
                if affectedRows > 0 then
                    TriggerClientEvent('QBCore:Notify', src, 'Evidence transferred to ' .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname, 'success')
                    TriggerClientEvent('QBCore:Notify', targetOfficer, 'Evidence received from ' .. Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, 'primary')
                end
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Evidence not found', 'error')
        end
    end)
end)

-- Evidence Destruction
RegisterNetEvent('ls-police:server:DestroyEvidence', function(evidenceId, reason)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not exports['ls-police']:IsPoliceJob(Player.PlayerData.job.name) then
        return
    end
    
    -- Check if player has permission (high rank required)
    if Player.PlayerData.job.grade.level < 3 then
        TriggerClientEvent('QBCore:Notify', src, 'Insufficient rank to destroy evidence', 'error')
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM police_evidence WHERE evidence_id = ?', {evidenceId}, function(result)
        if result[1] then
            local evidence = result[1]
            local evidenceData = json.decode(evidence.data)
            
            -- Mark as destroyed instead of deleting
            evidenceData.destroyed = true
            evidenceData.destroyed_by = Player.PlayerData.citizenid
            evidenceData.destroyed_at = os.time()
            evidenceData.destruction_reason = reason
            
            MySQL.Async.execute('UPDATE police_evidence SET data = ? WHERE evidence_id = ?', {
                json.encode(evidenceData),
                evidenceId
            }, function(affectedRows)
                if affectedRows > 0 then
                    TriggerClientEvent('QBCore:Notify', src, 'Evidence marked as destroyed', 'success')
                    
                    -- Log the destruction
                    MySQL.Async.insert('INSERT INTO police_evidence_log (evidence_id, action, officer, reason, timestamp) VALUES (?, ?, ?, ?, ?)', {
                        evidenceId,
                        'destroyed',
                        Player.PlayerData.citizenid,
                        reason,
                        os.time()
                    })
                end
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Evidence not found', 'error')
        end
    end)
end)

-- Helper Functions
function GenerateAnalysisResults(evidenceData)
    local results = {}
    
    if evidenceData.type == 'dna' then
        -- Simulate DNA analysis
        local dnaProfiles = {
            'Profile A - Male, Caucasian',
            'Profile B - Female, Hispanic',
            'Profile C - Male, African American',
            'Inconclusive - Degraded sample'
        }
        results.dna_profile = dnaProfiles[math.random(#dnaProfiles)]
        results.match_probability = math.random(75, 99) .. '%'
        
    elseif evidenceData.type == 'fingerprints' then
        -- Simulate fingerprint analysis
        local classifications = {
            'Loop pattern - Right hand index',
            'Whorl pattern - Left hand thumb',
            'Arch pattern - Right hand middle',
            'Partial print - Insufficient for comparison'
        }
        results.classification = classifications[math.random(#classifications)]
        results.points_of_comparison = math.random(8, 16)
        
    elseif evidenceData.type == 'photo' then
        -- Simulate photo analysis
        results.image_quality = 'High resolution'
        results.timestamp_extracted = os.date('%Y-%m-%d %H:%M:%S')
        results.metadata = 'GPS coordinates available'
        
    elseif evidenceData.type == 'physical' then
        -- Simulate physical evidence analysis
        local substances = {
            'Trace amounts of cocaine detected',
            'Gunshot residue present',
            'Blood type O-positive identified',
            'Fiber analysis: Cotton blend fabric'
        }
        results.substance = substances[math.random(#substances)]
        results.confidence = math.random(80, 95) .. '%'
    end
    
    return results
end

-- Create evidence log table
CreateThread(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `police_evidence_log` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `evidence_id` varchar(100) NOT NULL,
            `action` varchar(50) NOT NULL,
            `officer` varchar(50),
            `reason` text,
            `timestamp` int(11),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)