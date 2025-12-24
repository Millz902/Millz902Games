Config = {}

-- Bank Branches & Locations
Config.Banks = {
    ["pacific_standard"] = {
        name = "Pacific Standard Bank",
        coords = vector3(150.23, -1040.52, 29.37),
        heading = 340.0,
        type = "main_branch",
        vault_location = vector3(255.23, 225.46, 102.69),
        safe_deposit_boxes = 500,
        business_services = true,
        investment_services = true,
        loan_office = true,
        atm_network = "pacific_standard",
        operating_hours = {open = 8, close = 17}, -- 8 AM to 5 PM
        security_level = "maximum"
    },
    ["fleeca_downtown"] = {
        name = "Fleeca Bank Downtown",
        coords = vector3(147.04, -1035.77, 29.34),
        heading = 340.0,
        type = "branch",
        vault_location = vector3(148.56, -1044.72, 29.35),
        safe_deposit_boxes = 200,
        business_services = true,
        investment_services = false,
        loan_office = false,
        atm_network = "fleeca",
        operating_hours = {open = 9, close = 16},
        security_level = "high"
    },
    ["fleeca_great_ocean"] = {
        name = "Fleeca Bank Great Ocean",
        coords = vector3(-2962.71, 482.04, 15.70),
        heading = 358.54,
        type = "branch",
        vault_location = vector3(-2956.13, 481.45, 15.70),
        safe_deposit_boxes = 150,
        business_services = false,
        investment_services = false,
        loan_office = false,
        atm_network = "fleeca",
        operating_hours = {open = 9, close = 16},
        security_level = "medium"
    },
    ["blaine_county_savings"] = {
        name = "Blaine County Savings Bank",
        coords = vector3(-112.20, 6470.03, 31.63),
        heading = 135.0,
        type = "regional",
        vault_location = vector3(-109.45, 6464.12, 31.63),
        safe_deposit_boxes = 100,
        business_services = true,
        investment_services = false,
        loan_office = true,
        atm_network = "blaine_county",
        operating_hours = {open = 8, close = 17},
        security_level = "medium"
    }
}

-- Account Types & Features
Config.AccountTypes = {
    ["basic_checking"] = {
        name = "Basic Checking Account",
        minimum_balance = 100,
        monthly_fee = 25,
        overdraft_protection = false,
        debit_card_included = true,
        check_writing = true,
        online_banking = true,
        mobile_deposit = false,
        atm_fee_reimbursement = 0,
        interest_rate = 0.001, -- 0.1% APY
        transaction_limit_daily = 5000,
        withdrawal_limit_daily = 1000
    },
    ["premium_checking"] = {
        name = "Premium Checking Account",
        minimum_balance = 2500,
        monthly_fee = 0, -- waived with minimum balance
        overdraft_protection = true,
        debit_card_included = true,
        check_writing = true,
        online_banking = true,
        mobile_deposit = true,
        atm_fee_reimbursement = 25, -- per month
        interest_rate = 0.005, -- 0.5% APY
        transaction_limit_daily = 25000,
        withdrawal_limit_daily = 5000,
        personal_banker = true
    },
    ["business_checking"] = {
        name = "Business Checking Account",
        minimum_balance = 5000,
        monthly_fee = 50,
        overdraft_protection = true,
        debit_card_included = true,
        check_writing = true,
        online_banking = true,
        mobile_deposit = true,
        atm_fee_reimbursement = 50,
        interest_rate = 0.003, -- 0.3% APY
        transaction_limit_daily = 100000,
        withdrawal_limit_daily = 25000,
        business_services = true,
        payroll_processing = true
    },
    ["savings_account"] = {
        name = "High-Yield Savings Account",
        minimum_balance = 1000,
        monthly_fee = 10,
        overdraft_protection = false,
        debit_card_included = false,
        check_writing = false,
        online_banking = true,
        mobile_deposit = true,
        atm_fee_reimbursement = 0,
        interest_rate = 0.025, -- 2.5% APY
        transaction_limit_daily = 10000,
        withdrawal_limit_monthly = 6, -- federal regulation
        compound_frequency = "monthly"
    },
    ["investment_account"] = {
        name = "Investment Account",
        minimum_balance = 10000,
        monthly_fee = 100,
        overdraft_protection = false,
        debit_card_included = false,
        check_writing = false,
        online_banking = true,
        mobile_deposit = false,
        atm_fee_reimbursement = 0,
        interest_rate = 0.0, -- market dependent
        transaction_limit_daily = 1000000,
        investment_options = true,
        financial_advisor = true,
        portfolio_management = true
    }
}

