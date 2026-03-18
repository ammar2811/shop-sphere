---------------------------------------------------------
-- A3: ShopSphere Schema (Tables, Sequences, Triggers)
---------------------------------------------------------

-----------------------------
-- Drop Tables (if exist)
-----------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ORDERITEMS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PAYMENTS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ORDERS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PRODUCTS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CATEGORIES CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE USERS CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-----------------------------
-- Drop Sequences (if exist)
-----------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_users';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_categories';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_products';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_orders';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_payments';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_orderitems';
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN RAISE; END IF;
END;
/

---------------------------------------------------------
-- USERS TABLE
---------------------------------------------------------
CREATE TABLE USERS (
    user_id        NUMBER PRIMARY KEY,
    name           VARCHAR2(100) NOT NULL,
    email          VARCHAR2(150) NOT NULL UNIQUE,
    phone          VARCHAR2(20),
    password_hash  VARCHAR2(255) NOT NULL,
    address        VARCHAR2(255),
    created_at     DATE DEFAULT SYSDATE NOT NULL
);

CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_users
BEFORE INSERT ON USERS
FOR EACH ROW
WHEN (NEW.user_id IS NULL)
BEGIN
    SELECT seq_users.NEXTVAL INTO :NEW.user_id FROM dual;
END;
/

---------------------------------------------------------
-- CATEGORIES TABLE
---------------------------------------------------------
CREATE TABLE CATEGORIES (
    category_id        NUMBER PRIMARY KEY,
    category_name      VARCHAR2(100) NOT NULL,
    description        VARCHAR2(255),
    parent_category_id NUMBER,
    created_at         DATE DEFAULT SYSDATE NOT NULL,
    updated_at         DATE,
    status             VARCHAR2(20) DEFAULT 'Active'
                          CHECK (status IN ('Active','Inactive')),
    CONSTRAINT fk_parent_category
        FOREIGN KEY (parent_category_id) REFERENCES CATEGORIES(category_id)
);

CREATE SEQUENCE seq_categories START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_categories
BEFORE INSERT ON CATEGORIES
FOR EACH ROW
WHEN (NEW.category_id IS NULL)
BEGIN
    SELECT seq_categories.NEXTVAL INTO :NEW.category_id FROM dual;
END;
/

---------------------------------------------------------
-- PRODUCTS TABLE
---------------------------------------------------------
CREATE TABLE PRODUCTS (
    product_id      NUMBER PRIMARY KEY,
    name            VARCHAR2(150) NOT NULL,
    description     VARCHAR2(500),
    price           NUMBER(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity  NUMBER DEFAULT 0 CHECK (stock_quantity >= 0),
    image_url       VARCHAR2(255),
    category_id     NUMBER NOT NULL,
    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id) REFERENCES CATEGORIES(category_id)
);

CREATE SEQUENCE seq_products START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_products
BEFORE INSERT ON PRODUCTS
FOR EACH ROW
WHEN (NEW.product_id IS NULL)
BEGIN
    SELECT seq_products.NEXTVAL INTO :NEW.product_id FROM dual;
END;
/

---------------------------------------------------------
-- ORDERS TABLE
---------------------------------------------------------
CREATE TABLE ORDERS (
    order_id         NUMBER PRIMARY KEY,
    order_date       DATE DEFAULT SYSDATE NOT NULL,
    status           VARCHAR2(20) DEFAULT 'Pending'
                        CHECK (status IN ('Pending','Shipped','Delivered','Cancelled')),
    total_amount     NUMBER(10,2) CHECK (total_amount >= 0),
    shipping_address VARCHAR2(255),
    last_updated     DATE DEFAULT SYSDATE,
    user_id          NUMBER NOT NULL,
    CONSTRAINT fk_order_user
        FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

CREATE SEQUENCE seq_orders START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_orders
BEFORE INSERT ON ORDERS
FOR EACH ROW
WHEN (NEW.order_id IS NULL)
BEGIN
    SELECT seq_orders.NEXTVAL INTO :NEW.order_id FROM dual;
END;
/

---------------------------------------------------------
-- PAYMENTS TABLE
---------------------------------------------------------
CREATE TABLE PAYMENTS (
    payment_id            NUMBER PRIMARY KEY,
    payment_date          DATE DEFAULT SYSDATE NOT NULL,
    amount                NUMBER(10,2) NOT NULL CHECK (amount >= 0),
    payment_method        VARCHAR2(30) NOT NULL
                             CHECK (payment_method IN ('CreditCard','DebitCard','PayPal','GiftCard','Other')),
    status                VARCHAR2(20) DEFAULT 'Pending'
                             CHECK (status IN ('Pending','Completed','Failed','Refunded')),
    transaction_reference VARCHAR2(100) UNIQUE NOT NULL,
    order_id              NUMBER NOT NULL,
    user_id               NUMBER NOT NULL,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    CONSTRAINT fk_payment_user  FOREIGN KEY (user_id)  REFERENCES USERS(user_id)
);

CREATE SEQUENCE seq_payments START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_payments
BEFORE INSERT ON PAYMENTS
FOR EACH ROW
WHEN (NEW.payment_id IS NULL)
BEGIN
    SELECT seq_payments.NEXTVAL INTO :NEW.payment_id FROM dual;
END;
/

---------------------------------------------------------
-- ORDERITEMS TABLE (Weak Entity)
---------------------------------------------------------
CREATE TABLE ORDERITEMS (
    order_item_id     NUMBER,
    order_id          NUMBER NOT NULL,
    product_id        NUMBER NOT NULL,
    quantity          NUMBER NOT NULL CHECK (quantity > 0),
    price_at_purchase NUMBER(10,2) NOT NULL CHECK (price_at_purchase >= 0),
    discount_applied  NUMBER(5,2) DEFAULT 0 CHECK (discount_applied >= 0),
    subtotal          NUMBER(10,2) NOT NULL CHECK (subtotal >= 0),
    CONSTRAINT pk_orderitems PRIMARY KEY (order_item_id, order_id, product_id),
    CONSTRAINT fk_orderitems_order FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
    CONSTRAINT fk_orderitems_product FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);

CREATE SEQUENCE seq_orderitems START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_orderitems
BEFORE INSERT ON ORDERITEMS
FOR EACH ROW
WHEN (NEW.order_item_id IS NULL)
BEGIN
    SELECT seq_orderitems.NEXTVAL INTO :NEW.order_item_id FROM dual;
END;
/