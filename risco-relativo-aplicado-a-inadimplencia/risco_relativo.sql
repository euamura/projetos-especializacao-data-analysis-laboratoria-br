-- =============================================================
-- Projeto: Risco Relativo aplicado à Inadimplência — Super Caja
-- Objetivo: Identificar perfis de inadimplência com base em
--           indicadores financeiros e comportamentais
-- Linguagem: SQL (Google BigQuery)
-- Autora: Amanda Mendonça
-- Bootcamp: Laboratória Brasil — Especialização em Data Analysis (2024)
-- =============================================================


-- =============================================================
-- 1. PROCESSAMENTO E PREPARAÇÃO DOS DADOS
-- =============================================================

-- Projeto BigQuery: risco-relativo-super-caja
-- Dataset: super_caja
-- Tabelas originais: default, loans_detail, loans_outstanding, user_info


-- ---------------------------------------------------------------
-- 1.1 Identificar e tratar valores nulos
-- ---------------------------------------------------------------

-- Verificar nulos: tabela default
SELECT *
FROM `super_caja.default`
WHERE user_id IS NULL AND default_flag IS NULL;
-- resultado: sem nulos

-- Verificar nulos: tabela loans_detail
SELECT *
FROM `super_caja.loans_detail`
WHERE user_id IS NULL
   OR more_90_days_overdue IS NULL
   OR using_lines_not_secured_personal_assets IS NULL
   OR number_times_delayed_payment_loan_30_59_days IS NULL
   OR debt_ratio IS NULL
   OR number_times_delayed_payment_loan_60_89_days IS NULL;
-- resultado: sem nulos

-- Verificar nulos: tabela loans_outstanding
SELECT *
FROM `super_caja.loans_outstanding`
WHERE loan_id IS NULL
   OR user_id IS NULL
   OR loan_type IS NULL;
-- resultado: sem nulos

-- Verificar nulos: tabela user_info
SELECT *
FROM `super_caja.user_info`
WHERE user_id IS NULL
   OR age IS NULL
   OR sex IS NULL
   OR last_month_salary IS NULL
   OR number_dependents IS NULL;
-- resultado: nulos em last_month_salary e number_dependents
-- obs: nulos em number_dependents tratados como 0 (sem dependentes)

-- Contar nulos em last_month_salary
SELECT COUNT(*) AS nulls_count
FROM `super_caja.user_info`
WHERE last_month_salary IS NULL;
-- resultado: 7.199 nulos

-- Tratar nulos com COALESCE (substituir por 0)
CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS (
  SELECT
    t.* EXCEPT (last_month_salary, number_dependents),
    COALESCE(number_dependents, 0) AS number_dependents,
    COALESCE(last_month_salary, 0) AS last_month_salary
  FROM `super_caja.super_caja_tabela_analise_completa` t
);

-- Verificar registros inadimplentes sem loan_id
SELECT
  t.user_id,
  t.loan_id,
  t.default_flag
FROM `super_caja.super_caja_tabela_analise_completa` AS t
WHERE loan_id IS NULL AND default_flag = 1;
-- resultado: 61 registros inadimplentes sem loan_id


-- ---------------------------------------------------------------
-- 1.2 Identificar e tratar valores duplicados
-- ---------------------------------------------------------------

-- Padrão utilizado: ROW_NUMBER() OVER (PARTITION BY) para identificar
-- e remover duplicatas, mantendo apenas a primeira ocorrência.

-- Tabela: default
CREATE OR REPLACE TABLE `super_caja.default` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_default
  FROM `super_caja.default`
)
SELECT * EXCEPT (row_num_default)
FROM tabela_temp
WHERE row_num_default = 1;

-- Tabela: loans_detail
CREATE OR REPLACE TABLE `super_caja.loans_detail` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_loans_detail
  FROM `super_caja.loans_detail`
)
SELECT * EXCEPT (row_num_loans_detail)
FROM tabela_temp
WHERE row_num_loans_detail = 1;

-- Tabela: loans_outstanding (por user_id)
CREATE OR REPLACE TABLE `super_caja.loans_outstanding` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_loans_outstanding
  FROM `super_caja.loans_outstanding`
)
SELECT * EXCEPT (row_num_loans_outstanding)
FROM tabela_temp
WHERE row_num_loans_outstanding = 1;

