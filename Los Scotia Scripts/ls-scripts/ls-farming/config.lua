Config = {}

-- Farm Locations & Properties
Config.Farms = {
    ["grapeseed_farm"] = {
        name = "Grapeseed Agricultural Center",
        coords = vector3(2447.25, 4781.05, 34.30),
        heading = 45.0,
        owner = nil,
        purchase_price = 2500000,
        daily_upkeep = 2000,
        total_area = 50000, -- square meters
        available_plots = 20,
        plot_size = 2500, -- square meters per plot
        water_access = true,
        electricity = true,
        storage_capacity = 10000, -- kg
        farm_type = "mixed_agriculture",
        soil_quality = "excellent",
        climate_zone = "temperate"
    },
    ["paleto_ranch"] = {
        name = "Paleto Bay Ranch",
        coords = vector3(-1122.45, 4925.12, 218.67),
        heading = 180.0,
        owner = nil,
        purchase_price = 3500000,
        daily_upkeep = 3000,
        total_area = 75000,
        available_plots = 15,
        plot_size = 5000,
        water_access = true,
        electricity = true,
        storage_capacity = 15000,
        farm_type = "livestock_ranch",
        pasture_area = 40000,
        barn_capacity = 100
    },
    ["sandy_shores_greenhouse"] = {
        name = "Sandy Shores Greenhouse Complex",
        coords = vector3(2015.23, 3778.56, 32.18),
        heading = 270.0,
        owner = nil,
        purchase_price = 1800000,
        daily_upkeep = 1500,
        total_area = 5000,
        available_plots = 25,
        plot_size = 200,
        water_access = true,
        electricity = true,
        storage_capacity = 8000,
        farm_type = "greenhouse",
        climate_controlled = true,
        year_round_growing = true
    }
}

-- Crop Types & Growing
Config.Crops = {
    ["wheat"] = {
        name = "Wheat",
        category = "grain",
        grow_time = 120, -- minutes
        water_requirement = "medium",
        season_preference = {"spring", "summer"},
        yield_per_plot = {min = 150, max = 250}, -- kg
        base_sell_price = 8, -- per kg
        seed_cost = 50, -- per plot
        experience_gain = 15,
        required_level = 1,
        growth_stages = {"planted", "sprouting", "growing", "mature", "ready"},
        weather_sensitivity = "low",
        pest_resistance = "medium"
    },
    ["corn"] = {
        name = "Corn",
        category = "vegetable",
        grow_time = 150,
        water_requirement = "high",
        season_preference = {"summer"},
        yield_per_plot = {min = 200, max = 350},
        base_sell_price = 12,
        seed_cost = 75,
        experience_gain = 20,
        required_level = 3,
        growth_stages = {"planted", "sprouting", "growing", "tasseling", "mature", "ready"},
        weather_sensitivity = "medium",
        pest_resistance = "low"
    },
    ["tomatoes"] = {
        name = "Tomatoes",
        category = "vegetable",
        grow_time = 90,
        water_requirement = "high",
        season_preference = {"spring", "summer", "fall"},
        yield_per_plot = {min = 100, max = 180},
        base_sell_price = 25,
        seed_cost = 100,
        experience_gain = 25,
        required_level = 5,
        growth_stages = {"planted", "sprouting", "flowering", "fruit_set", "ripening", "ready"},
        weather_sensitivity = "high",
        pest_resistance = "low",
        greenhouse_compatible = true
    },
    ["potatoes"] = {
        name = "Potatoes",
        category = "root_vegetable",
        grow_time = 180,
        water_requirement = "medium",
        season_preference = {"spring", "fall"},
        yield_per_plot = {min = 300, max = 500},
        base_sell_price = 6,
        seed_cost = 40,
        experience_gain = 18,
        required_level = 2,
        growth_stages = {"planted", "sprouting", "vegetative", "tuber_formation", "maturation", "ready"},
        weather_sensitivity = "low",
        pest_resistance = "high"
    },
    ["cannabis"] = {
        name = "Cannabis",
        category = "medicinal",
        grow_time = 240,
        water_requirement = "high",
        season_preference = {"summer"},
        yield_per_plot = {min = 50, max = 120},
        base_sell_price = 150,
        seed_cost = 500,
        experience_gain = 50,
        required_level = 10,
        growth_stages = {"planted", "seedling", "vegetative", "pre_flower", "flowering", "ready"},
        weather_sensitivity = "high",
        pest_resistance = "low",
        requires_license = true,
        indoor_only = true
    },
    ["strawberries"] = {
        name = "Strawberries",
        category = "fruit",
        grow_time = 60,
        water_requirement = "medium",
        season_preference = {"spring", "summer"},
        yield_per_plot = {min = 80, max = 150},
        base_sell_price = 35,
        seed_cost = 120,
        experience_gain = 30,
        required_level = 7,
        growth_stages = {"planted", "sprouting", "flowering", "fruit_development", "ripening", "ready"},
        weather_sensitivity = "medium",
        pest_resistance = "medium",
        harvest_frequency = "weekly"
    },
    ["grapes"] = {
        name = "Grapes",
        category = "fruit",
        grow_time = 300,
        water_requirement = "low",
        season_preference = {"spring", "summer", "fall"},
        yield_per_plot = {min = 200, max = 400},
        base_sell_price = 45,
        seed_cost = 200,
        experience_gain = 40,
        required_level = 8,
        growth_stages = {"planted", "sprouting", "vegetative", "flowering", "fruit_set", "veraison", "ready"},
        weather_sensitivity = "low",
        pest_resistance = "medium",
        processing_options = {"wine", "juice", "raisins"}
    }
}

