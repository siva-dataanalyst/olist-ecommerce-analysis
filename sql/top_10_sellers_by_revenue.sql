


-- ============================================
-- Analysis: Top 10 sellers by total revenue
-- Output: seller_id, state, total_orders, total_revenue
-- Insight: SP dominates; BA seller at rank 2 shows high avg order value
--          despite low order volume (~622 BRL/order vs ~203 BRL for rank 1)
-- ============================================
SELECT TOP 10
    s.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_state
ORDER BY total_revenue DESC;