-- Tabela: loans_outstanding (por loan_id)
CREATE OR REPLACE TABLE `super_caja.loans_outstanding` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY loan_id ORDER BY loan_id) AS row_num_loan_id
  FROM `super_caja.loans_outstanding`
)
SELECT * EXCEPT (row_num_loan_id)
FROM tabela_temp
WHERE row_num_loan_id = 1;

-- Tabela: user_info
CREATE OR REPLACE TABLE `super_caja.user_info` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_user_info
  FROM `super_caja.user_info`
)
SELECT * EXCEPT (row_num_user_info)
FROM tabela_temp
WHERE row_num_user_info = 1;


-- ---------------------------------------------------------------
-- 1.3 Identificar e gerenciar dados fora do escopo
-- ---------------------------------------------------------------

-- Variável excluída: sex (fora do escopo de análise de risco)

-- Correlação entre more_90_days_overdue e atrasos de 30-59 dias
SELECT
  STDDEV_POP(more_90_days_overdue)                       AS dp_more_90_days_overdue,
  STDDEV_POP(number_times_delayed_payment_loan_30_59_days) AS dp_delayed_30_59,
  CORR(more_90_days_overdue, number_times_delayed_payment_loan_30_59_days) AS corr
FROM `super_caja.loans_detail`;
-- resultado: correlação de 0,98 → variável redundante

-- Correlação entre more_90_days_overdue e atrasos de 60-89 dias
SELECT
  STDDEV_POP(more_90_days_overdue)                       AS dp_more_90_days_overdue,
  STDDEV_POP(number_times_delayed_payment_loan_60_89_days) AS dp_delayed_60_89,
  CORR(more_90_days_overdue, number_times_delayed_payment_loan_60_89_days) AS corr
FROM `super_caja.loans_detail`;
-- resultado: correlação de 0,99 → variável redundante

-- Correlação entre debt_ratio e more_90_days_overdue
SELECT
  CORR(debt_ratio, more_90_days_overdue) AS corr
FROM `super_caja.loans_detail`;
-- resultado: -0,008 → correlação desprezível

-- Correlação entre using_lines_not_secured_personal_assets e default_flag
SELECT
  CORR(using_lines_not_secured_personal_assets, default_flag) AS corr
FROM `super_caja.tabela_principal`;
-- resultado: -0,0029

-- Correlação entre atrasos 60-89 dias e default_flag
SELECT
  CORR(number_times_delayed_payment_loan_60_89_days, default_flag) AS corr
FROM `super_caja.tabela_principal`;
-- resultado: 0,27


-- ---------------------------------------------------------------
-- 1.4 Identificar e tratar dados discrepantes em variáveis categóricas
-- ---------------------------------------------------------------

-- Frequência de default_flag
SELECT default_flag, COUNT(*) AS frequencia
FROM `super_caja.tabela_principal`
GROUP BY default_flag
ORDER BY frequencia ASC;
-- resultado: default_flag 1 → 622 | default_flag 0 → 34.953

-- Frequência de loan_type (detectou valor em caixa alta: REAL_STATE)
SELECT loan_type, COUNT(*) AS frequencia
FROM `super_caja.tabela_principal`
GROUP BY loan_type
ORDER BY frequencia ASC;

-- Padronizar loan_type para caixa baixa
CREATE OR REPLACE TABLE `super_caja.tabela_principal` AS
SELECT
  t1.* EXCEPT (loan_type),
  t2.* EXCEPT (loan_id)
FROM `super_caja.tabela_principal` AS t1
LEFT JOIN `super_caja.loan_type_tratado` AS t2
  ON t1.loan_id = t2.loan_id;
-- resultado após padronização: other → 13.119 | real estate → 22.456

-- Distribuição cruzada: loan_type × default_flag
SELECT loan_type, default_flag, COUNT(*) AS frequencia
FROM `super_caja.tabela_principal`
GROUP BY loan_type, default_flag
ORDER BY loan_type, default_flag;


-- ---------------------------------------------------------------
-- 1.5 Identificar e tratar dados discrepantes em variáveis numéricas
-- ---------------------------------------------------------------

-- Identificar outliers em last_month_salary (formato científico)
SELECT *
FROM `super_caja.user_info`
WHERE last_month_salary = 1.00E+05;
-- user_id 4931 e 9466 com notação científica → convertidos para 100.000

-- Identificar salários acima de 100.000
SELECT *
FROM `super_caja.user_info`
WHERE last_month_salary > 100000;


-- ---------------------------------------------------------------
-- 1.6 Verificar e alterar tipos de dados
-- ---------------------------------------------------------------

