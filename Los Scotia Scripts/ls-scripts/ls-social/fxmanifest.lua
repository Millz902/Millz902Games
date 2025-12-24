fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development Team'
description 'Los Scotia Advanced Social Media System - Complete social platform with posts, followers, influencers, content creation, and viral trends'
version '2.4.0'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua'
}

client_scripts {
    'client/main.lua',
    'client/posts.lua',
    'client/followers.lua',
    'client/influencer.lua',
    'client/content.lua',
    'client/trends.lua',
    'client/stories.lua',
    'client/live.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/posts.lua',
    'server/followers.lua',
    'server/influencer.lua',
    'server/content.lua',
    'server/trends.lua',
    'server/stories.lua',
    'server/live.lua',
    'server/database.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/main.js',
    'ui/posts.js',
    'ui/followers.js',
    'ui/influencer.js',
    'ui/content.js',
    'ui/trends.js',
    'ui/stories.js',
    'ui/live.js',
    'ui/sounds/*.mp3',
    'ui/img/*.png',
    'ui/img/*.jpg',
    'ui/fonts/*.ttf'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-menu',
    'qb-phone',
    'oxmysql'
}

lua54 'yes'