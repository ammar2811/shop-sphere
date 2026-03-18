---------------------------------------------------------
-- Assignment 5: Advanced Queries (Q11-Q17)
-- ShopSphere Database - Advanced SQL Operations
---------------------------------------------------------

---------------------------------------------------------
-- Q11: Find customers who have placed orders in ALL categories
-- Uses: EXISTS, NOT EXISTS (Set Operation), Multi-table JOIN
-- Description: Lists customers who are "complete shoppers" - 
--              they've purchased from every available category
---------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Q11: Customers Who Ordered From ALL Categories
PROMPT ========================================
PROMPT

SELECT DISTINCT u.user_id AS "User ID",
       u.name AS "Customer Name",
       u.email AS "Email"
FROM users u
WHERE NOT EXISTS (
    -- Find categories that this user has NOT ordered from
    SELECT c.category_id
    FROM categories c
    WHERE c.status = 'Active'
      AND NOT EXISTS (
          -- Check if user has ordered from this category
          SELECT 1
          FROM orders o
          JOIN orderitems oi ON o.order_id = oi.order_id
          JOIN products p ON oi.product_id = p.product_id
          WHERE o.user_id = u.user_id
            AND p.category_id = c.category_id
      )
)
AND EXISTS (
    -- Ensure user has at least one order
    SELECT 1
    FROM orders o
    WHERE o.user_id = u.user_id
)
ORDER BY u.name;

---------------------------------------------------------
-- Q12: Products that have NEVER been ordered
-- Uses: NOT EXISTS, Subquery
-- Description: Identifies products in inventory that customers
--              haven't purchased yet (potential clearance items)
---------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Q12: Products Never Ordered (Dead Stock)
PROMPT ========================================
PROMPT

SELECT p.product_id AS "Product ID",
       p.name AS "Product Name",
       c.category_name AS "Category",
       p.price AS "Price ($)",
       p.stock_quantity AS "Stock Qty"
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE NOT EXISTS (
    SELECT 1
    FROM orderitems oi
    WHERE oi.product_id = p.product_id
)
ORDER BY p.stock_quantity DESC, p.price DESC;

---------------------------------------------------------
-- Q13: Category Performance Analysis with Statistics
-- Uses: GROUP BY, HAVING, Aggregate Functions (COUNT, SUM, AVG, STDDEV)
-- Description: Comprehensive analysis of each category's sales performance
--              including statistical measures
---------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Q13: Category Sales Performance with Statistics
PROMPT ========================================
PROMPT

SELECT 
    c.category_name AS "Category",
    COUNT(DISTINCT o.order_id) AS "Total Orders",
    COUNT(oi.order_item_id) AS "Items Sold",
    SUM(oi.subtotal) AS "Total Revenue ($)",
    ROUND(AVG(oi.subtotal), 2) AS "Avg Item Value ($)",
    ROUND(STDDEV(oi.subtotal), 2) AS "StdDev ($)",
    MIN(oi.subtotal) AS "Min Sale ($)",
    MAX(oi.subtotal) AS "Max Sale ($)"
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN orderitems oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status != 'Cancelled'
GROUP BY c.category_name
HAVING SUM(oi.subtotal) > 0
ORDER BY SUM(oi.subtotal) DESC;

---------------------------------------------------------
-- Q14: High-Value Customers vs Low-Value Customers
-- Uses: UNION, Subquery, Aggregate Functions
-- Description: Combines two distinct customer segments:
--              Premium customers (spent > avg) and budget customers (spent < avg)
---------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Q14: Customer Segmentation (High vs Low Spenders)
PROMPT ========================================
PROMPT

SELECT 'HIGH VALUE' AS "Segment",
       u.name AS "Customer Name",
       COUNT(o.order_id) AS "Orders",
       SUM(o.total_amount) AS "Total Spent ($)"
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name
HAVING SUM(o.total_amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(o2.total_amount) AS total_spent
        FROM orders o2
        GROUP BY o2.user_id
    )
)
UNION
SELECT 'LOW VALUE' AS "Segment",
       u.name AS "Customer Name",
       COUNT(o.order_id) AS "Orders",
       SUM(o.total_amount) AS "Total Spent ($)"
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name
HAVING SUM(o.total_amount) <= (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(o2.total_amount) AS total_spent
        FROM orders o2
        GROUP BY o2.user_id
    )
)
ORDER BY "Segment" DESC, "Total Spent ($)" DESC;

