Config = {}

-- Gym Locations & Facilities
Config.Gyms = {
    ["muscle_sands"] = {
        name = "Muscle Sands Gym",
        coords = vector3(-1201.23, -1567.45, 4.61),
        heading = 0.0,
        owner = nil,
        purchase_price = 2000000,
        daily_upkeep = 1500,
        membership_capacity = 500,
        equipment_quality = "professional",
        facilities = {
            "weight_room", "cardio_area", "boxing_ring", "pool",
            "sauna", "locker_rooms", "juice_bar", "personal_training"
        },
        specialty = "bodybuilding",
        operating_hours = {open = 5, close = 23}, -- 5 AM to 11 PM
        outdoor_area = true,
        beach_access = true
    },
    ["downtown_fitness"] = {
        name = "Downtown Fitness Center",
        coords = vector3(-1270.45, -358.67, 36.91),
        heading = 180.0,
        owner = nil,
        purchase_price = 3500000,
        daily_upkeep = 2500,
        membership_capacity = 800,
        equipment_quality = "premium",
        facilities = {
            "weight_room", "cardio_area", "group_fitness_studio",
            "spin_studio", "yoga_studio", "pool", "spa", "childcare",
            "juice_bar", "pro_shop", "personal_training"
        },
        specialty = "general_fitness",
        operating_hours = {open = 4, close = 24}, -- 24/7 access for premium
        parking_available = true,
        luxury_amenities = true
    },
    ["vinewood_athletic_club"] = {
        name = "Vinewood Athletic Club",
        coords = vector3(247.23, 1185.67, 225.46),
        heading = 90.0,
        owner = nil,
        purchase_price = 8000000,
        daily_upkeep = 5000,
        membership_capacity = 300,
        equipment_quality = "elite",
        facilities = {
            "weight_room", "cardio_area", "tennis_court", "basketball_court",
            "swimming_pool", "spa", "massage_therapy", "nutrition_consulting",
            "juice_bar", "restaurant", "member_lounge", "valet_parking"
        },
        specialty = "luxury_wellness",
        operating_hours = {open = 5, close = 22},
        exclusive_membership = true,
        celebrity_clientele = true
    },
    ["sandy_shores_crossfit"] = {
        name = "Sandy Shores CrossFit",
        coords = vector3(1851.23, 3689.45, 34.27),
        heading = 270.0,
        owner = nil,
        purchase_price = 800000,
        daily_upkeep = 800,
        membership_capacity = 150,
        equipment_quality = "functional",
        facilities = {
            "crossfit_box", "outdoor_area", "tire_flipping",
            "rope_climbing", "basic_locker_rooms", "water_station"
        },
        specialty = "crossfit",
        operating_hours = {open = 6, close = 21},
        community_focused = true,
        outdoor_workouts = true
    }
}

-- Fitness Stats & Progression
Config.FitnessStats = {
    strength = {
        name = "Strength",
        max_level = 100,
        base_value = 50,
        activities = {"weightlifting", "powerlifting", "functional_training"},
        benefits = {
            melee_damage = 1.5, -- at max level
            carrying_capacity = 1.3,
            stamina_efficiency = 1.2
        },
        decay_rate = 0.1 -- per day without training
    },
    endurance = {
        name = "Endurance",
        max_level = 100,
        base_value = 50,
        activities = {"running", "cycling", "swimming", "cardio"},
        benefits = {
            stamina_regeneration = 2.0,
            running_speed = 1.25,
            breath_holding = 2.0
        },
        decay_rate = 0.15
    },
    flexibility = {
        name = "Flexibility",
        max_level = 100,
        base_value = 50,
        activities = {"yoga", "stretching", "pilates", "martial_arts"},
        benefits = {
            injury_resistance = 0.7, -- 30% less injury chance
            recovery_speed = 1.4,
            dodge_ability = 1.3
        },
        decay_rate = 0.05
    },
    coordination = {
        name = "Coordination",
        max_level = 100,
        base_value = 50,
        activities = {"boxing", "martial_arts", "dance", "sports"},
        benefits = {
            weapon_accuracy = 1.2,
            driving_skill = 1.15,
            reaction_time = 1.3
        },
        decay_rate = 0.08
    },
    mental_focus = {
        name = "Mental Focus",
        max_level = 100,
        base_value = 50,
        activities = {"meditation", "yoga", "martial_arts", "endurance_training"},
        benefits = {
            stress_resistance = 0.6,
            learning_speed = 1.25,
            decision_making = 1.2
        },
        decay_rate = 0.12
    }
}

