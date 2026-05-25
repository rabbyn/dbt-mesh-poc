-- =============================================================================
-- Seed script: Pre-stage upstream gold data into wh_poc_glb_sales
-- Simulates Fabric Shortcuts from ITA (Lakehouse) and CHE (Warehouse)
-- 
-- In PRODUCTION: Create Fabric Shortcuts in the GLB workspace that point to:
--   - lh_poc_ita_gold (Italy Lakehouse gold tables)
--   - wh_poc_che / dbo_gold (Switzerland Warehouse gold schema)
-- Shortcuts expose upstream tables as local schemas in the GLB warehouse.
--
-- For this POC: We manually create schemas and insert representative data.
-- Run this script against wh_poc_glb_sales via Fabric portal SQL editor.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- Create schemas to represent shortcutted upstream gold layers
-- ─────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ita_gold')
    EXEC('CREATE SCHEMA ita_gold');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'che_gold')
    EXEC('CREATE SCHEMA che_gold');
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- ITALY GOLD - Sales Domain
-- ─────────────────────────────────────────────────────────────────────────────

-- dim_branch (Italy)
DROP TABLE IF EXISTS ita_gold.dim_branch;
CREATE TABLE ita_gold.dim_branch (
    branch_id int,
    branch_name varchar(200),
    branch_city varchar(100),
    branch_region varchar(100),
    source_country varchar(3),
    is_active bit,
    _loaded_at datetime2(6)
);
INSERT INTO ita_gold.dim_branch VALUES
(1, 'Milano Centro', 'Milano', 'Lombardia', 'ITA', 1, SYSUTCDATETIME()),
(2, 'Roma Termini', 'Roma', 'Lazio', 'ITA', 1, SYSUTCDATETIME()),
(3, 'Torino Nord', 'Torino', 'Piemonte', 'ITA', 1, SYSUTCDATETIME()),
(4, 'Firenze Sud', 'Firenze', 'Toscana', 'ITA', 0, SYSUTCDATETIME()),
(5, 'Napoli Centro', 'Napoli', 'Campania', 'ITA', 1, SYSUTCDATETIME());

-- dim_client (Italy)
DROP TABLE IF EXISTS ita_gold.dim_client;
CREATE TABLE ita_gold.dim_client (
    client_id int,
    client_name varchar(200),
    client_type varchar(50),
    country_code varchar(3),
    source_country varchar(3),
    created_at datetime2(6),
    _loaded_at datetime2(6)
);
INSERT INTO ita_gold.dim_client VALUES
(1, 'Fiat SpA', 'Enterprise', 'ITA', 'ITA', '2023-01-15', SYSUTCDATETIME()),
(2, 'Barilla Group', 'Enterprise', 'ITA', 'ITA', '2023-02-20', SYSUTCDATETIME()),
(3, 'Esselunga', 'Mid-Market', 'ITA', 'ITA', '2023-03-10', SYSUTCDATETIME()),
(4, 'Luxottica', 'Enterprise', 'ITA', 'ITA', '2023-04-05', SYSUTCDATETIME()),
(5, 'Telecom Italia', 'Enterprise', 'ITA', 'ITA', '2023-05-12', SYSUTCDATETIME());

-- fct_sales_order (Italy)
DROP TABLE IF EXISTS ita_gold.fct_sales_order;
CREATE TABLE ita_gold.fct_sales_order (
    order_id int,
    client_id int,
    branch_id int,
    order_date date,
    amount decimal(18,2),
    currency_code varchar(3),
    order_status varchar(50),
    source_country varchar(3),
    _loaded_at datetime2(6)
);
INSERT INTO ita_gold.fct_sales_order VALUES
(1, 1, 1, '2024-01-10', 15000.00, 'EUR', 'Completed', 'ITA', SYSUTCDATETIME()),
(2, 2, 1, '2024-01-15', 8500.50, 'EUR', 'Completed', 'ITA', SYSUTCDATETIME()),
(3, 3, 2, '2024-02-01', 22000.00, 'EUR', 'Completed', 'ITA', SYSUTCDATETIME()),
(4, 4, 3, '2024-02-14', 12750.00, 'EUR', 'Pending', 'ITA', SYSUTCDATETIME()),
(5, 5, 2, '2024-03-01', 9800.00, 'EUR', 'Completed', 'ITA', SYSUTCDATETIME()),
(6, 1, 4, '2024-03-15', 31000.00, 'EUR', 'Completed', 'ITA', SYSUTCDATETIME()),
(7, 2, 5, '2024-04-01', 5600.00, 'EUR', 'Cancelled', 'ITA', SYSUTCDATETIME()),
(8, 3, 1, '2024-04-10', 18200.00, 'EUR', 'Completed', 'ITA', SYSUTCDATETIME());

