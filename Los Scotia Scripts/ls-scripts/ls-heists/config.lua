-- Los Scotia Heists Configuration
-- Expanded from placeholder so loader gets structured defaults

Config = Config or {}

LS_HEISTS = LS_HEISTS or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	Version = 1,
	Heists = {
		-- Example heist template (copy & customize)
		fleeca_small = {
			label = 'Fleeca (Small)',
			requiredPolice = 2,
			cooldown = 3600, -- seconds
			minReward = 15000,
			maxReward = 30000,
			itemsRequired = {'thermite','drill'},
			hacking = {time = 45, difficulty = 'easy'},
			vault = {object = 'v_ilev_gb_vauldr', coords = vector3(0.0,0.0,0.0)},
		}
	},
	GlobalCooldown = 300, -- seconds between any two heists starting
	LawDispatchWebhook = '',
	PayoutItem = 'markedbills'
}

-- Backwards compatibility: keep a simple Config alias pointing at LS_HEISTS
Config.Heists = LS_HEISTS

-- Export pattern (if other scripts expect global table only)
return LS_HEISTS
