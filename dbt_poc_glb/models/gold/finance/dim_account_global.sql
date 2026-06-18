{{ config(materialized='table') }}

-- Global Gold: Union of Italy and Switzerland account dimensions
-- Native dbt Mesh: cross-project ref() to public upstream gold models
select
    account_id,
    account_name,
    account_type,
    account_category,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('dbt_poc_ita', 'dim_account') }}

union all

select
    account_id,
    account_name,
    account_type,
    account_category,
    source_country,
    is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('dbt_poc_che', 'dim_account') }}
