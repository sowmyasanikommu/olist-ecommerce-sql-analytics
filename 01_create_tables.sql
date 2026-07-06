-- ============================================================
-- FILE   : 01_create_tables.sql
-- PROJECT: Olist E-Commerce SQL Business Analytics
-- AUTHOR : Sowmya Sanikommu
-- PURPOSE: Create all 9 tables for the Olist database schema
-- NOTE   : Run this script first before any data import

-- ============================================================
-- CONTENTS:
--   1. customers
--   2. orders
--   3. order_items
--   4. products
--   5. sellers
--   6. payments
--   7. reviews
--   8. geolocation
--   9. category_translation
-- ============================================================

-- ============================================================
-- SAFETY CHECK: Drop tables if they already exist
-- (Run only if starting fresh)
-- ============================================================

DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS geolocation;
DROP TABLE IF EXISTS category_translation;

-- ============================================================
-- TABLE 1: customers
-- One row per customer order (customer_id is per order)
-- customer_unique_id identifies the actual person
-- ============================================================
 
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);

-- ============================================================
-- TABLE 2: orders
-- Central fact table — every order ever placed on Olist
-- Contains order lifecycle timestamps
-- ============================================================

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- ============================================================
-- TABLE 3: order_items
-- One row per item within an order
-- An order can contain multiple items (multiple rows)
-- ============================================================

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);

 
-- ============================================================
-- TABLE 4: products
-- Product catalogue with dimensions and category info
-- product_category_name is in Portuguese
-- ============================================================

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);


-- ============================================================
-- TABLE 5: sellers
-- Seller registry with location information
-- ============================================================

CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state VARCHAR(5)
);


-- ============================================================
-- TABLE 6: payments
-- One row per payment sequence per order
-- An order can have multiple payment entries (installments)
-- ============================================================

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value NUMERIC(10,2)
);


-- ============================================================
-- TABLE 7: reviews
-- Customer satisfaction ratings per order
-- review_score: 1 (worst) to 5 (best)
-- ============================================================

CREATE TABLE reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title VARCHAR(100),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


-- ============================================================
-- TABLE 8: geolocation
-- Maps Brazilian zip codes to lat/long coordinates
-- Large table: ~1 million rows
-- ============================================================

CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat NUMERIC(10,6),
    geolocation_lng NUMERIC(10,6),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(5)
);


 
-- ============================================================
-- TABLE 9: category_translation
-- Maps Portuguese category names to English
-- Used in all category-level analysis
-- ============================================================

CREATE TABLE category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);


-- ============================================================
-- VERIFICATION: Confirm all 9 tables were created
-- ============================================================

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;




