fx_version 'cerulean'
game 'gta5'

description 'vSyncRevamped'
version '2.1.0'

shared_scripts {
    'config.lua',
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
	'locales/*.lua',
}

server_script 'server/server.lua'
client_script 'client/client.lua'

lua54 'yes'
