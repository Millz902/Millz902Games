-- Los Scotia Commands System - Safe Version
-- This file provides a safe command loading system with no QBCore.Commands.Add calls

print('[LS-COMMANDS] Los Scotia Commands system loaded safely (commands handled by init.lua)')

-- This file intentionally left mostly empty to prevent command conflicts  
-- All commands are now registered in init.lua within a CreateThread to ensure proper timing

-- Export placeholder functions for compatibility
exports('RegisterCommand', function() return false end)
exports('CommandExists', function() return false end) 
exports('GetAllCommands', function() return {} end)

print('[LS-COMMANDS] Safe command system initialized!')