local QBCore = exports['qb-core']:GetCoreObject()

-- MDT Events
RegisterNetEvent('ls-police:client:OpenMDT', function()
    if not exports['ls-police']:IsOnDuty() then
        QBCore.Functions.Notify("You must be on duty to access the MDT", "error")
        return
    end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openMDT",
        playerData = QBCore.Functions.GetPlayerData()
    })
end)

RegisterNetEvent('ls-police:client:CloseMDT', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeMDT"
    })
end)

-- NUI Callbacks
RegisterNUICallback('closeMDT', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('searchCitizen', function(data, cb)
    QBCore.Functions.TriggerCallback('ls-police:server:SearchCitizen', function(result)
        cb(result)
    end, data.search)
end)

RegisterNUICallback('searchVehicle', function(data, cb)
    QBCore.Functions.TriggerCallback('ls-police:server:SearchVehicle', function(result)
        cb(result)
    end, data.plate)
end)

RegisterNUICallback('createBOLO', function(data, cb)
    TriggerServerEvent('ls-police:server:CreateBOLO', data)
    cb('ok')
end)

RegisterNUICallback('removeBOLO', function(data, cb)
    TriggerServerEvent('ls-police:server:RemoveBOLO', data.id)
    cb('ok')
end)

RegisterNUICallback('createReport', function(data, cb)
    TriggerServerEvent('ls-police:server:CreateReport', data)
    cb('ok')
end)

RegisterNUICallback('updateReport', function(data, cb)
    TriggerServerEvent('ls-police:server:UpdateReport', data)
    cb('ok')
end)

RegisterNUICallback('addEvidence', function(data, cb)
    TriggerServerEvent('ls-police:server:AddEvidence', data)
    cb('ok')
end)

-- Commands
RegisterCommand('mdt', function()
    if exports['ls-police']:IsPoliceJob() and exports['ls-police']:IsOnDuty() then
        TriggerEvent('ls-police:client:OpenMDT')
    else
        QBCore.Functions.Notify("You don't have access to this command", "error")
    end
end, false)

-- Key Mapping
RegisterKeyMapping('mdt', 'Open Police MDT', 'keyboard', 'F5')

-- MDT Vehicle Mount
CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle ~= 0 and exports['ls-police']:IsPoliceVehicle(vehicle) and exports['ls-police']:IsOnDuty() then
            if IsControlJustPressed(0, 57) then -- F10
                TriggerEvent('ls-police:client:OpenMDT')
            end
            
            -- Draw instruction
            DrawText2D(0.5, 0.95, "Press F10 to open MDT", 0.4, 4, {255, 255, 255, 255})
        end
    end
end)

-- Helper Functions
function DrawText2D(x, y, text, scale, font, color)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end