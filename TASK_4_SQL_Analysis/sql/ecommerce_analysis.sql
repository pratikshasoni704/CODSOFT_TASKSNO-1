TASK 4: E-COMMERCE SQL DATA ANALYSIS

-- ============================================
-- 1. VIEW SAMPLE PRODUCTS
-- ============================================

 SELECT
    product_id,
    category,
    price_usd,
    units_sold
FROM products
LIMIT 10;

 ============================================
-- 2. FIND EXPENSIVE PRODUCTS
-- ============================================

SELECT
    product_id,
    category,
    price_usd
FROM products
WHERE price_usd > 100
ORDER BY price_usd DESC
LIMIT 10;


-- ============================================
-- 3. TOP 10 BEST-SELLING PRODUCTS
-- ============================================

SELECT
    product_id,
    category,
    units_sold
FROM products
ORDER BY units_sold DESC
LIMIT 10;

-- ============================================
-- 4. Find all products that sold more than 500 units.
-- ============================================
SELECT
    product_id,
    category,
    units_sold
FROM products
WHERE units_sold > 500;
ORDER BY units_sold DESC;
-- ============================================
-- 5.  TOTAL UNITS SOLD BY CATEGORY
-- ============================================
SELECT
    category,
    SUM(units_sold) AS total_units_sold
FROM products
GROUP BY category
ORDER BY total_units_sold DESC;
-- ============================================
-- 6. AVERAGE PRICE BY CATEGORY
-- ============================================

SELECT
    category,
    ROUND(AVG(price_usd), 2) AS average_price
FROM products
GROUP BY category
ORDER BY average_price DESC;
-- ============================================
-- 7. TOTAL REVENUE BY CATEGORY
-- ============================================

SELECT
    category,
    ROUND(SUM(price_usd * units_sold), 2) AS total_revenue
FROM products
GROUP BY category
ORDER BY total_revenue DESC;
-- ============================================
-- 8. UNITS SOLD BY DISCOUNT PERCENTAGE
-- ============================================

SELECT
    discount_percent,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(units_sold), 2) AS average_units_sold
FROM products
GROUP BY discount_percent
ORDER BY discount_percent;

-- ============================================
-- 9. CATEGORIES WITH HIGH SALES VOLUME
-- ============================================

SELECT
    category,
    SUM(units_sold) AS total_units_sold
FROM products
GROUP BY category
HAVING SUM(units_sold) > 1000000
ORDER BY total_units_sold DESC;

-- ============================================
-- 10. CLASSIFY PRODUCTS BY SALES VOLUME
-- ============================================

SELECT
    product_id,
    category,
    units_sold,
    CASE
        WHEN units_sold < 100 THEN 'Low Sales'
        WHEN units_sold BETWEEN 100 AND 500 THEN 'Medium Sales'
        ELSE 'High Sales'
    END AS sales_category
FROM products
ORDER BY units_sold DESC;

-- ============================================
-- 11. NUMBER OF PRODUCTS IN EACH SALES CATEGORY
-- ============================================

SELECT
    CASE
        WHEN units_sold < 100 THEN 'Low Sales'
        WHEN units_sold BETWEEN 100 AND 500 THEN 'Medium Sales'
        ELSE 'High Sales'
    END AS sales_category,
    COUNT(*) AS product_count
FROM products
GROUP BY
    CASE
        WHEN units_sold < 100 THEN 'Low Sales'
        WHEN units_sold BETWEEN 100 AND 500 THEN 'Medium Sales'
        ELSE 'High Sales'
    END
ORDER BY product_count DESC;

-- ============================================
-- 12. CATEGORIES WITH ABOVE-AVERAGE SALES
-- ============================================

WITH category_sales AS (
    SELECT
        category,
        SUM(units_sold) AS total_units_sold
    FROM products
    GROUP BY category
)

SELECT
    category,
    total_units_sold
FROM category_sales
WHERE total_units_sold > (
    SELECT AVG(total_units_sold)
    FROM category_sales
)
ORDER BY total_units_sold DESC;

-- ============================================
-- 13. CREATE CATEGORY INFORMATION TABLE
-- ============================================

CREATE TABLE category_info (
    category VARCHAR(100),
    department VARCHAR(100)
);



SELECT DISTINCT category
FROM products
ORDER BY category;

SELECT *
FROM category_info
ORDER BY category;



-- ============================================
-- 14. JOIN PRODUCTS WITH CATEGORY INFORMATION
-- ============================================

SELECT
    p.product_id,
    p.category,
    c.department,
    p.price_usd,
    p.units_sold
FROM products AS p
INNER JOIN category_info AS c
    ON p.category = c.category
LIMIT 20;


- ============================================
-- 15. TOTAL REVENUE BY DEPARTMENT
-- ============================================

SELECT
    c.department,
    ROUND(SUM(p.price_usd * p.units_sold), 2) AS total_revenue
FROM products AS p
INNER JOIN category_info AS c
    ON p.category = c.category
GROUP BY c.department
ORDER BY total_revenue DESC;

