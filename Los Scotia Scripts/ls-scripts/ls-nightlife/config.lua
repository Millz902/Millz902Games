Config = {}

-- Club Locations & Settings
Config.Clubs = {
    ["vanilla_unicorn"] = {
        name = "Vanilla Unicorn",
        coords = vector3(129.97, -1299.30, 29.23),
        heading = 0.0,
        type = "strip_club",
        owner = nil,
        purchase_price = 2500000,
        daily_upkeep = 2500,
        max_capacity = 150,
        vip_rooms = 5,
        dj_booth = vector3(120.50, -1281.90, 29.48),
        bar_locations = {
            vector3(129.30, -1284.25, 29.27),
            vector3(132.65, -1286.12, 29.27)
        },
        stage_locations = {
            vector3(104.75, -1294.33, 29.26),
            vector3(127.50, -1307.50, 29.26)
        },
        vip_room_coords = {
            vector3(113.73, -1297.68, 34.27),
            vector3(118.73, -1299.68, 34.27),
            vector3(123.73, -1301.68, 34.27),
            vector3(128.73, -1303.68, 34.27),
            vector3(133.73, -1305.68, 34.27)
        },
        music_zones = {
            {coords = vector3(120.0, -1290.0, 29.3), range = 50.0, volume = 0.3},
            {coords = vector3(104.0, -1294.0, 29.3), range = 30.0, volume = 0.4}
        },
        security_positions = {
            vector3(132.40, -1293.04, 29.27),
            vector3(96.20, -1284.84, 29.27),
            vector3(127.50, -1280.50, 29.27)
        },
        dress_code = "formal_casual",
        age_restriction = 18,
        entry_fee = 100,
        vip_entry_fee = 500
    },
    ["bahama_mamas"] = {
        name = "Bahama Mamas",
        coords = vector3(-1388.58, -618.42, 30.82),
        heading = 0.0,
        type = "nightclub",
        owner = nil,
        purchase_price = 3500000,
        daily_upkeep = 3000,
        max_capacity = 200,
        vip_rooms = 3,
        dj_booth = vector3(-1381.50, -614.25, 30.82),
        bar_locations = {
            vector3(-1391.20, -606.35, 30.32),
            vector3(-1385.75, -627.80, 30.32)
        },
        dance_floor = vector3(-1387.50, -617.25, 30.32),
        vip_room_coords = {
            vector3(-1377.20, -628.45, 35.02),
            vector3(-1374.80, -624.15, 35.02),
            vector3(-1372.40, -619.85, 35.02)
        },
        music_zones = {
            {coords = vector3(-1387.5, -617.3, 30.8), range = 60.0, volume = 0.4}
        },
        security_positions = {
            vector3(-1393.85, -596.42, 30.32),
            vector3(-1382.20, -599.85, 30.32)
        },
        dress_code = "trendy",
        age_restriction = 21,
        entry_fee = 200,
        vip_entry_fee = 750
    },
    ["eclipse_towers_penthouse"] = {
        name = "Eclipse Towers Sky Lounge",
        coords = vector3(-784.78, 323.44, 187.31),
        heading = 0.0,
        type = "luxury_lounge",
        owner = nil,
        purchase_price = 5000000,
        daily_upkeep = 5000,
        max_capacity = 80,
        vip_rooms = 2,
        bar_locations = {
            vector3(-789.25, 330.15, 187.31)
        },
        private_areas = {
            vector3(-796.50, 335.25, 187.31),
            vector3(-773.25, 315.80, 187.31)
        },
        dress_code = "formal",
        age_restriction = 25,
        entry_fee = 500,
        membership_required = true
    }
}

-- Bar Locations & Settings
Config.Bars = {
    ["yellow_jack"] = {
        name = "Yellow Jack Inn",
        coords = vector3(1986.33, 3054.77, 47.22),
        heading = 0.0,
        type = "sports_bar",
        owner = nil,
        purchase_price = 1500000,
        daily_upkeep = 1500,
        max_capacity = 100,
        bar_locations = {
            vector3(1982.23, 3051.12, 47.22)
        },
        pool_tables = {
            vector3(1990.25, 3049.85, 47.22),
            vector3(1987.75, 3045.25, 47.22)
        },
        dart_boards = {
            vector3(1979.50, 3048.25, 47.22)
        },
        karaoke_stage = vector3(1995.25, 3055.80, 47.22),
        age_restriction = 18,
        dress_code = "casual"
    },
    ["tequilala"] = {
        name = "Tequi-la-la",
        coords = vector3(-562.84, 286.88, 82.18),
        heading = 0.0,
        type = "cocktail_bar",
        owner = nil,
        purchase_price = 2000000,
        daily_upkeep = 2000,
        max_capacity = 120,
        bar_locations = {
            vector3(-561.25, 289.50, 82.18),
            vector3(-565.80, 278.25, 82.18)
        },
        dj_booth = vector3(-552.25, 284.15, 82.97),
        dance_floor = vector3(-556.25, 281.50, 82.18),
        vip_area = vector3(-549.85, 278.45, 87.38),
        age_restriction = 21,
        dress_code = "smart_casual",
        entry_fee = 50
    }
}

