Config = {}

-- Stock Market System
Config.StockMarket = {
    enabled = true,
    trading_hours = {
        open = 9, -- 9 AM
        close = 16 -- 4 PM
    },
    companies = {
        ["BAWSAQ"] = {
            name = "Bank of Liberty",
            sector = "financial",
            initial_price = 150.50,
            volatility = 0.02, -- 2% daily volatility
            market_cap = 50000000000, -- $50B
            dividend_yield = 0.035 -- 3.5% annually
        },
        ["ECO"] = {
            name = "Ecola Corporation",
            sector = "consumer_goods",
            initial_price = 85.20,
            volatility = 0.015,
            market_cap = 25000000000,
            dividend_yield = 0.028
        },
        ["LIFE"] = {
            name = "LifeInvader",
            sector = "technology",
            initial_price = 320.75,
            volatility = 0.04,
            market_cap = 120000000000,
            dividend_yield = 0.015
        },
        ["MAZE"] = {
            name = "Maze Bank",
            sector = "financial",
            initial_price = 45.30,
            volatility = 0.025,
            market_cap = 30000000000,
            dividend_yield = 0.042
        },
        ["FUEL"] = {
            name = "Ron Oil",
            sector = "energy",
            initial_price = 92.80,
            volatility = 0.035,
            market_cap = 40000000000,
            dividend_yield = 0.055
        },
        ["AUTO"] = {
            name = "Los Santos Customs",
            sector = "automotive",
            initial_price = 68.40,
            volatility = 0.03,
            market_cap = 15000000000,
            dividend_yield = 0.025
        }
    },
    market_indices = {
        ["LSX"] = { -- Los Santos Exchange
            name = "LS Stock Exchange Index",
            components = {"BAWSAQ", "ECO", "LIFE", "MAZE", "FUEL", "AUTO"},
            base_value = 1000
        }
    },
    trading_fees = {
        commission = 0.001, -- 0.1% per trade
        minimum_fee = 5,
        premium_account_discount = 0.5 -- 50% discount for premium accounts
    }
}

-- Business Ownership System
Config.Businesses = {
    types = {
        ["restaurant"] = {
            name = "Restaurant",
            initial_cost = 500000,
            daily_operating_cost = 2000,
            max_employees = 15,
            revenue_sources = {"food_sales", "beverage_sales", "catering"},
            required_supplies = {"food_ingredients", "beverages", "cleaning_supplies"},
            profit_margin = {min = 0.15, max = 0.35}
        },
        ["gas_station"] = {
            name = "Gas Station",
            initial_cost = 800000,
            daily_operating_cost = 1500,
            max_employees = 8,
            revenue_sources = {"fuel_sales", "convenience_store", "car_wash"},
            required_supplies = {"gasoline", "snacks", "automotive_supplies"},
            profit_margin = {min = 0.08, max = 0.20}
        },
        ["nightclub"] = {
            name = "Nightclub",
            initial_cost = 2000000,
            daily_operating_cost = 5000,
            max_employees = 25,
            revenue_sources = {"entry_fees", "bar_sales", "vip_services", "events"},
            required_supplies = {"alcohol", "sound_equipment", "security"},
            profit_margin = {min = 0.25, max = 0.50}
        },
        ["clothing_store"] = {
            name = "Clothing Store",
            initial_cost = 300000,
            daily_operating_cost = 1000,
            max_employees = 10,
            revenue_sources = {"clothing_sales", "accessories", "custom_orders"},
            required_supplies = {"clothing_inventory", "accessories", "packaging"},
            profit_margin = {min = 0.30, max = 0.60}
        },
        ["auto_shop"] = {
            name = "Auto Repair Shop",
            initial_cost = 750000,
            daily_operating_cost = 2500,
            max_employees = 12,
            revenue_sources = {"repairs", "modifications", "parts_sales"},
            required_supplies = {"car_parts", "tools", "oil_lubricants"},
            profit_margin = {min = 0.20, max = 0.45}
        },
        ["tech_company"] = {
            name = "Technology Company",
            initial_cost = 1500000,
            daily_operating_cost = 8000,
            max_employees = 50,
            revenue_sources = {"software_development", "consulting", "hardware_sales"},
            required_supplies = {"computer_equipment", "office_supplies", "software_licenses"},
            profit_margin = {min = 0.40, max = 0.70}
        }
    },
    locations = {
        -- Restaurants
        {
            type = "restaurant",
            name = "Burger Shot - Downtown",
            coords = vector3(139.4, -1469.6, 29.4),
            price = 450000,
            size = "medium"
        },
        {
            type = "restaurant",
            name = "Cluckin' Bell - Paleto Bay",
            coords = vector3(-146.9, 6161.5, 31.2),
            price = 350000,
            size = "small"
        },
        -- Gas Stations
        {
            type = "gas_station",
            name = "RON Gas - Great Ocean Highway",
            coords = vector3(2581.3, 362.0, 108.5),
            price = 750000,
            size = "large"
        },
        {
            type = "gas_station",
            name = "LTD Gasoline - Sandy Shores",
            coords = vector3(1961.3, 3740.0, 32.3),
            price = 600000,
            size = "medium"
        },
        -- Nightclubs
        {
            type = "nightclub",
            name = "Galaxy Super Yacht",
            coords = vector3(-1284.0, -674.4, 26.4),
            price = 2500000,
            size = "large"
        },
        -- Auto Shops
        {
            type = "auto_shop",
            name = "LS Customs - Strawberry",
            coords = vector3(727.9, -1088.7, 22.2),
            price = 800000,
            size = "large"
        }
    }
}

