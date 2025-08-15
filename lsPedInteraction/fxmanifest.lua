fx_version 'cerulean'
game 'gta5'

name 'rcuffs'
description 'Standalone cuff/uncuff + escort with target integration'
author 'Los Sacros Development Team'
version '1.1.0'
lua54 'yes'

-- Optional but recommended: ox_lib for context menus
shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

-- Stream your custom cuff model(s) here
files {
    'stream/*'
}

-- Optional: if you use interact-sound for SFX, keep that resource enabled in server.cfg
-- dependency 'ox_target' -- if you use ox_target
