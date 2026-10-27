# E-Commerce Analytics Platform using Databricks

> An end-to-end data engineering and analytics pipeline built on **Databricks**, **PySpark**, **Delta Lake**, and **Unity Catalog**, following the **Medallion Architecture** (Bronze -> Silver -> Gold) to transform raw e-commerce data into interactive sales and marketing dashboards.

## Architecture

```
Raw CSV Files (Unity Catalog Volume)
        |
  BRONZE LAYER  (Raw ingestion with metadata)
        |
  SILVER LAYER  (Cleansed, typed, deduplicated, normalized)
        |
  GOLD LAYER     (BI-ready fact & dimension tables + denormalized view)
        |
  DASHBOARDS     (Sales Insights + Marketing Insights)
```

## Technology Stack
- **Databricks** - Compute platform, notebook execution, AI/BI dashboards
- **PySpark** - Distributed data processing & transformations
- **Spark SQL** - SQL-based table operations and views
- **Delta Lake** - ACID transactions, schema enforcement
- **Unity Catalog** - Centralized governance (catalog/schema/table hierarchy)
- **AI/BI Dashboards** - Interactive visualizations

## Unity Catalog Structure

```
ecommerce (CATALOG)
+- bronze (SCHEMA): btr_brands, brz_order_items, brz_products, brz_customers, brz_category, brz_calendar
+- silver (SCHEMA): slv_brands, slv_category, slv_products, slv_customers, slv_calendar, slv_order_items
+- gold (SCHEMA): gld_fact_order_items, gld_dim_customers, gld_dim_date, gld_dim_products, fact_transactions_denorm (VIEW)
```

## Pipeline Transformations

### Bronze (Raw Ingestion)
- CSV files read with explicit schemas from Unity Catalog volume
- Metadata capture: `_source_file`, `ingest_timestamp`
- Written as Delta tables with `mergeSchema`

### Silver (Cleansing & Transformation)
- **Brands**: Trim names, clean codes, fix anomalous category codes (GROCERY->GRCY, BOOKS->BKS, TOYS->TOY)
- **Category**: Deduplicate, uppercase codes
- **Products**: Cast numerics (weight_grams, length_cm), fix spelling (Coton->Cotton, Alumium->Aluminum, Ruber->Rubber), abs rating_count
- **Customers**: Drop null IDs, fill null phones with 'Not Available'
- **Calendar**: Parse dates (dd-MM-yyyy), initcap day_name, format quarter as "Q3 2025", week as "Week-31-2025"
- **Order Items**: Deduplicate on (order_id, item_seq), cast quantity/unit_price/discount_pct/tax_amount, normalize channel (web->Website, app->Mobile), parse dates, lowercase/trim coupon_code

### Gold (BI-Ready)
- **gld_fact_order_items**: Calculated gross_amount, discount_amount, net_amount (gross - discount + tax), FX conversion to INR using static rate table, coupon_flag, date_id
- **gld_dim_customers**: Country/region enrichment via mapping (state code -> country -> APAC/AMER/EMEA)
- **gld_dim_date**: date_id (yyyyMMdd), month_name, is_weekend, formatted quarter & week
- **gld_dim_products**: Enriched with brand_name & category_name via JOIN
- **fact_transactions_denorm** (VIEW): Denormalized view joining fact + dim_date + dim_products with hour_of_day extraction

## Gold Layer Tables

### gld_fact_order_items (Fact Table)
| Column | Type | Description |
|--------|------|-------------|
| date_id | INT | Date key (yyyyMMdd) |
| transaction_date | DATE | Order date |
| transaction_id | STRING | Order ID |
| customer_id | STRING | Customer reference |
| product_id | STRING | Product reference |
| channel | STRING | Website or Mobile |
| coupon_flag | INT | 1 = coupon used, 0 = none |
| quantity | INT | Units ordered |
| unit_price | FLOAT | Price per unit |
| gross_amount | DOUBLE | quantity x unit_price |
| discount_amount | LONG | ceil(gross x discount_pct / 100) |
| net_amount | DOUBLE | gross - discount + tax |
| net_amount_inr | LONG | net_amount x FX rate |

