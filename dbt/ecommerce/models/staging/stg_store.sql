{{ 
    config(
        materialized='incremental',
        unique_key='store_sk',
        indexes=[{"columns":['store_sk'],"unique":true}],
        target_schema='staging'
    ) 
}}

with valid_stores as (
    select
        "Store_ID"::int as store_id,
        "Store_name"::varchar(50) as store_name,
        "region"::varchar(50) as region,
        'pgdb' as data_source
    from {{ source('ecommerce_oltp', 'Store') }}
    where
        "Store_ID" is not null
        and "Store_name" is not null
)

select
    md5(Store_ID || data_source) as store_sk, 
    *
from valid_stores
