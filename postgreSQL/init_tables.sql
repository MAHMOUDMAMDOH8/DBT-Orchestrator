-- Active: 1719647882295@@172.18.0.3@5432@ecommerce@oltp
-- Drop existing tables if they exist
DROP TABLE IF EXISTS "Brand";
DROP TABLE IF EXISTS "Categorys";
DROP TABLE IF EXISTS "Customers_phone";
DROP TABLE IF EXISTS "Customers";
DROP TABLE IF EXISTS "order_details";
DROP TABLE IF EXISTS "orders";
DROP TABLE IF EXISTS "products";
DROP TABLE IF EXISTS "product_brand";
DROP TABLE IF EXISTS "ratings";
DROP TABLE IF EXISTS "Store";
DROP TABLE IF EXISTS "Subcategorys";
DROP TABLE IF EXISTS "Suppliers";
DROP TABLE IF EXISTS "Supplier_product";
DROP TABLE IF EXISTS "product_store";

-- Create tables
CREATE TABLE "Categorys" (
    "Category_ID" INT PRIMARY KEY,
    "Category_name" VARCHAR(512)
);

CREATE TABLE "Subcategorys" (
    "Subcategory_ID" INT PRIMARY KEY,
    "Category_ID" INT,
    "Subcategory_name" VARCHAR(512),
    FOREIGN KEY ("Category_ID") REFERENCES "Categorys" ("Category_ID")
);

CREATE TABLE "Brand" (
    "Brand_ID" INT PRIMARY KEY,
    "brand_name" VARCHAR(512),
    "brand_country" VARCHAR(512),
    "start_date" VARCHAR(512)
);

CREATE TABLE "Suppliers" (
    "Supplier_ID" INT PRIMARY KEY,
    "supplier_name" VARCHAR(512),
    "location" VARCHAR(512)
);

CREATE TABLE "Supplier_product" (
    "Supplier_ID" INT,
    "Product_ID" INT,
    FOREIGN KEY ("Supplier_ID") REFERENCES "Suppliers" ("Supplier_ID"),
    FOREIGN KEY ("Product_ID") REFERENCES "products" ("Product_ID")
);

CREATE TABLE "Store" (
    "Store_ID" INT PRIMARY KEY,
    "Store_name" VARCHAR(512),
    "region" VARCHAR(512)
);

CREATE TABLE "products" (
    "Product_ID" INT PRIMARY KEY,
    "Product_name" VARCHAR(512),
    "price" INT,
    "cost" INT,
    "subcategory_ID" INT,
    FOREIGN KEY ("subcategory_ID") REFERENCES "Subcategorys" ("Subcategory_ID")
);

CREATE TABLE "product_store" (
    "Store_ID" INT,
    "Product_ID" INT,
    FOREIGN KEY ("Store_ID") REFERENCES "Store" ("Store_ID"),
    FOREIGN KEY ("Product_ID") REFERENCES "products" ("Product_ID")
);

CREATE TABLE "product_brand" (
    "product_ID" INT,
    "Brand_ID" INT,
    FOREIGN KEY ("product_ID") REFERENCES "products" ("Product_ID"),
    FOREIGN KEY ("Brand_ID") REFERENCES "Brand" ("Brand_ID")
);

CREATE TABLE "Customers" (
    "customer_id" INT PRIMARY KEY,
    "fname" VARCHAR(512),
    "lname" VARCHAR(512),
    "gender" VARCHAR(512),
    "zip_code" INT,
    "age" INT,
    "country" VARCHAR(512),
    "city" VARCHAR(512),
    "password" VARCHAR(512),
    "email" VARCHAR(512),
    "account_id" VARCHAR(512)
);

CREATE TABLE "Customers_phone" (
    "Customer_ID" INT,
    "Phone" INT,
    FOREIGN KEY ("Customer_ID") REFERENCES "Customers" ("customer_id")
);

CREATE TABLE "ratings" (
    "rating_id" INT PRIMARY KEY,
    "overall_rate" INT,
    "delivery_rate" INT,
    "customer_service_rate" INT,
    "product_quality_rate" INT,
    "loyality" VARCHAR(512),
    "customer_id" INT,
    FOREIGN KEY ("customer_id") REFERENCES "Customers" ("customer_id")
);

CREATE TABLE "orders" (
    "order_id" INT PRIMARY KEY,
    "sub_total" INT,
    "total_tax" INT,
    "total_freight" INT,
    "total_due" INT,
    "shipping_method" VARCHAR(512),
    "shipping_city" VARCHAR(512),
    "payment_method" VARCHAR(512),
    "order_date" VARCHAR(512),
    "customer_id" INT,
    FOREIGN KEY ("customer_id") REFERENCES "Customers" ("customer_id")
);

CREATE TABLE "order_details" (
    "order_detail_id" INT PRIMARY KEY,
    "quantity" VARCHAR(512),
    "order_id" INT,
    "product_id" INT,
    "line_total" INT,
    FOREIGN KEY ("order_id") REFERENCES "orders" ("order_id"),
    FOREIGN KEY ("product_id") REFERENCES "products" ("Product_ID")
);
