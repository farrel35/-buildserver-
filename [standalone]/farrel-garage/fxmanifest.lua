fx_version 'adamant'

lua54 'yes'
game 'gta5'

shared_scripts { 
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'@ox_lib/init.lua',
	'locales/*.lua',
	'config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}

dependencies {
	'es_extended',
	'esx_property'
}
