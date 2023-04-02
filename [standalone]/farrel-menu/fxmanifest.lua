fx_version 'cerulean'
game 'gta5'

description 'QB-RadialMenu'
version '1.2.0'

ui_page 'html/index.html'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    '@ox_lib/init.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}
files {
    'html/index.html',
    'html/css/main.css',
    'html/js/main.js',
    'html/js/RadialMenu.js',
}

lua54 'yes'
