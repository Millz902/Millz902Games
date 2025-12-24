fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development Team'
description 'Los Scotia Core Framework'
version '1.0.0'

dependencies {
    'qb-core',
    'oxmysql'
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

provide 'ls-core'

lua54 'yes'