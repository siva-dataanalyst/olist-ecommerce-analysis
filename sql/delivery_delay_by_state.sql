-- ============================================
-- Analysis: Average delivery delay by state
-- Output: state, total_orders, avg_delay_days
-- Insight: ALL states show negative delay (early delivery)
--          Remote states (AC, RO, AM) show highest early delivery (-20 days)
--          Suggests Olist deliberately pads estimates for customer satisfaction
--          Worst performers: AL (-8), MA (-9) — northeastern states
-- ============================================
SELECT 
    c.customer_state,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(DATEDIFF(day, 
        o.order_estimated_delivery_date, 
        o.order_delivered_customer_date)), 2) AS avg_delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delay_days ASC;