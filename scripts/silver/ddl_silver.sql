/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

/* Campaigns Table in Silver Layer*/
IF OBJECT_ID('silver_dim_campaigns', 'U') IS NOT NULL
    DROP TABLE silver_dim_campaigns;
GO

CREATE TABLE silver_dim_campaigns (
    campaign_id VARCHAR(20),
    campaign_name VARCHAR(255),
    start_date DATE, 
    end_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

/* Products Table in silver Layer*/
IF OBJECT_ID('silver_dim_products', 'U') IS NOT NULL
    DROP TABLE silver_dim_products;
GO

CREATE TABLE silver_dim_products (
    product_code VARCHAR(50),
    product_name VARCHAR(255),
    category VARCHAR(255),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

/* Stores Table in silver Layer*/
IF OBJECT_ID('silver_dim_stores', 'U') IS NOT NULL
    DROP TABLE silver_dim_stores;
GO

CREATE TABLE silver_dim_stores (
    store_id VARCHAR(50),
    city VARCHAR(100),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

/* Fact Events Table in silver Layer*/
IF OBJECT_ID('silver_fact_events', 'U') IS NOT NULL
    DROP TABLE silver_fact_events;
GO

CREATE TABLE silver_fact_events (
    event_id VARCHAR(10),
    store_id VARCHAR(10),
    campaign_id VARCHAR(20),
    product_code VARCHAR(10),
    base_price INT,
    promo_type VARCHAR(50),
    quantity_sold_before_promo INT,
    quantity_sold_after_promo INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

