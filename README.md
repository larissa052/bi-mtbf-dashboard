# 🚀 Portfólio BI - Painel MTBF Caixa Econômica Federal

## 👩‍💻 Sobre o Projeto

Este repositório apresenta um projeto real de Business Intelligence desenvolvido para a **Caixa Econômica Federal** durante minha atuação como **Desenvolvedora de BI** na **Global Hitss Brasil**. O projeto implementa um sistema completo de monitoramento MTBF (Mean Time Between Failures) para análise de disponibilidade e confiabilidade dos sistemas bancários.

## 🎯 Objetivo do Projeto

Desenvolver um painel executivo para monitoramento em tempo real da disponibilidade dos sistemas críticos da CAIXA, permitindo:

- **Análise de MTBF** por sistema e período
- **Monitoramento de disponibilidade** em múltiplas dimensões
- **Identificação de padrões** de falhas e indisponibilidade
- **Suporte à tomada de decisão** para melhoria da infraestrutura

## 🏗️ Arquitetura da Solução

### Stack Tecnológica
- **Fonte de Dados:** Oracle Database 19c (aradmin.hpd_help_desk)
- **Processamento:** Azure Data Explorer (Kusto)
- **Visualização:** Power BI Service
- **Integração:** Azure Data Factory

### Fluxo de Dados
```
Oracle DB → Azure Data Factory → Azure Data Explorer → Power BI Service
```

## 📊 Modelo de Dados

### Estrutura Dimensional (Star Schema)
- **1 Tabela Fato:** TB_FATO_INCIDENTES (18.439 registros)
- **7 Dimensões:** Datas, Prioridades, Crise, Tipo Incidente, Sigla, Motivo Status, Impacto
- **5 Tabelas Intermediárias:** Otimização de performance com DAX avançado

### Principais Entidades

#### 📅 TB_DIMENSAO_DATAS
Hierarquia temporal completa com campos: DATA, ANO, MES_ANO, MES, DIA, TRIMESTRE, DATA_SEM_HORA

#### 🏢 TB_DIMENSAO_SIGLA
Catálogo de **170 sistemas únicos** monitorados (SIARP, SISIB, SIPEN, SITRC, SICOV, etc.)

#### ⚠️ TB_DIMENSAO_CRISE
Classificação detalhada: Crise, Grave, Atender, Monitorar, Indisponibilidade, Lentidão, etc.

#### 🎯 TB_DIMENSAO_PRIORIDADES
Níveis: Crítico (0), Alto (1)

#### 📈 TB_DIMENSAO_IMPACTO
Escalas: Extensivo (1000), Significativo (2000), Moderado (3000), Menor (4000)

## 💡 Inovações Técnicas

### 🔥 Medidas DAX Avançadas

#### Detecção Dinâmica de Contexto
```dax
Periodo_operacional = 
VAR AtributoFiltrado =
    SWITCH(
        TRUE(),
        CALCULATE(COUNTROWS(TB_INTERMEDIARIA_SIGLA), ALLSELECTED(...)) > 0, "Sigla",
        CALCULATE(COUNTROWS(TB_INTERMEDIARIA_CO_IMPACTO), ALLSELECTED(...)) > 0, "Impacto",
        // ... lógica para outras dimensões
        "Nenhum"
    )
RETURN SWITCH(AtributoFiltrado, ...)
```

#### Cálculo Complexo de Intervalos
```dax
Dias_Sem_Incidentes = 
VAR TB_ORDENADA = SUMMARIZE(TB_FATO_INCIDENTES, ...)
VAR DIAS_ENTRE_FALHAS = SUMX(TB_ORDENADA, 
    VAR DATA_ATUAL = TB_FATO_INCIDENTES[DATA_HORA_ABERTURA]
    VAR ULTIMO_FECHAMENTO = CALCULATE(MAX(...), FILTER(...))
    RETURN DATEDIFF(ULTIMO_FECHAMENTO, DATA_ATUAL, DAY)
)
RETURN DIAS_ENTRE_FALHAS
```

### 🚀 Tabelas Intermediárias com DAX
```dax
TB_INTERMEDIARIA_CO_IMPACTO = 
GENERATE(
    TB_DIMENSAO_DATAS,
    ADDCOLUMNS(
        VALUES(TB_FATO_INCIDENTES[CO_IMPACTO]),
        "QUANTIDADE_INCIDENTES",
        COALESCE(CALCULATE(
            DISTINCTCOUNT(TB_FATO_INCIDENTES[INCIDENT_NUMBER]),
            FILTER(TB_FATO_INCIDENTES, ...)
        ), 0)
    )
)
```

## 📈 Métricas Implementadas

### KPIs Principais
- **MTBF:** `([Periodo_total_Dias] - [Dias_com_Incidentes]) / [TOTAL_FALHAS]`
- **Disponibilidade por Sistema:** Análise granular dos 170 sistemas
- **Tempo de Recuperação:** Médio e por criticidade
- **Maior Período sem Falhas:** Análise de estabilidade

### Análises Multidimensionais
- ✅ Por sistema (170 sistemas únicos)
- ✅ Por período (diário, semanal, mensal, trimestral)
- ✅ Por criticidade (prioridade + impacto)
- ✅ Por tipo de serviço
- ✅ Por horário de funcionamento

