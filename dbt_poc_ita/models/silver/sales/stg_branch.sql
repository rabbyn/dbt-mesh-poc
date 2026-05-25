-- Silver: Cleaned and typed branch master data
select
    cast(branch_id as int) as branch_id,
    trim(branch_name) as branch_name,
    trim(branch_city) as branch_city,
    trim(branch_region) as branch_region,
    cast(is_active as boolean) as is_active,
    current_timestamp() as _loaded_at
from {{ source('bronze_sales', 'branch') }}
where branch_id is not null
