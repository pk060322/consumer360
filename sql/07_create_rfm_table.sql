-- ============================================================
-- Consumer360 | File 07: RFM Segments Output Table
-- Stores Python analytics results back into MySQL
-- Power BI reads from this table for dashboard visuals
-- ============================================================

USE consumer360;

DROP TABLE IF EXISTS rfm_segments;

CREATE TABLE rfm_segments (
    rfm_id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id         INT NOT NULL,
    analysis_date       DATE NOT NULL,
    last_purchase_date  DATE,
    recency_days        INT,
    frequency_count     INT,
    monetary_total      DECIMAL(14,2),
    r_score             TINYINT,        -- 1 (worst) to 5 (best)
    f_score             TINYINT,
    m_score             TINYINT,
    rfm_score           VARCHAR(3),     -- e.g. "543"
    rfm_total           TINYINT,        -- sum of r+f+m (max 15)
    segment             VARCHAR(50),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- One record per customer per analysis date
    UNIQUE KEY uq_cust_date (customer_id, analysis_date),

    INDEX idx_rfm_segment     (segment),
    INDEX idx_rfm_date        (analysis_date),
    INDEX idx_rfm_score       (rfm_score),

    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)
);

SELECT 'rfm_segments table created successfully' AS status;
