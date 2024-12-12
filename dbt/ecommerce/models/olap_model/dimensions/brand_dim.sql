{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='brand_sk',
        indexes=
        [
            {"columns":['brand_sk'],'unique':true}
        ]
    )
}}

with brand_dim as (
    select
        brand_sk,
        brand_id,
        brand_name,
        brand_country,
        start_date,
        data_source
    from {{ref("stg_brand")}}
)

select * from brand_dim