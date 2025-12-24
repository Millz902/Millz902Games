# Los Scotia Branding

A comprehensive branding resource for the Los Scotia FiveM server. This resource adds custom branding elements throughout the server interface.

## Features

- **Custom Watermark**: Shows server name and time in configurable corner
- **UI Integration**: Injects Los Scotia branding into QBCore menus
- **Loading Screen Customization**: Replaces loading screen text with Los Scotia branding
- **Welcome Message**: Displays a welcome message for new players
- **Pause Menu Branding**: Changes pause menu text to show Los Scotia branding
- **Discord Integration**: Adds Discord button and F9 hotkey

## Recent Server Fixes (October 2025)

### Resource Organization
- Fixed "Couldn't find resource" errors for ls-medical, ls-fire, ls-taxi, etc.
- Moved LS scripts from EDITS directory to standard [ls] directory structure
- Updated server.cfg to reference resources in the correct locations

### Discord Webhook Integration
- Fixed webhook-related errors with multi-layered approach:
  1. Ensured webhook_fix loads first in server.cfg
  2. Added multiple global function registration methods
  3. Created webhook_fallback.lua for resources that need it
  4. Added proper validation for webhook URLs
  5. Improved error handling for 401/400 errors

### Database Fixes
- Fixed qb-alcohol script error related to "attempt to index a function value"
- Updated MySQL variable to use :GetObject() method correctly

### Load Screen Improvements
- Fixed UnhandledPromiseRejectionWarning in Millz902Games Load-Screen
- Corrected oxmysql import and added proper error handling
- Created fallback for Discord token issues

### Smartphone Issues
- Created placeholder for deprecated "smartphone" resource
- Ensured compatibility with smartphone-pro

## Configuration

All branding options can be customized in the `client.lua` Config table:

```lua
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
```

## Commands

- `/watermark` - Toggle the server watermark on/off
- `/discord` - Open the Los Scotia Discord
- F9 key - Quick access to the Discord

## Installation

1. Place the resource in your server's resources directory
2. Add `ensure ls-branding` to your server.cfg
3. Update the branding configuration in client.lua to match your server's branding
4. Replace the placeholder logo images with your own custom logos

## Customization

### Logo Files

Replace the placeholder image files in the `html/img` directory with your own custom logos:

- `los-scotia-logo.png` - Main server logo
- `watermark-logo.png` - Small watermark logo

### Custom Font

Replace `html/fonts/los-scotia.ttf` with your preferred branding font.

## Credits

Created by Millz902Games for Los Scotia Roleplay Server