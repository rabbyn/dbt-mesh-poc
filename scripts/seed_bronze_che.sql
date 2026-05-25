-- ============================================================
-- Bronze Data Seed Script for Switzerland (wh_poc_che)
-- Fixed for Fabric Warehouse: DATETIME2(6) + GENERATE_SERIES
-- ============================================================

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO

-- ============================================================
-- SALES DOMAIN
-- ============================================================

-- 1. CLIENT (~5000 rows)
DROP TABLE IF EXISTS bronze.client;
CREATE TABLE bronze.client (
    client_id    INT,
    client_name  VARCHAR(200),
    client_type  VARCHAR(50),
    country_code VARCHAR(3),
    created_at   DATETIME2(6)
);

INSERT INTO bronze.client (client_id, client_name, client_type, country_code, created_at)
SELECT
    value AS client_id,
    CONCAT('Client_CHE_', value) AS client_name,
    CASE value % 4
        WHEN 0 THEN 'ENTERPRISE'
        WHEN 1 THEN 'SMB'
        WHEN 2 THEN 'INDIVIDUAL'
        WHEN 3 THEN 'GOVERNMENT'
    END AS client_type,
    CASE value % 5
        WHEN 0 THEN 'CHE'
        WHEN 1 THEN 'CHE'
        WHEN 2 THEN 'CHE'
        WHEN 3 THEN 'DEU'
        WHEN 4 THEN 'FRA'
    END AS country_code,
    DATEADD(DAY, -(value % 1000), '2026-01-01') AS created_at
FROM GENERATE_SERIES(1, 5000);

-- 2. BRANCH (~200 rows)
DROP TABLE IF EXISTS bronze.branch;
CREATE TABLE bronze.branch (
    branch_id     INT,
    branch_name   VARCHAR(200),
    branch_city   VARCHAR(100),
    branch_region VARCHAR(100),
    is_active     BIT
);

INSERT INTO bronze.branch (branch_id, branch_name, branch_city, branch_region, is_active)
SELECT
    value AS branch_id,
    CONCAT('Branch_CHE_', value) AS branch_name,
    CASE value % 8
        WHEN 0 THEN 'Zurich'
        WHEN 1 THEN 'Geneva'
        WHEN 2 THEN 'Basel'
        WHEN 3 THEN 'Bern'
        WHEN 4 THEN 'Lausanne'
        WHEN 5 THEN 'Lucerne'
        WHEN 6 THEN 'St. Gallen'
        WHEN 7 THEN 'Lugano'
    END AS branch_city,
    CASE value % 4
        WHEN 0 THEN 'German-speaking'
        WHEN 1 THEN 'French-speaking'
        WHEN 2 THEN 'Italian-speaking'
        WHEN 3 THEN 'German-speaking'
    END AS branch_region,
    CASE WHEN value % 10 = 0 THEN 0 ELSE 1 END AS is_active
FROM GENERATE_SERIES(1, 200);

-- 3. SALES_ORDER (~10000 rows)
DROP TABLE IF EXISTS bronze.sales_order;
CREATE TABLE bronze.sales_order (
    order_id      INT,
    client_id     INT,
    branch_id     INT,
    order_date    DATE,
    amount        DECIMAL(18,2),
    currency_code VARCHAR(3),
    order_status  VARCHAR(50)
);

INSERT INTO bronze.sales_order (order_id, client_id, branch_id, order_date, amount, currency_code, order_status)
SELECT
    value AS order_id,
    (value % 5000) + 1 AS client_id,
    (value % 200)  + 1 AS branch_id,
    DATEADD(DAY, -(value % 365), '2026-05-01') AS order_date,
    CAST(50.0 + (value % 9950) AS DECIMAL(18,2)) AS amount,
    CASE value % 3
        WHEN 0 THEN 'CHF'
        WHEN 1 THEN 'EUR'
        WHEN 2 THEN 'CHF'
    END AS currency_code,
    CASE value % 5
        WHEN 0 THEN 'COMPLETED'
        WHEN 1 THEN 'COMPLETED'
        WHEN 2 THEN 'PENDING'
        WHEN 3 THEN 'SHIPPED'
        WHEN 4 THEN 'CANCELLED'
    END AS order_status
FROM GENERATE_SERIES(1, 10000);

-- ============================================================
-- FINANCE DOMAIN
-- ============================================================

-- 4. ACCOUNT (~500 rows)
DROP TABLE IF EXISTS bronze.account;
CREATE TABLE bronze.account (
    account_id       INT,
    account_name     VARCHAR(200),
    account_type     VARCHAR(50),
    account_category VARCHAR(50),
    is_active        BIT
);