-- Livestock System
Config.Livestock = {
    ["chickens"] = {
        name = "Chickens",
        category = "poultry",
        purchase_price = 150,
        daily_upkeep = 5,
        space_requirement = 2, -- square meters per animal
        maturity_time = 2880, -- minutes (48 hours)
        lifespan = 43200, -- minutes (30 days)
        products = {
            eggs = {
                production_rate = 720, -- minutes between production
                quantity = {min = 1, max = 3},
                sell_price = 15 -- per egg
            }
        },
        feed_requirement = "grain",
        feed_consumption = 2, -- kg per day
        health_decay = 0.5, -- per hour without care
        breeding_possible = true,
        required_level = 1
    },
    ["cows"] = {
        name = "Cows",
        category = "cattle",
        purchase_price = 5000,
        daily_upkeep = 50,
        space_requirement = 100,
        maturity_time = 10080, -- minutes (7 days)
        lifespan = 129600, -- minutes (90 days)
        products = {
            milk = {
                production_rate = 720, -- 12 hours
                quantity = {min = 10, max = 25},
                sell_price = 8 -- per liter
            },
            meat = {
                available_at_slaughter = true,
                quantity = {min = 200, max = 400},
                sell_price = 25 -- per kg
            }
        },
        feed_requirement = "hay",
        feed_consumption = 20,
        health_decay = 0.3,
        breeding_possible = true,
        required_level = 5,
        pregnancy_duration = 12960 -- 9 days
    },
    ["pigs"] = {
        name = "Pigs",
        category = "swine",
        purchase_price = 2000,
        daily_upkeep = 25,
        space_requirement = 25,
        maturity_time = 7200, -- 5 days
        lifespan = 86400, -- 60 days
        products = {
            meat = {
                available_at_slaughter = true,
                quantity = {min = 80, max = 150},
                sell_price = 30
            }
        },
        feed_requirement = "mixed_feed",
        feed_consumption = 8,
        health_decay = 0.4,
        breeding_possible = true,
        required_level = 3,
        pregnancy_duration = 5760 -- 4 days
    },
    ["sheep"] = {
        name = "Sheep",
        category = "livestock",
        purchase_price = 1200,
        daily_upkeep = 15,
        space_requirement = 50,
        maturity_time = 5760, -- 4 days
        lifespan = 100800, -- 70 days
        products = {
            wool = {
                production_rate = 2880, -- 2 days
                quantity = {min = 5, max = 12},
                sell_price = 20 -- per kg
            },
            meat = {
                available_at_slaughter = true,
                quantity = {min = 40, max = 80},
                sell_price = 28
            }
        },
        feed_requirement = "grass",
        feed_consumption = 5,
        health_decay = 0.3,
        breeding_possible = true,
        required_level = 4
    }
}

-- Equipment & Machinery
Config.Equipment = {
    ["basic_tools"] = {
        name = "Basic Farming Tools",
        price = 500,
        efficiency_bonus = 1.0,
        durability = 100,
        tools = {"hoe", "watering_can", "pruning_shears", "harvest_basket"}
    },
    ["irrigation_system"] = {
        name = "Irrigation System",
        price = 15000,
        efficiency_bonus = 1.5,
        water_savings = 0.30,
        coverage_area = 5000, -- square meters
        maintenance_cost = 200 -- daily
    },
    ["tractor"] = {
        name = "Farm Tractor",
        price = 75000,
        efficiency_bonus = 3.0,
        fuel_consumption = 20, -- per hour
        speed_bonus = 2.0,
        attachments = {"plow", "seeder", "harvester"},
        maintenance_cost = 500
    },
    ["greenhouse"] = {
        name = "Greenhouse Module",
        price = 25000,
        climate_control = true,
        yield_bonus = 1.8,
        year_round_growing = true,
        size = 200, -- square meters
        electricity_cost = 300 -- daily
    },
    ["processing_plant"] = {
        name = "Crop Processing Plant",
        price = 150000,
        processing_capacity = 1000, -- kg per hour
        value_added_multiplier = 2.5,
        products = {"flour", "canned_goods", "juice", "preserves"},
        staff_requirement = 3
    },
    ["silo"] = {
        name = "Grain Silo",
        price = 50000,
        storage_capacity = 50000, -- kg
        preservation_bonus = 0.95, -- 5% less spoilage
        bulk_discount_eligible = true
    }
}

