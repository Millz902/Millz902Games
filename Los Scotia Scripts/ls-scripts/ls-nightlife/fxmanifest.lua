fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development'
description 'Advanced Nightlife & Entertainment System for QBCore'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/clubs.lua',
    'client/bars.lua',
    'client/events.lua',
    'client/dj.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/clubs.lua',
    'server/bars.lua',
    'server/events.lua',
    'server/dj.lua',
    'server/database.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/main.js',
    'ui/style.css',
    'ui/sounds/*.mp3',
    'ui/music/*.mp3',
    'ui/assets/*.png',
    'ui/assets/*.jpg'
}

dependencies {
    'qb-core',
    'qb-target',
    'oxmysql'
}

lua54 'yes'