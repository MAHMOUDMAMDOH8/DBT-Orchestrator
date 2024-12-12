{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='order_detail_id',
        indexes = 
        [
            {"columns": ['order_detail_id'], 'unique': False},
            {"columns": ['product_id'], 'unique': False}
        ]
    )
}}


with order_detais_data as (
    select
        order_detail_id,
        quantity,
        order_id,
        product_id,
        line_total
    from {{ source('ecommerce_oltp', 'order_details') }}
    where order_detail_id is not null
    and quantity is not null
    and order_id is not null
    and product_id is not null
    and line_total is not null
)
select * from order_detais_data