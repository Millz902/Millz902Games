Config = {}

-- Debug mode
Config.Debug = false

-- Framework
Config.Framework = 'qb-core'

-- Database settings
Config.DatabasePrefix = 'ls_social_'

-- System Settings
Config.SocialSystem = {
    enabled = true,
    requireVerification = false,
    maxPostLength = 280,
    maxCaptionLength = 500,
    maxBioLength = 150,
    postCooldown = 30, -- seconds
    dailyPostLimit = 50,
    mediaUploadEnabled = true,
    liveStreamingEnabled = true,
    storiesEnabled = true,
    dmEnabled = true
}

-- Social Platforms
Config.Platforms = {
    {
        id = 1,
        name = "LifeInvader",
        description = "Connect with friends and share your life",
        type = "general",
        icon = "lifeinvader.png",
        color = "#1877F2",
        features = {
            posts = true,
            photos = true,
            videos = true,
            stories = true,
            live_streaming = true,
            groups = true,
            pages = true,
            marketplace = true
        },
        monetization = {
            enabled = true,
            min_followers = 1000,
            revenue_per_view = 0.001,
            revenue_per_like = 0.005,
            sponsorship_enabled = true
        }
    },
    {
        id = 2,
        name = "Snapmatic",
        description = "Share moments through photos and videos",
        type = "photo_video",
        icon = "snapmatic.png",
        color = "#FFFC00",
        features = {
            posts = true,
            photos = true,
            videos = true,
            stories = true,
            filters = true,
            effects = true,
            disappearing_messages = true
        },
        monetization = {
            enabled = true,
            min_followers = 500,
            revenue_per_view = 0.002,
            revenue_per_like = 0.003,
            sponsorship_enabled = true
        }
    },
    {
        id = 3,
        name = "Chirp",
        description = "Share thoughts in real-time",
        type = "microblog",
        icon = "chirp.png",
        color = "#1DA1F2",
        features = {
            posts = true,
            photos = true,
            videos = false,
            stories = false,
            trending_topics = true,
            hashtags = true,
            retweets = true
        },
        monetization = {
            enabled = true,
            min_followers = 2000,
            revenue_per_view = 0.0005,
            revenue_per_like = 0.002,
            sponsorship_enabled = true
        }
    },
    {
        id = 4,
        name = "VineStream",
        description = "Short-form video content",
        type = "short_video",
        icon = "vinestream.png",
        color = "#FF0050",
        features = {
            posts = false,
            photos = false,
            videos = true,
            stories = false,
            effects = true,
            music_sync = true,
            duets = true,
            challenges = true
        },
        monetization = {
            enabled = true,
            min_followers = 10000,
            revenue_per_view = 0.003,
            revenue_per_like = 0.01,
            sponsorship_enabled = true,
            creator_fund = true
        }
    }
}

-- Content Categories
Config.ContentCategories = {
    lifestyle = {
        name = "Lifestyle",
        hashtags = {"#lifestyle", "#daily", "#vibes", "#aesthetic"},
        trending_bonus = 1.2
    },
    automotive = {
        name = "Automotive",
        hashtags = {"#cars", "#racing", "#tuning", "#showoff"},
        trending_bonus = 1.5
    },
    fashion = {
        name = "Fashion",
        hashtags = {"#fashion", "#style", "#outfit", "#trendy"},
        trending_bonus = 1.3
    },
    food = {
        name = "Food & Dining",
        hashtags = {"#food", "#restaurant", "#cooking", "#yummy"},
        trending_bonus = 1.1
    },
    travel = {
        name = "Travel",
        hashtags = {"#travel", "#adventure", "#explore", "#vacation"},
        trending_bonus = 1.4
    },
    business = {
        name = "Business",
        hashtags = {"#business", "#entrepreneur", "#success", "#work"},
        trending_bonus = 1.2
    },
    entertainment = {
        name = "Entertainment",
        hashtags = {"#fun", "#party", "#music", "#entertainment"},
        trending_bonus = 1.6
    },
    fitness = {
        name = "Fitness",
        hashtags = {"#fitness", "#workout", "#health", "#gym"},
        trending_bonus = 1.3
    },
    crime = {
        name = "Street Life",
        hashtags = {"#streets", "#hustle", "#gang", "#respect"},
        trending_bonus = 1.8,
        police_attention = true
    }
}

