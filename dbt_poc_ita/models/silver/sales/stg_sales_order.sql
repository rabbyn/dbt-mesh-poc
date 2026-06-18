-- Silver: Cleaned and typed sales order transactions (T-SQL)
select
    cast(order_id as int) as order_id,
    cast(client_id as int) as client_id,
    cast(branch_id as int) as branch_id,
    cast(order_date as date) as order_date,
    cast(amount as decimal(18, 2)) as amount,
    upper(ltrim(rtrim(currency_code))) as currency_code,
    upper(ltrim(rtrim(order_status))) as order_status,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('bronze_sales', 'sales_order') }}
where order_id is not null
