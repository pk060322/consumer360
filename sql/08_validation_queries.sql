-- ============================================================
-- Consumer360 | File 08: Data Quality Validation Queries
-- Run these BEFORE and AFTER any pipeline run to verify data
-- ============================================================

USE consumer360;

-- TEST 1: Null values in critical columns
SELECT
    'fact_sales NULL check' AS test_name,
    SUM(CASE WHEN customer_id IS NULL  THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN product_id IS NULL   THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) AS null_amount,
    SUM(CASE WHEN date_id IS NULL      THEN 1 ELSE 0 END) AS null_date
FROM fact_sales;

-- TEST 2: Invalid amounts (should return 0)
SELECT COUNT(*) AS invalid_negative_amounts
FROM fact_sales
WHERE total_amount <= 0;

-- TEST 3: Orphaned foreign keys
SELECT 'Orphaned customer_id' AS test_name, COUNT(*) AS count
FROM fact_sales fs
LEFT JOIN dim_customer dc ON fs.customer_id = dc.customer_id
WHERE dc.customer_id IS NULL
UNION ALL
SELECT 'Orphaned product_id', COUNT(*)
FROM fact_sales fs
LEFT JOIN dim_product dp ON fs.product_id = dp.product_id
WHERE dp.product_id IS NULL
UNION ALL
SELECT 'Orphaned date_id', COUNT(*)
FROM fact_sales fs
LEFT JOIN dim_date dd ON fs.date_id = dd.date_id
WHERE dd.date_id IS NULL;

-- TEST 4: Revenue summary (verify against known totals)
SELECT
    COUNT(DISTINCT customer_id)  AS unique_customers,
    COUNT(DISTINCT product_id)   AS unique_products,
    COUNT(*)                     AS total_transactions,
    ROUND(SUM(total_amount), 2)  AS grand_total_revenue,
    ROUND(AVG(total_amount), 2)  AS avg_transaction_value,
    MIN(dd.full_date)            AS earliest_transaction,
    MAX(dd.full_date)            AS latest_transaction
FROM fact_sales fs
JOIN dim_date dd ON fs.date_id = dd.date_id;

-- TEST 5: RFM segment score validation (scores must be 1–5)
SELECT COUNT(*) AS invalid_rfm_scores
FROM rfm_segments
WHERE r_score NOT BETWEEN 1 AND 5
   OR f_score NOT BETWEEN 1 AND 5
   OR m_score NOT BETWEEN 1 AND 5;

-- TEST 6: Segment distribution (Champions should have high avg scores)
SELECT
    segment,
    COUNT(*)              AS customer_count,
    ROUND(AVG(r_score),1) AS avg_r,
    ROUND(AVG(f_score),1) AS avg_f,
    ROUND(AVG(m_score),1) AS avg_m,
    ROUND(AVG(monetary_total),0) AS avg_spend
FROM rfm_segments
WHERE analysis_date = (SELECT MAX(analysis_date) FROM rfm_segments)
GROUP BY segment
ORDER BY (AVG(r_score) + AVG(f_score) + AVG(m_score)) DESC;

-- TEST 7: Revenue by region (for dashboard cross-check)
SELECT
    dc.region,
    COUNT(DISTINCT fs.customer_id)  AS customers,
    COUNT(*)                        AS transactions,
    ROUND(SUM(fs.total_amount), 2)  AS revenue
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
GROUP BY dc.region
ORDER BY revenue DESC;

-- TEST 8: Top 5 products by revenue
SELECT
    dp.product_name,
    dp.category,
    SUM(fs.quantity)               AS total_units,
    ROUND(SUM(fs.total_amount), 2) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
GROUP BY dp.product_id, dp.product_name, dp.category
ORDER BY total_revenue DESC
LIMIT 5;
