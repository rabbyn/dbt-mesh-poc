{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Branch dimension
select
    branch_id,
    branch_name,
    branch_city,
    branch_region,
    'ITA' as source_country,
    is_active,
    current_timestamp() as _loaded_at
from {{ ref('stg_branch') }}
