-- ============================================================
-- Consumer360 | File 04: Fact Table
-- Central fact_sales table — one row per transaction
-- Run AFTER all dimension tables are created
-- ============================================================

USE consumer360;

DROP TABLE IF EXISTS fact_sales;

CREATE TABLE fact_sales (
    sale_id       BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT NOT NULL,
    product_id    INT NOT NULL,
    date_id       INT NOT NULL,
    store_id      INT NOT NULL,
    quantity      INT NOT NULL DEFAULT 1,
    unit_price    DECIMAL(10,2) NOT NULL,
    discount_pct  DECIMAL(5,2) DEFAULT 0.00,
    total_amount  DECIMAL(12,2) NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Referential integrity
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id)  REFERENCES dim_product(product_id),
    FOREIGN KEY (date_id)     REFERENCES dim_date(date_id),
    FOREIGN KEY (store_id)    REFERENCES dim_store(store_id)
);

SELECT 'fact_sales table created successfully' AS status;