-- Loan Products & Services
Config.LoanProducts = {
    ["personal_loan"] = {
        name = "Personal Loan",
        minimum_amount = 5000,
        maximum_amount = 100000,
        interest_rate_range = {0.08, 0.25}, -- 8% to 25% APR
        term_options = {12, 24, 36, 48, 60}, -- months
        origination_fee = 0.02, -- 2% of loan amount
        credit_score_required = 600,
        income_verification = true,
        collateral_required = false,
        approval_time = 24, -- hours
        uses = {"debt_consolidation", "home_improvement", "emergency", "other"}
    },
    ["auto_loan"] = {
        name = "Auto Loan",
        minimum_amount = 15000,
        maximum_amount = 500000,
        interest_rate_range = {0.04, 0.15}, -- 4% to 15% APR
        term_options = {24, 36, 48, 60, 72, 84},
        origination_fee = 0.01,
        credit_score_required = 650,
        income_verification = true,
        collateral_required = true, -- vehicle
        approval_time = 12,
        new_vs_used_rates = {new = 0.04, used = 0.06},
        down_payment_minimum = 0.10 -- 10%
    },
    ["mortgage_loan"] = {
        name = "Mortgage Loan",
        minimum_amount = 200000,
        maximum_amount = 5000000,
        interest_rate_range = {0.035, 0.08}, -- 3.5% to 8% APR
        term_options = {180, 240, 300, 360}, -- months (15, 20, 25, 30 years)
        origination_fee = 0.005,
        credit_score_required = 720,
        income_verification = true,
        collateral_required = true, -- property
        approval_time = 168, -- 7 days
        down_payment_minimum = 0.20, -- 20%
        property_appraisal_required = true,
        mortgage_insurance = true
    },
    ["business_loan"] = {
        name = "Business Loan",
        minimum_amount = 25000,
        maximum_amount = 2000000,
        interest_rate_range = {0.06, 0.20}, -- 6% to 20% APR
        term_options = {12, 24, 36, 60, 84, 120},
        origination_fee = 0.015,
        credit_score_required = 680,
        income_verification = true,
        collateral_required = true,
        approval_time = 72, -- 3 days
        business_plan_required = true,
        financial_statements_required = true,
        sba_guaranteed_options = true
    },
    ["line_of_credit"] = {
        name = "Personal Line of Credit",
        minimum_amount = 10000,
        maximum_amount = 250000,
        interest_rate_range = {0.10, 0.30}, -- 10% to 30% APR (variable)
        term_options = {0}, -- revolving credit
        origination_fee = 0.0,
        credit_score_required = 700,
        income_verification = true,
        collateral_required = false,
        approval_time = 6, -- hours
        draw_period = 60, -- months
        repayment_period = 120 -- months
    }
}

