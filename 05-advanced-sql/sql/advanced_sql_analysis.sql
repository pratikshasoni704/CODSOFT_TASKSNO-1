-- ============================================================
-- TASK 5 — ADVANCED SQL ANALYSIS
-- ============================================================
-- Database: PostgreSQL
-- Dataset: E-commerce Products
-- Purpose: Advanced SQL and business analytics
--
-- Concepts:
--   • Subqueries
--   • CTEs
--   • Window Functions
--   • ROW_NUMBER()
--   • RANK()
--   • LAG()
--   • LEAD()
--   • Running Totals
--   • Percentage Contribution
--   • Business KPI Analysis
-- ============================================================
-- ============================================================
-- 1. PRODUCTS ABOVE AVERAGE SALES
-- ============================================================

SELECT
    product_id,
    category,
    units_sold
FROM products
WHERE units_sold > (
    SELECT AVG(units_sold)
    FROM products
)
ORDER BY units_sold DESC;

-- ============================================================
-- 2. CATEGORIES ABOVE OVERALL AVERAGE SALES
-- ============================================================

SELECT
    category,
    ROUND(AVG(units_sold), 2) AS category_average_sales
FROM products
GROUP BY category
HAVING AVG(units_sold) > (
    SELECT AVG(units_sold)
    FROM products
)
ORDER BY category_average_sales DESC;

-- ============================================================
-- 3. NUMBER PRODUCTS BY SALES PERFORMANCE
-- ============================================================

SELECT
    product_id,
    category,
    units_sold,
    ROW_NUMBER() OVER (
        ORDER BY units_sold DESC
    ) AS sales_row_number
FROM products
ORDER BY sales_row_number
LIMIT 20;

-- ============================================================
-- 4. NUMBER PRODUCTS WITHIN EACH CATEGORY
-- ============================================================

SELECT
    product_id,
    category,
    units_sold,
    ROW_NUMBER() OVER (
        PARTITION BY category
        ORDER BY units_sold DESC
    ) AS category_row_number
FROM products
ORDER BY category, category_row_number;

-- ============================================================
-- 5. TOP 3 PRODUCTS IN EACH CATEGORY USING ROW_NUMBER
-- ============================================================

WITH ranked_products AS (
    SELECT
        product_id,
        category,
        units_sold,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY units_sold DESC
        ) AS category_row_number
    FROM products
)

SELECT
    product_id,
    category,
    units_sold,
    category_row_number
FROM ranked_products
WHERE category_row_number <= 3
ORDER BY category, category_row_number;

-- ============================================================
-- 6. COMPARE SALES WITH THE PREVIOUS PRODUCT
-- ============================================================

SELECT
    product_id,
    category,
    units_sold,

    LAG(units_sold) OVER (
        ORDER BY units_sold DESC
    ) AS previous_units_sold

FROM products
ORDER BY units_sold DESC
LIMIT 20;

-- ============================================================
-- 7. SALES DIFFERENCE FROM PREVIOUS PRODUCT
-- ============================================================

SELECT
    product_id,
    category,
    units_sold,

    LAG(units_sold) OVER (
        ORDER BY units_sold DESC
    ) AS previous_units_sold,

    units_sold -
    LAG(units_sold) OVER (
        ORDER BY units_sold DESC
    ) AS sales_difference

FROM products

ORDER BY units_sold DESC
LIMIT 20;

-- ============================================================
-- 8. SALES PERCENTAGE DIFFERENCE FROM PREVIOUS PRODUCT
-- ============================================================

WITH sales_comparison AS (
    SELECT
        product_id,
        category,
        units_sold,
        LAG(units_sold) OVER (
            ORDER BY units_sold DESC
        ) AS previous_units_sold
    FROM products
)

SELECT
    product_id,
    category,
    units_sold,
    previous_units_sold,

    ROUND(
        (
            (units_sold - previous_units_sold)
            / NULLIF(previous_units_sold, 0)::numeric
        ) * 100,
        2
    ) AS sales_percentage_difference

FROM sales_comparison

ORDER BY units_sold DESC
LIMIT 20;

-- ============================================================
-- 9. COMPARE SALES WITH THE NEXT PRODUCT
-- ============================================================

