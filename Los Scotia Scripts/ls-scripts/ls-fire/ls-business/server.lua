local QBCore = exports['qb-core']:GetCoreObject()

-- Business Management
RegisterNetEvent('ls-business:server:buyBusiness', function(businessId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local business = nil
    for _, biz in pairs(Config.Businesses) do
        if biz.id == businessId then
            business = biz
            break
        end
    end
    
    if not business then
        TriggerClientEvent('QBCore:Notify', src, 'Business not found', 'error')
        return
    end
    
    if business.owned then
        TriggerClientEvent('QBCore:Notify', src, 'Business is already owned', 'error')
        return
    end
    
    -- Check player money
    if Player.PlayerData.money.bank < business.price then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money in bank', 'error')
        return
    end
    
    -- Check business ownership limit
    local ownedBusinesses = MySQL.query.await('SELECT COUNT(*) as count FROM player_businesses WHERE citizenid = ?', {
        Player.PlayerData.citizenid
    })
    
    if ownedBusinesses[1].count >= Config.MaxBusinessesPerPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'You own too many businesses (max: ' .. Config.MaxBusinessesPerPlayer .. ')', 'error')
        return
    end
    
    -- Remove money and create business
    Player.Functions.RemoveMoney('bank', business.price)
    
    MySQL.insert('INSERT INTO player_businesses (citizenid, business_id, business_name, business_type, balance, daily_cost) VALUES (?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.citizenid,
        business.id,
        business.name,
        business.type,
        50000, -- Starting balance
        Config.BusinessTypes[business.type].dailyCost
    })
    
    -- Initialize stock
    local businessType = Config.BusinessTypes[business.type]
    for _, product in pairs(businessType.products) do
        MySQL.insert('INSERT INTO business_stock (business_id, item_name, quantity, buy_price, sell_price) VALUES (?, ?, ?, ?, ?)', {
            business.id,
            product,
            0,
            Config.Products[product].buyPrice,
            Config.Products[product].sellPrice
        })
    end
    
    business.owned = true
    
    TriggerClientEvent('ls-business:client:businessPurchased', src, business)
end)