INSERT INTO bronze.account (account_id, account_name, account_type, account_category, is_active)
SELECT
    value AS account_id,
    CONCAT('Account_CHE_', value) AS account_name,
    CASE value % 5
        WHEN 0 THEN 'ASSET'
        WHEN 1 THEN 'LIABILITY'
        WHEN 2 THEN 'EQUITY'
        WHEN 3 THEN 'REVENUE'
        WHEN 4 THEN 'EXPENSE'
    END AS account_type,
    CASE value % 6
        WHEN 0 THEN 'CURRENT_ASSET'
        WHEN 1 THEN 'FIXED_ASSET'
        WHEN 2 THEN 'SHORT_TERM_LIABILITY'
        WHEN 3 THEN 'LONG_TERM_LIABILITY'
        WHEN 4 THEN 'OPERATING_REVENUE'
        WHEN 5 THEN 'OPERATING_EXPENSE'
    END AS account_category,
    CASE WHEN value % 20 = 0 THEN 0 ELSE 1 END AS is_active
FROM GENERATE_SERIES(1, 500);

-- 5. COST_CENTER (~100 rows)
DROP TABLE IF EXISTS bronze.cost_center;
CREATE TABLE bronze.cost_center (
    cost_center_id   INT,
    cost_center_name VARCHAR(200),
    department       VARCHAR(100),
    manager_name     VARCHAR(200),
    is_active        BIT
);

INSERT INTO bronze.cost_center (cost_center_id, cost_center_name, department, manager_name, is_active)
SELECT
    value AS cost_center_id,
    CONCAT('CC_CHE_', value) AS cost_center_name,
    CASE value % 8
        WHEN 0 THEN 'Sales'
        WHEN 1 THEN 'Marketing'
        WHEN 2 THEN 'Finance'
        WHEN 3 THEN 'HR'
        WHEN 4 THEN 'IT'
        WHEN 5 THEN 'Operations'
        WHEN 6 THEN 'Legal'
        WHEN 7 THEN 'R&D'
    END AS department,
    CONCAT('Manager_', value) AS manager_name,
    CASE WHEN value % 15 = 0 THEN 0 ELSE 1 END AS is_active
FROM GENERATE_SERIES(1, 100);

-- 6. JOURNAL_ENTRY (~10000 rows)
DROP TABLE IF EXISTS bronze.journal_entry;
CREATE TABLE bronze.journal_entry (
    entry_id       INT,
    account_id     INT,
    cost_center_id INT,
    entry_date     DATE,
    debit_amount   DECIMAL(18,2),
    credit_amount  DECIMAL(18,2),
    currency_code  VARCHAR(3),
    description    VARCHAR(500)
);

INSERT INTO bronze.journal_entry (entry_id, account_id, cost_center_id, entry_date, debit_amount, credit_amount, currency_code, description)
SELECT
    value AS entry_id,
    (value % 500) + 1 AS account_id,
    (value % 100) + 1 AS cost_center_id,
    DATEADD(DAY, -(value % 365), '2026-05-01') AS entry_date,
    CASE WHEN value % 2 = 0 THEN CAST(100.0 + (value % 9900) AS DECIMAL(18,2)) ELSE 0 END AS debit_amount,
    CASE WHEN value % 2 = 1 THEN CAST(100.0 + (value % 9900) AS DECIMAL(18,2)) ELSE 0 END AS credit_amount,
    CASE value % 2 WHEN 0 THEN 'CHF' WHEN 1 THEN 'EUR' END AS currency_code,
    CONCAT('Journal entry ', value,
        CASE value % 6
            WHEN 0 THEN ' - Salary payment'
            WHEN 1 THEN ' - Office supplies'
            WHEN 2 THEN ' - Client invoice'
            WHEN 3 THEN ' - Tax provision'
            WHEN 4 THEN ' - Depreciation'
            WHEN 5 THEN ' - Consulting fees'
        END
    ) AS description
FROM GENERATE_SERIES(1, 10000);

-- ============================================================
-- Verification
-- ============================================================
SELECT 'bronze.client'       AS table_name, COUNT(*) AS row_count FROM bronze.client
UNION ALL SELECT 'bronze.branch',        COUNT(*) FROM bronze.branch
UNION ALL SELECT 'bronze.sales_order',   COUNT(*) FROM bronze.sales_order
UNION ALL SELECT 'bronze.account',       COUNT(*) FROM bronze.account
UNION ALL SELECT 'bronze.cost_center',   COUNT(*) FROM bronze.cost_center
UNION ALL SELECT 'bronze.journal_entry', COUNT(*) FROM bronze.journal_entry;