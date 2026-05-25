{{
  config(
    materialized='table',
    contract={'enforced': true},
    access='public'
  )
}}

-- Gold: Sales order fact table with enriched references
select
    o.order_id,
    o.client_id,
    o.branch_id,
    o.order_date,
    o.amount,
    o.currency_code,
    o.order_status,
    'ITA' as source_country,
    current_timestamp() as _loaded_at
from {{ ref('stg_sales_order') }} o
where o.order_status is not null
