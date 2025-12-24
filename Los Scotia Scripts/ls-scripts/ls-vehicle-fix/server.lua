-- Los Scotia Vehicle Fix - Server Side
print("^2[LS-VEHICLE] Server-side vehicle fix loaded^7")

-- Server commands for vehicle management
RegisterCommand('resetallvehicles', function(source, args, rawCommand)
    if source == 0 then -- Console command
        TriggerClientEvent('ls-vehicle:resetAll', -1)
        print("^2[LS-VEHICLE] Triggered vehicle reset for all players^7")
    else
        -- Check if player has admin permissions
        local Player = QBCore.Functions.GetPlayer(source)
        if Player and QBCore.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('ls-vehicle:resetAll', -1)
            TriggerClientEvent('QBCore:Notify', source, 'Vehicle system reset for all players', 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'No permission', 'error')
        end
    end
end, true)

-- Help command for vehicle issues
RegisterCommand('vehiclehelp', function(source, args, rawCommand)
    local helpText = [[
^2=== LOS SCOTIA VEHICLE FIX COMMANDS ===^7
^3/fixvehicles^7 - Reset vehicle system and fix changing issues
^3/spawntraffic^7 - Spawn additional DLC traffic vehicles
^3/resetallvehicles^7 - (Admin) Reset vehicles for all players

^2Vehicle Features:^7
- Enhanced DLC vehicle integration
- NPCs driving DLC cars in traffic
- Increased vehicle variety and density
- Fixed vehicle changing/switching issues
- Automatic traffic enhancement

^2If vehicles still have issues:^7
1. Use /fixvehicles command
2. Restart the resource: restart ls-vehicle-fix
3. Check for conflicting vehicle mods
4. Verify gameconfig compatibility
]]
    
    if source == 0 then
        print(helpText)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 255, 255},
            multiline = true,
            args = {"System", helpText}
        })
    end
end, false)

-- Event handlers
RegisterNetEvent('ls-vehicle:resetAll', function()
    -- This triggers client-side vehicle reset
end)