Config = Config or {}

LS_LAWYERS = LS_LAWYERS or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	LawyerJobs = {'lawyer'},
	CourtScheduleDays = { 'Mon','Wed','Fri' }
}

Config.Lawyers = LS_LAWYERS
return LS_LAWYERS
