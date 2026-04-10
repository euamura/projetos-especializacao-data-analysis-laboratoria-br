-- Identificar nulos
    
    ```sql
    -- visualizando tabela
    SELECT *
    FROM `super_store_etl.superstore`;
    -- criando CTE de contagem de nulos
    WITH nullos AS(
    	SELECT
    	  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_nulls,
    	  SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    		SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    		SUM(CASE WHEN customer_ID IS NULL THEN 1 ELSE 0 END) AS costumerid_nulls,
    		SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_name_nulls,
    		SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS discount_nulls,
    		SUM(CASE WHEN market IS NULL THEN 1 ELSE 0 END) AS market_nulls,
    		SUM(CASE WHEN unknown IS NULL THEN 1 ELSE 0 END) AS unknown_nulls,
    		SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
    		SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    		SUM(CASE WHEN order_priority IS NULL THEN 1 ELSE 0 END) AS order_priority_nulls,
    		SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    		SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS product_name_nulls,
    		SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS profit_nulls,
    		SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
    		SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS region_nulls,
    		SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) AS row_id_nulls,
    		SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS sales_nulls,
    		SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS segment_nulls,
    		SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS ship_date_nulls,
    		SUM(CASE WHEN ship_mode IS NULL THEN 1 ELSE 0 END) AS ship_mode_nulls,
    		SUM(CASE WHEN shipping_cost IS NULL THEN 1 ELSE 0 END) AS shipping_cost_nulls,
    		SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS state_nulls,
    		SUM(CASE WHEN sub_category IS NULL THEN 1 ELSE 0 END) AS sub_category_nulls,
    		SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_nulls,
    		SUM(CASE WHEN market2 IS NULL THEN 1 ELSE 0 END) AS market2_nulls,
    		SUM(CASE WHEN weeknum IS NULL THEN 1 ELSE 0 END) AS weeknum_nulls
    	FROM `super_store_etl.superstore`
    )
    -- visualizando tabela de contagem de nulos
    SELECT * FROM nullos;
    ```
    
-- Identificar duplicados
    
    ```sql
    -- visualizando tabela
    SELECT *
    FROM `super_store_etl.superstore`;
    
    ----criar tabela temporaria com contagem para identificar duplicados
    WITH duplicate_cte AS (
      SELECT
        product_id,
        order_id,
        COUNT(*) AS numero_ocorrencias
      FROM
        `super_store_etl.superstore`
      GROUP BY
        product_id,
        order_id
      HAVING 
      COUNT(*) > 1
    )
    
    SELECT * FROM duplicate_cte
    
    ----criar tabela temporaria com contagem para identificar duplicados usando chave primária
    WITH duplicate_cte AS (
      SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY order_id,costumer_ID ORDER BY order_id) AS row_num
      FROM `super_store_etl.superstore`
    )
    SELECT
      *
    FROM
      duplicate_cte
    WHERE
      row_num = 1;
    
    SELECT * 
    FROM `super_store_etl.superstore`
    WHERE order_id ='AO-2011-7110'
    ```
    