## 🎨 Interface e Visualização

### Layout do Painel
- **Cabeçalho:** Branding CAIXA + seletor de período
- **Filtros Laterais:** Dropdown para Serviço, Crise/Grave, Impacto, Prioridade, Motivo
- **KPIs Principais:** 3 cartões com métricas centrais
- **Gráfico Central:** Tendência MTBF ao longo do tempo
- **Tabelas Detalhadas:** Incidentes e configurações

### Paleta de Cores
Seguindo **guidelines da Caixa Econômica Federal**:
- Azul institucional (#003366)
- Laranja complementar (#FF6600)
- Interface profissional bancária

## 🔧 Complexidade Técnica

### Queries SQL Avançadas
```sql
-- Exemplo: Dimensão de Datas com hierarquia completa
SELECT
    data,
    EXTRACT(YEAR FROM data) ano,
    TO_CHAR(data,'MM/YYYY') mes_ano,
    EXTRACT(MONTH FROM data) mes,
    TO_CHAR(data,'Q') trimestre
FROM (
    SELECT TO_DATE('01-JAN-2024','DD-MM-YYYY') + level - 1 AS data
    FROM dual
    CONNECT BY level <= (TO_DATE('31-12-2024','DD-MM-YYYY') - TO_DATE('01-01-2024','DD-MM-YYYY')) + 1
)
```

### Otimizações de Performance
- **Tabelas intermediárias** para pré-agregações
- **Relacionamentos otimizados** (1:N)
- **Índices estratégicos** nas chaves de relacionamento
- **Particionamento** da tabela fato por data

## 📊 Resultados e Impacto

### Métricas de Sucesso
- **170 sistemas** monitorados simultaneamente
- **18.439 incidentes** analisados
- **Tempo real** de atualização via Azure Data Explorer
- **Múltiplas dimensões** de análise implementadas

### Benefícios Entregues
- ✅ **Visibilidade completa** da disponibilidade dos sistemas
- ✅ **Identificação proativa** de padrões de falha
- ✅ **Suporte à decisão** para investimentos em infraestrutura
- ✅ **Compliance** com SLAs bancários

## 🛠️ Competências Demonstradas

### Técnicas Avançadas
- **Modelagem dimensional** para ambientes corporativos
- **DAX avançado** com detecção dinâmica de contexto
- **Integração de dados** Oracle → Azure → Power BI
- **Otimização de performance** em grandes volumes
- **Métricas de confiabilidade** para sistemas críticos

### Metodologias Aplicadas
- **Kimball Methodology** para data warehousing
- **Agile BI** para desenvolvimento iterativo
- **DevOps** para integração e deploy
- **Data Governance** para qualidade dos dados

## 📁 Estrutura do Repositório

```
portfolio-mtbf-caixa/
├── README.md                          # Este arquivo
├── docs/
│   ├── arquitetura.md                 # Documentação da arquitetura
│   ├── metodologia.md                 # Metodologia de desenvolvimento
│   ├── medidas_dax_reais.md          # Medidas DAX implementadas
│   └── data_dictionary_real.md       # Dicionário de dados completo
├── sql/
│   └── queries/                       # Queries SQL das dimensões
│       ├── dimensao_datas.sql
│       ├── dimensao_prioridades.sql
│       ├── dimensao_crise.sql
│       ├── dimensao_tipo_incidente.sql
│       ├── dimensao_sigla.sql
│       ├── dimensao_motivo_status.sql
│       ├── dimensao_impacto.sql
│       └── fato_incidentes.sql
├── data/
│   ├── sample_data.csv               # Dados sintéticos para demonstração
│   └── data_dictionary_real.md       # Dicionário de dados
├── images/
│   ├── arquitetura_solucao.png       # Diagrama de arquitetura
│   ├── modelo_dados.png              # Modelo dimensional
│   └── layout_mtbf_dashboard.png     # Layout do painel
└── powerbi/
    └── (arquivos .pbix mascarados)   # Arquivos Power BI
```

## 🎓 Contexto Profissional

### Empresa: Global Hitss Brasil
**Cargo:** Desenvolvedora de Business Intelligence  
**Cliente:** Caixa Econômica Federal  
**Período:** 2024  

### Responsabilidades
- Desenvolvimento de soluções BI end-to-end
- Modelagem dimensional de data warehouses
- Criação de dashboards executivos
- Otimização de performance em grandes volumes
- Integração com sistemas legados bancários

## 🔒 Nota sobre Confidencialidade

Este projeto utiliza **dados mascarados** e **estruturas anonimizadas** para preservar a confidencialidade das informações da Caixa Econômica Federal. Todas as implementações técnicas e metodologias são reais e demonstram as competências aplicadas no projeto original.

## 📞 Contato

**LinkedIn:** https://www.linkedin.com/in/larissa-lima-304146112/
**Email:** soylarissa@gmail.com
**GitHub:** larissa052

---

*Este portfólio demonstra expertise avançada em Business Intelligence, desde a concepção arquitetural até a implementação de soluções complexas em ambiente bancário de grande porte.*

