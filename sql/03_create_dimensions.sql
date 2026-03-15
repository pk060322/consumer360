-- ============================================================
-- Consumer360 | File 03: Dimension Tables (Star Schema)
-- dim_customer, dim_product, dim_date, dim_store
-- ============================================================

USE consumer360;

-- ─────────────────────────────────────────────
-- DIMENSION: Customer (who bought)
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer (
    customer_id  INT PRIMARY KEY AUTO_INCREMENT,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(255) UNIQUE NOT NULL,
    phone        VARCHAR(20),
    city         VARCHAR(100),
    state        VARCHAR(100),
    region       VARCHAR(100),
    country      VARCHAR(100) DEFAULT 'India',
    join_date    DATE,
    is_active    TINYINT(1) DEFAULT 1,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- DIMENSION: Product (what was bought)
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_product (
    product_id    INT PRIMARY KEY AUTO_INCREMENT,
    product_name  VARCHAR(200) NOT NULL,
    category      VARCHAR(100) NOT NULL,
    sub_category  VARCHAR(100),
    brand         VARCHAR(100),
    unit_cost     DECIMAL(10,2),
    is_active     TINYINT(1) DEFAULT 1,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
-- DIMENSION: Date (when it was bought)
-- Pre-populated for fast time-based filtering
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    date_id      INT PRIMARY KEY,          -- format YYYYMMDD e.g. 20240315
    full_date    DATE NOT NULL,
    year         INT NOT NULL,
    quarter      INT NOT NULL,
    month        INT NOT NULL,
    month_name   VARCHAR(20) NOT NULL,
    week         INT NOT NULL,
    day_of_week  VARCHAR(20) NOT NULL,
    day_number   INT NOT NULL,             -- 1=Sunday ... 7=Saturday
    is_weekend   TINYINT(1) NOT NULL
);

-- Stored procedure to fill dim_date for any date range
DELIMITER //
DROP PROCEDURE IF EXISTS populate_dim_date//
CREATE PROCEDURE populate_dim_date(IN start_date DATE, IN end_date DATE)
BEGIN
    DECLARE cur DATE DEFAULT start_date;
    WHILE cur <= end_date DO
        INSERT IGNORE INTO dim_date VALUES (
            CAST(DATE_FORMAT(cur,'%Y%m%d') AS UNSIGNED),
            cur,
            YEAR(cur),
            QUARTER(cur),
            MONTH(cur),
            MONTHNAME(cur),
            WEEK(cur, 1),
            DAYNAME(cur),
            DAYOFWEEK(cur),
            IF(DAYOFWEEK(cur) IN (1,7), 1, 0)
        );
        SET cur = DATE_ADD(cur, INTERVAL 1 DAY);
    END WHILE;
END//
DELIMITER ;

-- Populate 2020–2026 (adjust range as needed)
CALL populate_dim_date('2020-01-01', '2026-12-31');

-- ─────────────────────────────────────────────
-- DIMENSION: Store (where it was bought)
-- ─────────────────────────────────────────────
DROP TABLE IF EXISTS dim_store;

CREATE TABLE dim_store (
    store_id    INT PRIMARY KEY AUTO_INCREMENT,
    store_name  VARCHAR(200) NOT NULL,
    city        VARCHAR(100),
    state       VARCHAR(100),
    region      VARCHAR(100),
    country     VARCHAR(100) DEFAULT 'India',
    store_type  ENUM('Physical','Online','Franchise') DEFAULT 'Physical',
    is_active   TINYINT(1) DEFAULT 1
);

SELECT 'All dimension tables created successfully' AS status;
