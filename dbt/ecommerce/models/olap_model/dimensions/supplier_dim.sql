{{
    config(
        materialized='incremental',
        strategy='append',
        unique_key='supplier_sk',
        indexes=
        [
            {"columns":['supplier_sk'],'unique':true}
        ]
    )
}}

with supplier_dim as(
    select  
        supplier_sk,
        "Supplier_ID",
        "supplier_name",
        "location",
        data_source
    from {{ref("stg_suppliers")}}
    where "Supplier_ID" is not null
)

select * from supplier_dim