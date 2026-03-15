"""
============================================================
Consumer360 | rfm_engine.py
Core RFM Analytics Engine

Calculates Recency, Frequency, Monetary values per customer,
assigns 1-5 scores on each dimension, and segments customers
into actionable business groups.

Usage:
    python rfm_engine.py              (runs analysis and prints results)
    from rfm_engine import run_rfm_analysis   (import into pipeline)
============================================================
"""

import pandas as pd
import numpy as np
import mysql.connector
import logging
from datetime import date, datetime

from db_config import DB_CONFIG

# ─────────────────────────────────────────────
# LOGGING SETUP
# ─────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(levelname)-8s | %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)


# ─────────────────────────────────────────────
# 1. DATABASE CONNECTION
# ─────────────────────────────────────────────
def get_db_connection():
    """
    Open and return a MySQL connection.
    Raises on failure — the pipeline should catch this.
    """
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        logger.info("Database connection established")
        return conn
    except mysql.connector.Error as e:
        logger.error(f"Database connection failed: {e}")
        raise


# ─────────────────────────────────────────────
# 2. DATA EXTRACTION
# ─────────────────────────────────────────────
def extract_transaction_data(conn):
    """
    Pull all transactions from the star schema.
    Joins fact_sales → dim_customer and dim_date
    to get customer names and proper date objects.
    """
    query = """
        SELECT
            fs.customer_id,
            CONCAT(dc.first_name, ' ', dc.last_name)  AS customer_name,
            dc.email,
            dc.region,
            dc.city,
            dd.full_date                               AS transaction_date,
            fs.total_amount
        FROM fact_sales fs
        JOIN dim_customer dc ON fs.customer_id = dc.customer_id
        JOIN dim_date     dd ON fs.date_id      = dd.date_id
        WHERE dc.is_active = 1
        ORDER BY fs.customer_id, dd.full_date
    """
    try:
        df = pd.read_sql(query, conn)
        logger.info(
            f"Extracted {len(df):,} transactions "
            f"for {df['customer_id'].nunique():,} customers"
        )
        return df
    except Exception as e:
        logger.error(f"Data extraction failed: {e}")
        raise


# ─────────────────────────────────────────────
# 3. RFM CALCULATION
# ─────────────────────────────────────────────
def calculate_rfm(df, analysis_date=None):
    """
    Compute raw RFM values per customer.

    Recency  = days since last purchase (lower = better)
    Frequency = number of transactions (higher = better)
    Monetary  = total spend in currency (higher = better)

    analysis_date: reference date for recency.
    Defaults to today. Change for backtesting.
    """
    if analysis_date is None:
        analysis_date = date.today()

    df['transaction_date'] = pd.to_datetime(df['transaction_date'])

    rfm = df.groupby(
        ['customer_id', 'customer_name', 'email', 'region', 'city']
    ).agg(
        last_purchase_date = ('transaction_date', 'max'),
        frequency          = ('transaction_date', 'count'),
        monetary           = ('total_amount',     'sum')
    ).reset_index()

    rfm['recency'] = (
        pd.Timestamp(analysis_date) - rfm['last_purchase_date']
    ).dt.days

    rfm['monetary'] = rfm['monetary'].round(2)

    logger.info(
        f"RFM calculated | "
        f"Avg recency: {rfm['recency'].mean():.0f} days | "
        f"Avg frequency: {rfm['frequency'].mean():.1f} | "
        f"Avg monetary: ₹{rfm['monetary'].mean():,.0f}"
    )
    return rfm


# ─────────────────────────────────────────────
# 4. RFM SCORING  (1 = worst, 5 = best)
# ─────────────────────────────────────────────
def assign_rfm_scores(rfm):
    """
    Convert raw values into 1–5 quintile scores.

    RECENCY is REVERSED: lower days = higher score.
    A customer who bought 2 days ago (score 5) is better
    than one who bought 500 days ago (score 1).

    FREQUENCY and MONETARY are normal:
    higher value = higher score.

    Uses pd.qcut (quantile-based bins) so each quintile
    has roughly the same number of customers.
    """
    result = rfm.copy()

    def safe_qcut(series, labels):
        """qcut with fallback to cut when values aren't distinct enough."""
        try:
            return pd.qcut(series, q=5, labels=labels, duplicates='drop').astype(int)
        except ValueError:
            return pd.cut(series, bins=5, labels=labels).astype(int)

    # Recency: REVERSE labels (5,4,3,2,1) so lower days = score 5
    result['r_score'] = safe_qcut(result['recency'],   [5, 4, 3, 2, 1])

    # Frequency and Monetary: normal order
    result['f_score'] = safe_qcut(result['frequency'], [1, 2, 3, 4, 5])
    result['m_score'] = safe_qcut(result['monetary'],  [1, 2, 3, 4, 5])

    # String concat: "543" means R=5, F=4, M=3
    result['rfm_score'] = (
        result['r_score'].astype(str) +
        result['f_score'].astype(str) +
        result['m_score'].astype(str)
    )

    # Numeric total for overall ranking (max possible = 15)
    result['rfm_total'] = result['r_score'] + result['f_score'] + result['m_score']

    logger.info("RFM scores (1–5) assigned per dimension")
    return result


