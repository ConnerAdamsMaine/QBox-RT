fx_version 'cerulean'
game 'gta5'

author 'Project Misfits'
description 'Texture reloader for FiveM with batching and render distance control'
version '1.0.0'

dependencies { 'qbx_core' }

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'deps/client.lua',
    'deps/lib.lua',
    'client/textures.lua',
    'client/events.lua'
}

server_scripts {
    'server/commands.lua'
}

ui_page 'deps/h.html'

files {
    'deps/h.html'
}

exports {
    'Start',
    'Stop',
    'SetRenderDistance',
    'SetBatchSize',
    'SetMaxConcurrent',
    'SetRequestDelay',
    'GetConfig',
    'GetSetting'
}

lua54 'yes'