-- ─────────────────────────────────────────────────────────────────────────────
-- ITALY GOLD - Finance Domain
-- ─────────────────────────────────────────────────────────────────────────────

-- dim_account (Italy)
DROP TABLE IF EXISTS ita_gold.dim_account;
CREATE TABLE ita_gold.dim_account (
    account_id int,
    account_name varchar(200),
    account_type varchar(50),
    account_category varchar(50),
    source_country varchar(3),
    is_active bit,
    _loaded_at datetime2(6)
);
INSERT INTO ita_gold.dim_account VALUES
(1, 'Ricavi Vendite', 'Revenue', 'Operating', 'ITA', 1, SYSUTCDATETIME()),
(2, 'Costo del Personale', 'Expense', 'Operating', 'ITA', 1, SYSUTCDATETIME()),
(3, 'Ammortamenti', 'Expense', 'Non-Operating', 'ITA', 1, SYSUTCDATETIME()),
(4, 'Crediti Commerciali', 'Asset', 'Current', 'ITA', 1, SYSUTCDATETIME()),
(5, 'Debiti Fornitori', 'Liability', 'Current', 'ITA', 1, SYSUTCDATETIME());

-- dim_cost_center (Italy)
DROP TABLE IF EXISTS ita_gold.dim_cost_center;
CREATE TABLE ita_gold.dim_cost_center (
    cost_center_id int,
    cost_center_name varchar(200),
    department varchar(100),
    manager_name varchar(200),
    source_country varchar(3),
    is_active bit,
    _loaded_at datetime2(6)
);
INSERT INTO ita_gold.dim_cost_center VALUES
(1, 'CC Milano Vendite', 'Sales', 'Marco Rossi', 'ITA', 1, SYSUTCDATETIME()),
(2, 'CC Roma Operations', 'Operations', 'Laura Bianchi', 'ITA', 1, SYSUTCDATETIME()),
(3, 'CC Torino IT', 'Technology', 'Giuseppe Verdi', 'ITA', 1, SYSUTCDATETIME()),
(4, 'CC Firenze HR', 'Human Resources', 'Anna Conti', 'ITA', 0, SYSUTCDATETIME()),
(5, 'CC Napoli Finance', 'Finance', 'Paolo Russo', 'ITA', 1, SYSUTCDATETIME());

-- fct_journal_entry (Italy)
DROP TABLE IF EXISTS ita_gold.fct_journal_entry;
CREATE TABLE ita_gold.fct_journal_entry (
    entry_id int,
    account_id int,
    cost_center_id int,
    entry_date date,
    debit_amount decimal(18,2),
    credit_amount decimal(18,2),
    currency_code varchar(3),
    description varchar(500),
    source_country varchar(3),
    _loaded_at datetime2(6)
);
INSERT INTO ita_gold.fct_journal_entry VALUES
(1, 1, 1, '2024-01-31', 0.00, 45000.00, 'EUR', 'Ricavi vendite gennaio', 'ITA', SYSUTCDATETIME()),
(2, 2, 1, '2024-01-31', 28000.00, 0.00, 'EUR', 'Stipendi gennaio', 'ITA', SYSUTCDATETIME()),
(3, 3, 3, '2024-01-31', 5000.00, 0.00, 'EUR', 'Ammortamento server', 'ITA', SYSUTCDATETIME()),
(4, 4, 1, '2024-02-15', 22000.00, 0.00, 'EUR', 'Credito cliente Fiat', 'ITA', SYSUTCDATETIME()),
(5, 5, 2, '2024-02-28', 0.00, 15000.00, 'EUR', 'Pagamento fornitore', 'ITA', SYSUTCDATETIME()),
(6, 1, 2, '2024-02-28', 0.00, 38000.00, 'EUR', 'Ricavi vendite febbraio', 'ITA', SYSUTCDATETIME()),
(7, 2, 2, '2024-02-28', 28000.00, 0.00, 'EUR', 'Stipendi febbraio', 'ITA', SYSUTCDATETIME()),
(8, 1, 1, '2024-03-31', 0.00, 52000.00, 'EUR', 'Ricavi vendite marzo', 'ITA', SYSUTCDATETIME());

-- ─────────────────────────────────────────────────────────────────────────────
-- SWITZERLAND GOLD - Sales Domain
-- (Mirrors data from wh_poc_che.dbo_gold)
-- ─────────────────────────────────────────────────────────────────────────────

