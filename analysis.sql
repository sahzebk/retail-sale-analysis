-- =====================================================================
-- UK Online Retail — Sales Analysis
-- ---------------------------------------------------------------------
-- Dataset : UCI Online Retail (541,909 rows, Dec 2010 – Dec 2011)
--           https://archive.ics.uci.edu/dataset/352/online+retail
-- Database: MySQL 8
-- Author  : Sahzeb Khan
--
-- Pipeline: raw Excel -> MySQL -> cleaned & enriched in SQL
--           -> exported to CSV -> visualised in Tableau Public
-- =====================================================================


-- =====================================================================
-- 1. SCHEMA
-- =====================================================================

CREATE DATABASE retail_analytics;
USE retail_analytics;

CREATE TABLE online_retail (
    invoice_no    VARCHAR(20),
    stock_code    VARCHAR(20),
    description   TEXT,
    quantity      INT,
    invoice_date  DATETIME,
    unit_price    DECIMAL(10,2),
    customer_id   INT,
    country       VARCHAR(60)
);

-- Data loaded from CSV using the MySQL Workbench Table Data Import Wizard
-- (right-click the table in the Schemas panel -> Table Data Import Wizard).
-- LOAD DATA LOCAL INFILE was blocked by local_infile restrictions on macOS.


-- =====================================================================
-- 2. DATA CLEANING
-- Raw file contains cancellations, returns and anonymous transactions
-- that would distort any revenue or customer analysis.
-- =====================================================================

-- Drop transactions with no customer ID — cannot be attributed to a customer
DELETE FROM online_retail
WHERE customer_id IS NULL;

-- Drop cancelled orders (invoice numbers prefixed with 'C')
DELETE FROM online_retail
WHERE invoice_no LIKE 'C%';

-- Drop returns and invalid pricing
DELETE FROM online_retail
WHERE quantity <= 0 OR unit_price <= 0;

-- Result: 541,909 -> 397,884 rows (~27% removed)


-- =====================================================================
-- 3. ENRICHMENT
-- Store line-level revenue once rather than recomputing it in every query.
-- =====================================================================

ALTER TABLE online_retail
ADD COLUMN revenue DECIMAL(12,2);

UPDATE online_retail
SET revenue = quantity * unit_price;


-- =====================================================================
-- 4. VALIDATION
-- =====================================================================

SELECT COUNT(*) AS row_count FROM online_retail;   -- expect 397,884
SELECT * FROM online_retail LIMIT 10;


-- =====================================================================
-- 5. ANALYSIS
-- =====================================================================

-- ---------------------------------------------------------------------
-- Q1. Which products generate the most revenue?
--     Units sold is included alongside revenue to separate high-price,
--     low-volume products from cheap, high-volume ones.
-- ---------------------------------------------------------------------
SELECT
    stock_code,
    description,
    SUM(revenue)  AS total_revenue,
    SUM(quantity) AS total_units_sold
FROM online_retail
GROUP BY stock_code, description
ORDER BY total_revenue DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- Q2. How does revenue move month to month?
--     Ordered by revenue to rank the strongest months.
--     Swap to "ORDER BY year, month" for a chronological trend line.
-- ---------------------------------------------------------------------
SELECT
    YEAR(invoice_date)  AS year,
    MONTH(invoice_date) AS month,
    SUM(revenue)        AS monthly_revenue
FROM online_retail
GROUP BY YEAR(invoice_date), MONTH(invoice_date)
ORDER BY monthly_revenue DESC;


-- ---------------------------------------------------------------------
-- Q3. Who are the highest-value customers?
--     COUNT(DISTINCT invoice_no) counts orders, not line items —
--     a single order spans many rows.
-- ---------------------------------------------------------------------
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS num_orders,
    SUM(revenue)               AS total_spent
FROM online_retail
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;


-- ---------------------------------------------------------------------
-- Q4. Which markets drive sales?
--     The retailer is UK-based; this identifies international markets
--     with the most existing traction.
-- ---------------------------------------------------------------------
SELECT
    country,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(revenue)               AS total_revenue
FROM online_retail
GROUP BY country
ORDER BY total_revenue DESC;


-- =====================================================================
-- 6. EXPORT FOR TABLEAU
-- Run, then export via the Result Grid (set the row limit to
-- "Don't Limit" first) or the Table Data Export Wizard.
-- =====================================================================

SELECT * FROM online_retail;
