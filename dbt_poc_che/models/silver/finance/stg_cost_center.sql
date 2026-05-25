-- Silver: Cleaned and typed cost center master data (T-SQL)
select
    cast(cost_center_id as int) as cost_center_id,
    ltrim(rtrim(cost_center_name)) as cost_center_name,
    ltrim(rtrim(department)) as department,
    ltrim(rtrim(manager_name)) as manager_name,
    cast(is_active as bit) as is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('bronze_finance', 'cost_center') }}
where cost_center_id is not null
