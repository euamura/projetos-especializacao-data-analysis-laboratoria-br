-- =============================================================================
-- Amazon Sales — Queries BigQuery
-- Projeto: amazon-sales-lab-proj4 | Dataset: amazon_sales / Amazon
-- =============================================================================


-- =============================================================================
-- 1. PROCESSAR E PREPARAR A BASE DE DADOS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1.2 Identificar e tratar valores nulos
-- -----------------------------------------------------------------------------

-- Visualizar tabelas originais
SELECT * FROM `amazon_sales.amazon_product`;
SELECT * FROM `amazon_sales.amazon_review`;

-- Contagem de nulos — amazon_product
WITH product_nulls AS (
  SELECT
    SUM(CASE WHEN product_id          IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN product_name        IS NULL THEN 1 ELSE 0 END) AS product_name_nulls,
    SUM(CASE WHEN category            IS NULL THEN 1 ELSE 0 END) AS category_nulls,
    SUM(CASE WHEN discounted_price    IS NULL THEN 1 ELSE 0 END) AS discounted_price_nulls,
    SUM(CASE WHEN actual_price        IS NULL THEN 1 ELSE 0 END) AS actual_price_nulls,
    SUM(CASE WHEN discount_percentage IS NULL THEN 1 ELSE 0 END) AS discount_percentage_nulls,
    SUM(CASE WHEN about_product       IS NULL THEN 1 ELSE 0 END) AS about_product_nulls
  FROM `amazon_sales.amazon_product`
)
SELECT * FROM product_nulls;

-- Contagem de nulos — amazon_review
WITH review_nulls AS (
  SELECT
    SUM(CASE WHEN user_id        IS NULL THEN 1 ELSE 0 END) AS user_id_nulls,
    SUM(CASE WHEN user_name      IS NULL THEN 1 ELSE 0 END) AS user_name_nulls,
    SUM(CASE WHEN review_id      IS NULL THEN 1 ELSE 0 END) AS review_id_nulls,
    SUM(CASE WHEN review_title   IS NULL THEN 1 ELSE 0 END) AS review_title_nulls,
    SUM(CASE WHEN review_content IS NULL THEN 1 ELSE 0 END) AS review_content_nulls,
    SUM(CASE WHEN img_link       IS NULL THEN 1 ELSE 0 END) AS img_link_nulls,
    SUM(CASE WHEN product_link   IS NULL THEN 1 ELSE 0 END) AS product_link_nulls,
    SUM(CASE WHEN product_id     IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN rating         IS NULL THEN 1 ELSE 0 END) AS rating_nulls,
    SUM(CASE WHEN rating_count   IS NULL THEN 1 ELSE 0 END) AS rating_count_nulls
  FROM `amazon_sales.amazon_review`
)
SELECT * FROM review_nulls;

-- Verificar linhas com rating_count nulo
SELECT *
FROM `amazon_sales.amazon_review_clean`
WHERE rating_count IS NULL;

-- Remover linhas com rating_count nulo e atualizar tabela
CREATE OR REPLACE TABLE `amazon_sales.amazon_review_clean` AS (
  SELECT *
  FROM `amazon_sales.amazon_review_clean`
  WHERE rating_count IS NOT NULL
);


-- -----------------------------------------------------------------------------
-- 1.3 Identificar e tratar valores duplicados
-- -----------------------------------------------------------------------------

-- Identificar duplicados — amazon_review
WITH review_duplicates AS (
  SELECT
    r.*,
    ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY review_id) AS row_num
  FROM `amazon_sales.amazon_review` AS r
)
SELECT *
FROM review_duplicates
WHERE row_num = 1;

-- Identificar duplicados — amazon_product
WITH product_duplicates AS (
  SELECT
    r.*,
    ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) AS row_num
  FROM `amazon_sales.amazon_product` AS r
)
SELECT *
FROM product_duplicates
WHERE row_num = 1;


