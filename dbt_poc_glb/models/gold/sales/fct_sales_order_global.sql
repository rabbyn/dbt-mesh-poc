{{ config(materialized='table') }}

-- Global Gold: Union of Italy and Switzerland sales order facts
select
    order_id,
    client_id,
    branch_id,
    order_date,
    amount,
    currency_code,
    order_status,
    source_country,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('ita_gold_sales', 'fct_sales_order') }}

union all

select
    order_id,
    client_id,
    branch_id,
    order_date,
    amount,
    currency_code,
    order_status,
    source_country,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('che_gold_sales', 'fct_sales_order') }}
