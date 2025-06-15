# Arquitetura da Solução MTBF

## Visão Geral da Arquitetura

A solução de monitoramento MTBF foi projetada seguindo uma arquitetura moderna de Business Intelligence, integrando múltiplas camadas de processamento de dados para garantir performance, escalabilidade e confiabilidade.

## Camadas da Arquitetura

### 1. Camada de Dados (Data Layer)

#### Fonte Primária: Oracle Database
- **Versão:** Oracle 19c Enterprise Edition
- **Função:** Armazenamento transacional dos dados operacionais
- **Tabelas Principais:**
  - `TB_INCIDENTES` - Registro de todos os incidentes
  - `TB_SISTEMAS` - Catálogo de sistemas monitorados
  - `TB_SERVICOS` - Definição dos serviços bancários
  - `TB_LOGS_OPERACAO` - Logs detalhados de operações

#### Azure Data Explorer (Kusto)
- **Função:** Processamento de dados em tempo real
- **Capacidade:** Análise de séries temporais em alta velocidade
- **Integração:** Ingestão contínua via pipelines automatizados

### 2. Camada de Integração (Integration Layer)

#### ETL/ELT Processes
- **Ferramenta:** Azure Data Factory + Custom SQL Procedures
- **Frequência:** Execução a cada 15 minutos para dados críticos
- **Transformações:**
  - Cálculo de métricas MTBF em tempo real
  - Agregações por diferentes granularidades temporais
  - Limpeza e validação de dados

#### Data Pipeline
```
Oracle DB → Azure Data Factory → Azure Data Explorer → Power BI
     ↓
Stored Procedures → Views Materializadas → Cache Layer
```

### 3. Camada de Apresentação (Presentation Layer)

#### Power BI Service
- **Modelo:** DirectQuery + Import híbrido
- **Refresh:** Automático a cada 30 minutos
- **Segurança:** Row-level security implementada
- **Performance:** Agregações automáticas configuradas

## Modelo de Dados

### Estrutura Dimensional

#### Tabelas de Fato
- **FATO_MTBF_DIARIO** - Métricas diárias consolidadas
- **FATO_INCIDENTES** - Detalhes de cada incidente

#### Tabelas de Dimensão
- **DIM_TEMPO** - Hierarquia temporal completa
- **DIM_SISTEMA** - Catálogo de sistemas
- **DIM_SERVICO** - Serviços bancários
- **DIM_IMPACTO** - Classificação de impacto
- **DIM_PRIORIDADE** - Níveis de prioridade

### Relacionamentos
- Modelo estrela (Star Schema) otimizado
- Relacionamentos 1:N entre dimensões e fatos
- Chaves surrogate para performance

## Tecnologias e Ferramentas

### Banco de Dados
- **Oracle 19c** - SGBD principal
- **PL/SQL** - Stored procedures e funções
- **Oracle Partitioning** - Otimização de consultas

### Processamento
- **Azure Data Explorer** - Análise em tempo real
- **KQL (Kusto Query Language)** - Consultas analíticas
- **Azure Data Factory** - Orquestração de pipelines

### Visualização
- **Power BI Premium** - Dashboards e relatórios
- **DAX** - Medidas e cálculos avançados
- **Power Query** - Transformação de dados

## Considerações de Performance

### Otimizações Implementadas
- **Índices especializados** em colunas de data/hora
- **Particionamento temporal** das tabelas de fato
- **Views materializadas** para consultas frequentes
- **Cache inteligente** no Power BI

### Monitoramento
- **Alertas automáticos** para degradação de performance
- **Métricas de utilização** em tempo real
- **Logs detalhados** de execução de queries

## Segurança e Governança

### Controle de Acesso
- **Active Directory** integrado
- **Row-level security** por área de negócio
- **Auditoria completa** de acessos e modificações

### Backup e Recuperação
- **Backup automático** diário
- **Replicação** para ambiente de contingência
- **RTO:** 4 horas | **RPO:** 1 hora

## Escalabilidade

### Dimensionamento Horizontal
- **Particionamento** por período temporal
- **Distribuição** de carga entre servidores
- **Auto-scaling** baseado em demanda

### Capacidade Atual
- **Volume de dados:** 500GB+ de dados históricos
- **Throughput:** 10.000+ registros/minuto
- **Usuários concorrentes:** 200+ usuários simultâneos

