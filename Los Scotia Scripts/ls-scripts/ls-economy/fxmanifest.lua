fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development Team'
description 'Los Scotia Advanced Economy & Business System'
version '1.0.0'

dependencies {
    'qb-core',
    'oxmysql',
    'qb-target',
    'qb-menu'
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/stock_market.lua',
    'client/business.lua',
    'client/supply_chain.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/stock_market.lua',
    'server/business_management.lua',
    'server/economic_simulation.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

lua54 'yes'