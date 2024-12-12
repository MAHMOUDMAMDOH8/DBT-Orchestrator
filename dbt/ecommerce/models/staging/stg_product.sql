{{
    config(
        materialized='incremental',
        unique_key='product_id',
        indexes=[{"columns": ['product_id'], "unique": true}],
        target_schema='staging'
    )
}}

with products as (
    select
        *,
        'pgdb' as data_source
    from {{ ref("CDC_product") }}
),

subcategories as (
    select
        "Subcategory_ID",
        "Subcategory_name",
        "Category_ID"
    from {{ source('ecommerce_oltp', 'Subcategorys') }}
),

categories as (
    select
        "Category_ID",
        "Category_name"
    from {{ source('ecommerce_oltp', 'Categorys') }}
),

product_with_subcategory as (
    select
        p.product_id,
        p.product_name,
        p."subcategory_ID",
        sc."Subcategory_name",
        sc."Category_ID",
        p.price,
        p.cost,
        p.data_source
    from products p
    left join subcategories sc
        on p."subcategory_ID" = sc."Subcategory_ID"
),

final as (
    select
        md5(cast(product_id as text) || data_source) as product_sk,
        pwsc.product_id,
        pwsc.product_name,
        pwsc."Subcategory_name",
        c."Category_name",
        pwsc.price,
        pwsc.cost,
        pwsc.data_source
    from product_with_subcategory pwsc
    left join categories c
        on pwsc."Category_ID" = c."Category_ID"
)

{% if is_incremental() %}
-- Incremental logic: Insert only new or updated rows
select * from final
where product_id not in (select distinct product_id from {{ this }})
{% else %}
-- Full refresh logic: Load all rows
select * from final
{% endif %}
