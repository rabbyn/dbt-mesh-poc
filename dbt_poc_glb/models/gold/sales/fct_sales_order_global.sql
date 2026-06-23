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
-- Source: dbt_poc_ita project (ITA Fabric workspace, gold.fct_sales_order)
from {{ source('mesh_sales', 'fct_sales_order_ita') }}

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
-- Source: dbt_poc_che project (CHE Fabric workspace, gold.fct_sales_order)
from {{ source('mesh_sales', 'fct_sales_order') }}