-- -----------------------------------------------------------------------------
-- 1.5 Identificar e tratar dados discrepantes em variáveis categóricas
-- -----------------------------------------------------------------------------

-- Verificar range de rating
SELECT
  MIN(rating) AS min_rating,
  MAX(rating) AS max_rating
FROM `amazon_sales.amazon_review_clean`;

-- Identificar linha com dado discrepante (rating = '|')
SELECT *
FROM `amazon_sales.amazon_review`
WHERE rating = '|';

-- Consultar tabela sem o dado discrepante
SELECT *
FROM `amazon_sales.amazon_review_clean`
WHERE rating != '|';

-- Remover linha com dado discrepante e atualizar tabela
CREATE OR REPLACE TABLE `amazon_sales.amazon_review_clean` AS
  SELECT *
  FROM `amazon_sales.amazon_review_clean`
  WHERE rating != '|';


-- -----------------------------------------------------------------------------
-- 1.6 Identificar dados discrepantes em variáveis numéricas
-- -----------------------------------------------------------------------------

SELECT
  MAX(discounted_price),
  MIN(discounted_price),
  AVG(discounted_price)
FROM `projeto-4-caso-consultoria.Amazon.amazon_product`;

SELECT
  MAX(actual_price),
  MIN(actual_price),
  AVG(actual_price)
FROM `projeto-4-caso-consultoria.Amazon.amazon_product`;

SELECT
  MAX(discount_percentage),
  MIN(discount_percentage),
  AVG(discount_percentage)
FROM `projeto-4-caso-consultoria.Amazon.amazon_product`;

SELECT
  MAX(rating_count),
  MIN(rating_count),
  AVG(rating_count)
FROM `projeto-4-caso-consultoria.Amazon.amazon_review`;

SELECT
  MAX(rating),
  MIN(rating),
  AVG(rating)
FROM `projeto-4-caso-consultoria.Amazon.amazon_review`;


-- -----------------------------------------------------------------------------
-- 1.7 Verificar e alterar o tipo de dados
-- -----------------------------------------------------------------------------

-- Teste: converter rating de STRING para FLOAT64
WITH test AS (
  SELECT
    * EXCEPT(rating, row_num),
    CAST(rating AS FLOAT64) AS rating
  FROM `amazon_sales.amazon_review_clean`
)
SELECT * FROM test;

-- Atualizar tabela com o tipo corrigido
CREATE OR REPLACE TABLE `amazon_sales.amazon_review_clean` AS (
  SELECT
    * EXCEPT(rating, row_num),
    CAST(rating AS FLOAT64) AS rating
  FROM `amazon_sales.amazon_review_clean`
);


-- -----------------------------------------------------------------------------
-- 1.8 Criar novas variáveis
-- -----------------------------------------------------------------------------

-- Teste: extrair main_category e sub_category a partir da coluna category
WITH category_array AS (
  SELECT
    * EXCEPT(row_num),
    SPLIT(category, '|')[OFFSET(0)] AS main_category,
    SPLIT(category, '|')[OFFSET(1)] AS sub_category
  FROM `amazon_sales.amazon_product_clean`
)
SELECT * FROM category_array;

-- Atualizar tabela com as novas colunas
CREATE OR REPLACE TABLE `amazon_sales.amazon_product_clean` AS (
  SELECT
    * EXCEPT(row_num),
    SPLIT(category, '|')[OFFSET(0)] AS main_category,
    SPLIT(category, '|')[OFFSET(1)] AS sub_category
  FROM `amazon_sales.amazon_product_clean`
);

