local QBCore = exports['qb-core']:GetCoreObject()

-- Integration with QBCore multicharacter and illenium-appearance
-- This will hook into the character creation process to show the music player

-- Function to detect when character creation starts
local function IntegrateWithCharacterCreation()
    -- Listen for multicharacter events
    AddEventHandler('qb-multicharacter:client:chooseCharacter', function()
        -- Small delay to let the UI load first
        Citizen.Wait(1000)
        TriggerEvent('ls-musicplayer:client:showMusicPlayer')
    end)

    -- Listen for illenium-appearance events
    AddEventHandler('illenium-appearance:client:openClothingMenu', function()
        -- Check if this is part of character creation (not just clothing store)
        -- Small delay to let the UI load first
        Citizen.Wait(1000)
        TriggerEvent('ls-musicplayer:client:showMusicPlayer')
    end)
    
    -- Alternative method if the above doesn't catch the event
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        -- Check if first login (new character)
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData.metadata and PlayerData.metadata.firstLogin then
            -- This is likely a new character, show music player
            Citizen.Wait(3000) -- Wait for other UI elements
            TriggerEvent('ls-musicplayer:client:showMusicPlayer')
        end
    end)

    -- Hook into qb-clothing events if used instead of illenium-appearance
    if GetResourceState('qb-clothing') ~= 'missing' then
        AddEventHandler('qb-clothing:client:openMenu', function()
            Citizen.Wait(1000)
            TriggerEvent('ls-musicplayer:client:showMusicPlayer')
        end)
    end
end

-- Initialize integration when resource starts
Citizen.CreateThread(function()
    IntegrateWithCharacterCreation()
end)

-- Listen for firstspawn event from cs_firstspawn resource
RegisterNetEvent('cs_firstspawn:client:startIntro')
AddEventHandler('cs_firstspawn:client:startIntro', function()
    -- Show music player during intro video
    TriggerEvent('ls-musicplayer:client:showMusicPlayer')
end)

-- Listen for player model change which might indicate character creation
AddEventHandler('skinchanger:modelLoaded', function()
    -- This is used by some clothing/character systems
    Citizen.Wait(1000)
    TriggerEvent('ls-musicplayer:client:showMusicPlayer')
end)