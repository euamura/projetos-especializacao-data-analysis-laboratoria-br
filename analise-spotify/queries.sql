-- =============================================================================
-- Análise de Hipóteses — Spotify 2023
-- Projeto: projeto-2-hipoteses-420623 | Dataset: projeto2
-- =============================================================================


-- =============================================================================
-- 2. PROCESSAR E PREPARAR A BASE DE DADOS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 2.2 Identificar e tratar valores nulos
-- -----------------------------------------------------------------------------

-- Contagem de nulos por coluna em cada tabela (exemplo: in_shazam_charts)
-- Padrão: COUNT(*) WHERE coluna IS NULL aplicado por tabela no BigQuery


-- -----------------------------------------------------------------------------
-- 2.3 Identificar e tratar valores duplicados
-- -----------------------------------------------------------------------------

-- Identificar duplicatas agrupando por track_name + artist_s__name
SELECT
  track_name,
  artist_s__name,
  COUNT(*)
FROM `projeto-2-hipoteses-420623.projeto2.track_in_spotify`
GROUP BY track_name, artist_s__name;

-- Filtrar apenas os casos com mais de uma ocorrência
SELECT
  track_name,
  artist_s__name,
  COUNT(*)
FROM `projeto-2-hipoteses-420623.projeto2.track_in_spotify`
GROUP BY track_name, artist_s__name
HAVING COUNT(*) > 1;

-- Criar nova tabela removendo as 4 faixas duplicadas pelos seus track_id
CREATE OR REPLACE TABLE `projeto-2-hipoteses-420623.projeto2.new_track_in_spotify` AS
SELECT
  track_id,
  track_name,
  artist_s__name,
  artist_count,
  released_year,
  released_month,
  released_day,
  in_spotify_playlists,
  in_spotify_charts,
  streams
FROM `projeto-2-hipoteses-420623.projeto2.track_in_spotify`
WHERE track_id NOT IN ('8173823', '1119309', '7173596', '3814670');

-- Alternativa: remover duplicatas via ROW_NUMBER (reutilizável para qualquer tabela)
-- Passo 1: verificar resultado da deduplicação
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY track_id ORDER BY track_id) AS row_num
  FROM `projeto2.uniao_tabelas`
)
SELECT *
FROM tabela_temp
WHERE row_num = 1;

-- Passo 2: aplicar e salvar
CREATE OR REPLACE TABLE `projeto2.uniao_tabelas` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY track_id ORDER BY track_id) AS row_num
  FROM `projeto2.uniao_tabelas`
)
SELECT *
FROM tabela_temp
WHERE row_num = 1;


-- -----------------------------------------------------------------------------
-- 2.4 Dados fora do escopo
-- -----------------------------------------------------------------------------

-- Excluir colunas key e mode de track_technical_info
SELECT * EXCEPT (key, mode)
FROM `projeto-2-hipoteses-420623.projeto2.track_technical_info`;

-- Excluir coluna in_shazam_charts de track_in_competition
SELECT * EXCEPT (in_shazam_charts)
FROM `projeto-2-hipoteses-420623.projeto2.track_in_competition`;


-- -----------------------------------------------------------------------------
-- 2.5 Dados discrepantes em variáveis categóricas
-- -----------------------------------------------------------------------------

-- Remover registro com valor string no campo streams (track_id = '4061483')
SELECT *
FROM `projeto-2-hipoteses-420623.projeto2.new_track_in_spotify`
WHERE track_id != '4061483';


-- -----------------------------------------------------------------------------
-- 2.6 Dados discrepantes em variáveis numéricas
-- -----------------------------------------------------------------------------

-- Estatísticas descritivas — track_in_spotify
SELECT
  MAX(released_year)        AS max_released_year,
  MIN(released_year)        AS min_released_year,
  AVG(released_year)        AS avg_released_year,
  MAX(released_month)       AS max_released_month,
  MIN(released_month)       AS min_released_month,
  AVG(released_month)       AS avg_released_month,
  MAX(released_day)         AS max_released_day,
  MIN(released_day)         AS min_released_day,
  AVG(released_day)         AS avg_released_day,
  MAX(in_spotify_playlists) AS max_in_spotify_playlists,
  MIN(in_spotify_playlists) AS min_in_spotify_playlists,
  AVG(in_spotify_playlists) AS avg_in_spotify_playlists,
  MAX(in_spotify_charts)    AS max_in_spotify_charts,
  MIN(in_spotify_charts)    AS min_in_spotify_charts,
  AVG(in_spotify_charts)    AS avg_in_spotify_charts
