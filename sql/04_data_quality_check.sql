-- ============================================
-- FILE   : 04_data_quality_check.sql
-- PROJECT: Olist E-Commerce SQL Analytics
-- AUTHOR : Sowmya Sanikommu
-- DATE   : 2024
-- PURPOSE: Data quality checks and cleaning
--          before core business analysis
-- ============================================

-- CONTENTS:
-- 1. NULL Value Check
-- 2. Order Status Distribution
-- 3. Duplicate Order Check
-- 4. Date Range Validation
-- 5. Product Category Quality Check
-- 6. Foreign Keys
-- 7. Indexes
-- 8. Master View Creation
-- 9. Delivery Performance Check
-- ============================================
-- Check for NULL values in orders table

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(order_id) AS null_order_id,
    COUNT(*) - COUNT(customer_id) AS null_customer_id,
    COUNT(*) - COUNT(order_status) AS null_order_status,
    COUNT(*) - COUNT(order_purchase_timestamp) AS null_purchase_date,
    COUNT(*) - COUNT(order_approved_at) AS null_approved_date,
    COUNT(*) - COUNT(order_delivered_carrier_date) AS null_carrier_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS null_delivery_date,
    COUNT(*) - COUNT(order_estimated_delivery_date) AS null_estimated_date
FROM orders;


-- What order statuses exist and how many?
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Are there any duplicate order IDs?
SELECT
    order_id,
    COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- What time period does our data cover?
SELECT
    MIN(order_purchase_timestamp)::DATE AS first_order_date,
    MAX(order_purchase_timestamp)::DATE AS last_order_date,
    MAX(order_purchase_timestamp)::DATE - 
    MIN(order_purchase_timestamp)::DATE AS days_of_data,
    COUNT(DISTINCT DATE_TRUNC('month', order_purchase_timestamp)) AS total_months
FROM orders;


-- How many products have missing category names?
SELECT
    COUNT(*) AS total_products,
    COUNT(product_category_name) AS products_with_category,
    COUNT(*) - COUNT(product_category_name) AS missing_category,
    ROUND((COUNT(*) - COUNT(product_category_name)) * 100.0 / COUNT(*), 2) 
    AS missing_percentage
FROM products;


-- Add Foreign Key: orders → customers
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Add Foreign Key: order_items → orders
ALTER TABLE order_items
ADD CONSTRAINT fk_items_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Add Foreign Key: order_items → products
ALTER TABLE order_items
ADD CONSTRAINT fk_items_products
FOREIGN KEY (product_id) REFERENCES products(product_id);

-- Add Foreign Key: order_items → sellers
ALTER TABLE order_items
ADD CONSTRAINT fk_items_sellers
FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);

-- Add Foreign Key: payments → orders
ALTER TABLE payments
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Add Foreign Key: reviews → orders
ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_orders
FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- Index on orders date (used in almost every time-based query)
CREATE INDEX idx_orders_purchase_date 
ON orders(order_purchase_timestamp);

-- Index on orders customer_id (used in JOIN operations)
CREATE INDEX idx_orders_customer_id 
ON orders(customer_id);

-- Index on order_items order_id (used in JOIN operations)
CREATE INDEX idx_order_items_order_id 
ON order_items(order_id);

-- Index on order_items product_id
CREATE INDEX idx_order_items_product_id 
ON order_items(product_id);

-- Index on payments order_id
CREATE INDEX idx_payments_order_id 
ON payments(order_id);

-- Index on reviews order_id
CREATE INDEX idx_reviews_order_id 
ON reviews(order_id);


-- Create a master analytics view
CREATE VIEW vw_orders_master AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    c.customer_city,
    c.customer_state,
    p.payment_type,
    p.payment_value,
    r.review_score,
    -- Calculate delivery days
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
        THEN DATE_PART('day',
             o.order_delivered_customer_date -
             o.order_purchase_timestamp)
        ELSE NULL
    END AS delivery_days,
    -- Was delivery on time?
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN 'On Time'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'Not Delivered'
    END AS delivery_status
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN reviews r ON o.order_id = r.order_id;


SELECT * FROM vw_orders_master LIMIT 10;


-- Test 1: How many rows does the view have?
SELECT COUNT(*) FROM vw_orders_master;

-- Test 2: Check delivery status breakdown
SELECT delivery_status, COUNT(*) AS total
FROM vw_orders_master
GROUP BY delivery_status
ORDER BY total DESC;

-- Test 3: Average delivery days
SELECT
    ROUND(AVG(delivery_days)::NUMERIC, 1) AS avg_delivery_days
FROM vw_orders_master
WHERE delivery_days IS NOT NULL;
