-- Silver: Cleaned and typed branch master data (T-SQL)
select
    cast(branch_id as int) as branch_id,
    ltrim(rtrim(branch_name)) as branch_name,
    ltrim(rtrim(branch_city)) as branch_city,
    ltrim(rtrim(branch_region)) as branch_region,
    cast(is_active as bit) as is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('bronze_sales', 'branch') }}
where branch_id is not null