-- Supply Chain Management
Config.SupplyChain = {
    enabled = true,
    suppliers = {
        ["food_distributors"] = {
            name = "Los Santos Food Distributors",
            coords = vector3(1006.0, -2160.4, 30.5),
            supplies = {
                {item = "food_ingredients", price = 50, bulk_discount = 0.1},
                {item = "beverages", price = 30, bulk_discount = 0.15},
                {item = "cleaning_supplies", price = 25, bulk_discount = 0.05}
            },
            delivery_time = {min = 30, max = 120}, -- minutes
            minimum_order = 1000
        },
        ["fuel_supplier"] = {
            name = "Ron Oil Supply",
            coords = vector3(2752.0, 1432.0, 24.5),
            supplies = {
                {item = "gasoline", price = 2.80, bulk_discount = 0.2}
            },
            delivery_time = {min = 60, max = 180},
            minimum_order = 5000
        },
        ["tech_distributor"] = {
            name = "LifeInvader Tech Supply",
            coords = vector3(-1082.3, -247.7, 37.8),
            supplies = {
                {item = "computer_equipment", price = 800, bulk_discount = 0.08},
                {item = "software_licenses", price = 300, bulk_discount = 0.12}
            },
            delivery_time = {min = 120, max = 300},
            minimum_order = 10000
        }
    },
    logistics = {
        delivery_companies = {
            {
                name = "Fast Delivery Co.",
                price_per_km = 5,
                speed_multiplier = 1.5,
                reliability = 0.95
            },
            {
                name = "Reliable Transport",
                price_per_km = 3,
                speed_multiplier = 1.0,
                reliability = 0.99
            },
            {
                name = "Budget Shipping",
                price_per_km = 2,
                speed_multiplier = 0.8,
                reliability = 0.85
            }
        },
        warehouse_system = {
            enabled = true,
            locations = {
                {
                    name = "Port Warehouse",
                    coords = vector3(1009.5, -2160.4, 30.5),
                    capacity = 10000, -- units
                    monthly_cost = 15000
                },
                {
                    name = "Sandy Shores Storage",
                    coords = vector3(1885.2, 3757.8, 32.8),
                    capacity = 5000,
                    monthly_cost = 8000
                }
            }
        }
    }
}

-- Economic Simulation
Config.EconomicSimulation = {
    enabled = true,
    cycles = {
        recession = {
            duration = {min = 30, max = 90}, -- days
            effects = {
                stock_market = -0.25, -- -25% average
                business_revenue = -0.20,
                unemployment = 0.15,
                consumer_spending = -0.30
            }
        },
        growth = {
            duration = {min = 60, max = 180},
            effects = {
                stock_market = 0.20,
                business_revenue = 0.15,
                unemployment = -0.10,
                consumer_spending = 0.25
            }
        },
        boom = {
            duration = {min = 20, max = 60},
            effects = {
                stock_market = 0.40,
                business_revenue = 0.30,
                unemployment = -0.20,
                consumer_spending = 0.40
            }
        }
    },
    factors = {
        government_policy = {
            tax_rates = {low = 0.15, medium = 0.25, high = 0.35},
            interest_rates = {low = 0.01, medium = 0.05, high = 0.10},
            regulation_level = {low = 0.05, medium = 0.15, high = 0.30}
        },
        global_events = {
            {
                name = "Trade War",
                probability = 0.1,
                duration = 90,
                effects = {stock_market = -0.15, imports = -0.30}
            },
            {
                name = "Tech Innovation",
                probability = 0.05,
                duration = 180,
                effects = {tech_stocks = 0.40, productivity = 0.20}
            },
            {
                name = "Natural Disaster",
                probability = 0.03,
                duration = 30,
                effects = {insurance_stocks = 0.20, construction = 0.30, overall_market = -0.10}
            }
        }
    }
}

