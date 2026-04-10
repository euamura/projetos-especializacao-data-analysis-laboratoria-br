# Introdução

A gestão eficiente de dados tornou-se crucial para o sucesso das organizações. A Super Store, líder em seu setor, enfrenta o desafio de gerenciar grandes volumes de dados dispersos e desestruturados. Para resolver esse problema e melhorar a tomada de decisões, propõe-se a implementação de um sistema ETL robusto (Extract, Transform, Load ou em português: Extrair, Transformar e Carregar) com tabelas de fatos e dimensões.

Este projeto foca na criação de um sistema abrangente que permita extrair dados de diversas fontes, transformá-los de acordo com as necessidades específicas da Super Store e carregá-los de forma eficiente em um data warehouse organizado.

---

# Objetivos

O objetivo deste projeto não é apenas otimizar o armazenamento de dados, mas também aumentar a capacidade da Super Store de identificar padrões, tendências e oportunidades de mercado. Com um sistema ETL bem projetado, a empresa estará melhor preparada para se adaptar rapidamente às mudanças na demanda do consumidor, melhorar a eficiência operacional e manter uma vantagem competitiva em um mercado em constante evolução.

---

# Ferramentas
- Google BigQuery
- Planilhas Google ou Python e Google Colab
- Power BI para análise exploratória dos dados e visualização

---

# Linguagens
- SQL no BigQuery
- Python no Google Colab

---

# Contexto e Motivação

A Super Store, sendo líder de mercado, possui um volume crescente de dados originados de múltiplas fontes, como sistemas de vendas, marketing digital, inventário e atendimento ao cliente. Esses dados são muitas vezes armazenados em sistemas distintos e desestruturados, dificultando uma visão integrada do negócio. A implementação de um sistema ETL permitirá a centralização e organização dos dados, facilitando a análise e a geração de insights. A motivação principal é habilitar a Super Store a tomar decisões baseadas em dados de forma mais rápida e precisa.

---

# Fontes de Dados
- Documento CSV SuperStore disponibilizado na plataforma da LAB
- Base de dados de mercados multinacionais (https://en.wikipedia.org/wiki/List_of_supermarket_chains)

---

# Metodologia
- **Extração:** Extração dos dados em CSV da plataforma LAB e Web Scraping  
- **Carregamento:** Carregamento dos dados no BigQuery  
    - Modelagem de dados  
        - Projeção tabelas de fatos e tabelas de dimensões  
        - Criação tabelas de fatos e tabelas de dimensões no BigQuery  
- **Transformação:** Tratamento de dados  
    - Identificar Nulos  
    - Identificar duplicatas  
    - Identificar e tratar inconsistências de dados  
    - Identificar se é necessário alterar o tipo de dados de alguma variável  
- **Pipeline de Dados:**  
    - Projeção de pipeline de atualização de dados  
- **EDA:**  
    - Conexão dos dados ao Power BI  
    - Análise exploratória dos dados  
        - Agrupar dados de acordo com variáveis categóricas  
        - Visualizar as variáveis categóricas  
        - Aplicar medidas de tendência central  
        - Visualizar distribuição  
        - Aplicar medidas de dispersão  
        - Ver o comportamento dos dados ao longo do tempo  
    - Criação de dashboard

---

# Análises Realizadas
- **Análise de Qualidade de Dados:** Durante a fase de transformação, identifiquei e corrigi inconsistências nos dados.
- **Modelagem de Dados:** Criação do modelo dimensional para o Data Warehouse, definindo as tabelas de fatos e dimensões.

---

# Resultados
- Centralização das fontes de dados em um único Data Warehouse
- Transformação melhorou a qualidade dos dados corrigindo inconsistências
- A nova estrutura permitiu a criação de dashboards que oferecem insights em tempo real

---

# Conclusão e Recomendações

## Conclusão
A implementação do sistema ETL proporciona à Super Store uma base de dados estruturada e consolidada que facilita a análise de informações estratégicas. Criando o acesso a dados precisos e centralizados, otimizando o processo.

## Recomendações
- **Monitoramento Contínuo:** Estabelecer uma rotina de monitoramento da qualidade dos dados automatizada.
- **Escalabilidade:** Considerar a expansão do sistema ETL para incluir novas fontes de dados.

---
