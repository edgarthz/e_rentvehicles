fx_version 'adamant'
game 'gta5'

description 'Vehicle Rental System – NPC + NUI'
author 'edgarthz'
version '1.0.0'

lua54 'yes'

shared_script '@es_extended/imports.lua'

client_scripts {
    'locales/*.lua',
    'config.lua',
    'client/main.lua'
}

server_scripts {
    'locales/*.lua',
    'config.lua',
    'server/main.lua'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/css/app.css',
    'html/js/app.js',
    'html/img/*.*'
}