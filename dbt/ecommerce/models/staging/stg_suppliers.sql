{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='Supplier_sk',
        indexes=[{"columns":['Supplier_sk'],"unique":true}],
        target_scheam='staging_tables'
    )
}}

with valid_suppliers as (
    select 
        "Supplier_ID",
        "supplier_name",
        "location",
        'pgdb' as data_source
    from{{ source('ecommerce_oltp', 'Suppliers') }}
    where supplier_name is not null
    and location is not null
)

select 
    md5("Supplier_ID" || data_source) as Supplier_sk,
    *
from valid_suppliers