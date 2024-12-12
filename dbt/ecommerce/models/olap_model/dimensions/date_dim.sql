{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='date_sk',
        indexes=
        [
            {"columns":['date_sk'],'unique':true}
        ]
    )
}}

with data_dim  as(
    select
        date_sk,
        full_date,
        year,
        month,
        day,
        day_name,
        month_name
    from {{ref("stg_date")}}
)

select * from data_dim 