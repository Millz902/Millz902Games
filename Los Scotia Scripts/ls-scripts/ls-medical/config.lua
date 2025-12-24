Config = Config or {}

LS_MEDICAL = LS_MEDICAL or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	ReviveTimeSeconds = 8,
	HealItem = 'bandage',
	AmbulanceJobs = {'ambulance','ems'},
	MaxInjurySeverity = 5
}

Config.Medical = LS_MEDICAL
return LS_MEDICAL
