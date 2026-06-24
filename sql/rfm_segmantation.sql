-- ============================================
-- KEY FINDINGS:
-- 1. "Lost" segment has HIGHEST avg spend (271 BRL)
--    → Only 621 customers, 45-day recency
--    → High-value one-time buyers, not truly lost
--    → Priority target for win-back campaigns
--
-- 2. "Champions" have LOWEST avg spend (39 BRL)
--    → Frequent buyers purchase low-ticket items
--    → Olist's repeat buyers ≠ high-value buyers
--    → Loyalty ≠ Revenue on this platform
--
-- 3. "Needs Attention" = largest segment (31,219 customers)
--    → 229 BRL avg spend, 156-day recency
--    → Biggest revenue recovery opportunity
--
-- 4. Frequency = 1 across ALL segments
--    → Confirms 96.88% one-time buyer problem from Day 1
--    → Olist has a structural repeat-purchase challenge
--
-- 5. Potential Loyalist avg recency = 395 days (over 1 year)
--    → 27,503 customers gone cold
--    → Re-engagement likely very difficult at this stage
--
-- BUSINESS IMPLICATION:
--    Olist's biggest opportunity is NOT rewarding champions
--    but RECOVERING high-spend lost customers and converting
--    31,219 "Needs Attention" customers before they go cold
-- ============================================
WITH reference_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date
    FROM orders
    WHERE order_status = 'delivered'
),
rfm_raw AS (
    SELECT
        c.customer_unique_id,
        DATEDIFF(day, MAX(o.order_purchase_timestamp), 
            (SELECT max_date FROM reference_date)) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oi.price), 2) AS monetary
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scored AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        -- Lower recency days = better = higher score
        NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm_raw
),
rfm_segmented AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        (r_score + f_score + m_score) AS total_rfm_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 
                THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 
                THEN 'Loyal Customer'
            WHEN r_score >= 3 AND f_score <= 2 
                THEN 'Potential Loyalist'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 
                THEN 'At Risk'
            WHEN r_score = 1 AND f_score = 1 
                THEN 'Lost'
            ELSE 
                'Needs Attention'
        END AS customer_segment
    FROM rfm_scored
)
SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary), 2) AS avg_spend,
    ROUND(AVG(recency_days), 2) AS avg_recency_days,
    ROUND(AVG(frequency), 2) AS avg_frequency
FROM rfm_segmented
GROUP BY customer_segment
ORDER BY avg_spend DESC;