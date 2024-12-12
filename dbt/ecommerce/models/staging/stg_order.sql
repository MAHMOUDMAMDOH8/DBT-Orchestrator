{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='order_id',
        indexes = 
        [
            {"columns": ['order_id'], 'unique': False},
            {"columns": ['customer_id'], 'unique': False}
        ]
    )
}}

with order_data as (
    select 
        order_id,
        customer_id,
        order_date::date,
        shipping_method,
        shipping_city,
        payment_method,
        sub_total,
        total_tax,
        total_freight,
        total_due
    from {{source('ecommerce_oltp','orders')}}
    where order_id is not null 
    and customer_id is not null 
    and order_date is not null 
    and sub_total is not null 
    and total_tax is not null 
    and total_due is not null 
    and total_freight is not null 
    and payment_method is not null 
    and shipping_city is not null 
    and shipping_method is not null 
)

select * from order_data