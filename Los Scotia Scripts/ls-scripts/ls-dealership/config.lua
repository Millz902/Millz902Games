Config = Config or {}

LS_DEALERSHIP = LS_DEALERSHIP or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	CommissionPercent = 10,
	TestDriveMinutes = 5,
	StockRefreshHours = 24
}

Config.Dealership = LS_DEALERSHIP
return LS_DEALERSHIP