FROM `projeto-2-hipoteses-420623.projeto2.new3_track_in_spotify`;

-- Estatísticas descritivas — track_technical_info
SELECT
  MAX(bpm)               AS max_bpm,
  MIN(bpm)               AS min_bpm,
  AVG(bpm)               AS avg_bpm,
  MAX(danceability__)    AS max_danceability__,
  MIN(danceability__)    AS min_danceability__,
  AVG(danceability__)    AS avg_danceability__,
  MAX(valence__)         AS max_valence__,
  MIN(valence__)         AS min_valence__,
  AVG(valence__)         AS avg_valence__,
  MAX(energy__)          AS max_energy__,
  MIN(energy__)          AS min_energy__,
  AVG(energy__)          AS avg_energy__,
  MAX(acousticness__)    AS max_acousticness__,
  MIN(acousticness__)    AS min_acousticness__,
  AVG(acousticness__)    AS avg_acousticness__,
  MAX(instrumentalness__) AS max_instrumentalness__,
  MIN(instrumentalness__) AS min_instrumentalness__,
  AVG(instrumentalness__) AS avg_instrumentalness__,
  MAX(liveness__)        AS max_liveness__,
  MIN(liveness__)        AS min_liveness__,
  AVG(liveness__)        AS avg_liveness__,
  MAX(speechiness__)     AS max_speechiness__,
  MIN(speechiness__)     AS min_speechiness__,
  AVG(speechiness__)     AS avg_speechiness__
FROM `projeto-2-hipoteses-420623.projeto2.new_track_technal_info`;

-- Estatísticas descritivas — track_in_competition
SELECT
  MAX(in_apple_playlists)  AS max_in_apple_playlists,
  MIN(in_apple_playlists)  AS min_in_apple_playlists,
  AVG(in_apple_playlists)  AS avg_in_apple_playlists,
  MAX(in_apple_charts)     AS max_in_apple_charts,
  MIN(in_apple_charts)     AS min_in_apple_charts,
  AVG(in_apple_charts)     AS avg_in_apple_charts,
  MAX(in_deezer_playlists) AS max_in_deezer_playlists,
  MIN(in_deezer_playlists) AS min_in_deezer_playlists,
  AVG(in_deezer_playlists) AS avg_in_deezer_playlists,
  MAX(in_deezer_charts)    AS max_in_deezer_charts,
  MIN(in_deezer_charts)    AS min_in_deezer_charts,
  AVG(in_deezer_charts)    AS avg_in_deezer_charts
FROM `projeto-2-hipoteses-420623.projeto2.new_track_in_competition`;


-- -----------------------------------------------------------------------------
-- 2.7 Verificar e alterar o tipo de dados
-- -----------------------------------------------------------------------------

-- Converter streams de STRING para INT64
CREATE OR REPLACE TABLE `projeto-2-hipoteses-420623.projeto2.new3_track_in_spotify` AS
SELECT
  track_id,
  track_name,
  artist_s__name,
  artist_count,
  released_year,
  released_month,
  released_day,
  in_spotify_playlists,
  in_spotify_charts,
  SAFE_CAST(streams AS INT64) AS streams
FROM `projeto-2-hipoteses-420623.projeto2.new2_track_in_spotify`;


-- -----------------------------------------------------------------------------
-- 2.8 Criar novas variáveis
-- -----------------------------------------------------------------------------

-- Nova variável: release_date (formato YYYY-MM-DD)
SELECT
  DATE(CONCAT(
    CAST(released_year  AS STRING), '-',
    CAST(released_month AS STRING), '-',
    CAST(released_day   AS STRING)
  )) AS release_date,
  SUM(in_spotify_charts)    AS total_in_spotify_charts,
  SUM(in_spotify_playlists) AS total_in_spotify_playlists
FROM `projeto-2-hipoteses-420623.projeto2.new2_track_in_spotify`
GROUP BY release_date;


-- -----------------------------------------------------------------------------
-- 2.9 Unir tabelas
-- -----------------------------------------------------------------------------

