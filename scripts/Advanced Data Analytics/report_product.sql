/*
===============================================================================
Product Performance Report
===============================================================================
Purpose:
    - To consolidate product-level sales performance.
    - Aggregates the quantities sold before and after promotions.
    - Computes net uplift and segments products based on the sales uplift.
    
Tables Used:
    - fact_events (columns: event_id, product_key, quantity_sold_before_promo, quantity_sold_after_promo)
    - dim_products (columns: product_key, product_name, category)
    
SQL Functions Used:
    - COUNT(), SUM()
    - CASE for conditional segmentation
===============================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base AS (
    SELECT
         f.event_id,
         f.product_key,
         f.quantity_sold_before_promo,
         f.quantity_sold_after_promo,
         p.product_name,
         p.category
    FROM gold.fact_events f
    JOIN gold.dim_products p
         ON f.product_key = p.product_key
),

product_agg AS (
    SELECT
         product_key,
         product_name,
         category,
         COUNT(event_id) AS total_events,
         SUM(quantity_sold_before_promo) AS total_before,
         SUM(quantity_sold_after_promo) AS total_after,
         SUM(quantity_sold_after_promo) - SUM(quantity_sold_before_promo) AS net_uplift
    FROM base
    GROUP BY product_key, product_name, category
)

SELECT
    product_key,
    product_name,
    category,
    total_events,
    total_before,
    total_after,
    net_uplift,
    CASE 
         WHEN net_uplift > 0 THEN 'Positive Uplift'
         ELSE 'No/Negative Uplift'
    END AS performance_segment
FROM product_agg;
GO
