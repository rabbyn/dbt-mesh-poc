{{ config(materialized='table') }}

-- Global Gold: Union of Italy and Switzerland branch dimensions
select
    branch_id,
    branch_name,
    branch_city,
    branch_region,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('ita_gold_sales', 'dim_branch') }}

union all

select
    branch_id,
    branch_name,
    branch_city,
    branch_region,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('che_gold_sales', 'dim_branch') }}
