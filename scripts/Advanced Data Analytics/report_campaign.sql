/*
===============================================================================
Campaign Effectiveness Report
===============================================================================
Purpose:
    - To analyze the performance of each campaign.
    - Aggregates total sales quantities before and after promotions.
    - Computes the net uplift and an average daily uplift rate based on campaign duration.
    
Tables Used:
    - fact_events (columns: event_id, campaign_key, quantity_sold_before_promo, quantity_sold_after_promo)
    - dim_campaigns (columns: campaign_key, campaign_name, start_date, end_date)
    
SQL Functions Used:
    - COUNT(), SUM(), DATEDIFF()
    - CASE for conditional calculations
===============================================================================
*/

IF OBJECT_ID('gold.report_campaigns', 'V') IS NOT NULL
    DROP VIEW gold.report_campaigns;
GO

CREATE VIEW gold.report_campaigns AS

WITH base AS (
    SELECT 
         f.event_id,
         f.campaign_key,
         f.quantity_sold_before_promo,
         f.quantity_sold_after_promo,
         c.campaign_name,
         c.start_date,
         c.end_date
    FROM gold.fact_events f
    JOIN gold.dim_campaigns c
        ON f.campaign_key = c.campaign_key
    WHERE c.start_date IS NOT NULL 
      AND c.end_date IS NOT NULL
),

campaign_agg AS (
    SELECT 
         campaign_key,
         campaign_name,
         start_date,
         end_date,
         COUNT(event_id) AS total_events,
         SUM(quantity_sold_before_promo) AS total_before,
         SUM(quantity_sold_after_promo) AS total_after,
         SUM(quantity_sold_after_promo) - SUM(quantity_sold_before_promo) AS net_uplift,
         DATEDIFF(DAY, start_date, end_date) AS campaign_duration_days
    FROM base
    GROUP BY campaign_key, campaign_name, start_date, end_date
)

SELECT
    campaign_key,
    campaign_name,
    start_date,
    end_date,
    campaign_duration_days,
    total_events,
    total_before,
    total_after,
    net_uplift,
    CASE 
         WHEN campaign_duration_days = 0 THEN net_uplift
         ELSE CAST(net_uplift AS FLOAT) / campaign_duration_days
    END AS daily_uplift_rate
FROM campaign_agg;
GO
