# Otimizando a Análise de Produtos para Estratégias de Dropshipping na Amazon

> Projeto realizado durante o Bootcamp de Especialização em Data Analysis da [Laboratória Brasil](https://www.laboratoria.la/br).

## Links

| Recurso | Link |
|---|---|
| Dashboard Power BI | [Acessar dashboard](https://app.powerbi.com/view?r=eyJrIjoiNzUwYzgxNjktYzQ4Ni00ZDRlLTkwODctMDkyNjRhNzZkOTJkIiwidCI6IjRhNWRiNDI3LTllNTgtNDQ5MC04ZDY4LWYxOWJlYjRiNzlmMCJ9) |
| Vídeo de apresentação | [Assistir no YouTube](https://youtu.be/ehf84D7a0ko) |

## Equipe

- Amanda Mendonça
- Keila Del Re

---

## Sumário

- [Contexto](#contexto)
- [Objetivos e Hipóteses](#objetivos-e-hipóteses)
- [Ferramentas](#ferramentas)
- [Metodologia](#metodologia)
- [Resultados](#resultados)
- [Conclusões e Próximos Passos](#conclusões-e-próximos-passos)

---

## Contexto

Diante do crescimento do comércio eletrônico, a Amazon e seus fornecedores de dropshipping precisam aprimorar estratégias para maximizar o sucesso em um mercado cada vez mais competitivo. A análise é estruturada em três pilares:

1. **Rentabilidade do Produto** — preço e descontos disponíveis na plataforma
2. **Popularidade do Produto** — número de avaliações e classificação média
3. **Satisfação do Cliente** — pontuação média das avaliações

---

## Objetivos e Hipóteses

Elaborar uma análise abrangente para orientar decisões estratégicas dos diretores de produto, com foco no desempenho por categoria e subcategoria.

**Hipóteses analisadas:**

| # | Hipótese |
|---|---|
| H1 | Quanto maior o desconto, melhor será a pontuação |
| H2 | Quanto maior o número de avaliações, melhor será a classificação |
| H3 | Categorias com produtos mais caros têm maiores pontuações |
| H4 | Quanto maior o desconto, mais avaliações a categoria recebe |

---

## Ferramentas

![BigQuery](https://img.shields.io/badge/SQL-BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)

---

## Metodologia

### 1. Processar e preparar a base de dados

Duas tabelas foram importadas no BigQuery dentro do dataset `amazon_sales`: `amazon_product` e `amazon_review`.

> Todas as queries estão documentadas em [`queries.sql`](./queries.sql).

---

**1.1 Importação**

Projeto no BigQuery: `amazon-sales-lab-proj4` | Dataset: `amazon_sales` | Tabelas: `amazon_product`, `amazon_review`.

---

**1.2 Valores nulos**

**amazon_product**

| Coluna | Nulos |
|---|---|
| product_id | 0 |
| product_name | 0 |
| category | 0 |
| discounted_price | 0 |
| actual_price | 0 |
| discount_percentage | 0 |
| about_product | **4** |

**amazon_review**

| Coluna | Nulos |
|---|---|
| user_id | 0 |
| user_name | 0 |
| review_id | 0 |
| review_title | 0 |
| review_content | 0 |
| img_link | **466** |
| product_link | **466** |
| product_id | 0 |
| rating | 0 |
| rating_count | **2** |

A variável `rating_count` é chave para a análise — as 2 linhas com nulo foram removidas.

---

**1.3 Duplicatas**

Removidas via `ROW_NUMBER() OVER (PARTITION BY)` em ambas as tabelas.

---

**1.4 Dados fora do escopo**

Colunas avaliadas por relevância analítica. Mantidas: `product_id`, `category`, `discounted_price`, `actual_price`, `discount_percentage`, `rating`, `rating_count`. Descartadas colunas sem objetivo claro para o escopo (ex.: `img_link`, `product_link`, `about_product`).

---

**1.5 Discrepâncias em variáveis categóricas**

- Coluna `rating`: encontrado valor discrepante `"|"` em um registro com `rating_count = 992` — registro removido como exceção
- Colunas `review_title` e `review_content`: presença de emojis e formatos variados; tratamento de normalização de texto

---

**1.6 Discrepâncias em variáveis numéricas**

Nenhum outlier identificado que justificasse remoção. Por se tratar de múltiplos varejos autônomos, a variação de preços e descontos foi mantida como característica natural da base.

---

**1.7 Conversão de tipos**

Coluna `rating` convertida de `STRING` para `FLOAT64` via `CAST`.

---

**1.8 Novas variáveis**

Criadas `main_category` e `sub_category` a partir do split da coluna `category` pelo delimitador `|`.

---

**1.9 União das tabelas**

Tabelas `amazon_product_clean` e `amazon_review_clean` unidas via `LEFT JOIN` em `product_id`. Duplicatas da união tratadas com `ROW_NUMBER() OVER (PARTITION BY product_id)`.

---

### 2. Análise Exploratória

**2.1 Correlação entre variáveis**

| Par de variáveis | Correlação |
|---|---|
| actual_price × rating | fraca |
| actual_price × rating_count | fraca |
| discount_percentage × rating | fraca |
| discount_percentage × rating_count | fraca |
| rating × rating_count | fraca |

---

**2.2 Quintis e medidas de tendência central**

Base dividida em 5 grupos (`NTILE(5)`) para as variáveis: `rating`, `rating_count`, `actual_price` e `discount_percentage`.

---

**2.3 Agrupamento por variáveis categóricas**

Dados agrupados por `main_category`, `sub_category` e produto, analisando `rating` e `rating_count` em cada nível.

---

**2.4 Medidas de dispersão**

Desvio padrão e variância calculados para as principais variáveis numéricas.

---

### 3. Técnicas de Análise

**3.1 Validação de hipóteses**

Hipóteses validadas via análise de correlação, quintis e visualizações no Power BI.

**3.2 Segmentação**

- Criada coluna `rating_range` classificando avaliações em faixas: `0-1`, `1-2`, `2-3`, `3-4`, `4-5`
- Criada coluna `average_quintile`: média arredondada dos quintis de `rating`, `rating_count`, `actual_price` e `discount_percentage` — representa o desempenho geral do produto

---

## Resultados

**Ranking de satisfação dos clientes por categoria:**

| Posição | Categoria | Destaque |
|---|---|---|
| 1º | Casa e Cozinha | Maior satisfação geral |
| 2º | Computadores e Acessórios | — |
| 3º | Eletrônicos | Maior portfólio (8,6M avaliações) |
| 4º | Produtos de Escritório | 100% com rating entre 4–5, mas apenas 31 produtos (2,29% do total) |

---

## Conclusões e Próximos Passos

**Conclusão**

A implementação do modelo de análise permite que a Amazon e seus fornecedores de dropshipping tomem decisões mais assertivas sobre portfólio de produtos. A categoria **Eletrônicos**, apesar de ser a maior em volume, fica em 3º lugar em satisfação — indicando oportunidade de melhoria na curadoria de produtos.

A **Matriz BCG** foi sugerida como ferramenta complementar para classificar produtos por participação de mercado e taxa de crescimento.

**Próximos passos**

Para evoluir o modelo, recomenda-se incorporar:

| Variável | Contribuição |
|---|---|
| Data e valor de venda | Identificar tendências de mercado e sazonalidade |
| Investimento do fornecedor | Calcular margem de lucro real |
| Análise de sentimento (NLP) | Aprofundar leitura de satisfação a partir dos textos de review |

Com esses dados, os três pilares da análise ganham maior precisão:

1. **Rentabilidade** — preço de venda, descontos *e margem de lucro real*
2. **Popularidade** — avaliações, classificação *e tendências de pesquisa ao longo do tempo*
3. **Satisfação** — pontuação média *e análise de sentimento via NLP*
