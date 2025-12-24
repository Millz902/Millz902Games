fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development Team'
description 'Los Scotia Advanced Farming & Agriculture System'
version '1.0.0'

dependencies {
    'qb-core',
    'oxmysql',
    'qb-target'
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
    -- Additional client files not yet implemented:
    -- 'client/farming.lua',
    -- 'client/livestock.lua', 
    -- 'client/processing.lua',
    -- 'client/market.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
    -- Additional server files not yet implemented:
    -- 'server/farming.lua',
    -- 'server/livestock.lua',
    -- 'server/processing.lua', 
    -- 'server/market.lua',
    -- 'server/database.lua'
}

-- UI not yet implemented
-- ui_page 'ui/index.html'

-- files {
--     'ui/index.html',
--     'ui/main.js',
--     'ui/style.css',
--     'ui/assets/*.png',
--     'ui/assets/*.jpg',
--     'ui/sounds/*.mp3'
-- }

lua54 'yes'