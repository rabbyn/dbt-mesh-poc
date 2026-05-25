-- Silver: Cleaned and typed chart of accounts
select
    cast(account_id as int) as account_id,
    trim(account_name) as account_name,
    upper(trim(account_type)) as account_type,
    upper(trim(account_category)) as account_category,
    cast(is_active as boolean) as is_active,
    current_timestamp() as _loaded_at
from {{ source('bronze_finance', 'account') }}
where account_id is not null
