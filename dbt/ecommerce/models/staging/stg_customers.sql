{{ 
    config(
        materialized='incremental',
        strategy='append',
        unique_key='customer_sk',
        indexes=[{"columns": ['customer_sk'], "unique": true}],
        target_schema='staging'
    )
}}

with valid_customers as (
    select
        distinct customer_id,
        concat(fname, ' ', lname) as Name,
        gender,
        age,
        zip_code,
        country,
        city,
        account_id,
        'pgdb' as data_source
    from {{ source('ecommerce_oltp', 'Customers') }}
    where 
        customer_id is not null
    and account_id is not null
)

select 
    md5(customer_id || data_source) as customer_sk,
    *
from valid_customers
