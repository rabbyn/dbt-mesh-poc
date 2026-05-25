{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Sales order fact table - Switzerland
select
    cast(order_id as int) as order_id,
    cast(client_id as int) as client_id,
    cast(branch_id as int) as branch_id,
    order_date,
    amount,
    currency_code,
    order_status,
    'CHE' as source_country,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ ref('stg_sales_order') }}
where order_status is not null