-- Converter last_month_salary para INT64
CREATE OR REPLACE TABLE `super_caja.user_info` AS
SELECT
  t1.* EXCEPT (last_month_salary),
  CAST(last_month_salary AS INT64) AS last_month_salary
FROM `super_caja.user_info` t1;

-- Padronizar loan_type com LOWER e CASE WHEN
CREATE OR REPLACE TABLE `super_caja.loans_outstanding` AS
SELECT
  loan_id,
  user_id,
  CASE
    WHEN LOWER(loan_type) IN ('real estate') THEN 'real estate'
    WHEN LOWER(loan_type) IN ('other', 'others') THEN 'other'
    ELSE loan_type
  END AS loan_type_corrigido
FROM `super_caja.loans_outstanding`;


-- ---------------------------------------------------------------
-- 1.7 Criar novas variáveis
-- ---------------------------------------------------------------

-- Contagem de empréstimos por tipo
SELECT
  loan_type_corrigido,
  COUNT(loan_type_corrigido) AS num_loans_category
FROM `super_caja.loans_outstanding`
GROUP BY loan_type_corrigido;

-- Criar variáveis: total_loan, num_real_estate, num_other
SELECT
  user_id,
  COUNT(DISTINCT loan_id)                                                      AS total_loan,
  SUM(CASE WHEN loan_type_corrigido = 'real estate' THEN 1 ELSE 0 END)        AS num_real_estate,
  SUM(CASE WHEN loan_type_corrigido = 'other' THEN 1 ELSE 0 END)              AS num_other
FROM `super_caja.loans_outstanding`
GROUP BY user_id;


-- ---------------------------------------------------------------
-- 1.8 Unir tabelas
-- ---------------------------------------------------------------

CREATE OR REPLACE TABLE `super_caja.tabela_principal` AS
SELECT
  t1.* EXCEPT (sex),
  t2.loan_id,
  t2.loan_type_corrigido AS loan_type,
  t3.default_flag,
  t4.* EXCEPT (user_id, row_num),
  t5.* EXCEPT (user_id)
FROM `super_caja.user_info`         AS t1
LEFT JOIN `super_caja.loans_outstanding` AS t2 ON t1.user_id = t2.user_id
LEFT JOIN `super_caja.default`           AS t3 ON t3.user_id = t1.user_id
LEFT JOIN `super_caja.loans_detail`      AS t4 ON t4.user_id = t1.user_id
LEFT JOIN `super_caja.loans_count`       AS t5 ON t5.user_id = t1.user_id;


-- ---------------------------------------------------------------
-- 1.9 Construir tabelas auxiliares (salvar como views)
-- ---------------------------------------------------------------

-- Registros com last_month_salary nulo
SELECT * FROM `super_caja.tabela_principal` WHERE last_month_salary IS NULL;

-- Registros com loan_id nulo
SELECT * FROM `super_caja.tabela_principal` WHERE loan_id IS NULL;

-- Registros inadimplentes
SELECT * FROM `super_caja.tabela_principal` WHERE default_flag = 1;


-- =============================================================
-- 2. ANÁLISE EXPLORATÓRIA (EDA)
-- =============================================================

-- ---------------------------------------------------------------
-- 2.1 Calcular quartis para variáveis principais
-- ---------------------------------------------------------------

WITH ntile_vars AS (
  SELECT
    user_id,
    default_flag,
    debt_ratio,
    last_month_salary,
    age,
    using_lines_not_secured_personal_assets,
    more_90_days_overdue,
    total_loan,
    NTILE(4) OVER (ORDER BY debt_ratio)                             AS debt_ratio_ntile,
    NTILE(4) OVER (ORDER BY last_month_salary)                      AS last_month_salary_ntile,
    NTILE(4) OVER (ORDER BY age)                                    AS age_ntile,
    NTILE(4) OVER (ORDER BY using_lines_not_secured_personal_assets) AS using_lines_ntile,
    NTILE(4) OVER (ORDER BY more_90_days_overdue)                   AS more_90_days_overdue_ntile,
    NTILE(4) OVER (ORDER BY total_loan)                             AS total_loan_ntile
  FROM `super_caja.super_caja_tabela_analise_completa`
)
SELECT * FROM ntile_vars;


-- ---------------------------------------------------------------
-- 2.2 Calcular correlação de Pearson com default_flag
-- ---------------------------------------------------------------

