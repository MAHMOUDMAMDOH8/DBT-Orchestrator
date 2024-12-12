{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='customer_sk',
        indexes=
        [
            {"columns":['customer_sk'],'unique':true}
        ]
    )
}}

with customer_data as (
    select
        customer_sk,
        customer_id,
        name,
        gender,
        age,
        zip_code,
        country,
        city,
        account_id,
        data_source
    from {{ref("stg_customers")}}
)

select * from customer_data