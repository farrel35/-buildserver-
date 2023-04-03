fx_version 'cerulean'
game 'gta5'

ui_page "nui/index.html"

shared_scripts {
    '@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'@ox_lib/init.lua',
	'locales/*.lua',
    'shared/sh_config.lua'
}

client_scripts {
    'client/**/cl_*.lua',
    'shared/sh_actions.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/sv_*.lua',
}

files {
    "nui/index.html",
    "nui/js/**.js",
    "nui/css/**.css",
    "nui/webfonts/*.css",
    "nui/webfonts/*.otf",
    "nui/webfonts/*.ttf",
    "nui/webfonts/*.woff2",
}

exports {
    'CreateLog'
}

server_exports {
    'CreateLog'
} 

lua54 'yes'