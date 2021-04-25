fx_version 'bodacious'
games { 'gta5' }

author 'Mr Cloud'
description 'This script provides a Panic Button for customisable jobs (ESX requiered)'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua',
    '@mysql-async/lib/MySQL.lua'
}

files {
    'html/index.html',
    'html/listener.js',
    "html/audio/*.ogg",
    "html/audio/*.wav",
    "html/audio/streets/*.wav"
}

shared_script 'config.lua'
