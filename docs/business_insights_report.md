# Business Insights Report — Consumer360

## Executive Summary

This report demonstrates how to extract actionable business insights from the
Consumer360 RFM segmentation platform. Each insight is paired with a recommended
marketing action and a measurable success metric.

---

## Insight 1 — Champions Drive Revenue Concentration

**Finding:**
In most retail businesses, the top 10–15% of customers (Champions) generate
45–55% of total revenue. This is a direct manifestation of the Pareto Principle.

**How to find it in your dashboard:**
- Dashboard Page 2 → Champion Revenue % card
- Bar chart: Revenue by Segment

**Recommended Action:**
- Launch a VIP loyalty tier exclusively for Champions
- Offer early access to new products
- Request testimonials and referrals (Champions are your best brand advocates)
- Assign a dedicated customer success contact for top 50 Champions by monetary value

**Success Metric:**
Champion segment revenue share maintained above 45% quarter-over-quarter.

---

## Insight 2 — At-Risk Customers: The 90-Day Window

**Finding:**
Customers classified as At Risk were previously active but have gone quiet.
Analysis typically shows their last purchase was 90–180 days ago.
Recovery rate drops sharply after 180 days — acting within the 90-day window
recovers 3–4x more customers than campaigns sent after 6 months.

**How to find it in your dashboard:**
- Dashboard Page 2 → At Risk Count card
- Filter rfm_segments table: segment = 'At Risk', sort by recency_days ascending
- These are your most urgent contacts

**SQL to identify the priority list:**
```sql
SELECT
    dc.first_name, dc.last_name, dc.email,
    rs.recency_days,
    rs.monetary_total,
    rs.rfm_score
FROM rfm_segments rs
JOIN dim_customer dc ON rs.customer_id = dc.customer_id
WHERE rs.segment = 'At Risk'
  AND rs.analysis_date = CURDATE()
ORDER BY rs.monetary_total DESC;
```

**Recommended Action:**
- Send personalised win-back email within 48 hours of segment assignment
- Subject line: "We miss you, [First Name] — here's 15% off your next order"
- Include product recommendations based on their purchase history
- Follow up with SMS if no open within 3 days

**Success Metric:**
Win-back conversion rate > 12% within 30 days of campaign send.

---

## Insight 3 — Potential Loyalists: The Growth Engine

**Finding:**
Potential Loyalists bought recently and have moderate frequency.
They are one habit away from becoming Loyal Customers or Champions.
Converting just 20% of Potential Loyalists into Loyal Customers can increase
overall revenue by 8–12%.

**Recommended Action:**
- Invite them to your loyalty programme
- Offer double points on their next 3 purchases
- Send "Complete your collection" campaigns based on category affinities

**Success Metric:**
% of Potential Loyalists who make a second purchase within 60 days.

---

## Insight 4 — Regional Growth Opportunity

**Finding:**
Compare segment distribution by region. A region with high Potential Loyalists
but few Champions is a maturing market — the customer base is growing but not
yet fully converting to high-value behaviour.

**How to find it in your dashboard:**
- Dashboard Page 4 → Regional Sales
- Cross-filter Page 2 by region to compare segment mix

**SQL to find regional segment breakdown:**
```sql
SELECT
    dc.region,
    rs.segment,
    COUNT(*)                       AS customer_count,
    ROUND(AVG(rs.monetary_total),0) AS avg_spend
FROM rfm_segments rs
JOIN dim_customer dc ON rs.customer_id = dc.customer_id
WHERE rs.analysis_date = (SELECT MAX(analysis_date) FROM rfm_segments)
GROUP BY dc.region, rs.segment
ORDER BY dc.region, customer_count DESC;
```

**Recommended Action:**
- Prioritise loyalty programme rollout in regions with high Potential Loyalist ratio
- Run region-specific promotions timed to peak local shopping seasons

---

## Insight 5 — Product-Segment Affinity

**Finding:**
Joining RFM segments with product purchase data reveals which categories your
Champions and Loyal Customers buy most. These are your "gateway premium products"
— the items that, once purchased, tend to convert customers into higher segments.

**SQL to find Champion product affinity:**
```sql
SELECT
    dp.category,
    dp.product_name,
    COUNT(*)                       AS champion_purchases,
    ROUND(SUM(fs.total_amount),0)  AS revenue_from_champions
FROM fact_sales fs
JOIN dim_product dp    ON fs.product_id  = dp.product_id
JOIN rfm_segments rs   ON fs.customer_id = rs.customer_id
WHERE rs.segment = 'Champions'
  AND rs.analysis_date = (SELECT MAX(analysis_date) FROM rfm_segments)
GROUP BY dp.category, dp.product_id, dp.product_name
ORDER BY champion_purchases DESC
LIMIT 10;
```

**Recommended Action:**
- Feature these gateway products prominently in campaigns targeting Potential Loyalists
- Use them as "first purchase" recommendations in onboarding emails for New Customers

---

## Presenting Insights to Leadership

When presenting to executives, always use this structure:

1. **Situation** — What does the data show? (1 sentence)
2. **Implication** — Why does this matter to the business? (1–2 sentences)
3. **Recommended Action** — What should we do? (Specific, time-bound)
4. **Expected Outcome** — What result do we expect? (Quantified)
5. **How We Measure** — Which metric confirms success? (Single KPI)

Example:

> **Situation:** 23% of our customers (At Risk segment) have not purchased in
> over 90 days despite previously averaging 3 transactions per year.
>
> **Implication:** At their historical spend rate, this represents ₹18 lakh in
> at-risk annual revenue.
>
> **Recommended Action:** Launch a targeted win-back campaign to At Risk
> customers this week, personalised by their top product category,
> with a time-limited 15% discount.
>
> **Expected Outcome:** Based on industry benchmarks, a 12–15% win-back
> conversion rate would recover ₹2.2–2.7 lakh in the next 30 days.
>
> **Measure:** Win-back conversion rate tracked weekly in the Consumer360 dashboard.
