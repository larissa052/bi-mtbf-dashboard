# Medidas DAX Avançadas - Projeto MTBF

## Visão Geral

Este documento apresenta as medidas DAX desenvolvidas para o projeto de monitoramento MTBF, demonstrando expertise avançada em linguagem DAX e modelagem de dados no Power BI.

## Medidas Globais Implementadas

### 📊 Medidas Principais de MTBF

#### MTBF (Mean Time Between Failures)
```dax
MTBF = 
VAR TotalDias = [Periodo_total_Dias]
VAR TotalIncidentes = [Total_Incidentes]
RETURN
IF(
    TotalIncidentes > 0,
    DIVIDE(TotalDias, TotalIncidentes, 0),
    BLANK()
)
```

#### Dias_com_Incidentes
```dax
Dias_com_Incidentes = 
CALCULATE(
    DISTINCTCOUNT(TB_FATO_INCIDENTES[DATA_ABERTURA]),
    TB_FATO_INCIDENTES[CONSULTA_INCIDENTES] = 1
)
```

#### Dias_entre_Falhas
```dax
Dias_entre_Falhas = 
VAR PeriodoOperacional = [Periodo_operacional]
VAR TotalIncidentes = [Total_Incidentes]
RETURN
IF(
    TotalIncidentes > 1,
    DIVIDE(PeriodoOperacional, TotalIncidentes - 1, 0),
    BLANK()
)
```

### 🎯 Medidas de Disponibilidade por Contexto

#### Dias_Sem_Incidente_Flag_crise
```dax
Dias_Sem_Incidente_Flag_crise = 
VAR DiasComCrise = 
    CALCULATE(
        DISTINCTCOUNT(TB_FATO_INCIDENTES[DATA_ABERTURA]),
        TB_FATO_INCIDENTES[DS_CRISE_GRAVE] IN {"Crise", "Grave"}
    )
VAR TotalDias = [Periodo_total_Dias]
RETURN
TotalDias - DiasComCrise
```

#### Dias_Sem_Incidente_Flag_impacto
```dax
Dias_Sem_Incidente_Flag_impacto = 
VAR DiasComImpactoAlto = 
    CALCULATE(
        DISTINCTCOUNT(TB_FATO_INCIDENTES[DATA_ABERTURA]),
        TB_FATO_INCIDENTES[CO_IMPACTO] IN {1000, 2000}
    )
VAR TotalDias = [Periodo_total_Dias]
RETURN
TotalDias - DiasComImpactoAlto
```

#### Dias_Sem_Incidente_Flag_motivo
```dax
Dias_Sem_Incidente_Flag_motivo = 
VAR DiasComMotivosCriticos = 
    CALCULATE(
        DISTINCTCOUNT(TB_FATO_INCIDENTES[DATA_ABERTURA]),
        TB_FATO_INCIDENTES[CO_MOTIVO_STATUS] IN {7000, 8000, 12000}
    )
VAR TotalDias = [Periodo_total_Dias]
RETURN
TotalDias - DiasComMotivosCriticos
```

#### Dias_Sem_Incidente_Flag_prioridade
```dax
Dias_Sem_Incidente_Flag_prioridade = 
VAR DiasComPrioridadeCritica = 
    CALCULATE(
        DISTINCTCOUNT(TB_FATO_INCIDENTES[DATA_ABERTURA]),
        TB_FATO_INCIDENTES[CO_PRIORIDADE] = 0
    )
VAR TotalDias = [Periodo_total_Dias]
RETURN
TotalDias - DiasComPrioridadeCritica
```

#### Dias_Sem_Incidente_Flag_sigla
```dax
Dias_Sem_Incidente_Flag_sigla = 
VAR DiasComIncidentesSistema = 
    CALCULATE(
        DISTINCTCOUNT(TB_FATO_INCIDENTES[DATA_ABERTURA]),
        ALLEXCEPT(TB_FATO_INCIDENTES, TB_DIMENSAO_SIGLA[SIGLA])
    )
VAR TotalDias = [Periodo_total_Dias]
RETURN
TotalDias - DiasComIncidentesSistema
```

### ⏱️ Medidas Temporais Avançadas

#### Periodo_operacional
```dax
Periodo_operacional = 
VAR PrimeiroDia = 
    CALCULATE(
        MIN(TB_FATO_INCIDENTES[DATA_ABERTURA]),
        ALL(TB_FATO_INCIDENTES)
    )
VAR UltimoDia = 
    CALCULATE(
        MAX(TB_FATO_INCIDENTES[DATA_ABERTURA]),
        ALL(TB_FATO_INCIDENTES)
    )
VAR TotalHorasIndisponibilidade = [Periodo_total_Horas_Indisponibilidade]
VAR TotalHorasPeriodo = 
    DATEDIFF(PrimeiroDia, UltimoDia, DAY) * 24
RETURN
DIVIDE(TotalHorasPeriodo - TotalHorasIndisponibilidade, 24, 0)
```

#### Periodo_total_Dias
```dax
Periodo_total_Dias = 
VAR PrimeiroDia = MIN(TB_DIMENSAO_DATAS[DATA])
VAR UltimoDia = MAX(TB_DIMENSAO_DATAS[DATA])
RETURN
DATEDIFF(PrimeiroDia, UltimoDia, DAY) + 1
```

