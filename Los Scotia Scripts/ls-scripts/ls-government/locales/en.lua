-- Los Scotia Government System - Localization File
-- English (US) translations for government interface

local Translations = {
    -- System and Interface
    system = {
        title = "Los Scotia City Government",
        version = "Government Management System v2.1",
        loading = "Loading...",
        saving = "Saving...",
        saved = "Saved successfully",
        error = "An error occurred",
        success = "Operation completed successfully",
        warning = "Warning",
        info = "Information",
        confirm = "Confirm",
        cancel = "Cancel",
        close = "Close",
        submit = "Submit",
        save = "Save",
        edit = "Edit",
        delete = "Delete",
        add = "Add",
        view = "View",
        manage = "Manage",
        search = "Search",
        filter = "Filter",
        refresh = "Refresh",
        print = "Print",
        download = "Download",
        email = "Email",
        back = "Back",
        next = "Next",
        previous = "Previous",
        continue = "Continue",
        help = "Help",
        about = "About",
        support = "Support",
        logout = "Logout"
    },

    -- Header and Navigation
    header = {
        current_user = "Current User",
        current_date = "Date",
        current_time = "Time",
        welcome_back = "Welcome back, %s",
        logout_confirm = "Are you sure you want to logout?",
        city_logo_alt = "Los Scotia City Seal"
    },

    navigation = {
        dashboard = "Dashboard",
        mayor = "Mayor's Office",
        council = "City Council",
        departments = "Departments",
        services = "Public Services",
        permits = "Permits & Licenses",
        budget = "City Budget",
        elections = "Elections",
        planning = "City Planning"
    },

    -- Dashboard
    dashboard = {
        title = "Government Dashboard",
        city_stats = "City Statistics",
        population = "City Population",
        budget = "City Budget",
        pending_permits = "Pending Permits",
        active_issues = "Active Issues",
        recent_activity = "Recent Activity",
        upcoming_events = "Upcoming Events",
        refreshing = "Refreshing dashboard data...",
        refreshed = "Dashboard data refreshed successfully",
        activity = {
            new_application = "New %s Application",
            meeting_scheduled = "%s Meeting Scheduled",
            budget_approved = "Budget Amendment Approved",
            permit_issued = "Permit Issued",
            election_created = "Election Created",
            service_updated = "Service Updated"
        }
    },

    -- Mayor's Office
    mayor = {
        title = "Mayor's Office",
        current_mayor = "Mayor Alexandra Rivera",
        mayor_title = "Mayor of Los Scotia",
        term = "Term: 2024 - 2028",
        phone = "Phone",
        email = "Email",
        schedule_appointment = "Schedule Appointment",
        initiatives = "Mayor's Initiatives",
        schedule = "Mayor's Schedule",
        meeting_with = "Meeting with %s",
        press_conference = "Press Conference",
        community_event = "Community Event",
        initiatives_list = {
            green_city = "Green Los Scotia 2025",
            infrastructure = "Infrastructure Modernization",
            economic_development = "Economic Development",
            public_safety = "Public Safety Enhancement"
        },
        appointment_form = {
            full_name = "Full Name",
            organization = "Organization",
            purpose = "Purpose of Meeting",
            preferred_date = "Preferred Date",
            preferred_time = "Preferred Time",
            submit_request = "Submit Request",
            request_submitted = "Appointment request submitted successfully"
        }
    },

    -- City Council
    council = {
        title = "City Council",
        members = "Council Members",
        president = "Council President",
        vice_president = "Vice President",
        councilman = "Councilman",
        councilwoman = "Councilwoman",
        district = "District %d",
        schedule_meeting = "Schedule Meeting",
        meeting_minutes = "Meeting Minutes",
        upcoming_meetings = "Upcoming Meetings",
        recent_votes = "Recent Votes",
        agenda_items = "Agenda Items",
        passed = "PASSED",
        failed = "FAILED",
        unanimous = "unanimous",
        approval = "approval",
        meeting_types = {
            regular = "Regular Meeting",
            special = "Special Meeting",
            emergency = "Emergency Meeting",
            work_session = "Work Session"
        },
        meeting_form = {
            title = "Meeting Title",
            type = "Meeting Type",
            date = "Date",
            time = "Time",
            location = "Location",
            agenda = "Agenda Items",
            schedule_success = "Council meeting scheduled successfully"
        }
    },

    -- Departments
    departments = {
        title = "City Departments",
        add_department = "Add Department",
        view_department = "View Department",
        manage_department = "Manage Department",
        department_reports = "Department Reports",
        police = "Police Department",
        fire = "Fire Department",
        medical = "EMS Department",
        public_works = "Public Works",
        parks = "Parks & Recreation",
        planning = "Planning & Zoning",
        officers = "Officers",
        personnel = "Personnel",
        vehicles = "Vehicles",
        stations = "Stations",
        ambulances = "Ambulances",
        workers = "Workers",
        projects = "Projects",
        facilities = "Facilities",
        programs = "Programs",
        applications = "Applications",
        calls_24h = "Calls (24h)",
        budget_allocated = "Budget Allocated",
        staff_count = "Staff Count",
        department_form = {
            name = "Department Name",
            director = "Director/Chief",
            budget = "Annual Budget",
            description = "Description",
            icon_class = "Icon Class",
            create_success = "New department created successfully"
        }
    },

    -- Public Services
    services = {
        title = "Public Services",
        add_service = "Add Service",
        manage_service = "Manage Service",
        service_reports = "Service Reports",
        assign_staff = "Assign Staff",
        categories = {
            housing = "Housing Services",
            transportation = "Transportation",
            environmental = "Environmental",
            community = "Community"
        },
        housing_services = {
            assistance = "Housing Assistance Program",
            code_enforcement = "Code Enforcement",
            tax_assessment = "Property Tax Assessment"
        },
        transportation_services = {
            public_transit = "Public Transit",
            traffic_management = "Traffic Management",
            parking = "Parking Services"
        },
        environmental_services = {
            waste_management = "Waste Management",
            water_sewer = "Water & Sewer",
            environmental = "Environmental Protection"
        },
        community_services = {
            library = "Library Services",
            senior = "Senior Services",
            youth = "Youth Programs"
        },
        service_form = {
            name = "Service Name",
            category = "Category",
            description = "Description",
            budget = "Monthly Budget",
            create_success = "New service created successfully"
        }
    },

    -- Permits and Licenses
    permits = {
        title = "Permits & Licenses",
        new_application = "New Application",
        search_permits = "Search Permits",
        pending_applications = "Pending Applications",
        approved = "Approved",
        denied = "Denied",
        expired = "Expired",
        application_number = "Application #",
        permit_type = "Type",
        applicant = "Applicant",
        property_address = "Property Address",
        submit_date = "Submit Date",
        status = "Status",
        actions = "Actions",
        review = "Review",
        permit_types = {
            building = "Building Permits",
            business = "Business Licenses",
            event = "Event Permits",
            sign = "Sign Permits"
        },
        statuses = {
            pending = "Pending Review",
            in_review = "In Review",
            approved = "Approved",
            denied = "Denied",
            expired = "Expired"
        },
        application_form = {
            type = "Permit Type",
            name = "Applicant Name",
            address = "Property Address",
            description = "Project Description",
            cost = "Estimated Cost",
            submit_success = "Permit application submitted successfully"
        },
        review_form = {
            notes = "Review Notes",
            approve = "Approve",
            request_info = "Request More Info",
            deny = "Deny",
            decision_required = "Please make a decision on this permit"
        },
        search_form = {
            permit_id = "Permit ID",
            applicant_name = "Applicant Name",
            address = "Property Address",
            type = "Permit Type",
            status = "Status",
            all_types = "All Types",
            all_status = "All Status"
        }
    },

    -- Budget
    budget = {
        title = "City Budget",
        overview = "Budget Overview",
        generate_report = "Generate Report",
        new_proposal = "New Proposal",
        fiscal_year = "FY %d Budget Overview",
        total_revenue = "Total Revenue",
        total_expenditures = "Total Expenditures",
        net_balance = "Net Balance",
        allocation = "Budget Allocation",
        department_budgets = "Department Budgets",
        allocated = "Allocated",
        spent = "Spent",
        remaining = "Remaining",
        percent_used = "% Used",
        budget_status = {
            on_track = "On Track",
            warning = "Over Budget",
            critical = "Critical"
        },
        proposal_form = {
            title = "Proposal Title",
            department = "Department",
            amount = "Proposed Amount",
            justification = "Justification",
            timeline = "Implementation Timeline",
            submit_success = "Budget proposal submitted successfully"
        },
        report = {
            generating = "Generating budget report...",
            generated = "Budget report generated successfully",
            name = "Report Name",
            size = "File Size",
            generated_time = "Generated"
        }
    },

    -- Elections
    elections = {
        title = "Elections",
        create_election = "Create Election",
        upcoming = "Upcoming Elections",
        voter_registration = "Voter Registration",
        past_elections = "Past Elections",
        manage_election = "Manage Election",
        registered_voters = "Registered Voters",
        new_registrations = "New Registrations (30 days)",
        eligible_registered = "Eligible Population Registered",
        registration_deadline = "Registration Deadline",
        early_voting = "Early Voting",
        election_date = "Election Date",
        positions = "Positions",
        winner = "Winner",
        turnout = "Turnout",
        voters = "voters",
        election_types = {
            mayor = "Mayoral Election",
            council = "City Council Election",
            referendum = "Referendum",
            special = "Special Election"
        },
        election_form = {
            title = "Election Title",
            type = "Election Type",
            date = "Election Date",
            registration_deadline = "Registration Deadline",
            early_start = "Early Voting Start",
            early_end = "Early Voting End",
            create_success = "Election created successfully"
        },
        management_tabs = {
            candidates = "Candidates",
            voters = "Voters",
            results = "Results",
            settings = "Settings"
        }
    },

    -- City Planning
    planning = {
        title = "City Planning",
        new_project = "New Project",
        zoning_map = "Zoning Map",
        active_projects = "Active Projects",
        zoning_info = "Zoning Information",
        planning_applications = "Planning Applications",
        project_status = {
            planning = "Planning",
            in_progress = "In Progress",
            completed = "Completed",
            on_hold = "On Hold"
        },
        project_types = {
            development = "Development",
            infrastructure = "Infrastructure",
            park = "Park/Recreation",
            zoning = "Zoning Change"
        },
        zoning_types = {
            residential = "Residential (R1, R2, R3)",
            commercial = "Commercial (C1, C2)",
            industrial = "Industrial (I1, I2)",
            mixed_use = "Mixed Use (MU)"
        },
        project_form = {
            name = "Project Name",
            type = "Project Type",
            location = "Location",
            budget = "Estimated Budget",
            description = "Description",
            timeline = "Expected Timeline",
            create_success = "Planning project created successfully"
        },
        application_types = {
            subdivision = "Subdivision",
            rezoning = "Rezoning",
            variance = "Variance",
            conditional_use = "Conditional Use"
        }
    },

    -- Time and Dates
    time = {
        days = {
            monday = "Monday",
            tuesday = "Tuesday",
            wednesday = "Wednesday",
            thursday = "Thursday",
            friday = "Friday",
            saturday = "Saturday",
            sunday = "Sunday"
        },
        months = {
            january = "January",
            february = "February",
            march = "March",
            april = "April",
            may = "May",
            june = "June",
            july = "July",
            august = "August",
            september = "September",
            october = "October",
            november = "November",
            december = "December"
        },
        ago = {
            just_now = "Just now",
            minute_ago = "1 minute ago",
            minutes_ago = "%d minutes ago",
            hour_ago = "1 hour ago",
            hours_ago = "%d hours ago",
            day_ago = "1 day ago",
            days_ago = "%d days ago",
            week_ago = "1 week ago",
            weeks_ago = "%d weeks ago"
        }
    },

    -- Forms and Validation
    forms = {
        required_field = "This field is required",
        invalid_email = "Please enter a valid email address",
        invalid_phone = "Please enter a valid phone number",
        invalid_date = "Please enter a valid date",
        invalid_number = "Please enter a valid number",
        password_mismatch = "Passwords do not match",
        file_too_large = "File size is too large",
        invalid_file_type = "Invalid file type",
        form_incomplete = "Please complete all required fields",
        form_submitted = "Form submitted successfully",
        form_error = "Error submitting form. Please try again."
    },

    -- Notifications and Messages
    notifications = {
        welcome = "Welcome to the Los Scotia Government System",
        session_timeout = "Your session will expire in %d minutes",
        session_expired = "Your session has expired. Please log in again.",
        data_saved = "Data saved successfully",
        data_error = "Error saving data. Please try again.",
        permission_denied = "You do not have permission to perform this action",
        feature_unavailable = "This feature is currently unavailable",
        maintenance_mode = "The system is in maintenance mode. Please try again later.",
        update_available = "A system update is available",
        backup_completed = "System backup completed successfully",
        report_generated = "Report generated successfully",
        email_sent = "Email sent successfully",
        print_success = "Document sent to printer",
        export_success = "Data exported successfully",
        import_success = "Data imported successfully",
        sync_completed = "Data synchronization completed"
    },

    -- Error Messages
    errors = {
        general = "An unexpected error occurred",
        network = "Network connection error",
        timeout = "Request timed out",
        not_found = "Requested resource not found",
        unauthorized = "You are not authorized to access this resource",
        forbidden = "Access to this resource is forbidden",
        server_error = "Internal server error",
        database_error = "Database connection error",
        file_not_found = "File not found",
        invalid_request = "Invalid request",
        data_corruption = "Data corruption detected",
        quota_exceeded = "Storage quota exceeded",
        rate_limit = "Too many requests. Please try again later.",
        validation_failed = "Data validation failed",
        duplicate_entry = "Duplicate entry detected"
    },

    -- Help and Support
    help = {
        title = "Government System Help",
        keyboard_shortcuts = "Keyboard Shortcuts",
        navigation_help = "Navigation",
        data_management = "Data Management",
        shortcuts = {
            dashboard = "Go to Dashboard",
            refresh = "Refresh current section",
            save = "Save data",
            close_modal = "Close modal",
            search = "Search",
            new_item = "Create new item"
        },
        navigation_text = "Use the navigation bar at the top to switch between different government sections. Each section contains relevant tools and information for city administration.",
        data_text = "The system automatically saves data every 5 minutes. You can also manually save using Ctrl+S or the save button in each section.",
        contact_support = "For technical support, contact the IT Department at ext. 1234 or email support@losscotia.gov"
    },

    -- Support and Contact
    support = {
        title = "Contact Technical Support",
        ticket_submitted = "Support ticket submitted successfully. Ticket #%s",
        categories = {
            login = "Login Issues",
            data = "Data Problems",
            performance = "Performance Issues",
            bug = "Bug Report",
            feature = "Feature Request",
            other = "Other"
        },
        priority_levels = {
            low = "Low",
            medium = "Medium",
            high = "High",
            urgent = "Urgent"
        },
        form = {
            category = "Issue Category",
            subject = "Subject",
            description = "Description",
            priority = "Priority",
            submit_ticket = "Submit Ticket",
            describe_issue = "Please describe the issue in detail..."
        }
    },

    -- Footer
    footer = {
        copyright = "© %d City of Los Scotia. All rights reserved.",
        version_info = "Los Scotia Government Management System v%s",
        links = {
            help = "Help",
            about = "About",
            support = "Support",
            privacy = "Privacy Policy",
            terms = "Terms of Use"
        }
    },

    -- About Information
    about = {
        title = "About Los Scotia Government System",
        version = "Version",
        build_date = "Build Date",
        developer = "Developer",
        features_title = "Features",
        features = {
            administration = "Comprehensive city administration",
            departments = "Department management",
            permits = "Permit and license processing",
            budget = "Budget tracking and reporting",
            elections = "Election management",
            planning = "City planning tools"
        }
    },

    -- Accessibility
    accessibility = {
        skip_navigation = "Skip to main content",
        close_modal = "Close modal dialog",
        open_menu = "Open navigation menu",
        sort_ascending = "Sort ascending",
        sort_descending = "Sort descending",
        loading_content = "Loading content",
        required_field = "Required field",
        optional_field = "Optional field",
        current_page = "Current page",
        page_navigation = "Page navigation",
        search_results = "Search results"
    }
}

return Translations