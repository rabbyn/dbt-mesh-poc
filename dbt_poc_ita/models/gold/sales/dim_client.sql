{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Client dimension enriched with country info
select
    client_id,
    client_name,
    client_type,
    country_code,
    'ITA' as source_country,
    created_at,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('stg_client') }}
where country_code is not null
