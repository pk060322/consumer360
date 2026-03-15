"""
============================================================
Consumer360 | pipeline_master.py
Master Automation Pipeline

Runs the full ETL + RFM refresh automatically.
Schedule with Windows Task Scheduler or Linux cron.

Usage:
    python pipeline_master.py

Schedule (Windows Task Scheduler):
    Program: python.exe
    Arguments: C:\Projects\consumer360\python\pipeline_master.py

Schedule (Linux cron — every Monday 6 AM):
    0 6 * * 1 /usr/bin/python3 /home/user/consumer360/python/pipeline_master.py
============================================================
"""

import logging
import sys
import os
from datetime import date, datetime

# Ensure logs directory exists
os.makedirs('../logs', exist_ok=True)

# ─────────────────────────────────────────────
# LOGGING: write to file AND console
# ─────────────────────────────────────────────
log_file = f'../logs/pipeline_{date.today().strftime("%Y%m%d")}.log'

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(levelname)-8s | %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    handlers=[
        logging.FileHandler(log_file, encoding='utf-8'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Import RFM engine functions
from rfm_engine import (
    get_db_connection,
    extract_transaction_data,
    calculate_rfm,
    assign_rfm_scores,
    assign_segments,
    save_rfm_to_database
)


def run_pipeline():
    """
    Orchestrates the full Consumer360 pipeline in 5 steps.
    Returns exit code: 0 = success, 1 = failure.
    """
    start_time = datetime.now()
    today = date.today()

    logger.info("=" * 60)
    logger.info(f"  CONSUMER360 PIPELINE  |  {today}")
    logger.info("=" * 60)

    conn = None
    try:
        # ── Step 1: Database connection ──────────────────────────
        logger.info("Step 1/5 — Connecting to database...")
        conn = get_db_connection()
        logger.info("Step 1/5 — ✓ Connected")

        # ── Step 2: Extract transactions ─────────────────────────
        logger.info("Step 2/5 — Extracting transaction data...")
        df = extract_transaction_data(conn)
        if df.empty:
            logger.warning("No transactions found. Pipeline stopping.")
            return 1
        logger.info(f"Step 2/5 — ✓ {len(df):,} rows extracted")

        # ── Step 3: Calculate RFM values ─────────────────────────
        logger.info("Step 3/5 — Calculating RFM values...")
        rfm = calculate_rfm(df, analysis_date=today)
        logger.info(f"Step 3/5 — ✓ RFM calculated for {len(rfm):,} customers")

        # ── Step 4: Score and segment ─────────────────────────────
        logger.info("Step 4/5 — Scoring and segmenting customers...")
        rfm_scored = assign_rfm_scores(rfm)
        rfm_final, segment_summary = assign_segments(rfm_scored)
        logger.info("Step 4/5 — ✓ Segmentation complete")

        # ── Step 5: Save to database ──────────────────────────────
        logger.info("Step 5/5 — Saving results to database...")
        save_rfm_to_database(rfm_final, conn, analysis_date=today.isoformat())
        logger.info("Step 5/5 — ✓ Results saved")

        # ── Summary ───────────────────────────────────────────────
        elapsed = (datetime.now() - start_time).seconds
        logger.info("=" * 60)
        logger.info(f"  PIPELINE COMPLETED SUCCESSFULLY  |  {elapsed}s")
        logger.info("=" * 60)
        logger.info("\nSegment breakdown:\n" +
                    segment_summary[['segment', 'customer_count', 'total_revenue']].to_string(index=False))
        return 0

    except Exception as e:
        elapsed = (datetime.now() - start_time).seconds
        logger.error("=" * 60)
        logger.error(f"  PIPELINE FAILED  |  {elapsed}s")
        logger.error(f"  Error: {e}")
        logger.error("=" * 60, exc_info=True)
        return 1

    finally:
        if conn and conn.is_connected():
            conn.close()
            logger.info("Database connection closed")


if __name__ == '__main__':
    exit_code = run_pipeline()
    sys.exit(exit_code)
