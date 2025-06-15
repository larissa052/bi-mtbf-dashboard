# Dicionário de Dados Atualizado - Projeto MTBF CAIXA

## Estrutura Real Implementada

Baseado na análise do modelo de dados real implementado no Power BI para a Caixa Econômica Federal.

---

## TABELAS DIMENSÃO - ESTRUTURA REAL

### TB_DIMENSAO_DATAS
**Descrição:** Dimensão temporal com hierarquia completa

| Campo | Tipo | Valores Exemplo | Descrição |
|-------|------|-----------------|-----------|
| DATA | DATETIME | 2024-07-01 12:00:00 AM | Data completa com timestamp |
| ANO | NUMBER | 2024 | Ano (YYYY) |
| MES_ANO | VARCHAR | 07/2024 | Mês/Ano (MM/YYYY) |
| MES | NUMBER | 7 | Mês (1-12) |
| DIA | NUMBER | 1 | Dia do mês (1-31) |
| TRIMESTRE | NUMBER | 3 | Trimestre (1-4) |
| DATA_SEM_HORA | DATE | 2024-07-01 | Data sem componente de hora |

### TB_DIMENSAO_PRIORIDADES
**Descrição:** Classificação de prioridades de incidentes

| Campo | Tipo | Valores | Descrição |
|-------|------|---------|-----------|
| CO_PRIORIDADE | NUMBER | 0, 1 | Código da prioridade |
| DS_PRIORIDADE | VARCHAR | Crítico, Alto | Descrição da prioridade |

### TB_DIMENSAO_CRISE
**Descrição:** Classificação detalhada de tipos de crise/severidade

| Campo | Tipo | Valores Principais | Descrição |
|-------|------|-------------------|-----------|
| DS_CRISE_GRAVE | VARCHAR | Atender, Crise, Monitorar, Cadastrar, Alterar, Solicitação de Informações, Caminho Crítico, Indisponibilidade, Analisar, Atendimento Clientes CAIXA, Incidentes, Grave, Sem Informação, Processos Internos Service Desk, Orientar, Executar, Registrar, Lentidao, Atendimento Interno, Reativar, Reativo, Tratar, Crise GGC | Classificação detalhada do tipo de ocorrência |

### TB_DIMENSAO_TIPO_INCIDENTE
**Descrição:** Tipos de serviço de incidentes

| Campo | Tipo | Valores | Descrição |
|-------|------|---------|-----------|
| CO_TIPO_INCIDENTE | NUMBER | 0, 1, 2, 3 | Código do tipo |
| DS_TIPO_INCIDENTE | VARCHAR | Restauração de Serviço do Usuário, Solicitação de Serviço do Usuário, Restauração de infraestrutura, Evento de infraestrutura | Descrição do tipo de incidente |

### TB_DIMENSAO_SIGLA
**Descrição:** Catálogo de sistemas (170 sistemas únicos)

| Campo | Tipo | Valores Exemplo | Descrição |
|-------|------|-----------------|-----------|
| SIGLA | VARCHAR(5) | SIARP, SISIB, SIPEN, SITRC, SICOV, SIIAC, SICID, SIGPI, SICTD, SIB24, SID00, SIDON, SIFGI, SIGOV, SICTM, SIECM, SICNL, SIGCX, SIACL, SIINF, SIACC, SIADT, SIOCR, SINAT, SIRFE, SITAX, SIGSJ... (170 total) | Sigla do sistema |
| Servico | VARCHAR | Outro | Agrupamento por serviço |

### TB_DIMENSAO_MOTIVO_STATUS
**Descrição:** Motivos de resolução de incidentes

| Campo | Tipo | Valores Principais | Descrição |
|-------|------|-------------------|-----------|
| CO_MOTIVO_STATUS | NUMBER | 0, 1000, 2000, 5000, 7000, 9000, 10000, 11000, 12000, 14000, 15000, 16000, 17000, 18000, 19000, 20000, 21000, 22000 | Código do motivo |
| DS_MOTIVO_STATUS | VARCHAR | Outros, Mudança de Infraestrutura Criada, Outros, Outros, Ação Requerida de Fornecedor, Outros, Outros, Melhorias Futuras, Incidente Original Pendente, Monitorando Incidente, Acompanhamento do Cliente, Ação Corretiva Temporária, Nenhuma Outra Ação Requerida, Resolvido pelo Incidente Original, Resolução Automatizada Informada, Não é mais um IC Causal, Solução Definitiva, Solução de Contorno | Descrição do motivo de resolução |

