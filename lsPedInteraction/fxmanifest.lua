fx_version 'cerulean'
game 'gta5'

name 'rcuffs'
description 'Cuff/uncuff and escort players with ox_target (or any target via exports)'
author 'Los Sacros Development Team'
version '1.0.0'

lua54 'yes'

-- Dependencies (recommended)
-- ox_target for the interaction wheel/eye
dependency 'ox_target'

-- If you want the optional cuff SFX via InteractSound, keep that resource running.
-- dependency 'interact-sound'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- not required; remove if not using DB anywhere else
    'server/server.lua'
}

-- Stream your custom cuff model here (any name). ydd/ydr/ytd supported.
files {
    'stream/*'
}
