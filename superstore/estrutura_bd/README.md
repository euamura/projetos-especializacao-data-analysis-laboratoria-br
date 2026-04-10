## 📐 Modelagem Dimensional — Estrutura do Banco de Dados

![Diagrama do Modelo de Dados](images/diagrama.png)

A imagem acima apresenta o **modelo dimensional** utilizado no projeto, estruturado no formato **Star Schema** para otimizar análises, agregações e consultas em ambientes de Business Intelligence.

### 🏛️ Tabela Fato  
**`fact_orders`**  
Armazena os eventos transacionais com granularidade nível **pedido**.  
Atributos e métricas principais:
- `order_id`  
- `order_date`  
- `discount`  
- `quantity`  
- `profit`  
- `product_id`  
- `customer_id`  
- `local_id`  
- `order_priority`

### 📚 Tabelas Dimensão  
As dimensões fornecem contexto e enriquecem as análises realizadas sobre a tabela fato.

**`dim_products`**  
- `product_id`  
- `product_name`  
- `category`  
- `sub_category`

**`dim_customers`**  
- `customer_id`  
- `customer_name`  
- `segment`

**`dim_local`**  
- `local_id`  
- `city`  
- `state`  
- `country`  
- `region`  
- `market`

### 🔗 Relacionamentos  
Todos os relacionamentos seguem o padrão **1 para N (1:N)**, garantindo integridade referencial e consistência analítica:

- **dim_products (1) → fact_orders (N)** via `product_id`  
- **dim_customers (1) → fact_orders (N)** via `customer_id`  
- **dim_local (1) → fact_orders (N)** via `local_id`

Esse modelo facilita análises multidimensionais e garante alta performance para dashboards, relatórios e exploração de dados.
