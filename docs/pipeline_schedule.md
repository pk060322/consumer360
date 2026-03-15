# Pipeline Scheduling Guide — Consumer360

## Overview

The `pipeline_master.py` script should run automatically on a regular schedule.
Recommended: every Monday at 6:00 AM before business hours.

---

## Option A: Windows Task Scheduler

1. Press `Win + S` → search for **Task Scheduler** → Open
2. Click **Create Basic Task** in the right panel
3. Fill in the wizard:

   | Field | Value |
   |---|---|
   | Name | Consumer360 RFM Pipeline |
   | Description | Weekly RFM customer segmentation refresh |
   | Trigger | Weekly |
   | Day | Monday |
   | Time | 6:00 AM |
   | Action | Start a program |
   | Program | `C:\Python311\python.exe` (your Python path) |
   | Arguments | `C:\Projects\consumer360\python\pipeline_master.py` |
   | Start in | `C:\Projects\consumer360\python` |

4. Check **Run whether user is logged on or not**
5. Check **Run with highest privileges**
6. Click Finish

**Verify it works:**
Right-click the task → Run → check `logs/pipeline_YYYYMMDD.log`

---

## Option B: Linux / Mac (Cron)

```bash
# Open crontab editor
crontab -e

# Add this line — runs every Monday at 6:00 AM
0 6 * * 1 /usr/bin/python3 /home/user/consumer360/python/pipeline_master.py >> /home/user/consumer360/logs/cron.log 2>&1
```

Cron syntax reference: `minute hour day month weekday`
- `0 6 * * 1` = minute 0, hour 6, any day, any month, Monday (1)

**Verify cron is running:**
```bash
grep CRON /var/log/syslog | tail -20
```

---

## Log Files

Logs are written to `logs/pipeline_YYYYMMDD.log`.
Each run creates a new dated file.

Example log output:
```
2024-12-02 06:00:01 | INFO     | ============================================================
2024-12-02 06:00:01 | INFO     |   CONSUMER360 PIPELINE  |  2024-12-02
2024-12-02 06:00:01 | INFO     | ============================================================
2024-12-02 06:00:01 | INFO     | Step 1/5 — Connecting to database...
2024-12-02 06:00:01 | INFO     | Step 1/5 — ✓ Connected
2024-12-02 06:00:02 | INFO     | Step 2/5 — ✓ 28 rows extracted
2024-12-02 06:00:02 | INFO     | Step 3/5 — ✓ RFM calculated for 10 customers
2024-12-02 06:00:02 | INFO     | Step 4/5 — ✓ Segmentation complete
2024-12-02 06:00:02 | INFO     | Step 5/5 — ✓ Results saved
2024-12-02 06:00:02 | INFO     | PIPELINE COMPLETED SUCCESSFULLY  |  1s
```

---

## Monitoring

Add email alerts by importing Python's `smtplib` in `pipeline_master.py`:

```python
import smtplib
from email.mime.text import MIMEText

def send_alert(subject, body):
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From']    = 'pipeline@yourcompany.com'
    msg['To']      = 'analyst@yourcompany.com'
    with smtplib.SMTP('smtp.gmail.com', 587) as server:
        server.starttls()
        server.login('your_email', 'app_password')
        server.send_message(msg)

# Call on failure:
# send_alert('Consumer360 Pipeline FAILED', str(error))
```