-- Investment Products
Config.InvestmentProducts = {
    ["certificates_of_deposit"] = {
        name = "Certificates of Deposit (CDs)",
        minimum_investment = 5000,
        maximum_investment = 1000000,
        term_options = {3, 6, 12, 24, 36, 60}, -- months
        interest_rates = {
            [3] = 0.015,  -- 3 months: 1.5% APY
            [6] = 0.020,  -- 6 months: 2.0% APY
            [12] = 0.030, -- 12 months: 3.0% APY
            [24] = 0.035, -- 24 months: 3.5% APY
            [36] = 0.040, -- 36 months: 4.0% APY
            [60] = 0.045  -- 60 months: 4.5% APY
        },
        early_withdrawal_penalty = 0.10, -- 10% of interest earned
        compound_frequency = "quarterly",
        fdic_insured = true
    },
    ["money_market"] = {
        name = "Money Market Account",
        minimum_investment = 10000,
        maximum_investment = 5000000,
        interest_rate = 0.022, -- 2.2% APY (variable)
        transaction_limit_monthly = 6,
        check_writing_allowed = true,
        debit_card_access = true,
        tiered_interest_rates = {
            {min = 10000, max = 49999, rate = 0.020},
            {min = 50000, max = 99999, rate = 0.022},
            {min = 100000, max = 499999, rate = 0.025},
            {min = 500000, max = 999999, rate = 0.028},
            {min = 1000000, max = 9999999, rate = 0.030}
        }
    },
    ["mutual_funds"] = {
        name = "Mutual Funds",
        minimum_investment = 2500,
        maximum_investment = 10000000,
        fund_options = {
            conservative = {
                name = "Conservative Growth Fund",
                expected_return = 0.04, -- 4% annually
                risk_level = "low",
                expense_ratio = 0.008 -- 0.8%
            },
            moderate = {
                name = "Balanced Fund",
                expected_return = 0.07, -- 7% annually
                risk_level = "medium",
                expense_ratio = 0.012 -- 1.2%
            },
            aggressive = {
                name = "Growth Fund",
                expected_return = 0.10, -- 10% annually
                risk_level = "high",
                expense_ratio = 0.015 -- 1.5%
            },
            index = {
                name = "Market Index Fund",
                expected_return = 0.08, -- 8% annually
                risk_level = "medium",
                expense_ratio = 0.005 -- 0.5%
            }
        },
        redemption_fee = 0.02, -- 2% if held less than 90 days
        dividend_reinvestment = true
    },
    ["retirement_accounts"] = {
        name = "Retirement Accounts (IRA/401k)",
        minimum_investment = 1000,
        maximum_investment = 100000, -- annual contribution limit
        account_types = {
            traditional_ira = {
                tax_deductible = true,
                tax_deferred_growth = true,
                early_withdrawal_penalty = 0.10,
                required_distributions_age = 65
            },
            roth_ira = {
                tax_deductible = false,
                tax_free_growth = true,
                early_withdrawal_penalty = 0.10,
                required_distributions_age = 0 -- none
            }
        },
        investment_options = {"mutual_funds", "cds", "money_market"},
        employer_matching = true, -- for 401k
        vesting_schedule = true
    }
}

-- ATM Network & Services
Config.ATMNetwork = {
    locations = {
        -- Downtown Los Santos
        {coords = vector3(147.04, -1035.77, 29.34), network = "fleeca", type = "bank_attached"},
        {coords = vector3(285.79, -1282.48, 29.64), network = "fleeca", type = "standalone"},
        {coords = vector3(-303.23, -829.27, 32.42), network = "pacific_standard", type = "standalone"},
        {coords = vector3(-721.23, -415.67, 34.98), network = "fleeca", type = "standalone"},
        {coords = vector3(-1315.73, -834.89, 16.96), network = "pacific_standard", type = "convenience_store"},
        
        -- Vinewood & Hills
        {coords = vector3(374.23, 329.45, 103.57), network = "fleeca", type = "standalone"},
        {coords = vector3(-846.23, -341.67, 38.68), network = "pacific_standard", type = "standalone"},
        
        -- Sandy Shores & Paleto Bay
        {coords = vector3(1968.12, 3743.45, 32.34), network = "blaine_county", type = "standalone"},
        {coords = vector3(-112.20, 6470.03, 31.63), network = "blaine_county", type = "bank_attached"},
        {coords = vector3(155.89, 6642.12, 31.60), network = "fleeca", type = "standalone"}
    },
    transaction_fees = {
        same_network = 0,
        different_network = 5,
        international = 15,
        balance_inquiry = 0
    },
    daily_limits = {
        withdrawal = 2500,
        deposit = 25000,
        transfer = 10000,
        balance_inquiries = 50
    },
    services = {
        cash_withdrawal = true,
        cash_deposit = true,
        balance_inquiry = true,
        mini_statement = true,
        transfer_funds = true,
        bill_payment = true,
        mobile_top_up = false,
        check_deposit = false -- bank ATMs only
    }
}

