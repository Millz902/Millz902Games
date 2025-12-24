-- Los Scotia Weather Configuration

Config = Config or {}

LS_WEATHER = LS_WEATHER or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	CycleIntervalMinutes = 30,
	AllowedWeathers = { 'EXTRASUNNY','CLEAR','CLOUDS','OVERCAST','RAIN' },
	EnableStorms = false,
	StormChancePercent = 5,
	SyncIntervalSeconds = 120,
	TransitionTimeSeconds = 25
}

Config.Weather = LS_WEATHER
return LS_WEATHER
