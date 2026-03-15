-- ============================================================
-- Consumer360 | File 02: Raw Staging Table
-- Landing zone for raw CSV imports — no transformation yet
-- ============================================================

USE consumer360;

DROP TABLE IF EXISTS stg_transactions;

CREATE TABLE stg_transactions (
    row_id          INT AUTO_INCREMENT PRIMARY KEY,
    raw_customer_id VARCHAR(50),
    raw_product_id  VARCHAR(50),
    raw_date        VARCHAR(50),       -- stored as string, validated later
    raw_store_id    VARCHAR(50),
    quantity        VARCHAR(20),
    unit_price      VARCHAR(20),
    total_amount    VARCHAR(20),
    source_file     VARCHAR(200),
    load_timestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT 'Staging table stg_transactions created' AS status;
