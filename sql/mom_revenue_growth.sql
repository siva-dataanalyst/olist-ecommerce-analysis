

-- ============================================
-- Analysis: Month-over-Month revenue growth
-- Output: order_month, total_revenue, prev_month_revenue, mom_growth_pct
-- Insight: Nov 2017 highest MoM growth (+52.37%) — Black Friday effect
--          2016-12 and 2017-01 are data artifacts (incomplete month + 1 order)
--          Revenue peaks at ~R$987K in Nov 2017, stabilizes ~R$900K in 2018
-- ============================================
SELECT 
    order_month,
    total_revenue,
    prev_month_revenue,
    ROUND(
        (total_revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 
    2) AS mom_growth_pct
FROM (
    SELECT 
        FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
        SUM(oi.price) AS total_revenue,
        LAG(SUM(oi.price)) OVER (ORDER BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')) AS prev_month_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
) AS monthly_revenue
ORDER BY order_month;