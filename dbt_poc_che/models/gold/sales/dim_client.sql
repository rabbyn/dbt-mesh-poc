{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Client dimension - Switzerland
select
    cast(client_id as int) as client_id,
    client_name,
    client_type,
    country_code,
    'CHE' as source_country,
    created_at,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('stg_client') }}
where country_code is not null
