fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development Team'
description 'Los Scotia Gang Management System'
version '1.0.0'

dependencies {
    'qb-core',
    'oxmysql',
    'qb-target'
}

ui_page 'html/index.html'

shared_scripts {
    'shared/config.lua',
    'locales/en.lua'
}

client_scripts {
    'client/main.lua',
    'client/events.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/events.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}