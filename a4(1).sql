---------------------------------------------------------
-- Assignment 4 - Part 1: ShopSphere Database Queries
---------------------------------------------------------

---------------------------------------------------------
-- DEMO DATA INSERTS (using sequences and triggers)
---------------------------------------------------------

-- Clear old data (optional, use only during testing)
DELETE FROM ORDERITEMS;
DELETE FROM PAYMENTS;
DELETE FROM ORDERS;
DELETE FROM PRODUCTS;
DELETE FROM CATEGORIES;
DELETE FROM USERS;
COMMIT;

---------------------------------------------------------
-- USERS
---------------------------------------------------------
INSERT INTO USERS (name, email, phone, password_hash, address)
VALUES ('Irtaza Abbasi', 'abbasi@example.com', '911-911-9111', 'hash1', 'Toronto, ON');

INSERT INTO USERS (name, email, phone, password_hash, address)
VALUES ('Bob Smith', 'bob@example.com', '222-333-4444', 'hash2', 'Ottawa, ON');

INSERT INTO USERS (name, email, phone, password_hash, address)
VALUES ('Sarah Khan', 'sarahkhan@example.com', '647-777-9999', 'hash3', 'Mississauga, ON');

INSERT INTO USERS (name, email, phone, password_hash, address)
VALUES ('Liam Wong', 'liamw@example.com', '416-555-2222', 'hash4', 'Markham, ON');

---------------------------------------------------------
-- CATEGORIES
---------------------------------------------------------
INSERT INTO CATEGORIES (category_name, description, status)
VALUES ('Electronics', 'Phones, laptops, and accessories', 'Active');

INSERT INTO CATEGORIES (category_name, description, status)
VALUES ('Clothing', 'Men and Women apparel', 'Active');

INSERT INTO CATEGORIES (category_name, description, status)
VALUES ('Home Appliances', 'Kitchen and home gadgets', 'Active');

INSERT INTO CATEGORIES (category_name, description, status)
VALUES ('Books', 'Novels and educational books', 'Active');

---------------------------------------------------------
-- PRODUCTS
---------------------------------------------------------
INSERT INTO PRODUCTS (name, description, price, stock_quantity, category_id)
VALUES ('iPhone 15', 'Latest Apple smartphone', 1200, 10, (SELECT category_id FROM CATEGORIES WHERE category_name='Electronics'));

INSERT INTO PRODUCTS (name, description, price, stock_quantity, category_id)
VALUES ('Samsung TV', '55-inch 4K Smart TV', 800, 5, (SELECT category_id FROM CATEGORIES WHERE category_name='Electronics'));

INSERT INTO PRODUCTS (name, description, price, stock_quantity, category_id)
VALUES ('T-Shirt', 'Cotton round neck', 20, 50, (SELECT category_id FROM CATEGORIES WHERE category_name='Clothing'));

INSERT INTO PRODUCTS (name, description, price, stock_quantity, category_id)
VALUES ('Jeans', 'Slim-fit denim jeans', 45, 40, (SELECT category_id FROM CATEGORIES WHERE category_name='Clothing'));

INSERT INTO PRODUCTS (name, description, price, stock_quantity, category_id)
VALUES ('Microwave', 'Countertop digital microwave', 150, 15, (SELECT category_id FROM CATEGORIES WHERE category_name='Home Appliances'));

INSERT INTO PRODUCTS (name, description, price, stock_quantity, category_id)
VALUES ('Air Fryer', 'Compact air fryer', 110, 20, (SELECT category_id FROM CATEGORIES WHERE category_name='Home Appliances'));

INSERT INTO PRODUCTS (name, description, price, stock_quantity, category_id)
VALUES ('Novel', 'Best-selling fiction book', 25, 100, (SELECT category_id FROM CATEGORIES WHERE category_name='Books'));

INSERT INTO PRODUCTS (name, description, price, stock_quantity, category_id)
VALUES ('Textbook', 'Engineering Fundamentals', 90, 30, (SELECT category_id FROM CATEGORIES WHERE category_name='Books'));

