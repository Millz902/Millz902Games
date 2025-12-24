local QBCore = exports['qb-core']:GetCoreObject()

-- Client-side functionality for the server scanner
local scanInProgress = false

-- Create command for players to run the scanner
RegisterCommand('serverscan', function()
    local playerData = QBCore.Functions.GetPlayerData()
    
    -- Only allow server scan for admins
    if playerData.metadata.admin then
        if not scanInProgress then
            scanInProgress = true
            QBCore.Functions.Notify('Starting server scan...', 'primary', 7500)
            
            -- Trigger the server event to run the scan
            TriggerServerEvent('ls-scanner:server:runScan')
            
            -- Reset the flag after a delay
            Citizen.SetTimeout(10000, function()
                scanInProgress = false
            end)
        else
            QBCore.Functions.Notify('A scan is already in progress', 'error')
        end
    else
        QBCore.Functions.Notify('You do not have permission to use this command', 'error')
    end
end, false)

-- Register key binding if needed (default: CTRL+ALT+S)
RegisterKeyMapping('serverscan_menu', 'Open Server Scanner Menu', 'keyboard', 'DELETE')

-- Command to show the server scanner menu
RegisterCommand('serverscan_menu', function()
    local playerData = QBCore.Functions.GetPlayerData()
    
    -- Only show menu for admins
    if playerData.metadata.admin then
        -- Show menu with options
        local MenuItems = {
            {
                header = "Los Scotia Server Scanner",
                isMenuHeader = true
            },
            {
                header = "Run Full Server Scan",
                txt = "Check for conflicts, issues, and missing dependencies",
                params = {
                    event = "ls-scanner:client:runFullScan",
                }
            },
            {
                header = "Scan for Conflicts Only",
                txt = "Check for resource conflicts and duplicates",
                params = {
                    event = "ls-scanner:client:scanConflicts",
                }
            },
            {
                header = "Check Dependencies",
                txt = "Analyze resource dependencies and load order issues",
                params = {
                    event = "ls-scanner:client:checkDependencies",
                }
            },
            {
                header = "Check SQL Integrity",
                txt = "Validate SQL files and database structure",
                params = {
                    event = "ls-scanner:client:checkSQL",
                }
            },
            {
                header = "Validate Core Systems",
                txt = "Check functionality of critical server systems",
                params = {
                    event = "ls-scanner:client:checkSystems",
                }
            },
            {
                header = "Generate Report File",
                txt = "Create a detailed report file (HTML and TXT) for later review",
                params = {
                    event = "ls-scanner:client:generateReport",
                }
            },
            {
                header = "View Latest Reports",
                txt = "List and open recently generated reports",
                params = {
                    event = "ls-scanner:client:viewReports",
                }
            },
            {
                header = "Close Menu",
                txt = "",
                params = {
                    event = "qb-menu:client:closeMenu",
                }
            },
        }
        
        -- Export to open menu
        exports['qb-menu']:openMenu(MenuItems)
    else
        QBCore.Functions.Notify('You do not have permission to use this menu', 'error')
    end
end, false)

-- Event handlers for menu options
RegisterNetEvent('ls-scanner:client:runFullScan')
AddEventHandler('ls-scanner:client:runFullScan', function()
    if not scanInProgress then
        scanInProgress = true
        QBCore.Functions.Notify('Starting full server scan...', 'primary', 7500)
        
        -- Trigger the server event to run the scan
        TriggerServerEvent('ls-scanner:server:runScan')
        
        -- Reset the flag after a delay
        Citizen.SetTimeout(10000, function()
            scanInProgress = false
        end)
    else
        QBCore.Functions.Notify('A scan is already in progress', 'error')
    end
end)

RegisterNetEvent('ls-scanner:client:scanConflicts')
AddEventHandler('ls-scanner:client:scanConflicts', function()
    QBCore.Functions.Notify('Starting conflict scan...', 'primary', 7500)
    TriggerServerEvent('ls-scanner:server:runConflictScan')
end)

RegisterNetEvent('ls-scanner:client:checkDependencies')
AddEventHandler('ls-scanner:client:checkDependencies', function()
    QBCore.Functions.Notify('Analyzing resource dependencies...', 'primary', 7500)
    TriggerServerEvent('ls-scanner:server:runDependencyCheck')
end)

