fx_version 'adamant'

game 'gta5'

client_scripts {
	'menu/dependencies/menu.lua',
	'cl_menu.lua',
	'coffre/client.lua',
	'@es_extended/locale.lua',
}

server_scripts {
    'menu/sv_deco.lua',
	'coffre/server.lua',
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua'
}

server_script 	'@mysql-async/lib/MySQL.lua' 


