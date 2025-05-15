-- Test 1: Null kontrolü
SELECT *
FROM {{ ref('stg_exchange_rates') }}
WHERE exchange_rate IS NULL;

-- Test 2: Makul aralık kontrolü
SELECT *
FROM {{ ref('stg_exchange_rates') }}
WHERE exchange_rate < 0.000001 OR exchange_rate > 1000000;

-- Test 3: Tekillik kontrolü
SELECT target_currency, COUNT(*)
FROM {{ ref('stg_exchange_rates') }}
GROUP BY target_currency
HAVING COUNT(*) > 1;
