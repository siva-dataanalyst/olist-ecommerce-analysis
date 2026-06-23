-- ============================================
-- Analysis: Running total of revenue by month
-- Output: order_month, monthly_revenue, running_total, pct_of_total
-- Insight: Total business revenue = R$13.2 million
--          50% of all revenue earned by Jan 2018
--          Nov 2017 alone contributed 7% of total revenue (Black Friday)
--          2018 contributed 54.59% vs 45.41% for 2016-2017 combined
--          Business clearly accelerating into 2018
-- ============================================
WITH monthly_revenue AS (
    SELECT 
        FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
        ROUND(SUM(oi.price), 2) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
),
running_total AS (
    SELECT 
        order_month,
        monthly_revenue,
        ROUND(SUM(monthly_revenue) OVER (
            ORDER BY order_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2) AS running_total
    FROM monthly_revenue
),
final_calc AS (
    SELECT 
        order_month,
        monthly_revenue,
        running_total,
        ROUND(running_total * 100.0 / SUM(monthly_revenue) OVER(), 2) AS pct_of_total
    FROM running_total
)
SELECT * FROM final_calc
ORDER BY order_month;