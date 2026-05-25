-- Silver: Cleaned and typed client master data (T-SQL)
select
    cast(client_id as int) as client_id,
    ltrim(rtrim(client_name)) as client_name,
    upper(ltrim(rtrim(client_type))) as client_type,
    upper(ltrim(rtrim(country_code))) as country_code,
    cast(created_at as datetime2(6)) as created_at,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('bronze_sales', 'client') }}
where client_id is not null
