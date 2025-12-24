-- Los Scotia Advanced Racing Configuration

Config = Config or {}

LS_RACING_ADVANCED = LS_RACING_ADVANCED or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	EloEnabled = true,
	DefaultStake = 0,
	AntiCheatChecks = true,
	Elo = {
		Start = 1000,
		KFactor = 32
	},
	Seasons = {
		Active = false,
		CurrentSeason = 1,
		SeasonLengthDays = 30
	}
}

Config.RacingAdvanced = LS_RACING_ADVANCED
return LS_RACING_ADVANCED
