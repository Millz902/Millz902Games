Config = Config or {}

LS_GOVERNMENT = LS_GOVERNMENT or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = true,  -- ENABLED FOR BASIC FUNCTIONALITY
	ElectionCycleDays = 14,
	MayorJob = 'mayor',
	GovernmentJobs = {'government','mayor'},
	TaxRates = { income = 0.05, sales = 0.03, luxury = 0.10 }
}

Config.Government = LS_GOVERNMENT
return LS_GOVERNMENT