-- Credit System & Scoring
Config.CreditSystem = {
    score_ranges = {
        excellent = {750, 850},
        very_good = {700, 749},
        good = {650, 699},
        fair = {600, 649},
        poor = {300, 599}
    },
    score_factors = {
        payment_history = 0.35, -- 35% weight
        credit_utilization = 0.30, -- 30% weight
        length_of_credit_history = 0.15, -- 15% weight
        credit_mix = 0.10, -- 10% weight
        new_credit_inquiries = 0.10 -- 10% weight
    },
    score_calculation = {
        starting_score = 650,
        on_time_payment_bonus = 5, -- per month
        late_payment_penalty = -25, -- per occurrence
        high_utilization_penalty = -10, -- if >30% utilization
        low_utilization_bonus = 2, -- if <10% utilization
        new_account_bonus = 10, -- for credit mix
        hard_inquiry_penalty = -5, -- per inquiry
        max_score_change_monthly = 25
    },
    credit_building_programs = {
        secured_credit_card = {
            deposit_required = 1000,
            credit_limit_ratio = 1.0, -- 100% of deposit
            graduation_period = 12, -- months
            annual_fee = 50
        },
        credit_builder_loan = {
            loan_amount = 5000,
            term_months = 24,
            interest_rate = 0.08,
            funds_held_until_paid = true
        }
    }
}

-- Mobile & Online Banking
Config.DigitalBanking = {
    mobile_app_features = {
        account_balance = true,
        transaction_history = true,
        fund_transfers = true,
        bill_pay = true,
        mobile_deposit = true,
        card_controls = true,
        budget_tracking = true,
        financial_insights = true,
        investment_tracking = true,
        loan_management = true,
        appointment_scheduling = true,
        customer_support_chat = true
    },
    online_banking_features = {
        account_management = true,
        detailed_statements = true,
        tax_document_access = true,
        wire_transfers = true,
        stop_payment_requests = true,
        account_alerts = true,
        recurring_transfers = true,
        investment_research = true,
        loan_applications = true,
        document_upload = true
    },
    security_features = {
        two_factor_authentication = true,
        biometric_login = true,
        device_registration = true,
        transaction_alerts = true,
        account_lockout = true,
        fraud_monitoring = true,
        secure_messaging = true,
        session_timeout = 15 -- minutes
    }
}

-- Business Banking Services
Config.BusinessBanking = {
    account_types = {
        small_business = {
            minimum_balance = 2500,
            monthly_fee = 25,
            transaction_limit = 200,
            cash_management = "basic"
        },
        commercial = {
            minimum_balance = 25000,
            monthly_fee = 100,
            transaction_limit = 1000,
            cash_management = "advanced"
        },
        corporate = {
            minimum_balance = 100000,
            monthly_fee = 500,
            transaction_limit = 9999,
            cash_management = "enterprise"
        }
    },
    services = {
        payroll_processing = {
            setup_fee = 500,
            per_employee_fee = 15,
            direct_deposit = true,
            tax_filing = true
        },
        merchant_services = {
            card_processing = true,
            pos_systems = true,
            online_payments = true,
            mobile_payments = true,
            processing_rate = 0.025 -- 2.5%
        },
        cash_management = {
            armored_car_service = true,
            coin_counting = true,
            currency_exchange = true,
            safe_deposit_boxes = true
        },
        trade_finance = {
            letters_of_credit = true,
            documentary_collections = true,
            export_financing = true,
            foreign_exchange = true
        }
    }
}

