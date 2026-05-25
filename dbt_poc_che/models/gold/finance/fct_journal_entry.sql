{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Journal entry fact table - Switzerland
select
    cast(entry_id as int) as entry_id,
    cast(account_id as int) as account_id,
    cast(cost_center_id as int) as cost_center_id,
    entry_date,
    debit_amount,
    credit_amount,
    currency_code,
    description,
    'CHE' as source_country,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('stg_journal_entry') }}