-- dim_branch (Switzerland)
DROP TABLE IF EXISTS che_gold.dim_branch;
CREATE TABLE che_gold.dim_branch (
    branch_id int,
    branch_name varchar(200),
    branch_city varchar(100),
    branch_region varchar(100),
    source_country varchar(3),
    is_active bit,
    _loaded_at datetime2(6)
);
INSERT INTO che_gold.dim_branch VALUES
(1, 'Zurich Hauptbahnhof', 'Zurich', 'Zurich', 'CHE', 1, SYSUTCDATETIME()),
(2, 'Geneva Lac', 'Geneva', 'Geneva', 'CHE', 1, SYSUTCDATETIME()),
(3, 'Basel Stadt', 'Basel', 'Basel-Stadt', 'CHE', 1, SYSUTCDATETIME()),
(4, 'Bern Zentrum', 'Bern', 'Bern', 'CHE', 0, SYSUTCDATETIME()),
(5, 'Lausanne Gare', 'Lausanne', 'Vaud', 'CHE', 1, SYSUTCDATETIME());

-- dim_client (Switzerland)
DROP TABLE IF EXISTS che_gold.dim_client;
CREATE TABLE che_gold.dim_client (
    client_id int,
    client_name varchar(200),
    client_type varchar(50),
    country_code varchar(3),
    source_country varchar(3),
    created_at datetime2(6),
    _loaded_at datetime2(6)
);
INSERT INTO che_gold.dim_client VALUES
(1, 'Nestle SA', 'Enterprise', 'CHE', 'CHE', '2023-01-10', SYSUTCDATETIME()),
(2, 'Novartis AG', 'Enterprise', 'CHE', 'CHE', '2023-02-15', SYSUTCDATETIME()),
(3, 'UBS Group', 'Enterprise', 'CHE', 'CHE', '2023-03-20', SYSUTCDATETIME()),
(4, 'Swatch Group', 'Mid-Market', 'CHE', 'CHE', '2023-04-01', SYSUTCDATETIME()),
(5, 'ABB Ltd', 'Enterprise', 'CHE', 'CHE', '2023-05-10', SYSUTCDATETIME());

-- fct_sales_order (Switzerland)
DROP TABLE IF EXISTS che_gold.fct_sales_order;
CREATE TABLE che_gold.fct_sales_order (
    order_id int,
    client_id int,
    branch_id int,
    order_date date,
    amount decimal(18,2),
    currency_code varchar(3),
    order_status varchar(50),
    source_country varchar(3),
    _loaded_at datetime2(6)
);
INSERT INTO che_gold.fct_sales_order VALUES
(1, 1, 1, '2024-01-08', 25000.00, 'CHF', 'Completed', 'CHE', SYSUTCDATETIME()),
(2, 2, 1, '2024-01-20', 18000.00, 'CHF', 'Completed', 'CHE', SYSUTCDATETIME()),
(3, 3, 2, '2024-02-05', 42000.00, 'CHF', 'Completed', 'CHE', SYSUTCDATETIME()),
(4, 4, 3, '2024-02-18', 9500.00, 'CHF', 'Pending', 'CHE', SYSUTCDATETIME()),
(5, 5, 2, '2024-03-03', 35000.00, 'CHF', 'Completed', 'CHE', SYSUTCDATETIME()),
(6, 1, 4, '2024-03-20', 28000.00, 'CHF', 'Completed', 'CHE', SYSUTCDATETIME()),
(7, 3, 5, '2024-04-05', 15500.00, 'CHF', 'Cancelled', 'CHE', SYSUTCDATETIME()),
(8, 2, 1, '2024-04-15', 21000.00, 'CHF', 'Completed', 'CHE', SYSUTCDATETIME());

-- ─────────────────────────────────────────────────────────────────────────────
-- SWITZERLAND GOLD - Finance Domain
-- ─────────────────────────────────────────────────────────────────────────────

-- dim_account (Switzerland)
DROP TABLE IF EXISTS che_gold.dim_account;
CREATE TABLE che_gold.dim_account (
    account_id int,
    account_name varchar(200),
    account_type varchar(50),
    account_category varchar(50),
    source_country varchar(3),
    is_active bit,
    _loaded_at datetime2(6)
);
INSERT INTO che_gold.dim_account VALUES
(1, 'Sales Revenue', 'Revenue', 'Operating', 'CHE', 1, SYSUTCDATETIME()),
(2, 'Personnel Costs', 'Expense', 'Operating', 'CHE', 1, SYSUTCDATETIME()),
(3, 'Depreciation', 'Expense', 'Non-Operating', 'CHE', 1, SYSUTCDATETIME()),
(4, 'Trade Receivables', 'Asset', 'Current', 'CHE', 1, SYSUTCDATETIME()),
(5, 'Trade Payables', 'Liability', 'Current', 'CHE', 1, SYSUTCDATETIME());

