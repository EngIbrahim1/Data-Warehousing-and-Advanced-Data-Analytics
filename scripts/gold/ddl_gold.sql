/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_code) AS product_key, -- Surrogate key
    product_code,
    product_name,
    category
FROM silver_dim_products;
GO


-- =============================================================================
-- Create Dimension: gold.dim_stores
-- =============================================================================
IF OBJECT_ID('gold.dim_stores', 'V') IS NOT NULL
    DROP VIEW gold.dim_stores;
GO

CREATE VIEW gold.dim_stores AS
SELECT
    ROW_NUMBER() OVER (ORDER BY store_id) AS store_key, -- Surrogate key
    store_id,
    city
FROM silver_dim_stores;
GO


-- =============================================================================
-- Create Fact Table: gold.dim_campaigns
-- =============================================================================
IF OBJECT_ID('gold.dim_campaigns', 'V') IS NOT NULL
    DROP VIEW gold.dim_campaigns;
GO

CREATE VIEW gold.dim_campaigns AS
SELECT
    ROW_NUMBER() OVER (ORDER BY campaign_id) AS campaign_key, -- Surrogate key
    campaign_id,
    campaign_name,
    start_date,
    end_date
FROM silver_dim_campaigns;
GO


-- =============================================================================
-- Create Fact Table: gold.fact_events
-- =============================================================================
IF OBJECT_ID('gold.fact_events', 'V') IS NOT NULL
    DROP VIEW gold.fact_events;
GO

CREATE VIEW gold.fact_events AS
SELECT
    fe.event_id,
    dp.product_key,
    ds.store_key,
    dc.campaign_key,
    fe.base_price,
    fe.promo_type,
    fe.quantity_sold_before_promo,
    fe.quantity_sold_after_promo
FROM silver_fact_events fe
LEFT JOIN gold.dim_products dp
    ON fe.product_code = dp.product_code
LEFT JOIN gold.dim_stores ds
    ON fe.store_id = ds.store_id
LEFT JOIN gold.dim_campaigns dc
    ON fe.campaign_id = dc.campaign_id;
GO