SELECT *
FROM `projeto-2-hipoteses-420623.projeto2.new3_track_in_spotify`    AS t1
JOIN `projeto-2-hipoteses-420623.projeto2.new_track_technal_info`   AS t2 ON t1.track_id = t2.track_id
JOIN `projeto-2-hipoteses-420623.projeto2.new_track_in_competition` AS t3 ON t1.track_id = t3.track_id;


-- -----------------------------------------------------------------------------
-- 2.10 Tabelas auxiliares
-- -----------------------------------------------------------------------------

-- Tabela temporária: total de músicas e streams por artista
WITH teste AS (
  SELECT
    artist_s__name,
    COUNT(DISTINCT track_name) AS total_musicas,
    SUM(streams)               AS total_streams
  FROM `projeto-2-hipoteses-420623.projeto2.new3_track_in_spotify`
  GROUP BY artist_s__name
)
SELECT *
FROM `projeto-2-hipoteses-420623.projeto2.new3_track_in_spotify` AS spotify
LEFT JOIN teste ON spotify.artist_s__name = teste.artist_s__name;

-- Salvar tabela de totais por artista
CREATE TABLE `projeto-2-hipoteses-420623.projeto2.totais_musicas_streams` AS
SELECT
  artist_s__name,
  COUNT(DISTINCT track_name) AS total_musicas,
  SUM(streams)               AS total_streams
FROM `projeto-2-hipoteses-420623.projeto2.new3_track_in_spotify`
GROUP BY artist_s__name;

-- Contagem de músicas por artista (passo 1: verificar)
SELECT
  artist_s__name,
  COUNT(track_id) AS track_count
FROM `projeto-2-hipoteses-420623.projeto2.uniao_tabelas`
GROUP BY artist_s__name;

-- Passo 2: salvar tabela track_count
CREATE TABLE `projeto-2-hipoteses-420623.projeto2.track_count` AS
SELECT
  artist_s__name,
  COUNT(track_id) AS track_count
FROM `projeto-2-hipoteses-420623.projeto2.uniao_tabelas`
GROUP BY artist_s__name;

-- Passo 3: unir track_count à tabela principal
CREATE OR REPLACE TABLE `projeto2.uniao_tabelas` AS
SELECT
  t1.*,
  t2.track_count
FROM `projeto-2-hipoteses-420623.projeto2.uniao_tabelas` AS t1
LEFT JOIN (
  SELECT
    artist_s__name,
    COUNT(track_id) AS track_count
  FROM `projeto-2-hipoteses-420623.projeto2.uniao_tabelas`
  GROUP BY artist_s__name
) AS t2 ON t1.artist_s__name = t2.artist_s__name;


-- =============================================================================
-- 3. ANÁLISE EXPLORATÓRIA
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 3.9 Calcular quartis e categorizar variáveis
-- -----------------------------------------------------------------------------

-- Criar tabelas de quartil por variável
CREATE OR REPLACE TABLE `projeto-2-hipoteses-420623.projeto2.quartil_streams` AS
SELECT
  streams,
  NTILE(4) OVER (ORDER BY streams) AS quartil_streams
FROM `projeto-2-hipoteses-420623.projeto2.uniao_tabelas`;

CREATE TABLE `projeto-2-hipoteses-420623.projeto2.quartil_track_count` AS
SELECT
  track_count,
  NTILE(4) OVER (ORDER BY track_count) AS quartil_track_count
FROM `projeto2.uniao_tabelas`;

CREATE TABLE `projeto-2-hipoteses-420623.projeto2.quartil_bpm` AS
SELECT
  bpm,
  NTILE(4) OVER (ORDER BY bpm) AS quartil_bpm
FROM `projeto2.uniao_tabelas`;

CREATE TABLE `projeto-2-hipoteses-420623.projeto2.quartil_spotify_playlists` AS
SELECT
  in_spotify_playlists,
  NTILE(4) OVER (ORDER BY in_spotify_playlists) AS quartil_in_spotify_playlists
FROM `projeto2.uniao_tabelas`;

-- Categorizar quartis
SELECT
  streams,
  quartil_streams,
  IF(quartil_streams = 4, 'alto', IF(quartil_streams = 3, 'médio', 'baixo')) AS categoria_streams
