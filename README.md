# ShopSphere

ShopSphere is an Oracle-based e-commerce database project with:

- a full relational schema (users, products, categories, orders, payments, and order items),
- sample data for demonstration,
- analytical SQL queries (basic to advanced), and
- an Oracle APEX GUI export for a web interface.

## Repository contents

- `a3.sql`  
  Creates the core schema: tables, constraints, sequences, and auto-ID triggers.
- `a4(1).sql`  
  Loads demo data and includes query set **Q1-Q7**.
- `a4(2).sql`  
  Adds reporting views and query set **Q8-Q10**.
- `a5.sql`  
  Contains advanced query set **Q11-Q18**.
- `ShopSphere_GUI.sql`  
  Oracle APEX application export for the ShopSphere UI.

## Data model (high level)

Core tables:

- `USERS`
- `CATEGORIES` (supports parent-child hierarchy via `parent_category_id`)
- `PRODUCTS`
- `ORDERS`
- `PAYMENTS`
- `ORDERITEMS`

The schema includes:

- foreign key relationships across all transactional entities,
- validation checks (for statuses, non-negative numeric values, etc.),
- unique constraints (for example on user email and payment transaction reference),
- sequences and triggers to auto-populate primary keys.

## How to run

Run scripts in the following order in Oracle SQL*Plus / SQL Developer:

1. `a3.sql`
2. `a4(1).sql`
3. `a4(2).sql`
4. `a5.sql`

Then import `ShopSphere_GUI.sql` into Oracle APEX to load the GUI.

## Query coverage

- **Q1-Q7**: foundational reporting and joins
- **Q8-Q10**: view-based and filtered reporting
- **Q11-Q18**: advanced SQL patterns (e.g., `EXISTS`, `NOT EXISTS`, `UNION`, `MINUS`, aggregate analytics)

## Notes

- This repository is SQL-first and does not include a conventional unit test framework.
- The scripts are intended for Oracle SQL syntax and Oracle APEX compatibility.
