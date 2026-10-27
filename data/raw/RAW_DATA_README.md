# Raw Data

This directory is a placeholder for raw e-commerce source data.

## Data Sources

The pipeline ingests CSV files from a Unity Catalog volume:
`/Volumes/ecommerce/source_data/raw/order_items/ecomm-raw-data/`

### Source files

| File | Description | Target Bronze Table |
|------|-------------|---------------------|
| `order_items/landing/*.csv` | Daily order line items | `ecommerce.bronze.brz_order_items` |
| `brands/brands.csv` | Brand master data | `ecommerce.bronze.btr_brands` |
| `products/products.csv` | Product catalog | `ecommerce.bronze.brz_products` |
| `customers/customers.csv` | Customer master | `ecommerce.bronze.brz_customers` |
| `category/category.csv` | Category master | `ecommerce.bronze.brz_category` |
| `date/date.csv` | Calendar dimensions | `ecommerce.bronze.brz_calendar` |

> **Note:** Raw data files are NOT included in this repository.
> They are ingested from a Databricks Unity Catalog volume at runtime.
> Do not upload proprietary or customer PII data to this public repo.