-- Event System
Config.Events = {
    event_types = {
        dj_night = {
            name = "DJ Night",
            duration = 180, -- minutes
            min_attendees = 20,
            max_attendees = 200,
            base_cost = 5000,
            revenue_share = 0.70, -- 70% to venue, 30% to DJ
            music_genres = {"house", "techno", "hip_hop", "pop", "electronic"}
        },
        live_music = {
            name = "Live Music Performance",
            duration = 120,
            min_attendees = 15,
            max_attendees = 150,
            base_cost = 3000,
            revenue_share = 0.60,
            performance_types = {"band", "solo_artist", "acoustic", "karaoke_night"}
        },
        themed_night = {
            name = "Themed Party Night",
            duration = 240,
            min_attendees = 30,
            max_attendees = 300,
            base_cost = 8000,
            revenue_share = 0.80,
            themes = {
                "80s_retro", "masquerade", "neon_party", "formal_gala",
                "beach_party", "halloween", "new_years", "valentines"
            }
        },
        private_party = {
            name = "Private Party",
            duration = 180,
            min_attendees = 10,
            max_attendees = 100,
            base_cost = 2000,
            revenue_share = 1.0,
            customizable = true
        },
        celebrity_appearance = {
            name = "Celebrity Appearance",
            duration = 120,
            min_attendees = 50,
            max_attendees = 500,
            base_cost = 25000,
            revenue_share = 0.50,
            booking_fee = 50000
        }
    },
    booking_system = {
        advance_booking_days = 14,
        cancellation_deadline = 48, -- hours
        deposit_percentage = 0.25,
        refund_policy = {
            full_refund = 72, -- hours before event
            partial_refund = 24, -- 50% refund
            no_refund = 12 -- no refund within 12 hours
        }
    },
    promotion_system = {
        social_media_boost = {
            cost = 500,
            attendance_increase = 0.15
        },
        radio_advertisement = {
            cost = 1000,
            attendance_increase = 0.25
        },
        flyer_distribution = {
            cost = 250,
            attendance_increase = 0.10
        },
        vip_invitations = {
            cost = 1500,
            vip_attendance_increase = 0.30
        }
    }
}

-- DJ System
Config.DJ = {
    equipment = {
        basic_setup = {
            name = "Basic DJ Setup",
            cost = 15000,
            quality_bonus = 1.0,
            range = 30.0,
            max_volume = 0.3
        },
        professional_setup = {
            name = "Professional DJ Setup",
            cost = 50000,
            quality_bonus = 1.5,
            range = 50.0,
            max_volume = 0.5
        },
        premium_setup = {
            name = "Premium DJ Setup",
            cost = 100000,
            quality_bonus = 2.0,
            range = 75.0,
            max_volume = 0.7
        },
        state_of_art = {
            name = "State-of-the-Art Setup",
            cost = 250000,
            quality_bonus = 3.0,
            range = 100.0,
            max_volume = 1.0
        }
    },
    music_library = {
        house = {
            "Deep House Mix", "Progressive House", "Tech House", "Future House",
            "Tropical House", "Electro House", "Bass House", "Melodic House"
        },
        techno = {
            "Underground Techno", "Industrial Techno", "Minimal Techno", "Hard Techno",
            "Detroit Techno", "Berlin Techno", "Acid Techno", "Melodic Techno"
        },
        hip_hop = {
            "Old School Hip Hop", "Trap Beats", "Boom Bap", "Conscious Rap",
            "Gangsta Rap", "Party Hip Hop", "Underground Hip Hop", "Mainstream Hits"
        },
        pop = {
            "Top 40 Hits", "Pop Remixes", "Dance Pop", "Indie Pop",
            "Retro Pop", "Electronic Pop", "Commercial Pop", "Underground Pop"
        },
        electronic = {
            "EDM Bangers", "Dubstep", "Drum & Bass", "Trance",
            "Ambient Electronic", "Synthwave", "Hardstyle", "Future Bass"
        }
    },
    dj_skills = {
        mixing = {
            levels = 10,
            experience_per_hour = 25,
            bonus_effects = "smoother_transitions"
        },
        reading_crowd = {
            levels = 10,
            experience_per_hour = 15,
            bonus_effects = "better_song_selection"
        },
        equipment_mastery = {
            levels = 10,
            experience_per_hour = 10,
            bonus_effects = "enhanced_sound_quality"
        },
        showmanship = {
            levels = 10,
            experience_per_hour = 20,
            bonus_effects = "increased_crowd_engagement"
        }
    },
    performance_metrics = {
        crowd_energy = {
            factors = {"song_choice", "mixing_quality", "timing", "crowd_reading"},
            max_energy = 100,
            energy_decay_rate = 2 -- per minute without good music
        },
        tip_system = {
            base_tip_range = {50, 500},
            performance_multiplier = {0.5, 3.0},
            crowd_size_bonus = true,
            vip_tip_bonus = 2.0
        }
    }
}

