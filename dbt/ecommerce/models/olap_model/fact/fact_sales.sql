{{
    config(
        materialized='incremental',
        strategy='merge',
        unique_key='transaction_id',
        indexes = 
        [
            {"columns": ['transaction_id'], 'unique': True},
            {"columns": ['store_sk'], 'unique': False},
            {"columns": ['product_sk'], 'unique': False},
            {"columns": ['customer_sk'], 'unique': False},
            {"columns": ['date_sk'], 'unique': False},
            {"columns": ['brand_sk'], 'unique': False}
        ]
    ) 
}}

with order_details as (
    select 
        od.order_detail_id,
        od.order_id,
        p.product_sk,
        st.supplier_sk,
        pd.brand_sk,
        s.store_sk,
        od.quantity,
        od.line_total
    from {{ref("stg_order_details")}} od
    left join {{ref("product_dim")}} p
        on od.product_id = p.product_id
    left join {{source('ecommerce_oltp', 'product_brand')}} pb
        on p.product_id = pb."product_ID"
    left join {{ref('brand_dim')}} pd
        on pb."Brand_ID" = pd.brand_id
    left join {{source('ecommerce_oltp', 'product_store')}} ps
        on p.product_id = ps."Product_ID"
    left join {{ref("store_dim")}} s
        on ps."Store_ID" = s.store_id
    left join {{source('ecommerce_oltp', 'Supplier_product')}} sp
        on p.product_id = sp."Product_ID"
    left join {{ref("supplier_dim")}} st
        on sp."Supplier_ID" = st."Supplier_ID"
),
orders as (
    select
        o.order_id,
        d.date_sk,
        c.customer_sk,
        o.shipping_method,
        o.shipping_city,
        o.payment_method,
        o.sub_total,
        o.total_tax,
        o.total_freight,
        o.total_due
    from {{ref("stg_order")}} o
    left join {{ref('customer_dim')}} c
        on o.customer_id = c.customer_id
    left join {{ref("date_dim")}} d
        on o.order_date = d.full_date
)

select 
    row_number() over (order by o.order_id) as transaction_id,  
    o.order_id,
    o.date_sk,
    o.customer_sk,
    o.shipping_method,
    o.shipping_city,
    o.payment_method,
    o.sub_total,
    o.total_tax,
    o.total_freight,
    o.total_due,
    od.order_detail_id,
    od.product_sk,
    od.supplier_sk,
    od.brand_sk,
    od.store_sk,
    od.quantity,
    od.line_total
from order_details od
inner join orders o
    on od.order_id = o.order_id