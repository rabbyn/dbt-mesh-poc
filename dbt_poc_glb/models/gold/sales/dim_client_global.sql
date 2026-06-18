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
from {{ source('ita_gold_sales', 'dim_client') }}

union all

select
    client_id,
    client_name,
    client_type,
    country_code,
    source_country,
    created_at,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('che_gold_sales', 'dim_client') }}
