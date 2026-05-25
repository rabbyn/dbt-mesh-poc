-- =============================================================================
-- Seed script: Pre-stage upstream gold finance data into gold_wh_glb_finance
-- Simulates Fabric Shortcuts from ITA (Lakehouse) and CHE (Warehouse)
--
-- In PRODUCTION: Create Fabric Shortcuts in gold_wh_glb_finance that point to:
--   - gold_lh_ita (Italy Lakehouse) -> finance schema -> exposed as ita_gold
--   - gold_wh_che (Switzerland Warehouse) -> finance schema -> exposed as che_gold
--
-- For this POC: Manually create schemas and insert representative data.
-- Run this script against gold_wh_glb_finance via Fabric portal SQL editor.
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
-- ITALY GOLD - Finance Domain
-- ─────────────────────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS ita_gold.dim_account;
CREATE TABLE ita_gold.dim_account (
    account_id       int,
    account_name     varchar(200),
    account_type     varchar(50),
    account_category varchar(50),
    source_country   varchar(3),
    is_active        bit,
    _loaded_at       datetime2(6)
);
INSERT INTO ita_gold.dim_account VALUES
(1, 'Ricavi Vendite',      'Revenue',   'Operating',     'ITA', 1, SYSUTCDATETIME()),
(2, 'Costo del Personale', 'Expense',   'Operating',     'ITA', 1, SYSUTCDATETIME()),
(3, 'Ammortamenti',        'Expense',   'Non-Operating', 'ITA', 1, SYSUTCDATETIME()),
(4, 'Crediti Commerciali', 'Asset',     'Current',       'ITA', 1, SYSUTCDATETIME()),
(5, 'Debiti Fornitori',    'Liability', 'Current',       'ITA', 1, SYSUTCDATETIME());

DROP TABLE IF EXISTS ita_gold.dim_cost_center;
CREATE TABLE ita_gold.dim_cost_center (
    cost_center_id   int,
    cost_center_name varchar(200),
    department       varchar(100),
    manager_name     varchar(200),
    source_country   varchar(3),
    is_active        bit,
    _loaded_at       datetime2(6)
);
INSERT INTO ita_gold.dim_cost_center VALUES
(1, 'CC Milano Vendite',  'Sales',           'Marco Rossi',    'ITA', 1, SYSUTCDATETIME()),
(2, 'CC Roma Operations', 'Operations',      'Laura Bianchi',  'ITA', 1, SYSUTCDATETIME()),
(3, 'CC Torino IT',       'Technology',      'Giuseppe Verdi', 'ITA', 1, SYSUTCDATETIME()),
(4, 'CC Firenze HR',      'Human Resources', 'Anna Conti',     'ITA', 0, SYSUTCDATETIME()),
(5, 'CC Napoli Finance',  'Finance',         'Paolo Russo',    'ITA', 1, SYSUTCDATETIME());

DROP TABLE IF EXISTS ita_gold.fct_journal_entry;
CREATE TABLE ita_gold.fct_journal_entry (
    entry_id       int,
    account_id     int,
    cost_center_id int,
    entry_date     date,
    debit_amount   decimal(18,2),
    credit_amount  decimal(18,2),
    currency_code  varchar(3),
    description    varchar(500),
    source_country varchar(3),
    _loaded_at     datetime2(6)
);
INSERT INTO ita_gold.fct_journal_entry VALUES
(1, 1, 1, '2024-01-31', 0.00,     45000.00, 'EUR', 'Ricavi vendite gennaio', 'ITA', SYSUTCDATETIME()),
(2, 2, 1, '2024-01-31', 28000.00, 0.00,     'EUR', 'Stipendi gennaio',       'ITA', SYSUTCDATETIME()),
(3, 3, 3, '2024-01-31', 5000.00,  0.00,     'EUR', 'Ammortamento server',    'ITA', SYSUTCDATETIME()),
(4, 4, 1, '2024-02-15', 22000.00, 0.00,     'EUR', 'Credito cliente Fiat',  'ITA', SYSUTCDATETIME()),
(5, 5, 2, '2024-02-28', 0.00,     15000.00, 'EUR', 'Pagamento fornitore',   'ITA', SYSUTCDATETIME()),
(6, 1, 2, '2024-02-28', 0.00,     38000.00, 'EUR', 'Ricavi vendite febbraio','ITA', SYSUTCDATETIME()),
(7, 2, 2, '2024-02-28', 28000.00, 0.00,     'EUR', 'Stipendi febbraio',      'ITA', SYSUTCDATETIME()),
(8, 1, 1, '2024-03-31', 0.00,     52000.00, 'EUR', 'Ricavi vendite marzo',  'ITA', SYSUTCDATETIME());

