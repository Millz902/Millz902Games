local QBCore = exports['qb-core']:GetCoreObject()

-- ================================================
-- VARIABLES
-- ================================================

local PlayerData = {}
local isInGym = false
local currentWorkout = nil
local workoutProgress = 0
local nutritionData = {
    hunger = 100,
    thirst = 100,
    energy = 100
}

-- ================================================
-- EVENTS
-- ================================================

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    TriggerServerEvent('ls-gym:server:GetMembershipStatus')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isInGym = false
    currentWorkout = nil
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- ================================================
-- GYM LOCATIONS
-- ================================================

CreateThread(function()
    for _, gym in pairs(Config.Locations) do
        -- Create blip
        local blip = AddBlipForCoord(gym.coords.x, gym.coords.y, gym.coords.z)
        SetBlipSprite(blip, 311)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(gym.name)
        EndTextCommandSetBlipName(blip)
        
        -- Entrance target
        exports['qb-target']:AddBoxZone('gym_entrance_' .. gym.name, gym.coords, 3.0, 3.0, {
            name = 'gym_entrance_' .. gym.name,
            heading = gym.heading,
            debugPoly = false,
        }, {
            options = {
                {
                    type = 'client',
                    event = 'ls-gym:client:EnterGym',
                    icon = 'fas fa-dumbbell',
                    label = 'Enter Gym',
                    gym = gym.name
                }
            },
            distance = 3.0
        })
        
        -- Equipment targets
        for equipmentId, equipment in pairs(gym.equipment) do
            exports['qb-target']:AddBoxZone('gym_equipment_' .. gym.name .. '_' .. equipmentId, equipment.coords, 2.0, 2.0, {
                name = 'gym_equipment_' .. gym.name .. '_' .. equipmentId,
                heading = equipment.heading,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'ls-gym:client:UseEquipment',
                        icon = 'fas fa-dumbbell',
                        label = 'Use ' .. equipment.label,
                        equipment = equipmentId,
                        gym = gym.name
                    }
                },
                distance = 2.0
            })
        end
        
        -- Membership desk
        if gym.membershipDesk then
            exports['qb-target']:AddBoxZone('gym_membership_' .. gym.name, gym.membershipDesk.coords, 2.0, 2.0, {
                name = 'gym_membership_' .. gym.name,
                heading = gym.membershipDesk.heading,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'ls-gym:client:OpenMembershipMenu',
                        icon = 'fas fa-id-card',
                        label = 'Membership Desk',
                        gym = gym.name
                    }
                },
                distance = 2.0
            })
        end
        
        -- Nutrition bar
        if gym.nutritionBar then
            exports['qb-target']:AddBoxZone('gym_nutrition_' .. gym.name, gym.nutritionBar.coords, 2.0, 2.0, {
                name = 'gym_nutrition_' .. gym.name,
                heading = gym.nutritionBar.heading,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'ls-gym:client:OpenNutritionMenu',
                        icon = 'fas fa-apple-alt',
                        label = 'Nutrition Bar',
                        gym = gym.name
                    }
                },
                distance = 2.0
            })
        end
        
        -- Locker room
        if gym.lockerRoom then
            exports['qb-target']:AddBoxZone('gym_locker_' .. gym.name, gym.lockerRoom.coords, 2.0, 2.0, {
                name = 'gym_locker_' .. gym.name,
                heading = gym.lockerRoom.heading,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = 'client',
                        event = 'ls-gym:client:OpenLockerRoom',
                        icon = 'fas fa-tshirt',
                        label = 'Locker Room',
                        gym = gym.name
                    }
                },
                distance = 2.0
            })
        end
    end
end)

-- ================================================
-- GYM ENTRY SYSTEM
-- ================================================

RegisterNetEvent('ls-gym:client:EnterGym', function(data)
    local gym = data.gym
    
    -- Check membership status
    QBCore.Functions.TriggerCallback('ls-gym:server:HasMembership', function(hasMembership)
        if hasMembership then
            isInGym = true
            QBCore.Functions.Notify('Welcome to ' .. gym .. '!', 'success')
            TriggerEvent('ls-gym:client:ShowGymInterface')
        else
            QBCore.Functions.Notify('You need a gym membership to enter!', 'error')
            TriggerEvent('ls-gym:client:OpenMembershipMenu', {gym = gym})
        end
    end)
end)

-- ================================================
-- MEMBERSHIP SYSTEM
-- ================================================

