# Databricks notebook source
# ---
# Script:  dim_category (Bronze - Category)
# Purpose: Ingest category CSV from raw volume into ecommerce.bronze.brz_category
# ---

from pyspark.sql.types import StructType, StructField, StringType
from pyspark.sql import functions as F

catalog_name = "ecommerce"

category_schema = StructType([
    StructField("category_code", StringType(), False),
    StructField("category_name", StringType(), True)
])

raw_data_path = "/Volumes/ecommerce/source_data/raw/order_items/ecomm-raw-data/category/category.csv"

df_raw = (
    spark.read
    .option("header", "true")
    .option("delimiter", ",")
    .schema(category_schema)
    .csv(raw_data_path)
)

df_raw = (
    df_raw
    .withColumn("_ingested_at", F.current_timestamp())
    .withColumn("_source_file", F.col("_metadata.file_path"))
)

df_raw.write.format("delta") \
    .mode("overwrite") \
    .option("mergeSchema", "true") \
    .saveAsTable(f"{catalog_name}.bronze.brz_category")
