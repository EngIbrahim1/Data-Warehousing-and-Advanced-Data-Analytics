/*
===============================================================================
Store Performance Report
===============================================================================
Purpose:
    - To aggregate key metrics for each store.
    - Calculates total quantities sold before and after promotions.
    - Computes net uplift and segments stores by uplift performance.
    
Tables Used:
    - fact_events (columns: event_id, store_key, quantity_sold_before_promo, quantity_sold_after_promo)
    - dim_stores (columns: store_key, city)
    
SQL Functions Used:
    - COUNT(), SUM()
    - CASE for segmentation
===============================================================================
*/

IF OBJECT_ID('gold.report_stores', 'V') IS NOT NULL
    DROP VIEW gold.report_stores;
GO

CREATE VIEW gold.report_stores AS

WITH base AS (
    SELECT 
         f.event_id,
         f.store_key,
         f.quantity_sold_before_promo,
         f.quantity_sold_after_promo,
         s.city
    FROM gold.fact_events f
    JOIN gold.dim_stores s
         ON f.store_key = s.store_key
),

store_agg AS (
    SELECT
         store_key,
         city,
         COUNT(event_id) AS total_events,
         SUM(quantity_sold_before_promo) AS total_before,
         SUM(quantity_sold_after_promo) AS total_after,
         SUM(quantity_sold_after_promo) - SUM(quantity_sold_before_promo) AS net_uplift
    FROM base
    GROUP BY store_key, city
)

SELECT
    store_key,
    city,
    total_events,
    total_before,
    total_after,
    net_uplift,
    CASE 
         WHEN net_uplift > 0 THEN 'Positive Uplift'
         ELSE 'No/Negative Uplift'
    END AS performance_segment
FROM store_agg;
GO
