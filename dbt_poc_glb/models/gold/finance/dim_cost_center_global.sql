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
-- Source: dbt_poc_ita project (ITA Fabric workspace, gold.dim_cost_center)
from {{ source('gold_ita_finance', 'dim_cost_center') }}

union all

select
    cost_center_id,
    cost_center_name,
    department,
    manager_name,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
-- Source: dbt_poc_che project (CHE Fabric workspace, gold.dim_cost_center)
from {{ source('gold_che_finance', 'dim_cost_center') }}
