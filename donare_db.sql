-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Apr 05, 2026 at 09:48 AM
-- Server version: 8.4.7
-- PHP Version: 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `donare_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
CREATE TABLE IF NOT EXISTS `admins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `name`, `email`, `password`, `created_at`) VALUES
(1, 'Admin', 'admin@gmail.com', '$2y$10$s14m0QCvjvd4otjYkeCvjOV0Ocs0rgc8nqWYMEtDC5XpjwhhjkgRK', '2026-03-10 04:25:36');

-- --------------------------------------------------------

--
-- Table structure for table `campaigns`
--

DROP TABLE IF EXISTS `campaigns`;
CREATE TABLE IF NOT EXISTS `campaigns` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `ngo_id` int NOT NULL,
  `category` enum('Education','Environment','Humanitarian','Energy','Health') NOT NULL,
  `goal` decimal(12,2) NOT NULL,
  `raised` decimal(12,2) DEFAULT '0.00',
  `donors` int DEFAULT '0',
  `days_left` int DEFAULT '30',
  `image_url` varchar(500) DEFAULT NULL,
  `description` text,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ngo_id` (`ngo_id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `campaigns`
--

INSERT INTO `campaigns` (`id`, `title`, `ngo_id`, `category`, `goal`, `raised`, `donors`, `days_left`, `image_url`, `description`, `is_active`, `created_at`) VALUES
(1, 'Clean Water Wells for 20 Rural Schools', 1, 'Environment', 45000.00, 28450.00, 12, 38, 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80', 'Install clean water wells and filtration systems in 20 rural schools across Malaysia, providing safe drinking water to over 5,000 students daily.', 1, '2026-04-02 13:54:33'),
(2, 'Borneo Rainforest Restoration 2026', 2, 'Environment', 65000.00, 42300.00, 18, 45, 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&q=80', 'Plant 80,000 native trees across 40 hectares of degraded rainforest in Borneo, restoring critical wildlife habitat and combating climate change.', 1, '2026-04-02 13:54:33'),
(3, 'Emergency Food Relief - East Coast Floods', 3, 'Humanitarian', 32000.00, 19800.00, 15, 28, 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800&q=80', 'Provide emergency food rations to 800 families affected by recent flooding in Kelantan and Terengganu. Each pack includes 10 days of essential supplies.', 1, '2026-04-02 13:54:33'),
(4, 'Girls STEM Education Scholarship 2026', 4, 'Education', 58000.00, 31200.00, 22, 52, 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800&q=80', 'Award 100 scholarships to underprivileged girls pursuing STEM subjects in secondary school, covering tuition, books, uniforms, and tutoring support.', 1, '2026-04-02 13:54:33'),
(5, 'Solar Panels for 15 Rural Clinics', 5, 'Energy', 48000.00, 26700.00, 14, 41, 'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800&q=80', 'Equip 15 rural health clinics with solar panel systems, ensuring uninterrupted electricity for medical equipment and refrigeration of vaccines.', 1, '2026-04-02 13:54:33'),
(6, 'Youth Mental Health Hotline & Counselling', 6, 'Health', 38000.00, 18900.00, 11, 35, 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=800&q=80', 'Launch a 24/7 mental health hotline with trained counsellors and provide free therapy sessions for 500 young people aged 15-25.', 1, '2026-04-02 13:54:33'),
(7, 'Community Water Purification Stations', 1, 'Environment', 52000.00, 14700.00, 9, 60, 'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=800&q=80', 'Build 8 community water purification stations in underserved villages, providing access to clean drinking water for 4,200 residents.', 1, '2026-04-02 13:54:33'),
(8, 'Coastal Mangrove Replanting Initiative', 2, 'Environment', 41000.00, 22100.00, 13, 33, 'https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=800&q=80', 'Plant 50,000 mangrove saplings along 12km of coastline to protect fishing communities from erosion and restore marine ecosystems.', 1, '2026-04-02 13:54:33'),
(9, 'Urban Nutrition Program for Low-Income Families', 3, 'Humanitarian', 35000.00, 21400.00, 16, 30, 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=800&q=80', 'Provide weekly nutrition-balanced food baskets to 300 low-income urban families in Kuala Lumpur and Johor Bahru for 6 months.', 1, '2026-04-02 13:54:33');

-- --------------------------------------------------------

--
-- Table structure for table `donations`
--

DROP TABLE IF EXISTS `donations`;
CREATE TABLE IF NOT EXISTS `donations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `receipt_id` varchar(50) NOT NULL,
  `user_id` int DEFAULT NULL,
  `donor_name` varchar(100) NOT NULL,
  `donor_email` varchar(150) NOT NULL,
  `campaign_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('Completed','Pending','Failed') DEFAULT 'Completed',
  `donated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `donor_phone` varchar(30) DEFAULT NULL,
  `donor_address` text,
  `payment_method` varchar(30) DEFAULT NULL,
  `payment_details` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `receipt_id` (`receipt_id`),
  KEY `campaign_id` (`campaign_id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=132 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `donations`
--

INSERT INTO `donations` (`id`, `receipt_id`, `user_id`, `donor_name`, `donor_email`, `campaign_id`, `amount`, `status`, `donated_at`, `donor_phone`, `donor_address`, `payment_method`, `payment_details`) VALUES
(1, 'DNR-1001', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 1, 2500.00, 'Completed', '2026-03-28 04:45:00', '+60123456789', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****4532\",\"cardExpiry\":\"12/25\"}'),
(2, 'DNR-1002', 2, 'Nurul Aisyah', 'nurul.aisyah@email.com', 1, 1800.00, 'Completed', '2026-03-29 09:00:00', '+60123456790', 'Penang', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Nurul Aisyah\"}'),
(3, 'DNR-1003', 3, 'David Tan', 'david.tan@email.com', 1, 3200.00, 'Completed', '2026-03-30 04:15:00', '+60123456791', 'Johor Bahru', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****8765\",\"cardExpiry\":\"06/26\"}'),
(4, 'DNR-1004', 4, 'Priya Kumar', 'priya.kumar@email.com', 1, 2100.00, 'Completed', '2026-03-31 10:50:00', '+60123456792', 'Ipoh', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Priya Kumar\"}'),
(5, 'DNR-1005', 5, 'Michael Wong', 'michael.wong@email.com', 1, 4500.00, 'Completed', '2026-04-01 05:40:00', '+60123456793', 'Melaka', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****2134\",\"cardExpiry\":\"09/27\"}'),
(6, 'DNR-1006', 6, 'Fatimah Hassan', 'fatimah.hassan@email.com', 1, 3800.00, 'Completed', '2026-04-01 08:15:00', '+60123456794', 'Kota Kinabalu', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Fatimah Hassan\"}'),
(7, 'DNR-1007', 7, 'Jonathan Lee', 'jonathan.lee@email.com', 1, 2900.00, 'Completed', '2026-04-02 03:00:00', '+60123456795', 'Kuching', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****6543\",\"cardExpiry\":\"03/26\"}'),
(8, 'DNR-1008', 8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', 1, 1750.00, 'Completed', '2026-04-02 04:30:00', '+60123456796', 'Shah Alam', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Siti Nurhaliza\"}'),
(9, 'DNR-1009', 9, 'Daniel Chen', 'daniel.chen@email.com', 1, 2400.00, 'Completed', '2026-04-02 06:50:00', '+60123456797', 'Petaling Jaya', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****9876\",\"cardExpiry\":\"11/25\"}'),
(10, 'DNR-1010', 10, 'Aisha Abdullah', 'aisha.abdullah@email.com', 1, 1950.00, 'Completed', '2026-04-02 08:45:00', '+60123456798', 'Seremban', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Aisha Abdullah\"}'),
(11, 'DNR-1011', 11, 'Ryan Lim', 'ryan.lim@email.com', 1, 1500.00, 'Completed', '2026-04-02 10:00:00', '+60123456799', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****3421\",\"cardExpiry\":\"08/26\"}'),
(12, 'DNR-1012', 12, 'Zainab Ismail', 'zainab.ismail@email.com', 1, 1000.00, 'Completed', '2026-04-02 11:15:00', '+60123456800', 'Georgetown', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Zainab Ismail\"}'),
(13, 'DNR-1013', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 2, 3500.00, 'Completed', '2026-03-27 05:30:00', '+60123456789', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****4532\",\"cardExpiry\":\"12/25\"}'),
(14, 'DNR-1014', 3, 'David Tan', 'david.tan@email.com', 2, 2800.00, 'Completed', '2026-03-28 07:50:00', '+60123456791', 'Johor Bahru', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"David Tan\"}'),
(15, 'DNR-1015', 5, 'Michael Wong', 'michael.wong@email.com', 2, 4200.00, 'Completed', '2026-03-29 04:00:00', '+60123456793', 'Melaka', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****2134\",\"cardExpiry\":\"09/27\"}'),
(16, 'DNR-1016', 7, 'Jonathan Lee', 'jonathan.lee@email.com', 2, 3100.00, 'Completed', '2026-03-30 09:20:00', '+60123456795', 'Kuching', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Jonathan Lee\"}'),
(17, 'DNR-1017', 9, 'Daniel Chen', 'daniel.chen@email.com', 2, 2900.00, 'Completed', '2026-03-31 04:45:00', '+60123456797', 'Petaling Jaya', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****9876\",\"cardExpiry\":\"11/25\"}'),
(18, 'DNR-1018', 11, 'Ryan Lim', 'ryan.lim@email.com', 2, 3800.00, 'Completed', '2026-04-01 07:10:00', '+60123456799', 'Kuala Lumpur', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Ryan Lim\"}'),
(19, 'DNR-1019', 13, 'James Tan', 'james.tan@email.com', 2, 4500.00, 'Completed', '2026-04-01 09:50:00', '+60123456801', 'Ipoh', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****5678\",\"cardExpiry\":\"04/26\"}'),
(20, 'DNR-1020', 15, 'Kevin Ng', 'kevin.ng@email.com', 2, 3200.00, 'Completed', '2026-04-02 03:40:00', '+60123456803', 'Kota Kinabalu', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Kevin Ng\"}'),
(21, 'DNR-1021', 2, 'Nurul Aisyah', 'nurul.aisyah@email.com', 2, 2600.00, 'Completed', '2026-04-02 06:00:00', '+60123456790', 'Penang', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****8765\",\"cardExpiry\":\"06/26\"}'),
(22, 'DNR-1022', 4, 'Priya Kumar', 'priya.kumar@email.com', 2, 3100.00, 'Completed', '2026-04-02 07:45:00', '+60123456792', 'Ipoh', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Priya Kumar\"}'),
(23, 'DNR-1023', 6, 'Fatimah Hassan', 'fatimah.hassan@email.com', 2, 2900.00, 'Completed', '2026-04-02 09:20:00', '+60123456794', 'Kota Kinabalu', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****6543\",\"cardExpiry\":\"03/26\"}'),
(24, 'DNR-1024', 8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', 2, 2300.00, 'Completed', '2026-04-02 10:50:00', '+60123456796', 'Shah Alam', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Siti Nurhaliza\"}'),
(25, 'DNR-1025', 10, 'Aisha Abdullah', 'aisha.abdullah@email.com', 2, 1800.00, 'Completed', '2026-04-02 11:40:00', '+60123456798', 'Seremban', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****3421\",\"cardExpiry\":\"08/26\"}'),
(26, 'DNR-1026', 12, 'Zainab Ismail', 'zainab.ismail@email.com', 2, 2000.00, 'Completed', '2026-04-02 12:30:00', '+60123456800', 'Georgetown', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Zainab Ismail\"}'),
(27, 'DNR-1027', 14, 'Mariam Yusof', 'mariam.yusof@email.com', 2, 2500.00, 'Completed', '2026-04-02 13:15:00', '+60123456802', 'Kuching', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****1234\",\"cardExpiry\":\"10/26\"}'),
(28, 'DNR-1028', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 2, 1700.00, 'Completed', '2026-04-02 13:50:00', '+60123456789', 'Kuala Lumpur', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Ahmad Rahman\"}'),
(29, 'DNR-1029', 3, 'David Tan', 'david.tan@email.com', 2, 1400.00, 'Completed', '2026-04-02 14:20:00', '+60123456791', 'Johor Bahru', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****4532\",\"cardExpiry\":\"12/25\"}'),
(30, 'DNR-1030', 5, 'Michael Wong', 'michael.wong@email.com', 2, 1600.00, 'Completed', '2026-04-02 14:45:00', '+60123456793', 'Melaka', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Michael Wong\"}'),
(31, 'DNR-1031', 2, 'Nurul Aisyah', 'nurul.aisyah@email.com', 3, 1800.00, 'Completed', '2026-03-26 05:00:00', '+60123456790', 'Penang', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****8765\",\"cardExpiry\":\"06/26\"}'),
(32, 'DNR-1032', 4, 'Priya Kumar', 'priya.kumar@email.com', 3, 2100.00, 'Completed', '2026-03-27 07:15:00', '+60123456792', 'Ipoh', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Priya Kumar\"}'),
(33, 'DNR-1033', 6, 'Fatimah Hassan', 'fatimah.hassan@email.com', 3, 1500.00, 'Completed', '2026-03-28 08:50:00', '+60123456794', 'Kota Kinabalu', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****6543\",\"cardExpiry\":\"03/26\"}'),
(34, 'DNR-1034', 8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', 3, 1900.00, 'Completed', '2026-03-29 03:45:00', '+60123456796', 'Shah Alam', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Siti Nurhaliza\"}'),
(35, 'DNR-1035', 10, 'Aisha Abdullah', 'aisha.abdullah@email.com', 3, 2300.00, 'Completed', '2026-03-30 06:10:00', '+60123456798', 'Seremban', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****3421\",\"cardExpiry\":\"08/26\"}'),
(36, 'DNR-1036', 12, 'Zainab Ismail', 'zainab.ismail@email.com', 3, 1700.00, 'Completed', '2026-03-31 07:55:00', '+60123456800', 'Georgetown', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Zainab Ismail\"}'),
(37, 'DNR-1037', 14, 'Mariam Yusof', 'mariam.yusof@email.com', 3, 2000.00, 'Completed', '2026-04-01 05:20:00', '+60123456802', 'Kuching', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****1234\",\"cardExpiry\":\"10/26\"}'),
(38, 'DNR-1038', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 3, 1400.00, 'Completed', '2026-04-01 08:40:00', '+60123456789', 'Kuala Lumpur', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Ahmad Rahman\"}'),
(39, 'DNR-1039', 3, 'David Tan', 'david.tan@email.com', 3, 1600.00, 'Completed', '2026-04-02 04:00:00', '+60123456791', 'Johor Bahru', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****2134\",\"cardExpiry\":\"09/27\"}'),
(40, 'DNR-1040', 5, 'Michael Wong', 'michael.wong@email.com', 3, 1200.00, 'Completed', '2026-04-02 05:50:00', '+60123456793', 'Melaka', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Michael Wong\"}'),
(41, 'DNR-1041', 7, 'Jonathan Lee', 'jonathan.lee@email.com', 3, 800.00, 'Completed', '2026-04-02 08:10:00', '+60123456795', 'Kuching', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****9876\",\"cardExpiry\":\"11/25\"}'),
(42, 'DNR-1042', 9, 'Daniel Chen', 'daniel.chen@email.com', 3, 1100.00, 'Completed', '2026-04-02 09:45:00', '+60123456797', 'Petaling Jaya', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Daniel Chen\"}'),
(43, 'DNR-1043', 11, 'Ryan Lim', 'ryan.lim@email.com', 3, 900.00, 'Completed', '2026-04-02 11:20:00', '+60123456799', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****5678\",\"cardExpiry\":\"04/26\"}'),
(44, 'DNR-1044', 13, 'James Tan', 'james.tan@email.com', 3, 950.00, 'Completed', '2026-04-02 12:35:00', '+60123456801', 'Ipoh', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"James Tan\"}'),
(45, 'DNR-1045', 15, 'Kevin Ng', 'kevin.ng@email.com', 3, 850.00, 'Completed', '2026-04-02 13:55:00', '+60123456803', 'Kota Kinabalu', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****4532\",\"cardExpiry\":\"12/25\"}'),
(46, 'DNR-1046', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 4, 2200.00, 'Completed', '2026-03-25 04:30:00', '+60123456789', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****4532\",\"cardExpiry\":\"12/25\"}'),
(47, 'DNR-1047', 2, 'Nurul Aisyah', 'nurul.aisyah@email.com', 4, 1800.00, 'Completed', '2026-03-26 06:00:00', '+60123456790', 'Penang', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Nurul Aisyah\"}'),
(48, 'DNR-1048', 3, 'David Tan', 'david.tan@email.com', 4, 2500.00, 'Completed', '2026-03-27 07:45:00', '+60123456791', 'Johor Bahru', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****8765\",\"cardExpiry\":\"06/26\"}'),
(49, 'DNR-1049', 4, 'Priya Kumar', 'priya.kumar@email.com', 4, 1900.00, 'Completed', '2026-03-28 04:10:00', '+60123456792', 'Ipoh', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Priya Kumar\"}'),
(50, 'DNR-1050', 5, 'Michael Wong', 'michael.wong@email.com', 4, 2100.00, 'Completed', '2026-03-29 06:50:00', '+60123456793', 'Melaka', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****2134\",\"cardExpiry\":\"09/27\"}'),
(51, 'DNR-1051', 6, 'Fatimah Hassan', 'fatimah.hassan@email.com', 4, 1600.00, 'Completed', '2026-03-30 09:15:00', '+60123456794', 'Kota Kinabalu', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Fatimah Hassan\"}'),
(52, 'DNR-1052', 7, 'Jonathan Lee', 'jonathan.lee@email.com', 4, 1400.00, 'Completed', '2026-03-31 05:00:00', '+60123456795', 'Kuching', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****6543\",\"cardExpiry\":\"03/26\"}'),
(53, 'DNR-1053', 8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', 4, 1700.00, 'Completed', '2026-04-01 06:20:00', '+60123456796', 'Shah Alam', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Siti Nurhaliza\"}'),
(54, 'DNR-1054', 9, 'Daniel Chen', 'daniel.chen@email.com', 4, 2000.00, 'Completed', '2026-04-01 07:50:00', '+60123456797', 'Petaling Jaya', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****9876\",\"cardExpiry\":\"11/25\"}'),
(55, 'DNR-1055', 10, 'Aisha Abdullah', 'aisha.abdullah@email.com', 4, 1500.00, 'Completed', '2026-04-01 09:40:00', '+60123456798', 'Seremban', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Aisha Abdullah\"}'),
(56, 'DNR-1056', 11, 'Ryan Lim', 'ryan.lim@email.com', 4, 1300.00, 'Completed', '2026-04-02 03:30:00', '+60123456799', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****3421\",\"cardExpiry\":\"08/26\"}'),
(57, 'DNR-1057', 12, 'Zainab Ismail', 'zainab.ismail@email.com', 4, 1100.00, 'Completed', '2026-04-02 05:15:00', '+60123456800', 'Georgetown', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Zainab Ismail\"}'),
(58, 'DNR-1058', 13, 'James Tan', 'james.tan@email.com', 4, 1250.00, 'Completed', '2026-04-02 07:00:00', '+60123456801', 'Ipoh', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****5678\",\"cardExpiry\":\"04/26\"}'),
(59, 'DNR-1059', 14, 'Mariam Yusof', 'mariam.yusof@email.com', 4, 1450.00, 'Completed', '2026-04-02 08:45:00', '+60123456802', 'Kuching', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Mariam Yusof\"}'),
(60, 'DNR-1060', 15, 'Kevin Ng', 'kevin.ng@email.com', 4, 1600.00, 'Completed', '2026-04-02 10:25:00', '+60123456803', 'Kota Kinabalu', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****1234\",\"cardExpiry\":\"10/26\"}'),
(61, 'DNR-1061', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 4, 1350.00, 'Completed', '2026-04-02 11:50:00', '+60123456789', 'Kuala Lumpur', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Ahmad Rahman\"}'),
(62, 'DNR-1062', 2, 'Nurul Aisyah', 'nurul.aisyah@email.com', 4, 1550.00, 'Completed', '2026-04-02 13:10:00', '+60123456790', 'Penang', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****8765\",\"cardExpiry\":\"06/26\"}'),
(63, 'DNR-1063', 3, 'David Tan', 'david.tan@email.com', 4, 1200.00, 'Completed', '2026-04-02 13:45:00', '+60123456791', 'Johor Bahru', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"David Tan\"}'),
(64, 'DNR-1064', 4, 'Priya Kumar', 'priya.kumar@email.com', 4, 1400.00, 'Completed', '2026-04-02 14:30:00', '+60123456792', 'Ipoh', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****2134\",\"cardExpiry\":\"09/27\"}'),
(65, 'DNR-1065', 5, 'Michael Wong', 'michael.wong@email.com', 4, 1150.00, 'Completed', '2026-04-02 15:00:00', '+60123456793', 'Melaka', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Michael Wong\"}'),
(66, 'DNR-1066', 6, 'Fatimah Hassan', 'fatimah.hassan@email.com', 4, 1000.00, 'Completed', '2026-04-02 15:30:00', '+60123456794', 'Kota Kinabalu', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****6543\",\"cardExpiry\":\"03/26\"}'),
(67, 'DNR-1067', 7, 'Jonathan Lee', 'jonathan.lee@email.com', 4, 1050.00, 'Completed', '2026-04-02 15:55:00', '+60123456795', 'Kuching', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Jonathan Lee\"}'),
(68, 'DNR-1068', 8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', 5, 2400.00, 'Completed', '2026-03-24 04:00:00', '+60123456796', 'Shah Alam', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****9876\",\"cardExpiry\":\"11/25\"}'),
(69, 'DNR-1069', 9, 'Daniel Chen', 'daniel.chen@email.com', 5, 2100.00, 'Completed', '2026-03-25 06:15:00', '+60123456797', 'Petaling Jaya', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Daniel Chen\"}'),
(70, 'DNR-1070', 10, 'Aisha Abdullah', 'aisha.abdullah@email.com', 5, 1900.00, 'Completed', '2026-03-26 07:50:00', '+60123456798', 'Seremban', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****3421\",\"cardExpiry\":\"08/26\"}'),
(71, 'DNR-1071', 11, 'Ryan Lim', 'ryan.lim@email.com', 5, 2200.00, 'Completed', '2026-03-27 04:45:00', '+60123456799', 'Kuala Lumpur', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Ryan Lim\"}'),
(72, 'DNR-1072', 12, 'Zainab Ismail', 'zainab.ismail@email.com', 5, 1800.00, 'Completed', '2026-03-28 07:20:00', '+60123456800', 'Georgetown', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****5678\",\"cardExpiry\":\"04/26\"}'),
(73, 'DNR-1073', 13, 'James Tan', 'james.tan@email.com', 5, 2000.00, 'Completed', '2026-03-29 09:00:00', '+60123456801', 'Ipoh', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"James Tan\"}'),
(74, 'DNR-1074', 14, 'Mariam Yusof', 'mariam.yusof@email.com', 5, 1700.00, 'Completed', '2026-03-30 04:10:00', '+60123456802', 'Kuching', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****1234\",\"cardExpiry\":\"10/26\"}'),
(75, 'DNR-1075', 15, 'Kevin Ng', 'kevin.ng@email.com', 5, 2300.00, 'Completed', '2026-03-31 05:50:00', '+60123456803', 'Kota Kinabalu', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Kevin Ng\"}'),
(76, 'DNR-1076', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 5, 1600.00, 'Completed', '2026-04-01 07:40:00', '+60123456789', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****4532\",\"cardExpiry\":\"12/25\"}'),
(77, 'DNR-1077', 2, 'Nurul Aisyah', 'nurul.aisyah@email.com', 5, 1500.00, 'Completed', '2026-04-01 10:05:00', '+60123456790', 'Penang', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Nurul Aisyah\"}'),
(78, 'DNR-1078', 3, 'David Tan', 'david.tan@email.com', 5, 2500.00, 'Completed', '2026-04-02 03:50:00', '+60123456791', 'Johor Bahru', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****8765\",\"cardExpiry\":\"06/26\"}'),
(79, 'DNR-1079', 4, 'Priya Kumar', 'priya.kumar@email.com', 5, 2700.00, 'Completed', '2026-04-02 06:20:00', '+60123456792', 'Ipoh', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Priya Kumar\"}'),
(80, 'DNR-1080', 5, 'Michael Wong', 'michael.wong@email.com', 5, 2600.00, 'Completed', '2026-04-02 08:35:00', '+60123456793', 'Melaka', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****2134\",\"cardExpiry\":\"09/27\"}'),
(81, 'DNR-1081', 6, 'Fatimah Hassan', 'fatimah.hassan@email.com', 5, 2400.00, 'Completed', '2026-04-02 11:00:00', '+60123456794', 'Kota Kinabalu', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Fatimah Hassan\"}'),
(82, 'DNR-1082', 7, 'Jonathan Lee', 'jonathan.lee@email.com', 6, 1900.00, 'Completed', '2026-03-23 04:45:00', '+60123456795', 'Kuching', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****6543\",\"cardExpiry\":\"03/26\"}'),
(83, 'DNR-1083', 8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', 6, 1700.00, 'Completed', '2026-03-24 07:10:00', '+60123456796', 'Shah Alam', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Siti Nurhaliza\"}'),
(84, 'DNR-1084', 9, 'Daniel Chen', 'daniel.chen@email.com', 6, 2100.00, 'Completed', '2026-03-25 08:50:00', '+60123456797', 'Petaling Jaya', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****9876\",\"cardExpiry\":\"11/25\"}'),
(85, 'DNR-1085', 10, 'Aisha Abdullah', 'aisha.abdullah@email.com', 6, 1500.00, 'Completed', '2026-03-26 04:20:00', '+60123456798', 'Seremban', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Aisha Abdullah\"}'),
(86, 'DNR-1086', 11, 'Ryan Lim', 'ryan.lim@email.com', 6, 1800.00, 'Completed', '2026-03-27 06:00:00', '+60123456799', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****3421\",\"cardExpiry\":\"08/26\"}'),
(87, 'DNR-1087', 12, 'Zainab Ismail', 'zainab.ismail@email.com', 6, 2000.00, 'Completed', '2026-03-28 08:15:00', '+60123456800', 'Georgetown', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Zainab Ismail\"}'),
(88, 'DNR-1088', 13, 'James Tan', 'james.tan@email.com', 6, 1600.00, 'Completed', '2026-03-29 04:50:00', '+60123456801', 'Ipoh', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****5678\",\"cardExpiry\":\"04/26\"}'),
(89, 'DNR-1089', 14, 'Mariam Yusof', 'mariam.yusof@email.com', 6, 1400.00, 'Completed', '2026-03-30 06:40:00', '+60123456802', 'Kuching', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Mariam Yusof\"}'),
(90, 'DNR-1090', 15, 'Kevin Ng', 'kevin.ng@email.com', 6, 2200.00, 'Completed', '2026-03-31 09:05:00', '+60123456803', 'Kota Kinabalu', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****1234\",\"cardExpiry\":\"10/26\"}'),
(91, 'DNR-1091', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 6, 1300.00, 'Completed', '2026-04-01 03:45:00', '+60123456789', 'Kuala Lumpur', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Ahmad Rahman\"}'),
(92, 'DNR-1092', 2, 'Nurul Aisyah', 'nurul.aisyah@email.com', 6, 1100.00, 'Completed', '2026-04-02 05:55:00', '+60123456790', 'Penang', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****8765\",\"cardExpiry\":\"06/26\"}'),
(93, 'DNR-1093', 3, 'David Tan', 'david.tan@email.com', 7, 2100.00, 'Completed', '2026-03-22 05:00:00', '+60123456791', 'Johor Bahru', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"David Tan\"}'),
(94, 'DNR-1094', 4, 'Priya Kumar', 'priya.kumar@email.com', 7, 1800.00, 'Completed', '2026-03-23 07:45:00', '+60123456792', 'Ipoh', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****2134\",\"cardExpiry\":\"09/27\"}'),
(95, 'DNR-1095', 5, 'Michael Wong', 'michael.wong@email.com', 7, 2400.00, 'Completed', '2026-03-24 10:10:00', '+60123456793', 'Melaka', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Michael Wong\"}'),
(96, 'DNR-1096', 6, 'Fatimah Hassan', 'fatimah.hassan@email.com', 7, 1600.00, 'Completed', '2026-03-25 03:50:00', '+60123456794', 'Kota Kinabalu', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****6543\",\"cardExpiry\":\"03/26\"}'),
(97, 'DNR-1097', 7, 'Jonathan Lee', 'jonathan.lee@email.com', 7, 1900.00, 'Completed', '2026-03-26 06:20:00', '+60123456795', 'Kuching', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Jonathan Lee\"}'),
(98, 'DNR-1098', 8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', 7, 2200.00, 'Completed', '2026-03-27 08:40:00', '+60123456796', 'Shah Alam', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****9876\",\"cardExpiry\":\"11/25\"}'),
(99, 'DNR-1099', 9, 'Daniel Chen', 'daniel.chen@email.com', 7, 1500.00, 'Completed', '2026-03-28 05:05:00', '+60123456797', 'Petaling Jaya', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Daniel Chen\"}'),
(100, 'DNR-1100', 10, 'Aisha Abdullah', 'aisha.abdullah@email.com', 7, 1700.00, 'Completed', '2026-03-29 07:25:00', '+60123456798', 'Seremban', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****3421\",\"cardExpiry\":\"08/26\"}'),
(101, 'DNR-1101', 11, 'Ryan Lim', 'ryan.lim@email.com', 8, 2000.00, 'Completed', '2026-03-21 04:15:00', '+60123456799', 'Kuala Lumpur', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Ryan Lim\"}'),
(102, 'DNR-1102', 12, 'Zainab Ismail', 'zainab.ismail@email.com', 8, 1800.00, 'Completed', '2026-03-22 05:50:00', '+60123456800', 'Georgetown', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****5678\",\"cardExpiry\":\"04/26\"}'),
(103, 'DNR-1103', 13, 'James Tan', 'james.tan@email.com', 8, 2200.00, 'Completed', '2026-03-23 08:20:00', '+60123456801', 'Ipoh', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"James Tan\"}'),
(104, 'DNR-1104', 14, 'Mariam Yusof', 'mariam.yusof@email.com', 8, 1600.00, 'Completed', '2026-03-24 04:45:00', '+60123456802', 'Kuching', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****1234\",\"cardExpiry\":\"10/26\"}'),
(105, 'DNR-1105', 15, 'Kevin Ng', 'kevin.ng@email.com', 8, 1900.00, 'Completed', '2026-03-25 07:10:00', '+60123456803', 'Kota Kinabalu', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Kevin Ng\"}'),
(106, 'DNR-1106', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 8, 2100.00, 'Completed', '2026-03-26 08:55:00', '+60123456789', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****4532\",\"cardExpiry\":\"12/25\"}'),
(107, 'DNR-1107', 2, 'Nurul Aisyah', 'nurul.aisyah@email.com', 8, 1700.00, 'Completed', '2026-03-27 04:05:00', '+60123456790', 'Penang', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Nurul Aisyah\"}'),
(108, 'DNR-1108', 3, 'David Tan', 'david.tan@email.com', 8, 2300.00, 'Completed', '2026-03-28 06:25:00', '+60123456791', 'Johor Bahru', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****8765\",\"cardExpiry\":\"06/26\"}'),
(109, 'DNR-1109', 4, 'Priya Kumar', 'priya.kumar@email.com', 8, 2000.00, 'Completed', '2026-03-29 07:50:00', '+60123456792', 'Ipoh', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Priya Kumar\"}'),
(110, 'DNR-1110', 5, 'Michael Wong', 'michael.wong@email.com', 8, 2500.00, 'Completed', '2026-03-30 10:15:00', '+60123456793', 'Melaka', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****2134\",\"cardExpiry\":\"09/27\"}'),
(111, 'DNR-1111', 6, 'Fatimah Hassan', 'fatimah.hassan@email.com', 8, 1800.00, 'Completed', '2026-03-31 04:40:00', '+60123456794', 'Kota Kinabalu', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Fatimah Hassan\"}'),
(112, 'DNR-1112', 7, 'Jonathan Lee', 'jonathan.lee@email.com', 8, 1500.00, 'Completed', '2026-04-01 07:00:00', '+60123456795', 'Kuching', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****6543\",\"cardExpiry\":\"03/26\"}'),
(113, 'DNR-1113', 8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', 8, 1400.00, 'Completed', '2026-04-02 09:20:00', '+60123456796', 'Shah Alam', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Siti Nurhaliza\"}'),
(114, 'DNR-1114', 9, 'Daniel Chen', 'daniel.chen@email.com', 9, 1700.00, 'Completed', '2026-03-20 04:50:00', '+60123456797', 'Petaling Jaya', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****9876\",\"cardExpiry\":\"11/25\"}'),
(115, 'DNR-1115', 10, 'Aisha Abdullah', 'aisha.abdullah@email.com', 9, 1900.00, 'Completed', '2026-03-21 07:15:00', '+60123456798', 'Seremban', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"Aisha Abdullah\"}'),
(116, 'DNR-1116', 11, 'Ryan Lim', 'ryan.lim@email.com', 9, 1500.00, 'Completed', '2026-03-22 08:40:00', '+60123456799', 'Kuala Lumpur', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****3421\",\"cardExpiry\":\"08/26\"}'),
(117, 'DNR-1117', 12, 'Zainab Ismail', 'zainab.ismail@email.com', 9, 1800.00, 'Completed', '2026-03-23 04:00:00', '+60123456800', 'Georgetown', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Zainab Ismail\"}'),
(118, 'DNR-1118', 13, 'James Tan', 'james.tan@email.com', 9, 2100.00, 'Completed', '2026-03-24 06:20:00', '+60123456801', 'Ipoh', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****5678\",\"cardExpiry\":\"04/26\"}'),
(119, 'DNR-1119', 14, 'Mariam Yusof', 'mariam.yusof@email.com', 9, 1600.00, 'Completed', '2026-03-25 07:45:00', '+60123456802', 'Kuching', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Mariam Yusof\"}'),
(120, 'DNR-1120', 15, 'Kevin Ng', 'kevin.ng@email.com', 9, 2200.00, 'Completed', '2026-03-26 10:10:00', '+60123456803', 'Kota Kinabalu', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****1234\",\"cardExpiry\":\"10/26\"}'),
(121, 'DNR-1121', 1, 'Ahmad Rahman', 'ahmad.rahman@email.com', 9, 1400.00, 'Completed', '2026-03-27 04:35:00', '+60123456789', 'Kuala Lumpur', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Ahmad Rahman\"}'),
(122, 'DNR-1122', 2, 'Nurul Aisyah', 'nurul.aisyah@email.com', 9, 1300.00, 'Completed', '2026-03-28 06:55:00', '+60123456790', 'Penang', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****8765\",\"cardExpiry\":\"06/26\"}'),
(123, 'DNR-1123', 3, 'David Tan', 'david.tan@email.com', 9, 2000.00, 'Completed', '2026-03-29 09:15:00', '+60123456791', 'Johor Bahru', 'Bank Transfer', '{\"bankName\":\"RHB\",\"accountName\":\"David Tan\"}'),
(124, 'DNR-1124', 4, 'Priya Kumar', 'priya.kumar@email.com', 9, 2300.00, 'Completed', '2026-03-30 03:50:00', '+60123456792', 'Ipoh', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****2134\",\"cardExpiry\":\"09/27\"}'),
(125, 'DNR-1125', 5, 'Michael Wong', 'michael.wong@email.com', 9, 1800.00, 'Completed', '2026-03-31 06:10:00', '+60123456793', 'Melaka', 'Bank Transfer', '{\"bankName\":\"Public Bank\",\"accountName\":\"Michael Wong\"}'),
(126, 'DNR-1126', 6, 'Fatimah Hassan', 'fatimah.hassan@email.com', 9, 1500.00, 'Completed', '2026-04-01 08:25:00', '+60123456794', 'Kota Kinabalu', 'Card Payment', '{\"cardType\":\"Visa\",\"cardNumber\":\"****6543\",\"cardExpiry\":\"03/26\"}'),
(127, 'DNR-1127', 7, 'Jonathan Lee', 'jonathan.lee@email.com', 9, 1200.00, 'Completed', '2026-04-01 10:40:00', '+60123456795', 'Kuching', 'Bank Transfer', '{\"bankName\":\"CIMB\",\"accountName\":\"Jonathan Lee\"}'),
(128, 'DNR-1128', 8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', 9, 1100.00, 'Completed', '2026-04-02 05:00:00', '+60123456796', 'Shah Alam', 'Card Payment', '{\"cardType\":\"Mastercard\",\"cardNumber\":\"****9876\",\"cardExpiry\":\"11/25\"}'),
(129, 'DNR-1129', 9, 'Daniel Chen', 'daniel.chen@email.com', 9, 1000.00, 'Completed', '2026-04-02 07:20:00', '+60123456797', 'Petaling Jaya', 'Bank Transfer', '{\"bankName\":\"Maybank\",\"accountName\":\"Daniel Chen\"}'),
(131, 'DNR-69D22E166B69F', 16, '0', 'sam@gmail.com', 7, 100.00, 'Completed', '2026-04-05 09:40:38', '9054522402', 'Ahmedabad', 'Bank Transfer', '{\"bank_name\":\"BOB\",\"account_name\":\"Sam\",\"account_number\":\"39560100021388\",\"ifsc_code\":\"BARB0JUHAPU\",\"remarks\":\"N\\/A\"}');

-- --------------------------------------------------------

--
-- Table structure for table `ngos`
--

DROP TABLE IF EXISTS `ngos`;
CREATE TABLE IF NOT EXISTS `ngos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ngos`
--

INSERT INTO `ngos` (`id`, `name`, `description`, `created_at`) VALUES
(1, 'WaterFirst NGO', 'Providing clean water access to rural communities across Southeast Asia', '2026-04-02 13:54:33'),
(2, 'GreenEarth Alliance', 'Dedicated to reforestation and environmental conservation initiatives', '2026-04-02 13:54:33'),
(3, 'FeedHope Foundation', 'Emergency food relief and nutrition programs for displaced families', '2026-04-02 13:54:33'),
(4, 'EduRise NGO', 'Empowering girls through education scholarships and mentorship programs', '2026-04-02 13:54:33'),
(5, 'LightUp Alliance', 'Bringing sustainable solar energy solutions to off-grid communities', '2026-04-02 13:54:33'),
(6, 'MindBridge NGO', 'Mental health awareness and counselling services for youth and adults', '2026-04-02 13:54:33');

-- --------------------------------------------------------

--
-- Table structure for table `ngo_history`
--

DROP TABLE IF EXISTS `ngo_history`;
CREATE TABLE IF NOT EXISTS `ngo_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ngo_id` int NOT NULL,
  `year` varchar(10) NOT NULL,
  `title` varchar(200) NOT NULL,
  `raised` decimal(12,2) NOT NULL DEFAULT '0.00',
  `distributed` decimal(12,2) NOT NULL DEFAULT '0.00',
  `beneficiaries` varchar(100) DEFAULT NULL,
  `period` varchar(100) DEFAULT NULL,
  `note` text,
  PRIMARY KEY (`id`),
  KEY `ngo_id` (`ngo_id`)
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ngo_history`
--

INSERT INTO `ngo_history` (`id`, `ngo_id`, `year`, `title`, `raised`, `distributed`, `beneficiaries`, `period`, `note`) VALUES
(1, 1, '2025', 'Rural School Wells Phase 1', 22400.00, 19800.00, '8 schools', 'Jan–Jun 2025', 'Installed 8 borehole wells serving 1,200 students. Remaining funds allocated to maintenance reserves.'),
(2, 1, '2024', 'Community Water Tanks', 15600.00, 14200.00, '5 villages', 'Mar–Aug 2024', 'Constructed 5 elevated water tanks providing clean water to 3,400 residents across Sabah.'),
(3, 1, '2023', 'Water Filtration Systems for Clinics', 18900.00, 17500.00, '12 health clinics', 'Apr–Nov 2023', 'Provided clean water filtration systems for 12 rural health clinics, ensuring safe water for patients and staff.'),
(4, 2, '2025', 'Borneo Forest Restoration', 38000.00, 35500.00, '28,000 trees', 'Feb–Dec 2025', '28,000 native Dipterocarps planted across 14 hectares. Survival rate: 87% at 6-month audit.'),
(5, 2, '2024', 'Mangrove Replanting Drive', 21200.00, 19900.00, '12,000 saplings', 'Apr–Oct 2024', 'Coastal mangrove belt restored in Selangor, protecting shoreline for 6 fishing communities.'),
(6, 2, '2023', 'Urban Tree Planting Initiative', 14800.00, 13900.00, '3,500 trees', 'Mar–Sep 2023', 'Planted 3,500 shade trees in urban areas of Kuala Lumpur and Penang to combat urban heat island effect.'),
(7, 3, '2025', 'Flood Disaster Relief — Kelantan', 12800.00, 12100.00, '340 families', 'Jan 2025', 'Emergency ration packs delivered within 48 hours of flooding. Each pack covered 7 days of meals for a family of 4.'),
(8, 3, '2024', 'Urban Hunger Initiative', 9400.00, 8700.00, '210 families', 'Jun–Dec 2024', 'Weekly food basket programme for urban poor households in Kuala Lumpur and Penang.'),
(9, 3, '2023', 'School Meal Program', 16500.00, 15800.00, '450 students', 'Jan–Dec 2023', 'Provided daily nutritious meals to 450 underprivileged students across 6 primary schools.'),
(10, 4, '2025', 'Girls STEM Scholarship 2025', 48000.00, 45500.00, '92 students', 'Jan–Dec 2025', '92 scholarships awarded covering school fees, uniforms, and books. Average grant: ₹ 494 per student.'),
(11, 4, '2024', 'Secondary School Bursary 2024', 35200.00, 33800.00, '78 students', 'Jan–Dec 2024', '78 girls supported through Form 4 and Form 5. 94% achieved at least 5As in SPM.'),
(12, 4, '2023', 'Digital Learning Tablets Program', 28900.00, 27400.00, '120 students', 'Feb–Oct 2023', 'Distributed 120 tablets with preloaded educational content to rural students without internet access.'),
(13, 5, '2025', 'Off-Grid Sarawak Villages Phase 1', 26400.00, 24900.00, '8 villages', 'Mar–Nov 2025', 'Solar microgrids installed in 8 longhouses. Average of 4.2kW per household, eliminating kerosene dependency.'),
(14, 5, '2024', 'Solar for Schools Pilot', 18000.00, 17200.00, '4 schools', 'Jan–Aug 2024', '4 rural schools received solar panels, reducing electricity bills by 80% and enabling after-dark study.'),
(15, 5, '2023', 'Community Solar Street Lights', 12600.00, 11900.00, '15 villages', 'May–Nov 2023', 'Installed solar-powered street lighting in 15 rural villages, improving safety and extending productive hours.'),
(16, 6, '2025', 'Youth Counselling Outreach 2025', 16500.00, 15300.00, '520 youth', 'Jan–Jun 2025', '520 young people attended free workshops. 148 referred for ongoing counselling. 3 licensed counsellors deployed.'),
(17, 6, '2024', 'University Campus Awareness', 11200.00, 10600.00, '9 campuses', 'Apr–Dec 2024', 'Mental health awareness drives across 9 universities, reaching an estimated 14,000 students.'),
(18, 6, '2023', 'Workplace Mental Health Training', 14900.00, 14100.00, '35 companies', 'Feb–Nov 2023', 'Trained HR staff and managers from 35 SMEs on mental health first aid and supportive workplace practices.');

-- --------------------------------------------------------

--
-- Table structure for table `support_messages`
--

DROP TABLE IF EXISTS `support_messages`;
CREATE TABLE IF NOT EXISTS `support_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `message` text NOT NULL,
  `submitted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(20) DEFAULT 'Pending',
  `resolved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trustees`
--

DROP TABLE IF EXISTS `trustees`;
CREATE TABLE IF NOT EXISTS `trustees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `ngo_name` varchar(150) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `trustees`
--

INSERT INTO `trustees` (`id`, `name`, `email`, `password`, `ngo_name`, `created_at`) VALUES
(1, 'WaterFirst Trustee', 'waterfirst@gmail.com', '$2y$10$/.FJ3.pfveTdUFVMaTUI3OL3/Y.oYXSMLY85jElB/fOr3TvJuOY92', 'WaterFirst NGO', '2026-03-10 04:25:36'),
(2, 'Sarah Ahmad', 'trustee@waterfirst.org', '$2y$10$bK9s0L8mW7vU6tS5rQ4pO3nM2lK1jI0hG9fE8dC7bA6z5y4x3w2v1', 'WaterFirst NGO', '2026-03-30 15:35:55');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('user','admin','trustee') DEFAULT 'user',
  `ngo_name` varchar(150) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `ngo_name`, `created_at`) VALUES
(1, 'Ahmad Rahman', 'ahmad.rahman@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(2, 'Nurul Aisyah', 'nurul.aisyah@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(3, 'David Tan', 'david.tan@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(4, 'Priya Kumar', 'priya.kumar@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(5, 'Michael Wong', 'michael.wong@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(6, 'Fatimah Hassan', 'fatimah.hassan@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(7, 'Jonathan Lee', 'jonathan.lee@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(8, 'Siti Nurhaliza', 'siti.nurhaliza@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(9, 'Daniel Chen', 'daniel.chen@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(10, 'Aisha Abdullah', 'aisha.abdullah@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(11, 'Ryan Lim', 'ryan.lim@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(12, 'Zainab Ismail', 'zainab.ismail@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(13, 'James Tan', 'james.tan@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(14, 'Mariam Yusof', 'mariam.yusof@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(15, 'Kevin Ng', 'kevin.ng@email.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', NULL, '2026-04-02 13:54:33'),
(16, 'Sam', 'sam@gmail.com', '$2y$10$IISzdu45MTFXNpmD7FMl3OmNI0fO7WEcWIJyhUkxV5it6G5VygrZa', 'user', NULL, '2026-04-03 05:03:59');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
