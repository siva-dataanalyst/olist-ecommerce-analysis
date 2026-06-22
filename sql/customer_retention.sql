

-- ============================================
-- Analysis: Customer retention — repeat vs one-time buyers
-- Output: purchase_type, customer_count, percentage
-- Insight: 96.88% one-time buyers indicates critically low retention
--          Industry avg ~20-30%; signals acquisition-heavy, retention-weak model
--          Recommendation: investigate post-purchase experience & loyalty programs
-- ============================================
SELECT 
    purchase_type,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM (
    SELECT 
        customer_unique_id,
        CASE 
            WHEN COUNT(o.order_id) > 1 THEN 'Repeat Buyer'
            ELSE 'One-Time Buyer'
        END AS purchase_type
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY customer_unique_id
) AS buyer_segments
GROUP BY purchase_type;