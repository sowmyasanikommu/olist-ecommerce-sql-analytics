- ============================================================
-- FILE:    02_import_data.sql
-- PROJECT: Olist E-Commerce SQL Business Analytics
-- AUTHOR:  Sowmya Sanikommu
-- PURPOSE: Import all 9 CSV files into PostgreSQL tables
-- NOTE:    Update file paths to match your local directory
--          Run 01_create_tables.sql before this script
-- ============================================================
 
-- CONTENTS:
--   1. Import customers
--   2. Import orders
--   3. Import order_items
--   4. Import products
--   5. Import sellers
--   6. Import payments
--   7. Import reviews
--   8. Import geolocation
--   9. Import category_translation
--  10. Row count verification
-- ============================================================
 
-- ============================================================
-- IMPORTANT: Update this base path to your local folder
-- Windows example: C:/olist_data/
-- Mac example:     /Users/yourname/olist_data/
-- ============================================================


-- ============================================================
-- 1. Import: customers
-- Expected rows: ~99,441
-- ============================================================

COPY customers FROM 'C:/olist_data/olist_customers_dataset.csv'
DELIMITER ',' CSV HEADER;


-- ============================================================
-- 2. Import: orders
-- Expected rows: ~99,441
-- ============================================================

COPY orders FROM 'C:/olist_data/olist_orders_dataset.csv'
DELIMITER ',' CSV HEADER;


-- ============================================================
-- 3. Import: order_items
-- Expected rows: ~112,650
-- ============================================================

COPY order_items FROM 'C:/olist_data/olist_order_items_dataset.csv'
DELIMITER ',' CSV HEADER;


 
-- ============================================================
-- 4. Import: products
-- Expected rows: ~32,951
-- ============================================================

COPY products FROM 'C:/olist_data/olist_products_dataset.csv'
DELIMITER ',' CSV HEADER;


-- ============================================================
-- 5. Import: sellers
-- Expected rows: ~3,095
-- ============================================================

COPY sellers FROM 'C:/olist_data/olist_sellers_dataset.csv'
DELIMITER ',' CSV HEADER;


-- ============================================================
-- 6. Import: payments
-- Expected rows: ~103,886
-- ============================================================

COPY payments FROM 'C:/olist_data/olist_order_payments_dataset.csv'
DELIMITER ',' CSV HEADER;


-- ============================================================
-- 7. Import: reviews
-- Expected rows: ~99,224
-- ============================================================

COPY reviews FROM 'C:/olist_data/olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;


-- ============================================================
-- 8. Import: geolocation
-- Expected rows: ~1,000,163
-- ============================================================

COPY geolocation FROM 'C:/olist_data/olist_geolocation_dataset.csv'
DELIMITER ',' CSV HEADER;


 
-- ============================================================
-- 9. Import: category_translation
-- Expected rows: ~71
-- ============================================================

COPY category_translation FROM 'C:/olist_data/product_category_name_translation.csv'
DELIMITER ',' CSV HEADER;


-- ============================================================
-- 10. VERIFICATION: Row count check for all tables
-- Compare against expected counts to confirm import success
-- ============================================================

SELECT 'customers'        AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders',          COUNT(*) FROM orders
UNION ALL
SELECT 'order_items',     COUNT(*) FROM order_items
UNION ALL
SELECT 'products',        COUNT(*) FROM products
UNION ALL
SELECT 'sellers',         COUNT(*) FROM sellers
UNION ALL
SELECT 'payments',        COUNT(*) FROM payments
UNION ALL
SELECT 'reviews',         COUNT(*) FROM reviews
UNION ALL
SELECT 'geolocation',     COUNT(*) FROM geolocation
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;
