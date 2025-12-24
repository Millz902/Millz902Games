fx_version 'cerulean'
game 'gta5'

description 'Los Scotia Enhanced Police System'
version '1.0.0'
author 'Los Scotia Development'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'ls-police'
}