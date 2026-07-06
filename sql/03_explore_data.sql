-- ============================================================
-- FILE:    03_explore_data.sql
-- PROJECT: Olist E-Commerce SQL Business Analytics
-- AUTHOR:  Sowmya Sanikommu
-- PURPOSE: Initial data exploration to understand
--          structure, relationships, and data quality
--          before performing business analysis
-- ============================================================
 
-- CONTENTS:
--   1. Preview each table
--   2. Order status distribution
--   3. Date range of dataset
--   4. Top customer states
--   5. Sample joined data view
-- ============================================================
 
 
-- ============================================================
-- 1. PREVIEW EACH TABLE (first 5 rows)
-- ============================================================
 
-- Orders: Central fact table
SELECT * FROM orders LIMIT 5;
 
-- Customers: Who is buying?
SELECT * FROM customers LIMIT 5;
 
-- Order Items: What is inside each order?
SELECT * FROM order_items LIMIT 5;
 
-- Products: What products are sold?
SELECT * FROM products LIMIT 5;
 
-- Payments: How are customers paying?
SELECT * FROM payments LIMIT 5;
 
-- Reviews: What do customers think?
SELECT * FROM reviews LIMIT 5;
 
 
-- ============================================================
-- 2. ORDER STATUS DISTRIBUTION
-- Understanding how many orders reached each stage
-- ============================================================
 
SELECT
    order_status,
    COUNT(*)                                        AS total_orders,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER()::NUMERIC,
        2
    )                                               AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
 
 
-- ============================================================
-- 3. DATE RANGE OF THE DATASET
-- Critical for scoping the analysis period correctly
-- ============================================================
 
SELECT
    MIN(order_purchase_timestamp)::DATE             AS first_order_date,
    MAX(order_purchase_timestamp)::DATE             AS last_order_date,
    MAX(order_purchase_timestamp)::DATE
        - MIN(order_purchase_timestamp)::DATE       AS days_of_data,
    COUNT(DISTINCT
        DATE_TRUNC('month', order_purchase_timestamp)
    )                                               AS total_months
FROM orders;
 
 
-- ============================================================
-- 4. TOP 10 CUSTOMER STATES BY ORDER VOLUME
-- First look at geographic distribution
-- ============================================================
 
SELECT
    customer_state,
    COUNT(*)                                        AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC
LIMIT 10;
 
 
-- ============================================================
-- 5. SAMPLE JOINED DATA
-- Verify table relationships work correctly
-- ============================================================
 
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state,
    p.payment_type,
    p.payment_value,
    r.review_score
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN payments p
    ON o.order_id = p.order_id
LEFT JOIN reviews r
    ON o.order_id = r.order_id
LIMIT 10;
 