---------------------------------------------------------
-- Q15: Active Products vs Inactive Products in Sales
-- Uses: MINUS (Set Operation), JOIN
-- Description: Products that are in active categories but haven't sold
--              vs products that sold but are now in inactive categories
---------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Q15: Product Activity Analysis (MINUS Operation)
PROMPT ========================================
PROMPT

-- Products in active categories
SELECT p.product_id AS "Product ID",
       p.name AS "Product Name",
       c.category_name AS "Category",
       'In Active Category' AS "Status"
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE c.status = 'Active'
MINUS
-- Products that have been sold
SELECT p.product_id,
       p.name,
       c.category_name,
       'In Active Category'
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN orderitems oi ON p.product_id = oi.product_id
WHERE c.status = 'Active';

---------------------------------------------------------
-- Q16: Payment Method Efficiency Analysis
-- Uses: GROUP BY, HAVING, Multiple Aggregate Functions
-- Description: Analyzes which payment methods are most successful
--              (completion rate, average transaction value)
---------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Q16: Payment Method Success Analysis
PROMPT ========================================
PROMPT

SELECT 
    payment_method AS "Payment Method",
    COUNT(*) AS "Total Transactions",
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS "Successful",
    SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS "Failed",
    ROUND(SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS "Success Rate (%)",
    ROUND(AVG(amount), 2) AS "Avg Transaction ($)",
    SUM(amount) AS "Total Volume ($)"
FROM payments
GROUP BY payment_method
HAVING COUNT(*) > 0
ORDER BY "Success Rate (%)" DESC, "Total Volume ($)" DESC;

---------------------------------------------------------
-- Q17: Complex Order Analysis - Multi-Item Orders with High Value
-- Uses: EXISTS, GROUP BY, HAVING, Multiple JOINs, Aggregate Functions
-- Description: Finds orders with multiple different products that exceed
--              average order value, showing customer loyalty and basket size
---------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Q17: High-Value Multi-Item Order Analysis
PROMPT ========================================
PROMPT

SELECT 
    o.order_id AS "Order ID",
    u.name AS "Customer",
    COUNT(DISTINCT oi.product_id) AS "Unique Items",
    SUM(oi.quantity) AS "Total Qty",
    o.total_amount AS "Order Total ($)",
    o.status AS "Status",
    TO_CHAR(o.order_date, 'YYYY-MM-DD') AS "Order Date"
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN orderitems oi ON o.order_id = oi.order_id
WHERE EXISTS (
    -- Order must have items from at least 2 different categories
    SELECT 1
    FROM orderitems oi2
    JOIN products p2 ON oi2.product_id = p2.product_id
    WHERE oi2.order_id = o.order_id
    GROUP BY oi2.order_id
    HAVING COUNT(DISTINCT p2.category_id) >= 2
)
GROUP BY o.order_id, u.name, o.total_amount, o.status, o.order_date
HAVING o.total_amount > (
    SELECT AVG(total_amount)
    FROM orders
    WHERE status != 'Cancelled'
)
AND COUNT(DISTINCT oi.product_id) >= 2
ORDER BY o.total_amount DESC;

---------------------------------------------------------
-- Q18: Customer Purchase Frequency Analysis
-- Uses: GROUP BY, HAVING, Subquery with Aggregate Functions
-- Description: Identifies active customers based on order frequency
--              and compares them to occasional shoppers
---------------------------------------------------------
PROMPT
PROMPT ========================================
PROMPT Q18: Customer Activity Level Classification
PROMPT ========================================
PROMPT

SELECT 
    u.name AS "Customer Name",
    COUNT(o.order_id) AS "Total Orders",
    ROUND(AVG(o.total_amount), 2) AS "Avg Order Value ($)",
    SUM(o.total_amount) AS "Lifetime Value ($)",
    CASE 
        WHEN COUNT(o.order_id) >= 3 THEN 'FREQUENT'
        WHEN COUNT(o.order_id) = 2 THEN 'REGULAR'
        ELSE 'OCCASIONAL'
    END AS "Customer Type"
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE o.status != 'Cancelled' OR o.order_id IS NULL
GROUP BY u.user_id, u.name
HAVING COUNT(o.order_id) > 0
ORDER BY COUNT(o.order_id) DESC, SUM(o.total_amount) DESC;

PROMPT
PROMPT ========================================
PROMPT All Advanced Queries Completed Successfully!
PROMPT ========================================