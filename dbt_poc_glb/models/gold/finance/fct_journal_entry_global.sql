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
from {{ ref('dbt_poc_ita', 'fct_journal_entry') }}

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
from {{ ref('dbt_poc_che', 'fct_journal_entry') }}
