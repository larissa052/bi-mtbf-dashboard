# 🚀 BI Portfolio - MTBF Dashboard for Caixa Econômica Federal

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Oracle](https://img.shields.io/badge/Oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-FF6600?style=for-the-badge&logo=powerbi&logoColor=white)

![Enterprise](https://img.shields.io/badge/Enterprise-Grade-success?style=flat-square)
![Banking](https://img.shields.io/badge/Banking-Sector-blue?style=flat-square)
![Real Project](https://img.shields.io/badge/Real-Project-brightgreen?style=flat-square)
![170+ Systems](https://img.shields.io/badge/170+-Systems-orange?style=flat-square)
![18K+ Records](https://img.shields.io/badge/18K+-Records-red?style=flat-square)

## 👩‍💻 About the Project

This repository showcases a **real-world Business Intelligence project** developed for **Caixa Econômica Federal** (Brazil's largest public bank) during my role as **BI Developer** at **Global Hitss Brasil**. The project implements a comprehensive MTBF (Mean Time Between Failures) monitoring system for analyzing availability and reliability of critical banking systems.

## 🎯 Project Objectives

Develop an executive dashboard for real-time monitoring of CAIXA's critical systems availability, enabling:

- **MTBF Analysis** by system and time period
- **Availability Monitoring** across multiple dimensions  
- **Failure Pattern Identification** and downtime analysis
- **Decision Support** for infrastructure improvement initiatives

## 🏗️ Solution Architecture

### Technology Stack
- **Data Source:** Oracle Database 19c (aradmin.hpd_help_desk)
- **Processing:** Azure Data Explorer (Kusto)
- **Visualization:** Power BI Service
- **Integration:** Azure Data Factory

### Data Flow
```
Oracle DB → Azure Data Factory → Azure Data Explorer → Power BI Service
```

## 📊 Data Model

### Dimensional Structure (Star Schema)
- **1 Fact Table:** TB_FATO_INCIDENTES (18,439 records)
- **7 Dimensions:** Dates, Priorities, Crisis, Incident Type, System Code, Status Reason, Impact
- **5 Intermediate Tables:** Performance optimization with advanced DAX

### Key Entities

#### 📅 TB_DIMENSAO_DATAS
Complete temporal hierarchy with fields: DATA, ANO, MES_ANO, MES, DIA, TRIMESTRE, DATA_SEM_HORA

#### 🏢 TB_DIMENSAO_SIGLA  
Catalog of **170 unique systems** monitored (SIARP, SISIB, SIPEN, SITRC, SICOV, etc.)

#### ⚠️ TB_DIMENSAO_CRISE
Detailed classification: Crisis, Severe, Attend, Monitor, Unavailability, Slowness, etc.

#### 🎯 TB_DIMENSAO_PRIORIDADES
Levels: Critical (0), High (1)

#### 📈 TB_DIMENSAO_IMPACTO
Scales: Extensive (1000), Significant (2000), Moderate (3000), Minor (4000)

## 💡 Technical Innovations

### 🔥 Advanced DAX Measures

#### Dynamic Context Detection
```dax
Periodo_operacional = 
VAR AtributoFiltrado =
    SWITCH(
        TRUE(),
        CALCULATE(COUNTROWS(TB_INTERMEDIARIA_SIGLA), ALLSELECTED(...)) > 0, "Sigla",
        CALCULATE(COUNTROWS(TB_INTERMEDIARIA_CO_IMPACTO), ALLSELECTED(...)) > 0, "Impacto",
        // ... logic for other dimensions
        "Nenhum"
    )
RETURN SWITCH(AtributoFiltrado, ...)
```

#### Complex Interval Calculations
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

### 🚀 Intermediate Tables with DAX
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

## 📈 Implemented Metrics

### Key KPIs
- **MTBF:** `([Periodo_total_Dias] - [Dias_com_Incidentes]) / [TOTAL_FALHAS]`
- **System Availability:** Granular analysis of 170 systems
- **Recovery Time:** Average and by criticality
- **Longest Period Without Failures:** Stability analysis

### Multidimensional Analysis
- ✅ By system (170 unique systems)
- ✅ By time period (daily, weekly, monthly, quarterly)
- ✅ By criticality (priority + impact)
- ✅ By service type
- ✅ By operating hours

## 🎨 Interface and Visualization

### Dashboard Layout
- **Header:** CAIXA branding + period selector
- **Side Filters:** Dropdown for Service, Crisis/Severe, Impact, Priority, Reason
- **Main KPIs:** 3 cards with central metrics
- **Central Chart:** MTBF trend over time
- **Detailed Tables:** Incidents and configurations

### Color Palette
Following **Caixa Econômica Federal guidelines**:
- Institutional blue (#003366)
- Complementary orange (#FF6600)
- Professional banking interface

## 🔧 Technical Complexity

### Advanced SQL Queries
```sql
-- Example: Date Dimension with complete hierarchy
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

### Performance Optimizations
- **Intermediate tables** for pre-aggregations
- **Optimized relationships** (1:N)
- **Strategic indexes** on relationship keys
- **Fact table partitioning** by date

## 📊 Results and Impact

### Success Metrics
- **170 systems** monitored simultaneously
- **18,439 incidents** analyzed
- **Real-time** updates via Azure Data Explorer
- **Multiple analysis dimensions** implemented

### Delivered Benefits
- ✅ **Complete visibility** into system availability
- ✅ **Proactive identification** of failure patterns
- ✅ **Decision support** for infrastructure investments
- ✅ **Compliance** with banking SLAs

## 🛠️ Demonstrated Competencies

### Advanced Techniques
- **Dimensional modeling** for corporate environments
- **Advanced DAX** with dynamic context detection
- **Data integration** Oracle → Azure → Power BI
- **Performance optimization** at scale
- **Reliability metrics** for critical systems

### Applied Methodologies
- **Kimball Methodology** for data warehousing
- **Agile BI** for iterative development
- **DevOps** for integration and deployment
- **Data Governance** for data quality

## 📁 Repository Structure

```
portfolio-mtbf-caixa/
├── README.md                          # This file
├── README_PORTUGUES.md                # Portuguese version
├── docs/
│   ├── arquitetura.md                 # Architecture documentation
│   ├── metodologia.md                 # Development methodology
│   ├── medidas_dax_reais.md          # Implemented DAX measures
│   └── data_dictionary_real.md       # Complete data dictionary
├── sql/
│   └── queries/                       # SQL queries for dimensions
│       ├── dimensao_datas.sql
│       ├── dimensao_prioridades.sql
│       ├── dimensao_crise.sql
│       ├── dimensao_tipo_incidente.sql
│       ├── dimensao_sigla.sql
│       ├── dimensao_motivo_status.sql
│       ├── dimensao_impacto.sql
│       └── fato_incidentes.sql
├── data/
│   ├── sample_data.csv               # Synthetic data for demonstration
│   └── data_dictionary_real.md       # Data dictionary
├── images/
│   ├── arquitetura_solucao.png       # Architecture diagram
│   ├── modelo_dados.png              # Dimensional model
│   └── layout_mtbf_dashboard.png     # Dashboard layout
└── powerbi/
    └── (masked .pbix files)          # Power BI files
```

## 🎓 Professional Context

### Company: Global Hitss Brasil
**Role:** Business Intelligence Developer  
**Client:** Caixa Econômica Federal  
**Period:** 2024  

### Responsibilities
- End-to-end BI solution development
- Data warehouse dimensional modeling
- Executive dashboard creation
- Large-scale performance optimization
- Legacy banking system integration

## 🔒 Confidentiality Note

This project uses **masked data** and **anonymized structures** to preserve the confidentiality of Caixa Econômica Federal's information. All technical implementations and methodologies are real and demonstrate the competencies applied in the original project.

## 📞 Contact

**LinkedIn:** https://www.linkedin.com/in/larissa-lima-304146112/  
**Email:** soylarissa@gmail.com  
**GitHub:** larissa052

---

*This portfolio demonstrates advanced expertise in Business Intelligence, from architectural conception to implementation of complex solutions in large-scale banking environments.*

## 🌍 Language Versions

- **English:** [README.md](README.md)
- **Português:** [README_PORTUGUES.md](README_PORTUGUES.md)