-- Influencer System
Config.InfluencerSystem = {
    tiers = {
        {
            name = "Nano Influencer",
            min_followers = 100,
            max_followers = 999,
            benefits = {
                verified_badge = false,
                custom_username = false,
                analytics = "basic",
                monetization = false,
                brand_deals = false
            }
        },
        {
            name = "Micro Influencer",
            min_followers = 1000,
            max_followers = 9999,
            benefits = {
                verified_badge = true,
                custom_username = true,
                analytics = "detailed",
                monetization = true,
                brand_deals = true,
                promotion_boost = 1.2
            }
        },
        {
            name = "Mid-Tier Influencer",
            min_followers = 10000,
            max_followers = 99999,
            benefits = {
                verified_badge = true,
                custom_username = true,
                analytics = "advanced",
                monetization = true,
                brand_deals = true,
                promotion_boost = 1.5,
                creator_studio = true
            }
        },
        {
            name = "Macro Influencer",
            min_followers = 100000,
            max_followers = 999999,
            benefits = {
                verified_badge = true,
                custom_username = true,
                analytics = "premium",
                monetization = true,
                brand_deals = true,
                promotion_boost = 2.0,
                creator_studio = true,
                priority_support = true
            }
        },
        {
            name = "Celebrity",
            min_followers = 1000000,
            max_followers = 999999999,
            benefits = {
                verified_badge = true,
                custom_username = true,
                analytics = "enterprise",
                monetization = true,
                brand_deals = true,
                promotion_boost = 3.0,
                creator_studio = true,
                priority_support = true,
                exclusive_features = true
            }
        }
    },
    brand_deals = {
        {
            brand = "Redwood Cigarettes",
            category = "lifestyle",
            min_followers = 5000,
            payment_per_post = 2500,
            requirements = {"18+", "smoking_content"},
            duration = 30 -- days
        },
        {
            brand = "Benefactor Motors",
            category = "automotive",
            min_followers = 10000,
            payment_per_post = 5000,
            requirements = {"car_content", "luxury_lifestyle"},
            duration = 60
        },
        {
            brand = "Clucking Bell",
            category = "food",
            min_followers = 2000,
            payment_per_post = 1000,
            requirements = {"food_content"},
            duration = 14
        },
        {
            brand = "eCola",
            category = "lifestyle",
            min_followers = 15000,
            payment_per_post = 3000,
            requirements = {"youth_content", "active_lifestyle"},
            duration = 45
        }
    }
}

-- Viral Trends System
Config.TrendsSystem = {
    trending_algorithm = {
        engagement_weight = 0.4, -- likes, comments, shares
        velocity_weight = 0.3, -- speed of engagement
        recency_weight = 0.2, -- how recent the content is
        diversity_weight = 0.1 -- variety of users engaging
    },
    hashtag_trends = {
        update_interval = 300, -- 5 minutes
        max_trending = 10,
        min_posts_required = 50,
        trend_duration = 3600 -- 1 hour minimum
    },
    viral_thresholds = {
        nano = {views = 1000, engagement = 100},
        micro = {views = 10000, engagement = 500},
        viral = {views = 100000, engagement = 5000},
        mega_viral = {views = 1000000, engagement = 50000}
    },
    challenges = {
        {
            name = "Car Show Challenge",
            hashtag = "#CarShowChallenge",
            description = "Show off your ride",
            reward = 5000,
            duration = 7, -- days
            category = "automotive"
        },
        {
            name = "Fashion Week LS",
            hashtag = "#FashionWeekLS",
            description = "Best outfit wins",
            reward = 3000,
            duration = 5,
            category = "fashion"
        },
        {
            name = "Street Photography",
            hashtag = "#StreetPhotoLS",
            description = "Capture the city's essence",
            reward = 2000,
            duration = 10,
            category = "lifestyle"
        }
    }
}

-- Content Creation Tools
Config.ContentTools = {
    photo_filters = {
        {name = "Vintage", effect = "sepia", popularity = 85},
        {name = "Black & White", effect = "grayscale", popularity = 75},
        {name = "Vibrant", effect = "saturate", popularity = 90},
        {name = "Retro", effect = "vintage", popularity = 70},
        {name = "Neon", effect = "neon", popularity = 80},
        {name = "Cinematic", effect = "cinema", popularity = 85}
    },
    video_effects = {
        {name = "Slow Motion", effect = "slowmo", cost = 100},
        {name = "Time Lapse", effect = "timelapse", cost = 150},
        {name = "Transition", effect = "transition", cost = 200},
        {name = "Color Grading", effect = "color", cost = 250}
    },
    music_library = {
        {name = "Chill Vibes", genre = "chill", royalty_free = true},
        {name = "Party Beats", genre = "electronic", royalty_free = true},
        {name = "Street Sound", genre = "hip_hop", royalty_free = true},
        {name = "Rock Anthem", genre = "rock", royalty_free = true},
        {name = "Jazz Lounge", genre = "jazz", royalty_free = true}
    }
}

-- Stories System
Config.StoriesSystem = {
    enabled = true,
    duration = 86400, -- 24 hours
    max_stories_per_day = 10,
    viewer_tracking = true,
    story_highlights = true,
    interactive_elements = {
        polls = true,
        questions = true,
        stickers = true,
        location_tags = true,
        mentions = true
    }
}

-- Live Streaming
Config.LiveStreaming = {
    enabled = true,
    min_followers = 500,
    max_duration = 7200, -- 2 hours
    viewer_limit = 1000,
    monetization = {
        donations = true,
        super_chat = true,
        subscriber_only_chat = true
    },
    moderation = {
        auto_moderation = true,
        chat_filters = true,
        viewer_timeout = true,
        viewer_ban = true
    }
}

