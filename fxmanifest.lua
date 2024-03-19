fx_version 'cerulean'

Description 'nw-license created by nw, contact him via discord: nowiex'

author 'nw | nowiex'

name 'nw-license'

game 'gta5'

dependency {
	'oxmysql',
	'ox_inventory',
	'es_extended'
}

shared_script {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'config.lua',
}

client_script {
	'scripts/client.lua',
}

server_script { 
	'@oxmysql/lib/MySQL.lua',
	'scripts/server.lua'
}

lua54 'yes'