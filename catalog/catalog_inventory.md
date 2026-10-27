# E-Commerce Unity Catalog Inventory

> **Catalog:** `ecommerce`
> **Generated:** 2026-10-28
> **Source:** `system.information_schema.tables` and `system.information_schema.columns`

## Overview

| Schema | Tables | Type |
|--------|--------|------|
| `bronze` | 6 | MANAGED (Delta) |
| `silver` | 6 | MANAGED (Delta) |
| `gold` | 4 + 1 view | MANAGED + VIEW |

---

## Bronze Layer (Raw Ingestion)

### ecommerce.bronze.btr_brands
Brands master data ingested from CSV.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | brand_code | STRING | YES |
| 2 | brand_name | STRING | YES |
| 3 | category_code | STRING | YES |
| 4 | _source_file | STRING | YES |
| 5 | ingested_at | TIMESTAMP | YES |

### ecommerce.bronze.brz_order_items
Order line items ingested from CSV landing zone.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | dt | STRING | YES |
| 2 | order_ts | STRING | YES |
| 3 | customer_id | STRING | YES |
| 4 | order_id | STRING | YES |
| 5 | item_seq | STRING | YES |
| 6 | product_id | STRING | YES |
| 7 | quantity | STRING | YES |
| 8 | unit_price_currency | STRING | YES |
| 9 | unit_price | STRING | YES |
| 10 | discount_pct | STRING | YES |
| 11 | tax_amount | STRING | YES |
| 12 | channel | STRING | YES |
| 13 | coupon_code | STRING | YES |
| 14 | _source_file | STRING | YES |
| 15 | _ingested_at | TIMESTAMP | YES |
| 16 | file_name | STRING | YES |
| 17 | ingest_timestamp | TIMESTAMP | YES |

### ecommerce.bronze.brz_products
Product catalog ingested from CSV.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | product_id | STRING | YES |
| 2 | sku | STRING | YES |
| 3 | category_code | STRING | YES |
| 4 | brand_code | STRING | YES |
| 5 | color | STRING | YES |
| 6 | size | STRING | YES |
| 7 | material | STRING | YES |
| 8 | weight_grams | STRING | YES |
| 9 | length_cm | STRING | YES |
| 10 | width_cm | FLOAT | YES |
| 11 | height_cm | FLOAT | YES |
| 12 | rating_count | INT | YES |
| 13 | file_name | STRING | YES |
| 14 | ingest_timestamp | TIMESTAMP | YES |

### ecommerce.bronze.brz_customers
Customer master ingested from CSV.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | customer_id | STRING | YES |
| 2 | phone | STRING | YES |
| 3 | state | STRING | YES |
| 4 | ingest_timestamp | TIMESTAMP | YES |

### ecommerce.bronze.brz_category
Category master ingested from CSV.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | category_code | STRING | YES |
| 2 | category_name | STRING | YES |
| 3 | _ingested_at | TIMESTAMP | YES |
| 4 | _source_file | STRING | YES |

### ecommerce.bronze.brz_calendar
Calendar dimensions ingested from CSV.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | date | STRING | YES |
| 2 | year | INT | YES |
| 3 | day_name | STRING | YES |
| 4 | quarter | INT | YES |
| 5 | week_of_year | INT | YES |
| 6 | _ingested_at | TIMESTAMP | YES |
| 7 | _source_file | STRING | YES |

---

## Silver Layer (Cleansed & Transformed)

### ecommerce.silver.slv_brands
Trimmed names, cleaned codes, fixed anomalous category codes.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | brand_code | STRING | YES |
| 2 | brand_name | STRING | YES |
| 3 | category_code | STRING | YES |
| 4 | _source_file | STRING | YES |
| 5 | ingested_at | TIMESTAMP | YES |

### ecommerce.silver.slv_category
Deduplicated, uppercased codes.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | category_code | STRING | YES |
| 2 | category_name | STRING | YES |
| 3 | _ingested_at | TIMESTAMP | YES |
| 4 | _source_file | STRING | YES |

### ecommerce.silver.slv_products
Cast numerics, uppercased codes, fixed spelling, abs rating_count.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | product_id | STRING | YES |
| 2 | sku | STRING | YES |
| 3 | category_code | STRING | YES |
| 4 | brand_code | STRING | YES |
| 5 | color | STRING | YES |
| 6 | size | STRING | YES |
| 7 | material | STRING | YES |
| 8 | weight_grams | INT | YES |
| 9 | length_cm | FLOAT | YES |
| 10 | width_cm | FLOAT | YES |
| 11 | height_cm | FLOAT | YES |
| 12 | rating_count | INT | YES |
| 13 | file_name | STRING | YES |
| 14 | ingest_timestamp | TIMESTAMP | YES |

### ecommerce.silver.slv_customers
Dropped null IDs, filled null phones with 'Not Available'.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | customer_id | STRING | YES |
| 2 | phone | STRING | YES |
| 3 | state | STRING | YES |
| 4 | ingest_timestamp | TIMESTAMP | YES |

### ecommerce.silver.slv_calendar
Date parsed, day_name initcapped, quarter & week formatted.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | date | DATE | YES |
| 2 | year | INT | YES |
| 3 | day_name | STRING | YES |
| 4 | quarter | STRING | YES |
| 5 | _ingested_at | TIMESTAMP | YES |
| 6 | _source_file | STRING | YES |