-- ============================================
-- 16. RANK PRODUCTS BY UNITS SOLD
-- ============================================

SELECT
    product_id,
    category,
    units_sold,
    RANK() OVER (
        ORDER BY units_sold DESC
    ) AS sales_rank
FROM products
ORDER BY sales_rank
LIMIT 20;

-- ============================================
-- 17. RANK PRODUCTS WITHIN EACH CATEGORY
-- ============================================

SELECT
    product_id,
    category,
    units_sold,
    RANK() OVER (
        PARTITION BY category
        ORDER BY units_sold DESC
    ) AS category_rank
FROM products
ORDER BY category, category_rank;

-- ============================================
-- 18. TOP 3 PRODUCTS IN EACH CATEGORY
-- ============================================

WITH ranked_products AS (
    SELECT
        product_id,
        category,
        units_sold,
        RANK() OVER (
            PARTITION BY category
            ORDER BY units_sold DESC
        ) AS category_rank
    FROM products
)

SELECT
    product_id,
    category,
    units_sold,
    category_rank
FROM ranked_products
WHERE category_rank <= 3
ORDER BY category, category_rank;

-- ============================================
-- 19. CHECK FOR NULL VALUES
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(product_id) AS product_id_present,
    COUNT(category) AS category_present,
    COUNT(price_usd) AS price_present,
    COUNT(units_sold) AS units_sold_present,
    COUNT(rating) AS rating_present
FROM products;

-- ============================================
-- 20. CHECK FOR DUPLICATE PRODUCT IDs
-- ============================================

SELECT
    product_id,
    COUNT(*) AS occurrence_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- ============================================
-- 21. CHECK FOR INVALID NUMERIC VALUES
-- ============================================

SELECT
    COUNT(*) FILTER (WHERE price_usd < 0) AS invalid_price,
    COUNT(*) FILTER (WHERE discount_percent < 0 OR discount_percent > 100) AS invalid_discount,
    COUNT(*) FILTER (WHERE rating < 0 OR rating > 5) AS invalid_rating,
    COUNT(*) FILTER (WHERE stock_quantity < 0) AS invalid_stock,
    COUNT(*) FILTER (WHERE units_sold < 0) AS invalid_units_sold,
    COUNT(*) FILTER (WHERE return_rate < 0 OR return_rate > 1) AS invalid_return_rate
FROM products;

-- ============================================
-- 22. TOP PRODUCTS BY ESTIMATED REVENUE
-- ============================================

SELECT
    product_id,
    category,
    price_usd,
    units_sold,
    ROUND(price_usd * units_sold, 2) AS estimated_revenue
FROM products
ORDER BY estimated_revenue DESC
LIMIT 20;

-- ============================================
-- 23. TOP PRODUCTS BY DISCOUNTED REVENUE
-- ============================================

SELECT
    product_id,
    category,
    price_usd,
    discount_percent,
    units_sold,
    ROUND(
        price_usd * (1 - discount_percent / 100.0) * units_sold,
        2
    ) AS discounted_revenue
FROM products
ORDER BY discounted_revenue DESC
LIMIT 20;

-- ============================================
-- 24. DISCOUNT IMPACT ON REVENUE
-- ============================================

SELECT
    category,

    ROUND(
        SUM(price_usd * units_sold),
        2
    ) AS revenue_before_discount,

    ROUND(
        SUM(
            price_usd
            * (1 - discount_percent / 100.0)
            * units_sold
        ),
        2
    ) AS revenue_after_discount,

    ROUND(
        SUM(price_usd * units_sold)
        -
        SUM(
            price_usd
            * (1 - discount_percent / 100.0)
            * units_sold
        ),
        2
    ) AS discount_impact

FROM products

GROUP BY category

ORDER BY discount_impact DESC;

-- ============================================
-- 25. AVERAGE RATING BY CATEGORY
-- ============================================

SELECT
    category,
    ROUND(AVG(rating), 2) AS average_rating,
    COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY average_rating DESC;

-- ============================================
-- 26. RATING VS SALES PERFORMANCE
-- ============================================

SELECT
    category,
    ROUND(AVG(rating), 2) AS average_rating,
    SUM(units_sold) AS total_units_sold,
    COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY total_units_sold DESC;

-- ============================================
-- 27. RETURN RATE BY CATEGORY
-- ============================================

SELECT
    category,
    ROUND(AVG(return_rate) * 100, 2) AS average_return_rate_percent,
    SUM(units_sold) AS total_units_sold,
    COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY average_return_rate_percent DESC;

-- ============================================
-- 28. OVERALL CATEGORY PERFORMANCE
-- ============================================

SELECT
    category,

    SUM(units_sold) AS total_units_sold,

    ROUND(AVG(rating), 2) AS average_rating,

    ROUND(AVG(return_rate) * 100, 2) AS average_return_rate_percent,

    ROUND(
        SUM(price_usd * units_sold),
        2
    ) AS estimated_revenue

FROM products

GROUP BY category

ORDER BY estimated_revenue DESC;