-- Silver: Cleaned and typed client master data
select
    cast(client_id as int) as client_id,
    trim(client_name) as client_name,
    upper(trim(client_type)) as client_type,
    upper(trim(country_code)) as country_code,
    cast(created_at as timestamp) as created_at,
    current_timestamp() as _loaded_at
from {{ source('bronze_sales', 'client') }}
where client_id is not null
