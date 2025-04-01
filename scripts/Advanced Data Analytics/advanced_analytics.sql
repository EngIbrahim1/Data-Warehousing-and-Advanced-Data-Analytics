/*
===============================================================================
Campaign Uplift Analysis
===============================================================================
Purpose:
    - To evaluate the performance of each campaign by comparing sales before and after the promotion.
    - To calculate the uplift in units sold for each campaign.
    
SQL Functions Used:
    - SUM(): Aggregates total units sold before and after promotion.
    - Arithmetic Operations: Computes the difference (uplift).
    - JOIN: Combines campaign details with event sales.
    - GROUP BY, ORDER BY: Groups data by campaign and sorts by uplift.
===============================================================================
*/
SELECT 
    c.campaign_name,
    SUM(f.quantity_sold_before_promo) AS qty_before,
    SUM(f.quantity_sold_after_promo) AS qty_after,
    SUM(f.quantity_sold_after_promo) - SUM(f.quantity_sold_before_promo) AS uplift
FROM gold.fact_events f
JOIN gold.dim_campaigns c ON f.campaign_key = c.campaign_key
GROUP BY c.campaign_name
ORDER BY uplift DESC;


/*
===============================================================================
Cumulative Sales Analysis
===============================================================================
Purpose:
    - To track the running total of sales for each product over the sequence of events.
    - Useful for identifying trends and growth in sales over time for each product.
    
SQL Functions Used:
    - Window Function: SUM() OVER() to calculate cumulative totals.
    - PARTITION BY: Segments the data per product.
    - ORDER BY: Orders events to maintain the cumulative logic.
===============================================================================
*/
SELECT 
    p.product_name,
    SUM(f.quantity_sold_after_promo) OVER (PARTITION BY p.product_name ORDER BY f.event_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales
FROM gold.fact_events f
JOIN gold.dim_products p ON f.product_key = p.product_key;


/*
===============================================================================
Product Uplift Percentage Analysis
===============================================================================
Purpose:
    - To calculate and rank products based on the percentage increase in sales due to promotions.
    - Provides a relative measure of promotional effectiveness for each product.
    
SQL Functions Used:
    - SUM(): Aggregates sales before and after promotion.
    - ROUND(): Rounds the computed uplift percentage.
    - NULLIF(): Prevents division by zero.
    - GROUP BY, ORDER BY: Groups data by product and sorts by uplift percentage.
===============================================================================
*/
SELECT 
    p.product_name,
    SUM(f.quantity_sold_before_promo) AS before,
    SUM(f.quantity_sold_after_promo) AS after,
    ROUND(
        (SUM(f.quantity_sold_after_promo) - SUM(f.quantity_sold_before_promo)) * 100.0 
        / NULLIF(SUM(f.quantity_sold_before_promo), 0), 2
    ) AS uplift_percentage
FROM gold.fact_events f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY uplift_percentage DESC;


/*
===============================================================================
Part-to-Whole Sales Contribution Analysis
===============================================================================
Purpose:
    - To determine each product's contribution to the total post-promotion sales.
    - Helps identify key products driving the overall sales figures.
    
SQL Functions Used:
    - SUM(): Aggregates total sales.
    - Window Function: SUM() OVER() calculates the overall total.
    - ROUND(): Rounds the percentage to two decimal places.
    - GROUP BY, ORDER BY: Groups data by product and sorts by percentage contribution.
===============================================================================
*/
SELECT 
    p.product_name,
    SUM(f.quantity_sold_after_promo) AS total_sold,
    ROUND(
        100.0 * SUM(f.quantity_sold_after_promo) / SUM(SUM(f.quantity_sold_after_promo)) OVER (), 2
    ) AS percentage_of_total
FROM gold.fact_events f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY percentage_of_total DESC;


/*
===============================================================================
Data Segmentation Analysis: Category-Level Sales Metrics
===============================================================================
Purpose:
    - To analyze sales performance by product category.
    - Provides insights on the total number of events, total units sold, and average units sold per event within each category.
    
SQL Functions Used:
    - COUNT(DISTINCT): Counts unique events.
    - SUM(): Aggregates total units sold.
    - AVG(): Computes the average sales per event.
    - ROUND(): Rounds the average for better readability.
    - GROUP BY, ORDER BY: Groups data by category and sorts by total units sold.
===============================================================================
*/
SELECT 
    p.category,
    COUNT(DISTINCT f.event_id) AS total_events,
    SUM(f.quantity_sold_after_promo) AS total_units_sold,
    ROUND(AVG(f.quantity_sold_after_promo), 2) AS avg_per_event
FROM gold.fact_events f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_units_sold DESC;