-- Analytics & Insights
Config.Analytics = {
    metrics = {
        "reach", "impressions", "engagement", "profile_visits",
        "website_clicks", "follower_growth", "demographics",
        "best_posting_times", "content_performance"
    },
    reporting_periods = {"24h", "7d", "30d", "90d"},
    competitor_analysis = true,
    hashtag_performance = true,
    audience_insights = true
}

-- Monetization
Config.Monetization = {
    ad_revenue = {
        enabled = true,
        min_followers = 1000,
        revenue_per_1000_views = 2.5,
        revenue_per_1000_impressions = 1.0,
        payout_threshold = 100
    },
    creator_fund = {
        enabled = true,
        min_followers = 10000,
        monthly_budget = 50000,
        performance_based = true
    },
    sponsorships = {
        enabled = true,
        platform_fee = 0.15, -- 15%
        escrow_system = true,
        dispute_resolution = true
    },
    premium_subscriptions = {
        enabled = true,
        monthly_cost = 99,
        benefits = {
            "ad_free_experience",
            "exclusive_content",
            "early_access",
            "premium_filters",
            "advanced_analytics"
        }
    }
}

-- Moderation System
Config.Moderation = {
    auto_moderation = {
        enabled = true,
        profanity_filter = true,
        spam_detection = true,
        harassment_detection = true,
        copyright_detection = true
    },
    reporting_system = {
        enabled = true,
        categories = {
            "spam", "harassment", "hate_speech", "violence",
            "inappropriate_content", "copyright", "fake_news", "other"
        },
        auto_action_threshold = 5, -- reports
        moderator_review = true
    },
    penalties = {
        warning = {action = "warning", duration = 0},
        content_removal = {action = "remove_content", duration = 0},
        temporary_restriction = {action = "restrict", duration = 86400}, -- 24 hours
        temporary_suspension = {action = "suspend", duration = 604800}, -- 7 days
        permanent_ban = {action = "ban", duration = -1}
    }
}

-- Economy Integration
Config.Economy = {
    post_costs = {
        standard_post = 0,
        promoted_post = 500,
        sponsored_post = 1000,
        premium_features = 100
    },
    earning_opportunities = {
        viral_bonus = 1000, -- for going viral
        trending_bonus = 500, -- for trending content
        engagement_milestone = 250, -- per milestone reached
        follower_milestone = 1000 -- per follower milestone
    },
    marketplace_integration = {
        enabled = true,
        commission_rate = 0.05, -- 5%
        seller_verification = true,
        buyer_protection = true
    }
}

-- Notifications
Config.Notifications = {
    new_follower = "You have a new follower: %s",
    new_like = "%s liked your post",
    new_comment = "%s commented on your post: '%s'",
    new_share = "%s shared your post",
    trending_content = "Your post is trending! 🔥",
    viral_content = "Your post went viral! 🚀",
    brand_deal_offer = "New brand deal offer from %s",
    milestone_reached = "Congratulations! You reached %s followers",
    live_stream_started = "%s is now live!",
    story_view = "%s viewed your story",
    mention = "%s mentioned you in a post"
}

-- Privacy Settings
Config.Privacy = {
    default_settings = {
        profile_visibility = "public", -- public, friends, private
        post_visibility = "public",
        story_visibility = "public",
        allow_mentions = true,
        allow_tags = true,
        show_online_status = true,
        show_read_receipts = true
    },
    data_protection = {
        data_retention = 2592000, -- 30 days for deleted content
        data_export = true,
        data_deletion = true,
        consent_management = true
    }
}

-- Discord Webhooks
Config.Webhooks = {
    enabled = true,
    viral_content = "", -- Add your webhook URL
    trending_posts = "", -- Add your webhook URL
    new_influencers = "", -- Add your webhook URL
    platform_stats = "", -- Add your webhook URL
    moderation_actions = "" -- Add your webhook URL
}

-- Integration
Config.Integration = {
    phone_app = true, -- Social media app for qb-phone
    business_pages = true,
    event_promotion = true,
    real_estate_listings = true,
    job_postings = true,
    marketplace_integration = true,
    news_feed = true
}

LS_SOCIAL = LS_SOCIAL or {}
LS_SOCIAL.Platforms = Config.Platforms
LS_SOCIAL.ContentCategories = Config.ContentCategories
LS_SOCIAL.InfluencerSystem = Config.InfluencerSystem
LS_SOCIAL.TrendsSystem = Config.TrendsSystem
LS_SOCIAL.ContentTools = Config.ContentTools
LS_SOCIAL.StoriesSystem = Config.StoriesSystem
LS_SOCIAL.LiveStreaming = Config.LiveStreaming
LS_SOCIAL.Analytics = Config.Analytics
LS_SOCIAL.Monetization = Config.Monetization
LS_SOCIAL.Moderation = Config.Moderation
LS_SOCIAL.Economy = Config.Economy
LS_SOCIAL.Notifications = Config.Notifications
LS_SOCIAL.Privacy = Config.Privacy
LS_SOCIAL.Webhooks = Config.Webhooks
LS_SOCIAL.Integration = Config.Integration
return LS_SOCIAL