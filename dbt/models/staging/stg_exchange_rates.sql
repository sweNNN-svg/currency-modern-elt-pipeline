{{ config(
    materialized='incremental',
    unique_key='target_currency'
) }}

with raw_data as (
  select 
    jsonb_each_text(_airbyte_data->'conversion_rates') as rate_data,
    (_airbyte_data->>'time_last_update_utc') as last_updated_raw
  from {{ source('public', 'exchange_rates_raw') }}
)

select
  'TRY'::varchar(3) as base_currency,
  rate_data.key::varchar(3) as target_currency,
  rate_data.value::numeric(18,6) as exchange_rate,
  to_timestamp(last_updated_raw, 'Dy, DD Mon YYYY HH24:MI:SS UTC') as updated_at
from raw_data
{% if is_incremental() %}
where to_timestamp(last_updated_raw, 'Dy, DD Mon YYYY HH24:MI:SS UTC') > (select max(updated_at) from {{ this }})
{% endif %}
