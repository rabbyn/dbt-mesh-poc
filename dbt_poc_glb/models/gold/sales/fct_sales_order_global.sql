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
from {{ ref('dbt_poc_ita', 'fct_sales_order') }}

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
from {{ ref('dbt_poc_che', 'fct_sales_order') }}
