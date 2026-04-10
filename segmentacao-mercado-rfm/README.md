# Segmentação de Mercado — Modelo RFM

Segmentação de clientes utilizando o modelo **RFM (Recência, Frequência e Valor Monetário)** para identificar perfis de comportamento de compra e apoiar estratégias de marketing e retenção.

> Projeto realizado durante o Bootcamp de Especialização em Data Analysis da [Laboratória Brasil](https://www.laboratoria.la/br).

---

## Sumário

- [Contexto](#contexto)
- [Objetivo](#objetivo)
- [Metodologia](#metodologia)
- [Ferramentas](#ferramentas)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Links](#links)

---

## Contexto

Empresas com bases de clientes ativas precisam entender o comportamento de compra para direcionar ações de marketing de forma eficiente. A segmentação RFM permite classificar clientes com base em três dimensões comportamentais:

- **Recência (R):** há quanto tempo o cliente realizou a última compra
- **Frequência (F):** com que frequência o cliente compra
- **Valor Monetário (M):** quanto o cliente gasta no total

---

## Objetivo

Segmentar a base de clientes em grupos com comportamentos distintos, permitindo identificar clientes de alto valor, clientes em risco de churn e oportunidades de reativação.

---

## Metodologia

1. **Processamento dos dados** — limpeza e preparação das tabelas de clientes, transações e resumo de compras
2. **Cálculo das métricas RFM** — extração de recência, frequência e valor monetário por cliente
3. **Segmentação por quartis** — classificação dos clientes em grupos com base nas pontuações RFM
4. **Análise e visualização** — identificação dos perfis e recomendações estratégicas

---

## Ferramentas

![BigQuery](https://img.shields.io/badge/SQL-BigQuery-4285F4?style=flat&logo=googlebigquery&logoColor=white)
![Google Sheets](https://img.shields.io/badge/Google%20Sheets-Análise-34A853?style=flat&logo=googlesheets&logoColor=white)
![PowerPoint](https://img.shields.io/badge/PowerPoint-Apresentação-B7472A?style=flat&logo=microsoftpowerpoint&logoColor=white)

---

## Estrutura do repositório

```
segmentacao-mercado-rfm/
├── README.md
├── dashboard-analise-rfm.xlsx
├── dashboard-analise-rfm.csv
├── apresentacao/
│   └── Laboratoria-projeto-1-segmentacao.pptx
└── data/
    ├── raw/
    │   ├── clientes.csv
    │   ├── resumo_compras.csv
    │   └── transacoes.csv
    └── processed/
        └── LaboratoriaBR_RFM_Market_Project_Stg.xlsx
```

---

## Links

| Recurso | Link |
|---|---|
| Apresentação de negócio | `apresentacao/Laboratoria-projeto-1-segmentacao.pptx` |

---

*Projeto desenvolvido para fins educacionais e de portfólio.*
