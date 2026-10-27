# E-Commerce Analytics Platform using Databricks

> An end-to-end data engineering and analytics pipeline built on **Databricks**, **PySpark**, **Delta Lake**, and **Unity Catalog**, following the **Medallion Architecture** (Bronze → Silver → Gold) to transform raw e-commerce data into interactive sales and marketing dashboards.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Data Pipeline](#data-pipeline)
- [Unity Catalog Structure](#unity-catalog-structure)
- [Gold Layer Tables](#gold-layer-tables)
- [Dashboard](#dashboard)
- [Repository Structure](#repository-structure)
- [Setup Instructions](#setup-instructions)
- [Sharing the Dashboard](#sharing-the-dashboard)
- [Known Quirks & Design Decisions](#known-quirks--design-decisions)

---

## Overview

This project ingests raw e-commerce transaction data (order items, products, customers, brands, categories, and calendar) from CSV files stored in a Unity Catalog volume, processes it through a multi-layer Medallion Architecture pipeline, and delivers BI-ready Gold tables that power interactive **Sales Insights** and **Marketing Insights** dashboards.

The pipeline handles data quality issues including:
- Duplicate records (deduplication on `order_id` + `item_seq`)
- Mixed data types (string-to-numeric casting)
- Inconsistent formatting (date parsing, channel name normalization)
- Spelling errors in product materials (`Coton` → `Cotton`, `Alumium` → `Aluminum`, `Ruber` → `Rubber`)
- Anomalous category codes (`GROCERY` → `GRCY`, `BOOKS` → `BKS`, `TOYS` → `TOY`)
- Multi-currency transactions (FX conversion to INR using static rate table)

---

## Architecture

```
Raw CSV Files (Unity Catalog Volume)
        │
        ▼
┌─────────────────────────────────┐
│        BRONZE LAYER              │
│  Raw ingestion with metadata     │
│  (file_name, ingest_timestamp)   │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│        SILVER LAYER              │
│  Cleansed & typed data           │
│  Deduplication, casting,         │
│  normalization, spelling fixes  │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│        GOLD LAYER                │
│  BI-ready fact & dimension tables│
│  + Denormalized view for BI      │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│     DASHBOARDS (AI/BI)           │
│  Sales Insights + Marketing      │
│  Insights pages                  │
└─────────────────────────────────┘
```

### Pipeline Flow (Dimension Track)

| Step | Source | Target | Key Transformations |
|------|--------|--------|-------------------|
| Bronze | `brands.csv` | `bronze.btr_brands` | Schema enforcement, metadata capture |
| Bronze | `products.csv` | `bronze.brz_products` | Schema enforcement, metadata capture |
| Bronze | `customers.csv` | `bronze.brz_customers` | Schema enforcement, metadata capture |
| Bronze | `category.csv` | `bronze.brz_category` | Schema enforcement, metadata capture |
| Bronze | `date.csv` | `bronze.brz_calendar` | Schema enforcement, metadata capture |
| Silver | `bronze.btr_brands` | `silver.slv_brands` | Trim names, clean codes, fix anomalous categories |
| Silver | `bronze.brz_category` | `silver.slv_category` | Deduplicate, uppercase codes |
| Silver | `bronze.brz_products` | `silver.slv_products` | Cast numerics, fix spelling, abs rating_count |
| Silver | `bronze.brz_customers` | `silver.slv_customers` | Drop null IDs, fill null phones |
| Silver | `bronze.brz_calendar` | `silver.slv_calendar` | Parse dates, initcap day_name, format quarter/week |
| Gold | `silver.slv_customers` | `gold.gld_dim_customers` | Country/region enrichment via mapping |
| Gold | `silver.slv_calendar` | `gold.gld_dim_date` | Add date_id, month_name, is_weekend, week |
| Gold | `bronze.brz_products` + silver | `gold.gld_dim_products` | Enrich with brand & category names |

### Pipeline Flow (Fact Track)

| Step | Source | Target | Key Transformations |
|------|--------|--------|-------------------|
| Bronze | `order_items/landing/*.csv` | `bronze.brz_order_items` | Schema enforcement, metadata capture |
| Silver | `bronze.brz_order_items` | `silver.slv_order_items` | Deduplicate, cast types, normalize channel, parse dates |
| Gold | `silver.slv_order_items` | `gold.gld_fact_order_items` | Calculate amounts, FX conversion to INR, coupon_flag |
| Gold View | `gold.gld_fact_order_items` + dims | `gold.fact_transactions_denorm` | Denormalized view for BI dashboards |

---

## Technology Stack

| Technology | Role |
|-----------|------|
| **Databricks** | Compute platform, notebook execution, dashboards |
| **PySpark** | Distributed data processing & transformations |
| **Spark SQL** | SQL-based table operations and views |
| **Delta Lake** | ACID transactions, schema enforcement, MERGE support |
| **Unity Catalog** | Centralized governance, catalog/schema/table hierarchy |
| **AI/BI Dashboards** | Interactive visualizations with counters, bars, lines, pies |

---

## Unity Catalog Structure

```
ecommerce (CATALOG)
├── bronze (SCHEMA)
│   ├── btr_brands        -- Brand master (raw)
│   ├── brz_order_items   -- Order line items (raw)
│   ├── brz_products      -- Product catalog (raw)
│   ├── brz_customers     -- Customer master (raw)
│   ├── brz_category      -- Category master (raw)
│   └── brz_calendar      -- Calendar dimensions (raw)
├── silver (SCHEMA)
│   ├── slv_brands        -- Cleansed brands
│   ├── slv_category      -- Cleansed categories
│   ├── slv_products      -- Cleansed products
│   ├── slv_customers     -- Cleansed customers
│   ├── slv_calendar      -- Cleansed calendar
│   └── slv_order_items   -- Cleansed order items
└── gold (SCHEMA)
    ├── gld_fact_order_items      -- Fact table with amounts & FX
    ├── gld_dim_customers         -- Customer dimension (with region)
    ├── gld_dim_date              -- Date dimension
    ├── gld_dim_products         -- Product dimension (with brand/category)
    └── fact_transactions_denorm  -- Denormalized VIEW for BI
```

Full column-level metadata is available in [`catalog/catalog_inventory.md`](catalog/catalog_inventory.md) and [`catalog/catalog_inventory.csv`](catalog/catalog_inventory.csv).

---

## Gold Layer Tables

### gld_fact_order_items (Fact)

| Column | Type | Description |
|--------|------|-------------|
| `date_id` | INT | Date key (yyyyMMdd) |
| `transaction_date` | DATE | Order date |
| `transaction_ts` | TIMESTAMP | Order timestamp |
| `transaction_id` | STRING | Order ID |
| `customer_id` | STRING | Customer reference |
| `product_id` | STRING | Product reference |
| `channel` | STRING | Website or Mobile |
| `coupon_code` | STRING | Coupon used (nullable) |
| `coupon_flag` | INT | 1 = coupon used, 0 = no coupon |
| `quantity` | INT | Units ordered |
| `unit_price` | FLOAT | Price per unit |
| `gross_amount` | DOUBLE | quantity × unit_price |
| `discount_amount` | LONG | ceil(gross × discount_pct / 100) |
| `net_amount` | DOUBLE | gross - discount + tax |
| `net_amount_inr` | LONG | net_amount × FX rate to INR |

### gld_dim_customers (Dimension)

| Column | Type | Description |
|--------|------|-------------|
| `customer_id` | STRING | Unique customer ID |
| `phone` | STRING | Phone number |
| `state` | STRING | 2-letter country code (IN, US, GB, AE, SG, CA, AU) |
| `country` | STRING | Full country name |
| `region` | STRING | APAC, AMER, or EMEA |

### gld_dim_date (Dimension)

| Column | Type | Description |
|--------|------|-------------|
| `date_id` | INT | Date key (yyyyMMdd) |
| `date` | DATE | Calendar date |
| `year` | INT | Year |
| `month_name` | STRING | Month name |
| `day_name` | STRING | Day of week |
| `is_weekend` | INT | 1 = Saturday/Sunday, 0 = weekday |
| `quarter` | STRING | e.g., "Q3 2025" |
| `week` | STRING | e.g., "Week-31-2025" |

### gld_dim_products (Dimension)

| Column | Type | Description |
|--------|------|-------------|
| `product_id` | STRING | Unique product ID |
| `sku` | STRING | Stock keeping unit |
| `category_name` | STRING | Category name (enriched) |
| `brand_name` | STRING | Brand name (enriched) |
| `color` | STRING | Product color |
| `size` | STRING | Product size |
| `material` | STRING | Material (spelling corrected) |
| `rating_count` | INT | Number of ratings |

### fact_transactions_denorm (VIEW)

Denormalized view joining `gld_fact_order_items` with `gld_dim_date` and `gld_dim_products`, adding `hour_of_day` for time-based analysis. This view is the primary dataset for the dashboards.

DDL: [`sql/views/01_fact_transactions_denorm.sql`](sql/views/01_fact_transactions_denorm.sql)

---

## Dashboard

**E-commerce Sales Insights** — an AI/BI dashboard with 2 pages and 22 widgets.

### Page 1: Marketing Insights

| Widget | Type | Metric |
|--------|------|--------|
| Distinct Customers | Counter | COUNT(DISTINCT customer_id) |
| Coupon Redemption Rate | Counter | MEASURE(coupon_redemption_rate) |
| Coupon Net Sales | Counter | SUM(net_amount) |
| Coupons Used | Counter | COUNT(DISTINCT coupon_code) |
| Net Amount Distribution | Histogram | net_amount |
| Customers by Channel | Bar | channel vs customer count |
| Top 10 Coupons by Net Sales | Bar | coupon_code vs SUM(net_amount) |
| Weekend vs Weekday Net Sales | Bar | is_weekend vs SUM(net_amount) |
| Net Sales Trend by Channel | Line | month_name vs SUM(net_amount) by channel |

### Page 2: Sales Insights

| Widget | Type | Metric |
|--------|------|--------|
| Monthly Sales Trend by Year | Line | month_name vs SUM(net_amount) by year |
| Total Net Sales | Counter | SUM(net_amount) |
| Total Orders | Counter | COUNT(DISTINCT transaction_id) |
| Units Sold | Counter | SUM(quantity) |
| Avg Order Value | Counter | MEASURE(avg_order_value) |
| Net Sales by Channel | Pie | channel share of net_amount |
| Net Sales by Coupon Usage | Bar | coupon_flag vs SUM(net_amount) |
| Net Sales by Hour of Day | Bar | hour_of_day vs SUM(net_amount) |
| Net Sales by Day of Week | Bar | day_name vs SUM(net_amount) |
| Top 10 Products by Net Sales | Bar | product_id vs SUM(net_amount) |
| Net Sales by Category | Bar | category_name vs SUM(net_amount) |

Dashboard definition exported to: [`dashboards/sales_insights_dashboard.lvdash.json`](dashboards/sales_insights_dashboard.lvdash.json)

---

## Repository Structure

```
E-Commerce-Analytics-Platform-using-Databricks/
├── README.md                          # This file
├── .gitignore                          # Git ignore rules
├── notebooks/
│   ├── bronze/                        # Bronze layer ingestion scripts
│   │   ├── 1_dim_bronze.py           # Brands ingestion
│   │   ├── dim_product.py             # Products ingestion
│   │   ├── dim_date.py               # Calendar ingestion
│   │   ├── dim_customer.py            # Customers ingestion
│   │   ├── dim_category.py            # Category ingestion
│   │   └── 1_fact_bronze.py           # Order items ingestion
│   ├── silver/                        # Silver layer transformation scripts
│   │   ├── _dim_silver.py            # Dimension cleansing
│   │   └── 2_fact_silver.py           # Fact cleansing
│   └── gold/                          # Gold layer BI-ready scripts
│       ├── flatlists.py               # Dim customers & dim date gold
│       ├── 3_fact_gold.py            # Fact order items gold
│       └── fact_order_items_gold.py   # Fact gold (alternative)
├── sql/
│   ├── bronze/
│   │   └── 01_bronze_ddl.sql          # Bronze table DDL
│   ├── silver/
│   │   └── 01_silver_ddl.sql          # Silver table DDL
│   ├── gold/
│   │   ├── 01_gold_ddl.sql            # Gold table DDL
│   │   └── 02_gld_dim_products.sql    # Product dimension creation
│   └── views/
│       └── 01_fact_transactions_denorm.sql  # Denormalized view
├── catalog/
│   ├── catalog_inventory.md           # Full table/column documentation
│   └── catalog_inventory.csv          # Machine-readable catalog metadata
├── dashboards/
│   └── sales_insights_dashboard.lvdash.json  # Dashboard export
├── docs/
│   └── images/                        # Dashboard screenshots
└── data/
    └── raw/                           # Raw data placeholder (no data committed)
```

---

## Setup Instructions

### Prerequisites

- Databricks workspace with Unity Catalog enabled
- Compute cluster (or serverless) with Spark runtime
- Unity Catalog catalog named `ecommerce` with `bronze`, `silver`, `gold` schemas
- Raw CSV data uploaded to a Unity Catalog volume

### Steps

1. **Create the catalog and schemas:**
   ```sql
   CREATE CATALOG IF NOT EXISTS ecommerce;
   CREATE SCHEMA IF NOT EXISTS ecommerce.bronze;
   CREATE SCHEMA IF NOT EXISTS ecommerce.silver;
   CREATE SCHEMA IF NOT EXISTS ecommerce.gold;
   ```

2. **Upload raw data** to a Unity Catalog volume at:
   `/Volumes/ecommerce/source_data/raw/order_items/ecomm-raw-data/`

   Required files: `brands.csv`, `products.csv`, `customers.csv`, `category.csv`, `date.csv`, and `order_items/landing/*.csv`

3. **Run Bronze notebooks** (ingest raw data):
   - `1_dim_bronze` → brands
   - `dim_product` → products
   - `dim_customer` → customers
   - `dim_category` → category
   - `dim_date` → calendar
   - `1_fact_bronze` → order items

4. **Run Silver notebooks** (cleanse & transform):
   - `_dim_silver` → all dimension silver tables
   - `2_fact_silver` → order items silver

5. **Run Gold notebooks** (build BI-ready tables):
   - `flatlists` → gld_dim_customers, gld_dim_date
   - `3_fact_gold` → gld_fact_order_items
   - Run `sql/gold/02_gld_dim_products.sql` → gld_dim_products
   - Run `sql/views/01_fact_transactions_denorm.sql` → fact_transactions_denorm view

6. **Create the dashboard:**
   Import `dashboards/sales_insights_dashboard.lvdash.json` into Databricks AI/BI dashboards, or rebuild from the widget specifications in this README.

---

## Sharing the Dashboard

To share the dashboard with recruiters:

1. **Publish** the dashboard in Databricks (click **Publish** in the dashboard editor)
2. **Share** using the Share button to generate a link, or add specific users with Viewer permissions
3. **Screenshot** each page for the README:
   - Save as `docs/images/sales-insights-dashboard.png`
   - Save as `docs/images/marketing-insights-dashboard.png`
4. Add the screenshots to the README or link to the published dashboard URL

> **Note:** The dashboard is NOT publicly accessible by default. You must explicitly publish and share it. Do not share credentials or workspace URLs in the public repository.

---

## Known Quirks & Design Decisions

1. **`state` column holds country codes**: In `slv_customers` and `gld_dim_customers`, the `state` column contains 2-letter **country** codes (IN, US, GB, AE, SG, CA, AU), not state/province codes. The `country` column in `gld_dim_customers` was derived by mapping these codes to full country names.

2. **`brand_name` and `category_name` may show 'Not Available'**: In `gld_dim_products`, brand and category enrichment relies on a join between `slv_brands` and `slv_category`. If the join keys don't match, values default to `'Not Available'`.

3. **FX rates are static**: The currency conversion to INR uses a hardcoded rate dictionary, not a live API. Rates: INR=1.00, AED=24.18, AUD=57.55, CAD=62.93, GBP=117.98, SGD=68.18, USD=88.29.

4. **`week_of_year` may show negative values**: The source CSV contains negative week numbers. This is a known data quality issue in the raw data.

5. **Data spans Aug–Oct 2025**: The current dataset covers approximately 3 months of transactions (Aug 1 – Oct 27, 2025).

---

## Data Privacy

- No customer personal data (PII), credentials, tokens, or secrets are committed to this repository
- Raw data files are excluded via `.gitignore` and are not redistributed
- Phone numbers in the customer dimension are cleansed but not exposed in the public repo
- The repository contains only code, DDL, metadata, and dashboard definitions

---

## License

This project is for portfolio demonstration purposes. All code is the author's original work.
