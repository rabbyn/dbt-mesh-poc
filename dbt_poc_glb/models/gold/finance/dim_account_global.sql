{{ config(materialized='table') }}

-- Global Gold: Union of Italy and Switzerland account dimensions
-- Fabric Mesh: source() routes through GLB-workspace Shortcuts to ITA/CHE gold schemas.
-- Cross-project ref() is not used because Fabric blocks cross-workspace SQL;
-- project dependencies are still declared in dependencies.yml for Mesh governance.
select
    account_id,
    account_name,
    account_type,
    account_category,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('ita_gold_finance', 'dim_account') }}

union all

select
    account_id,
    account_name,
    account_type,
    account_category,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('che_gold_finance', 'dim_account') }}
