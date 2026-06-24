-- ============================================
-- Analysis: RFM Score Calculation
-- KEY FINDINGS:
-- 1. High spenders are mostly one-time buyers (frequency = 1)
--    confirms 96.88% one-time buyer trend from Day 1
--
-- 2. Top customer spent 13,440 BRL but last bought 334 days ago
--    → High monetary, poor recency = likely "At Risk" or "Lost"
--
-- 3. Customer with 45-day recency + 7,160 BRL spend
--    → Most promising: Recent + High Value
--
-- 4. Customer with 35-day recency + 6,729 BRL spend
--    → Another strong recent buyer worth targeting
--
-- 5. Recency ranges from 35 to 563 days
--    → Huge spread = segmentation will be highly meaningful
--
-- BUSINESS IMPLICATION:
--    Olist needs re-engagement campaigns for high-spend,
--    low-recency customers to recover lost revenue potential
-- ============================================
WITH reference_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date
    FROM orders
    WHERE order_status = 'delivered'
),
rfm_raw AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(day, MAX(o.order_purchase_timestamp), (SELECT max_date FROM reference_date)) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price), 2) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT * FROM rfm_raw
ORDER BY monetary DESC;