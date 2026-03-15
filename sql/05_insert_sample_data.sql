-- ============================================================
-- Consumer360 | File 05: Sample Data Insertion
-- 8 customers, 6 products, 8 stores, 30+ transactions
-- ============================================================

USE consumer360;

-- ─────────────────────────────────────────────
-- CUSTOMERS
-- ─────────────────────────────────────────────
INSERT INTO dim_customer (first_name, last_name, email, city, state, region, join_date) VALUES
('Arjun',   'Sharma',    'arjun.sharma@email.com',    'Mumbai',    'Maharashtra', 'West',  '2022-01-15'),
('Priya',   'Patel',     'priya.patel@email.com',     'Ahmedabad', 'Gujarat',     'West',  '2021-06-20'),
('Ravi',    'Kumar',     'ravi.kumar@email.com',      'Bangalore', 'Karnataka',   'South', '2020-03-10'),
('Anita',   'Singh',     'anita.singh@email.com',     'Delhi',     'Delhi',       'North', '2023-02-28'),
('Suresh',  'Reddy',     'suresh.reddy@email.com',    'Hyderabad', 'Telangana',   'South', '2021-11-05'),
('Kavitha', 'Nair',      'kavitha.nair@email.com',    'Chennai',   'Tamil Nadu',  'South', '2022-08-14'),
('Deepak',  'Joshi',     'deepak.joshi@email.com',    'Pune',      'Maharashtra', 'West',  '2020-12-01'),
('Meena',   'Gupta',     'meena.gupta@email.com',     'Jaipur',    'Rajasthan',   'North', '2023-05-19'),
('Vikram',  'Iyer',      'vikram.iyer@email.com',     'Kochi',     'Kerala',      'South', '2021-03-22'),
('Sunita',  'Mehta',     'sunita.mehta@email.com',    'Surat',     'Gujarat',     'West',  '2022-09-30');

-- ─────────────────────────────────────────────
-- PRODUCTS
-- ─────────────────────────────────────────────
INSERT INTO dim_product (product_name, category, sub_category, brand, unit_cost) VALUES
('Samsung Galaxy S24',        'Electronics',   'Mobile',       'Samsung',       45000.00),
('Nike Air Max 2024',         'Footwear',      'Running',      'Nike',           8000.00),
('Organic Green Tea 200g',    'Grocery',       'Beverages',    'Organic India',   350.00),
("Levi's 511 Slim Jeans",    'Apparel',       'Denim',        "Levi's",         3200.00),
('Sony WH-1000XM5 Headphones','Electronics',  'Audio',        'Sony',          15000.00),
('Himalaya Purifying Neem',   'Personal Care', 'Skincare',     'Himalaya',        280.00),
('Apple iPad Air 2024',       'Electronics',   'Tablet',       'Apple',         62000.00),
('Adidas Ultraboost 23',      'Footwear',      'Running',      'Adidas',        12000.00);

-- ─────────────────────────────────────────────
-- STORES
-- ─────────────────────────────────────────────
INSERT INTO dim_store (store_name, city, state, region, store_type) VALUES
('Mumbai Central Mall',      'Mumbai',    'Maharashtra', 'West',  'Physical'),
('Ahmedabad Galleria',       'Ahmedabad', 'Gujarat',     'West',  'Physical'),
('Bangalore Tech Park',      'Bangalore', 'Karnataka',   'South', 'Physical'),
('Delhi Select Citywalk',    'Delhi',     'Delhi',       'North', 'Physical'),
('Hyderabad GVK One',        'Hyderabad', 'Telangana',   'South', 'Physical'),
('Chennai Phoenix MarketCity','Chennai',  'Tamil Nadu',  'South', 'Physical'),
('Pune Seasons Mall',        'Pune',      'Maharashtra', 'West',  'Physical'),
('Consumer360 Online Store', 'Online',    'PAN India',   'All',   'Online');

-- ─────────────────────────────────────────────
-- TRANSACTIONS (fact_sales)
-- Mix of frequent, occasional, and lapsed customers
-- ─────────────────────────────────────────────

-- Arjun Sharma (customer 1) — Champion: recent, frequent, high spend
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(1, 1, 20240315, 1, 1, 45000.00, 45000.00),
(1, 2, 20240410, 1, 2,  8000.00, 16000.00),
(1, 5, 20240520, 8, 1, 15000.00, 15000.00),
(1, 7, 20240715, 1, 1, 62000.00, 62000.00),
(1, 3, 20241001, 8, 5,   350.00,  1750.00);

-- Priya Patel (customer 2) — Loyal: regular mid-value purchases
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(2, 3, 20240101, 2, 10,  350.00,  3500.00),
(2, 6, 20240215, 2,  3,  280.00,   840.00),
(2, 4, 20240520, 2,  1, 3200.00,  3200.00),
(2, 3, 20241115, 8,  8,  350.00,  2800.00);

-- Ravi Kumar (customer 3) — Potential Loyalist: bought recently, could grow
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(3, 5, 20231205, 3, 1, 15000.00, 15000.00),
(3, 6, 20240220, 3, 3,   280.00,   840.00),
(3, 2, 20241010, 8, 1,  8000.00,  8000.00);

-- Anita Singh (customer 4) — New Customer: first purchase recent
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(4, 4, 20241105, 4, 1, 3200.00, 3200.00);

-- Suresh Reddy (customer 5) — Champion: very high value, frequent
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(5, 1, 20240101, 5, 1, 45000.00, 45000.00),
(5, 7, 20240310, 5, 1, 62000.00, 62000.00),
(5, 5, 20240415, 8, 1, 15000.00, 15000.00),
(5, 2, 20240615, 5, 2,  8000.00, 16000.00),
(5, 8, 20241001, 8, 1, 12000.00, 12000.00);

-- Kavitha Nair (customer 6) — At Risk: was active, quiet for months
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(6, 5, 20231101, 6, 1, 15000.00, 15000.00),
(6, 4, 20231210, 6, 2,  3200.00,  6400.00);

-- Deepak Joshi (customer 7) — At Risk / Lost: very old purchases
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(7, 4, 20220501, 7, 2, 3200.00, 6400.00),
(7, 2, 20221010, 7, 1, 8000.00, 8000.00);

-- Meena Gupta (customer 8) — New: recent, one purchase
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(8, 6, 20241115, 8, 1, 280.00, 280.00);

-- Vikram Iyer (customer 9) — Loyal: consistent, moderate value
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(9, 5, 20240201, 8, 1, 15000.00, 15000.00),
(9, 8, 20240505, 8, 1, 12000.00, 12000.00),
(9, 3, 20240810, 8, 6,   350.00,  2100.00);

-- Sunita Mehta (customer 10) — Potential Loyalist: recent, low frequency
INSERT INTO fact_sales (customer_id, product_id, date_id, store_id, quantity, unit_price, total_amount) VALUES
(10, 4, 20241001, 8, 1, 3200.00, 3200.00),
(10, 6, 20241120, 8, 2,  280.00,  560.00);

SELECT 
    COUNT(DISTINCT customer_id) AS customers_with_data,
    COUNT(*)                    AS total_transactions,
    ROUND(SUM(total_amount),2)  AS total_revenue
FROM fact_sales;
