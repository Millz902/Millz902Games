-- Los Scotia Rental Configuration

Config = Config or {}

LS_RENTAL = LS_RENTAL or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	MaxActiveRentals = 2,
	DamageDepositPercent = 25,
	AllowEarlyReturnRefund = true,
	Vehicles = {
		compact = {model='panto', pricePerMinute=25, deposit=500},
		sedan = {model='tailgater', pricePerMinute=40, deposit=750},
		suv = {model='baller2', pricePerMinute=55, deposit=900}
	}
}

Config.Rental = LS_RENTAL
return LS_RENTAL
