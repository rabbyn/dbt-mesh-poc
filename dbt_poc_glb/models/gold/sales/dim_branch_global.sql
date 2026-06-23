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
-- Source: dbt_poc_ita project (ITA Fabric workspace, gold.dim_branch)
from {{ source('mesh_sales_ita', 'dim_branch_ita') }}

union all

select
    branch_id,
    branch_name,
    branch_city,
    branch_region,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
-- Source: dbt_poc_che project (CHE Fabric workspace, gold.dim_branch)
from {{ source('mesh_sales_che', 'dim_branch') }}
