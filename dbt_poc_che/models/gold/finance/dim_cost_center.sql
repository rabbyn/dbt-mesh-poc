{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Cost center dimension - Switzerland
select
    cast(cost_center_id as int) as cost_center_id,
    cost_center_name,
    department,
    manager_name,
    'CHE' as source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('stg_cost_center') }}
