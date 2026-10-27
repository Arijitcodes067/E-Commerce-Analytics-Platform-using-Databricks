# Databricks notebook source
# ---
# Notebook: 1_dim_bronze
# Layer:   Bronze (Dimension)
# Purpose: Ingest brands CSV from raw volume into ecommerce.bronze.btr_brands
# ---

from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DateType, TimestampType, FloatType
import pyspark.sql.functions as F

catalogue_name = "ecommerce"
brand_schema = StructType([
  StructField("brand_code", StringType(), False),
  StructField("brand_name", StringType(), True),
  StructField("category_code", StringType(), True)
])

raw_data_path = "/Volumes/ecommerce/source_data/raw/order_items/ecomm-raw-data/brands/brands.csv"

df = spark.read.option("header", "true").option("delimiter", ",").schema(brand_schema).csv(raw_data_path)

df = df.withColumn("_source_file", F.col("_metadata.file_path")) \
    .withColumn("ingested_at", F.current_timestamp())

df.write.format("delta").mode("overwrite").option("mergeSchema", "true").saveAsTable(f"{catalogue_name}.bronze.btr_brands")