-- Banking & Finance
Config.Banking = {
    business_loans = {
        enabled = true,
        interest_rates = {
            startup = 0.08, -- 8%
            expansion = 0.06, -- 6%
            equipment = 0.05, -- 5%
            real_estate = 0.04 -- 4%
        },
        max_loan_amounts = {
            startup = 500000,
            expansion = 2000000,
            equipment = 1000000,
            real_estate = 10000000
        },
        requirements = {
            credit_score_min = 650,
            business_plan = true,
            collateral_ratio = 0.3 -- 30% collateral required
        }
    },
    investment_banking = {
        ipo_services = true,
        merger_acquisition = true,
        corporate_bonds = true,
        fees = {
            ipo = 0.05, -- 5% of raised capital
            ma_advisory = 0.02, -- 2% of deal value
            bond_underwriting = 0.01 -- 1% of bond value
        }
    }
}

-- Cryptocurrency System
Config.Cryptocurrency = {
    enabled = true,
    currencies = {
        ["BTC"] = {
            name = "Bitcoin",
            symbol = "BTC",
            initial_price = 45000,
            volatility = 0.05,
            mining_difficulty = "high",
            transaction_fee = 0.001
        },
        ["ETH"] = {
            name = "Ethereum",
            symbol = "ETH",
            initial_price = 3000,
            volatility = 0.06,
            mining_difficulty = "medium",
            transaction_fee = 0.002
        },
        ["LSC"] = {
            name = "Los Santos Coin",
            symbol = "LSC",
            initial_price = 1.50,
            volatility = 0.10,
            mining_difficulty = "low",
            transaction_fee = 0.0001
        }
    },
    mining = {
        enabled = true,
        equipment_cost = {
            basic = 50000,
            advanced = 200000,
            industrial = 1000000
        },
        electricity_cost = 0.15, -- per kWh
        mining_pools = {
            "LS Mining Pool",
            "Pacific Standard Pool",
            "Vinewood Miners"
        }
    },
    exchanges = {
        {
            name = "LS Crypto Exchange",
            coords = vector3(-1082.3, -247.7, 37.8),
            trading_fee = 0.002,
            supported_currencies = {"BTC", "ETH", "LSC"}
        }
    }
}

-- Market Analytics
Config.Analytics = {
    enabled = true,
    reports = {
        daily_market_summary = true,
        business_performance = true,
        economic_indicators = true,
        sector_analysis = true
    },
    indicators = {
        "gdp_growth",
        "inflation_rate",
        "unemployment_rate",
        "consumer_confidence",
        "business_investment",
        "government_spending"
    }
}

-- Language
Config.Lang = {
    ['stock_purchased'] = 'Purchased %s shares of %s at $%s per share',
    ['stock_sold'] = 'Sold %s shares of %s at $%s per share',
    ['business_purchased'] = 'Business purchased successfully!',
    ['business_revenue'] = 'Daily revenue: $%s (Profit: $%s)',
    ['supply_order_placed'] = 'Supply order placed - Delivery in %s minutes',
    ['loan_approved'] = 'Business loan approved: $%s at %s%% interest',
    ['economic_update'] = 'Economic cycle changed to: %s',
    ['dividend_received'] = 'Dividend received: $%s from %s',
    ['market_crash'] = 'Market crash detected - Prices falling rapidly!',
    ['market_rally'] = 'Market rally in progress - Prices rising!',
    ['crypto_mined'] = 'Successfully mined %s %s',
    ['insufficient_funds'] = 'Insufficient funds for this transaction',
}

-- Export alias (moved to end after all Config sections defined)
LS_ECONOMY = LS_ECONOMY or {}
LS_ECONOMY.StockMarket = Config.StockMarket
LS_ECONOMY.Businesses = Config.Businesses
LS_ECONOMY.SupplyChain = Config.SupplyChain
LS_ECONOMY.EconomicSimulation = Config.EconomicSimulation
LS_ECONOMY.Banking = Config.Banking
LS_ECONOMY.Cryptocurrency = Config.Cryptocurrency
LS_ECONOMY.Analytics = Config.Analytics
LS_ECONOMY.Lang = Config.Lang
return LS_ECONOMY