---------------------------------------------------------
-- ORDERS
---------------------------------------------------------
INSERT INTO ORDERS (status, total_amount, shipping_address, user_id)
VALUES ('Pending', 1220, 'Toronto, ON', (SELECT user_id FROM USERS WHERE name='Irtaza Abbasi'));

INSERT INTO ORDERS (status, total_amount, shipping_address, user_id)
VALUES ('Shipped', 20, 'Ottawa, ON', (SELECT user_id FROM USERS WHERE name='Bob Smith'));

INSERT INTO ORDERS (status, total_amount, shipping_address, user_id)
VALUES ('Delivered', 890, 'Mississauga, ON', (SELECT user_id FROM USERS WHERE name='Sarah Khan'));

INSERT INTO ORDERS (status, total_amount, shipping_address, user_id)
VALUES ('Cancelled', 150, 'Markham, ON', (SELECT user_id FROM USERS WHERE name='Liam Wong'));

---------------------------------------------------------
-- PAYMENTS
---------------------------------------------------------
INSERT INTO PAYMENTS (amount, payment_method, status, transaction_reference, order_id, user_id)
VALUES (1220, 'CreditCard', 'Completed', 'TXN001',
        (SELECT order_id FROM ORDERS WHERE total_amount=1220),
        (SELECT user_id FROM USERS WHERE name='Irtaza Abbasi'));

INSERT INTO PAYMENTS (amount, payment_method, status, transaction_reference, order_id, user_id)
VALUES (20, 'PayPal', 'Completed', 'TXN002',
        (SELECT order_id FROM ORDERS WHERE total_amount=20),
        (SELECT user_id FROM USERS WHERE name='Bob Smith'));

INSERT INTO PAYMENTS (amount, payment_method, status, transaction_reference, order_id, user_id)
VALUES (890, 'DebitCard', 'Completed', 'TXN003',
        (SELECT order_id FROM ORDERS WHERE total_amount=890),
        (SELECT user_id FROM USERS WHERE name='Sarah Khan'));

INSERT INTO PAYMENTS (amount, payment_method, status, transaction_reference, order_id, user_id)
VALUES (150, 'GiftCard', 'Refunded', 'TXN004',
        (SELECT order_id FROM ORDERS WHERE total_amount=150),
        (SELECT user_id FROM USERS WHERE name='Liam Wong'));

---------------------------------------------------------
-- ORDER ITEMS
---------------------------------------------------------
INSERT INTO ORDERS (status, total_amount, shipping_address, user_id)
VALUES ('Delivered', 65, 'Mississauga, ON', (SELECT user_id FROM USERS WHERE name='Sarah Khan'));

INSERT INTO ORDERITEMS (order_id, product_id, quantity, price_at_purchase, subtotal)
VALUES ((SELECT MAX(order_id) FROM ORDERS),
        (SELECT product_id FROM PRODUCTS WHERE name='T-Shirt'),
        1, 20, 20);

INSERT INTO ORDERITEMS (order_id, product_id, quantity, price_at_purchase, subtotal)
VALUES ((SELECT MAX(order_id) FROM ORDERS),
        (SELECT product_id FROM PRODUCTS WHERE name='Jeans'),
        1, 45, 45);

-- Add Home Appliances order
INSERT INTO ORDERS (status, total_amount, shipping_address, user_id)
VALUES ('Delivered', 110, 'Mississauga, ON', (SELECT user_id FROM USERS WHERE name='Sarah Khan'));

INSERT INTO ORDERITEMS (order_id, product_id, quantity, price_at_purchase, subtotal)
VALUES ((SELECT MAX(order_id) FROM ORDERS),
        (SELECT product_id FROM PRODUCTS WHERE name='Air Fryer'),
        1, 110, 110);
        
INSERT INTO ORDERITEMS (order_id, product_id, quantity, price_at_purchase, subtotal)
VALUES ((SELECT order_id FROM ORDERS WHERE total_amount=1220),
        (SELECT product_id FROM PRODUCTS WHERE name='iPhone 15'),
        1, 1200, 1200);

