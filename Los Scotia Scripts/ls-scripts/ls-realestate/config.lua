-- Los Scotia Real Estate Configuration

Config = Config or {}

LS_REALESTATE = LS_REALESTATE or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	CommissionPercent = 5,
	AllowAuctions = false,
	ListingFee = 500,
	MaxActiveListings = 25,
	Webhook = ''
}

Config.RealEstate = LS_REALESTATE
return LS_REALESTATE
