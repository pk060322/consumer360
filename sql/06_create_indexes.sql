-- ============================================================
-- Consumer360 | File 06: Performance Indexes
-- Without these, analytical queries scan the full table
-- ============================================================

USE consumer360;

-- Single-column indexes for common filter conditions
CREATE INDEX idx_fact_customer ON fact_sales (customer_id);
CREATE INDEX idx_fact_date     ON fact_sales (date_id);
CREATE INDEX idx_fact_product  ON fact_sales (product_id);
CREATE INDEX idx_fact_store    ON fact_sales (store_id);

-- Composite index for the most common RFM query pattern
-- (customer_id + date_id together, used when grouping by customer with date filter)
CREATE INDEX idx_sales_cust_date     ON fact_sales (customer_id, date_id);
CREATE INDEX idx_customer_region     ON dim_customer (region);
CREATE INDEX idx_product_category    ON dim_product (category);
CREATE INDEX idx_date_year_month     ON dim_date (year, month);

SELECT 'Indexes created successfully' AS status;
