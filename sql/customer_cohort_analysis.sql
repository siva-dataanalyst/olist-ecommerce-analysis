-- ============================================
-- Analysis: Customer Cohort Analysis
-- Output: cohort_month, order_month, cohort_size, retained_customers, retention_rate
-- Insight: Retention consistently below 1% across all cohorts
--          Largest cohort: Nov 2017 (7,060 customers) — Black Friday effect
--          Highest retention always in Month+1, drops sharply after
--          Confirms 96.88% one-time buyer finding from retention query
-- ============================================
WITH first_purchases AS (
    SELECT 
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order_date,
        FORMAT(MIN(o.order_purchase_timestamp), 'yyyy-MM') AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM first_purchases
    GROUP BY cohort_month
),
cohort_activity AS (
    SELECT 
        fp.cohort_month,
        FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
        COUNT(DISTINCT c.customer_unique_id) AS retained_customers
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN first_purchases fp ON c.customer_unique_id = fp.customer_unique_id
    WHERE o.order_status = 'delivered'
    GROUP BY fp.cohort_month, FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
)
SELECT 
    ca.cohort_month,
    ca.order_month,
    cs.cohort_size,
    ca.retained_customers,
    ROUND(ca.retained_customers * 100.0 / cs.cohort_size, 2) AS retention_rate
FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.order_month;