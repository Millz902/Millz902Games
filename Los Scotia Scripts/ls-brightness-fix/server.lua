-- Los Scotia Brightness Fix - Server Side
print("^2[LS-BRIGHTNESS] Server-side brightness fix loaded^7")

-- Server command to trigger client brightness fix for all players
RegisterCommand('fixallbrightness', function(source, args, rawCommand)
    if source == 0 then -- Console command
        TriggerClientEvent('ls-brightness:fixAll', -1)
        print("^2[LS-BRIGHTNESS] Triggered brightness fix for all players^7")
    else
        -- Check if player has admin permissions (adjust as needed)
        local Player = QBCore.Functions.GetPlayer(source)
        if Player and QBCore.Functions.HasPermission(source, 'admin') then
            TriggerClientEvent('ls-brightness:fixAll', -1)
            TriggerClientEvent('QBCore:Notify', source, 'Brightness fix applied to all players', 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'No permission', 'error')
        end
    end
end, true)

-- Event to fix brightness for all players
RegisterNetEvent('ls-brightness:fixAll', function()
    TriggerClientEvent('ls-brightness:fixBrightness', source)
end)

-- Help command for brightness issues
RegisterCommand('brightnesshelp', function(source, args, rawCommand)
    local helpText = [[
^2=== LOS SCOTIA BRIGHTNESS FIX COMMANDS ===^7
^3/fixbrightness^7 - Reset your screen brightness and clear dimming
^3/fixdim^7 - Alternative command for fixing dimming
^3/cleardim^7 - Clear screen dimming effects  
^3/brightfix^7 - Quick brightness reset
^3/fixallbrightness^7 - (Admin) Fix brightness for all players

^2Common Causes of Dimming:^7
- Stuck NUI menus or overlays
- Timecycle modifiers from scripts
- Weather effects (fog/rain)
- Night vision or thermal vision stuck on
- Screen transition effects

^2If dimming persists:^7
1. Try disconnecting and reconnecting
2. Check Windows display settings
3. Update graphics drivers
4. Verify monitor brightness settings
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