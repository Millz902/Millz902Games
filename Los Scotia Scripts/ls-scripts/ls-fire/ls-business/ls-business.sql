-- Los Scotia Business System Database Schema
-- This file contains all required tables for the ls-business system

-- Player businesses table
CREATE TABLE IF NOT EXISTS `player_businesses` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `business_id` varchar(50) NOT NULL,
    `business_name` varchar(255) NOT NULL,
    `business_type` varchar(100) NOT NULL,
    `balance` int(11) NOT NULL DEFAULT 0,
    `daily_cost` int(11) NOT NULL DEFAULT 500,
    `daily_revenue` int(11) NOT NULL DEFAULT 0,
    `employees` longtext DEFAULT NULL,
    `settings` longtext DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_business` (`business_id`),
    KEY `citizenid` (`citizenid`),
    KEY `business_type` (`business_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Business employees table
CREATE TABLE IF NOT EXISTS `business_employees` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `citizenid` varchar(50) NOT NULL,
    `position` varchar(100) NOT NULL DEFAULT 'employee',
    `salary` int(11) NOT NULL DEFAULT 1000,
    `permissions` longtext DEFAULT NULL,
    `hired_date` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    KEY `citizenid` (`citizenid`),
    FOREIGN KEY (`business_id`) REFERENCES `player_businesses` (`business_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Business transactions table
CREATE TABLE IF NOT EXISTS `business_transactions` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `type` enum('income','expense','purchase','sale') NOT NULL,
    `amount` int(11) NOT NULL,
    `description` varchar(255) NOT NULL,
    `employee_id` varchar(50) DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    KEY `type` (`type`),
    KEY `created_at` (`created_at`),
    FOREIGN KEY (`business_id`) REFERENCES `player_businesses` (`business_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Business stock/inventory table
CREATE TABLE IF NOT EXISTS `business_stock` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `business_id` varchar(50) NOT NULL,
    `item_name` varchar(100) NOT NULL,
    `quantity` int(11) NOT NULL DEFAULT 0,
    `cost_price` decimal(10,2) NOT NULL DEFAULT 0.00,
    `sell_price` decimal(10,2) NOT NULL DEFAULT 0.00,
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `business_id` (`business_id`),
    KEY `item_name` (`item_name`),
    FOREIGN KEY (`business_id`) REFERENCES `player_businesses` (`business_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;