-- Silver: Cleaned and typed sales order transactions
select
    cast(order_id as int) as order_id,
    cast(client_id as int) as client_id,
    cast(branch_id as int) as branch_id,
    cast(order_date as date) as order_date,
    cast(amount as decimal(18, 2)) as amount,
    upper(trim(currency_code)) as currency_code,
    upper(trim(order_status)) as order_status,
    current_timestamp() as _loaded_at
from {{ source('bronze_sales', 'sales_order') }}
where order_id is not null
