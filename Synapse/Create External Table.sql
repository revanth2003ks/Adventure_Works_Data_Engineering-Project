CREATE MASTER KEY ENCRYPTION BY PASSWORD  = 'Xy$7&mP9#vL2!kQ4'

CREATE DATABASE SCOPED CREDENTIAL cred_ansh
WITH 
    IDENTITY = 'Managed Identity'


CREATE EXTERNAL DATA SOURCE source_silver
WITH
(
    LOCATION = 'https://awprojectdata.dfs.core.windows.net/silver',
    CREDENTIAL = cred_ansh
)

CREATE EXTERNAL DATA SOURCE source_gold
WITH
(
    LOCATION = 'https://awprojectdata.dfs.core.windows.net/gold',
    CREDENTIAL = cred_ansh
)

CREATE EXTERNAL FILE FORMAT format_parquet
WITH
(
    FORMAT_TYPE = PARQUET,
    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
)

--views - used to just access data
--External Tables - access and transform data and to external location

--Create External Table ExtSales

CREATE EXTERNAL TABLE gold.extsales
WITH
(
    LOCATION = 'extsales',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)AS 
SELECT * FROM gold.sales ---data accessed from view(gold.sales) and pasted into gold layer as 'extsales'

SELECT * FROM gold.extsales


CREATE EXTERNAL TABLE gold.ext_calendar
WITH
(
    LOCATION = 'calendar',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)AS 
SELECT * FROM gold.calendar ---data accessed from view(gold.sales) and pasted into gold layer as 'extsales'

CREATE EXTERNAL TABLE gold.ext_customer
WITH
(
    LOCATION = 'customer',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)AS 
SELECT * FROM gold.customer

CREATE EXTERNAL TABLE gold.ext_products
WITH
(
    LOCATION = 'products',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)AS 
SELECT * FROM gold.products

CREATE EXTERNAL TABLE gold.ext_products_sub_categories
WITH
(
    LOCATION = 'products_sub_categories',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)AS 
SELECT * FROM gold.products_sub_categories

CREATE EXTERNAL TABLE gold.ext_products_categories
WITH
(
    LOCATION = 'products_categories',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)AS 
SELECT * FROM gold.products_categories

CREATE EXTERNAL TABLE gold.ext_Returns
WITH
(
    LOCATION = 'Returns',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)AS 
SELECT * FROM gold.Returns

CREATE EXTERNAL TABLE gold.ext_Territories
WITH
(
    LOCATION = 'Territories',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
)AS 
SELECT * FROM gold.Territories
