# DBT-Orchestrator

## Table of Contents
- [Introduction](#introduction)
- [Approach](#approach)
- [Tech Stack & Tools](#tech-stack--tools)
- [Assumptions](#assumptions)
- [Pipeline Architecture](#pipeline-architecture)
- [DBT Directory Structure](#dbt-directory-structure)
- [Airflow DAG Overview](#airflow-dag-overview)
- [Database Schema](#database-schema)
- [Surrogate Keys Logic](#surrogate-keys-logic)
- [ERD (Entity-Relationship Diagram)](#erd-entity-relationship-diagram)
- [Data Warehouse Model](#data-warehouse-model)
- [Data Lineage](#data-lineage)
- [Reporting](#reporting)

---

## Introduction

**DBT-Orchestrator** is a project designed to transform raw data into analytics-ready datasets using **DBT** (Data Build Tool). It integrates modular data models with a PostgreSQL data warehouse and provides a reporting layer for business intelligence and decision-making.

---

## Approach
```mermaid
flowchart LR;
A[Source 1]
B[Source 2]
C[Staing table orders]
D[Join operation]
F[Orders fact]
G[Staging table products]

A -- "store 'source 1' in data_src" --> C
B -- "store 'source 2' in data_src" --> C

A -- "store 'source 1' in data_src" --> G
B -- "store 'source 2' in data_src" --> G

G -- "create surrogate key" --> Gs[MD5]


C -- "product_id AND data_src" --> D
Gs -- "product_id AND data_src" --> D


D --"Replace source foreign keys with new pproducts surrogate keys"--> F;

```

## Tech Stack & Tools

- **DBT (Data Build Tool)**: For building and transforming data models.
- **PostgreSQL**: As the data warehouse.
- **Docker**: To containerize and standardize the development environment.
- **Python**: For scripting and automation.
- **Airflow** (optional): For orchestrating ETL workflows.
- **Power BI** (optional): For visualizing the reporting layer.

---

## Assumptions

1. PostgreSQL is the database platform used for data storage and transformations.
2. Docker is installed and used for containerized environments.
3. Required datasets are accessible in a suitable format (e.g., CSV or Parquet).

---

## Pipeline Architecture

The project follows a layered architecture:

1. **Raw Data Layer**: Holds unprocessed data.
2. **Staging Layer**: Cleans and pre-processes data.
3. **OLAP Models**: 
   - **Dimension Models**: Prepares dimension tables for analysis.
   - **Fact Models**: Aggregates and calculates business metrics.

### DBT Directory Structure
```plaintext
dbt/
├── ecommerce/
│   ├── models/
│   │   ├── staging/          # Staging models
│   │   ├── olap_model/       # OLAP models directory
│   │   │   ├── dimensions/   # Dimension models
│   │   │   ├── fact/         # Fact models
│   ├── dbt_project.yml       # DBT project configuration
│   └── profiles.yml          # DBT profiles configuration
```
## Airflow DAG Overview
If using Airflow for orchestration, the DAG performs the following tasks:

Extract: Reads raw data from source olap database or APIs.
Load: Loads data into the PostgreSQL database.
Transform: Executes DBT models to build staging, dimension, and fact tables.
## Database Schema
Staging Tables:

stg_orders: Pre-processed orders data.
stg_customers: Pre-processed customer data.
Dimension Tables (in olap_model/dimensions):

dim_customers: Cleaned and deduplicated customer records.
dim_products: Product metadata.
Fact Tables (in olap_model/fact):

fact_sales: Aggregated sales metrics.


## Surrogate Keys Logic

| Surrogate Key   | Logic                                        |
|-----------------|----------------------------------------------|
| `product_sk`     | MD5 Hash of cleaned `product_name`          |
| `supplier_sk`   | MD5 Hash of cleaned `supplier_name`          |
| `customer_sk`   | MD5 Hash of cleaned `customer_name`          |
| `data_sk`       | MD5 Hash of cleaned `date` (from `dim_date`) |
| `brand_sk`       | MD5 Hash of cleaned `brand|| datasource`   |
| `store_sk`       | MD5 Hash of cleaned store_name|| datasource`   |

## ERD (Entity-Relationship Diagram)
### Logical Model

```mermaid 
erDiagram
    CATEGORYS {
        INT Category_ID PK
        VARCHAR Category_name
    }
    SUBCATEGORYS {
        INT Subcategory_ID PK
        INT Category_ID FK
        VARCHAR Subcategory_name
    }
    BRAND {
        INT Brand_ID PK
        VARCHAR brand_name
        VARCHAR brand_country
        DATE start_date
    }
    SUPPLIERS {
        INT Supplier_ID PK
        VARCHAR supplier_name
        VARCHAR location
    }
    SUPPLIER_PRODUCT {
        INT Supplier_ID FK
        INT Product_ID FK
    }
    STORE {
        INT Store_ID PK
        VARCHAR Store_name
        VARCHAR region
    }
    PRODUCTS {
        INT Product_ID PK
        VARCHAR Product_name
        INT price
        INT cost
        INT subcategory_ID FK
    }
    PRODUCT_STORE {
        INT Store_ID FK
        INT Product_ID FK
    }
    PRODUCT_BRAND {
        INT Product_ID FK
        INT Brand_ID FK
    }
    CUSTOMERS {
        INT customer_id PK
        VARCHAR fname
        VARCHAR lname
        VARCHAR gender
        INT zip_code
        INT age
        VARCHAR country
        VARCHAR city
        VARCHAR password
        VARCHAR email
        VARCHAR account_id
    }
    CUSTOMERS_PHONE {
        INT Customer_ID FK
        INT Phone
    }
    RATINGS {
        INT rating_id PK
        INT overall_rate
        INT delivery_rate
        INT customer_service_rate
        INT product_quality_rate
        VARCHAR loyality
        INT customer_id FK
    }
    ORDERS {
        INT order_id PK
        INT sub_total
        INT total_tax
        INT total_freight
        INT total_due
        VARCHAR shipping_method
        VARCHAR shipping_city
        VARCHAR payment_method
        DATE order_date
        INT customer_id FK
    }
    ORDER_DETAILS {
        INT order_detail_id PK
        VARCHAR quantity
        INT order_id FK
        INT product_id FK
        INT line_total
    }
    CATEGORYS ||--o| SUBCATEGORYS : has
    SUBCATEGORYS ||--o| PRODUCTS : contains
    BRAND ||--o| PRODUCT_BRAND : links
    PRODUCTS ||--o| PRODUCT_BRAND : linked_to
    SUPPLIERS ||--o| SUPPLIER_PRODUCT : provides
    PRODUCTS ||--o| SUPPLIER_PRODUCT : supplied_by
    STORE ||--o| PRODUCT_STORE : contains
    PRODUCTS ||--o| PRODUCT_STORE : sold_at
    CUSTOMERS ||--o| RATINGS : rated_by
    CUSTOMERS ||--o| ORDERS : places
    ORDERS ||--o| ORDER_DETAILS : contains
    PRODUCTS ||--o| ORDER_DETAILS : included_in
    CUSTOMERS ||--o| CUSTOMERS_PHONE : has
```
## Data Warehouse Model
```mermaid
erDiagram
    brand_dim {
        string brand_sk
        int brand_id
        string brand_name
        string brand_country
        date start_date
        string data_source
    }
    customer_dim {
        string customer_sk
        int customer_id
        string name
        string gender
        int age
        int zip_code
        string country
        string city
        string account_id
        string data_source
    }
    data_dim {
        string date_sk
        date full_date
        double year
        double month
        double day
        string day_name
        string month_name
    }
    fact_sales {
        bigint transaction_id
        int order_id
        string date_sk
        string customer_sk
        string shipping_method
        string shipping_city
        string payment_method
        int sub_total
        int total_tax
        int total_freight
        int total_due
        int order_detail_id
        string product_sk
        string supplier_sk
        string brand_sk
        string store_sk
        string quantity
        int line_total
    }
    product_dim {
        string product_sk
        int product_id
        string product_name
        string Subcategory_name
        string Category_name
        numeric price
        numeric cost
        string data_source
    }
    store_dim {
        string store_sk
        int store_id
        string store_name
        string region
        string data_source
    }
    supplier_dim {
        string supplier_sk
        int Supplier_ID
        string supplier_name
        string location
        string data_source
    }
    brand_dim ||--o| fact_sales : has
    customer_dim ||--o| fact_sales : makes
    data_dim ||--o| fact_sales : records
    product_dim ||--o| fact_sales : contains
    store_dim ||--o| fact_sales : located_in
    supplier_dim ||--o| fact_sales : supplies
```
## Data Lineage
![Screenshot from 2024-12-14 16-13-20](https://github.com/user-attachments/assets/a035c0df-681a-4a1e-81c2-5dc2b4049363)

![Screenshot from 2024-12-14 16-15-43](https://github.com/user-attachments/assets/f753b7da-ec45-4982-bfeb-703507006f21)




## Reporting
### overview
![overview](https://github.com/user-attachments/assets/ae9de47a-25ae-4716-a479-a96f8db6a3e9)

### order details 

![order details](https://github.com/user-attachments/assets/02cdb1a9-7f69-47a5-afff-9aadf397433c)










