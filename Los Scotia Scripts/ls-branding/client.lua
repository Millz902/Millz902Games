local QBCore = exports['qb-core']:GetCoreObject()

-- Server branding resources
local Config = {
    -- Los Scotia branding
    brandName = "Los Scotia",
    brandColor = "~r~", -- Red color
    companyName = "Millz902Games",
    
    -- Pause menu text replacements
    pauseMenuTitle = "Los Scotia Roleplay",
    
    -- Menu integration
    injectQBMenus = true,
    injectRadialMenu = true,
    
    -- Welcome message
    showWelcomeMessage = true,
    welcomeMessage = "Welcome to Los Scotia Roleplay",
    welcomeTitle = "LOS SCOTIA",
    welcomeSubtitle = "ROLEPLAY SERVER",
    welcomeIcon = "info",
    
    -- UI replacements
    replaceLoadingScreens = true,
    replaceCharacterUI = true,
    
    -- Watermark options
    watermark = {
        enabled = true,
        text = "Los Scotia Roleplay",
        position = "topleft", -- Options: topleft, topright, bottomleft, bottomright
        color = {255, 0, 0, 180}, -- RGBA format
    },
    
    -- Discord button
    discordButton = {
        enabled = true,
        link = "https://discord.gg/losscotia",
        text = "Join Our Discord"
    }
}

-- Function to override GTA pause menu header
Citizen.CreateThread(function()
    while true do
        -- Add Los Scotia branding to the pause menu
        AddTextEntry('FE_THDR_GTAO', Config.brandColor .. Config.pauseMenuTitle)
        
        -- Replace "Rockstar Games" with "Millz902Games" in various text entries
        AddTextEntry('PM_PANE_LEAVE', 'Return to ' .. Config.brandColor .. Config.brandName)
        AddTextEntry('PM_PANE_QUIT', 'Quit ' .. Config.brandColor .. Config.brandName)
        
        -- Replace other text entries
        AddTextEntry('PM_PANE_FEH', Config.brandColor .. Config.brandName .. '~w~ Help')
        AddTextEntry('FE_THDR_GTAO', Config.brandColor .. Config.pauseMenuTitle .. ' Online')
        
        -- Sleep to avoid unnecessary resource usage
        Citizen.Wait(60000) -- Check every minute (this rarely changes)
    end
end)

-- Function to override various UI elements with Los Scotia branding
Citizen.CreateThread(function()
    -- Wait for player to be fully loaded
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(0)
    end
    
    -- Display welcome message after short delay
    if Config.showWelcomeMessage then
        Citizen.Wait(5000)
        
        -- Enhanced welcome message with QBCore notification
        TriggerEvent('QBCore:Notify', Config.welcomeMessage, Config.welcomeIcon, 10000)
        
        -- Also add to chat for visibility
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {Config.welcomeTitle, Config.welcomeMessage}
        })
        
        -- Show server information
        Citizen.Wait(12000)
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {Config.welcomeTitle, "^1Join our Discord: ^7discord.gg/losscotia"}
        })
    end
end)

-- Inject Los Scotia branding into QBCore menus
if Config.injectQBMenus then
    -- Hook into qb-menu events to add branding
    AddEventHandler('qb-menu:client:openMenu', function()
        -- Add small delay to let menu render first
        Citizen.Wait(100)
        
        -- Send NUI message to modify menu
        SendNUIMessage({
            action = 'injectBranding',
            data = {
                brandName = Config.brandName,
                brandColor = '#ff0000' -- Red in hex format for CSS
            }
        })
    end)
end

-- Custom watermark in corner of screen
local showWatermark = Config.watermark.enabled
local position = {x = 0.005, y = 0.005} -- Default: top left

-- Set watermark position based on config
if Config.watermark.position == "topright" then
    position = {x = 0.995, y = 0.005, align = 2} -- top right with right alignment
elseif Config.watermark.position == "bottomleft" then
    position = {x = 0.005, y = 0.985} -- bottom left
elseif Config.watermark.position == "bottomright" then
    position = {x = 0.995, y = 0.985, align = 2} -- bottom right with right alignment
end

-- Add server time to watermark
Citizen.CreateThread(function()
    while true do
        if showWatermark then
            -- Get current time (24-hour format)
            local h = GetClockHours()
            local m = GetClockMinutes()
            local time = string.format("%02d:%02d", h, m)
            
            -- Format watermark text
            local watermarkText = Config.watermark.text .. " | " .. time
            
            -- Draw text with proper position and alignment
            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(table.unpack(Config.watermark.color))
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(watermarkText)
            
            if position.align == 2 then
                SetTextRightJustify(true)
                SetTextWrap(0.0, position.x)
            end
            
            DrawText(position.x, position.y)
        end
        Citizen.Wait(1000) -- Update once per second
    end
end)

-- Command to toggle watermark
RegisterCommand('watermark', function()
    showWatermark = not showWatermark
    TriggerEvent('QBCore:Notify', (showWatermark and 'Watermark shown' or 'Watermark hidden'), 'success')
    
    -- Save preference for session
    SetResourceKvp('ls_watermark_enabled', tostring(showWatermark))
end, false)

-- Discord button
if Config.discordButton.enabled then
    RegisterCommand('discord', function()
        -- Attempt to open Discord link via UI
        SendNUIMessage({
            action = 'openURL',
            url = Config.discordButton.link
        })
        
        -- Also show in chat for backup
        TriggerEvent('chat:addMessage', {
            color = {114, 137, 218}, -- Discord blue
            multiline = true,
            args = {"DISCORD", "Join our community: " .. Config.discordButton.link}
        })
        
        TriggerEvent('QBCore:Notify', 'Discord link opened!', 'success')
    end, false)
    
    -- Register a keybinding for Discord (F9)
    RegisterKeyMapping('discord', 'Open Los Scotia Discord', 'keyboard', 'F9')
end