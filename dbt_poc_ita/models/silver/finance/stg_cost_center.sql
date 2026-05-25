-- Silver: Cleaned and typed cost center master data
select
    cast(cost_center_id as int) as cost_center_id,
    trim(cost_center_name) as cost_center_name,
    trim(department) as department,
    trim(manager_name) as manager_name,
    cast(is_active as boolean) as is_active,
    current_timestamp() as _loaded_at
from {{ source('bronze_finance', 'cost_center') }}
where cost_center_id is not null
