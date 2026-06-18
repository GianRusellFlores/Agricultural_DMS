-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 18, 2026 at 08:13 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `agriculture_dms`
--

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `activity_logs`
--

INSERT INTO `activity_logs` (`id`, `user_id`, `action`, `description`, `created_at`) VALUES
(101, 1, 'LOGIN', 'User Logged In', '2026-06-18 01:23:32'),
(102, 1, 'LOGIN', 'User Logged In', '2026-06-18 02:45:22');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `category_name`, `description`, `created_at`) VALUES
(1, 'Farmer Records', 'Farmer registration documents', '2026-06-16 06:54:16'),
(2, 'Seed Distribution', 'Seed distribution records', '2026-06-16 06:54:16'),
(3, 'Financial Reports', 'Budget and financial reports', '2026-06-16 06:54:16'),
(4, 'Legal Documents', 'Legal and administrative documents', '2026-06-16 06:54:16'),
(5, 'Contracts', 'Office contracts and agreements', '2026-06-16 06:54:16'),
(6, 'Agricultural Projects', 'Agricultural project records', '2026-06-16 06:54:16'),
(7, 'Training Reports', 'Seminars and training reports', '2026-06-16 06:54:16'),
(8, 'General Documents', 'Miscellaneous documents', '2026-06-16 06:54:16');

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `id` int(11) NOT NULL,
  `document_no` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `original_filename` varchar(255) DEFAULT NULL,
  `filetype` varchar(50) DEFAULT NULL,
  `filesize` varchar(50) DEFAULT NULL,
  `status` enum('Active','Review','Archived') DEFAULT 'Active',
  `uploaded_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `downloads`
--

CREATE TABLE `downloads` (
  `id` int(11) NOT NULL,
  `document_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `downloaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` int(11) NOT NULL,
  `report_name` varchar(255) DEFAULT NULL,
  `report_type` enum('PDF','EXCEL','CSV') DEFAULT 'PDF',
  `generated_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `fullname` varchar(150) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `contact_no` varchar(20) DEFAULT NULL,
  `role` enum('admin','staff','viewer') DEFAULT 'viewer',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `fullname`, `username`, `password`, `email`, `contact_no`, `role`, `status`, `created_at`) VALUES
(1, 'System Administrator', 'admin', 'admin123', NULL, NULL, 'admin', 'active', '2026-06-18 01:21:50'),
(2, 'User 01', 'user01', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(3, 'User 02', 'user02', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(4, 'User 03', 'user03', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(5, 'User 04', 'user04', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(6, 'User 05', 'user05', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(7, 'User 06', 'user06', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(8, 'User 07', 'user07', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(9, 'User 08', 'user08', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(10, 'User 09', 'user09', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(11, 'User 10', 'user10', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(12, 'User 11', 'user11', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(13, 'User 12', 'user12', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(14, 'User 13', 'user13', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(15, 'User 14', 'user14', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(16, 'User 15', 'user15', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(17, 'User 16', 'user16', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(18, 'User 17', 'user17', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(19, 'User 18', 'user18', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(20, 'User 19', 'user19', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(21, 'User 20', 'user20', '123456', NULL, NULL, 'staff', 'active', '2026-06-18 01:58:30'),
(22, 'User 21', 'user21', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(23, 'User 22', 'user22', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(24, 'User 23', 'user23', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(25, 'User 24', 'user24', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(26, 'User 25', 'user25', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(27, 'User 26', 'user26', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(28, 'User 27', 'user27', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(29, 'User 28', 'user28', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(30, 'User 29', 'user29', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(31, 'User 30', 'user30', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(32, 'User 31', 'user31', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(33, 'User 32', 'user32', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(34, 'User 33', 'user33', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(35, 'User 34', 'user34', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(36, 'User 35', 'user35', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(37, 'User 36', 'user36', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(38, 'User 37', 'user37', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(39, 'User 38', 'user38', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(40, 'User 39', 'user39', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30'),
(41, 'User 40', 'user40', '123456', NULL, NULL, 'viewer', 'active', '2026-06-18 01:58:30');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `document_no` (`document_no`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `uploaded_by` (`uploaded_by`);

--
-- Indexes for table `downloads`
--
ALTER TABLE `downloads`
  ADD PRIMARY KEY (`id`),
  ADD KEY `document_id` (`document_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `generated_by` (`generated_by`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `downloads`
--
ALTER TABLE `downloads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `activity_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `documents_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `downloads`
--
ALTER TABLE `downloads`
  ADD CONSTRAINT `downloads_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `downloads_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`generated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
