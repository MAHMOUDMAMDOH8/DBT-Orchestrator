{{
    config(
        materialized='incremental',
        unique_key='date_sk',
        on_schema_change='append_new_columns'
    )
}}

with range_date as (
    select
        coalesce(
            min(CASE 
                    WHEN order_date ~ '^\d{4}-\d{2}-\d{2}$' THEN order_date::date 
                    ELSE NULL 
                END), 
            '2000-01-01'::date
        ) as min_date,
        coalesce(
            max(CASE 
                    WHEN order_date ~ '^\d{4}-\d{2}-\d{2}$' THEN order_date::date 
                    ELSE NULL 
                END), 
            current_date
        ) as max_date
    from {{ source('ecommerce_oltp', 'orders') }}
),
date_series as (
    select 
        generate_series(
            (select min_date from range_date),
            (select max_date from range_date),
            '1 day'::interval
        )::date as full_date
)
SELECT
    md5(full_date::text) as date_sk, 
    full_date,
    extract(year from full_date) as year,
    extract(month from full_date) as month,
    extract(day from full_date) as day,
    to_char(full_date, 'Day') as day_name,
    to_char(full_date, 'Month') as month_name
from date_series

{% if is_incremental() %}
    WHERE full_date > (
        SELECT MAX(full_date) 
        FROM {{ this }} 
        WHERE full_date IS NOT NULL
    )
{% endif %}