-- Entertainment Activities
Config.Activities = {
    pool_tables = {
        game_types = {"8_ball", "9_ball", "straight_pool"},
        game_duration = 15, -- minutes
        cost_per_game = 50,
        betting_allowed = true,
        max_bet = 5000,
        skill_system = {
            levels = 10,
            experience_per_game = 10,
            accuracy_bonus = true
        }
    },
    dart_boards = {
        game_types = {"501", "301", "cricket", "around_the_clock"},
        game_duration = 10,
        cost_per_game = 25,
        betting_allowed = true,
        max_bet = 2500,
        tournaments = {
            daily = true,
            weekly = true,
            entry_fee = 100,
            prize_pool_multiplier = 0.80
        }
    },
    karaoke = {
        song_library = {
            "classic_rock", "pop_hits", "country", "hip_hop",
            "r_and_b", "international", "duets", "party_songs"
        },
        performance_scoring = true,
        audience_reactions = true,
        recording_system = true,
        competitions = {
            weekly_contests = true,
            prize_money = 1000,
            audience_voting = true
        }
    },
    dance_competitions = {
        dance_styles = {"freestyle", "breakdance", "salsa", "hip_hop", "ballroom"},
        judging_criteria = {"technique", "creativity", "crowd_appeal", "timing"},
        entry_fee = 200,
        prize_tiers = {
            first_place = 2000,
            second_place = 1000,
            third_place = 500
        }
    }
}

-- VIP System
Config.VIP = {
    membership_tiers = {
        bronze = {
            name = "Bronze VIP",
            monthly_cost = 500,
            benefits = {
                "skip_entry_lines",
                "10_percent_drink_discount",
                "event_notifications"
            },
            club_access = "basic"
        },
        silver = {
            name = "Silver VIP",
            monthly_cost = 1500,
            benefits = {
                "skip_entry_lines",
                "20_percent_drink_discount",
                "priority_reservations",
                "exclusive_events",
                "complimentary_coat_check"
            },
            club_access = "premium"
        },
        gold = {
            name = "Gold VIP",
            monthly_cost = 3000,
            benefits = {
                "skip_entry_lines",
                "30_percent_drink_discount",
                "private_table_reservations",
                "exclusive_events",
                "complimentary_services",
                "guest_privileges",
                "personal_concierge"
            },
            club_access = "luxury"
        },
        platinum = {
            name = "Platinum VIP",
            monthly_cost = 7500,
            benefits = {
                "unlimited_club_access",
                "50_percent_drink_discount",
                "private_room_access",
                "exclusive_events",
                "complimentary_everything",
                "unlimited_guests",
                "24_7_concierge",
                "helicopter_transport"
            },
            club_access = "elite"
        }
    },
    room_reservations = {
        vip_table = {
            hourly_rate = 500,
            capacity = 8,
            includes = {"bottle_service", "personal_server", "priority_ordering"}
        },
        private_booth = {
            hourly_rate = 750,
            capacity = 6,
            includes = {"privacy_screens", "premium_sound", "dedicated_server"}
        },
        exclusive_room = {
            hourly_rate = 1500,
            capacity = 15,
            includes = {"private_bar", "personal_dj", "security", "catering"}
        }
    }
}

