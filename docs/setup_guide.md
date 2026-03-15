# Setup Guide — Consumer360

## Prerequisites

Before you start, ensure you have installed:

| Tool | Version | Download |
|---|---|---|
| MySQL Server | 8.0+ | https://dev.mysql.com/downloads/mysql/ |
| MySQL Workbench | 8.0+ | https://dev.mysql.com/downloads/workbench/ |
| Python | 3.10+ | https://www.python.org/downloads/ |
| Power BI Desktop | Latest | https://powerbi.microsoft.com/desktop/ |
| Git | Latest | https://git-scm.com/downloads |

---

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/consumer360.git
cd consumer360
```

### 2. Set Up MySQL Database

Open MySQL Workbench or a terminal and run the SQL files in order:

```bash
# Option A: Command line (recommended)
mysql -u root -p < sql/01_create_database.sql
mysql -u root -p consumer360 < sql/02_create_staging.sql
mysql -u root -p consumer360 < sql/03_create_dimensions.sql
mysql -u root -p consumer360 < sql/04_create_fact_table.sql
mysql -u root -p consumer360 < sql/05_insert_sample_data.sql
mysql -u root -p consumer360 < sql/06_create_indexes.sql
mysql -u root -p consumer360 < sql/07_create_rfm_table.sql
```

```sql
-- Option B: MySQL Workbench
-- Open each .sql file and run with Ctrl+Shift+Enter
```

Verify the setup:
```sql
USE consumer360;
SHOW TABLES;
-- Expected: dim_customer, dim_date, dim_product, dim_store,
--           fact_sales, rfm_segments, stg_transactions
```

### 3. Configure Python

```bash
cd python
pip install -r requirements.txt
```

Edit `python/db_config.py` — update your MySQL credentials:
```python
DB_CONFIG = {
    'host':     'localhost',
    'user':     'root',
    'password': 'YOUR_ACTUAL_PASSWORD',  # ← change this
    'database': 'consumer360',
    ...
}
```

### 4. Run the RFM Analysis

```bash
# Test the engine standalone
python python/rfm_engine.py

# Run the full pipeline
python python/pipeline_master.py
```

Expected output:
```
2024-12-01 06:00:00 | INFO     | Database connection established
2024-12-01 06:00:00 | INFO     | Extracted 28 transactions for 10 customers
2024-12-01 06:00:00 | INFO     | RFM calculated...
2024-12-01 06:00:00 | INFO     | Saved 10 RFM records
2024-12-01 06:00:00 | INFO     | PIPELINE COMPLETED SUCCESSFULLY
```

### 5. Verify in MySQL

```sql
USE consumer360;
SELECT customer_id, segment, rfm_score, recency_days, monetary_total
FROM rfm_segments
ORDER BY rfm_total DESC;
```

### 6. Connect Power BI

1. Open Power BI Desktop
2. Get Data → MySQL Database
3. Server: `localhost`, Database: `consumer360`
4. If driver missing: install MySQL Connector/NET from mysql.com
5. Select tables: `fact_sales`, `dim_customer`, `dim_product`, `dim_date`, `dim_store`, `rfm_segments`
6. Build relationships in Model view (see `powerbi/dax_measures.md`)

---

## Troubleshooting

**MySQL connection refused**
- Ensure MySQL service is running: `net start MySQL80` (Windows) or `sudo service mysql start` (Linux)

**Python import error: mysql.connector not found**
- Run: `pip install mysql-connector-python`

**qcut ValueError during RFM scoring**
- This happens with very small datasets (< 10 customers). The engine handles this automatically with a fallback to `pd.cut`. Add more sample data if needed.

**Power BI "Driver not found"**
- Download and install MySQL Connector/NET from: https://dev.mysql.com/downloads/connector/net/
