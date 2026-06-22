{{ config(materialized='table') }}

-- Global Gold: Union of Italy and Switzerland journal entry facts
select
    entry_id,
    account_id,
    cost_center_id,
    entry_date,
    debit_amount,
    credit_amount,
    currency_code,
    description,
    source_country,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
-- Source: dbt_poc_ita project (ITA Fabric workspace, gold.fct_journal_entry)
from {{ source('gold_ita_finance', 'fct_journal_entry') }}

union all

select
    entry_id,
    account_id,
    cost_center_id,
    entry_date,
    debit_amount,
    credit_amount,
    currency_code,
    description,
    source_country,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
-- Source: dbt_poc_che project (CHE Fabric workspace, gold.fct_journal_entry)
from {{ source('gold_che_finance', 'fct_journal_entry') }}
