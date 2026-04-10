# Análise de Hipóteses — Músicas mais ouvidas no Spotify (2023)

> Projeto realizado durante o Bootcamp de Especialização em Data Analysis da [Laboratória Brasil](https://www.laboratoria.la/br).

## Links

| Recurso | Link |
|---|---|
| Apresentação (PDF) | [Google Drive](https://drive.google.com/file/d/1YnPTOWRMnsW291v9dAaMtU49sEKE_QN4/view) |
| Dashboard Power BI | [Acessar dashboard](https://app.powerbi.com/view?r=eyJrIjoiYTE1M2IxNDEtMmY0OC00ZDZiLWFjMjMtMWI1ODFkZDgyOWJjIiwidCI6IjRhNWRiNDI3LTllNTgtNDQ5MC04ZDY4LWYxOWJlYjRiNzlmMCJ9) |
| Vídeo de apresentação (Loom) | [Assistir](https://www.loom.com/share/4142893d432e4b7daec5ae6aeb1f1eae) |
| Análise estatística (Colab) | [Abrir no Colab](https://colab.research.google.com/drive/1DoGV9qHeNQFyMAKRSwS0yJI5cxyJN-h_?usp=sharing) |

---

## Sumário

- [Contexto e Objetivo](#contexto-e-objetivo)
- [Hipóteses](#hipóteses)
- [Ferramentas](#ferramentas)
- [Metodologia](#metodologia)
- [Resultados e Validação das Hipóteses](#resultados-e-validação-das-hipóteses)

---

## Contexto e Objetivo

Uma gravadora enfrenta o desafio de lançar um novo artista no cenário musical global e conta com um extenso conjunto de dados do Spotify sobre as músicas mais ouvidas em 2023.

O objetivo é **validar ou refutar hipóteses** a partir da análise de dados, fornecendo estratégias para que a gravadora e o artista tomem decisões que aumentem as chances de sucesso.

---

## Hipóteses

| # | Hipótese |
|---|---|
| H1 | Músicas com BPM mais altos fazem mais sucesso em streams |
| H2 | Músicas populares no Spotify têm comportamento semelhante em outras plataformas (ex.: Deezer) |
| H3 | Presença em mais playlists está correlacionada com mais streams |
| H4 | Artistas com mais músicas no Spotify têm mais streams |
| H5 | Características musicais influenciam o sucesso em streams |

---

## Ferramentas

![BigQuery](https://img.shields.io/badge/SQL-BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-Google%20Colab-3776AB?style=flat&logo=python&logoColor=white)

---

## Metodologia

### 1. Pré-processamento

Três tabelas foram importadas no BigQuery dentro do dataset `projeto2`: `track_in_spotify`, `track_technical_info` e `track_in_competition`.

![Download e extração dos arquivos](./images/41a60b5b-5cf5-4262-9768-a4d57c8b0de0.png)
![Importação no BigQuery](./images/b8a4eaa1-2bf2-42e8-bc6e-c0c70ce64ab5.png)

---

### 2. Processar e preparar a base de dados

**2.1 Valores nulos**

A coluna `in_shazam_charts` apresentou 50 nulos e foi excluída por não ser plataforma de streaming. As colunas `key` e `mode` também foram descartadas por estarem fora do escopo analítico.

![Identificação de nulos no BigQuery](./images/98e870ba-fa0a-4f0b-ab82-65e6fe28b177.png)

Resumo de nulos por tabela:

**track_technical_info**

| Coluna | Nulos |
|---|---|
| track_id | 0 |
| bpm | 0 |
| key | 95 |
| mode | 0 |
| danceability__ | 0 |
| valence__ | 0 |
| energy__ | 0 |
| acousticness__ | 0 |
| instrumentalness__ | 0 |
| liveness__ | 0 |
| speechiness__ | 0 |

**track_in_spotify**

| Coluna | Nulos |
|---|---|
| track_id | 0 |
| track_name | 0 |
| artist_s__name | 0 |
| artist_count | 0 |
| released_year | 0 |
| released_month | 0 |
| released_day | 0 |
| in_spotify_playlists | 0 |
| in_spotify_charts | 0 |
| streams | 0 |

**track_in_competition**

| Coluna | Nulos |
|---|---|
| track_id | 0 |
| in_apple_playlists | 0 |
| in_apple_charts | 0 |
| in_deezer_playlists | 0 |
| in_deezer_charts | 0 |
| in_shazam_charts | **50** |

**2.2 Duplicatas**

Identificadas 4 músicas duplicadas em `track_in_spotify`. O agrupamento foi feito por `track_name` + `artist_s__name` (e não por `track_id`, que pode se repetir entre artistas diferentes):

| track_name | artist_s__name |
|---|---|
| SNAP | Rosa Linn |
| About Damn Time | Lizzo |
| Take My Breath | The Weeknd |
| SPIT IN MY FACE! | ThxSoMch |

**2.3 Dados fora do escopo**

Colunas `key` e `mode` (track_technical_info) e `in_shazam_charts` (track_in_competition) excluídas via `SELECT * EXCEPT`.

**2.4 Discrepâncias e conversão de tipos**

- Registro com `track_id = '4061483'` removido (valor string no campo `streams`)
- Coluna `streams` convertida de `STRING` para `INT64` via `SAFE_CAST`

**2.5 Novas variáveis e união das tabelas**

- Criada coluna `release_date` concatenando `released_year`, `released_month` e `released_day`
- Criada coluna `track_count` (total de músicas por artista)
- Tabelas unidas via `JOIN` em `track_id`

> Todas as queries estão documentadas em [`queries.sql`](./queries.sql).

---

### 3. Análise Exploratória (Power BI)

**Matrizes por hipótese**

![BPM x Streams](./images/04300203-cfba-401b-9e0e-edb7b9688455.png)
![Charts: Spotify / Deezer / Apple](./images/41016d59-2b39-42f1-8e42-a73b884f9a34.png)
![Streams x Playlists](./images/285e539b-6918-4b77-859c-1589da471d41.png)
![Contagem de músicas x Streams](./images/1456f482-c130-42d2-aa39-c2541e2a7d16.png)

**Medidas de tendência central** (soma, média e mediana por variável)

![Medidas de tendência central](./images/df783c17-0f63-4f67-bdd6-e02be4e0e785.png)

**Distribuição — histogramas (Python no Power BI)**

![Histograma de BPM](./images/38b38e2b-ae75-4a7d-aa44-af14377c6225.png)

**Medidas de dispersão** (desvio padrão e variância)

![Dispersão 1](./images/8653b9e6-26e6-4635-9eb3-96236cb4f2a6.png)
![Dispersão 2](./images/5d3086e7-f99d-41df-8832-120fda10c846.png)

**Comportamento ao longo do tempo**

![Streams ao longo do tempo](./images/f4a5f0be-e8aa-4e4a-87fb-86c4c90d0635.png)

**Estatísticas descritivas — track_in_spotify**

![Stats track_in_spotify (1)](./images/fa5b6a5f-04d3-4edc-a75d-d86a0b4d6346.png)
![Stats track_in_spotify (2)](./images/02873f2e-55f1-45ef-9fc5-0bcd79226720.png)

**Estatísticas descritivas — track_technical_info**

![Stats track_technical_info (1)](./images/3cae7872-9b4a-463e-a49f-315458cf4b7c.png)
![Stats track_technical_info (2)](./images/9adfb5f9-72ee-421d-9767-46628eb0e188.png)
![Stats track_technical_info (3)](./images/d3353730-9041-4b9b-a37a-cb67f9645cb5.png)
![Stats track_technical_info (4)](./images/2944c1e9-424c-45db-8a79-d733aa5c8425.png)

**Estatísticas descritivas — track_in_competition**

![Stats track_in_competition (1)](./images/4d7626c3-9bc1-45ae-8062-b56151dd5a85.png)
![Stats track_in_competition (2)](./images/2e4bb009-d152-4b0c-88f5-b42173e70f12.png)

---

### 4. Técnicas de Análise

**Segmentação por quartis de streams**

A base foi dividida em 4 grupos pelo quartil de streams. As matrizes usam o quartil como linha e a média das variáveis como valor:

![Segmentação por quartil de streams](./images/f97eebe3-dc21-4e55-b927-23cffd9ec00e.png)

**Correlação de Pearson**

![Correlação de Pearson (1)](./images/fab8c16b-141b-4221-b3ef-9938bb636168.png)
![Correlação de Pearson (2)](./images/a95c64ea-e67c-48ea-8128-d511d6d5344c.png)

**Correlação de Spearman**

![Correlação de Spearman (1)](./images/deb2bee8-d573-4d5d-8472-944079ae4b25.png)
![Correlação de Spearman (2)](./images/eec9848e-07e2-45e9-815b-33a346bc54e5.png)
![Correlação de Spearman (3)](./images/d5a70455-8a72-4bca-9f36-95516ab14d80.png)

**Teste de significância — Mann-Whitney U** (Google Colab)

Aplicado para comparar streams entre grupos de BPM alto e baixo. Script disponível em [`queries.sql`](./queries.sql).

---

## Resultados e Validação das Hipóteses

| # | Hipótese | Resultado |
|---|---|---|
| H1 | BPM alto → mais streams | ❌ Refutada |
| H2 | Popularidade Spotify ~ outras plataformas | ✅ Validada |
| H3 | Mais playlists → mais streams | ✅ Validada |
| H4 | Mais músicas no catálogo → mais streams | ❌ Refutada |
| H5 | Características musicais influenciam streams | ❌ Refutada |

**H1 — BPM não determina streams**

![H1 — BPM x Streams](./images/2d789650-9a81-4983-8c36-18b85f827c3c.png)

**H2 — Comportamento semelhante entre plataformas**

![H2 — Spotify x Deezer](./images/745daaf2-28cf-4681-bee9-f7d868110768.png)

**H3 — Playlists correlacionadas com streams**

![H3 — Playlists x Streams](./images/690e46f7-ba6c-4286-bcb2-bc00836ae6e1.png)

**H4 — Volume de músicas no catálogo não garante mais streams**

![H4 — Catálogo x Streams](./images/3a213fd6-63f6-4739-9ebb-9b55bc6e00ae.png)

**H5 — Características musicais sem correlação com streams**

![H5 — Características x Streams](./images/b85c96c9-0f6b-4dbb-a7ff-74a4009c995c.png)
