{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Journal entry fact table
select
    entry_id,
    account_id,
    cost_center_id,
    entry_date,
    debit_amount,
    credit_amount,
    currency_code,
    description,
    'ITA' as source_country,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('stg_journal_entry') }}