-- Processing & Value-Added Products
Config.Processing = {
    recipes = {
        ["wheat_to_flour"] = {
            input = {wheat = 100},
            output = {flour = 80},
            processing_time = 30, -- minutes
            experience_gain = 10,
            required_equipment = "processing_plant",
            sell_price_bonus = 2.0
        },
        ["tomatoes_to_sauce"] = {
            input = {tomatoes = 50},
            output = {tomato_sauce = 25},
            processing_time = 45,
            experience_gain = 15,
            required_equipment = "processing_plant",
            sell_price_bonus = 3.0
        },
        ["grapes_to_wine"] = {
            input = {grapes = 100},
            output = {wine = 30},
            processing_time = 480, -- 8 hours fermentation
            experience_gain = 25,
            required_equipment = "winery",
            sell_price_bonus = 5.0,
            aging_bonus = true
        },
        ["milk_to_cheese"] = {
            input = {milk = 20},
            output = {cheese = 5},
            processing_time = 120,
            experience_gain = 20,
            required_equipment = "dairy_processor",
            sell_price_bonus = 4.0
        },
        ["wool_to_textile"] = {
            input = {wool = 10},
            output = {textile = 8},
            processing_time = 60,
            experience_gain = 18,
            required_equipment = "textile_mill",
            sell_price_bonus = 3.5
        }
    },
    quality_grades = {
        poor = {multiplier = 0.7, requirements = {health = 30, care = 20}},
        fair = {multiplier = 0.85, requirements = {health = 50, care = 40}},
        good = {multiplier = 1.0, requirements = {health = 70, care = 60}},
        excellent = {multiplier = 1.3, requirements = {health = 85, care = 80}},
        premium = {multiplier = 1.6, requirements = {health = 95, care = 95}}
    }
}

-- Market & Economy
Config.Market = {
    price_fluctuation = {
        enabled = true,
        daily_variance = 0.10, -- ±10%
        seasonal_modifier = {
            spring = {vegetables = 1.2, fruits = 0.9},
            summer = {vegetables = 0.9, fruits = 1.3, grains = 1.1},
            fall = {grains = 1.3, vegetables = 1.1, fruits = 0.8},
            winter = {vegetables = 1.4, fruits = 1.5, grains = 0.9}
        },
        supply_demand_impact = true
    },
    contracts = {
        restaurant_supply = {
            duration = 7, -- days
            quantity_bonus = 1.2,
            price_stability = true,
            quality_requirements = "good",
            penalty_for_missed_delivery = 0.20
        },
        grocery_chain = {
            duration = 14,
            quantity_bonus = 1.5,
            bulk_discounts = true,
            quality_requirements = "fair",
            regular_pickup_schedule = true
        },
        export_orders = {
            duration = 3,
            price_premium = 1.8,
            shipping_costs = 0.15,
            quality_requirements = "excellent",
            documentation_required = true
        }
    },
    farmers_market = {
        location = vector3(1986.45, 3054.12, 47.22),
    operating_hours = {start_hour = 6, end_hour = 14}, -- 6 AM to 2 PM
        stall_rental = 200, -- daily
        direct_to_consumer = true,
        price_premium = 1.4,
        customer_relationships = true
    }
}

-- Farming Levels & Experience
Config.Experience = {
    levels = {
        {level = 1, required_xp = 0, perks = {"basic_farming"}},
        {level = 2, required_xp = 500, perks = {"improved_yield_5_percent"}},
        {level = 3, required_xp = 1200, perks = {"livestock_access", "disease_resistance"}},
        {level = 4, required_xp = 2000, perks = {"advanced_crops", "equipment_efficiency"}},
        {level = 5, required_xp = 3500, perks = {"greenhouse_access", "breeding_programs"}},
        {level = 6, required_xp = 5500, perks = {"processing_recipes", "market_contracts"}},
        {level = 7, required_xp = 8000, perks = {"exotic_crops", "premium_livestock"}},
        {level = 8, required_xp = 12000, perks = {"organic_certification", "export_access"}},
        {level = 9, required_xp = 17000, perks = {"hydroponics", "genetics_research"}},
        {level = 10, required_xp = 25000, perks = {"master_farmer", "all_content_unlocked"}}
    },
    activity_xp = {
        planting = 5,
        watering = 3,
        harvesting = 10,
        animal_care = 8,
        processing = 15,
        selling = 5,
        research = 20
    }
}

