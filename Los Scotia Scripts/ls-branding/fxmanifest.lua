fx_version 'cerulean'
game 'gta5'

name 'ls-branding'
description 'Server Branding Enhancements for Los Scotia'
author 'Millz902Games'
version '1.0.0'

-- UI files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png',
    'html/fonts/*.ttf'
}

-- Replace Rockstar logos with Millz902Games
replace_level_meta 'meta/gta5'

-- Stream custom assets
data_file 'SCALEFORM_DLC_FILE' 'stream/pausemenu.gfx'
data_file 'SCALEFORM_DLC_FILE' 'stream/pausemenumap.gfx'
data_file 'SCALEFORM_DLC_FILE' 'stream/frontend.gfx'
data_file 'SCALEFORM_DLC_FILE' 'stream/mpentry.gfx'

client_scripts {
    'client.lua',
    'loadingscreen.lua'
}