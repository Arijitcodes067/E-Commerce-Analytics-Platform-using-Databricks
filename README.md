# E-Commerce Analytics Platform \| Databricks, PySpark & SQL

An  e-commerce data engineering and analytics project built
with **Databricks**, **PySpark**, **Spark SQL**, and **Delta Lake**. The
project organizes raw e-commerce data into a Medallion Architecture
(**Bronze → Silver → Gold**) and prepares curated datasets for sales and
marketing dashboards.

> **Project status:** The notebooks and Gold-layer transformations are
> included in this repository. The sales and marketing dashboards were
> created in Databricks; add dashboard screenshots and a shareable
> Databricks URL below when you are ready to publish them.

## Project Overview

The project takes raw e-commerce data through ingestion, cleaning,
dimensional modeling, and analytics-ready modeling. It covers both
dimension data (products, brands, categories, customers, and dates) and
order-item fact data.

### Architecture

``` text
Raw CSV files (Unity Catalog Volumes)
              |
              v
       BRONZE — Raw ingestion
       • Explicit schemas
       • Source-file metadata
       • Ingestion timestamps
              |
              v
       SILVER — Cleaned data
       • Type conversions
       • Null and duplicate handling
       • Text normalization and anomaly fixes
       • Standardized order-item fields
              |
              v
       GOLD — Analytics-ready models
       • Product, customer and date dimensions
       • Order-item fact table
       • Denormalized transaction view
              |
              v
       Databricks Sales & Marketing Dashboards
```

## Technology Stack

-   **Databricks** --- notebooks, SQL, data exploration, dashboards, and
    Unity Catalog
-   **PySpark** --- ingestion and data transformations
-   **Spark SQL** --- Gold-layer table creation and analytical views
-   **Delta Lake** --- managed tables in the medallion layers
-   **Unity Catalog** --- catalog and schema organization
-   **GitHub** --- version control and project documentation

## Data Pipeline

### 1. Bronze: Raw ingestion

The Bronze notebooks read CSV files from Databricks Volumes using
explicit schemas and write them as Delta tables. Ingestion metadata is
captured where implemented.

Dimension tables: - `ecommerce.bronze.brz_brands` -
`ecommerce.bronze.brz_category` - `ecommerce.bronze.brz_products` -
`ecommerce.bronze.brz_customers` - `ecommerce.bronze.brz_calendar`

Fact table: - `ecommerce.bronze.brz_order_items`

### 2. Silver: Cleaning and standardization

The Silver notebooks transform Bronze data into more consistent
datasets.

Examples of implemented cleaning: - Remove duplicate order-item records
using `order_id` and `item_seq` - Convert quantity, price, discount,
tax, date, and timestamp fields to usable types - Normalize coupon codes
and sales channel labels - Clean product weights and dimensions
containing inconsistent characters or decimal separators - Normalize
brand/category codes and selected material spelling variants - Handle
missing customer IDs and phone numbers - Parse calendar dates, remove
duplicate dates, standardize day-name casing, and normalize week values

Silver tables: - `ecommerce.silver.slv_brands` -
`ecommerce.silver.slv_category` - `ecommerce.silver.slv_products` -
`ecommerce.silver.slv_customers` - `ecommerce.silver.slv_calendar` -
`ecommerce.silver.slv_order_items`

### 3. Gold: Business-ready models

The Gold notebooks prepare datasets for reporting and dashboard use.

  -------------------------------------------------------------------------------
  Gold asset                                  Purpose
  ------------------------------------------- -----------------------------------
  `ecommerce.gold.gld_dim_products`           Product attributes enriched with
                                              brand and category names

  `ecommerce.gold.gld_dim_customers`          Customer attributes enriched with a
                                              region mapping

  `ecommerce.gold.gld_dim_date`               Calendar dimension with date key,
                                              month name, weekend flag, quarter,
                                              and week

  `ecommerce.gold.gld_fact_order_items`       Order-item fact table with gross
                                              amount, discount, tax-inclusive net
                                              amount, coupon flag, and
                                              INR-converted amount

  `ecommerce.gold.fact_transactions_denorm`   Denormalized transaction view
                                              joining the fact table to date and
                                              product dimensions
  -------------------------------------------------------------------------------

