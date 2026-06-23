{{ config(materialized='table') }}

-- Global Gold: Union of Italy and Switzerland client dimensions
select
    client_id,
    client_name,
    client_type,
    country_code,
    source_country,
    created_at,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
-- Source: dbt_poc_ita project (ITA Fabric workspace, gold.dim_client)
from {{ source('mesh_sales', 'dim_client_ita') }}

union all

select
    client_id,
    client_name,
    client_type,
    country_code,
    source_country,
    created_at,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
-- Source: dbt_poc_che project (CHE Fabric workspace, gold.dim_client)
from {{ source('mesh_sales', 'dim_client') }}
