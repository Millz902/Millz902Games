fx_version 'cerulean'
game 'gta5'

name 'ls-musicplayer'
description 'Music Player for Character Creation'
author 'Millz902Games'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png',
    'sounds/*.mp3'
}

client_scripts {
    'client/main.lua',
    'client/integration.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'qb-multicharacter',
    'illenium-appearance'
}