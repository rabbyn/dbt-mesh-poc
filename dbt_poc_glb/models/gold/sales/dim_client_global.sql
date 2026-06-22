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
from {{ source('gold_ita_sales', 'dim_client') }}

union all

select
    client_id,
    client_name,
    client_type,
    country_code,
    source_country,
    created_at,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('gold_che_sales', 'dim_client') }}
