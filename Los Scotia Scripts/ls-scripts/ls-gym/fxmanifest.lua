fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development'
description 'Advanced Fitness & Gym System for QBCore'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/workouts.lua',
    'client/training.lua',
    'client/competitions.lua',
    'client/nutrition.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/workouts.lua',
    'server/training.lua',
    'server/competitions.lua',
    'server/nutrition.lua',
    'server/database.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/main.js',
    'ui/style.css',
    'ui/assets/*.png',
    'ui/assets/*.jpg',
    'ui/sounds/*.mp3'
}

dependencies {
    'qb-core',
    'qb-target',
    'oxmysql'
}

lua54 'yes'