-- ─────────────────────────────────────────────────────────────────────────────
-- SWITZERLAND GOLD - Finance Domain
-- ─────────────────────────────────────────────────────────────────────────────

DROP TABLE IF EXISTS che_gold.dim_account;
CREATE TABLE che_gold.dim_account (
    account_id       int,
    account_name     varchar(200),
    account_type     varchar(50),
    account_category varchar(50),
    source_country   varchar(3),
    is_active        bit,
    _loaded_at       datetime2(6)
);
INSERT INTO che_gold.dim_account VALUES
(1, 'Sales Revenue',      'Revenue',   'Operating',     'CHE', 1, SYSUTCDATETIME()),
(2, 'Personnel Costs',    'Expense',   'Operating',     'CHE', 1, SYSUTCDATETIME()),
(3, 'Depreciation',       'Expense',   'Non-Operating', 'CHE', 1, SYSUTCDATETIME()),
(4, 'Trade Receivables',  'Asset',     'Current',       'CHE', 1, SYSUTCDATETIME()),
(5, 'Trade Payables',     'Liability', 'Current',       'CHE', 1, SYSUTCDATETIME());

DROP TABLE IF EXISTS che_gold.dim_cost_center;
CREATE TABLE che_gold.dim_cost_center (
    cost_center_id   int,
    cost_center_name varchar(200),
    department       varchar(100),
    manager_name     varchar(200),
    source_country   varchar(3),
    is_active        bit,
    _loaded_at       datetime2(6)
);
INSERT INTO che_gold.dim_cost_center VALUES
(1, 'CC Zurich Sales',    'Sales',           'Hans Mueller',    'CHE', 1, SYSUTCDATETIME()),
(2, 'CC Geneva Ops',      'Operations',      'Marie Dupont',    'CHE', 1, SYSUTCDATETIME()),
(3, 'CC Basel IT',        'Technology',      'Thomas Schmidt',  'CHE', 1, SYSUTCDATETIME()),
(4, 'CC Bern HR',         'Human Resources', 'Sabine Weber',    'CHE', 0, SYSUTCDATETIME()),
(5, 'CC Lausanne Finance','Finance',         'Pierre Martin',   'CHE', 1, SYSUTCDATETIME());

DROP TABLE IF EXISTS che_gold.fct_journal_entry;
CREATE TABLE che_gold.fct_journal_entry (
    entry_id       int,
    account_id     int,
    cost_center_id int,
    entry_date     date,
    debit_amount   decimal(18,2),
    credit_amount  decimal(18,2),
    currency_code  varchar(3),
    description    varchar(500),
    source_country varchar(3),
    _loaded_at     datetime2(6)
);
INSERT INTO che_gold.fct_journal_entry VALUES
(1, 1, 1, '2024-01-31', 0.00,     65000.00, 'CHF', 'January sales revenue',  'CHE', SYSUTCDATETIME()),
(2, 2, 1, '2024-01-31', 42000.00, 0.00,     'CHF', 'January salaries',        'CHE', SYSUTCDATETIME()),
(3, 3, 3, '2024-01-31', 8000.00,  0.00,     'CHF', 'Server depreciation',     'CHE', SYSUTCDATETIME()),
(4, 4, 1, '2024-02-15', 35000.00, 0.00,     'CHF', 'Nestle receivable',       'CHE', SYSUTCDATETIME()),
(5, 5, 2, '2024-02-28', 0.00,     22000.00, 'CHF', 'Supplier payment',        'CHE', SYSUTCDATETIME()),
(6, 1, 2, '2024-02-28', 0.00,     58000.00, 'CHF', 'February sales revenue',  'CHE', SYSUTCDATETIME()),
(7, 2, 2, '2024-02-28', 42000.00, 0.00,     'CHF', 'February salaries',       'CHE', SYSUTCDATETIME()),
(8, 1, 1, '2024-03-31', 0.00,     72000.00, 'CHF', 'March sales revenue',     'CHE', SYSUTCDATETIME());

-- ─────────────────────────────────────────────────────────────────────────────
-- Verification
-- ─────────────────────────────────────────────────────────────────────────────
SELECT 'ita_gold.dim_account'      as [table], COUNT(*) as [rows] FROM ita_gold.dim_account
UNION ALL SELECT 'ita_gold.dim_cost_center',   COUNT(*) FROM ita_gold.dim_cost_center
UNION ALL SELECT 'ita_gold.fct_journal_entry', COUNT(*) FROM ita_gold.fct_journal_entry
UNION ALL SELECT 'che_gold.dim_account',       COUNT(*) FROM che_gold.dim_account
UNION ALL SELECT 'che_gold.dim_cost_center',   COUNT(*) FROM che_gold.dim_cost_center
UNION ALL SELECT 'che_gold.fct_journal_entry', COUNT(*) FROM che_gold.fct_journal_entry;