# ─────────────────────────────────────────────
# 5. CUSTOMER SEGMENTATION
# ─────────────────────────────────────────────
def assign_segments(rfm_scored):
    """
    Map score combinations to named business segments.

    Priority order (first match wins):
    1. Champions          — R≥4, F≥4, M≥4
    2. Loyal Customers    — R≥3, F≥3, M≥3
    3. Potential Loyalists— R≥3, total≥9
    4. New Customers      — R≥4, F=1 (bought recently, first time)
    5. At Risk            — R≤2, previously active (F≥2 or M≥3)
    6. Lost               — R=1, F=1, M≤2
    7. Needs Attention    — everything else
    """

    def get_segment(row):
        r, f, m = row['r_score'], row['f_score'], row['m_score']
        total = row['rfm_total']

        if r >= 4 and f >= 4 and m >= 4:
            return 'Champions'
        elif r >= 3 and f >= 3 and m >= 3:
            return 'Loyal Customers'
        elif r >= 3 and total >= 9:
            return 'Potential Loyalists'
        elif r >= 4 and f == 1:
            return 'New Customers'
        elif r <= 2 and (f >= 2 or m >= 3):
            return 'At Risk'
        elif r == 1 and f == 1 and m <= 2:
            return 'Lost'
        else:
            return 'Needs Attention'

    rfm_scored = rfm_scored.copy()
    rfm_scored['segment'] = rfm_scored.apply(get_segment, axis=1)

    # Segment summary report for logging
    summary = rfm_scored.groupby('segment').agg(
        customer_count = ('customer_id', 'count'),
        avg_recency    = ('recency',     'mean'),
        avg_frequency  = ('frequency',   'mean'),
        avg_monetary   = ('monetary',    'mean'),
        total_revenue  = ('monetary',    'sum')
    ).round(2).reset_index()

    summary['pct_customers'] = (
        summary['customer_count'] / summary['customer_count'].sum() * 100
    ).round(1)

    logger.info(f"\n{'='*60}\nSegment Summary\n{'='*60}\n"
                f"{summary[['segment','customer_count','pct_customers','avg_monetary','total_revenue']].to_string(index=False)}")

    return rfm_scored, summary


# ─────────────────────────────────────────────
# 6. SAVE RESULTS TO DATABASE
# ─────────────────────────────────────────────
def save_rfm_to_database(rfm_final, conn, analysis_date=None):
    """
    Write RFM results to rfm_segments table.

    Uses INSERT ... ON DUPLICATE KEY UPDATE so:
    - First run of the day: inserts new records
    - Re-run same day: updates existing records (idempotent)
    """
    if analysis_date is None:
        analysis_date = date.today().isoformat()

    cursor = conn.cursor()

    upsert_sql = """
        INSERT INTO rfm_segments
            (customer_id, analysis_date, last_purchase_date,
             recency_days, frequency_count, monetary_total,
             r_score, f_score, m_score, rfm_score, rfm_total, segment)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            last_purchase_date = VALUES(last_purchase_date),
            recency_days       = VALUES(recency_days),
            frequency_count    = VALUES(frequency_count),
            monetary_total     = VALUES(monetary_total),
            r_score            = VALUES(r_score),
            f_score            = VALUES(f_score),
            m_score            = VALUES(m_score),
            rfm_score          = VALUES(rfm_score),
            rfm_total          = VALUES(rfm_total),
            segment            = VALUES(segment)
    """

    rows = []
    for _, row in rfm_final.iterrows():
        rows.append((
            int(row['customer_id']),
            analysis_date,
            row['last_purchase_date'].date().isoformat(),
            int(row['recency']),
            int(row['frequency']),
            float(row['monetary']),
            int(row['r_score']),
            int(row['f_score']),
            int(row['m_score']),
            row['rfm_score'],
            int(row['rfm_total']),
            row['segment']
        ))

    cursor.executemany(upsert_sql, rows)
    conn.commit()
    logger.info(f"Saved {len(rows):,} RFM records (analysis_date: {analysis_date})")
    cursor.close()


# ─────────────────────────────────────────────
# 7. MAIN ORCHESTRATOR
# ─────────────────────────────────────────────
def run_rfm_analysis(save_to_db=True):
    """
    Full RFM pipeline:
    Connect → Extract → Calculate → Score → Segment → (Save)
    Returns (rfm_final_df, segment_summary_df)
    """
    conn = None
    try:
        conn = get_db_connection()
        df = extract_transaction_data(conn)
        rfm = calculate_rfm(df)
        rfm_scored = assign_rfm_scores(rfm)
        rfm_final, summary = assign_segments(rfm_scored)

        if save_to_db:
            save_rfm_to_database(rfm_final, conn)

        return rfm_final, summary

    finally:
        if conn and conn.is_connected():
            conn.close()
            logger.info("Database connection closed")


# ─────────────────────────────────────────────
# STANDALONE EXECUTION
# ─────────────────────────────────────────────
if __name__ == '__main__':
    results, summary = run_rfm_analysis(save_to_db=True)

    print("\n" + "="*60)
    print("TOP CHAMPIONS")
    print("="*60)
    champions = results[results['segment'] == 'Champions'].sort_values(
        'monetary', ascending=False
    )
    print(champions[[
        'customer_name', 'recency', 'frequency',
        'monetary', 'rfm_score', 'segment'
    ]].to_string(index=False))

    print("\n" + "="*60)
    print("AT RISK CUSTOMERS")
    print("="*60)
    at_risk = results[results['segment'] == 'At Risk'].sort_values(
        'monetary', ascending=False
    )
    print(at_risk[[
        'customer_name', 'recency', 'frequency',
        'monetary', 'rfm_score', 'segment'
    ]].to_string(index=False))