FROM `projeto2.quartil_streams`;

SELECT
  track_count,
  quartil_track_count,
  IF(quartil_track_count = 4, 'alto', IF(quartil_track_count = 3, 'médio', 'baixo')) AS categoria_track_count
FROM `projeto2.quartil_track_count`;

SELECT
  bpm,
  quartil_bpm,
  IF(quartil_bpm IN (4, 3), 'alto', 'baixo') AS categoria_bpm
FROM `projeto2.quartil_bpm`;

SELECT
  in_spotify_playlists,
  quartil_in_spotify_playlists,
  IF(quartil_in_spotify_playlists = 4, 'alto', 'baixo') AS categoria_in_spotify_playlists
FROM `projeto2.quartil_spotify_playlists`;

-- Unir tabelas de quartil à tabela principal
CREATE OR REPLACE TABLE `projeto2.uniao_tabelas` AS
SELECT t1.*, t2.* EXCEPT (streams)
FROM `projeto2.uniao_tabelas` AS t1
LEFT JOIN `projeto2.categoria_streams` AS t2 ON t1.streams = t2.streams;

CREATE OR REPLACE TABLE `projeto2.uniao_tabelas` AS
SELECT t1.*, t2.* EXCEPT (bpm)
FROM `projeto2.uniao_tabelas` AS t1
LEFT JOIN `projeto2.categoria_bpm` AS t2 ON t1.bpm = t2.bpm;

CREATE OR REPLACE TABLE `projeto2.uniao_tabelas` AS
SELECT t1.*, t2.* EXCEPT (in_spotify_playlists)
FROM `projeto2.uniao_tabelas` AS t1
LEFT JOIN `projeto2.categoria_in_spotify_playlists` AS t2 ON t1.in_spotify_playlists = t2.in_spotify_playlists;

CREATE OR REPLACE TABLE `projeto2.uniao_tabelas` AS
SELECT t1.*, t2.* EXCEPT (track_count)
FROM `projeto2.uniao_tabelas` AS t1
LEFT JOIN `projeto2.categoria_track_count` AS t2 ON t1.track_count = t2.track_count;


-- -----------------------------------------------------------------------------
-- 3.10 Correlação entre variáveis
-- -----------------------------------------------------------------------------

-- Correlação de Pearson: streams x variáveis
SELECT
  CORR(streams, in_spotify_playlists) AS corr_spotify_playlists,
  CORR(streams, in_spotify_charts)    AS corr_spotify_charts,
  CORR(streams, in_deezer_playlists)  AS corr_deezer_playlists,
  CORR(streams, in_deezer_charts)     AS corr_deezer_charts,
  CORR(streams, in_apple_playlists)   AS corr_apple_playlists,
  CORR(streams, in_apple_charts)      AS corr_apple_charts,
  CORR(streams, danceability__)       AS corr_danceability,
  CORR(streams, energy__)             AS corr_energy,
  CORR(streams, liveness__)           AS corr_liveness,
  CORR(streams, bpm)                  AS corr_bpm,
  CORR(streams, speechiness__)        AS corr_speechiness,
  CORR(streams, valence__)            AS corr_valence,
  CORR(streams, acousticness__)       AS corr_acousticness,
  CORR(streams, instrumentalness__)   AS corr_instrumentalness
FROM `projeto2.uniao_tabelas`;

