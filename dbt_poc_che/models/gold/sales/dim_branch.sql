{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Branch dimension - Switzerland
select
    cast(branch_id as int) as branch_id,
    branch_name,
    branch_city,
    branch_region,
    'CHE' as source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('stg_branch') }}