RegisterNetEvent('ls-gym:client:OpenMembershipMenu', function(data)
    local gym = data.gym
    local membershipOptions = {}
    
    for membershipType, membershipData in pairs(Config.Memberships) do
        table.insert(membershipOptions, {
            header = membershipData.name,
            txt = string.format('$%d for %d days - %s', membershipData.price, membershipData.duration, membershipData.description),
            params = {
                event = 'ls-gym:client:PurchaseMembership',
                args = {
                    gym = gym,
                    type = membershipType,
                    price = membershipData.price,
                    duration = membershipData.duration
                }
            }
        })
    end
    
    table.insert(membershipOptions, {
        header = 'Cancel',
        txt = 'Close membership menu',
        params = {
            event = 'qb-menu:closeMenu'
        }
    })
    
    exports['qb-menu']:openMenu(membershipOptions)
end)

RegisterNetEvent('ls-gym:client:PurchaseMembership', function(data)
    QBCore.Functions.TriggerCallback('ls-gym:server:PurchaseMembership', function(success)
        if success then
            QBCore.Functions.Notify('Membership purchased successfully!', 'success')
        else
            QBCore.Functions.Notify('Not enough money!', 'error')
        end
    end, data.type, data.price, data.duration)
end)

-- ================================================
-- EQUIPMENT USAGE
-- ================================================

RegisterNetEvent('ls-gym:client:UseEquipment', function(data)
    local equipmentId = data.equipment
    local gym = data.gym
    local equipment = Config.Locations[gym].equipment[equipmentId]
    
    if not equipment then
        QBCore.Functions.Notify('Equipment not found!', 'error')
        return
    end
    
    -- Check membership
    QBCore.Functions.TriggerCallback('ls-gym:server:HasMembership', function(hasMembership)
        if not hasMembership then
            QBCore.Functions.Notify('You need a gym membership!', 'error')
            return
        end
        
        -- Check energy requirements
        if nutritionData.energy < equipment.energyRequired then
            QBCore.Functions.Notify('You don\'t have enough energy!', 'error')
            return
        end
        
        StartWorkout(equipmentId, equipment)
    end)
end)

function StartWorkout(equipmentId, equipment)
    if currentWorkout then
        QBCore.Functions.Notify('You are already working out!', 'error')
        return
    end
    
    currentWorkout = equipmentId
    workoutProgress = 0
    
    local ped = PlayerPedId()
    local dict = equipment.animDict
    local anim = equipment.animName
    
    -- Load animation dictionary
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
    
    -- Start animation
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    -- Start workout UI
    SendNUIMessage({
        action = 'showWorkout',
        equipment = equipment.label,
        duration = equipment.duration,
        difficulty = equipment.difficulty
    })
    
    QBCore.Functions.Notify('Starting workout on ' .. equipment.label, 'primary')
    
    -- Workout loop
    CreateThread(function()
        local duration = equipment.duration * 1000 -- Convert to milliseconds
        local startTime = GetGameTimer()
        
        while currentWorkout == equipmentId do
            local currentTime = GetGameTimer()
            local elapsed = currentTime - startTime
            
            if elapsed >= duration then
                CompleteWorkout(equipmentId, equipment)
                break
            end
            
            -- Update progress
            workoutProgress = math.floor((elapsed / duration) * 100)
            
            -- Send progress to UI
            SendNUIMessage({
                action = 'updateProgress',
                progress = workoutProgress
            })
            
            -- Check if player moved away or stopped animation
            if #(GetEntityCoords(ped) - equipment.coords) > 3.0 or not IsEntityPlayingAnim(ped, dict, anim, 3) then
                CancelWorkout()
                break
            end
            
            Wait(100)
        end
    end)
end

function CompleteWorkout(equipmentId, equipment)
    currentWorkout = nil
    workoutProgress = 0
    
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    
    -- Hide workout UI
    SendNUIMessage({
        action = 'hideWorkout'
    })
    
    -- Calculate rewards
    local strengthGain = math.random(equipment.strengthMin, equipment.strengthMax)
    local staminaGain = math.random(equipment.staminaMin, equipment.staminaMax)
    local energyLoss = equipment.energyRequired
    
    -- Update nutrition
    nutritionData.energy = math.max(0, nutritionData.energy - energyLoss)
    nutritionData.hunger = math.max(0, nutritionData.hunger - 5)
    nutritionData.thirst = math.max(0, nutritionData.thirst - 10)
    
    -- Send to server
    TriggerServerEvent('ls-gym:server:CompleteWorkout', equipmentId, strengthGain, staminaGain)
    
    QBCore.Functions.Notify(string.format('Workout complete! +%d Strength, +%d Stamina', strengthGain, staminaGain), 'success')
end

function CancelWorkout()
    if not currentWorkout then return end
    
    currentWorkout = nil
    workoutProgress = 0
    
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    
    -- Hide workout UI
    SendNUIMessage({
        action = 'hideWorkout'
    })
    
    QBCore.Functions.Notify('Workout cancelled!', 'error')
end

-- ================================================
-- NUTRITION SYSTEM
-- ================================================

