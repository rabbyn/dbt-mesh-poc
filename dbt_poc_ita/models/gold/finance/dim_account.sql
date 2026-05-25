{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Account dimension
select
    account_id,
    account_name,
    account_type,
    account_category,
    'ITA' as source_country,
    is_active,
    current_timestamp() as _loaded_at
from {{ ref('stg_account') }}
