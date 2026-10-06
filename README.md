# Adventure_Works_Data_Engineering-Project

# AW Azure Data Engineering Project

An end-to-end data engineering pipeline on Azure using the **AdventureWorks** dataset and the **Medallion Architecture** (Bronze → Silver → Gold).

Raw CSV files are pulled from GitHub with **Azure Data Factory**, stored in **Azure Data Lake Storage Gen2**, cleaned with **Azure Databricks (PySpark)**, served through **Azure Synapse Analytics**, and visualised in **Power BI**.

---
## Architecture

<img width="2576" height="1444" alt="architecture" src="https://github.com/user-attachments/assets/1abcb3cc-4cba-4eee-94c3-dc2fd836b3dd" />

**Data flow:** GitHub (HTTP) → Data Factory → Data Lake (Bronze) → Databricks → Data Lake (Silver) → Synapse → Data Lake (Gold) → Power BI

| Layer | Container | Format | What happens here |
|---|---|---|---|
| 🥉 Bronze | `bronze` | CSV | Raw files copied as-is from GitHub by Data Factory |
| 🥈 Silver | `silver` | Parquet | Cleaned and transformed data written by Databricks |
| 🥇 Gold | `gold` | Parquet | Business-ready tables created by Synapse external tables |

---

## Tech Stack

| Purpose | Service |
|---|---|
| Source | GitHub (HTTP) |
| Ingestion | Azure Data Factory |
| Storage | Azure Data Lake Storage Gen2 |
| Transformation | Azure Databricks (PySpark) |
| Serving | Azure Synapse Analytics (serverless SQL pool) |
| Reporting | Power BI |
| Authentication | Microsoft Entra ID service principal (Databricks), managed identity (Synapse) |

---

## Dataset

AdventureWorks files used:

- Calendar
- Customers
- Product Categories
- Product Subcategories
- Products
- Returns
- Sales (2015, 2016, 2017)
- Territories

---

## Pipeline Walkthrough

### 1. Ingestion: Azure Data Factory

A single metadata-driven pipeline copies all files into the `bronze` container:

| Activity | Role |
|---|---|
| **Lookup** | Reads the list of files to copy |
| **ForEach** | Loops over each item from Lookup |
| **Copy** | Copies each file from GitHub (HTTP) to the bronze container |

Adding a new file only needs a new entry in the list; the pipeline stays unchanged.

### 2. Transformation: Azure Databricks

PySpark notebooks read the CSVs from `bronze`, transform them, and write Parquet to `silver`.

| Table | Transformation |
|---|---|
| Calendar | Added `Month` and `Year` columns |
| Customers | Added `Fullname` (Prefix + FirstName + LastName) |
| Products | Cleaned `ProductSKU` and `ProductName` using `split` |
| Sales | Merged the 2015, 2016 and 2017 files, converted `StockDate` to timestamp, replaced `S` with `T` in `OrderNumber`, added `Multiply` (OrderLineItem × OrderQuantity) |
| Others | Categories, subcategories, returns and territories copied to silver as Parquet |

Example:

```python
df_sal = spark.read.format('csv')\
    .option('header', True)\
    .option('inferSchema', True)\
    .load('abfss://bronze@<storage_account>.dfs.core.windows.net/AdventureWorks_Sales*')

df_sales = df_sal.withColumn('StockDate', to_timestamp('StockDate'))\
    .withColumn('OrderNumber', regexp_replace(col('OrderNumber'), 'S', 'T'))\
    .withColumn('Multiply', col('OrderLineItem') * col('OrderQuantity'))

df_sales.write.format('parquet')\
    .mode('append')\
    .option('path', 'abfss://silver@<storage_account>.dfs.core.windows.net/AdventureWorks_Sales')\
    .save()
```

### 3. Serving: Azure Synapse

In a Synapse **serverless SQL pool**:

1. Created a `gold` schema.
2. Created **views** over the silver Parquet files using `OPENROWSET`. Views only read data.
3. Created a managed identity credential, external data sources and a Parquet file format.
4. Created **external tables (CETAS)** that read from the views and **write the result to the gold container**.

```sql
CREATE VIEW gold.sales
AS
SELECT *
FROM OPENROWSET(
    BULK 'https://<storage_account>.dfs.core.windows.net/silver/AdventureWorks_Sales/',
    FORMAT = 'PARQUET'
) AS sales;

CREATE EXTERNAL TABLE gold.extsales
WITH (
    LOCATION = 'extsales',
    DATA_SOURCE = source_gold,
    FILE_FORMAT = format_parquet
) AS
SELECT * FROM gold.sales;
```

### 4. Reporting: Power BI

Power BI connects to Synapse, loads the gold tables, and powers the dashboard.

<!-- Add your dashboard screenshot here -->
<!-- ![Dashboard](images/dashboard.png) -->

---

## Suggested Repository Structure

```
.
├── README.md
├── images/
│   ├── architecture.jpg
│   └── dashboard.png
├── adf/
│   └── pipeline.json            # Data Factory pipeline (Lookup, ForEach, Copy)
├── databricks/
│   └── silver_transformations.ipynb
├── synapse/
│   ├── 01_views.sql
│   └── 02_external_tables.sql
└── powerbi/
    └── dashboard.pbix
```

---

## How to Reproduce

1. Create a storage account (ADLS Gen2) with containers `bronze`, `silver` and `gold`.
2. Create a Data Factory and build the Lookup → ForEach → Copy pipeline to load the files from GitHub into `bronze`.
3. Create a service principal, give it access to the storage account (Storage Blob Data Contributor), and connect Databricks to the lake.
4. Run the Databricks notebook to create the silver layer.
5. Create a Synapse workspace, then run the SQL scripts to create the views, credentials and external tables.
6. Give the Synapse managed identity access to the storage account.
7. Connect Power BI to the Synapse serverless SQL endpoint and build the report.

---

## Security Notes

- **No secrets are stored in this repository.** Placeholders such as `<CLIENT_SECRET>` and `<storage_account>` must be replaced with your own values.
- Recommended: store secrets in **Azure Key Vault** and read them in Databricks with a secret scope.

---

## Key Learnings

- Building a metadata-driven pipeline with Lookup, ForEach and Copy
- Organising data with the Medallion Architecture
- Authenticating Databricks to ADLS Gen2 with a service principal
- Difference between **views** (read only) and **external tables / CETAS** (read, transform and write to storage) in Synapse
- Why Parquet is preferred over CSV for analytics

## Future Improvements

- Use `overwrite` or Delta Lake with `MERGE` so reruns do not duplicate data
- Add incremental loading in Data Factory
- Store secrets in Azure Key Vault
- Schedule the pipeline with triggers and add monitoring and alerts
- Add data quality checks in the silver layer

---

## Author

**Revanth**

- LinkedIn: [linkedin.com/in/revanth-ks](https://linkedin.com/in/revanth-ks)
- GitHub: [revanth2003ks](https://github.com/revanth2003ks)