-- Correlação de Spearman: rankings entre plataformas
WITH ranked_data AS (
  SELECT
    streams,
    in_spotify_charts,
    in_deezer_charts,
    in_apple_charts,
    RANK() OVER (ORDER BY streams)           AS rank_streams,
    RANK() OVER (ORDER BY in_spotify_charts) AS rank_in_spotify_charts,
    RANK() OVER (ORDER BY in_deezer_charts)  AS rank_in_deezer_charts,
    RANK() OVER (ORDER BY in_apple_charts)   AS rank_in_apple_charts
  FROM `projeto2.uniao_tabelas`
)
SELECT
  CORR(rank_streams, rank_in_spotify_charts)          AS spearman_streams_spotify,
  IF(CORR(rank_streams, rank_in_spotify_charts) >= 0.5, 'correlação alta', 'correlação fraca') AS spotify_streams_valor_p,
  CORR(rank_streams, rank_in_deezer_charts)           AS spearman_streams_deezer,
  IF(CORR(rank_streams, rank_in_deezer_charts) >= 0.5, 'correlação alta', 'correlação fraca')  AS deezer_streams_valor_p,
  CORR(rank_streams, rank_in_apple_charts)            AS spearman_streams_apple,
  IF(CORR(rank_streams, rank_in_apple_charts) >= 0.5, 'correlação alta', 'correlação fraca')   AS apple_streams_valor_p,
  CORR(rank_in_spotify_charts, rank_in_deezer_charts) AS spearman_deezer_spotify_charts,
  IF(CORR(rank_in_spotify_charts, rank_in_deezer_charts) >= 0.5, 'correlação alta', 'correlação fraca') AS charts_deezer_spotify_valor_p,
  CORR(rank_in_spotify_charts, rank_in_apple_charts)  AS spearman_apple_spotify_charts,
  IF(CORR(rank_in_spotify_charts, rank_in_apple_charts) >= 0.5, 'correlação alta', 'correlação fraca')  AS charts_apple_spotify_valor_p,
  CORR(rank_in_deezer_charts, rank_in_apple_charts)   AS spearman_apple_deezer_charts,
  IF(CORR(rank_in_deezer_charts, rank_in_apple_charts) >= 0.5, 'correlação alta', 'correlação fraca')   AS charts_apple_deezer_valor_p
FROM ranked_data;


-- =============================================================================
-- 4. TÉCNICAS DE ANÁLISE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 4.2 Teste de significância — categorização binária para Mann-Whitney U
-- -----------------------------------------------------------------------------

-- Criar e categorizar quartil de streams (binário: alto / baixo)
CREATE OR REPLACE TABLE `projeto-2-hipoteses-420623.projeto2.quartil_streams` AS
SELECT
  track_id,
  streams,
  NTILE(4) OVER (ORDER BY streams) AS quartil_streams,
  IF(NTILE(4) OVER (ORDER BY streams) = 4, 'alto', 'baixo') AS categoria_streams
FROM `projeto-2-hipoteses-420623.projeto2.uniao_tabelas`;

-- Criar e categorizar quartil de in_spotify_charts (binário: alto / baixo)
CREATE OR REPLACE TABLE `projeto-2-hipoteses-420623.projeto2.quartil_in_spotify_charts` AS
SELECT
  track_id,
  in_spotify_charts,
  NTILE(4) OVER (ORDER BY in_spotify_charts) AS quartil_charts,
  IF(NTILE(4) OVER (ORDER BY in_spotify_charts) = 4, 'alto', 'baixo') AS categoria_charts
FROM `projeto-2-hipoteses-420623.projeto2.uniao_tabelas`;

-- Atualizar tabela principal com as novas categorias
CREATE OR REPLACE TABLE `projeto2.uniao_tabelas` AS
SELECT
  t1.*,
  t2.quartil_streams,
  t2.categoria_streams,
  t3.quartil_charts,
  t3.categoria_charts
FROM `projeto2.uniao_tabelas` AS t1
LEFT JOIN `projeto2.quartil_streams`           AS t2 ON t1.track_id = t2.track_id
LEFT JOIN `projeto2.quartil_in_spotify_charts` AS t3 ON t1.track_id = t3.track_id;


-- =============================================================================
-- PYTHON — Teste Mann-Whitney U (Google Colab)
-- =============================================================================

/*
# Importar bibliotecas
import pandas as pd
from scipy.stats import mannwhitneyu

# Carregar dados exportados do BigQuery
df = pd.read_csv('/content/drive/MyDrive/bootcamp - laboratoria/projeto 2/hipotesis-laboratoria.csv')

# Separar grupos alto e baixo BPM
df_alto  = df[df['categoria_bpm'] == 'alto']['streams']
df_baixo = df[df['categoria_bpm'] == 'baixo']['streams']

# Executar teste
estatistica, p_value = mannwhitneyu(df_alto, df_baixo, alternative='two-sided')

print(f"Mann-Whitney U statistic: {estatistica:.4f}")
print(f"P-value: {p_value:.4f}")

if p_value < 0.05:
    print("Rejeite a hipótese nula: há diferença significativa entre os grupos.")
else:
    print("Não rejeite a hipótese nula: não há diferença significativa entre os grupos.")
*/