-- Tratamento de variáveis
    
    ```sql
    -- consulta variaveis categoricas
    SELECT *
    FROM `super_store_etl.super_store` AS superstore
    
    --category
    SELECT
      category, COUNT(*) AS freq_cat,
    FROM `super_store_etl.super_store`
    GROUP BY category 
    ORDER BY freq_cat ASC;
    
    --city
    SELECT
      country,
      city, COUNT(*) AS freq,
    FROM `super_store_etl.super_store`
    GROUP BY city, country
    ORDER BY freq DESC;
    
    -- sub_category
    SELECT
      category,
      sub_category,COUNT(*) AS freq
    FROM `super_store_etl.super_store`
    GROUP BY category, sub_category
    ORDER BY freq DESC;
    
    -- market
    SELECT
      market2, COUNT(*) AS freq,
    FROM `super_store_etl.super_store`
    GROUP BY market2
    ORDER BY freq DESC;
    
    -- market2
    SELECT
      market, COUNT(*) AS freq,
    FROM `super_store_etl.super_store`
    GROUP BY market
    ORDER BY freq DESC;
    
    -- ship_mode
    SELECT
      ship_mode, COUNT(*) AS freq,
    FROM `super_store_etl.superstore`
    GROUP BY ship_mode
    ORDER BY freq DESC;
    
    -- segment
    SELECT
      segment, COUNT(*) AS freq,
    FROM `super_store_etl.super_store`
    GROUP BY segment
    ORDER BY freq DESC;
    
    -- region
    SELECT
      region, COUNT(*) AS freq,
    FROM `super_store_etl.super_store`
    GROUP BY region
    ORDER BY freq DESC;
    
    -- order_priority
    SELECT
      order_priority, COUNT(*) AS freq,
    FROM `super_store_etl.super_store`
    GROUP BY order_priority
    ORDER BY freq DESC;
    
    ----- consulta variaveis numéricas
    SELECT
    --discount
    MIN(discount) AS discount_min,
    AVG(discount) AS discount_avg,
    MAX(discount) AS discount_max,
    --profit
    MIN(profit) AS profit_min,
    AVG(profit) AS profit_avg,
    MAX(profit) AS profit_max,
    --quantity
    MIN(quantity) AS quantity_min,
    AVG(quantity) AS quantity_avg,
    MAX(quantity) AS quantity_max,
    --sales
    MIN(sales) AS sales_min,
    AVG(sales) AS sales_avg,
    MAX(sales) AS salex_max,
    --shipping_cost
    MIN(shipping_cost) AS shipping_cost_min,
    AVG(shipping_cost) AS shipping_cost_avg,
    MAX(shipping_cost) AS shipping_cost_max,
    --weeknum
    MIN(weeknum) AS weeknum_min,
    AVG(weeknum) AS weeknum_avg,
    MAX(weeknum) AS weeknum_max
    FROM `super_store_etl.super_store`;
    
    ```
    
-- Criar tabelas
    
    ```sql
    -- criar tabelas de dimensão e fatos
    
    SELECT * FROM `super_store_etl.super_store`
    
    -- dim_local
    SELECT
     market2,
     market,
     region,
     country,
     state,
     city
    FROM `super_store_etl.super_store`
    
    ```
    
-- Remover duplicados

 ```sql
--------- dim_local
SELECT * FROM `super_store_etl.dim_local`


CREATE OR REPLACE TABLE `super_store_etl.dim_local` AS
 SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY market, market2, region, country, state, city ORDER BY market, market2, region, country, state, city) AS row_num
FROM `super_store_etl.dim_local`


CREATE OR REPLACE TABLE `super_store_etl.dim_local` AS
  SELECT
    * EXCEPT(row_num)
  FROM `super_store_etl.dim_local`


CREATE OR REPLACE TABLE `super_store_etl.dim_local` AS
  SELECT *, ROW_NUMBER() OVER (ORDER BY market, market2, region, country, state, city) AS local_id FROM `super_store_etl.dim_local`;



---- DIM_CUSTOMERS
SELECT
  customer_ID,
  customer_name,
  segment
FROM `super_store_etl.super_store`


CREATE OR REPLACE TABLE `super_store_etl.dim_customers` AS
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY customer_ID, customer_name ORDER BY customer_ID, customer_name) AS row_num 
FROM `super_store_etl.dim_customers`

CREATE OR REPLACE TABLE `super_store_etl.dim_customers` AS 
SELECT * FROM `super_store_etl.dim_customers`
WHERE row_num = 1 


----- DIM_PRODUCTS

SELECT
  product_id,
  product_name,
  category,
  sub_category
FROM `super_store_etl.super_store`



CREATE OR REPLACE TABLE `super_store_etl.dim_products` AS 
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) AS row_num
FROM `super_store_etl.dim_products`

CREATE OR REPLACE TABLE `super_store_etl.dim_products` AS
SELECT * EXCEPT(row_num) FROM `super_store_etl.dim_products`
WHERE row_num = 1

SELECT * FROM `super_store_etl.dim_products`


-------- FACT_ORDERS

SELECT
  ss.order_id,
  ss.order_priority,
  ss.order_date,
  ss.product_id,
  ss.customer_ID,
  ss.quantity,
  ss.discount,
  ss.profit,
  ss.row_id,
  ss.sales,
  ss.weeknum,
  ss.ship_date,
  ss.ship_mode,
  ss.shipping_cost,
  l.local_id
FROM `super_store_etl.super_store` ss
JOIN `super_store_etl.dim_local` l ON l.city = ss.city
 ```














