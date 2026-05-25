{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Account dimension - Switzerland
select
    cast(account_id as int) as account_id,
    account_name,
    account_type,
    account_category,
    'CHE' as source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('stg_account') }}
