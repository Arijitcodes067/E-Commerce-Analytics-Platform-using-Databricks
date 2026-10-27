-- ============================================================
-- Bronze Layer: Raw ingestion tables (ecommerce.bronze)
-- These tables are created by the Bronze notebooks via saveAsTable.
-- DDL shown here for documentation and reproducibility.
-- ============================================================

-- Brands (ingested from CSV via 1_dim_bronze notebook)
CREATE TABLE IF NOT EXISTS ecommerce.bronze.btr_brands (
    brand_code     STRING,
    brand_name     STRING,
    category_code  STRING,
    _source_file   STRING,
    ingested_at    TIMESTAMP
) USING DELTA;

-- Order Items (ingested from CSV landing zone via 1_fact_bronze notebook)
CREATE TABLE IF NOT EXISTS ecommerce.bronze.brz_order_items (
    dt                  STRING,
    order_ts            STRING,
    customer_id         STRING,
    order_id            STRING,
    item_seq            STRING,
    product_id          STRING,
    quantity            STRING,
    unit_price_currency STRING,
    unit_price           STRING,
    discount_pct        STRING,
    tax_amount          STRING,
    channel             STRING,
    coupon_code         STRING,
    _source_file        STRING,
    _ingested_at        TIMESTAMP,
    file_name           STRING,
    ingest_timestamp   TIMESTAMP
) USING DELTA;

-- Products (ingested from CSV via dim_product script)
CREATE TABLE IF NOT EXISTS ecommerce.bronze.brz_products (
    product_id        STRING,
    sku               STRING,
    category_code     STRING,
    brand_code        STRING,
    color             STRING,
    size              STRING,
    material          STRING,
    weight_grams      STRING,
    length_cm         STRING,
    width_cm          FLOAT,
    height_cm         FLOAT,
    rating_count      INT,
    file_name         STRING,
    ingest_timestamp  TIMESTAMP
) USING DELTA;

-- Customers (ingested from CSV via dim_customer script)
CREATE TABLE IF NOT EXISTS ecommerce.bronze.brz_customers (
    customer_id       STRING,
    phone             STRING,
    state             STRING,
    ingest_timestamp  TIMESTAMP
) USING DELTA;

-- Category (ingested from CSV via dim_category script)
CREATE TABLE IF NOT EXISTS ecommerce.bronze.brz_category (
    category_code  STRING,
    category_name  STRING,
    _ingested_at   TIMESTAMP,
    _source_file   STRING
) USING DELTA;

-- Calendar (ingested from CSV via dim_date script)
CREATE TABLE IF NOT EXISTS ecommerce.bronze.brz_calendar (
    date           STRING,
    year           INT,
    day_name       STRING,
    quarter        INT,
    week_of_year   INT,
    _ingested_at   TIMESTAMP,
    _source_file   STRING
) USING DELTA;
