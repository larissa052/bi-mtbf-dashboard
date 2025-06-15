# Dicionário de Dados - Projeto MTBF

## Visão Geral

Este documento apresenta o dicionário de dados completo do projeto de monitoramento MTBF (Mean Time Between Failures) desenvolvido para a Caixa Econômica Federal. O modelo dimensional foi projetado para suportar análises avançadas de disponibilidade e confiabilidade dos sistemas bancários.

## Estrutura do Modelo

### Modelo Dimensional (Star Schema)
- **1 Tabela Fato:** TB_FATO_INCIDENTES
- **7 Tabelas Dimensão:** Datas, Prioridades, Crise, Tipo Incidente, Sigla, Motivo Status, Impacto

---

## TABELA FATO

### TB_FATO_INCIDENTES
**Descrição:** Tabela central contendo os eventos de incidentes com métricas para cálculo de MTBF

| Campo | Tipo | Descrição | Observações |
|-------|------|-----------|-------------|
| incident_number | VARCHAR(50) | Número único do incidente | Chave primária |
| data_hora_abertura | VARCHAR(19) | Data/hora de abertura do incidente | Formato: YYYY/MM/DD HH24:MI:SS |
| data_hora_fechamento | TIMESTAMP | Data/hora de fechamento do incidente | Para cálculo de duração |
| co_prioridade | NUMBER | Código da prioridade | FK para TB_DIMENSAO_PRIORIDADES |
| ds_crise_grave | VARCHAR(50) | Descrição do nível de crise | FK para TB_DIMENSAO_CRISE |
| co_tipo_incidente | NUMBER | Código do tipo de incidente | FK para TB_DIMENSAO_TIPO_INCIDENTE |
| sigla | VARCHAR(5) | Sigla do sistema afetado | FK para TB_DIMENSAO_SIGLA |
| co_motivo_status | NUMBER | Código do motivo de resolução | FK para TB_DIMENSAO_MOTIVO_STATUS |
| co_impacto | NUMBER | Código do nível de impacto | FK para TB_DIMENSAO_IMPACTO |
| duracao_resolucao_horas | NUMBER(10,2) | Tempo de resolução em horas | Métrica calculada |
| periodo_abertura | VARCHAR(20) | Período do dia da abertura | HORARIO_COMERCIAL, HORARIO_NOTURNO, MADRUGADA |
| fim_semana | CHAR(1) | Indicador de fim de semana | S/N |
| score_criticidade | NUMBER | Score composto de criticidade | 1-10 baseado em prioridade + impacto |
| data_abertura | DATE | Data de abertura (sem hora) | FK para TB_DIMENSAO_DATAS |
| contador_incidentes | NUMBER | Contador para agregações | Sempre 1 |
| tempo_indisponibilidade | NUMBER(10,2) | Tempo de indisponibilidade | Em horas |

---

## TABELAS DIMENSÃO

### TB_DIMENSAO_DATAS
**Descrição:** Dimensão temporal com hierarquia completa para análises temporais

| Campo | Tipo | Descrição | Observações |
|-------|------|-----------|-------------|
| data | DATE | Data completa | Chave primária |
| data_sem_hora | DATE | Data sem componente de hora | Mesmo valor que data |
| ano | NUMBER(4) | Ano | YYYY |
| mes_ano | VARCHAR(7) | Mês/Ano | MM/YYYY |
| mes | NUMBER(2) | Mês | 1-12 |
| dia | NUMBER(2) | Dia do mês | 1-31 |
| trimestre | NUMBER(1) | Trimestre | 1-4 |
| dia_semana | VARCHAR(20) | Nome do dia da semana | Em português |
| numero_dia_semana | NUMBER(1) | Número do dia da semana | 1=Domingo, 7=Sábado |
| semana_ano | NUMBER(2) | Semana do ano | 1-53 |
| semana_iso | NUMBER(2) | Semana ISO | 1-53 |
| fim_semana | CHAR(1) | Indicador de fim de semana | S/N |
| feriado_nacional | CHAR(1) | Indicador de feriado | S/N |
| trimestre_fiscal | NUMBER(1) | Trimestre fiscal | 1-4 |

