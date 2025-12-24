fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development Team'
description 'Los Scotia Dealership System'
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
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

lua54 'yes'