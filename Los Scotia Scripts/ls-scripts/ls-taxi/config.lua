-- Los Scotia Taxi Configuration

Config = Config or {}

LS_TAXI = LS_TAXI or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	BaseFare = 50,
	PerMeter = 0.4,
	EnableNPCJobs = true,
	NPCJobLocations = {
		vector3(215.8, -810.2, 30.7),
		vector3(-160.5, -604.6, 32.4),
		vector3(-660.7, -1138.4, 14.6)
	},
	VehicleModels = { 'taxi' },
	MeterUpdateIntervalMs = 2000
}

Config.Taxi = LS_TAXI
return LS_TAXI
