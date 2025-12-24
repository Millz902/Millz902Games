fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development Team'
description 'Los Scotia Resource Verification System'
version '1.0.0'

-- Server scripts
server_scripts {
    'init.lua'
}

-- Exports
server_exports {
    'VerifyDependencies',
    'VerifyLSResources', 
    'CheckResource'
}

lua54 'yes'