RegisterNetEvent('ls-business:server:sellBusiness', function(businessId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local businessData = MySQL.query.await('SELECT * FROM player_businesses WHERE citizenid = ? AND business_id = ?', {
        Player.PlayerData.citizenid,
        businessId
    })
    
    if not businessData[1] then
        TriggerClientEvent('QBCore:Notify', src, 'You dont own this business', 'error')
        return
    end
    
    local business = nil
    for _, biz in pairs(Config.Businesses) do
        if biz.id == businessId then
            business = biz
            break
        end
    end
    
    if not business then return end
    
    -- Calculate sale price (70% of original + current balance)
    local salePrice = math.floor(business.price * 0.7) + businessData[1].balance
    
    -- Remove business and related data
    MySQL.execute('DELETE FROM player_businesses WHERE citizenid = ? AND business_id = ?', {
        Player.PlayerData.citizenid,
        businessId
    })
    
    MySQL.execute('DELETE FROM business_stock WHERE business_id = ?', {businessId})
    MySQL.execute('DELETE FROM business_employees WHERE business_id = ?', {businessId})
    MySQL.execute('DELETE FROM business_finances WHERE business_id = ?', {businessId})
    
    Player.Functions.AddMoney('bank', salePrice)
    business.owned = false
    
    TriggerClientEvent('ls-business:client:businessSold', src, business, salePrice)
end)

RegisterNetEvent('ls-business:server:getBusinessInfo', function(businessId)
    local src = source
    
    local business = nil
    for _, biz in pairs(Config.Businesses) do
        if biz.id == businessId then
            business = biz
            break
        end
    end
    
    if not business then return end
    
    local businessData = MySQL.query.await('SELECT * FROM player_businesses WHERE business_id = ?', {businessId})
    
    local ownerInfo = nil
    local finances = nil
    
    if businessData[1] then
        local ownerPlayer = MySQL.query.await('SELECT charinfo FROM players WHERE citizenid = ?', {businessData[1].citizenid})
        if ownerPlayer[1] then
            local charinfo = json.decode(ownerPlayer[1].charinfo)
            ownerInfo = {
                name = charinfo.firstname .. ' ' .. charinfo.lastname
            }
            
            finances = {
                balance = businessData[1].balance,
                daily_revenue = businessData[1].daily_revenue or 0,
                employee_count = MySQL.query.await('SELECT COUNT(*) as count FROM business_employees WHERE business_id = ?', {businessId})[1].count
            }
        end
    end
    
    TriggerClientEvent('ls-business:client:showBusinessInfo', src, business, ownerInfo, finances)
end)

-- Employee Management
RegisterNetEvent('ls-business:server:hireEmployee', function(businessId, targetId, position)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
        return
    end
    
    -- Check if player owns the business or has hire permission
    local hasPermission = false
    local businessData = MySQL.query.await('SELECT * FROM player_businesses WHERE citizenid = ? AND business_id = ?', {
        Player.PlayerData.citizenid,
        businessId
    })
    
    if businessData[1] then
        hasPermission = true
    else
        -- Check if player is manager with hire permission
        local employeeData = MySQL.query.await('SELECT * FROM business_employees WHERE citizenid = ? AND business_id = ?', {
            Player.PlayerData.citizenid,
            businessId
        })
        
        if employeeData[1] and Config.Positions[employeeData[1].position].permissions.hire then
            hasPermission = true
        end
    end
    
    if not hasPermission then
        TriggerClientEvent('QBCore:Notify', src, 'You dont have permission to hire employees', 'error')
        return
    end
    
    if not Config.Positions[position] then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid position', 'error')
        return
    end
    
    -- Check if target is already employed
    local existingEmployee = MySQL.query.await('SELECT * FROM business_employees WHERE citizenid = ? AND business_id = ?', {
        TargetPlayer.PlayerData.citizenid,
        businessId
    })
    
    if existingEmployee[1] then
        TriggerClientEvent('QBCore:Notify', src, 'Player is already employed at this business', 'error')
        return
    end
    
    -- Check employee limit
    local currentEmployees = MySQL.query.await('SELECT COUNT(*) as count FROM business_employees WHERE business_id = ?', {businessId})
    local maxEmployees = Config.BusinessTypes[businessData[1].business_type].maxEmployees
    
    if currentEmployees[1].count >= maxEmployees then
        TriggerClientEvent('QBCore:Notify', src, 'Business has reached maximum employee limit', 'error')
        return
    end
    
    -- Hire employee
    MySQL.insert('INSERT INTO business_employees (business_id, citizenid, position, salary, hire_date) VALUES (?, ?, ?, ?, ?)', {
        businessId,
        TargetPlayer.PlayerData.citizenid,
        position,
        Config.Positions[position].salary,
        os.time()
    })
    
    local business = nil
    for _, biz in pairs(Config.Businesses) do
        if biz.id == businessId then
            business = biz
            break
        end
    end
    
    TriggerClientEvent('ls-business:client:employeeHired', src, business.name, TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname, Config.Positions[position].name)
    TriggerClientEvent('ls-business:client:jobOfferReceived', targetId, business.name, Config.Positions[position].name, Config.Positions[position].salary)
end)

RegisterNetEvent('ls-business:server:fireEmployee', function(businessId, targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
        return
    end
    
    -- Check permissions (owner can fire anyone, managers can fire employees/supervisors)
    local hasPermission = false
    local businessData = MySQL.query.await('SELECT * FROM player_businesses WHERE citizenid = ? AND business_id = ?', {
        Player.PlayerData.citizenid,
        businessId
    })
    
    if businessData[1] then
        hasPermission = true
    else
        local employeeData = MySQL.query.await('SELECT * FROM business_employees WHERE citizenid = ? AND business_id = ?', {
            Player.PlayerData.citizenid,
            businessId
        })
        
        if employeeData[1] and Config.Positions[employeeData[1].position].permissions.fire then
            hasPermission = true
        end
    end
    
    if not hasPermission then
        TriggerClientEvent('QBCore:Notify', src, 'You dont have permission to fire employees', 'error')
        return
    end
    
    -- Fire employee
    MySQL.execute('DELETE FROM business_employees WHERE citizenid = ? AND business_id = ?', {
        TargetPlayer.PlayerData.citizenid,
        businessId
    })
    
    local business = nil
    for _, biz in pairs(Config.Businesses) do
        if biz.id == businessId then
            business = biz
            break
        end
    end
    
    TriggerClientEvent('ls-business:client:employeeFired', src, business.name, TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname)
    TriggerClientEvent('ls-business:client:firedFromJob', targetId, business.name)
end)

RegisterNetEvent('ls-business:server:getBusinessEmployees', function(businessId)
    local src = source
    
    local employees = MySQL.query.await('SELECT * FROM business_employees WHERE business_id = ?', {businessId})
    
    local employeeList = {}
    for _, employee in pairs(employees) do
        local playerData = MySQL.query.await('SELECT charinfo FROM players WHERE citizenid = ?', {employee.citizenid})
        if playerData[1] then
            local charinfo = json.decode(playerData[1].charinfo)
            table.insert(employeeList, {
                name = charinfo.firstname .. ' ' .. charinfo.lastname,
                position = Config.Positions[employee.position].name,
                salary = employee.salary
            })
        end
    end
    
    TriggerClientEvent('ls-business:client:showBusinessEmployees', src, employeeList)
end)

-- Stock Management
RegisterNetEvent('ls-business:server:getBusinessStock', function(businessId)
    local src = source
    
    local stock = MySQL.query.await('SELECT * FROM business_stock WHERE business_id = ?', {businessId})
    
    local stockList = {}
    for _, item in pairs(stock) do
        table.insert(stockList, {
            name = Config.Products[item.item_name].name,
            quantity = item.quantity,
            buyPrice = item.buy_price,
            sellPrice = item.sell_price
        })
    end
    
    TriggerClientEvent('ls-business:client:showBusinessStock', src, stockList)
end)

RegisterNetEvent('ls-business:server:restockBusiness', function(businessId, item, quantity)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check permissions
    local hasPermission = false
    local businessData = MySQL.query.await('SELECT * FROM player_businesses WHERE citizenid = ? AND business_id = ?', {
        Player.PlayerData.citizenid,
        businessId
    })
    
    if businessData[1] then
        hasPermission = true
    else
        local employeeData = MySQL.query.await('SELECT * FROM business_employees WHERE citizenid = ? AND business_id = ?', {
            Player.PlayerData.citizenid,
            businessId
        })
        
        if employeeData[1] and Config.Positions[employeeData[1].position].permissions.manage_stock then
            hasPermission = true
        end
    end
    
    if not hasPermission then
        TriggerClientEvent('QBCore:Notify', src, 'You dont have permission to manage stock', 'error')
        return
    end
    
    if not Config.Products[item] then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid item', 'error')
        return
    end
    
    local totalCost = Config.Products[item].buyPrice * quantity
    
    -- Check business balance
    if businessData[1].balance < totalCost then
        TriggerClientEvent('QBCore:Notify', src, 'Business doesnt have enough money', 'error')
        return
    end
    
    -- Update stock
    MySQL.execute('UPDATE business_stock SET quantity = quantity + ? WHERE business_id = ? AND item_name = ?', {
        quantity,
        businessId,
        item
    })
    
    -- Update business balance
    MySQL.execute('UPDATE player_businesses SET balance = balance - ? WHERE business_id = ?', {
        totalCost,
        businessId
    })
    
    TriggerClientEvent('ls-business:client:stockRestocked', src, Config.Products[item].name, quantity, totalCost)
end)

-- Customer Purchases
RegisterNetEvent('ls-business:server:buyItem', function(businessId, item, quantity)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local stock = MySQL.query.await('SELECT * FROM business_stock WHERE business_id = ? AND item_name = ?', {
        businessId,
        item
    })
    
    if not stock[1] then
        TriggerClientEvent('QBCore:Notify', src, 'Item not available', 'error')
        return
    end
    
    if stock[1].quantity < quantity then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough stock available', 'error')
        return
    end
    
    local totalCost = stock[1].sell_price * quantity
    
    if Player.PlayerData.money.cash < totalCost then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough cash', 'error')
        return
    end
    
    -- Process purchase
    Player.Functions.RemoveMoney('cash', totalCost)
    Player.Functions.AddItem(item, quantity)
    
    -- Update stock
    MySQL.execute('UPDATE business_stock SET quantity = quantity - ? WHERE business_id = ? AND item_name = ?', {
        quantity,
        businessId,
        item
    })
    
    -- Add revenue to business
    MySQL.execute('UPDATE player_businesses SET balance = balance + ?, daily_revenue = daily_revenue + ? WHERE business_id = ?', {
        totalCost,
        totalCost,
        businessId
    })
    
    TriggerClientEvent('ls-business:client:itemPurchased', src, Config.Products[item].name, quantity, totalCost)
end)

RegisterNetEvent('ls-business:server:getPlayerBusinesses', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local businesses = MySQL.query.await('SELECT * FROM player_businesses WHERE citizenid = ?', {
        Player.PlayerData.citizenid
    })
    
    local businessList = {}
    for _, business in pairs(businesses) do
        table.insert(businessList, {
            id = business.business_id,
            name = business.business_name,
            type = Config.BusinessTypes[business.business_type].name,
            balance = business.balance
        })
    end
    
    TriggerClientEvent('ls-business:client:showPlayerBusinesses', src, businessList)
end)

-- Business Menu Access
RegisterNetEvent('ls-business:server:openBusinessMenu', function(businessId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has access (owner or employee)
    local hasAccess = false
    local businessData = MySQL.query.await('SELECT * FROM player_businesses WHERE business_id = ?', {businessId})
    
    if businessData[1] then
        if businessData[1].citizenid == Player.PlayerData.citizenid then
            hasAccess = true
        else
            local employeeData = MySQL.query.await('SELECT * FROM business_employees WHERE citizenid = ? AND business_id = ?', {
                Player.PlayerData.citizenid,
                businessId
            })
            
            if employeeData[1] then
                hasAccess = true
            end
        end
    end
    
    local business = nil
    for _, biz in pairs(Config.Businesses) do
        if biz.id == businessId then
            business = biz
            break
        end
    end
    
    TriggerClientEvent('ls-business:client:openBusinessMenu', src, business, hasAccess)
end)

-- Automated Systems
CreateThread(function()
    while true do
        Wait(Config.Finance.payrollTime * 1000) -- Weekly payroll
        
        local employees = MySQL.query.await('SELECT * FROM business_employees')
        
        for _, employee in pairs(employees) do
            local businessData = MySQL.query.await('SELECT * FROM player_businesses WHERE business_id = ?', {employee.business_id})
            
            if businessData[1] and businessData[1].balance >= employee.salary then
                -- Pay employee
                MySQL.execute('UPDATE player_businesses SET balance = balance - ? WHERE business_id = ?', {
                    employee.salary,
                    employee.business_id
                })
                
                local Player = QBCore.Functions.GetPlayerByCitizenId(employee.citizenid)
                if Player then
                    Player.Functions.AddMoney('bank', employee.salary)
                    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'Received paycheck: $' .. employee.salary, 'success')
                end
            end
        end
    end
end)

print("^2[LS-BUSINESS]^7 Business Management System loaded successfully!")