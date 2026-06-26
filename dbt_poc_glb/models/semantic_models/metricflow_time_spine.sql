{{
    config(
        materialized = 'table',
        tags = ['metricflow', 'utility']
    )
}}

-- ─────────────────────────────────────────────────────────────────────────────
-- MetricFlow time spine (DAY granularity)
-- Required by the dbt Semantic Layer for cumulative metrics (sales_mtd,
-- sales_ytd) and offset metrics (sales_prior_month).
--
-- Fabric Warehouse T-SQL compatible:
--   * No dbt_utils dependency (date_spine not available in this project)
--   * No recursive CTE (unsupported in Fabric Warehouse)
--   * Dates generated via cross-joined digit tables, then DATEADD from an anchor
--
-- Coverage: 2020-01-01 .. 2029-12-31 (3653 days)
-- ─────────────────────────────────────────────────────────────────────────────

with digits as (
    select 0 as d union all select 1 union all select 2 union all select 3
    union all select 4 union all select 5 union all select 6 union all select 7
    union all select 8 union all select 9
),

numbers as (
    select (d3.d * 1000 + d2.d * 100 + d1.d * 10 + d0.d) as n
    from digits as d0
    cross join digits as d1
    cross join digits as d2
    cross join digits as d3
)

select
    cast(dateadd(day, n, cast('2020-01-01' as date)) as date) as date_day
from numbers
where n < 3653
