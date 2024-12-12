{% snapshot CDC_product %}

{{
    config(
        target_schema='snapshots',
        unique_key='product_id',
        strategy='check',
        check_cols=['price', 'cost']
    )
}}

select 
    "Product_ID"::int as product_id,       
    "Product_name"::varchar(250) as product_name,
    "price"::numeric as price,
    "cost"::numeric as cost,
    "subcategory_ID",
    current_timestamp as snapshot_timestamp 
from {{ source('ecommerce_oltp', 'products') }}

{% endsnapshot %}