RegisterNetEvent('ls-scanner:client:checkSQL')
AddEventHandler('ls-scanner:client:checkSQL', function()
    QBCore.Functions.Notify('Starting SQL integrity check...', 'primary', 7500)
    TriggerServerEvent('ls-scanner:server:runSQLCheck')
end)

RegisterNetEvent('ls-scanner:client:checkSystems')
AddEventHandler('ls-scanner:client:checkSystems', function()
    QBCore.Functions.Notify('Validating core systems functionality...', 'primary', 7500)
    TriggerServerEvent('ls-scanner:server:runSystemsCheck')
end)

RegisterNetEvent('ls-scanner:client:generateReport')
AddEventHandler('ls-scanner:client:generateReport', function()
    QBCore.Functions.Notify('Generating comprehensive report file...', 'primary', 7500)
    TriggerServerEvent('ls-scanner:server:generateReport')
end)

-- View reports menu
RegisterNetEvent('ls-scanner:client:viewReports')
AddEventHandler('ls-scanner:client:viewReports', function()
    QBCore.Functions.Notify('Fetching available reports...', 'primary', 3000)
    TriggerServerEvent('ls-scanner:server:getReportsList')
end)

-- Display list of reports
RegisterNetEvent('ls-scanner:client:showReportsList')
AddEventHandler('ls-scanner:client:showReportsList', function(reports)
    if #reports == 0 then
        QBCore.Functions.Notify('No reports found. Generate a report first.', 'error')
        return
    end
    
    local MenuItems = {
        {
            header = "Los Scotia Scanner Reports",
            isMenuHeader = true
        }
    }
    
    -- Add each report to the menu
    for i, report in ipairs(reports) do
        -- Parse the timestamp from the filename
        local timestamp = report:match("ls_scanner_report_(%d+%-%d+%-%d+_%d+%-%d+%-%d+)")
        if not timestamp then timestamp = report end
        
        local reportType = "Unknown"
        if report:match("%.html$") then
            reportType = "HTML Report"
        elseif report:match("%.txt$") then
            reportType = "Text Report"
        end
        
        table.insert(MenuItems, {
            header = reportType .. " - " .. timestamp,
            txt = "View this report",
            params = {
                event = "ls-scanner:client:openReport",
                args = {
                    filename = report
                }
            }
        })
    end
    
    -- Add back button
    table.insert(MenuItems, {
        header = "⬅ Back to Scanner Menu",
        txt = "",
        params = {
            event = "ls-scanner:client:backToMainMenu",
        }
    })
    
    -- Open the menu
    exports['qb-menu']:openMenu(MenuItems)
end)

-- Return to main menu
RegisterNetEvent('ls-scanner:client:backToMainMenu')
AddEventHandler('ls-scanner:client:backToMainMenu', function()
    -- Re-open the server scanner menu
    TriggerEvent('serverscan_menu')
end)

-- Open a specific report
RegisterNetEvent('ls-scanner:client:openReport')
AddEventHandler('ls-scanner:client:openReport', function(data)
    if data and data.filename then
        TriggerServerEvent('ls-scanner:server:openReport', data.filename)
    end
end)

-- Notification event
RegisterNetEvent('ls-scanner:client:notify')
AddEventHandler('ls-scanner:client:notify', function(message, type)
    QBCore.Functions.Notify(message, type)
end)

-- Display text report content in chat
RegisterNetEvent('ls-scanner:client:displayReportChunk')
AddEventHandler('ls-scanner:client:displayReportChunk', function(chunk, isFirst)
    if isFirst then
        TriggerEvent('chat:addMessage', {
            color = {52, 152, 219},
            multiline = true,
            args = {"SERVER SCANNER REPORT", ""}
        })
    end
    
    -- Display the chunk in chat
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 255},
        multiline = true,
        args = {"", chunk}
    })
end)

-- Open URL in browser
RegisterNetEvent('ls-scanner:client:openUrl')
AddEventHandler('ls-scanner:client:openUrl', function(url)
    SendNUIMessage({
        type = "openBrowser",
        url = url
    })
end)