{{ config(materialized='table') }}

-- Global Gold: Union of Italy and Switzerland account dimensions
-- Sources reference upstream gold tables exposed via Fabric shortcuts
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
