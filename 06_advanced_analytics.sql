-- AQ1: Running Revenue & Month over Month Growth
-- Purpose: Track cumulative revenue trajectory
--          and identify growth acceleration
-- Author: SOWMYA SANIKOMMU

WITH monthly_revenue AS (
    -- Step 1: Calculate monthly revenue
    SELECT
        DATE_TRUNC('month',
            o.order_purchase_timestamp)::DATE  AS month,
        ROUND(
            SUM(oi.price
                + oi.freight_value)::NUMERIC,
            2
        )                                      AS monthly_revenue,
        COUNT(DISTINCT o.order_id)             AS total_orders
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    AND o.order_purchase_timestamp >= '2017-01-01'
    AND o.order_purchase_timestamp <  '2018-09-01'
    GROUP BY 1
),

revenue_with_lag AS (
    -- Step 2: Add previous month using LAG()
    SELECT
        month,
        monthly_revenue,
        total_orders,
        LAG(monthly_revenue, 1)
            OVER (ORDER BY month)              AS prev_month_revenue
    FROM monthly_revenue
)

-- Step 3: Calculate all metrics together
SELECT
    TO_CHAR(month, 'YYYY-MM')                 AS month,
    monthly_revenue,
    total_orders,
    ROUND(
        SUM(monthly_revenue)
            OVER (ORDER BY month
                  ROWS BETWEEN UNBOUNDED PRECEDING
                  AND CURRENT ROW)::NUMERIC,
        2
    )                                          AS cumulative_revenue,
    prev_month_revenue,
    ROUND(
        (monthly_revenue - prev_month_revenue)
        * 100.0
        / NULLIF(prev_month_revenue, 0)::NUMERIC,
        2
    )                                          AS mom_growth_pct
FROM revenue_with_lag
ORDER BY month;


-- =============================
-- AQ2: Top Product Category Per State
-- Purpose: Identify regional product preferences
--          for targeted marketing and inventory
-- Author: SOWMYA SANIKOMMU

WITH category_revenue AS (
    -- Step 1: Revenue per category per state
    SELECT
        c.customer_state,
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Uncategorized'
        )                                      AS product_category,
        ROUND(
            SUM(oi.price
                + oi.freight_value)::NUMERIC,
            2
        )                                      AS total_revenue,
        COUNT(DISTINCT o.order_id)             AS total_orders
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name
           = ct.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY
        c.customer_state,
        COALESCE(
            ct.product_category_name_english,
            p.product_category_name,
            'Uncategorized'
        )
),

ranked_categories AS (
    -- Step 2: Rank categories within each state
    SELECT
        customer_state,
        product_category,
        total_revenue,
        total_orders,
        RANK() OVER (
            PARTITION BY customer_state
            ORDER BY total_revenue DESC
        )                                      AS category_rank
    FROM category_revenue
)

-- Step 3: Show only #1 category per state
SELECT
    customer_state,
    product_category          AS top_category,
    total_revenue,
    total_orders,
    category_rank
FROM ranked_categories
WHERE category_rank = 1
ORDER BY total_revenue DESC;