RegisterNetEvent('ls-gym:client:OpenNutritionMenu', function(data)
    local gym = data.gym
    local nutritionOptions = {}
    
    for itemId, item in pairs(Config.NutritionItems) do
        table.insert(nutritionOptions, {
            header = item.name,
            txt = string.format('$%d - %s', item.price, item.description),
            params = {
                event = 'ls-gym:client:PurchaseNutrition',
                args = {
                    item = itemId,
                    price = item.price,
                    name = item.name
                }
            }
        })
    end
    
    table.insert(nutritionOptions, {
        header = 'Cancel',
        txt = 'Close nutrition menu',
        params = {
            event = 'qb-menu:closeMenu'
        }
    })
    
    exports['qb-menu']:openMenu(nutritionOptions)
end)

RegisterNetEvent('ls-gym:client:PurchaseNutrition', function(data)
    QBCore.Functions.TriggerCallback('ls-gym:server:PurchaseNutrition', function(success)
        if success then
            QBCore.Functions.Notify('Purchased ' .. data.name, 'success')
        else
            QBCore.Functions.Notify('Not enough money!', 'error')
        end
    end, data.item, data.price)
end)

RegisterNetEvent('ls-gym:client:ConsumeNutrition', function(item)
    local nutritionItem = Config.NutritionItems[item]
    if not nutritionItem then return end
    
    -- Apply effects
    if nutritionItem.energy then
        nutritionData.energy = math.min(100, nutritionData.energy + nutritionItem.energy)
    end
    if nutritionItem.hunger then
        nutritionData.hunger = math.min(100, nutritionData.hunger + nutritionItem.hunger)
    end
    if nutritionItem.thirst then
        nutritionData.thirst = math.min(100, nutritionData.thirst + nutritionItem.thirst)
    end
    
    QBCore.Functions.Notify('Consumed ' .. nutritionItem.name, 'success')
end)

-- ================================================
-- LOCKER ROOM SYSTEM
-- ================================================

RegisterNetEvent('ls-gym:client:OpenLockerRoom', function(data)
    local lockerOptions = {
        {
            header = 'Change Clothes',
            txt = 'Change into gym clothes',
            params = {
                event = 'ls-gym:client:ChangeClothes',
                args = {type = 'gym'}
            }
        },
        {
            header = 'Change Back',
            txt = 'Change back to normal clothes',
            params = {
                event = 'ls-gym:client:ChangeClothes',
                args = {type = 'normal'}
            }
        },
        {
            header = 'Store Items',
            txt = 'Store items in locker',
            params = {
                event = 'ls-gym:client:StoreItems'
            }
        },
        {
            header = 'Retrieve Items',
            txt = 'Retrieve items from locker',
            params = {
                event = 'ls-gym:client:RetrieveItems'
            }
        },
        {
            header = 'Cancel',
            txt = 'Close locker menu',
            params = {
                event = 'qb-menu:closeMenu'
            }
        }
    }
    
    exports['qb-menu']:openMenu(lockerOptions)
end)

RegisterNetEvent('ls-gym:client:ChangeClothes', function(data)
    local ped = PlayerPedId()
    
    if data.type == 'gym' then
        -- Apply gym outfit
        local outfit = Config.GymOutfit
        for component, data in pairs(outfit) do
            SetPedComponentVariation(ped, data.component, data.drawable, data.texture, 0)
        end
        QBCore.Functions.Notify('Changed into gym clothes', 'success')
    else
        -- Restore original outfit
        TriggerEvent('qb-clothing:client:loadOutfit')
        QBCore.Functions.Notify('Changed back to normal clothes', 'success')
    end
end)

-- ================================================
-- COMPETITION SYSTEM
-- ================================================

RegisterNetEvent('ls-gym:client:ShowCompetitionResults', function(results)
    local competitionOptions = {}
    
    table.insert(competitionOptions, {
        header = 'Competition Results',
        txt = 'Bodybuilding Competition Rankings',
        isMenuHeader = true
    })
    
    for i, participant in ipairs(results) do
        table.insert(competitionOptions, {
            header = string.format('%d. %s', i, participant.name),
            txt = string.format('Score: %d | Prize: $%d', participant.score, participant.prize),
            params = {
                event = 'qb-menu:closeMenu'
            }
        })
    end
    
    exports['qb-menu']:openMenu(competitionOptions)
end)

-- ================================================
-- UI CALLBACKS
-- ================================================

RegisterNUICallback('closeWorkout', function(data, cb)
    CancelWorkout()
    cb('ok')
end)

RegisterNUICallback('getProgress', function(data, cb)
    cb({progress = workoutProgress})
end)

-- ================================================
-- EXPORTS
-- ================================================

exports('IsInGym', function()
    return isInGym
end)

exports('IsWorkingOut', function()
    return currentWorkout ~= nil
end)

exports('GetWorkoutProgress', function()
    return workoutProgress
end)

exports('GetNutritionData', function()
    return nutritionData
end)