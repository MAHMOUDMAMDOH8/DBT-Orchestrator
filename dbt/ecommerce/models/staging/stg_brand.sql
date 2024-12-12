{{
    config(
        materialized='incremental',
        unique_key='Brand_sk',
        indexes=[{"columns":['Brand_sk'],"unique":true}],
        target_schema='staging'
    )
}}

with valid_brands as (
    select
        "Brand_ID"::int as Brand_ID,
        "brand_name"::varchar(50) as brand_name,
        "brand_country"::varchar(50) as brand_country,
        "start_date"::date as start_date,
        'pgdb' as data_source
    from {{ source('ecommerce_oltp', 'Brand') }}
    where "Brand_ID" is not null
)

select
    md5(Brand_ID || data_source) as Brand_sk,
    *
from valid_brands