### ecommerce.silver.slv_order_items
Deduplicated, typed casts, channel normalized, dates parsed.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | dt | DATE | YES |
| 2 | order_ts | TIMESTAMP | YES |
| 3 | customer_id | STRING | YES |
| 4 | order_id | STRING | YES |
| 5 | item_seq | STRING | YES |
| 6 | product_id | STRING | YES |
| 7 | quantity | INT | YES |
| 8 | unit_price_currency | STRING | YES |
| 9 | unit_price | FLOAT | YES |
| 10 | discount_pct | FLOAT | YES |
| 11 | tax_amount | FLOAT | YES |
| 12 | channel | STRING | YES |
| 13 | coupon_code | STRING | YES |
| 14 | _source_file | STRING | YES |
| 15 | _ingested_at | TIMESTAMP | YES |

---

## Gold Layer (BI-Ready)

### ecommerce.gold.gld_fact_order_items
Fact table with calculated amounts and INR currency conversion.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | date_id | INT | YES |
| 2 | transaction_date | DATE | YES |
| 3 | transaction_ts | TIMESTAMP | YES |
| 4 | transaction_id | STRING | YES |
| 5 | customer_id | STRING | YES |
| 6 | seq_no | STRING | YES |
| 7 | product_id | STRING | YES |
| 8 | channel | STRING | YES |
| 9 | coupon_code | STRING | YES |
| 10 | coupon_flag | INT | YES |
| 11 | unit_price_currency | STRING | YES |
| 12 | quantity | INT | YES |
| 13 | unit_price | FLOAT | YES |
| 14 | gross_amount | DOUBLE | YES |
| 15 | discount_percent | FLOAT | YES |
| 16 | discount_amount | LONG | YES |
| 17 | tax_amount | FLOAT | YES |
| 18 | net_amount | DOUBLE | YES |
| 19 | net_amount_inr | LONG | YES |

### ecommerce.gold.gld_dim_customers
Customer dimension with country & region enrichment.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | state | STRING | YES |
| 2 | customer_id | STRING | YES |
| 3 | phone | STRING | YES |
| 4 | ingest_timestamp | TIMESTAMP | YES |
| 5 | country | STRING | YES |
| 6 | region | STRING | YES |

### ecommerce.gold.gld_dim_date
Date dimension with date_id, month_name, is_weekend, formatted quarter & week.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | date_id | INT | YES |
| 2 | date | DATE | YES |
| 3 | year | INT | YES |
| 4 | month_name | STRING | YES |
| 5 | day_name | STRING | YES |
| 6 | is_weekend | INT | YES |
| 7 | quarter | STRING | YES |
| 8 | week | STRING | YES |
| 9 | _ingested_at | TIMESTAMP | YES |
| 10 | _source_file | STRING | YES |

### ecommerce.gold.gld_dim_products
Product dimension enriched with brand & category names.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | product_id | STRING | YES |
| 2 | sku | STRING | YES |
| 3 | category_code | STRING | YES |
| 4 | category_name | STRING | YES |
| 5 | brand_code | STRING | YES |
| 6 | brand_name | STRING | YES |
| 7 | color | STRING | YES |
| 8 | size | STRING | YES |
| 9 | material | STRING | YES |
| 10 | weight_grams | STRING | YES |
| 11 | length_cm | STRING | YES |
| 12 | width_cm | FLOAT | YES |
| 13 | height_cm | FLOAT | YES |
| 14 | rating_count | INT | YES |
| 15 | file_name | STRING | YES |
| 16 | ingest_timestamp | TIMESTAMP | YES |

### ecommerce.gold.fact_transactions_denorm (VIEW)
Denormalized view joining fact_order_items + dim_date + dim_products for BI.

| # | Column | Type | Nullable |
|---|--------|------|----------|
| 1 | date_id | INT | YES |
| 2 | transaction_date | DATE | YES |
| 3 | transaction_ts | TIMESTAMP | YES |
| 4 | transaction_id | STRING | YES |
| 5 | customer_id | STRING | YES |
| 6 | seq_no | STRING | YES |
| 7 | product_id | STRING | YES |
| 8 | channel | STRING | YES |
| 9 | coupon_code | STRING | YES |
| 10 | coupon_flag | INT | YES |
| 11 | unit_price_currency | STRING | YES |
| 12 | quantity | INT | YES |
| 13 | unit_price | FLOAT | YES |
| 14 | gross_amount | DOUBLE | YES |
| 15 | discount_percent | FLOAT | YES |
| 16 | discount_amount | LONG | YES |
| 17 | tax_amount | FLOAT | YES |
| 18 | net_amount | DOUBLE | YES |
| 19 | net_amount_inr | LONG | YES |
| 20 | year | INT | YES |
| 21 | month_name | STRING | YES |
| 22 | day_name | STRING | YES |
| 23 | is_weekend | INT | YES |
| 24 | quarter | STRING | YES |
| 25 | week | STRING | YES |
| 26 | sku | STRING | YES |
| 27 | category_code | STRING | YES |
| 28 | category_name | STRING | YES |
| 29 | brand_code | STRING | YES |
| 30 | brand_name | STRING | YES |
| 31 | color | STRING | YES |
| 32 | size | STRING | YES |
| 33 | rating_count | INT | YES |
| 34 | hour_of_day | INT | YES |