### TB_DIMENSAO_IMPACTO
**Descrição:** Níveis de impacto de incidentes

| Campo | Tipo | Valores | Descrição |
|-------|------|---------|-----------|
| CO_IMPACTO | NUMBER | 1000, 2000, 3000, 4000 | Código do impacto |
| DS_IMPACTO | VARCHAR | 1 - Extensivo/difundido, 2 - Significativo/grande, 3 - Moderado/limitado, 4 - Menor/localizado | Descrição do nível de impacto |

---

## TABELAS INTERMEDIÁRIAS

### Estrutura de Otimização
O modelo utiliza tabelas intermediárias para otimização de performance:

- **TB_INTERMEDIARIA_CO_IMPACTO** - Agregações por impacto
- **TB_INTERMEDIARIA_CRISE** - Consolidações por tipo de crise
- **TB_INTERMEDIARIA_MOTIVO_STATUS** - Agrupamentos por motivo
- **TB_INTERMEDIARIA_PRIORIDADE** - Métricas por prioridade
- **TB_INTERMEDIARIA_SIGLA** - Análises por sistema

---

## MEDIDAS GLOBAIS IMPLEMENTADAS

### Medidas Principais de MTBF
- **MTBF** - Tempo médio entre falhas
- **Dias_com_Incidentes** - Contagem de dias com ocorrências
- **Dias_entre_Falhas** - Intervalo médio entre falhas
- **Periodo_operacional** - Período operacional efetivo
- **Periodo_total_Dias** - Período total em dias
- **Periodo_total_Horas** - Período total em horas
- **Maior_Periodo_sem_falhas** - Maior intervalo sem incidentes
- **Total_Incidentes** - Contagem total de incidentes
- **Ultimo_Periodo_Sem_Incidentes** - Dias desde último incidente

### Medidas de Disponibilidade por Contexto
- **Dias_Sem_Incidente_Flag_crise** - Disponibilidade por nível de crise
- **Dias_Sem_Incidente_Flag_impacto** - Disponibilidade por impacto
- **Dias_Sem_Incidente_Flag_motivo** - Disponibilidade por motivo
- **Dias_Sem_Incidente_Flag_prioridade** - Disponibilidade por prioridade
- **Dias_Sem_Incidente_Flag_sigla** - Disponibilidade por sistema

### Medidas de Controle
- **Coluna_do_grupo_de_calculo** - Controle de grupos de cálculo

---

## CARACTERÍSTICAS TÉCNICAS

### Complexidade do Modelo
- **7 Dimensões** com relacionamentos 1:N
- **170 Sistemas** únicos monitorados
- **Múltiplas categorias** de classificação por dimensão
- **Tabelas intermediárias** para otimização
- **20+ Medidas DAX** avançadas

### Fonte de Dados
- **Oracle Database** (aradmin.hpd_help_desk)
- **Azure Data Explorer** (Kusto) para processamento
- **Power BI Service** para visualização

### Técnicas Avançadas Utilizadas
- **Modelagem dimensional** (Star Schema)
- **Medidas DAX complexas** com CTEs e variáveis
- **Otimização de performance** com tabelas intermediárias
- **Tratamento de contextos** múltiplos
- **Cálculos temporais** avançados

---

## MÉTRICAS DE NEGÓCIO

### MTBF (Mean Time Between Failures)
Métrica principal para medir confiabilidade dos sistemas bancários da CAIXA.

### Disponibilidade por Sistema
Análise granular de disponibilidade dos 170 sistemas monitorados.

### Classificação de Severidade
Múltiplas dimensões de classificação (prioridade, impacto, crise) para análise detalhada.

### Análise Temporal
Hierarquia temporal completa permitindo análises desde diárias até anuais.

---

Este modelo demonstra expertise avançada em:
- **Modelagem dimensional** para ambientes corporativos
- **Desenvolvimento DAX** com técnicas avançadas
- **Otimização de performance** em grandes volumes
- **Integração de dados** Oracle → Azure → Power BI
- **Métricas de confiabilidade** para sistemas críticos bancários

