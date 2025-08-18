fx_version 'cerulean'
game 'gta5'

author 'Los Sacros Development Team'
name 'Boot Script'
description 'Standalone boot (trunk) loadouts per boot type, mapped to spawn codes. ox_target + ox_lib.'
version '1.1.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_target',
    'ox_lib'
}
