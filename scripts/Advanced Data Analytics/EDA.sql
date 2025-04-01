/*
===============================================================================
Row Counts Exploration
===============================================================================
Purpose:
    - To assess the volume of records in key fact and dimension tables.
    - Provides quick insight into the overall scale of events, products, stores, and campaigns.
    
SQL Functions Used:
    - COUNT()
===============================================================================
*/
SELECT COUNT(*) AS total_events FROM gold.fact_events;
SELECT COUNT(*) AS total_products FROM gold.dim_products;
SELECT COUNT(*) AS total_stores FROM gold.dim_stores;
SELECT COUNT(*) AS total_campaigns FROM gold.dim_campaigns;


/*
===============================================================================
Unique Dimension Values Analysis
===============================================================================
Purpose:
    - To explore the diversity within key dimensions.
    - Retrieves distinct product categories and store cities.
    - Counts the number of unique promotional types recorded in the events.
    
SQL Functions Used:
    - DISTINCT, COUNT(DISTINCT)
===============================================================================
*/
SELECT DISTINCT category FROM gold.dim_products;
SELECT DISTINCT city FROM gold.dim_stores;
SELECT COUNT(DISTINCT promo_type) AS unique_promo_types FROM gold.fact_events;


/*
===============================================================================
Campaign Date Range Analysis
===============================================================================
Purpose:
    - To determine the time span covered by promotional campaigns.
    - Identifies the earliest start date and the latest end date among all campaigns.
    
SQL Functions Used:
    - MIN(), MAX()
===============================================================================
*/
SELECT 
    MIN(start_date) AS earliest_campaign,
    MAX(end_date) AS latest_campaign
FROM gold.dim_campaigns;


/*
===============================================================================
Sales Uplift Analysis
===============================================================================
Purpose:
    - To compare overall sales performance before and after promotional activities.
    - Aggregates the quantity sold before and after promotions.
    - Computes the uplift in sales resulting from the promotional events.
    
SQL Functions Used:
    - SUM(), Arithmetic Operations
===============================================================================
*/
SELECT 
    SUM(quantity_sold_before_promo) AS total_before,
    SUM(quantity_sold_after_promo) AS total_after,
    SUM(quantity_sold_after_promo) - SUM(quantity_sold_before_promo) AS total_uplift
FROM gold.fact_events;


/*
===============================================================================
Top Products and Cities by Post-Promotion Sales (Ranking Analysis)
===============================================================================
Purpose:
    - To identify the best-performing products and cities based on post-promotion sales.
    - Uses aggregation and ranking functions to pinpoint the top 5 in each category.
    - Provides insight into which products and geographic locations drive the highest post-promo sales.
    
SQL Functions Used:
    - JOIN, GROUP BY, ORDER BY, TOP, SUM()
===============================================================================
*/
SELECT TOP 5 p.product_name, SUM(f.quantity_sold_after_promo) AS total_sold
FROM gold.fact_events f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sold DESC;

SELECT TOP 5 s.city, SUM(f.quantity_sold_after_promo) AS total_sold
FROM gold.fact_events f
JOIN gold.dim_stores s ON f.store_key = s.store_key
GROUP BY s.city
ORDER BY total_sold DESC;
