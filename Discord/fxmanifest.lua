fx_version 'cerulean'
game 'gta5'

name 'LSRP Migration System'
author 'Los Sacros Development Team'
description 'All-in-one Discord role tags + role-based vehicle menu'
version '1.1.0'

lua54 'yes'

shared_script 'config.lua'
server_script 'server.lua'
client_scripts {
  'client.lua',
  'client_menu.lua'
}

dependency 'chat' -- uses default chat resource events