SELECT
    product_id,
    category,
    units_sold,

    LEAD(units_sold) OVER (
        ORDER BY units_sold DESC
    ) AS next_units_sold

FROM products

ORDER BY units_sold DESC
LIMIT 20;

-- ============================================================
-- 10. SALES GAP TO THE NEXT PRODUCT
-- ============================================================

WITH sales_comparison AS (
    SELECT
        product_id,
        category,
        units_sold,
        LEAD(units_sold) OVER (
            ORDER BY units_sold DESC
        ) AS next_units_sold
    FROM products
)

SELECT
    product_id,
    category,
    units_sold,
    next_units_sold,
    units_sold - next_units_sold AS sales_gap
FROM sales_comparison
ORDER BY units_sold DESC
LIMIT 20;

-- ============================================================
-- 11. RUNNING TOTAL OF UNITS SOLD
-- ============================================================

SELECT
    product_id,
    category,
    units_sold,

    SUM(units_sold) OVER (
        ORDER BY units_sold DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_units

FROM products

ORDER BY units_sold DESC
LIMIT 20;

-- ============================================================
-- 12. PRODUCT CONTRIBUTION TO TOTAL SALES
-- ============================================================

SELECT
    product_id,
    category,
    units_sold,

    ROUND(
        (
            units_sold::numeric
            / SUM(units_sold) OVER ()
        ) * 100,
        2
    ) AS sales_contribution_percent

FROM products

ORDER BY sales_contribution_percent DESC
LIMIT 20;

-- ============================================================
-- 13. CUMULATIVE SALES CONTRIBUTION BY CATEGORY
-- ============================================================

WITH category_sales AS (
    SELECT
        category,
        SUM(units_sold) AS total_units_sold
    FROM products
    GROUP BY category
)

SELECT
    category,
    total_units_sold,

    ROUND(
        (
            total_units_sold::numeric
            / SUM(total_units_sold) OVER ()
        ) * 100,
        2
    ) AS sales_contribution_percent,

    ROUND(
        (
            SUM(total_units_sold) OVER (
                ORDER BY total_units_sold DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )::numeric
            / SUM(total_units_sold) OVER ()
        ) * 100,
        2
    ) AS cumulative_sales_percent

FROM category_sales

ORDER BY total_units_sold DESC;

-- ============================================================
-- 14. CATEGORY BUSINESS KPI SCORECARD
-- ============================================================

SELECT
    category,

    COUNT(*) AS product_count,

    SUM(units_sold) AS total_units_sold,

    ROUND(
        SUM(price_usd * units_sold),
        2
    ) AS estimated_revenue,

    ROUND(
        AVG(rating),
        2
    ) AS average_rating,

    ROUND(
        AVG(return_rate) * 100,
        2
    ) AS average_return_rate_percent,

    ROUND(
        AVG(discount_percent),
        2
    ) AS average_discount_percent

FROM products

GROUP BY category

ORDER BY estimated_revenue DESC;

-- ============================================================
-- 15. FINAL CATEGORY PERFORMANCE ANALYSIS
-- ============================================================

WITH category_metrics AS (
    SELECT
        category,

        SUM(units_sold) AS total_units_sold,

        ROUND(
            SUM(price_usd * units_sold),
            2
        ) AS estimated_revenue,

        ROUND(
            AVG(rating),
            2
        ) AS average_rating,

        ROUND(
            AVG(return_rate) * 100,
            2
        ) AS average_return_rate_percent

    FROM products

    GROUP BY category
),

ranked_categories AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY estimated_revenue DESC
        ) AS revenue_rank
    FROM category_metrics
)

SELECT
    category,
    total_units_sold,
    estimated_revenue,
    average_rating,
    average_return_rate_percent,
    revenue_rank,

    CASE
        WHEN average_rating >= 4.0
             AND average_return_rate_percent < 10
             THEN 'High Performing'

        WHEN average_rating >= 3.5
             AND average_return_rate_percent < 15
             THEN 'Moderate Performing'

        ELSE 'Needs Attention'
    END AS performance_status

FROM ranked_categories

ORDER BY revenue_rank;