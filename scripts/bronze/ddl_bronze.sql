/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

/* Campaigns Table in Bronze Layer*/
IF OBJECT_ID('bronze_dim_campaigns', 'U') IS NOT NULL
    DROP TABLE bronze_dim_campaigns;
GO

CREATE TABLE bronze_dim_campaigns (
    campaign_id VARCHAR(20),
    campaign_name VARCHAR(255),
    start_date DATE, 
    end_date DATE
);
GO

/* Products Table in Bronze Layer*/
IF OBJECT_ID('bronze_dim_products', 'U') IS NOT NULL
    DROP TABLE bronze_dim_products;
GO

CREATE TABLE bronze_dim_products (
    product_code VARCHAR(50),
    product_name VARCHAR(255),
    category VARCHAR(255)
);
GO

/* Stores Table in Bronze Layer*/
IF OBJECT_ID('bronze_dim_stores', 'U') IS NOT NULL
    DROP TABLE bronze_dim_stores;
GO

CREATE TABLE bronze_dim_stores (
    store_id VARCHAR(50),
    city VARCHAR(100)
);
GO

/* Fact Events Table in Bronze Layer*/
IF OBJECT_ID('bronze_fact_events', 'U') IS NOT NULL
    DROP TABLE bronze_fact_events;
GO

CREATE TABLE bronze_fact_events (
    event_id VARCHAR(10),
    store_id VARCHAR(10),
    campaign_id VARCHAR(20),
    product_code VARCHAR(10),
    base_price INT,
    promo_type VARCHAR(50),
    quantity_sold_before_promo INT,
    quantity_sold_after_promo INT
);
GO
