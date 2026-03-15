# Data Dictionary — Consumer360

## fact_sales

| Column | Type | Description |
|---|---|---|
| sale_id | BIGINT | Primary key, auto-incremented |
| customer_id | INT | FK → dim_customer |
| product_id | INT | FK → dim_product |
| date_id | INT | FK → dim_date (format: YYYYMMDD) |
| store_id | INT | FK → dim_store |
| quantity | INT | Number of units purchased |
| unit_price | DECIMAL(10,2) | Price per unit in INR |
| discount_pct | DECIMAL(5,2) | Discount percentage applied |
| total_amount | DECIMAL(12,2) | Final transaction value in INR |

## dim_customer

| Column | Type | Description |
|---|---|---|
| customer_id | INT | Primary key |
| first_name | VARCHAR | Customer first name |
| last_name | VARCHAR | Customer last name |
| email | VARCHAR | Unique email address |
| city | VARCHAR | City of residence |
| region | VARCHAR | North / South / West / East |
| join_date | DATE | Date customer first registered |
| is_active | TINYINT | 1 = active, 0 = deactivated |

## dim_product

| Column | Type | Description |
|---|---|---|
| product_id | INT | Primary key |
| product_name | VARCHAR | Full product name |
| category | VARCHAR | Top-level category (Electronics, Apparel, etc.) |
| sub_category | VARCHAR | More specific sub-group |
| brand | VARCHAR | Manufacturer / brand name |
| unit_cost | DECIMAL | Cost price in INR |

## dim_date

| Column | Type | Description |
|---|---|---|
| date_id | INT | Primary key — format YYYYMMDD |
| full_date | DATE | Standard DATE value |
| year | INT | Calendar year |
| quarter | INT | 1–4 |
| month | INT | 1–12 |
| month_name | VARCHAR | January, February, etc. |
| week | INT | ISO week number |
| day_of_week | VARCHAR | Monday, Tuesday, etc. |
| is_weekend | TINYINT | 1 if Saturday or Sunday |

## rfm_segments

| Column | Type | Description |
|---|---|---|
| rfm_id | BIGINT | Primary key |
| customer_id | INT | FK → dim_customer |
| analysis_date | DATE | Date this RFM run was performed |
| recency_days | INT | Days since last purchase |
| frequency_count | INT | Total number of transactions |
| monetary_total | DECIMAL | Total spend in INR |
| r_score | TINYINT | Recency score 1–5 (5 = best) |
| f_score | TINYINT | Frequency score 1–5 (5 = best) |
| m_score | TINYINT | Monetary score 1–5 (5 = best) |
| rfm_score | VARCHAR(3) | Combined e.g. "543" |
| rfm_total | TINYINT | r+f+m total (max 15) |
| segment | VARCHAR | Champions / Loyal Customers / etc. |
