Config = {}

Config.Debug = false
Config.Framework = 'qb-core'  -- The framework being used (qb-core)

-- Server Settings
Config.ServerName = GetConvar('ls_server_name', 'Los Scotia 902')
Config.EnableLogging = GetConvarInt('ls_enable_logging', 1) == 1
Config.DebugMode = GetConvarInt('ls_debug_mode', 0) == 1

-- Economy Settings
Config.StartingMoney = GetConvarInt('ls_starting_money', 5000)
Config.MaxFineAmount = GetConvarInt('ls_max_fine_amount', 50000)
Config.HeistCooldown = GetConvarInt('ls_heist_cooldown', 3600)
Config.GymMembershipDuration = GetConvarInt('ls_gym_membership_duration', 30)

-- Police Settings
Config.MaxJailTime = GetConvarInt('ls_max_jail_time', 120)
Config.BackupTimeout = GetConvarInt('ls_backup_timeout', 300)
Config.EvidenceTimeout = GetConvarInt('ls_evidence_timeout', 600)

-- Medical Settings
Config.ReviveTime = GetConvarInt('ls_revive_time', 30)
Config.HospitalBeds = GetConvarInt('ls_hospital_beds', 20)

-- Business Settings
Config.BusinessTaxRate = GetConvarInt('ls_business_tax_rate', 5) / 100
Config.MaxBusinessesPerPlayer = GetConvarInt('ls_max_businesses_per_player', 3)