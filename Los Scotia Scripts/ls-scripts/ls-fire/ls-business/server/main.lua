local QBCore = exports['qb-core']:GetCoreObject()

-- Database initialization (run once)
CreateThread(function()
    if Config.UseOxMySQL then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS ls_businesses (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                owner VARCHAR(50) NOT NULL,
                type VARCHAR(100) NOT NULL,
                status ENUM('open', 'closed') DEFAULT 'closed',
                settings JSON,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ]])
        
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS ls_business_employees (
                id INT AUTO_INCREMENT PRIMARY KEY,
                business_id INT,
                citizen_id VARCHAR(50) NOT NULL,
                rank VARCHAR(50) DEFAULT 'employee',
                salary INT DEFAULT 50,
                hired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (business_id) REFERENCES ls_businesses(id) ON DELETE CASCADE
            )
        ]])
    end
end)

-- Callbacks
QBCore.Functions.CreateCallback('ls-business:server:getBusinessData', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    
    local citizenId = Player.PlayerData.citizenid
    
    if Config.UseOxMySQL then
        MySQL.query('SELECT * FROM ls_businesses WHERE owner = ?', {citizenId}, function(businesses)
            if businesses and #businesses > 0 then
                local business = businesses[1]
                MySQL.query('SELECT * FROM ls_business_employees WHERE business_id = ?', {business.id}, function(employees)
                    cb({
                        business = business,
                        employees = employees or {}
                    })
                end)
            else
                cb({
                    business = nil,
                    employees = {}
                })
            end
        end)
    else
        cb({
            business = nil,
            employees = {}
        })
    end
end)

-- Events
RegisterNetEvent('ls-business:server:hireEmployee', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local targetId = data.targetId
    local rank = data.rank or 'employee'
    local salary = data.salary or Config.EmployeeRanks[rank].salary
    
    -- Add hiring logic here
    TriggerClientEvent('QBCore:Notify', src, 'Employee hired successfully', 'success')
end)

RegisterNetEvent('ls-business:server:fireEmployee', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local employeeId = data.employeeId
    
    -- Add firing logic here
    TriggerClientEvent('QBCore:Notify', src, 'Employee fired successfully', 'success')
end)

RegisterNetEvent('ls-business:server:updateSettings', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Add settings update logic here
    TriggerClientEvent('QBCore:Notify', src, 'Business settings updated', 'success')
end)

-- Commands
QBCore.Commands.Add(Config.Commands['business_hire'], 'Hire an employee (Business Owner)', {{name = 'id', help = 'Player ID'}}, false, function(source, args)
    -- Hire command logic
end, 'admin')

QBCore.Commands.Add(Config.Commands['business_fire'], 'Fire an employee (Business Owner)', {{name = 'id', help = 'Employee ID'}}, false, function(source, args)
    -- Fire command logic
end, 'admin')