-- Workout Programs & Equipment
Config.WorkoutPrograms = {
    ["strength_training"] = {
        name = "Strength Training",
        category = "strength",
        duration = 45, -- minutes
        difficulty = "intermediate",
        equipment_required = {"barbells", "dumbbells", "weight_plates", "bench"},
        exercises = {
            {name = "Bench Press", sets = 3, reps = 8, rest = 90},
            {name = "Squats", sets = 3, reps = 10, rest = 120},
            {name = "Deadlifts", sets = 3, reps = 6, rest = 180},
            {name = "Overhead Press", sets = 3, reps = 8, rest = 90},
            {name = "Rows", sets = 3, reps = 10, rest = 90}
        },
        stat_gains = {strength = 3, endurance = 1},
        calorie_burn = 350,
        membership_required = "basic"
    },
    ["cardio_blast"] = {
        name = "Cardio Blast",
        category = "endurance",
        duration = 30,
        difficulty = "beginner",
        equipment_required = {"treadmill", "stationary_bike", "elliptical"},
        exercises = {
            {name = "Treadmill Run", duration = 10, intensity = "moderate"},
            {name = "Bike Intervals", duration = 10, intensity = "high"},
            {name = "Elliptical", duration = 10, intensity = "moderate"}
        },
        stat_gains = {endurance = 4, strength = 1},
        calorie_burn = 450,
        membership_required = "basic"
    },
    ["yoga_flow"] = {
        name = "Yoga Flow",
        category = "flexibility",
        duration = 60,
        difficulty = "beginner",
        equipment_required = {"yoga_mat", "blocks", "straps"},
        exercises = {
            {name = "Sun Salutation", duration = 15},
            {name = "Warrior Poses", duration = 15},
            {name = "Balance Poses", duration = 15},
            {name = "Cool Down Stretches", duration = 15}
        },
        stat_gains = {flexibility = 4, mental_focus = 2},
        calorie_burn = 200,
        membership_required = "premium",
        stress_relief = true
    },
    ["crossfit_wod"] = {
        name = "CrossFit WOD",
        category = "functional",
        duration = 60,
        difficulty = "advanced",
        equipment_required = {"barbells", "kettlebells", "pull_up_bar", "box"},
        exercises = {
            {name = "Burpees", reps = 20},
            {name = "Box Jumps", reps = 15},
            {name = "Kettlebell Swings", reps = 25},
            {name = "Pull-ups", reps = 10}
        },
        stat_gains = {strength = 2, endurance = 3, coordination = 2},
        calorie_burn = 600,
        membership_required = "crossfit",
        time_based = true
    },
    ["boxing_training"] = {
        name = "Boxing Training",
        category = "combat",
        duration = 45,
        difficulty = "intermediate",
        equipment_required = {"heavy_bag", "speed_bag", "gloves", "wraps"},
        exercises = {
            {name = "Heavy Bag Work", rounds = 5, duration = 3},
            {name = "Speed Bag", rounds = 3, duration = 2},
            {name = "Footwork Drills", duration = 10},
            {name = "Conditioning", duration = 10}
        },
        stat_gains = {strength = 2, endurance = 2, coordination = 3},
        calorie_burn = 500,
        membership_required = "premium",
        combat_skills = true
    },
    ["swimming_workout"] = {
        name = "Swimming Workout",
        category = "endurance",
        duration = 45,
        difficulty = "intermediate",
        equipment_required = {"pool", "goggles", "kickboard"},
        exercises = {
            {name = "Freestyle Laps", distance = 500},
            {name = "Backstroke", distance = 200},
            {name = "Kick Sets", distance = 300},
            {name = "Cool Down", distance = 100}
        },
        stat_gains = {endurance = 4, strength = 2},
        calorie_burn = 400,
        membership_required = "premium",
        low_impact = true
    }
}

