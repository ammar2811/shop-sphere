---------------------------------------------------------
-- Assignment 4 - Part 2: Views and Advanced Queries
---------------------------------------------------------

---------------------------------------------------------
-- VIEW 1: vw_customer_orders_summary
-- Purpose: Summarizes each customer's total orders and total spending
---------------------------------------------------------
CREATE OR REPLACE VIEW vw_customer_orders_summary AS
SELECT 
    u.user_id,
    u.name AS customer_name,
    COUNT(o.order_id) AS total_orders,
    NVL(SUM(o.total_amount), 0) AS total_spent
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name;

---------------------------------------------------------
-- TEST VIEW 1: Display total orders and spending by customer
---------------------------------------------------------
SELECT 
    customer_name AS "Customer Name",
    total_orders AS "Total Orders",
    total_spent AS "Total Spent ($)"
FROM vw_customer_orders_summary
ORDER BY total_spent DESC;

---------------------------------------------------------
-- VIEW 2: vw_order_details_expanded
-- Purpose: Full order detail with customer, product, and category info
---------------------------------------------------------
CREATE OR REPLACE VIEW vw_order_details_expanded AS
SELECT
    o.order_id,
    u.name AS customer_name,
    c.category_name,
    p.name AS product_name,
    oi.quantity,
    oi.subtotal,
    o.status,
    o.shipping_address AS order_location
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN orderitems oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id;

---------------------------------------------------------
-- TEST VIEW 2: Show recent orders with details
---------------------------------------------------------
SELECT 
    order_id AS "Order ID",
    customer_name AS "Customer",
    category_name AS "Category",
    product_name AS "Product",
    quantity AS "Qty",
    subtotal AS "Subtotal ($)",
    status AS "Status",
    order_location AS "Shipping Address"
FROM vw_order_details_expanded
ORDER BY order_id DESC;

---------------------------------------------------------
-- Q8: Top 3 Customers by Spending
---------------------------------------------------------
SELECT *
FROM (
    SELECT
        customer_name AS "Customer",
        total_orders AS "Total Orders",
        total_spent AS "Total Spent ($)"
    FROM vw_customer_orders_summary
    ORDER BY total_spent DESC
)
WHERE ROWNUM <= 3;

---------------------------------------------------------
-- Q9: Category-wise Revenue Summary (multi-table join)
---------------------------------------------------------
SELECT
    c.category_name AS "Category",
    SUM(oi.subtotal) AS "Total Sales ($)",
    COUNT(DISTINCT o.order_id) AS "Number of Orders"
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN orderitems oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY c.category_name
ORDER BY SUM(oi.subtotal) DESC;

---------------------------------------------------------
-- Q10: Refunded or Cancelled Orders Report (advanced filter)
---------------------------------------------------------
SELECT
    u.name AS "Customer",
    o.status AS "Order Status",
    p.payment_method AS "Payment Type",
    p.status AS "Payment Status",
    p.amount AS "Amount ($)"
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN users u ON p.user_id = u.user_id
WHERE o.status = 'Cancelled'
   OR p.status = 'Refunded'
ORDER BY p.amount DESC;