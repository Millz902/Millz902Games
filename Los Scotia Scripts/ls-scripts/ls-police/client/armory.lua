local QBCore = exports['qb-core']:GetCoreObject()

-- Armory Events
RegisterNetEvent('ls-police:client:OpenArmory', function(data)
    if not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You must be on duty to access the armory", "error")
        return
    end
    
    local stationName = data.station
    local armoryData = Config.Armory[stationName]
    
    if not armoryData then
        QBCore.Functions.Notify("Armory not available at this location", "error")
        return
    end
    
    -- Create armory menu
    local armoryMenu = {
        {
            header = "Police Armory - " .. stationName,
            isMenuHeader = true,
        }
    }
    
    -- Add weapons section
    armoryMenu[#armoryMenu + 1] = {
        header = "🔫 Weapons",
        txt = "Access police weapons",
        params = {
            event = "ls-police:client:OpenWeapons",
            args = {
                station = stationName
            }
        }
    }
    
    -- Add items section
    armoryMenu[#armoryMenu + 1] = {
        header = "🎒 Equipment",
        txt = "Access police equipment",
        params = {
            event = "ls-police:client:OpenItems",
            args = {
                station = stationName
            }
        }
    }
    
    -- Add clothing section
    armoryMenu[#armoryMenu + 1] = {
        header = "👕 Uniforms",
        txt = "Change into uniform",
        params = {
            event = "ls-police:client:OpenClothing",
            args = {
                station = stationName
            }
        }
    }
    
    armoryMenu[#armoryMenu + 1] = {
        header = "⬅️ Close",
        params = {
            event = "qb-menu:closeMenu"
        }
    }
    
    exports['qb-menu']:openMenu(armoryMenu)
end)

RegisterNetEvent('ls-police:client:OpenWeapons', function(data)
    local stationName = data.station
    local weapons = Config.Armory[stationName].weapons
    
    local weaponMenu = {
        {
            header = "Police Weapons - " .. stationName,
            isMenuHeader = true,
        }
    }
    
    for i, weapon in ipairs(weapons) do
        local weaponData = QBCore.Shared.Weapons[weapon.name]
        local label = weaponData and weaponData.label or weapon.name
        
        weaponMenu[#weaponMenu + 1] = {
            header = label,
            txt = "Ammo: " .. weapon.amount,
            params = {
                isServer = true,
                event = "ls-police:server:GiveWeapon",
                args = {
                    weapon = weapon.name,
                    ammo = weapon.amount
                }
            }
        }
    end
    
    weaponMenu[#weaponMenu + 1] = {
        header = "⬅️ Back",
        params = {
            event = "ls-police:client:OpenArmory",
            args = {
                station = stationName
            }
        }
    }
    
    exports['qb-menu']:openMenu(weaponMenu)
end)

RegisterNetEvent('ls-police:client:OpenItems', function(data)
    local stationName = data.station
    local items = Config.Armory[stationName].items
    
    local itemMenu = {
        {
            header = "Police Equipment - " .. stationName,
            isMenuHeader = true,
        }
    }
    
    for i, item in ipairs(items) do
        local itemData = QBCore.Shared.Items[item.name]
        local label = itemData and itemData.label or item.name
        
        itemMenu[#itemMenu + 1] = {
            header = label,
            txt = "Amount: " .. item.amount,
            params = {
                isServer = true,
                event = "ls-police:server:GiveItem",
                args = {
                    item = item.name,
                    amount = item.amount
                }
            }
        }
    end
    
    itemMenu[#itemMenu + 1] = {
        header = "⬅️ Back",
        params = {
            event = "ls-police:client:OpenArmory",
            args = {
                station = stationName
            }
        }
    }
    
    exports['qb-menu']:openMenu(itemMenu)
end)

RegisterNetEvent('ls-police:client:OpenClothing', function(data)
    local clothingMenu = {
        {
            header = "Police Uniforms",
            isMenuHeader = true,
        },
        {
            header = "👮 Patrol Uniform",
            txt = "Standard patrol outfit",
            params = {
                event = "ls-police:client:ChangeClothing",
                args = {
                    type = "patrol"
                }
            }
        },
        {
            header = "🚁 SWAT Uniform",
            txt = "Tactical gear",
            params = {
                event = "ls-police:client:ChangeClothing",
                args = {
                    type = "swat"
                }
            }
        },
        {
            header = "🕵️ Detective Suit",
            txt = "Undercover clothing",
            params = {
                event = "ls-police:client:ChangeClothing",
                args = {
                    type = "detective"
                }
            }
        },
        {
            header = "👔 Civilian Clothes",
            txt = "Regular clothing",
            params = {
                event = "ls-police:client:ChangeClothing",
                args = {
                    type = "civilian"
                }
            }
        },
        {
            header = "⬅️ Back",
            params = {
                event = "ls-police:client:OpenArmory",
                args = data
            }
        }
    }
    
    exports['qb-menu']:openMenu(clothingMenu)
end)

RegisterNetEvent('ls-police:client:ChangeClothing', function(data)
    local ped = PlayerPedId()
    local gender = QBCore.Functions.GetPlayerData().charinfo.gender
    
    if data.type == "patrol" then
        if gender == 0 then -- Male
            SetPedComponentVariation(ped, 8, 58, 0, 0) -- Undershirt
            SetPedComponentVariation(ped, 11, 55, 0, 0) -- Torso
            SetPedComponentVariation(ped, 4, 35, 0, 0) -- Legs
            SetPedComponentVariation(ped, 6, 25, 0, 0) -- Feet
        else -- Female
            SetPedComponentVariation(ped, 8, 35, 0, 0) -- Undershirt
            SetPedComponentVariation(ped, 11, 48, 0, 0) -- Torso
            SetPedComponentVariation(ped, 4, 34, 0, 0) -- Legs
            SetPedComponentVariation(ped, 6, 25, 0, 0) -- Feet
        end
        SetPedPropIndex(ped, 6, 0, 0, true) -- Earpiece
    elseif data.type == "swat" then
        if gender == 0 then -- Male
            SetPedComponentVariation(ped, 8, 15, 0, 0) -- Undershirt
            SetPedComponentVariation(ped, 11, 53, 0, 0) -- Torso
            SetPedComponentVariation(ped, 4, 31, 0, 0) -- Legs
            SetPedComponentVariation(ped, 6, 25, 0, 0) -- Feet
        else -- Female
            SetPedComponentVariation(ped, 8, 15, 0, 0) -- Undershirt
            SetPedComponentVariation(ped, 11, 46, 0, 0) -- Torso
            SetPedComponentVariation(ped, 4, 30, 0, 0) -- Legs
            SetPedComponentVariation(ped, 6, 25, 0, 0) -- Feet
        end
        SetPedPropIndex(ped, 0, 125, 0, true) -- Helmet
    elseif data.type == "detective" then
        TriggerEvent('qb-clothing:client:openOutfitMenu')
    elseif data.type == "civilian" then
        TriggerEvent('qb-clothing:client:openOutfitMenu')
    end
    
    QBCore.Functions.Notify("Outfit changed", "success")
end)