The fact-table calculations include: -
`gross_amount = quantity × unit_price` - `discount_amount` based on
`discount_pct` -
`net_amount = gross_amount − discount_amount + tax_amount` - `date_id`
formatted as `yyyyMMdd` - `coupon_flag` indicating whether a coupon code
is present - `net_amount_inr` using a fixed exchange-rate lookup

**Currency note:** The notebook uses fixed exchange rates dated
**2025-10-15**. These are static project assumptions, not live FX rates.
The discount calculation currently uses ceiling rounding; financial
reporting may require a documented currency-precision and rounding
policy.

## Dashboards

I also built **Sales** and **Marketing** dashboards in Databricks using
the curated project data.

Suggested dashboard evidence to add to this repository: -
`docs/images/sales-dashboard.png` -
`docs/images/marketing-dashboard.png`

If you publish a dashboard using Databricks' sharing options, add the
relevant link here:

-   **Sales dashboard:** *Add your shareable Databricks dashboard URL*
-   **Marketing dashboard:** *Add your shareable Databricks dashboard
    URL*

If the dashboard cannot be shared publicly, use sanitized screenshots
with sensitive data removed and explain that the interactive dashboard
is available on request. Do not commit workspace credentials, access
tokens, customer-level personal data, or private workspace URLs that
reveal restricted information.

## Repository Structure

A recruiter-friendly layout could look like this:

``` text
ecommerce-databricks-analytics/
├── README.md
├── notebooks/
│   ├── bronze/
│   │   ├── 01_dimension_bronze.ipynb
│   │   └── 02_fact_bronze.ipynb
│   ├── silver/
│   │   ├── 01_dimension_silver.ipynb
│   │   └── 02_fact_silver.ipynb
│   └── gold/
│       ├── 01_dimension_gold.ipynb
│       └── 02_fact_gold.ipynb
├── sql/
│   └── fact_transactions_denorm.sql
├── docs/
│   ├── architecture.png
│   └── images/
│       ├── sales-dashboard.png
│       └── marketing-dashboard.png
├── data/
│   └── README.md
└── .gitignore
```

The names above are a suggested organization; rename the six supplied
notebooks to match this structure when committing them. Do not upload
source CSVs unless you have permission to redistribute them. A
`data/README.md` can describe the expected input files and column
schemas without containing the data itself.

## Running the Project

1.  Import the notebooks into a Databricks workspace.
2.  Make the input CSV files available in a Unity Catalog Volume and
    update the paths in the Bronze notebooks if needed.
3.  Confirm that the `ecommerce` catalog and the `bronze`, `silver`, and
    `gold` schemas exist and that your Databricks identity has the
    required permissions.
4.  Run the notebooks in order:
    1.  Dimension Bronze
    2.  Fact Bronze
    3.  Dimension Silver
    4.  Fact Silver
    5.  Dimension Gold
    6.  Fact Gold
5.  Create the denormalized transaction view using the SQL script after
    its source Gold tables exist.
6.  Validate row counts and inspect the Gold tables before connecting
    them to dashboards.

The notebooks use `mode("overwrite")` for table writes, so rerunning
them replaces existing table data. Review this behavior before using the
pipeline with production data.

## Data and Access Notes

-   Raw file paths point to a Databricks Unity Catalog Volume and will
    need to be configured in another workspace.
-   The repository contains transformation logic, not a portable copy of
    the Databricks catalog or its underlying data.
-   Catalog names, schemas, table definitions, permissions, dashboard
    assets, and data are separate items. Document or export the relevant
    metadata if you want others to reproduce the setup.
-   Never commit credentials, personal customer data, proprietary
    datasets, or workspace secrets.

## What This Project Demonstrates

-   Building a multi-layer data pipeline with the Bronze/Silver/Gold
    pattern
-   Applying explicit schemas and ingestion metadata
-   Cleaning inconsistent real-world data with PySpark
-   Creating dimensional and fact models for BI
-   Using Spark SQL to build a denormalized analytical view
-   Enriching sales data with currency conversion logic
-   Preparing curated data for sales and marketing dashboards in
    Databricks

## Author

**Arijit Bhattacharjee**

-   GitHub: *Add your GitHub profile URL*
-   LinkedIn: *Add your LinkedIn profile URL*
