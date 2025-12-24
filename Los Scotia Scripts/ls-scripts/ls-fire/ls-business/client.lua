local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentBusiness = nil
local insideBusiness = false

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    CreateBusinessBlips()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Business Commands
RegisterCommand('buybusiness', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /buybusiness [business_id]', 'primary')
        return
    end
    
    local businessId = tonumber(args[1])
    TriggerServerEvent('ls-business:server:buyBusiness', businessId)
end)

RegisterCommand('sellbusiness', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /sellbusiness [business_id]', 'primary')
        return
    end
    
    local businessId = tonumber(args[1])
    TriggerServerEvent('ls-business:server:sellBusiness', businessId)
end)

RegisterCommand('businessinfo', function()
    if not currentBusiness then
        QBCore.Functions.Notify('You are not near any business', 'error')
        return
    end
    
    TriggerServerEvent('ls-business:server:getBusinessInfo', currentBusiness.id)
end)

RegisterCommand('hireemployee', function(source, args)
    if not args[1] or not args[2] then
        QBCore.Functions.Notify('Usage: /hireemployee [player_id] [position]', 'primary')
        return
    end
    
    if not currentBusiness then
        QBCore.Functions.Notify('You must be at your business', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    local position = args[2]:lower()
    
    TriggerServerEvent('ls-business:server:hireEmployee', currentBusiness.id, targetId, position)
end)

RegisterCommand('fireemployee', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /fireemployee [player_id]', 'primary')
        return
    end
    
    if not currentBusiness then
        QBCore.Functions.Notify('You must be at your business', 'error')
        return
    end
    
    local targetId = tonumber(args[1])
    TriggerServerEvent('ls-business:server:fireEmployee', currentBusiness.id, targetId)
end)

RegisterCommand('businessstock', function()
    if not currentBusiness then
        QBCore.Functions.Notify('You must be at a business', 'error')
        return
    end
    
    TriggerServerEvent('ls-business:server:getBusinessStock', currentBusiness.id)
end)

RegisterCommand('restockbusiness', function(source, args)
    if not args[1] or not args[2] then
        QBCore.Functions.Notify('Usage: /restockbusiness [item] [quantity]', 'primary')
        return
    end
    
    if not currentBusiness then
        QBCore.Functions.Notify('You must be at your business', 'error')
        return
    end
    
    local item = args[1]
    local quantity = tonumber(args[2])
    
    TriggerServerEvent('ls-business:server:restockBusiness', currentBusiness.id, item, quantity)
end)

RegisterCommand('mybusinesses', function()
    TriggerServerEvent('ls-business:server:getPlayerBusinesses')
end)

RegisterCommand('businessemployees', function()
    if not currentBusiness then
        QBCore.Functions.Notify('You must be at your business', 'error')
        return
    end
    
    TriggerServerEvent('ls-business:server:getBusinessEmployees', currentBusiness.id)
end)

-- Business Interaction
CreateThread(function()
    while true do
        Wait(1000)
        if PlayerData then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local nearBusiness = nil
            
            for _, business in pairs(Config.Businesses) do
                local distance = #(playerCoords - business.coords)
                if distance <= 5.0 then
                    nearBusiness = business
                    break
                end
            end
            
            if nearBusiness and not currentBusiness then
                currentBusiness = nearBusiness
                QBCore.Functions.Notify('Near ' .. nearBusiness.name .. ' | Use /businessinfo for details', 'primary')
            elseif not nearBusiness and currentBusiness then
                currentBusiness = nil
            end
        end
    end
end)

-- Business Events
RegisterNetEvent('ls-business:client:businessPurchased', function(businessData)
    QBCore.Functions.Notify('Successfully purchased ' .. businessData.name .. ' for $' .. businessData.price, 'success')
    UpdateBusinessBlip(businessData.id, true)
end)

RegisterNetEvent('ls-business:client:businessSold', function(businessData, salePrice)
    QBCore.Functions.Notify('Successfully sold ' .. businessData.name .. ' for $' .. salePrice, 'success')
    UpdateBusinessBlip(businessData.id, false)
end)

RegisterNetEvent('ls-business:client:showBusinessInfo', function(businessData, ownerData, finances)
    local infoText = 'Business: ' .. businessData.name .. '\n'
    infoText = infoText .. 'Type: ' .. Config.BusinessTypes[businessData.type].name .. '\n'
    infoText = infoText .. 'Price: $' .. businessData.price .. '\n'
    
    if ownerData then
        infoText = infoText .. 'Owner: ' .. ownerData.name .. '\n'
        if finances then
            infoText = infoText .. 'Balance: $' .. finances.balance .. '\n'
            infoText = infoText .. 'Daily Revenue: $' .. finances.daily_revenue .. '\n'
            infoText = infoText .. 'Employees: ' .. finances.employee_count .. '\n'
        end
    else
        infoText = infoText .. 'Status: Available for Purchase\n'
    end
    
    QBCore.Functions.Notify(infoText, 'primary')
end)

RegisterNetEvent('ls-business:client:employeeHired', function(businessName, employeeName, position)
    QBCore.Functions.Notify(employeeName .. ' hired as ' .. position .. ' at ' .. businessName, 'success')
end)

RegisterNetEvent('ls-business:client:employeeFired', function(businessName, employeeName)
    QBCore.Functions.Notify(employeeName .. ' fired from ' .. businessName, 'error')
end)

RegisterNetEvent('ls-business:client:jobOfferReceived', function(businessName, position, salary)
    QBCore.Functions.Notify('Job offer: ' .. position .. ' at ' .. businessName .. ' ($' .. salary .. '/week)', 'success')
end)

RegisterNetEvent('ls-business:client:firedFromJob', function(businessName)
    QBCore.Functions.Notify('You have been fired from ' .. businessName, 'error')
end)

RegisterNetEvent('ls-business:client:showBusinessStock', function(stock)
    if not stock or #stock == 0 then
        QBCore.Functions.Notify('No stock information available', 'primary')
        return
    end
    
    local stockText = 'Business Stock:\n'
    for _, item in pairs(stock) do
        stockText = stockText .. item.name .. ': ' .. item.quantity .. ' units\n'
    end
    
    QBCore.Functions.Notify(stockText, 'primary')
end)

RegisterNetEvent('ls-business:client:stockRestocked', function(itemName, quantity, cost)
    QBCore.Functions.Notify('Restocked ' .. quantity .. ' ' .. itemName .. ' for $' .. cost, 'success')
end)

RegisterNetEvent('ls-business:client:showPlayerBusinesses', function(businesses)
    if #businesses == 0 then
        QBCore.Functions.Notify('You dont own any businesses', 'primary')
        return
    end
    
    local businessList = 'Your Businesses:\n'
    for _, business in pairs(businesses) do
        businessList = businessList .. business.name .. ' (' .. business.type .. ') - $' .. business.balance .. '\n'
    end
    
    QBCore.Functions.Notify(businessList, 'primary')
end)

RegisterNetEvent('ls-business:client:showBusinessEmployees', function(employees)
    if #employees == 0 then
        QBCore.Functions.Notify('No employees', 'primary')
        return
    end
    
    local employeeList = 'Employees:\n'
    for _, employee in pairs(employees) do
        employeeList = employeeList .. employee.name .. ' - ' .. employee.position .. ' ($' .. employee.salary .. '/week)\n'
    end
    
    QBCore.Functions.Notify(employeeList, 'primary')
end)

-- Customer System
RegisterCommand('buyitem', function(source, args)
    if not args[1] then
        QBCore.Functions.Notify('Usage: /buyitem [item_name]', 'primary')
        return
    end
    
    if not currentBusiness then
        QBCore.Functions.Notify('You must be at a business', 'error')
        return
    end
    
    local item = args[1]
    local quantity = tonumber(args[2]) or 1
    
    TriggerServerEvent('ls-business:server:buyItem', currentBusiness.id, item, quantity)
end)

RegisterNetEvent('ls-business:client:itemPurchased', function(itemName, quantity, totalCost)
    QBCore.Functions.Notify('Purchased ' .. quantity .. ' ' .. itemName .. ' for $' .. totalCost, 'success')
end)

-- Blip Functions
function CreateBusinessBlips()
    for _, business in pairs(Config.Businesses) do
        local blip = AddBlipForCoord(business.coords.x, business.coords.y, business.coords.z)
        
        local sprite = 52 -- Default business sprite
        if business.type == 'restaurant' then sprite = 106
        elseif business.type == 'shop' then sprite = 52
        elseif business.type == 'garage' then sprite = 72
        elseif business.type == 'clothing' then sprite = 73
        elseif business.type == 'bar' then sprite = 93
        elseif business.type == 'electronics' then sprite = 52
        end
        
        SetBlipSprite(blip, sprite)
        SetBlipColour(blip, business.owned and 2 or 1)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(business.name)
        EndTextCommandSetBlipName(blip)
        
        business.blip = blip
    end
end

function UpdateBusinessBlip(businessId, owned)
    for _, business in pairs(Config.Businesses) do
        if business.id == businessId and business.blip then
            SetBlipColour(business.blip, owned and 2 or 1)
            business.owned = owned
            break
        end
    end
end

-- Business Management Menu
RegisterCommand('businessmenu', function()
    if not currentBusiness then
        QBCore.Functions.Notify('You must be at a business', 'error')
        return
    end
    
    TriggerServerEvent('ls-business:server:openBusinessMenu', currentBusiness.id)
end)

RegisterNetEvent('ls-business:client:openBusinessMenu', function(businessData, hasAccess)
    if not hasAccess then
        QBCore.Functions.Notify('You dont have access to manage this business', 'error')
        return
    end
    
    local menuItems = {
        {
            header = businessData.name .. ' Management',
            txt = 'Manage your business operations',
            isMenuHeader = true
        },
        {
            header = 'View Stock',
            txt = 'Check current inventory levels',
            params = {
                event = 'ls-business:client:viewStock',
                args = {businessId = businessData.id}
            }
        },
        {
            header = 'Restock Items',
            txt = 'Purchase inventory for the business',
            params = {
                event = 'ls-business:client:restockMenu',
                args = {businessId = businessData.id}
            }
        },
        {
            header = 'Employee Management',
            txt = 'Hire, fire, and manage employees',
            params = {
                event = 'ls-business:client:employeeMenu',
                args = {businessId = businessData.id}
            }
        },
        {
            header = 'Financial Reports',
            txt = 'View business finances and reports',
            params = {
                event = 'ls-business:client:financeMenu',
                args = {businessId = businessData.id}
            }
        }
    }
    
    exports['qb-menu']:openMenu(menuItems)
end)

-- Export functions
exports('IsAtBusiness', function()
    return currentBusiness ~= nil
end)

exports('GetCurrentBusiness', function()
    return currentBusiness
end)