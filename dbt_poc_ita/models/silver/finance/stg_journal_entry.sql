-- Silver: Cleaned and typed journal entry transactions
select
    cast(entry_id as int) as entry_id,
    cast(account_id as int) as account_id,
    cast(cost_center_id as int) as cost_center_id,
    cast(entry_date as date) as entry_date,
    cast(debit_amount as decimal(18, 2)) as debit_amount,
    cast(credit_amount as decimal(18, 2)) as credit_amount,
    upper(trim(currency_code)) as currency_code,
    trim(description) as description,
    current_timestamp() as _loaded_at
from {{ source('bronze_finance', 'journal_entry') }}
where entry_id is not null
