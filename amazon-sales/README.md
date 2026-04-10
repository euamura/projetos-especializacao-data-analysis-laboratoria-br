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

Duas tabelas foram importadas no BigQuery: `amazon_product` e `amazon_review`.

- **1.1** Importação dos dados no BigQuery
- **1.2** Identificação e tratamento de valores nulos — `about_product` (4 nulos), `img_link` e `product_link` (466 cada), `rating_count` (2, removidos por serem variável-chave)
- **1.3** Remoção de duplicatas via `ROW_NUMBER() OVER (PARTITION BY)`
- **1.4** Gestão de dados fora do escopo — seleção das colunas relevantes à análise

**Escopo de colunas selecionadas:**

![Escopo de variáveis — produto](https://github.com/user-attachments/assets/8b17b9bd-7cfe-4176-988c-c8f5235da231)
![Escopo de variáveis — review](https://github.com/user-attachments/assets/ac30a25f-4725-4a4d-93a3-3e92d4f8c31a)

- **1.5** Tratamento de dados discrepantes em variáveis categóricas — remoção de registro com `rating = '|'` e normalização de texto em `review_title` e `review_content`

![Dado discrepante em rating](https://github.com/user-attachments/assets/346a84b8-362a-42a7-9776-cda48be93345)
![Dados de review com emojis e formatos variados](https://github.com/user-attachments/assets/a5cbc818-00c6-48ab-a345-31b01779a475)

- **1.6** Verificação de dados discrepantes em variáveis numéricas — sem outliers a tratar
- **1.7** Conversão do tipo de `rating` de `STRING` para `FLOAT64`
- **1.8** Criação de novas variáveis: `main_category` e `sub_category` a partir do split da coluna `category`
- **1.9** União das tabelas `amazon_product_clean` e `amazon_review_clean` via `LEFT JOIN` em `product_id`

> Todas as queries estão documentadas em [`queries.sql`](./queries.sql).

---

### 2. Análise Exploratória

**2.1 Correlação entre variáveis**

![Correlação entre variáveis](https://github.com/user-attachments/assets/03ea0345-3734-4caf-a4d2-0de9882ddf77)

**2.2 Quintis e medidas de tendência central**

![Quintil — rating](https://github.com/user-attachments/assets/84a4b270-1f3a-45a3-8258-18d1e294df20)
![Quintil — rating_count](https://github.com/user-attachments/assets/4f1d3491-7db3-4f14-a4a2-c6588a972366)
![Quintil — actual_price](https://github.com/user-attachments/assets/53269ae9-f95c-4adf-830a-36ab27ab25f2)
![Quintil — discount_percentage](https://github.com/user-attachments/assets/9094f435-dff5-41b9-a7aa-27b123ad9e7f)

**2.3 Agrupamento por variáveis categóricas**

![Rating e rating_count por categoria](https://github.com/user-attachments/assets/c1ec6c28-d3fc-4a88-8fb1-4c13df960a3c)
![Rating e rating_count por subcategoria](https://github.com/user-attachments/assets/4464e280-bed7-4732-bc9f-950f44928ef1)
![Rating e rating_count por produto](https://github.com/user-attachments/assets/71abd93d-68ec-4c08-856e-c8ac54c0f121)
![Distribuição de nulos](https://github.com/user-attachments/assets/592613cb-a062-4f6e-8779-da5d0bc07b80)
![Distribuição de nulos 2](https://github.com/user-attachments/assets/5e81d959-e239-4378-a619-8f6d82a7dcd8)

**2.4 Medidas de dispersão**

![Dispersão 1](https://github.com/user-attachments/assets/599615fc-ca71-4d3d-a3ea-bb37f48f9e70)
![Dispersão 2](https://github.com/user-attachments/assets/a9bd52fd-87ef-4b12-b6ce-ec45eac44149)
![Dispersão 3](https://github.com/user-attachments/assets/6234b4d2-a0e7-4ab6-be06-1fc3c6eacfbc)
![Dispersão 4](https://github.com/user-attachments/assets/a074c6b9-8991-46ae-bde5-aaaa6228cbe7)

---

### 3. Técnicas de Análise

**3.1 Validação de hipóteses**

![Hipótese 1](https://github.com/user-attachments/assets/14a1e7db-187d-4593-9ac1-f941efc564e1)
![Hipótese 2](https://github.com/user-attachments/assets/b7208118-b78d-4f1a-9485-751b51ad70fc)
![Hipótese 3](https://github.com/user-attachments/assets/09c105e2-eb5e-4d52-a929-d1e17b5d9ff0)
![Hipótese 4](https://github.com/user-attachments/assets/3dac41bb-d31e-4249-9783-f95af7af0beb)

**3.2 Segmentação** — classificação das avaliações em faixas (`0-1`, `1-2` ... `4-5`) e cálculo do `average_quintile` por produto, combinando `rating`, `rating_count`, `actual_price` e `discount_percentage`.

---

## Resultados

![Dashboard](https://github.com/user-attachments/assets/e22a5cd4-f512-4cde-b3b0-72d459638a9a)

**Tabela de resumo por categoria**

![Resumo por categoria](https://github.com/user-attachments/assets/f84941be-259e-4d7a-a2ff-70b182c21744)

Ranking de satisfação dos clientes por categoria:

| Posição | Categoria | Destaque |
|---|---|---|
| 1º | Casa e Cozinha | Maior satisfação geral |
| 2º | Computadores e Acessórios | — |
| 3º | Eletrônicos | Maior portfólio (8,6M avaliações) |
| 4º | Produtos de Escritório | 100% com rating entre 4–5, mas apenas 31 produtos (2,29% do total) |

---

## Conclusões e Próximos Passos

A análise viabiliza a construção de um modelo de desempenho de produto com base em rentabilidade, popularidade e satisfação. Para evoluir o modelo, recomenda-se incorporar:

- **Data e valor de venda** — identificar tendências de mercado
- **Investimento do fornecedor** — calcular margem de lucro real
- **Análise de sentimento (NLP)** — aprofundar a leitura de satisfação

Com dados complementares, é possível desenvolver uma **Matriz BCG automatizada**, classificando produtos por participação de mercado e taxa de crescimento para orientar decisões estratégicas de portfólio.
