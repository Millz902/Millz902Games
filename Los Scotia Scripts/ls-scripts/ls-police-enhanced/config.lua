Config = {}

-- Evidence Collection System
Config.Evidence = {
    types = {
        ["fingerprints"] = {
            name = "Fingerprints",
            collection_time = 15,
            required_item = "evidence_kit",
            degradation_time = 1800, -- 30 minutes
            match_accuracy = 0.95
        },
        ["dna"] = {
            name = "DNA Sample",
            collection_time = 30,
            required_item = "dna_kit",
            degradation_time = 3600, -- 1 hour
            match_accuracy = 0.99
        },
        ["ballistics"] = {
            name = "Ballistic Evidence",
            collection_time = 45,
            required_item = "ballistics_kit",
            degradation_time = 7200, -- 2 hours
            match_accuracy = 0.90
        },
        ["tire_tracks"] = {
            name = "Tire Tracks",
            collection_time = 60,
            required_item = "casting_kit",
            degradation_time = 900, -- 15 minutes
            match_accuracy = 0.80
        },
        ["footprints"] = {
            name = "Footprints", 
            collection_time = 45,
            required_item = "casting_kit",
            degradation_time = 600, -- 10 minutes
            match_accuracy = 0.75
        },
        ["security_footage"] = {
            name = "Security Footage",
            collection_time = 120,
            required_item = "data_extractor",
            degradation_time = 0, -- No degradation
            match_accuracy = 0.85
        }
    },
    processing_lab = vector3(478.2, -988.6, 30.7),
    analysis_time = {
        fingerprints = 300,
        dna = 600,
        ballistics = 900,
        tire_tracks = 240,
        footprints = 180,
        security_footage = 480
    }
}

-- Case Management System
Config.CaseManagement = {
    case_types = {
        "theft", "assault", "murder", "drug_trafficking", "fraud",
        "vandalism", "robbery", "kidnapping", "domestic_violence", "cybercrime"
    },
    case_statuses = {
        "open", "under_investigation", "pending_trial", "closed", "cold_case"
    },
    evidence_categories = {
        "physical", "digital", "witness_testimony", "surveillance", "forensic"
    },
    case_priorities = {
        {level = "low", description = "Minor crimes", response_time = 1800},
        {level = "medium", description = "Moderate crimes", response_time = 900},
        {level = "high", description = "Serious crimes", response_time = 300},
        {level = "critical", description = "Life-threatening situations", response_time = 120}
    }
}

-- Undercover Operations
Config.UndercoverOps = {
    enabled = true,
    identities = {
        {
            name = "Street Criminal",
            outfit = "gang_clothes",
            vehicle = "sultan",
            backstory = "Small-time drug dealer from Grove Street",
            skills = {"street_knowledge", "drug_contacts"}
        },
        {
            name = "Business Executive", 
            outfit = "business_suit",
            vehicle = "cognoscenti",
            backstory = "Corporate executive for money laundering investigation",
            skills = {"financial_knowledge", "corporate_contacts"}
        },
        {
            name = "Nightclub Patron",
            outfit = "casual_club",
            vehicle = "zentorno",
            backstory = "Wealthy club-goer for drug trafficking investigation",
            skills = {"party_scene_knowledge", "drug_suppliers"}
        }
    },
    surveillance_equipment = {
        "hidden_camera", "wire_tap", "gps_tracker", "listening_device", "night_vision"
    },
    operations = {
        drug_bust = {
            duration = 7200, -- 2 hours
            required_rank = "detective",
            success_rate = 0.7,
            reward_multiplier = 2.0
        },
        money_laundering = {
            duration = 14400, -- 4 hours
            required_rank = "sergeant",
            success_rate = 0.6,
            reward_multiplier = 3.0
        },
        organized_crime = {
            duration = 21600, -- 6 hours
            required_rank = "lieutenant",
            success_rate = 0.5,
            reward_multiplier = 4.0
        }
    }
}

-- K9 Unit System
Config.K9Unit = {
    enabled = true,
    dogs = {
        {
            name = "Rex",
            breed = "German Shepherd",
            specialization = "drug_detection",
            accuracy = 0.90,
            stamina = 100
        },
        {
            name = "Luna",
            breed = "Belgian Malinois", 
            specialization = "explosive_detection",
            accuracy = 0.95,
            stamina = 95
        },
        {
            name = "Max",
            breed = "Bloodhound",
            specialization = "tracking",
            accuracy = 0.85,
            stamina = 90
        }
    ],
    commands = {
        "sit", "stay", "heel", "search", "attack", "track", "find_drugs", "find_explosives"
    },
    detection_items = {
        drugs = {"weed", "cocaine", "meth", "heroin", "pills"},
        explosives = {"c4", "pipe_bomb", "grenade", "dynamite"},
        contraband = {"weapons", "stolen_goods", "counterfeit_money"}
    },
    training_requirements = {
        basic_handler = 40, -- hours
        advanced_handler = 80,
        specialist_handler = 120
    }
}

