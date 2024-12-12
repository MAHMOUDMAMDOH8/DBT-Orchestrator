{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='product_sk',
        indexes=
        [
            {"columns":['product_sk'],'unique':true}
        ]
    )
}}

with product_dim as (
    select 
        product_sk,
        product_id,
        product_name,
        "Subcategory_name",
        "Category_name",
        price,
        cost,
        data_source
    from {{ref("stg_product")}}
)

select * from product_dim