-- Limpeza de texto: espaços antes de maiúsculas, ao redor de & e após vírgula
WITH limpeza_textos AS (
  SELECT
    * EXCEPT(sub_category, main_category),
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        REGEXP_REPLACE(sub_category, r'([a-z])([A-Z])', r'\1 \2'),
        r'\s*&\s*', r' & '
      ),
      r',', r', '
    ) AS sub_category,
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        REGEXP_REPLACE(main_category, r'([a-z])([A-Z])', r'\1 \2'),
        r'\s*&\s*', r' & '
      ),
      r',', r', '
    ) AS main_category
  FROM `amazon_sales.amazon_product_clean`
)
SELECT * FROM limpeza_textos;

-- Atualizar tabela com texto limpo
CREATE OR REPLACE TABLE `amazon_sales.amazon_product_clean` AS (
  SELECT
    * EXCEPT(sub_category, main_category),
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        REGEXP_REPLACE(sub_category, r'([a-z])([A-Z])', r'\1 \2'),
        r'\s*&\s*', r' & '
      ),
      r',', r', '
    ) AS sub_category,
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        REGEXP_REPLACE(main_category, r'([a-z])([A-Z])', r'\1 \2'),
        r'\s*&\s*', r' & '
      ),
      r',', r', '
    ) AS main_category
  FROM `amazon_sales.amazon_product_clean`
);


-- -----------------------------------------------------------------------------
-- 1.9 Unir tabelas
-- -----------------------------------------------------------------------------

-- Visualizar tabelas limpas
SELECT * FROM `amazon_sales.amazon_review_clean`;
SELECT * FROM `amazon_sales.amazon_product_clean`;

-- Unir tabelas e remover duplicatas da união
WITH unida AS (
  SELECT
    p.product_id,
    p.main_category,
    p.sub_category,
    p.actual_price,
    p.discount_percentage,
    r.user_id,
    r.review_id,
    r.rating,
    r.rating_count
  FROM `amazon_sales.amazon_product_clean` AS p
  LEFT JOIN `amazon_sales.amazon_review_clean` AS r ON p.product_id = r.product_id
),
tratados AS (
  SELECT
    * EXCEPT(rating, rating_count),
    COALESCE(rating, 0)       AS rating,
    COALESCE(rating_count, 0) AS rating_count,
    ROW_NUMBER() OVER (PARTITION BY product_id) AS rownum
  FROM unida
)
SELECT * EXCEPT(rownum)
FROM tratados
WHERE rownum = 1;


-- =============================================================================
-- 2. ANÁLISE EXPLORATÓRIA
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 2.1 Calcular correlação entre variáveis
-- -----------------------------------------------------------------------------

SELECT * FROM `amazon_sales.amazon_principal`;

SELECT
  CORR(actual_price,        rating)            AS corr_price_rating,
  CORR(actual_price,        rating_count)      AS corr_price_rating_count,
  CORR(discount_percentage, rating)            AS corr_discount_rating,
  CORR(discount_percentage, rating_count)      AS corr_discount_rating_count,
  CORR(rating,              rating_count)      AS corr_rating_rating_count
FROM `amazon_sales.amazon_principal`;


-- -----------------------------------------------------------------------------
-- 2.2 Calcular quintis
-- -----------------------------------------------------------------------------

CREATE OR REPLACE TABLE `amazon_sales.amazon_principal` AS (
  WITH quintis AS (
    SELECT
      *,
      NTILE(5) OVER (ORDER BY rating)            AS rating_ntile,
      NTILE(5) OVER (ORDER BY rating_count)      AS rating_count_ntile,
      NTILE(5) OVER (ORDER BY actual_price)      AS actual_price_ntile,
      NTILE(5) OVER (ORDER BY discount_percentage) AS discount_percentage_ntile
    FROM `amazon_sales.amazon_principal`
  )
  SELECT * FROM quintis
);


-- =============================================================================
-- 3. TÉCNICAS DE ANÁLISE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.2 Segmentação — faixas de avaliação e average_quintile
-- -----------------------------------------------------------------------------

