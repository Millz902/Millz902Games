-- Los Scotia Brightness Fix - Client Side
-- Comprehensive fix for screen dimming, black overlays, and brightness issues

local QBCore = exports['qb-core']:GetCoreObject()

-- IMMEDIATE brightness fix on client load (before character selection)
CreateThread(function()
    -- Run immediately on resource start
    FixScreenBrightness()
    Wait(100)
    FixScreenBrightness()
    Wait(500) 
    FixScreenBrightness()
    Wait(1000)
    FixScreenBrightness()
    Wait(2000) -- Wait for everything to load
    FixScreenBrightness()
end)

-- EMERGENCY immediate fix on any script load
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        FixScreenBrightness()
    end
end)

-- Aggressive brightness fix function
function FixScreenBrightness()
    print("^2[LS-BRIGHTNESS] Applying AGGRESSIVE brightness fixes...^7")
    
    -- FORCE clear all NUI focus (common cause of dimming)
    for i = 1, 10 do
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        Wait(10)
    end
    
    -- FORCE reset ALL timecycle modifiers
    ClearTimecycleModifier()
    ClearExtraTimecycleModifier()
    SetTimecycleModifier("")
    SetTimecycleModifierStrength(0.0)
    SetExtraTimecycleModifier("")
    SetExtraTimecycleModifierStrength(0.0)
    SetTransitionTimecycleModifier("", 0.0)
    
    -- FORCE clear weather effects
    SetWeatherTypeNow("CLEAR")
    SetWeatherTypeNowPersist("CLEAR")
    SetRainFxIntensity(0.0)
    SetWindSpeed(0.0)
    
    -- FORCE clear ALL screen effects
    for i = 0, 50 do
        SetScreenEffect("", 0, false)
        StopScreenEffect("")
    end
    
    -- FORCE clear vision modes
    SetNightvision(false)
    SetSeethrough(false)
    
    -- FORCE screen fade in multiple times
    for i = 1, 5 do
        DoScreenFadeIn(50)
        Wait(10)
    end
    
    -- FORCE disable artificial lighting
    SetArtificialLightsState(false)
    
    -- FORCE reset camera
    SetCamEffect(0)
    ResetScriptGfxAlign()
    
    -- DISABLE all overlays and post-processing
    DisplayHud(true)
    DisplayRadar(true)
    
    print("^2[LS-BRIGHTNESS] AGGRESSIVE brightness fixes applied!^7")
end

-- Command to manually fix brightness
RegisterCommand('fixbrightness', function()
    FixScreenBrightness()
    if QBCore then
        QBCore.Functions.Notify('Screen brightness reset!', 'success')
    else
        print("^2Screen brightness has been reset!^7")
    end
end, false)

-- Alternative command names
RegisterCommand('fixdim', function()
    ExecuteCommand('fixbrightness')
end, false)

RegisterCommand('cleardim', function()
    ExecuteCommand('fixbrightness')
end, false)

RegisterCommand('brightfix', function()
    ExecuteCommand('fixbrightness')
end, false)

-- Auto-fix on certain events that can cause dimming
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(3000)
    FixScreenBrightness()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    FixScreenBrightness()
end)

-- Handle server-triggered brightness fix
RegisterNetEvent('ls-brightness:fixBrightness', function()
    FixScreenBrightness()
end)

RegisterNetEvent('ls-brightness:fixAll', function()
    FixScreenBrightness()
end)

-- AGGRESSIVE anti-dimming monitoring (runs frequently)
CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds instead of 30
        
        -- FORCE clear NUI focus if stuck
        if IsNuiFocused() then
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
        end
        
        -- FORCE clear ANY timecycle modifiers
        ClearTimecycleModifier()
        ClearExtraTimecycleModifier()
        
        -- FORCE clear weather effects that cause dimming
        SetWeatherTypeNow("CLEAR")
        
        -- FORCE disable screen effects
        SetScreenEffect("", 0, false)
        StopScreenEffect("")
        
        -- FORCE screen fade in if needed
        if IsScreenFadedOut() or IsScreenFadingOut() then
            DoScreenFadeIn(100)
        end
    end
end)

-- GENTLE brightness maintenance (stops radar flashing)
CreateThread(function()
    while true do
        Wait(10000) -- Check every 10 seconds, much less aggressive
        
        -- Only fix if there's actually a problem
        local playerPed = PlayerPedId()
        if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
            -- Only clear vision modes if they're actually on
            if IsNightvisionActive() then
                SetNightvision(false)
            end
            if IsSeethroughActive() then
                SetSeethrough(false)
            end
        end
    end
end)

-- GENTLE loading screen monitoring (less aggressive)
CreateThread(function()
    while true do
        Wait(2000) -- Check every 2 seconds instead of 50ms
        
        -- Only clear if actually stuck, not constantly
        if IsScreenFadedOut() then
            DoScreenFadeIn(1000) -- Gentle fade in with 1 second duration
        end
        
        -- Only clear NUI if it's actually stuck
        if IsNuiFocused() and not IsPauseMenuActive() then
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
        end
    end
end)

-- LOADING COMPLETION FIX
AddEventHandler('playerSpawned', function()
    -- When player spawns (after loading), clear any stuck dimming
    CreateThread(function()
        Wait(1000) -- Wait 1 second after spawn
        FixScreenBrightness()
        Wait(2000) -- Wait another 2 seconds
        FixScreenBrightness()
    end)
end)

-- FIX for when client finishes loading
AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- This resource started, likely after loading screen
        CreateThread(function()
            Wait(5000) -- Wait 5 seconds for everything to settle
            FixScreenBrightness()
        end)
    end
end)

print("^2[LS-BRIGHTNESS] Brightness fix system loaded - Use /fixbrightness to reset screen^7")