SELECT CORR(default_flag, more_90_days_overdue)                          AS corr_90_days_overdue       FROM `super_caja.tabela_principal`;  -- 0,30
SELECT CORR(default_flag, number_times_delayed_payment_loan_30_59_days)  AS corr_delayed_30_59         FROM `super_caja.tabela_principal`;  -- 0,29
SELECT CORR(default_flag, number_times_delayed_payment_loan_60_89_days)  AS corr_delayed_60_89         FROM `super_caja.tabela_principal`;  -- 0,27
SELECT CORR(last_month_salary, default_flag)                             AS corr_salary                FROM `super_caja.tabela_principal`;  -- -0,02
SELECT CORR(default_flag, total_loan)                                    AS corr_total_loan            FROM `super_caja.tabela_principal`;  -- -0,04
SELECT CORR(last_month_salary, total_loan)                               AS corr_salary_total_loan     FROM `super_caja.tabela_principal`;  -- -0,10


-- =============================================================
-- 3. CÁLCULO DO RISCO RELATIVO
-- =============================================================

-- Padrão utilizado para cada variável:
-- 1. Calcular quartil com NTILE(4)
-- 2. Unir quartil à tabela principal
-- 3. Calcular taxa de default por quartil
-- 4. Dividir pela taxa média geral para obter o RR

-- ---------------------------------------------------------------
-- 3.1 Risco relativo por variável (quartil)
-- ---------------------------------------------------------------

-- debt_ratio
WITH ntile_debt_ratio AS (
  SELECT user_id, default_flag, debt_ratio,
    NTILE(4) OVER (ORDER BY debt_ratio DESC) AS debt_ratio_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),
data_with_ntile AS (
  SELECT u.*, n.debt_ratio_ntile
  FROM `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN ntile_debt_ratio AS n ON u.user_id = n.user_id
),
risk_relative AS (
  SELECT
    debt_ratio_ntile,
    COUNT(*)          AS total_customers,
    SUM(default_flag) AS total_default,
    AVG(default_flag) AS default_rate
  FROM data_with_ntile
  GROUP BY debt_ratio_ntile
)
SELECT
  debt_ratio_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM risk_relative
ORDER BY debt_ratio_ntile;
-- resultado: Q1 e Q2 com RR > 1

-- last_month_salary
WITH ntile_last_month_salary AS (
  SELECT user_id, default_flag, last_month_salary,
    NTILE(4) OVER (ORDER BY last_month_salary) AS last_month_salary_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),
data_with_ntile AS (
  SELECT u.*, n.last_month_salary_ntile
  FROM `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN ntile_last_month_salary AS n ON u.user_id = n.user_id
),
risk_relative AS (
  SELECT
    last_month_salary_ntile,
    COUNT(*)          AS total_customers,
    SUM(default_flag) AS total_default,
    AVG(default_flag) AS default_rate
  FROM data_with_ntile
  GROUP BY last_month_salary_ntile
)
SELECT
  last_month_salary_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM risk_relative
ORDER BY last_month_salary_ntile;
-- resultado: Q1 e Q2 com RR > 1

-- age
WITH ntile_age AS (
  SELECT user_id, default_flag, age,
    NTILE(4) OVER (ORDER BY age) AS age_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),
data_with_ntile AS (
  SELECT u.*, n.age_ntile
  FROM `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN ntile_age AS n ON u.user_id = n.user_id
),
risk_relative AS (
  SELECT
    age_ntile,
    COUNT(*)          AS total_customers,
    SUM(default_flag) AS total_default,
    AVG(default_flag) AS default_rate
  FROM data_with_ntile
  GROUP BY age_ntile
)
SELECT
  age_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM risk_relative
ORDER BY age_ntile;
-- resultado: Q1 e Q2 com RR > 1

-- using_lines_not_secured_personal_assets
WITH ntile_using_lines AS (
  SELECT user_id, default_flag, using_lines_not_secured_personal_assets,
    NTILE(4) OVER (ORDER BY using_lines_not_secured_personal_assets DESC) AS using_lines_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),
data_with_ntile AS (
  SELECT u.*, n.using_lines_ntile
  FROM `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN ntile_using_lines AS n ON u.user_id = n.user_id
),
risk_relative AS (
  SELECT
    using_lines_ntile,
    COUNT(*)          AS total_customers,
    SUM(default_flag) AS total_default,
    AVG(default_flag) AS default_rate
  FROM data_with_ntile
  GROUP BY using_lines_ntile
)
SELECT
  using_lines_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM risk_relative