INSERT INTO ORDERITEMS (order_id, product_id, quantity, price_at_purchase, subtotal)
VALUES ((SELECT order_id FROM ORDERS WHERE total_amount=20),
        (SELECT product_id FROM PRODUCTS WHERE name='T-Shirt'),
        1, 20, 20);

INSERT INTO ORDERITEMS (order_id, product_id, quantity, price_at_purchase, subtotal)
VALUES ((SELECT order_id FROM ORDERS WHERE total_amount=890),
        (SELECT product_id FROM PRODUCTS WHERE name='Samsung TV'),
        1, 800, 800);

INSERT INTO ORDERITEMS (order_id, product_id, quantity, price_at_purchase, subtotal)
VALUES ((SELECT order_id FROM ORDERS WHERE total_amount=890),
        (SELECT product_id FROM PRODUCTS WHERE name='Novel'),
        2, 45, 90);

INSERT INTO ORDERITEMS (order_id, product_id, quantity, price_at_purchase, subtotal)
VALUES ((SELECT order_id FROM ORDERS WHERE total_amount=150),
        (SELECT product_id FROM PRODUCTS WHERE name='Microwave'),
        1, 150, 150);

COMMIT;

---------------------------------------------------------
-- Q1: Display all registered users (sorted by creation date)
---------------------------------------------------------
SELECT 
    user_id       AS "User ID",
    name          AS "Full Name",
    email         AS "Email",
    TO_CHAR(created_at, 'YYYY-MM-DD') AS "Created On"
FROM USERS
ORDER BY created_at DESC;

---------------------------------------------------------
-- Q2: Distinct category names (sorted alphabetically)
---------------------------------------------------------
SELECT DISTINCT category_name AS "Category"
FROM CATEGORIES
ORDER BY category_name;

---------------------------------------------------------
-- Q3: Products with category and price (sorted by price DESC)
---------------------------------------------------------
SELECT 
    p.product_id     AS "Product ID",
    p.name           AS "Product Name",
    c.category_name  AS "Category",
    p.price          AS "Price ($)",
    p.stock_quantity AS "Stock Available"
FROM PRODUCTS p
JOIN CATEGORIES c ON p.category_id = c.category_id
ORDER BY p.price DESC;

---------------------------------------------------------
-- Q4: Count total orders by status (with percentage)
---------------------------------------------------------
SELECT 
    status AS "Order Status",
    COUNT(*) AS "Total Orders",
    ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM ORDERS), 2) AS "Percent of Total (%)"
FROM ORDERS
GROUP BY status
ORDER BY COUNT(*) DESC;

---------------------------------------------------------
-- Q5: Payment method usage and total amount
---------------------------------------------------------
SELECT 
    payment_method AS "Payment Method",
    COUNT(*)       AS "Usage Count",
    SUM(amount)    AS "Total Amount ($)"
FROM PAYMENTS
GROUP BY payment_method
ORDER BY SUM(amount) DESC;

---------------------------------------------------------
-- Q6: Top 10 order items by quantity (Oracle 11XE compatible)
---------------------------------------------------------
SELECT 
    "Item ID",
    "Product",
    "Quantity Ordered",
    "Subtotal ($)"
FROM (
    SELECT 
        oi.order_item_id AS "Item ID",
        p.name AS "Product",
        oi.quantity AS "Quantity Ordered",
        oi.subtotal AS "Subtotal ($)"
    FROM ORDERITEMS oi
    JOIN PRODUCTS p ON oi.product_id = p.product_id
    ORDER BY oi.quantity DESC
)
WHERE ROWNUM <= 10;

---------------------------------------------------------
-- Q7: Users with total number of orders and spending
---------------------------------------------------------
SELECT 
    u.user_id AS "User ID",
    u.name AS "Customer Name",
    COUNT(o.order_id) AS "Total Orders",
    NVL(SUM(o.total_amount), 0) AS "Total Spent ($)"
FROM USERS u
LEFT JOIN ORDERS o ON u.user_id = o.user_id
GROUP BY u.user_id, u.name
ORDER BY COUNT(o.order_id) DESC;