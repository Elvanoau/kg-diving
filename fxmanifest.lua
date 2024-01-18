fx_version 'cerulean'
game 'gta5'
author '_elvano'
lua54 'yes'

shared_script {
    "config.lua"
}

client_scripts {
    "client.lua",
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
}

server_script {
    "server.lua"
}

escrow_ignore {
    'config.lua',
    'client.lua',
    'server.lua',
}