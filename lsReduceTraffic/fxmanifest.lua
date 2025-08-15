fx_version 'cerulean'
game 'gta5'

name 'traffic_density'
description 'Reduce civilian traffic & ambient peds to improve performance'
author 'Los Sacros Development Team'
version '1.0.0'

-- Reads replicated convars from server.cfg (use `setr`)
client_scripts {
    'client.lua'
}