-- Internal Affairs System
Config.InternalAffairs = {
    enabled = true,
    complaint_types = {
        "excessive_force", "corruption", "misconduct", "discrimination", 
        "abuse_of_power", "falsification_of_records", "unauthorized_disclosure"
    },
    investigation_stages = {
        "complaint_filed", "preliminary_review", "formal_investigation", 
        "hearing", "disciplinary_action", "case_closed"
    },
    disciplinary_actions = {
        {action = "verbal_warning", severity = 1},
        {action = "written_reprimand", severity = 2},
        {action = "suspension_without_pay", severity = 3, duration = {1, 30}}, -- days
        {action = "demotion", severity = 4},
        {action = "termination", severity = 5}
    },
    investigators = {
        "internal_affairs_detective", "external_investigator", "police_chief"
    }
}

-- Advanced Surveillance System
Config.Surveillance = {
    enabled = true,
    camera_locations = {
        {coords = vector3(425.1, -979.5, 30.7), type = "traffic_cam", range = 50.0},
        {coords = vector3(300.0, -586.0, 43.3), type = "security_cam", range = 30.0},
        {coords = vector3(-1037.8, -2737.4, 20.2), type = "port_security", range = 100.0},
        {coords = vector3(1961.0, 3741.0, 32.3), type = "rural_highway", range = 75.0}
    },
    facial_recognition = {
        enabled = true,
        accuracy = 0.85,
        processing_time = 30,
        database_size = 10000
    },
    license_plate_recognition = {
        enabled = true,
        accuracy = 0.95,
        processing_time = 5,
        stolen_vehicle_alerts = true
    },
    surveillance_equipment = {
        "handheld_camera", "dashcam", "body_camera", "drone", "telescope"
    }
}

-- Forensics Laboratory
Config.ForensicsLab = {
    location = vector3(478.2, -988.6, 30.7),
    equipment = {
        "microscope", "dna_analyzer", "ballistics_computer", "fingerprint_scanner",
        "chemical_analyzer", "3d_scanner", "evidence_storage"
    },
    tests = {
        dna_analysis = {
            time = 1800, -- 30 minutes
            cost = 500,
            accuracy = 0.99,
            required_skill = "forensic_science"
        },
        fingerprint_analysis = {
            time = 900, -- 15 minutes
            cost = 200,
            accuracy = 0.95,
            required_skill = "fingerprint_analysis"
        },
        ballistics_matching = {
            time = 1200, -- 20 minutes
            cost = 300,
            accuracy = 0.90,
            required_skill = "ballistics_expert"
        },
        toxicology_screen = {
            time = 2400, -- 40 minutes
            cost = 400,
            accuracy = 0.93,
            required_skill = "toxicology"
        }
    }
}

-- Crime Scene Processing
Config.CrimeScene = {
    processing_steps = {
        "secure_perimeter", "photograph_scene", "collect_evidence", 
        "interview_witnesses", "document_findings", "release_scene"
    },
    required_equipment = {
        "crime_scene_tape", "evidence_markers", "camera", "measuring_tape",
        "evidence_bags", "documentation_forms"
    },
    contamination_factors = {
        time_elapsed = 0.02, -- 2% accuracy loss per minute
        weather_conditions = 0.15, -- 15% loss in rain/wind
        foot_traffic = 0.10, -- 10% loss per person
        emergency_responders = 0.05 -- 5% loss if not properly secured
    }
}

-- Detective Skills System
Config.DetectiveSkills = {
    skills = {
        ["investigation"] = {
            name = "Investigation Techniques",
            max_level = 100,
            benefits = {"faster_evidence_processing", "better_witness_interviews"}
        },
        ["forensics"] = {
            name = "Forensic Science",
            max_level = 100,
            benefits = {"improved_evidence_analysis", "contamination_prevention"}
        },
        ["interrogation"] = {
            name = "Interrogation Skills",
            max_level = 100,
            benefits = {"suspect_confession_chance", "lie_detection"}
        },
        ["surveillance"] = {
            name = "Surveillance Techniques",
            max_level = 100,
            benefits = {"better_stealth", "improved_camera_operation"}
        }
    },
    experience_sources = {
        evidence_collected = 10,
        case_solved = 100,
        suspect_arrested = 50,
        training_completed = 25,
        successful_surveillance = 30
    }
}

-- Intelligence Database
Config.Intelligence = {
    databases = {
        "criminal_records", "vehicle_registrations", "property_records",
        "financial_records", "communications_metadata", "travel_records"
    },
    access_levels = {
        officer = {"criminal_records", "vehicle_registrations"},
        detective = {"criminal_records", "vehicle_registrations", "property_records"},
        sergeant = {"all_except_classified"},
        lieutenant = {"all_databases"}
    },
    query_types = {
        "name_search", "license_plate_lookup", "address_search",
        "associate_analysis", "pattern_matching", "predictive_analytics"
    }
}

-- Language
Config.Lang = {
    ['evidence_collected'] = 'Evidence collected: %s',
    ['case_opened'] = 'New case opened: %s',
    ['suspect_arrested'] = 'Suspect arrested and processed',
    ['undercover_mission_started'] = 'Undercover operation initiated',
    ['k9_deployed'] = 'K9 unit deployed for %s detection',
    ['surveillance_active'] = 'Surveillance system activated',
    ['forensics_analysis_complete'] = 'Forensic analysis completed - Results: %s',
    ['internal_investigation'] = 'Internal Affairs investigation opened',
    ['crime_scene_secured'] = 'Crime scene secured and processing begun',
    ['database_query_complete'] = 'Database search completed - %s results found',
    ['skill_improved'] = 'Detective skill improved: %s (+%s XP)',
}