-- Personal Training System
Config.PersonalTraining = {
    trainer_levels = {
        {level = 1, name = "Certified Trainer", hourly_rate = 150, specializations = {"general_fitness"}},
        {level = 2, name = "Specialized Trainer", hourly_rate = 250, specializations = {"strength", "cardio", "weight_loss"}},
        {level = 3, name = "Expert Trainer", hourly_rate = 400, specializations = {"bodybuilding", "powerlifting", "sports_specific"}},
        {level = 4, name = "Master Trainer", hourly_rate = 600, specializations = {"elite_athlete", "rehabilitation", "nutrition"}},
        {level = 5, name = "Celebrity Trainer", hourly_rate = 1000, specializations = {"transformation", "media_prep", "lifestyle"}}
    },
    training_programs = {
        weight_loss = {
            duration = 8, -- weeks
            sessions_per_week = 3,
            focus = {"cardio", "strength", "nutrition"},
            expected_results = "15-25 lbs weight loss",
            price_multiplier = 1.0
        },
        muscle_building = {
            duration = 12,
            sessions_per_week = 4,
            focus = {"strength", "nutrition", "recovery"},
            expected_results = "10-20 lbs muscle gain",
            price_multiplier = 1.2
        },
        athletic_performance = {
            duration = 16,
            sessions_per_week = 5,
            focus = {"sport_specific", "strength", "conditioning"},
            expected_results = "20-30% performance improvement",
            price_multiplier = 1.5
        },
        rehabilitation = {
            duration = 6,
            sessions_per_week = 2,
            focus = {"injury_recovery", "mobility", "strength"},
            expected_results = "Full recovery",
            price_multiplier = 1.3,
            medical_clearance_required = true
        }
    },
    progress_tracking = {
        body_measurements = true,
        fitness_assessments = true,
        photo_documentation = true,
        performance_metrics = true,
        nutrition_logging = true
    }
}

-- Nutrition & Supplements
Config.Nutrition = {
    supplements = {
        protein_powder = {
            name = "Whey Protein Powder",
            price = 150,
            benefits = {muscle_growth = 1.2, recovery_speed = 1.15},
            duration = 30, -- days
            side_effects = {},
            recommended_usage = "post_workout"
        },
        creatine = {
            name = "Creatine Monohydrate",
            price = 100,
            benefits = {strength = 1.1, power_output = 1.15},
            duration = 60,
            side_effects = {"water_retention"},
            recommended_usage = "daily"
        },
        pre_workout = {
            name = "Pre-Workout Formula",
            price = 120,
            benefits = {energy = 1.3, focus = 1.2, endurance = 1.1},
            duration = 45, -- servings
            side_effects = {"jitters", "crash"},
            recommended_usage = "pre_workout"
        },
        bcaa = {
            name = "Branched-Chain Amino Acids",
            price = 80,
            benefits = {recovery_speed = 1.25, muscle_preservation = 1.1},
            duration = 50,
            side_effects = {},
            recommended_usage = "during_workout"
        },
        multivitamin = {
            name = "Daily Multivitamin",
            price = 60,
            benefits = {general_health = 1.05, immunity = 1.1},
            duration = 90,
            side_effects = {},
            recommended_usage = "daily"
        }
    },
    meal_plans = {
        weight_loss = {
            name = "Weight Loss Meal Plan",
            daily_calories = 1500,
            macros = {protein = 40, carbs = 30, fat = 30},
            weekly_cost = 200,
            meal_frequency = 5
        },
        muscle_gain = {
            name = "Muscle Building Meal Plan",
            daily_calories = 2800,
            macros = {protein = 35, carbs = 45, fat = 20},
            weekly_cost = 300,
            meal_frequency = 6
        },
        athletic_performance = {
            name = "Athletic Performance Plan",
            daily_calories = 3200,
            macros = {protein = 30, carbs = 50, fat = 20},
            weekly_cost = 350,
            meal_frequency = 6
        },
        maintenance = {
            name = "Maintenance Plan",
            daily_calories = 2200,
            macros = {protein = 25, carbs = 45, fat = 30},
            weekly_cost = 250,
            meal_frequency = 4
        }
    }
}

