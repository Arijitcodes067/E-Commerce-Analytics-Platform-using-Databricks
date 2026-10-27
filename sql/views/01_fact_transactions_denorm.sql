-- ============================================================
-- Gold: Denormalized fact view for BI dashboards
-- Joins fact_order_items with dim_date and dim_products
-- Source: SHOW CREATE TABLE ecommerce.gold.fact_transactions_denorm
-- ============================================================

CREATE OR REPLACE VIEW ecommerce.gold.fact_transactions_denorm (
  date_id,
  transaction_date,
  transaction_ts,
  transaction_id,
  customer_id,
  seq_no,
  product_id,
  channel,
  coupon_code,
  coupon_flag,
  unit_price_currency,
  quantity,
  unit_price,
  gross_amount,
  discount_percent,
  discount_amount,
  tax_amount,
  net_amount,
  net_amount_inr,
  year,
  month_name,
  day_name,
  is_weekend,
  quarter,
  week,
  sku,
  category_code,
  category_name,
  brand_code,
  brand_name,
  color,
  size,
  rating_count,
  hour_of_day)
DEFAULT COLLATION UTF8_BINARY
WITH SCHEMA COMPENSATION
AS SELECT
    i.*,
    c.year,
    c.month_name,
    c.day_name,
    c.is_weekend,
    c.quarter,
    c.week,
    p.sku,
    p.category_code,
    p.category_name,
    p.brand_code,
    p.brand_name,
    p.color,
    p.size,
    p.rating_count,
    EXTRACT(HOUR FROM i.transaction_ts) AS hour_of_day

FROM ecommerce.gold.gld_fact_order_items AS i

JOIN ecommerce.gold.gld_dim_date AS c
    ON i.date_id = c.date_id

JOIN ecommerce.gold.gld_dim_products AS p
    ON i.product_id = p.product_id
