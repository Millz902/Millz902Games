-- Los Scotia Radio Configuration

Config = Config or {}

LS_RADIO = LS_RADIO or {
	Framework = 'QBCore',
	Debug = false,
	Locale = 'en',
	Enabled = false,
	MaxFrequencies = 200,
	RestrictedFrequencies = {1,2,911},
	RequireItem = 'radio',
	EncryptionItem = 'decrypter',
	AllowCrossDepartment = false
}

Config.Radio = LS_RADIO
return LS_RADIO
