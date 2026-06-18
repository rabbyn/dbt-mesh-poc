-- Silver: Cleaned and typed chart of accounts (T-SQL)
select
    cast(account_id as int) as account_id,
    ltrim(rtrim(account_name)) as account_name,
    upper(ltrim(rtrim(account_type))) as account_type,
    upper(ltrim(rtrim(account_category))) as account_category,
    cast(is_active as bit) as is_active,
    CAST(SYSUTCDATETIME() AS datetime2(6)) as _loaded_at
from {{ source('bronze_finance', 'account') }}
where account_id is not null
