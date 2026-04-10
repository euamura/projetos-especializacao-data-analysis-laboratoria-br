# Projeção de Pipeline
---
![Ingestao Visual](ingestao_pipeline.png)
---

## 1. Ingestão
- Automatizar o upload dos arquivos CSV para o Google Cloud Storage diariamente.
- Configurar um script Python que capture diariamente dados de concorrentes e salve em um arquivo CSV ou diretamente no Google Cloud Storage.

## 2. Armazenamento
- Criar scripts de importação que leiam os arquivos CSV do Google Cloud Storage e carreguem os dados em tabelas *staging* no BigQuery.

## 3. Processamento e Transformação dos Dados
- Criar consultas SQL no BigQuery para gerar *views* combinando as tabelas temporárias.
- Realizar cálculos como:
  - Média de preço  
  - Quantidade de produtos por pedido  
  - Estoque crítico  
  - Variação de preço  

## 4. Validação dos Dados
- Criar queries SQL para validar a qualidade dos dados, identificando:
  - Valores fora do escopo  
  - Registros duplicados  

## 5. Carga dos Dados Atualizados
- Criar tabelas materializadas no BigQuery contendo os dados finais, métricas calculadas e informações enriquecidas da concorrência.

## 6. Exportação para o Power BI
- Configurar a conexão entre Power BI e BigQuery utilizando a API do Google.

## 7. Visualização e Dashboard no Power BI
- Criar o dashboard com visualizações relevantes.

## 8. Automatização do Pipeline
- Agendar as importações dos CSVs e o web scraping com Google Cloud Functions.
- Configurar as atualizações automáticas no Power BI após cada carga no BigQuery.

## 9. Monitoramento e Alertas
- Configurar alertas no Power BI para enviar notificações por e-mail sobre KPIs críticos.

---

## **Ferramentas Utilizadas no Pipeline**

### 1. Ingestão
- **Python (Web Scraping)**: BeautifulSoup  
- **Google Cloud Storage**: Armazenamento de arquivos CSV

### 2. Armazenamento e Processamento
- **Google BigQuery**: Transformação e armazenamento de dados

### 3. Exportação e Visualização
- **Power BI**: Dashboards e relatórios

### 4. Automatização
- **Google Cloud Functions**: Agendamento e execução automática

### 5. Monitoramento
- **Power BI Alerts**: Alertas de KPIs


