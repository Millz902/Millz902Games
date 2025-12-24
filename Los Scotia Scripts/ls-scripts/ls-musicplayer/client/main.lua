local QBCore = exports['qb-core']:GetCoreObject()
local musicPlayerVisible = false
local defaultPlaylist = {
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

-- Function to show the music player
function ShowMusicPlayer(playlist, autoplay)
    if not musicPlayerVisible then
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'showMusicPlayer',
            playlist = playlist or defaultPlaylist,
            autoplay = autoplay or true
        })
        musicPlayerVisible = true
    end
end

-- Function to hide the music player
function HideMusicPlayer()
    if musicPlayerVisible then
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = 'hideMusicPlayer'
        })
        musicPlayerVisible = false
    end
end

-- Function to play/pause music
function TogglePlayPause()
    SendNUIMessage({
        type = 'playPause'
    })
end

-- Function to go to next track
function NextTrack()
    SendNUIMessage({
        type = 'nextTrack'
    })
end

-- Function to go to previous track
function PrevTrack()
    SendNUIMessage({
        type = 'prevTrack'
    })
end

-- Function to set volume (0.0 - 1.0)
function SetVolume(volume)
    SendNUIMessage({
        type = 'setVolume',
        volume = volume
    })
end

-- Function to set custom playlist
function SetPlaylist(playlist)
    SendNUIMessage({
        type = 'setPlaylist',
        playlist = playlist
    })
end

-- NUI Callbacks
RegisterNUICallback('musicPlayerClosed', function(data, cb)
    HideMusicPlayer()
    cb('ok')
end)

-- Register event handlers
RegisterNetEvent('ls-musicplayer:client:showMusicPlayer')
AddEventHandler('ls-musicplayer:client:showMusicPlayer', function(playlist, autoplay)
    ShowMusicPlayer(playlist, autoplay)
end)

RegisterNetEvent('ls-musicplayer:client:hideMusicPlayer')
AddEventHandler('ls-musicplayer:client:hideMusicPlayer', function()
    HideMusicPlayer()
end)

RegisterNetEvent('ls-musicplayer:client:togglePlayPause')
AddEventHandler('ls-musicplayer:client:togglePlayPause', function()
    TogglePlayPause()
end)

RegisterNetEvent('ls-musicplayer:client:nextTrack')
AddEventHandler('ls-musicplayer:client:nextTrack', function()
    NextTrack()
end)

RegisterNetEvent('ls-musicplayer:client:prevTrack')
AddEventHandler('ls-musicplayer:client:prevTrack', function()
    PrevTrack()
end)

RegisterNetEvent('ls-musicplayer:client:setVolume')
AddEventHandler('ls-musicplayer:client:setVolume', function(volume)
    SetVolume(volume)
end)

RegisterNetEvent('ls-musicplayer:client:setPlaylist')
AddEventHandler('ls-musicplayer:client:setPlaylist', function(playlist)
    SetPlaylist(playlist)
end)

-- Export functions
exports('ShowMusicPlayer', ShowMusicPlayer)
exports('HideMusicPlayer', HideMusicPlayer)
exports('TogglePlayPause', TogglePlayPause)
exports('NextTrack', NextTrack)
exports('PrevTrack', PrevTrack)
exports('SetVolume', SetVolume)
exports('SetPlaylist', SetPlaylist)

-- Command to show/hide music player for testing
RegisterCommand('musicplayer', function()
    if musicPlayerVisible then
        HideMusicPlayer()
    else
        ShowMusicPlayer()
    end
end, false)