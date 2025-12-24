-- Anti-Dimming Fix Script
-- This script forces NUI focus to be properly released to prevent screen dimming

local QBCore = exports['qb-core']:GetCoreObject()

-- Force clear NUI focus on resource start
CreateThread(function()
    Wait(5000) -- Wait 5 seconds after resource start
    SetNuiFocus(false, false) -- Force disable NUI focus
    print('[ANTI-DIMMING] NUI focus cleared on startup')
end)

-- Clear NUI focus every 30 seconds as a safety measure
CreateThread(function()
    while true do
        Wait(30000) -- Every 30 seconds
        
        -- Check if player is not in any known UI state
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and not playerData.metadata.isdead then
            -- Only clear if not in a menu/UI that should have focus
            if not IsPauseMenuActive() and not IsControlPressed(0, 322) then -- ESC key
                SetNuiFocus(false, false)
            end
        end
    end
end)

-- Command to manually clear NUI focus
RegisterCommand('clearnui', function()
    SetNuiFocus(false, false)
    TriggerEvent('chat:addMessage', {
        color = { 0, 255, 0},
        multiline = true,
        args = {"[SYSTEM]", "NUI focus cleared!"}
    })
end)

-- Force clear on death/respawn
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    SetNuiFocus(false, false)
    print('[ANTI-DIMMING] NUI focus cleared on player load')
end)

RegisterNetEvent('hospital:client:Revive', function()
    Wait(1000)
    SetNuiFocus(false, false)
    print('[ANTI-DIMMING] NUI focus cleared after revive')
end)