-- Staff Management
Config.Staff = {
    positions = {
        owner = {
            salary = 0, -- Revenue based
            permissions = {"all"},
            max_positions = 1
        },
        manager = {
            salary = 8000,
            permissions = {"staff_management", "inventory", "events", "finances"},
            max_positions = 2
        },
        head_bartender = {
            salary = 5000,
            permissions = {"bar_management", "inventory", "staff_training"},
            max_positions = 1
        },
        bartender = {
            salary = 3500,
            permissions = {"serve_drinks", "handle_payments"},
            max_positions = 6,
            tips_enabled = true
        },
        security = {
            salary = 4000,
            permissions = {"crowd_control", "check_ids", "handle_incidents"},
            max_positions = 8,
            equipment = {"radio", "restraints", "flashlight"}
        },
        dj = {
            salary = 2500,
            permissions = {"music_control", "crowd_interaction"},
            max_positions = 4,
            performance_bonuses = true
        },
        server = {
            salary = 2000,
            permissions = {"table_service", "vip_service"},
            max_positions = 10,
            tips_enabled = true
        },
        host = {
            salary = 2500,
            permissions = {"guest_relations", "reservations", "entry_management"},
            max_positions = 4
        },
        cleaner = {
            salary = 1500,
            permissions = {"maintenance", "cleaning"},
            max_positions = 3,
            shift_based = true
        }
    },
    shift_system = {
    day_shift = {start_hour = 6, end_hour = 18}, -- 6 AM to 6 PM
    night_shift = {start_hour = 18, end_hour = 6}, -- 6 PM to 6 AM
        overtime_rate = 1.5,
        break_duration = 30, -- minutes
        max_hours_per_shift = 12
    }
}

-- Economy & Pricing
Config.Economy = {
    drink_prices = {
        beer = {base_price = 15, markup = 3.0},
        wine = {base_price = 25, markup = 2.5},
        cocktails = {base_price = 30, markup = 4.0},
        shots = {base_price = 20, markup = 3.5},
        premium_spirits = {base_price = 50, markup = 5.0},
        non_alcoholic = {base_price = 10, markup = 2.0},
        bottle_service = {base_price = 500, markup = 6.0}
    },
    operational_costs = {
        electricity = 500, -- daily
        security = 1000,
        cleaning = 300,
        insurance = 800,
        licensing = 200,
        maintenance = 400,
        staff_bonuses = 1500
    },
    revenue_streams = {
        entry_fees = 0.15,
        drink_sales = 0.60,
        vip_services = 0.15,
        events = 0.08,
        merchandise = 0.02
    },
    dynamic_pricing = {
        peak_hours = {19, 2}, -- 7 PM to 2 AM
        peak_multiplier = 1.5,
        special_events_multiplier = 2.0,
        happy_hour = {17, 19}, -- 5 PM to 7 PM
        happy_hour_discount = 0.25
    }
}

-- Security & Safety
Config.Security = {
    age_verification = {
        required = true,
        fake_id_detection = true,
        database_checks = true
    },
    capacity_management = {
        fire_code_compliance = true,
        overcrowding_prevention = true,
        emergency_exits = true
    },
    incident_reporting = {
        fight_protocols = true,
        medical_emergencies = true,
        theft_reports = true,
        police_integration = true
    },
    surveillance = {
        camera_coverage = 95, -- percentage
        recording_retention = 30, -- days
        live_monitoring = true,
        facial_recognition = false -- privacy compliance
    }
}

-- Integration Settings
Config.Integration = {
    phone_apps = {
        event_calendar = true,
        reservation_system = true,
        drink_ordering = true,
        social_features = true
    },
    radio_stations = {
        promotional_spots = true,
        event_announcements = true,
        dj_shoutouts = true
    },
    social_media = {
        auto_posting = true,
        check_in_bonuses = true,
        photo_contests = true,
        influencer_partnerships = true
    }
}

-- Placeholder for future private services system
Config.PrivateServices = Config.PrivateServices or {
    enabled = false,
    description = "Reserved for future expansion of private concierge services"
}

LS_NIGHTLIFE = LS_NIGHTLIFE or {}
LS_NIGHTLIFE.Clubs = Config.Clubs
LS_NIGHTLIFE.Bars = Config.Bars
LS_NIGHTLIFE.Events = Config.Events
LS_NIGHTLIFE.DJ = Config.DJ
LS_NIGHTLIFE.Activities = Config.Activities
LS_NIGHTLIFE.VIP = Config.VIP
LS_NIGHTLIFE.PrivateServices = Config.PrivateServices
LS_NIGHTLIFE.Staff = Config.Staff
LS_NIGHTLIFE.Economy = Config.Economy
LS_NIGHTLIFE.Security = Config.Security
LS_NIGHTLIFE.Integration = Config.Integration
return LS_NIGHTLIFE