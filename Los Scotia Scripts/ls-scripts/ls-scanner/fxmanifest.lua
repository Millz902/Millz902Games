fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development Team'
description 'Server resource scanner for Los Scotia FiveM server'
version '1.1.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'reports/*.html'
}

dependency 'qb-core'

lua54 'yes'