-- Weather & Seasons
Config.Weather = {
    seasons = {
        spring = {
            months = {3, 4, 5},
            growing_bonus = 1.2,
            rain_frequency = "high",
            temperature_range = {15, 25}
        },
        summer = {
            months = {6, 7, 8},
            growing_bonus = 1.5,
            drought_risk = "medium",
            temperature_range = {25, 35}
        },
        fall = {
            months = {9, 10, 11},
            harvest_bonus = 1.3,
            frost_risk = "low",
            temperature_range = {10, 20}
        },
        winter = {
            months = {12, 1, 2},
            growing_penalty = 0.5,
            greenhouse_required = true,
            temperature_range = {0, 10}
        }
    },
    weather_effects = {
        rain = {crop_growth_bonus = 1.1, livestock_health_penalty = 0.95},
        drought = {crop_yield_penalty = 0.7, water_cost_increase = 2.0},
        frost = {crop_damage_risk = 0.3, heating_costs = 1.5},
        hail = {crop_damage_severe = 0.5, insurance_claims = true},
        extreme_heat = {livestock_stress = true, cooling_costs = 2.0}
    }
}

-- Research & Development
Config.Research = {
    projects = {
        drought_resistant_crops = {
            cost = 50000,
            duration = 7, -- days
            benefits = {"water_savings_30_percent", "drought_immunity"},
            required_level = 6
        },
        organic_certification = {
            cost = 25000,
            duration = 14,
            benefits = {"organic_premium_50_percent", "health_bonus"},
            required_level = 7
        },
        selective_breeding = {
            cost = 75000,
            duration = 21,
            benefits = {"livestock_yield_25_percent", "disease_resistance"},
            required_level = 8
        },
        hydroponic_systems = {
            cost = 100000,
            duration = 10,
            benefits = {"soilless_growing", "year_round_production", "space_efficiency"},
            required_level = 9
        }
    },
    university_partnership = {
        enabled = true,
        research_grants = true,
        student_workers = true,
        technology_transfer = true
    }
}

-- Cooperative System
Config.Cooperatives = {
    formation_requirements = {
        minimum_members = 5,
        initial_investment = 100000,
        shared_resources = true,
        democratic_decision_making = true
    },
    benefits = {
        bulk_purchasing_discounts = 0.15,
        shared_equipment_access = true,
        collective_marketing = true,
        risk_sharing = true,
        knowledge_exchange = true
    },
    shared_facilities = {
        processing_plant = {cost = 300000, member_access = true},
        cold_storage = {cost = 150000, rental_rates = 0.5},
        equipment_pool = {cost = 200000, scheduling_system = true},
        marketing_fund = {monthly_contribution = 1000, promotion_benefits = true}
    }
}

-- Environmental Impact
Config.Environment = {
    sustainability_practices = {
        crop_rotation = {
            enabled = true,
            soil_health_bonus = 1.2,
            pest_control_natural = true,
            nutrient_cycling = true
        },
        water_conservation = {
            drip_irrigation = {efficiency = 1.4, cost = 20000},
            rainwater_harvesting = {storage_capacity = 10000, cost = 15000},
            recycled_water = {treatment_cost = 5000, environmental_bonus = true}
        },
        renewable_energy = {
            solar_panels = {cost = 80000, electricity_savings = 0.60, carbon_offset = true},
            wind_turbines = {cost = 150000, electricity_generation = true, grid_sellback = true},
            biogas_digesters = {cost = 50000, waste_processing = true, energy_production = true}
        }
    },
    carbon_footprint = {
        tracking_enabled = true,
        carbon_credits = true,
        offset_programs = true,
        sustainability_certification = true
    }
}

-- Integration Settings
Config.Integration = {
    restaurants = {
        direct_supply = true,
        quality_requirements = true,
        contract_system = true,
        seasonal_menus = true
    },
    grocery_stores = {
        wholesale_pricing = true,
        freshness_tracking = true,
        local_sourcing_preference = true
    },
    export_markets = {
        international_shipping = true,
        quality_certifications = true,
        currency_exchange = true,
        trade_agreements = true
    }
}

-- Export alias (moved to end so all sections included)
LS_FARMING = LS_FARMING or {}
LS_FARMING.Farms = Config.Farms
LS_FARMING.Market = Config.Market
LS_FARMING.Experience = Config.Experience
LS_FARMING.Weather = Config.Weather
LS_FARMING.Research = Config.Research
LS_FARMING.Cooperatives = Config.Cooperatives
LS_FARMING.Environment = Config.Environment
LS_FARMING.Integration = Config.Integration
return LS_FARMING