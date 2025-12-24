Config = Config or {}

LS_VERIFY = LS_VERIFY or {
    Framework = 'QBCore',
    Debug = false,
    Locale = 'en',
    Enabled = false,
    VerificationItem = 'id_card'
}

Config.Verify = LS_VERIFY
return LS_VERIFY