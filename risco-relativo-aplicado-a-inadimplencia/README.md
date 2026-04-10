# Risco relativo aplicado à inadimplência — Super Caja

Análise de risco de crédito com foco na identificação de perfis de clientes com maior probabilidade de inadimplência, utilizando risco relativo, score de crédito e segmentação por quartis.

> Projeto realizado em 2024 durante o Bootcamp de Especialização em Data Analysis da [Laboratória Brasil](https://www.laboratoria.la/br).

---

## Sumário

- [Contexto](#contexto)
- [Objetivo](#objetivo)
- [Metodologia](#metodologia)
- [Principais insights](#principais-insights)
- [Ferramentas](#ferramentas)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Links](#links)

---

## Contexto

Com a queda das taxas de juros, o banco fictício **Super Caja** registrou um aumento expressivo na demanda por crédito. O processo manual de análise tornou-se lento e ineficiente, elevando o risco de concessão de crédito a maus pagadores.

Para resolver isso, o banco propôs **automatizar a análise de crédito** com base em dados históricos de clientes, usando técnicas estatísticas — entre elas, o **risco relativo**.

---

## Objetivo

Identificar quais grupos de clientes apresentam maior risco de inadimplência com base em variáveis financeiras e comportamentais, construindo um **score de crédito** que permita classificar clientes em perfis de baixo e alto risco.

**Variáveis analisadas:**

| Variável | Descrição |
|---|---|
| `age` | Idade do cliente |
| `last_month_salary` | Salário do último mês |
| `debt_ratio` | Relação dívida/renda |
| `using_lines_not_secured_personal_assets` | Uso de linhas de crédito sem garantia |
| `more_90_days_overdue` | Atrasos acima de 90 dias |
| `total_loan` | Quantidade total de empréstimos |

---

## Metodologia

### 1. Processamento e preparação dos dados

- Importação das tabelas no BigQuery (`default`, `loans_detail`, `loans_outstanding`, `user_info`)
- Identificação e tratamento de valores nulos com `COALESCE`
- Remoção de duplicatas com `ROW_NUMBER() OVER (PARTITION BY)`
- Padronização de variáveis categóricas (`loan_type`) com `LOWER`
- Conversão de tipos de dados (`CAST`)
- Criação de variáveis derivadas (`total_loan`, `num_real_estate`, `num_other`)
- União das tabelas com `LEFT JOIN`

### 2. Análise exploratória (EDA)

- Cálculo de quartis com `NTILE(4)` para as principais variáveis
- Correlação de Pearson entre variáveis numéricas e `default_flag`

**Resultados de correlação com inadimplência:**

| Variável | Correlação |
|---|---|
| `more_90_days_overdue` | 0,30 |
| `number_times_delayed_payment_loan_30_59_days` | 0,29 |
| `number_times_delayed_payment_loan_60_89_days` | 0,27 |
| `last_month_salary` | -0,02 |
| `total_loan` | -0,04 |

### 3. Cálculo do risco relativo

O risco relativo (RR) mede a chance de um cliente se tornar inadimplente em relação a um grupo de referência.

- **RR > 1** → maior risco de inadimplência
- **RR < 1** → menor risco
- **RR = 1** → risco equivalente

As variáveis foram ordenadas pela quantidade de inadimplentes com RR ≥ 1:

| Variável | Inadimplentes com RR ≥ 1 |
|---|---|
| `using_lines_not_secured_personal_assets` | 674 |
| `more_90_days_overdue` | 643 |
| `age` | 512 |
| `last_month_salary` | 439 |
| `debt_ratio` | 381 |

**Quartis com RR ≥ 1 (perfil de mau pagador):**

| Variável | Quartis de risco |
|---|---|
| `age` | Q1 e Q2 (clientes mais jovens) |
| `last_month_salary` | Q1 e Q2 (menor salário) |
| `using_lines_not_secured_personal_assets` | Q4 (maior uso) |
| `more_90_days_overdue` | Q4 (mais atrasos) |

### 4. Validação de hipóteses

| Hipótese | Resultado | RR | Conclusão |
|---|---|---|---|
| Clientes mais jovens têm maior risco de inadimplência | Alternativa confirmada | 0,15 (Q4 vs Q1) | Clientes jovens têm 85% mais chance de inadimplir |
| Mais empréstimos ativos = maior risco | Nula — hipótese rejeitada | 0,34 | Clientes com menos empréstimos têm 66% mais risco |
| Atrasos > 90 dias aumentam o risco | Alternativa confirmada | 0,01 (Q4 vs Q1) | Forte correlação entre atrasos e inadimplência |

### 5. Score de crédito e segmentação

Criação de variáveis dummy para cada perfil de risco, somadas em um **score de 0 a 4**. Clientes com score = 4 foram classificados como **alto risco**.

**Pontuação final (escala positiva):**

| Score | Pontuação |
|---|---|
| 0 | 1000 |
| 1 | 800 |
| 2 | 600 |
| 3 | 400 |
| 4 | 200 |

A segmentação foi avaliada com **matriz de confusão** para medir a precisão do modelo.

---

## Principais insights

- Clientes **mais jovens** apresentaram maior taxa de inadimplência
- **Baixo salário** e **alto uso de crédito sem garantia** são os fatores de maior peso no risco
- **Atrasos acima de 90 dias** têm forte correlação com inadimplência futura
- Clientes com **menos empréstimos ativos** têm, surpreendentemente, maior risco — possivelmente por menor histórico de crédito
- O modelo final classifica clientes em faixas de risco com alta precisão, apoiando a decisão de concessão de crédito

---

## Ferramentas

![SQL](https://img.shields.io/badge/SQL-BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![Python](https://img.shields.io/badge/Python-Google%20Colab-3776AB?style=flat&logo=python&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker%20Studio-Dashboard-4285F4?style=flat&logo=google&logoColor=white)

---

## Estrutura do repositório

```
risco-relativo-aplicado-a-inadimplencia/
├── README.md
└── risco_relativo.sql      ← queries completas: ETL, EDA, RR, score e segmentação
```

---

## Links

| Recurso | Link |
|---|---|
| Dashboard Looker Studio | [Acessar dashboard](https://lookerstudio.google.com/reporting/173aef6d-66e5-4f47-b7a5-673459f34794) |
| Apresentação em vídeo (Loom) | [Assistir apresentação](https://www.loom.com/share/098dd33d3aa6404f89713e53288cc549) |
| Análise em Python (Colab) | [Abrir no Colab](https://colab.research.google.com/drive/bc1qf92drq0wwm8w7rnw9d8p4wjvaut2csdd5sg2cx-Db2ci) |
| Dataset original | [Google Drive](https://drive.google.com/file/d/bc1qf92drq0wwm8w7rnw9d8p4wjvaut2csdd5sg2cx/view) |
| Documento de análise | [Google Docs](https://docs.google.com/document/d/1q6UPnF3SMgHFcuAsy5DrRsiHGHBxb0qA1aut1Y9daEE/edit) |

---

*Projeto desenvolvido para fins educacionais e de portfólio. Demonstra a aplicação de técnicas de análise de dados e estatística ao contexto financeiro.*