#### Periodo_total_Horas
```dax
Periodo_total_Horas = 
[Periodo_total_Dias] * 24
```

#### Maior_Periodo_sem_falhas
```dax
Maior_Periodo_sem_falhas = 
VAR TabelaIncidentes = 
    ADDCOLUMNS(
        SUMMARIZE(
            TB_FATO_INCIDENTES,
            TB_FATO_INCIDENTES[DATA_ABERTURA]
        ),
        "DiasAteProximo",
        VAR DataAtual = TB_FATO_INCIDENTES[DATA_ABERTURA]
        VAR ProximaData = 
            CALCULATE(
                MIN(TB_FATO_INCIDENTES[DATA_ABERTURA]),
                TB_FATO_INCIDENTES[DATA_ABERTURA] > DataAtual
            )
        RETURN
        IF(
            NOT ISBLANK(ProximaData),
            DATEDIFF(DataAtual, ProximaData, DAY),
            BLANK()
        )
    )
RETURN
MAXX(TabelaIncidentes, [DiasAteProximo])
```

### 📈 Medidas de Contagem e Agregação

#### Total_Incidentes
```dax
Total_Incidentes = 
CALCULATE(
    COUNTROWS(TB_FATO_INCIDENTES),
    TB_FATO_INCIDENTES[CONSULTA_INCIDENTES] = 1
)
```

#### Ultimo_Periodo_Sem_Incidentes
```dax
Ultimo_Periodo_Sem_Incidentes = 
VAR UltimoIncidente = 
    CALCULATE(
        MAX(TB_FATO_INCIDENTES[DATA_ABERTURA]),
        ALL(TB_FATO_INCIDENTES)
    )
VAR DataAtual = TODAY()
RETURN
DATEDIFF(UltimoIncidente, DataAtual, DAY)
```

#### Coluna_do_grupo_de_calculo
```dax
Coluna_do_grupo_de_calculo = 
SELECTEDVALUE('Medidas Globais'[Medida])
```

## Tabelas Intermediárias

### Estrutura de Tabelas Intermediárias
O modelo utiliza tabelas intermediárias para otimização de performance e cálculos específicos:

- **TB_INTERMEDIARIA_CRISE** - Agregações por nível de crise
- **TB_INTERMEDIARIA_SIGLA** - Métricas por sistema
- **TB_INTERMEDIARIA_PRIORIDADE** - Análises por prioridade
- **TB_INTERMEDIARIA_MOTIVO_STATUS** - Agrupamentos por motivo
- **TB_INTERMEDIARIA_CO_IMPACTO** - Consolidações por impacto

### Benefícios das Tabelas Intermediárias

1. **Performance Otimizada**: Pré-agregações reduzem tempo de processamento
2. **Cálculos Complexos**: Facilitam implementação de lógicas avançadas
3. **Reutilização**: Medidas podem ser reutilizadas em diferentes contextos
4. **Manutenibilidade**: Separação clara de responsabilidades

## Técnicas DAX Avançadas Utilizadas

### 1. Funções de Contexto
- `CALCULATE()` com múltiplos filtros
- `ALL()` e `ALLEXCEPT()` para manipulação de contexto
- `FILTER()` para filtros dinâmicos

### 2. Funções de Agregação Temporal
- `DATEDIFF()` para cálculos de intervalos
- `MIN()` e `MAX()` com contextos específicos
- Análises de séries temporais

### 3. Variáveis e Lógica Condicional
- Uso extensivo de `VAR` para clareza e performance
- `IF()` e `SWITCH()` para lógicas condicionais
- `DIVIDE()` para tratamento de divisões por zero

### 4. Funções de Tabela
- `ADDCOLUMNS()` para cálculos em tabelas virtuais
- `SUMMARIZE()` para agregações customizadas
- `MAXX()` e `MINX()` para iterações

### 5. Tratamento de Valores em Branco
- `BLANK()` para valores não aplicáveis
- `ISBLANK()` para validações
- Tratamento adequado de contextos vazios

## Padrões de Desenvolvimento

### Nomenclatura Consistente
- Medidas em português para alinhamento com negócio
- Prefixos descritivos (Dias_, Periodo_, Total_)
- Nomes autoexplicativos

### Documentação Inline
```dax
-- Calcula MTBF considerando apenas dias operacionais
-- Exclui finais de semana e feriados do cálculo
MTBF_Operacional = 
VAR DiasOperacionais = [Dias_Uteis_Periodo]
VAR IncidentesOperacionais = [Incidentes_Dias_Uteis]
RETURN
DIVIDE(DiasOperacionais, IncidentesOperacionais, 0)
```

### Otimização de Performance
- Uso de variáveis para evitar recálculos
- Filtros específicos antes de agregações
- Aproveitamento de relacionamentos do modelo

## Validação e Testes

### Testes de Consistência
- Validação cruzada entre medidas relacionadas
- Verificação de totais e subtotais
- Testes com diferentes contextos de filtro

### Casos de Borda
- Tratamento de períodos sem incidentes
- Validação com dados históricos limitados
- Comportamento com filtros extremos

Este conjunto de medidas DAX demonstra proficiência avançada em Business Intelligence, combinando conhecimento técnico profundo com aplicação prática em ambiente corporativo de grande porte.

