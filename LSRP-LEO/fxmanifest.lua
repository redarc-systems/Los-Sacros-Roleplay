fx_version 'cerulean'
game 'gta5'


name 'leo_system'
author 'yourname'
version '1.0.0'
license 'MIT'
description 'Lightweight LEO system for FiveM using ox_lib + ox_target'


-- Dependencies
lua54 'yes'


shared_scripts {
'@ox_lib/init.lua',
'config.lua'
}


client_scripts {
'client/main.lua'
}


server_scripts {
'@oxmysql/lib/MySQL.lua', -- optional if you want later persistence; safe to leave even if unused
'server/main.lua'
}


files {
}


-- Ensure these are started before this resource in server.cfg:
-- ensure ox_lib
-- ensure ox_target