ORDER BY using_lines_ntile;
-- resultado: Q1 com RR > 1

-- more_90_days_overdue
WITH ntile_more_90 AS (
  SELECT user_id, default_flag, more_90_days_overdue,
    NTILE(4) OVER (ORDER BY more_90_days_overdue DESC) AS more_90_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),
data_with_ntile AS (
  SELECT u.*, n.more_90_ntile
  FROM `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN ntile_more_90 AS n ON u.user_id = n.user_id
),
risk_relative AS (
  SELECT
    more_90_ntile,
    COUNT(*)          AS total_customers,
    SUM(default_flag) AS total_default,
    AVG(default_flag) AS default_rate
  FROM data_with_ntile
  GROUP BY more_90_ntile
)
SELECT
  more_90_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM risk_relative
ORDER BY more_90_ntile;
-- resultado: Q1 com RR > 1

-- total_loan
WITH ntile_total_loan AS (
  SELECT user_id, default_flag, total_loan,
    NTILE(4) OVER (ORDER BY total_loan) AS total_loan_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),
data_with_ntile AS (
  SELECT u.*, n.total_loan_ntile
  FROM `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN ntile_total_loan AS n ON u.user_id = n.user_id
),
risk_relative AS (
  SELECT
    total_loan_ntile,
    COUNT(*)          AS total_customers,
    SUM(default_flag) AS total_default,
    AVG(default_flag) AS default_rate
  FROM data_with_ntile
  GROUP BY total_loan_ntile
)
SELECT
  total_loan_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM risk_relative
ORDER BY total_loan_ntile;
-- resultado: Q1 com RR > 1


-- ---------------------------------------------------------------
-- 3.2 Risco relativo combinado (quartil com múltiplas variáveis)
-- ---------------------------------------------------------------

-- Ordem das variáveis por quantidade de inadimplentes com RR > 1:
-- using_lines (674) > more_90_days (643) > age (512) > salary (439) > debt_ratio (381)

WITH ntile_geral AS (
  SELECT
    user_id, default_flag,
    using_lines_not_secured_personal_assets,
    more_90_days_overdue, age, last_month_salary, debt_ratio,
    NTILE(4) OVER (
      ORDER BY
        using_lines_not_secured_personal_assets DESC,
        more_90_days_overdue DESC,
        age,
        last_month_salary,
        debt_ratio DESC
    ) AS geral_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),
data_with_ntile AS (
  SELECT u.*, n.geral_ntile
  FROM `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN ntile_geral AS n ON u.user_id = n.user_id
),
risk_relative AS (
  SELECT
    geral_ntile,
    COUNT(*)          AS total_customers,
    SUM(default_flag) AS total_default,
    AVG(default_flag) AS default_rate
  FROM data_with_ntile
  GROUP BY geral_ntile
)
SELECT
  geral_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM risk_relative
ORDER BY geral_ntile;
-- resultado (quartil): Q1 com RR > 1

-- Mesma lógica com NTILE(10) — decil
WITH ntile_geral AS (
  SELECT
    user_id, default_flag,
    using_lines_not_secured_personal_assets,
    more_90_days_overdue, age, last_month_salary, debt_ratio,
    NTILE(10) OVER (
      ORDER BY
        using_lines_not_secured_personal_assets DESC,
        more_90_days_overdue DESC,
        age,
        last_month_salary,
        debt_ratio DESC
    ) AS geral_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),
data_with_ntile AS (
  SELECT u.*, n.geral_ntile
  FROM `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN ntile_geral AS n ON u.user_id = n.user_id
),
risk_relative AS (
  SELECT
    geral_ntile,
    COUNT(*)          AS total_customers,
    SUM(default_flag) AS total_default,
    AVG(default_flag) AS default_rate
  FROM data_with_ntile
  GROUP BY geral_ntile
)
SELECT
  geral_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM risk_relative
ORDER BY geral_ntile;
-- resultado (decil): D1 e D2 com RR > 1


-- =============================================================
-- 4. CLASSIFICAÇÃO E SEGMENTAÇÃO DE CLIENTES
-- =============================================================

-- ---------------------------------------------------------------
-- 4.1 Classificar clientes em bom ou mau pagador por variável
-- ---------------------------------------------------------------

-- Critério: RR ≥ 1 → mau pagador | RR < 1 → bom pagador