### TB_DIMENSAO_PRIORIDADES
**Descrição:** Classificação de prioridades de incidentes com SLAs associados

| Campo | Tipo | Descrição | Observações |
|-------|------|-----------|-------------|
| co_prioridade | NUMBER | Código da prioridade | Chave primária |
| ds_prioridade | VARCHAR(20) | Descrição da prioridade | Crítico, Alto, Médio, Baixo |
| categoria_criticidade | VARCHAR(20) | Categoria de criticidade | ALTA_CRITICIDADE, BAIXA_CRITICIDADE |
| sla_resolucao_horas | NUMBER | SLA em horas | 2, 4, 8, 24 |
| peso_prioridade | NUMBER | Peso para cálculos | 4=Crítico, 3=Alto, 2=Médio, 1=Baixo |

### TB_DIMENSAO_CRISE
**Descrição:** Classificação de severidade de incidentes

| Campo | Tipo | Descrição | Observações |
|-------|------|-----------|-------------|
| ds_crise_grave | VARCHAR(50) | Descrição da severidade | Chave primária |
| co_nivel_severidade | NUMBER | Código numérico do nível | 1=Crise, 2=Grave, 3=Normal |
| ds_detalhada_severidade | VARCHAR(200) | Descrição detalhada | Explicação completa do nível |
| tempo_resposta_minutos | NUMBER | Tempo máximo de resposta | 15, 30, 60 minutos |
| escalacao_automatica | CHAR(1) | Requer escalação automática | S/N |
| peso_mtbf | NUMBER(3,1) | Peso para cálculos MTBF | 5.0=Crise, 3.0=Grave, 1.0=Normal |

### TB_DIMENSAO_TIPO_INCIDENTE
**Descrição:** Classificação de tipos de serviço de incidentes

| Campo | Tipo | Descrição | Observações |
|-------|------|-----------|-------------|
| co_tipo_incidente | NUMBER | Código do tipo | Chave primária |
| ds_tipo_incidente | VARCHAR(100) | Descrição do tipo | Restauração/Solicitação de Serviço |
| categoria_tipo | VARCHAR(30) | Categoria do tipo | RESTAURACAO_USUARIO, SOLICITACAO_USUARIO, etc. |
| area_impacto | VARCHAR(20) | Área de impacto | USUARIO_FINAL, INFRAESTRUTURA |
| prioridade_padrao | NUMBER | Prioridade padrão | 0-3 |
| sla_padrao_horas | NUMBER | SLA padrão em horas | 2, 4, 8, 24, 48 |
| afeta_mtbf | CHAR(1) | Indica se afeta MTBF | S/N |
| peso_disponibilidade | NUMBER(3,1) | Peso para disponibilidade | 0.0-3.0 |

### TB_DIMENSAO_SIGLA
**Descrição:** Catálogo de sistemas por sigla com agrupamento por serviços

| Campo | Tipo | Descrição | Observações |
|-------|------|-----------|-------------|
| sigla | VARCHAR(5) | Sigla do sistema | Chave primária |
| servico_agrupado | VARCHAR(50) | Serviço agrupado | Loterias, Internet Banking, PIX, etc. |
| categoria_servico | VARCHAR(30) | Categoria do serviço | LOTERIAS, INTERNET_BANKING, etc. |
| criticidade_negocio | VARCHAR(10) | Criticidade para negócio | CRITICO, ALTO, MEDIO, BAIXO |
| sla_sistema_horas | NUMBER | SLA específico do sistema | 1, 2, 4, 8 horas |
| horario_funcionamento | VARCHAR(20) | Horário de funcionamento | 24x7, 06:00-24:00, etc. |
| peso_mtbf | NUMBER(3,1) | Peso para cálculos MTBF | 1.0-4.0 |
| descricao_sistema | VARCHAR(100) | Descrição completa | Nome completo do sistema |

### TB_DIMENSAO_MOTIVO_STATUS
**Descrição:** Mapeamento de motivos de resolução de incidentes