-- Teste: criar coluna com faixa de avaliação (rating_range)
WITH CategorizedRatings AS (
  SELECT
    product_id,
    product_name,
    category,
    discounted_price,
    actual_price,
    discount_percentage,
    about_product,
    main_category,
    sub_category,
    user_id,
    user_name,
    review_id,
    review_title,
    review_content,
    rating_count,
    rating,
    rating_quintile,
    rating_count_quintile,
    actual_price_quintile,
    discount_percentage_quintile,
    CASE
      WHEN rating = 0              THEN '0'
      WHEN rating >= 0 AND rating < 1 THEN '0-1'
      WHEN rating >= 1 AND rating < 2 THEN '1-2'
      WHEN rating >= 2 AND rating < 3 THEN '2-3'
      WHEN rating >= 3 AND rating < 4 THEN '3-4'
      WHEN rating >= 4 AND rating < 5 THEN '4-5'
      WHEN rating = 5              THEN '5'
    END AS rating_range
  FROM `projeto-4-caso-consultoria.Amazon.uniao_tabelas`
)
SELECT *
FROM CategorizedRatings
ORDER BY main_category, rating_range;

-- Atualizar tabela com rating_range
CREATE OR REPLACE TABLE `projeto-4-caso-consultoria.Amazon.uniao_tabelas` AS
WITH CategorizedRatings AS (
  SELECT
    product_id,
    product_name,
    category,
    discounted_price,
    actual_price,
    discount_percentage,
    about_product,
    main_category,
    sub_category,
    user_id,
    user_name,
    review_id,
    review_title,
    review_content,
    rating_count,
    rating,
    rating_quintile,
    rating_count_quintile,
    actual_price_quintile,
    discount_percentage_quintile,
    CASE
      WHEN rating = 0              THEN '0'
      WHEN rating >= 0 AND rating < 1 THEN '0-1'
      WHEN rating >= 1 AND rating < 2 THEN '1-2'
      WHEN rating >= 2 AND rating < 3 THEN '2-3'
      WHEN rating >= 3 AND rating < 4 THEN '3-4'
      WHEN rating >= 4 AND rating < 5 THEN '4-5'
      WHEN rating = 5              THEN '5'
    END AS rating_range
  FROM `projeto-4-caso-consultoria.Amazon.uniao_tabelas`
)
SELECT *
FROM CategorizedRatings
ORDER BY main_category, rating_range;

-- Teste: calcular average_quintile (média dos 4 quintis)
WITH Quintile AS (
  SELECT
    product_id,
    product_name,
    category,
    discounted_price,
    actual_price,
    discount_percentage,
    about_product,
    main_category,
    sub_category,
    user_id,
    user_name,
    review_id,
    review_title,
    review_content,
    rating_count,
    rating,
    rating_quintile,
    rating_count_quintile,
    actual_price_quintile,
    discount_percentage_quintile,
    rating_range,
    ROUND(
      (rating_quintile + rating_count_quintile + actual_price_quintile + discount_percentage_quintile) / 4.0
    ) AS average_quintile
  FROM `projeto-4-caso-consultoria.Amazon.uniao_tabelas`
)
SELECT * FROM Quintile;

-- Atualizar tabela com average_quintile
CREATE OR REPLACE TABLE `projeto-4-caso-consultoria.Amazon.uniao_tabelas` AS
WITH Quintile AS (
  SELECT
    product_id,
    product_name,
    category,
    discounted_price,
    actual_price,
    discount_percentage,
    about_product,
    main_category,
    sub_category,
    user_id,
    user_name,
    review_id,
    review_title,
    review_content,
    rating_count,
    rating,
    rating_quintile,
    rating_count_quintile,
    actual_price_quintile,
    discount_percentage_quintile,
    rating_range,
    ROUND(
      (rating_quintile + rating_count_quintile + actual_price_quintile + discount_percentage_quintile) / 4.0
    ) AS average_quintile
  FROM `projeto-4-caso-consultoria.Amazon.uniao_tabelas`
)
SELECT * FROM Quintile;
