-- Enhanced loading screen branding for Los Scotia
Citizen.CreateThread(function()
    -- Wait for game to initialize
    Citizen.Wait(5000)
    
    -- Add custom text to loading screens
    AddTextEntry('FE_THDR_LOADING', '~r~LOS SCOTIA~w~ | Loading...')
    AddTextEntry('FE_THDR_GTAOONLINE', '~r~LOS SCOTIA~w~ | Connecting to Server')
    
    -- Add custom hints for loading screens
    local loadingScreenHints = {
        "Welcome to Los Scotia, the premier FiveM roleplay experience!",
        "Join our Discord at discord.gg/losscotia for the latest news and updates.",
        "Need help? Press F9 to open our Discord.",
        "Respect other players and follow server rules for the best experience.",
        "Report bugs and issues to our admin team via Discord.",
        "Los Scotia is brought to you by Millz902Games.",
        "Remember to use '/me' and '/do' commands for proper roleplay!",
        "Press F1 to access the radial menu."
    }
    
    for i, hint in ipairs(loadingScreenHints) do
        AddTextEntry('LOADING_HINT_' .. i, hint)
    end
end)