{{ config(materialized='table') }}

-- Global Gold: Union of Italy and Switzerland cost center dimensions
select
    cost_center_id,
    cost_center_name,
    department,
    manager_name,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('ita_gold_finance', 'dim_cost_center') }}

union all

select
    cost_center_id,
    cost_center_name,
    department,
    manager_name,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('che_gold_finance', 'dim_cost_center') }}
