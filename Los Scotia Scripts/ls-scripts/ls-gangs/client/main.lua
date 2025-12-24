local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

-- Variables
local inGangTerritory = false
local currentGang = nil
local gangBlips = {}
local gangZones = {}

-- Initialize
CreateThread(function()
    while not QBCore do
        Wait(10)
    end
    
    PlayerData = QBCore.Functions.GetPlayerData()
    
    -- Setup gang system
    SetupGangSystem()
    
    -- Create gang blips and zones
    CreateGangBlipsAndZones()
end)

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    SetupGangSystem()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    RemoveGangBlips()
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    PlayerData.gang = gang
    UpdateGangDisplay()
end)

RegisterNetEvent('ls-gangs:client:UpdateGangData', function(gangData)
    currentGang = gangData
    UpdateGangInterface()
end)

RegisterNetEvent('ls-gangs:client:EnterTerritory', function(gangName)
    inGangTerritory = true
    currentGang = gangName
    
    QBCore.Functions.Notify('You have entered ' .. gangName .. ' territory', 'primary', 5000)
    
    -- Show territory notification
    ShowTerritoryNotification(gangName, true)
end)

RegisterNetEvent('ls-gangs:client:ExitTerritory', function(gangName)
    inGangTerritory = false
    currentGang = nil
    
    QBCore.Functions.Notify('You have left ' .. gangName .. ' territory', 'primary', 3000)
    
    -- Hide territory notification
    ShowTerritoryNotification(gangName, false)
end)

RegisterNetEvent('ls-gangs:client:StartGangWar', function(data)
    QBCore.Functions.Notify('Gang war has started between ' .. data.gang1 .. ' and ' .. data.gang2, 'error', 10000)
    
    -- Start gang war effects
    StartGangWarEffects(data)
end)

RegisterNetEvent('ls-gangs:client:EndGangWar', function(data)
    QBCore.Functions.Notify('Gang war has ended. Winner: ' .. data.winner, 'success', 8000)
    
    -- End gang war effects
    EndGangWarEffects()
end)

-- Functions
function SetupGangSystem()
    if not PlayerData.gang then return end
    
    -- Request gang data from server
    TriggerServerEvent('ls-gangs:server:GetGangData', PlayerData.gang.name)
    
    -- Setup gang commands
    SetupGangCommands()
    
    -- Setup gang interactions
    SetupGangInteractions()
end

function SetupGangCommands()
    -- Gang management commands
    RegisterCommand('gang', function(source, args, rawCommand)
        if not PlayerData.gang then
            QBCore.Functions.Notify('You are not in a gang', 'error')
            return
        end
        
        OpenGangMenu()
    end, false)
    
    RegisterCommand('gangwar', function(source, args, rawCommand)
        if not PlayerData.gang then
            QBCore.Functions.Notify('You are not in a gang', 'error')
            return
        end
        
        if PlayerData.gang.grade.level < 3 then
            QBCore.Functions.Notify('You do not have permission to declare war', 'error')
            return
        end
        
        if args[1] then
            TriggerServerEvent('ls-gangs:server:DeclareWar', args[1])
        else
            QBCore.Functions.Notify('Usage: /gangwar [gang_name]', 'error')
        end
    end, false)
    
    RegisterCommand('gangstatus', function(source, args, rawCommand)
        if not PlayerData.gang then
            QBCore.Functions.Notify('You are not in a gang', 'error')
            return
        end
        
        TriggerServerEvent('ls-gangs:server:GetGangStatus')
    end, false)
end

function SetupGangInteractions()
    -- Drug selling interactions
    exports['qb-target']:AddGlobalPlayer({
        options = {
            {
                type = "client",
                event = "ls-gangs:client:SellDrugs",
                icon = "fas fa-pills",
                label = "Sell Drugs",
                canInteract = function(entity)
                    return PlayerData.gang and HasDrugsInInventory()
                end,
            },
        },
        distance = 2.0
    })
    
    -- Gang recruitment
    exports['qb-target']:AddGlobalPlayer({
        options = {
            {
                type = "client",
                event = "ls-gangs:client:RecruitPlayer",
                icon = "fas fa-user-plus",
                label = "Recruit to Gang",
                canInteract = function(entity)
                    return PlayerData.gang and PlayerData.gang.grade.level >= 2
                end,
            },
        },
        distance = 2.0
    })