SELECT
  t.*,
  CASE WHEN age_ntile <= 2             THEN 'mau pagador' ELSE 'bom pagador' END AS age_class,
  CASE WHEN using_lines_ntile = 4      THEN 'mau pagador' ELSE 'bom pagador' END AS using_lines_class,
  CASE WHEN more_90_days_overdue_ntile = 4 THEN 'mau pagador' ELSE 'bom pagador' END AS overdue_class,
  CASE WHEN last_month_salary_ntile <= 2 THEN 'mau pagador' ELSE 'bom pagador' END AS salary_class
FROM `super_caja.super_caja_tabela_analise_completa` AS t;

-- Atualizar tabela com colunas de classificação
CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS
SELECT
  t.*,
  CASE WHEN age_ntile <= 2             THEN 'mau pagador' ELSE 'bom pagador' END AS age_class,
  CASE WHEN using_lines_ntile = 4      THEN 'mau pagador' ELSE 'bom pagador' END AS using_lines_class,
  CASE WHEN more_90_days_overdue_ntile = 4 THEN 'mau pagador' ELSE 'bom pagador' END AS overdue_class,
  CASE WHEN last_month_salary_ntile <= 2 THEN 'mau pagador' ELSE 'bom pagador' END AS salary_class
FROM `super_caja.super_caja_tabela_analise_completa` AS t;


-- ---------------------------------------------------------------
-- 4.2 Criar variáveis dummy e calcular score
-- ---------------------------------------------------------------

-- Criar dummies
CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS
SELECT
  d.*,
  CASE WHEN age_class          = 'mau pagador' THEN 1 ELSE 0 END AS age_dummy,
  CASE WHEN salary_class       = 'mau pagador' THEN 1 ELSE 0 END AS salary_dummy,
  CASE WHEN overdue_class      = 'mau pagador' THEN 1 ELSE 0 END AS overdue_dummy,
  CASE WHEN using_lines_class  = 'mau pagador' THEN 1 ELSE 0 END AS using_line_dummy
FROM `super_caja.super_caja_tabela_analise_completa` AS d;

-- Calcular score (soma das dummies: 0 a 4)
CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS
SELECT
  t.*,
  (age_dummy + salary_dummy + overdue_dummy + using_line_dummy) AS score
FROM `super_caja.super_caja_tabela_analise_completa` AS t;


-- ---------------------------------------------------------------
-- 4.3 Segmentar e avaliar com matriz de confusão
-- ---------------------------------------------------------------

-- Analisar distribuição do score
WITH score_distribution AS (
  SELECT
    score,
    COUNT(*) AS total_clients,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS total_defaulters,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) / COUNT(*) AS default_rate
  FROM `super_caja.super_caja_tabela_analise_completa`
  GROUP BY score
)
SELECT * FROM score_distribution
ORDER BY score;

-- Segmentar em alto/baixo risco (corte: score = 4) e calcular matriz de confusão
WITH segmentacao AS (
  SELECT
    t.*,
    CASE WHEN score = 4 THEN 1 ELSE 0 END AS segmentacao_dummy
  FROM `super_caja.super_caja_tabela_analise_completa` AS t
),
classificacao AS (
  SELECT
    *,
    CASE WHEN segmentacao_dummy = 0 THEN 'baixo risco' ELSE 'alto risco' END AS classificacao
  FROM segmentacao
),
matriz_confusao AS (
  SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN default_flag = 1 AND segmentacao_dummy = 1 THEN 1 ELSE 0 END) AS true_positives,
    SUM(CASE WHEN default_flag = 0 AND segmentacao_dummy = 1 THEN 1 ELSE 0 END) AS false_positives,
    SUM(CASE WHEN default_flag = 1 AND segmentacao_dummy = 0 THEN 1 ELSE 0 END) AS false_negatives,
    SUM(CASE WHEN default_flag = 0 AND segmentacao_dummy = 0 THEN 1 ELSE 0 END) AS true_negatives
  FROM classificacao
)
SELECT
  true_positives,
  false_positives,
  false_negatives,
  true_negatives
FROM matriz_confusao;


-- ---------------------------------------------------------------
-- 4.4 Criar pontuação positiva (score invertido: 200 a 1000)
-- ---------------------------------------------------------------

CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS
SELECT
  t.*,
  CASE
    WHEN score = 0 THEN 1000
    WHEN score = 1 THEN 800
    WHEN score = 2 THEN 600
    WHEN score = 3 THEN 400
    ELSE 200
  END AS pontuacao
FROM `super_caja.super_caja_tabela_analise_completa` AS t;
