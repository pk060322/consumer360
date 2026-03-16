# ============================================================
# Consumer360 | db_config.py
# Database connection configuration
# ⚠️  UPDATE CREDENTIALS BEFORE RUNNING
# ⚠️  Never commit real passwords to GitHub
# ============================================================

import os

DB_CONFIG = {
    'host':     os.getenv('DB_HOST',     'localhost'),
    'port':     int(os.getenv('DB_PORT', '3306')),
    'database': os.getenv('DB_NAME',     'consumer360'),
    'user':     os.getenv('DB_USER',     'root'),       # ← update this
    'password': os.getenv('DB_PASSWORD', 'Pankaj@11'),  # ← update this
    'charset':  'utf8mb4',
    'autocommit': False
}

# How to use environment variables instead of hardcoding:
# Windows:  set DB_PASSWORD=mypassword
# Mac/Linux: export DB_PASSWORD=mypassword
# Then the os.getenv() calls above will pick it up automatically
