create database olist_analytics;

use olist_analytics;


-- ============================================
-- Data Quality Check: Inspect rows with NULL lat/lng
-- (geolocation table — investigating dropped cells during import)
-- ============================================
SELECT TOP 20 *
FROM geolocation
WHERE geolocation_lat IS NULL OR geolocation_lng IS NULL;


-- ============================================
-- Schema Check: Confirm data type/precision of lat/lng columns
-- (Ruling out precision overflow as root cause of NULLs)
-- ============================================
SELECT COLUMN_NAME, DATA_TYPE, NUMERIC_PRECISION, NUMERIC_SCALE
FROM olist_analytics.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'geolocation'
AND COLUMN_NAME IN ('geolocation_lat', 'geolocation_lng');


-- ============================================
-- Validation Check: Row counts across all imported tables
-- (Confirms successful import of all 9 raw CSVs into SQL Server)
-- ============================================
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM category_translation
ORDER BY table_name;


-- ============================================
-- Validation Check: Confirm each seller_id maps to exactly one state
-- (Confirms it's safe to GROUP BY seller_id + seller_state together)
-- ============================================
SELECT seller_id, COUNT(DISTINCT seller_state) AS state_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(DISTINCT seller_state) > 1;








