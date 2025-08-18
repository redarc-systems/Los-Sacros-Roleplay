fx_version 'cerulean'
game 'gta5'

author 'Los Sacros Development Team'
name 'bodycam'
description 'Standalone bodycam overlay with beep + top-right UI (NUI)'
version '1.0.0'
lua54 'yes'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/sounds/*.ogg',
    'html/sounds/*.mp3',
    'html/sounds/*.wav'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}
