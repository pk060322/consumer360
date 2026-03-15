-- ============================================================
-- Consumer360 | File 01: Create Database
-- Run this first before all other SQL files
-- ============================================================

-- Drop and recreate for a clean setup
DROP DATABASE IF EXISTS consumer360;

CREATE DATABASE consumer360
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE consumer360;

-- Confirm creation
SELECT 'Database consumer360 created successfully' AS status;
