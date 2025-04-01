/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		-- Loading silver_dim_campaigns
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver_dim_campaigns';
		TRUNCATE TABLE silver_dim_campaigns;
		PRINT '>> Inserting Data Into: silver_dim_campaigns';
		INSERT INTO silver_dim_campaigns 
        (
            campaign_id, 
            campaign_name, 
            start_date, 
            end_date
        )
        SELECT
            campaign_id,
            LTRIM(RTRIM(campaign_name)),
            TRY_CONVERT(DATE, start_date, 105),
            TRY_CONVERT(DATE, end_date, 105)
        FROM 
            bronze_dim_campaigns
        WHERE
            TRY_CONVERT(DATE, start_date, 105) IS NOT NULL
            AND TRY_CONVERT(DATE, end_date, 105) IS NOT NULL;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver_dim_products
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver_dim_products';
		TRUNCATE TABLE silver_dim_products;
		PRINT '>> Inserting Data Into: silver_dim_products';
        INSERT INTO silver_dim_products (product_code, product_name, category)
        SELECT
            TRIM(product_code),
            TRIM(product_name),
            TRIM(category)
        FROM bronze_dim_products
        WHERE product_code IS NOT NULL AND product_name IS NOT NULL;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading silver_dim_stores
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver_dim_stores';
		TRUNCATE TABLE silver_dim_stores;
		PRINT '>> Inserting Data Into: silver_dim_stores';
		
        INSERT INTO silver_dim_stores(store_id, city)
        SELECT
            TRIM(store_id),
            TRIM(city)
        FROM bronze_dim_stores
        WHERE store_id IS NOT NULL;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading silver_fact_events
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver_fact_events';
		TRUNCATE TABLE silver_fact_events;
		PRINT '>> Inserting Data Into: silver_fact_events';
		
        INSERT INTO silver_fact_events (
            event_id, store_id, campaign_id, product_code,
            base_price, promo_type, quantity_sold_before_promo, quantity_sold_after_promo
        )
        SELECT
            event_id,
            TRIM(store_id),
            campaign_id,
            TRIM(product_code),
            base_price,
            TRIM(promo_type),
            quantity_sold_before_promo,
            quantity_sold_after_promo
        FROM bronze_fact_events
        WHERE base_price >= 0
        AND quantity_sold_before_promo >= 0
        AND quantity_sold_after_promo >= 0;

	    SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';


		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END

EXEC silver.load_silver