-- ============================================================
-- Silver Layer: Cleansed & transformed tables (ecommerce.silver)
-- These tables are created by the Silver notebooks via saveAsTable.
-- DDL shown here for documentation and reproducibility.
-- ============================================================

-- Brands: trimmed names, cleaned codes, fixed anomalous category codes
CREATE TABLE IF NOT EXISTS ecommerce.silver.slv_brands (
    brand_code     STRING,
    brand_name     STRING,
    category_code  STRING,
    _source_file   STRING,
    ingested_at    TIMESTAMP
) USING DELTA;

-- Category: deduplicated, uppercased codes
CREATE TABLE IF NOT EXISTS ecommerce.silver.slv_category (
    category_code  STRING,
    category_name  STRING,
    _ingested_at   TIMESTAMP,
    _source_file   STRING
) USING DELTA;

-- Products: cast numerics, uppercased codes, fixed spelling, abs rating_count
CREATE TABLE IF NOT EXISTS ecommerce.silver.slv_products (
    product_id        STRING,
    sku               STRING,
    category_code     STRING,
    brand_code        STRING,
    color             STRING,
    size              STRING,
    material          STRING,
    weight_grams      INT,
    length_cm         FLOAT,
    width_cm          FLOAT,
    height_cm         FLOAT,
    rating_count      INT,
    file_name         STRING,
    ingest_timestamp  TIMESTAMP
) USING DELTA;

-- Customers: dropped null IDs, filled null phones
CREATE TABLE IF NOT EXISTS ecommerce.silver.slv_customers (
    customer_id       STRING,
    phone             STRING,
    state             STRING,
    ingest_timestamp  TIMESTAMP
) USING DELTA;

-- Calendar: date parsed, day_name initcapped, quarter & week formatted
CREATE TABLE IF NOT EXISTS ecommerce.silver.slv_calendar (
    date           DATE,
    year           INT,
    day_name       STRING,
    quarter        STRING,
    _ingested_at   TIMESTAMP,
    _source_file   STRING
) USING DELTA;

-- Order Items: deduplicated, typed casts, channel normalized, dates parsed
CREATE TABLE IF NOT EXISTS ecommerce.silver.slv_order_items (
    dt                  DATE,
    order_ts            TIMESTAMP,
    customer_id         STRING,
    order_id            STRING,
    item_seq            STRING,
    product_id          STRING,
    quantity            INT,
    unit_price_currency STRING,
    unit_price          FLOAT,
    discount_pct        FLOAT,
    tax_amount          FLOAT,
    channel             STRING,
    coupon_code         STRING,
    _source_file        STRING,
    _ingested_at        TIMESTAMP,
    processed_time      TIMESTAMP
) USING DELTA;