-- Wealth Management
Config.WealthManagement = {
    minimum_assets = 1000000, -- $1M minimum for private banking
    services = {
        private_banking = {
            dedicated_banker = true,
            priority_service = true,
            exclusive_products = true,
            estate_planning = true
        },
        investment_advisory = {
            portfolio_management = true,
            financial_planning = true,
            tax_optimization = true,
            retirement_planning = true
        },
        trust_services = {
            revocable_trusts = true,
            irrevocable_trusts = true,
            charitable_trusts = true,
            estate_administration = true
        },
        insurance_services = {
            life_insurance = true,
            disability_insurance = true,
            umbrella_policies = true,
            long_term_care = true
        }
    },
    fee_structure = {
        asset_management_fee = 0.01, -- 1% annually
        financial_planning_fee = 5000, -- one-time
        trust_administration_fee = 0.005, -- 0.5% annually
        estate_planning_fee = 10000 -- one-time
    }
}

-- Security & Fraud Prevention
Config.Security = {
    fraud_detection = {
        transaction_monitoring = true,
        velocity_checking = true,
        geographic_analysis = true,
        merchant_category_analysis = true,
        device_fingerprinting = true
    },
    security_measures = {
        encryption_level = "256_bit",
        secure_communication = true,
        regular_security_audits = true,
        employee_background_checks = true,
        physical_security = "maximum"
    },
    incident_response = {
        fraud_alert_system = true,
        card_blocking = true,
        account_freezing = true,
        law_enforcement_cooperation = true,
        customer_notification = true
    },
    compliance = {
        bank_secrecy_act = true,
        anti_money_laundering = true,
        know_your_customer = true,
        suspicious_activity_reporting = true,
        privacy_protection = true
    }
}

-- Customer Service
Config.CustomerService = {
    channels = {
        phone_support = {
            hours = "24/7",
            average_wait_time = 3, -- minutes
            first_call_resolution_rate = 0.85
        },
        online_chat = {
            hours = "24/7",
            average_response_time = 30, -- seconds
            ai_assistance = true
        },
        email_support = {
            response_time = 24, -- hours
            resolution_time = 72 -- hours
        },
        in_person = {
            hours = "business_hours",
            appointment_scheduling = true,
            walk_in_service = true
        }
    },
    service_levels = {
        basic_customer = {
            phone_priority = "standard",
            dedicated_support = false,
            premium_hours = false
        },
        premium_customer = {
            phone_priority = "high",
            dedicated_support = true,
            premium_hours = true
        },
        private_banking = {
            phone_priority = "immediate",
            dedicated_support = true,
            premium_hours = true,
            concierge_services = true
        }
    }
}

-- Regulatory Compliance
Config.Compliance = {
    deposit_insurance = {
        fdic_insured = true,
        coverage_limit = 250000, -- per depositor per bank
        joint_account_coverage = 500000
    },
    reporting_requirements = {
        currency_transaction_reports = 10000, -- amounts $10K+
        suspicious_activity_reports = true,
        large_cash_transactions = true,
        international_wire_transfers = true
    },
    privacy_regulations = {
        customer_data_protection = true,
        opt_out_information_sharing = true,
        secure_data_disposal = true,
        privacy_notice_requirements = true
    },
    lending_regulations = {
        truth_in_lending = true,
        fair_credit_reporting = true,
        equal_credit_opportunity = true,
        real_estate_settlement_procedures = true
    }
}

-- Integration Settings
Config.Integration = {
    qb_management = {
        boss_menu_integration = true,
        society_accounts = true,
        payroll_automation = true,
        business_expense_tracking = true
    },
    phone_integration = {
        banking_app = true,
        mobile_payments = true,
        account_notifications = true,
        transaction_alerts = true
    },
    government_integration = {
        tax_collection = true,
        government_payments = true,
        business_licensing_fees = true,
        court_ordered_payments = true
    },
    real_estate_integration = {
        mortgage_processing = true,
        escrow_services = true,
        property_tax_collection = true,
        hoa_payments = true
    }
}