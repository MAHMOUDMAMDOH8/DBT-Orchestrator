{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='store_sk',
        indexes=
        [
            {"columns":['store_sk'],'unique':true}
        ]
    )
}}

with store_dim as (
    select
        store_sk,
        store_id,
        store_name,
        region,
        data_source
    from {{ref('stg_store')}}
)

select * from store_dim
