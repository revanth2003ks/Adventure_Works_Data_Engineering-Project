--create schema
CREATE SCHEMA gold;

--create view calender
CREATE VIEW gold.calendar
AS
select * 
from OPENROWSET(
                 BULK 'https://awprojectdata.dfs.core.windows.net/silver/AdventureWorks_Calendar/',
                 Format = 'PARQUET'
) as calender

CREATE VIEW gold.customer
AS
select * 
from OPENROWSET(
                 BULK 'https://awprojectdata.blob.core.windows.net/silver/AdventureWorks_Customers/',
                 Format = 'PARQUET'
) as customer

CREATE VIEW gold.products
AS
select * 
from OPENROWSET(
                 BULK 'https://awprojectdata.blob.core.windows.net/silver/AdventureWorks_Product/',
                 Format = 'PARQUET'
) as product

CREATE VIEW gold.products_sub_categories
AS
select * 
from OPENROWSET(
                 BULK 'https://awprojectdata.blob.core.windows.net/silver/AdventureWorks_Product_Sub_Categories/',
                 Format = 'PARQUET'
) as product_sub_caregories


CREATE VIEW gold.products_categories
AS
select * 
from OPENROWSET(
                 BULK 'https://awprojectdata.blob.core.windows.net/silver/AdventureWorks_Product_category/',
                 Format = 'PARQUET'
) as product_caregories


CREATE VIEW gold.Returns
AS
select * 
from OPENROWSET(
                 BULK 'https://awprojectdata.blob.core.windows.net/silver/AdventureWorks_Returns/',
                 Format = 'PARQUET'
) as Returns

CREATE VIEW gold.Returns
AS
select * 
from OPENROWSET(
                 BULK 'https://awprojectdata.blob.core.windows.net/silver/AdventureWorks_Returns/',
                 Format = 'PARQUET'
) as Returns

CREATE VIEW gold.sales
AS
select * 
from OPENROWSET(
                 BULK 'https://awprojectdata.blob.core.windows.net/silver/AdventureWorks_Sales/',
                 Format = 'PARQUET'
) as sales

CREATE VIEW gold.Territories
AS
select * 
from OPENROWSET(
                 BULK 'https://awprojectdata.blob.core.windows.net/silver/AdventureWorks_Territories/',
                 Format = 'PARQUET'
) as Territories