-- dim_cost_center (Switzerland)
DROP TABLE IF EXISTS che_gold.dim_cost_center;
CREATE TABLE che_gold.dim_cost_center (
    cost_center_id int,
    cost_center_name varchar(200),
    department varchar(100),
    manager_name varchar(200),
    source_country varchar(3),
    is_active bit,
    _loaded_at datetime2(6)
);
INSERT INTO che_gold.dim_cost_center VALUES
(1, 'CC Zurich Sales', 'Sales', 'Hans Mueller', 'CHE', 1, SYSUTCDATETIME()),
(2, 'CC Geneva Ops', 'Operations', 'Marie Dupont', 'CHE', 1, SYSUTCDATETIME()),
(3, 'CC Basel IT', 'Technology', 'Thomas Schmidt', 'CHE', 1, SYSUTCDATETIME()),
(4, 'CC Bern HR', 'Human Resources', 'Sabine Weber', 'CHE', 0, SYSUTCDATETIME()),
(5, 'CC Lausanne Finance', 'Finance', 'Pierre Martin', 'CHE', 1, SYSUTCDATETIME());

-- fct_journal_entry (Switzerland)
DROP TABLE IF EXISTS che_gold.fct_journal_entry;
CREATE TABLE che_gold.fct_journal_entry (
    entry_id int,
    account_id int,
    cost_center_id int,
    entry_date date,
    debit_amount decimal(18,2),
    credit_amount decimal(18,2),
    currency_code varchar(3),
    description varchar(500),
    source_country varchar(3),
    _loaded_at datetime2(6)
);
INSERT INTO che_gold.fct_journal_entry VALUES
(1, 1, 1, '2024-01-31', 0.00, 65000.00, 'CHF', 'January sales revenue', 'CHE', SYSUTCDATETIME()),
(2, 2, 1, '2024-01-31', 42000.00, 0.00, 'CHF', 'January salaries', 'CHE', SYSUTCDATETIME()),
(3, 3, 3, '2024-01-31', 8000.00, 0.00, 'CHF', 'Server depreciation', 'CHE', SYSUTCDATETIME()),
(4, 4, 1, '2024-02-15', 35000.00, 0.00, 'CHF', 'Nestle receivable', 'CHE', SYSUTCDATETIME()),
(5, 5, 2, '2024-02-28', 0.00, 22000.00, 'CHF', 'Supplier payment', 'CHE', SYSUTCDATETIME()),
(6, 1, 2, '2024-02-28', 0.00, 58000.00, 'CHF', 'February sales revenue', 'CHE', SYSUTCDATETIME()),
(7, 2, 2, '2024-02-28', 42000.00, 0.00, 'CHF', 'February salaries', 'CHE', SYSUTCDATETIME()),
(8, 1, 1, '2024-03-31', 0.00, 72000.00, 'CHF', 'March sales revenue', 'CHE', SYSUTCDATETIME());

-- ─────────────────────────────────────────────────────────────────────────────
-- Verification
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 'ita_gold.dim_branch' as [table], COUNT(*) as [rows] FROM ita_gold.dim_branch
UNION ALL SELECT 'ita_gold.dim_client', COUNT(*) FROM ita_gold.dim_client
UNION ALL SELECT 'ita_gold.fct_sales_order', COUNT(*) FROM ita_gold.fct_sales_order
UNION ALL SELECT 'ita_gold.dim_account', COUNT(*) FROM ita_gold.dim_account
UNION ALL SELECT 'ita_gold.dim_cost_center', COUNT(*) FROM ita_gold.dim_cost_center
UNION ALL SELECT 'ita_gold.fct_journal_entry', COUNT(*) FROM ita_gold.fct_journal_entry
UNION ALL SELECT 'che_gold.dim_branch', COUNT(*) FROM che_gold.dim_branch
UNION ALL SELECT 'che_gold.dim_client', COUNT(*) FROM che_gold.dim_client
UNION ALL SELECT 'che_gold.fct_sales_order', COUNT(*) FROM che_gold.fct_sales_order
UNION ALL SELECT 'che_gold.dim_account', COUNT(*) FROM che_gold.dim_account
UNION ALL SELECT 'che_gold.dim_cost_center', COUNT(*) FROM che_gold.dim_cost_center
UNION ALL SELECT 'che_gold.fct_journal_entry', COUNT(*) FROM che_gold.fct_journal_entry;
