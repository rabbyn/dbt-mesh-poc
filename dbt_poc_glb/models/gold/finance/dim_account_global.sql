{{ config(materialized='table') }}

-- Global Gold: Union of Italy and Switzerland account dimensions
-- Fabric Mesh: cross-project ref() drives end-to-end lineage; the ref() override
-- macro remaps the compiled relation to the local OneLake Shortcut so the SQL runs
-- inside the GLB workspace. See macros/ref.sql.
select
    account_id,
    account_name,
    account_type,
    account_category,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
-- Source: dbt_poc_ita project (ITA Fabric workspace, gold.dim_account)
from {{ source('mesh_fin', 'dim_account_ita') }}

union all

select
    account_id,
    account_name,
    account_type,
    account_category,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
-- Source: dbt_poc_che project (CHE Fabric workspace, gold.dim_account)
from {{ source('mesh_fin', 'dim_account') }}
