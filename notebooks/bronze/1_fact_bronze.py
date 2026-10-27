# Databricks notebook source
# ---
# Notebook: 1_fact_bronze
# Layer:   Bronze (Fact)
# Purpose: Ingest order_items CSV from raw volume landing zone into ecommerce.bronze.brz_order_items
# ---

### Ingest Fact Data into Bronze Layer

from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DateType, BooleanType
import pyspark.sql.functions as F

catalog_name = 'ecommerce'

order_items_schema = StructType([
    StructField("dt",                  StringType(), True),
    StructField("order_ts",            StringType(), True),
    StructField("customer_id",         StringType(), True),
    StructField("order_id",            StringType(), True),
    StructField("item_seq",             StringType(), True),
    StructField("product_id",          StringType(), True),
    StructField("quantity",            StringType(), True),
    StructField("unit_price_currency", StringType(), True),
    StructField("unit_price",          StringType(), True),
    StructField("discount_pct",        StringType(), True),
    StructField("tax_amount",          StringType(), True),
    StructField("channel",             StringType(), True),
    StructField("coupon_code",         StringType(), True),
])

raw_data_path = "/Volumes/ecommerce/source_data/raw/order_items/ecomm-raw-data/order_items/landing/"

df = spark.read.option("header", "true").option("delimiter", ",").schema(order_items_schema).csv(raw_data_path) \
    .withColumn("file_name", F.col("_metadata.file_path")) \
    .withColumn("ingest_timestamp", F.current_timestamp())

df.write.format("delta") \
    .mode("overwrite") \
    .option("mergeSchema", "true") \
    .saveAsTable(f"{catalog_name}.bronze.brz_order_items")
