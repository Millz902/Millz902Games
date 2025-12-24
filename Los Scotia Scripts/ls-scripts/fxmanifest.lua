fx_version 'cerulean'
game 'gta5'

author 'Los Scotia Development Team'
description 'Los Scotia Scripts - Master Command and Permission System'
version '1.0.0'

-- Dependencies
dependencies {
    'qb-core',
    'oxmysql',
    'qb-target',
    'qb-inventory',
    'qb-menu'
}

-- Shared scripts
shared_scripts {
    '@qb-core/shared/locale.lua',
    'shared/config-fix.lua',       -- Load config validation FIRST
    'init.lua',                    -- Main initialization
    'config/*.lua',                -- Load all configs (currently placeholder directory)
    'shared/ls-utils.lua'          -- Aggregated LS namespace & helpers
}

-- Client scripts
client_scripts {
    'client/*.lua'         -- Load all client scripts
}

-- Server scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'utils/mysql-fix.lua',         -- Load MySQL compatibility FIRST
    'utils/qb-alcohol-mysql-fix.lua', -- QB Alcohol MySQL compatibility
    'server/*.lua',                -- Load all server scripts  
    'ls-*/server/*.lua'            -- Load all ls-scripts server files
}

-- Exports
server_exports {
    'GetInitializedScripts',
    'RestartScript', 
    'CheckScriptHealth',
    'GetLSScripts',
    'IsScriptLoaded',
    'GetLSNamespace'
}

-- Provide these to ensure compatibility
provide 'ls-scripts'

lua54 'yes'