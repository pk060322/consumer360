# Power BI DAX Measures — Consumer360

## Setup Instructions

1. In Power BI Desktop, create a blank table: **Home → Enter Data** → name it `_Measures` → Load
2. Delete the default column and use this table to store all measures
3. Add each measure below using **New Measure** (right-click `_Measures` table)

---

## Core Revenue Measures

```dax
Total Revenue =
    SUM(fact_sales[total_amount])

Total Transactions =
    COUNTROWS(fact_sales)

Unique Customers =
    DISTINCTCOUNT(fact_sales[customer_id])

Avg Order Value =
    DIVIDE([Total Revenue], [Total Transactions], 0)

Total Units Sold =
    SUM(fact_sales[quantity])
```

---

## Time Intelligence Measures

```dax
Revenue MoM % =
VAR CurrentMonth = [Total Revenue]
VAR PrevMonth    = CALCULATE([Total Revenue], DATEADD(dim_date[full_date], -1, MONTH))
RETURN
    DIVIDE(CurrentMonth - PrevMonth, PrevMonth, 0) * 100

Revenue YTD =
    CALCULATE([Total Revenue], DATESYTD(dim_date[full_date]))

Revenue Same Period Last Year =
    CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(dim_date[full_date]))

YoY Growth % =
    DIVIDE([Total Revenue] - [Revenue Same Period Last Year],
           [Revenue Same Period Last Year], 0) * 100
```

---

## Segment Measures

```dax
Champion Revenue =
    CALCULATE([Total Revenue],
        FILTER(rfm_segments, rfm_segments[segment] = "Champions"))

Champion Revenue % =
    DIVIDE([Champion Revenue], [Total Revenue], 0) * 100

Champion Count =
    CALCULATE(
        DISTINCTCOUNT(rfm_segments[customer_id]),
        rfm_segments[segment] = "Champions"
    )

At Risk Count =
    CALCULATE(
        DISTINCTCOUNT(rfm_segments[customer_id]),
        rfm_segments[segment] = "At Risk"
    )

Lost Customer Count =
    CALCULATE(
        DISTINCTCOUNT(rfm_segments[customer_id]),
        rfm_segments[segment] = "Lost"
    )
```

---

## KPI Card Formatting

For currency cards, use this format string: `₹#,##0.00`

For percentage cards: `0.0"%"`

For integer counts: `#,##0`

---

## Recommended Visuals Per Dashboard Page

### Page 1 — Revenue Overview
- Card: Total Revenue, Total Transactions, Avg Order Value, Unique Customers
- Line Chart: Monthly Revenue Trend (x = dim_date[month_name], y = Total Revenue)
- Bar Chart: Revenue by Region (x = dim_customer[region], y = Total Revenue)
- KPI: Revenue MoM %

### Page 2 — Customer Segmentation
- Donut Chart: rfm_segments[segment] by count
- Bar Chart: Total Revenue by Segment
- Table: Top 20 customers (name, segment, rfm_score, monetary_total)
- Slicer: rfm_segments[analysis_date]

### Page 3 — Product Performance
- Bar Chart: Top 10 Products by Revenue
- Matrix: dim_product[category] × dim_customer[region] with Total Revenue
- Scatter: quantity vs total_amount coloured by category

### Page 4 — Regional Sales
- Map: dim_customer[city] with bubble size = Total Revenue
- Bar Chart: Revenue by Region with MoM change
- Line Chart: Regional trends over months
