local QBCore = exports['qb-core']:GetCoreObject()

-- Server-side configuration
local Config = {
    DefaultVolume = 0.7,
    EnabledInCharacterCreation = true,
    DefaultPlaylist = {
        {
            title = "Los Scotia Theme",
            artist = "Millz902Games",
            file = "theme.mp3",
            art = "img/los-scotia-logo.png"
        },
        {
            title = "Night Drive",
            artist = "Millz902Games",
            file = "night_drive.mp3",
            art = "img/los-scotia-night.png"
        },
        {
            title = "City Lights",
            artist = "Millz902Games",
            file = "city_lights.mp3",
            art = "img/los-scotia-city.png"
        }
    }
}

-- Event to send config to clients when requested
RegisterNetEvent('ls-musicplayer:server:requestConfig')
AddEventHandler('ls-musicplayer:server:requestConfig', function()
    local src = source
    TriggerClientEvent('ls-musicplayer:client:receiveConfig', src, Config)
end)

-- Admin command to change default volume server-wide
QBCore.Commands.Add('setmusicvolume', 'Set default music player volume (Admin Only)', {{name = 'volume', help = 'Volume from 0.0 to 1.0'}}, true, function(source, args)
    local volume = tonumber(args[1])
    if volume and volume >= 0.0 and volume <= 1.0 then
        Config.DefaultVolume = volume
        TriggerClientEvent('QBCore:Notify', source, 'Default music volume set to ' .. volume, 'success')
        
        -- Update all clients
        TriggerClientEvent('ls-musicplayer:client:setVolume', -1, volume)
    else
        TriggerClientEvent('QBCore:Notify', source, 'Invalid volume. Use a number between 0.0 and 1.0', 'error')
    end
end, 'admin')

-- Admin command to toggle music player in character creation
QBCore.Commands.Add('togglecreationmusic', 'Toggle music in character creation (Admin Only)', {}, true, function(source, args)
    Config.EnabledInCharacterCreation = not Config.EnabledInCharacterCreation
    TriggerClientEvent('QBCore:Notify', source, 'Music in character creation ' .. (Config.EnabledInCharacterCreation and 'enabled' or 'disabled'), 'success')
end, 'admin')

-- Print startup message
Citizen.CreateThread(function()
    print('^2[LS-MusicPlayer]^7 Music Player initialized successfully')
end)