| Campo | Tipo | Descrição | Observações |
|-------|------|-----------|-------------|
| co_motivo_status | NUMBER | Código do motivo | Chave primária |
| ds_motivo_status | VARCHAR(100) | Descrição do motivo | Solução Definitiva, Contorno, etc. |
| categoria_resolucao | VARCHAR(30) | Categoria de resolução | RESOLVIDO_DEFINITIVO, TEMPORARIO, etc. |
| resolucao_definitiva | CHAR(1) | Indica resolução definitiva | S/N |
| requer_acompanhamento | CHAR(1) | Requer acompanhamento | S/N |
| peso_efetividade | NUMBER(3,1) | Peso para efetividade | 0.1-1.0 |
| tempo_estimado_resolucao_horas | NUMBER | Tempo estimado para resolução | 0-96 horas |

### TB_DIMENSAO_IMPACTO
**Descrição:** Classificação de níveis de impacto de incidentes

| Campo | Tipo | Descrição | Observações |
|-------|------|-----------|-------------|
| co_impacto | NUMBER | Código do impacto | Chave primária |
| ds_impacto | VARCHAR(50) | Descrição do impacto | 1-Extensivo, 2-Significativo, etc. |
| categoria_impacto | VARCHAR(20) | Categoria do impacto | EXTENSIVO, SIGNIFICATIVO, etc. |
| nivel_impacto | NUMBER | Nível numérico | 1-5 |
| descricao_detalhada | VARCHAR(200) | Descrição detalhada | Explicação completa do impacto |
| sla_resolucao_horas | NUMBER | SLA baseado no impacto | 1, 2, 4, 8, 24 horas |
| requer_comunicacao_externa | CHAR(1) | Requer comunicação externa | S/N |
| peso_disponibilidade | NUMBER(3,1) | Peso para disponibilidade | 0.5-4.0 |
| percentual_usuarios_afetados | NUMBER | % estimado de usuários afetados | 0-75% |
| escalacao_imediata | CHAR(1) | Requer escalação imediata | S/N |
| cor_visualizacao | VARCHAR(7) | Cor para visualização | Código hexadecimal |

---

## Relacionamentos

### Cardinalidades
- **TB_DIMENSAO_DATAS** → **TB_FATO_INCIDENTES** (1:N)
- **TB_DIMENSAO_PRIORIDADES** → **TB_FATO_INCIDENTES** (1:N)
- **TB_DIMENSAO_CRISE** → **TB_FATO_INCIDENTES** (1:N)
- **TB_DIMENSAO_TIPO_INCIDENTE** → **TB_FATO_INCIDENTES** (1:N)
- **TB_DIMENSAO_SIGLA** → **TB_FATO_INCIDENTES** (1:N)
- **TB_DIMENSAO_MOTIVO_STATUS** → **TB_FATO_INCIDENTES** (1:N)
- **TB_DIMENSAO_IMPACTO** → **TB_FATO_INCIDENTES** (1:N)

### Chaves de Relacionamento
- **data_abertura** → **data**
- **co_prioridade** → **co_prioridade**
- **ds_crise_grave** → **ds_crise_grave**
- **co_tipo_incidente** → **co_tipo_incidente**
- **sigla** → **sigla**
- **co_motivo_status** → **co_motivo_status**
- **co_impacto** → **co_impacto**

---

## Métricas Principais

### Cálculos de MTBF
- **MTBF (horas)** = Tempo total operacional / Número de falhas
- **MTBF (dias)** = MTBF (horas) / 24
- **Disponibilidade (%)** = (Tempo operacional / Tempo total) × 100
- **MTTR (horas)** = Tempo total de reparo / Número de incidentes

### Agregações Suportadas
- Por sistema (sigla)
- Por período (diário, semanal, mensal, trimestral, anual)
- Por criticidade (prioridade + impacto)
- Por tipo de serviço
- Por horário de funcionamento

---

## Considerações Técnicas

### Performance
- Índices recomendados em todas as chaves estrangeiras
- Particionamento da tabela fato por data_abertura
- Views materializadas para consultas frequentes

### Qualidade de Dados
- Validações de integridade referencial
- Tratamento de valores nulos
- Padronização de formatos de data/hora
- Validação de códigos de domínio

### Segurança
- Dados mascarados para ambiente de desenvolvimento
- Row-level security por área de negócio
- Auditoria de acessos e modificações

