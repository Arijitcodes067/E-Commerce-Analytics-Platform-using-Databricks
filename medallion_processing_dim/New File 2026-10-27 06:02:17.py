

spark.sql("""
CREATE OR REPLACE TABLE ecommerce.gold.gld_dim_products AS

WITH brands_categories AS (
    SELECT
        b.brand_name,
        b.brand_code,
        c.category_name,
        c.category_code
    FROM ecommerce.silver.slv_brands b
    INNER JOIN ecommerce.silver.slv_category c
        ON b.category_code = c.category_code
)

SELECT
    p.product_id,
    p.sku,
    p.category_code,
    COALESCE(bc.category_name, 'Not Available') AS category_name,
    p.brand_code,
    COALESCE(bc.brand_name, 'Not Available') AS brand_name,
    p.color,
    p.size,
    p.material,
    p.weight_grams,
    p.length_cm,
    p.width_cm,
    p.height_cm,
    p.rating_count,
    p.file_name,
    p.ingest_timestamp

FROM ecommerce.bronze.brz_products p

LEFT JOIN brands_categories bc
    ON p.brand_code = bc.brand_code
""")
