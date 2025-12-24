Config = Config or {}

LS_INSURANCE = LS_INSURANCE or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	DefaultPremiumPercent = 4,
	ClaimCooldownMinutes = 60
}

Config.Insurance = LS_INSURANCE
return LS_INSURANCE