### gld_dim_customers (Dimension)
| Column | Type | Description |
|--------|------|-------------|
| customer_id | STRING | Unique customer ID |
| state | STRING | 2-letter country code (IN, US, GB, AE, SG, CA, AU) |
| country | STRING | Full country name |
| region | STRING | APAC, AMER, or EMEA |

### gld_dim_date (Dimension)
| Column | Type | Description |
|--------|------|-------------|
| date_id | INT | Date key (yyyyMMdd) |
| date | DATE | Calendar date |
| year | INT | Year |
| month_name | STRING | Month name |
| is_weekend | INT | 1 = Sat/Sun, 0 = weekday |
| quarter | STRING | e.g., "Q3 2025" |

### gld_dim_products (Dimension)
| Column | Type | Description |
|--------|------|-------------|
| product_id | STRING | Unique product ID |
| sku | STRING | Stock keeping unit |
| category_name | STRING | Category (enriched) |
| brand_name | STRING | Brand (enriched) |
| material | STRING | Material (spelling corrected) |

### fact_transactions_denorm (VIEW)
Denormalized view joining gld_fact_order_items + gld_dim_date + gld_dim_products, adding hour_of_day for time analysis. This is the primary dataset for the dashboards.

## Dashboard: E-commerce Sales Insights

### Page 1: Marketing Insights
- Distinct Customers (counter)
- Coupon Redemption Rate (counter)
- Coupon Net Sales (counter)
- Coupons Used (counter)
- Net Amount Distribution (histogram)
- Customers by Channel (bar)
- Top 10 Coupons by Net Sales (bar)
- Weekend vs Weekday Net Sales (bar)
- Net Sales Trend by Channel (line)

### Page 2: Sales Insights
- Monthly Sales Trend by Year (line)
- Total Net Sales (counter)
- Total Orders (counter)
- Units Sold (counter)
- Avg Order Value (counter)
- Net Sales by Channel (pie)
- Net Sales by Coupon Usage (bar)
- Net Sales by Hour of Day (bar)
- Net Sales by Day of Week (bar)
- Top 10 Products by Net Sales (bar)
- Net Sales by Category (bar)

## Repository Structure
```
notebooks/bronze/    - Bronze layer ingestion scripts
notebooks/silver/    - Silver layer transformation scripts
notebooks/gold/      - Gold layer BI-ready scripts
sql/bronze/          - Bronze table DDL
sql/silver/          - Silver table DDL
sql/gold/            - Gold table DDL + dim_products creation
sql/views/           - Denormalized view DDL
catalog/             - Unity Catalog metadata (Markdown + CSV)
dashboards/          - Dashboard JSON export
docs/images/         - Dashboard screenshots
data/raw/            - Raw data placeholder (no data committed)
```

## Setup Instructions

1. Create catalog and schemas:
```sql
CREATE CATALOG IF NOT EXISTS ecommerce;
CREATE SCHEMA IF NOT EXISTS ecommerce.bronze;
CREATE SCHEMA IF NOT EXISTS ecommerce.silver;
CREATE SCHEMA IF NOT EXISTS ecommerce.gold;
```

2. Upload raw CSV data to Unity Catalog volume at `/Volumes/ecommerce/source_data/raw/order_items/ecomm-raw-data/`

3. Run Bronze notebooks (ingest raw data)

4. Run Silver notebooks (cleanse and transform)

5. Run Gold notebooks (build BI-ready tables)

6. Create denormalized view using `sql/views/fact_transactions_denorm_view.sql`

7. Import dashboard from `dashboards/` or rebuild from widget specs in this README

## Sharing the Dashboard with Recruiters
1. Publish the dashboard in Databricks
2. Use Share button to generate a link
3. Add screenshots to `docs/images/`
4. Do NOT share credentials or workspace URLs in the public repo

## Known Quirks
1. `state` column in customers holds 2-letter COUNTRY codes (IN, US, GB, etc.), not states
2. `brand_name` and `category_name` may show 'Not Available' when join keys don't match
3. FX rates are static (INR=1.00, AED=24.18, AUD=57.55, CAD=62.93, GBP=117.98, SGD=68.18, USD=88.29)
4. Data spans Aug-Oct 2025

## Data Privacy
- No PII, credentials, tokens, or secrets in this repository
- Raw data excluded via .gitignore
- Only code, DDL, metadata, and dashboard definitions are committed