-- Membership Types & Pricing
Config.Memberships = {
    day_pass = {
        name = "Day Pass",
        price = 50,
        duration = 1, -- days
        benefits = {"gym_access", "locker_room"},
        restrictions = {"no_classes", "no_personal_training"}
    },
    basic_monthly = {
        name = "Basic Monthly",
        price = 800,
        duration = 30,
        benefits = {"gym_access", "locker_room", "basic_classes"},
        restrictions = {"no_premium_classes", "no_spa"}
    },
    premium_monthly = {
        name = "Premium Monthly",
        price = 1500,
        duration = 30,
        benefits = {
            "gym_access", "locker_room", "all_classes",
            "pool_access", "sauna", "guest_passes"
        },
        restrictions = {"limited_personal_training"}
    },
    vip_monthly = {
        name = "VIP Monthly",
        price = 3000,
        duration = 30,
        benefits = {
            "unlimited_access", "all_amenities", "personal_training_discount",
            "nutrition_consultation", "priority_booking", "valet_parking"
        },
        restrictions = {}
    },
    annual_discount = {
        discount_rate = 0.15, -- 15% off
        payment_upfront = true,
        cancellation_policy = "6_month_minimum"
    }
}

-- Group Fitness Classes
Config.GroupClasses = {
    spin_class = {
        name = "Spin Class",
        duration = 45,
        max_participants = 20,
        instructor_required = true,
        equipment = {"stationary_bikes", "sound_system"},
        difficulty = "intermediate",
        calorie_burn = 500,
        schedule = {"monday_6pm", "wednesday_7am", "friday_6pm"}
    },
    yoga = {
        name = "Yoga",
        duration = 60,
        max_participants = 15,
        instructor_required = true,
        equipment = {"yoga_mats", "blocks", "straps"},
        difficulty = "beginner",
        calorie_burn = 200,
        schedule = {"daily_8am", "daily_6pm"}
    },
    zumba = {
        name = "Zumba Dance",
        duration = 45,
        max_participants = 25,
        instructor_required = true,
        equipment = {"sound_system", "mirrors"},
        difficulty = "beginner",
        calorie_burn = 400,
        schedule = {"tuesday_7pm", "thursday_7pm", "saturday_10am"}
    },
    bootcamp = {
        name = "Boot Camp",
        duration = 60,
        max_participants = 12,
        instructor_required = true,
        equipment = {"kettlebells", "medicine_balls", "agility_ladder"},
        difficulty = "advanced",
        calorie_burn = 600,
        schedule = {"monday_6am", "wednesday_6am", "friday_6am"}
    },
    pilates = {
        name = "Pilates",
        duration = 50,
        max_participants = 12,
        instructor_required = true,
        equipment = {"pilates_reformers", "mats"},
        difficulty = "intermediate",
        calorie_burn = 250,
        schedule = {"tuesday_9am", "thursday_12pm", "sunday_10am"}
    }
}

-- Competitions & Events
Config.Competitions = {
    bodybuilding_show = {
        name = "Los Santos Bodybuilding Championship",
        frequency = "quarterly",
        entry_fee = 500,
        categories = {"men_physique", "women_bikini", "classic_physique", "bodybuilding"},
        prize_pool = 50000,
        judging_criteria = {"muscularity", "symmetry", "conditioning", "presentation"},
        sponsorship_opportunities = true
    },
    powerlifting_meet = {
        name = "LS Powerlifting Open",
        frequency = "monthly",
        entry_fee = 200,
        categories = {"squat", "bench_press", "deadlift", "total"},
        prize_pool = 15000,
        judging_criteria = {"technique", "weight_lifted"},
        drug_testing = true
    },
    marathon = {
        name = "Los Santos Marathon",
        frequency = "annually",
        entry_fee = 150,
        categories = {"full_marathon", "half_marathon", "10k", "5k"},
        prize_pool = 25000,
        charity_component = true,
        city_permit_required = true
    },
    crossfit_competition = {
        name = "CrossFit Games Qualifier",
        frequency = "annually",
        entry_fee = 300,
        categories = {"rx_male", "rx_female", "scaled_male", "scaled_female"},
        prize_pool = 35000,
        judging_criteria = {"time", "reps", "form"},
        qualification_requirements = true
    }
}

