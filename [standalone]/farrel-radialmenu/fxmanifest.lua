fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

shared_scripts {
    '@es_extended/imports.lua',
	'@es_extended/locale.lua',
    '@ox_lib/init.lua',
    'locales/en.lua',
    'config.lua',
}

client_scripts {
    'client/*.lua',
}

files {
    'html/index.html',
    'html/css/main.css',
    'html/js/main.js',
    'html/js/RadialMenu.js',
}

lua54 'yes'