-- Los Scotia Towing Configuration

Config = Config or {}

LS_TOWING = LS_TOWING or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	ImpoundFee = 500,
	TowTruckModels = { 'flatbed', 'towtruck' },
	MaxDistanceAttach = 8.0,
	ImpoundLocations = {
		{ name = 'City Impound', coords = vector3(408.61, -1625.87, 29.29) }
	}
}

Config.Towing = LS_TOWING
return LS_TOWING