-- Health & Wellness Services
Config.WellnessServices = {
    massage_therapy = {
        types = {
            swedish = {duration = 60, price = 200, benefits = {"relaxation", "stress_relief"}},
            deep_tissue = {duration = 90, price = 300, benefits = {"muscle_recovery", "pain_relief"}},
            sports = {duration = 60, price = 250, benefits = {"injury_prevention", "performance"}},
            hot_stone = {duration = 90, price = 350, benefits = {"deep_relaxation", "circulation"}}
        },
        therapist_certification = true,
        booking_required = true
    },
    physical_therapy = {
        services = {
            injury_assessment = {duration = 60, price = 300},
            rehabilitation = {duration = 45, price = 200},
            movement_analysis = {duration = 30, price = 150},
            prevention_program = {duration = 60, price = 250}
        },
        insurance_accepted = true,
        doctor_referral_preferred = true
    },
    nutrition_counseling = {
        services = {
            initial_consultation = {duration = 90, price = 400},
            follow_up = {duration = 30, price = 150},
            meal_planning = {duration = 60, price = 200},
            supplement_guidance = {duration = 30, price = 100}
        },
        registered_dietitian = true,
        body_composition_analysis = true
    }
}

-- Staff Management
Config.Staff = {
    positions = {
        owner = {
            salary = 0, -- profit-based
            permissions = {"all"},
            max_positions = 1
        },
        manager = {
            salary = 6000,
            permissions = {"staff_management", "member_management", "scheduling"},
            max_positions = 2
        },
        fitness_instructor = {
            salary = 3500,
            permissions = {"class_instruction", "member_assistance"},
            max_positions = 10,
            certification_required = true
        },
        personal_trainer = {
            salary = 2500,
            permissions = {"personal_training", "program_design"},
            max_positions = 8,
            commission_based = true,
            certification_required = true
        },
        front_desk = {
            salary = 2000,
            permissions = {"member_checkin", "sales", "scheduling"},
            max_positions = 6
        },
        maintenance = {
            salary = 2200,
            permissions = {"equipment_maintenance", "facility_upkeep"},
            max_positions = 3
        },
        nutritionist = {
            salary = 4000,
            permissions = {"nutrition_consulting", "meal_planning"},
            max_positions = 2,
            degree_required = true
        }
    },
    training_programs = {
        customer_service = {duration = 8, cost = 500},
        equipment_operation = {duration = 16, cost = 800},
        emergency_procedures = {duration = 4, cost = 300},
        sales_techniques = {duration = 12, cost = 600}
    }
}

-- Integration Settings
Config.Integration = {
    phone_apps = {
        workout_tracking = true,
        class_booking = true,
        trainer_scheduling = true,
        progress_photos = true,
        nutrition_logging = true
    },
    wearable_devices = {
        heart_rate_monitoring = true,
        step_counting = true,
        calorie_tracking = true,
        workout_sync = true
    },
    medical_integration = {
        health_screenings = true,
        injury_reporting = true,
        doctor_communication = true,
        insurance_processing = true
    }
}

-- Export alias for loader
LS_GYM = LS_GYM or {}
LS_GYM.Gyms = Config.Gyms
LS_GYM.FitnessStats = Config.FitnessStats
LS_GYM.MealPlans = Config.MealPlans
LS_GYM.Memberships = Config.Memberships
LS_GYM.GroupClasses = Config.GroupClasses
LS_GYM.Competitions = Config.Competitions
LS_GYM.WellnessServices = Config.WellnessServices
LS_GYM.Staff = Config.Staff
LS_GYM.Integration = Config.Integration
return LS_GYM