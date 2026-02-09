fx_version 'cerulean'
game 'gta5'

author 'Project Misfits'
description 'Texture reloader for FiveM with batching and render distance control'
version '1.0.0'

dependencies { 'qbx_core' }

client_scripts {
    'client/textures.lua',
    'client/events.lua'
}

server_scripts {
    'server/commands.lua'
}

lua54 'yes'
