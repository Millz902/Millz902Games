-- Los Scotia Housing System Database Schema
-- This file contains all required tables for the ls-housing system

-- Main houses table
CREATE TABLE IF NOT EXISTS `houses` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(50) NOT NULL,
    `label` varchar(255) NOT NULL,
    `price` int(11) NOT NULL DEFAULT 0,
    `coords` longtext DEFAULT NULL,
    `tier` int(11) NOT NULL DEFAULT 1,
    `garage` longtext DEFAULT NULL,
    `decorations` longtext DEFAULT NULL,
    `shell` varchar(50) DEFAULT NULL,
    `owned` tinyint(1) NOT NULL DEFAULT 0,
    `locked` tinyint(1) NOT NULL DEFAULT 1,
    `for_sale` tinyint(1) NOT NULL DEFAULT 1,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`),
    KEY `owned` (`owned`),
    KEY `for_sale` (`for_sale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- House rentals table (this is the missing table causing the error)
CREATE TABLE IF NOT EXISTS `house_rentals` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `house_id` int(11) NOT NULL,
    `tenant_identifier` varchar(50) NOT NULL,
    `landlord_identifier` varchar(50) NOT NULL,
    `rent_amount` int(11) NOT NULL DEFAULT 0,
    `rent_due` bigint(20) NOT NULL,
    `deposit` int(11) NOT NULL DEFAULT 0,
    `lease_start` timestamp NOT NULL DEFAULT current_timestamp(),
    `lease_end` timestamp NULL DEFAULT NULL,
    `status` enum('active','expired','terminated') NOT NULL DEFAULT 'active',
    `auto_renew` tinyint(1) NOT NULL DEFAULT 1,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `house_id` (`house_id`),
    KEY `tenant_identifier` (`tenant_identifier`),
    KEY `landlord_identifier` (`landlord_identifier`),
    KEY `rent_due` (`rent_due`),
    KEY `status` (`status`),
    FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- House keys table
CREATE TABLE IF NOT EXISTS `house_keys` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `house_id` int(11) NOT NULL,
    `identifier` varchar(50) NOT NULL,
    `access_level` enum('owner','tenant','guest','emergency') NOT NULL DEFAULT 'guest',
    `granted_by` varchar(50) NOT NULL,
    `granted_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `expires_at` timestamp NULL DEFAULT NULL,
    `revoked` tinyint(1) NOT NULL DEFAULT 0,
    `revoked_at` timestamp NULL DEFAULT NULL,
    `revoked_by` varchar(50) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `house_id` (`house_id`),
    KEY `identifier` (`identifier`),
    KEY `access_level` (`access_level`),
    KEY `revoked` (`revoked`),
    FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- House furniture/decorations table
CREATE TABLE IF NOT EXISTS `house_furniture` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `house_id` int(11) NOT NULL,
    `item_name` varchar(100) NOT NULL,
    `coords` longtext NOT NULL,
    `rotation` longtext DEFAULT NULL,
    `metadata` longtext DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `house_id` (`house_id`),
    KEY `item_name` (`item_name`),
    FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- House storage/stash table
CREATE TABLE IF NOT EXISTS `house_stash` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `house_id` int(11) NOT NULL,
    `stash_id` varchar(50) NOT NULL,
    `items` longtext DEFAULT NULL,
    `capacity` int(11) NOT NULL DEFAULT 100,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_house_stash` (`house_id`, `stash_id`),
    KEY `house_id` (`house_id`),
    KEY `stash_id` (`stash_id`),
    FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- House utilities table (for bills, electricity, water, etc.)
CREATE TABLE IF NOT EXISTS `house_utilities` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `house_id` int(11) NOT NULL,
    `utility_type` enum('electricity','water','gas','internet','security') NOT NULL,
    `usage_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
    `cost_per_unit` decimal(10,2) NOT NULL DEFAULT 0.00,
    `bill_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
    `billing_period_start` timestamp NOT NULL,
    `billing_period_end` timestamp NOT NULL,
    `due_date` timestamp NOT NULL,
    `paid` tinyint(1) NOT NULL DEFAULT 0,
    `paid_at` timestamp NULL DEFAULT NULL,
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `house_id` (`house_id`),
    KEY `utility_type` (`utility_type`),
    KEY `due_date` (`due_date`),
    KEY `paid` (`paid`),
    FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- House garage table
CREATE TABLE IF NOT EXISTS `house_garages` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `house_id` int(11) NOT NULL,
    `garage_name` varchar(100) NOT NULL,
    `coords` longtext NOT NULL,
    `spawn_coords` longtext NOT NULL,
    `capacity` int(11) NOT NULL DEFAULT 2,
    `type` enum('small','medium','large','underground') NOT NULL DEFAULT 'small',
    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
    `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
    PRIMARY KEY (`id`),
    KEY `house_id` (`house_id`),
    KEY `garage_name` (`garage_name`),
    FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert some sample house data if needed
INSERT IGNORE INTO `houses` (`id`, `identifier`, `label`, `price`, `coords`, `tier`, `garage`, `shell`, `owned`, `locked`, `for_sale`) VALUES
(1, 'house_1', 'Grove Street House', 50000, '{"x": -9.96, "y": -1438.54, "z": 31.1, "h": 180.0}', 1, '{"x": -6.43, "y": -1456.18, "z": 30.45, "h": 142.2}', 'shell_ranch', 0, 1, 1),
(2, 'house_2', 'Vinewood Hills Mansion', 250000, '{"x": 1273.9, "y": -1729.08, "z": 54.77, "h": 21.83}', 3, '{"x": 1295.48, "y": -1739.85, "z": 54.28, "h": 111.5}', 'shell_mansion', 0, 1, 1),
(3, 'house_3', 'Mirror Park Family Home', 85000, '{"x": 1060.59, "y": -378.65, "z": 68.23, "h": 183.5}', 2, '{"x": 1069.43, "y": -391.58, "z": 67.86, "h": 269.3}', 'shell_trevor', 0, 1, 1);