end

function CreateGangBlipsAndZones()
    TriggerServerEvent('ls-gangs:server:GetGangTerritories')
end

function CreateGangBlip(gangData)
    local blip = AddBlipForCoord(gangData.coords.x, gangData.coords.y, gangData.coords.z)
    SetBlipSprite(blip, 84)
    SetBlipColour(blip, gangData.color or 1)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(gangData.name .. ' Territory')
    EndTextCommandSetBlipName(blip)
    
    gangBlips[gangData.name] = blip
end

function RemoveGangBlips()
    for _, blip in pairs(gangBlips) do
        RemoveBlip(blip)
    end
    gangBlips = {}
end

function OpenGangMenu()
    local gangMenu = {
        {
            header = PlayerData.gang.label .. ' Management',
            isMenuHeader = true
        },
        {
            header = 'Gang Information',
            txt = 'View gang details and statistics',
            icon = 'fas fa-info-circle',
            params = {
                event = 'ls-gangs:client:ViewGangInfo'
            }
        },
        {
            header = 'Member Management',
            txt = 'Manage gang members',
            icon = 'fas fa-users',
            params = {
                event = 'ls-gangs:client:ManageMembers'
            }
        },
        {
            header = 'Territory Control',
            txt = 'View and manage territories',
            icon = 'fas fa-map',
            params = {
                event = 'ls-gangs:client:TerritoryMenu'
            }
        },
        {
            header = 'Gang Stash',
            txt = 'Access gang stash',
            icon = 'fas fa-box',
            params = {
                event = 'ls-gangs:client:OpenStash'
            }
        },
        {
            header = 'Close Menu',
            txt = '',
            icon = 'fas fa-times',
            params = {
                event = 'qb-menu:client:closeMenu'
            }
        }
    }
    
    exports['qb-menu']:openMenu(gangMenu)
end

function ShowTerritoryNotification(gangName, entering)
    local text = entering and 'ENTERING' or 'LEAVING'
    local color = entering and '~g~' or '~r~'
    
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextScale(0.8, 0.8)
    SetTextCentre(1)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentString(color .. text .. ' ~w~' .. gangName:upper() .. ' TERRITORY')
    EndTextCommandDisplayText(0.5, 0.85)
end

function StartGangWarEffects(data)
    -- Add visual and audio effects for gang war
    CreateThread(function()
        while inGangWar do
            -- Flash screen red occasionally
            if math.random(1, 100) <= 5 then
                SetFlash(0, 0, 100, 500, 100)
            end
            Wait(1000)
        end
    end)
end

function EndGangWarEffects()
    inGangWar = false
end

function HasDrugsInInventory()
    local items = {'weed_brick', 'coke_brick', 'meth'}
    for _, item in pairs(items) do
        if QBCore.Functions.HasItem(item) then
            return true
        end
    end
    return false
end

-- Gang Events
RegisterNetEvent('ls-gangs:client:ViewGangInfo', function()
    TriggerServerEvent('ls-gangs:server:GetGangInfo')
end)

RegisterNetEvent('ls-gangs:client:ManageMembers', function()
    if PlayerData.gang.grade.level < 2 then
        QBCore.Functions.Notify('You do not have permission to manage members', 'error')
        return
    end
    TriggerServerEvent('ls-gangs:server:GetGangMembers')
end)

RegisterNetEvent('ls-gangs:client:TerritoryMenu', function()
    TriggerServerEvent('ls-gangs:server:GetTerritories')
end)

RegisterNetEvent('ls-gangs:client:OpenStash', function()
    if not PlayerData.gang then return end
    TriggerEvent('inventory:client:SetCurrentStash', PlayerData.gang.name .. '_stash')
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', PlayerData.gang.name .. '_stash', {
        maxweight = 1000000,
        slots = 50,
    })
end)

RegisterNetEvent('ls-gangs:client:SellDrugs', function(data)
    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    TriggerServerEvent('ls-gangs:server:SellDrugs', targetId)
end)

RegisterNetEvent('ls-gangs:client:RecruitPlayer', function(data)
    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    TriggerServerEvent('ls-gangs:server:RecruitPlayer', targetId)
end)