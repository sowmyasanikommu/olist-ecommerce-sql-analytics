-- BQ1: Monthly Revenue Trend Analysis
-- Purpose: Track Olist's revenue growth month by month
-- Author:Sowmya Sanikommu 

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS month,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC,
        2
    ) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
AND o.order_purchase_timestamp >= '2017-01-01'
AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY 1
ORDER BY 1;


-- BQ2: Revenue by Product Category
-- Purpose: Identify top performing product categories
-- Author: SOWMYA SANIKOMMU

SELECT
    COALESCE(
        ct.product_category_name_english,
        'Uncategorized'
    )                                    AS category,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC,
        2
    )                                    AS total_revenue,
    COUNT(DISTINCT o.order_id)           AS total_orders,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC
        / COUNT(DISTINCT o.order_id),
        2
    )                                    AS avg_order_value,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC
        * 100.0
        / SUM(SUM(oi.price + oi.freight_value))
          OVER()::NUMERIC,
        2
    )                                    AS revenue_percentage
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name =
       ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY ct.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 15;


-- BQ3: Revenue by Brazilian State
-- Purpose: Identify highest value geographic markets
-- Author: SOWMYA SANIKOMMU

SELECT
    c.customer_state,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC,
        2
    )                                     AS total_revenue,
    COUNT(DISTINCT o.order_id)            AS total_orders,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC
        / COUNT(DISTINCT o.order_id),
        2
    )                                     AS avg_order_value,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC
        * 100.0
        / SUM(SUM(oi.price + oi.freight_value))
          OVER()::NUMERIC,
        2
    )                                     AS revenue_percentage
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;
   

-- BQ4: Payment Method Analysis
-- Purpose: Understand customer payment preferences
-- Author: SOWMYA SANIKOMMU

WITH total_revenue AS (
    SELECT SUM(p.payment_value) AS grand_total
    FROM payments p
    JOIN orders o ON p.order_id = o.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    p.payment_type,
    COUNT(DISTINCT o.order_id)              AS total_orders,
    ROUND(
        SUM(p.payment_value)::NUMERIC,
        2
    )                                       AS total_revenue,
    ROUND(
        SUM(p.payment_value)::NUMERIC
        / COUNT(DISTINCT o.order_id),
        2
    )                                       AS avg_order_value,
    ROUND(
        AVG(p.payment_installments)::NUMERIC,
        1
    )                                       AS avg_installments,
    ROUND(
        SUM(p.payment_value)::NUMERIC
        * 100.0
        / t.grand_total::NUMERIC,
        2
    )                                       AS revenue_percentage
FROM payments p
JOIN orders o
    ON p.order_id = o.order_id
CROSS JOIN total_revenue t
WHERE o.order_status = 'delivered'
GROUP BY
    p.payment_type,
    t.grand_total
ORDER BY total_revenue DESC;


-- BQ5: Review Score vs Delivery Performance
-- Purpose: Prove connection between delivery 
--          speed and customer satisfaction
-- Author: Ganesh Reddy Dodda

-- PART A: Your Version — Delivery Status vs Reviews
SELECT
    CASE
        WHEN o.order_delivered_customer_date
             <= o.order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END                                    AS delivery_status,
    COUNT(*)                               AS total_orders,
    ROUND(
        AVG(r.review_score)::NUMERIC,
        2
    )                                      AS avg_review_score,
    COUNT(
        CASE WHEN r.review_score >= 4
        THEN 1 END
    )                                      AS positive_reviews,
    COUNT(
        CASE WHEN r.review_score <= 2
        THEN 1 END
    )                                      AS negative_reviews,
    ROUND(
        COUNT(CASE WHEN r.review_score <= 2 THEN 1 END)
        * 100.0
        / COUNT(*)::NUMERIC,
        2
    )                                      AS negative_pct
FROM orders o
JOIN reviews r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
AND o.order_status = 'delivered'
GROUP BY delivery_status
ORDER BY delivery_status;


-- PART B: My Version — Score Distribution with Delivery Days
SELECT
    r.review_score,
    COUNT(*)                               AS total_reviews,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER()::NUMERIC,
        2
    )                                      AS percentage,
    ROUND(
        AVG(
            DATE_PART('day',
                o.order_delivered_customer_date
                - o.order_purchase_timestamp)
        )::NUMERIC,
        1
    )                                      AS avg_delivery_days,
    COUNT(
        CASE
            WHEN o.order_delivered_customer_date
                 > o.order_estimated_delivery_date
            THEN 1
        END
    )                                      AS late_deliveries
FROM reviews r
JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score ASC;


-- BQ6: Top 10 Sellers by Revenue
-- Purpose: Identify highest value sellers
--          for account management priority
-- Author: SOWMYA SANIKOMMU

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)            AS total_orders,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC,
        2
    )                                      AS total_revenue,
    ROUND(
        AVG(oi.price + oi.freight_value)::NUMERIC,
        2
    )                                      AS avg_order_value,
    ROUND(
        SUM(oi.price + oi.freight_value)::NUMERIC
        * 100.0
        / SUM(SUM(oi.price + oi.freight_value))
          OVER()::NUMERIC,
        2
    )                                      AS revenue_percentage
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;


-- BQ7: Delivery Performance by State
-- Purpose: Identify states with worst delivery
--          performance and lowest satisfaction
-- Author: SOWMYA SANIKOMMU

SELECT
    c.customer_state,
    COUNT(o.order_id)                      AS total_orders,
    ROUND(
        AVG(
            o.order_delivered_customer_date::DATE
            - o.order_purchase_timestamp::DATE
        )::NUMERIC,
        1
    )                                      AS avg_delivery_days,
    SUM(
        CASE
            WHEN o.order_delivered_customer_date
                 > o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    )                                      AS late_orders,
    ROUND(
        SUM(
            CASE
                WHEN o.order_delivered_customer_date
                     > o.order_estimated_delivery_date
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(o.order_id)::NUMERIC,
        2
    )                                      AS late_percentage,
    ROUND(
        AVG(r.review_score)::NUMERIC,
        2
    )                                      AS avg_review_score
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN reviews r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY
    late_percentage DESC,
    avg_delivery_days DESC;


-- BQ8: Customer Order Frequency Analysis
-- Purpose: Identify one-time buyers vs
--          repeat customers to measure
--          customer loyalty and retention
-- Author: SOWMYA SANIKOMMU

WITH customer_orders AS (
    -- Step 1: Count total orders per unique customer
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id)              AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

customer_segments AS (
    -- Step 2: Segment customers by purchase frequency
    SELECT
        customer_unique_id,
        total_orders,
        CASE
            WHEN total_orders = 1 THEN '1 Order'
            WHEN total_orders = 2 THEN '2 Orders'
            ELSE                       '3+ Orders'
        END                            AS order_frequency
    FROM customer_orders
)

-- Step 3: Summarize segments with percentages
SELECT
    order_frequency,
    COUNT(*)                           AS total_customers,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER()::NUMERIC,
        2
    )                                  AS percentage_of_customers
FROM customer_segments
GROUP BY order_frequency
ORDER BY
    CASE
        WHEN order_frequency = '1 Order'   THEN 1
        WHEN order_frequency = '2 Orders'  THEN 2
        ELSE                                    3
    END;