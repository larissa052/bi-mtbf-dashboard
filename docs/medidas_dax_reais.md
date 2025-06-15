# Medidas DAX Reais - Projeto MTBF CAIXA

## Medidas Globais Implementadas

### 📊 Medidas Principais de MTBF

#### MTBF (Mean Time Between Failures)
```dax
MTBF = ( [Periodo_total_Dias] - [Dias_com_Incidentes]) / [TOTAL_FALHAS]
```

#### Dias_com_Incidentes
```dax
Dias_com_Incidentes = 
[Periodo_total_Dias] - [Periodo_operacional]
```

#### Dias_entre_Falhas
```dax
Dias_entre_Falhas = 
VAR DATA_ATUAL = MIN(TB_DIMENSAO_DATAS[DATA])
VAR ULTIMO_DIA_FALHA = 
CALCULATE(
    MAX(TB_DIMENSAO_DATAS[DATA]),
    FILTER(
        ALL(TB_DIMENSAO_DATAS),
        TB_DIMENSAO_DATAS[DATA] < DATA_ATUAL &&
        (
            [Dias_Sem_Incidente_Flag_crise] > 0  ||
            [Dias_Sem_Incidente_Flag_impacto] > 0  ||
            [Dias_Sem_Incidente_Flag_motivo]  > 0 ||
            [Dias_Sem_Incidente_Flag_prioridade] > 0 ||
            [Dias_Sem_Incidente_Flag_sigla] > 0 
        )
    ))
    RETURN
    IF(
        NOT ISBLANK(ULTIMO_DIA_FALHA),
        DATEDIFF(ULTIMO_DIA_FALHA, DATA_ATUAL, DAY),
        0
    )
```

### 🎯 Medidas de Disponibilidade por Contexto

#### Dias_Sem_Incidente_Flag_crise
```dax
Dias_Sem_Incidente_Flag_crise = 
COALESCE(CALCULATE(
    COUNTROWS(TB_DIMENSAO_DATAS),
    FILTER(
        TB_DIMENSAO_DATAS,
        [Quantidade_crise] = 1)), 0)
```

#### Dias_Sem_Incidente_Flag_impacto
```dax
Dias_Sem_Incidente_Flag_impacto = 
COALESCE(CALCULATE(
    COUNTROWS(TB_DIMENSAO_DATAS),
    FILTER(
        TB_DIMENSAO_DATAS,
        [Quantidade_impacto] = 1)) ,0)
```

#### Dias_Sem_Incidente_Flag_motivo
```dax
Dias_Sem_Incidente_Flag_motivo = 
COALESCE(CALCULATE(
    COUNTROWS(TB_DIMENSAO_DATAS),
    FILTER(
        TB_DIMENSAO_DATAS,
        [Quantidade_motivo] = 1)) ,0)
```

#### Dias_Sem_Incidente_Flag_prioridade
```dax
Dias_Sem_Incidente_Flag_prioridade = 
COALESCE(CALCULATE(
    COUNTROWS(TB_DIMENSAO_DATAS),
    FILTER(
        TB_DIMENSAO_DATAS,
        [Quantidade_prioridade] = 1)), 0)
```

#### Dias_Sem_Incidente_Flag_sigla
```dax
Dias_Sem_Incidente_Flag_sigla = 
COALESCE(CALCULATE(
    COUNTROWS(TB_DIMENSAO_DATAS),
    FILTER(
        TB_DIMENSAO_DATAS,
        [Quantidade_sigla] = 1)), 0)
```

### ⏱️ Medidas Temporais Avançadas

#### Dias_Sem_Incidentes
```dax
Dias_Sem_Incidentes = 
VAR TB_ORDENADA =
SUMMARIZE(
    TB_FATO_INCIDENTES,
    TB_FATO_INCIDENTES[DATA_HORA_ABERTURA],
    TB_FATO_INCIDENTES[DATA_HORA_FECHAMENTO]
)
VAR DIAS_ENTRE_FALHAS =
SUMX(
    TB_ORDENADA,
    VAR DATA_ATUAL = TB_FATO_INCIDENTES[DATA_HORA_ABERTURA]
    VAR ULTIMO_FECHAMENTO = 
CALCULATE(
    MAX(TB_FATO_INCIDENTES[DATA_HORA_FECHAMENTO]),
        FILTER(
            ALL(TB_FATO_INCIDENTES),
            TB_FATO_INCIDENTES[DATA_HORA_FECHAMENTO] < DATA_ATUAL 
    )
)
RETURN
IF(
    NOT ISBLANK(ULTIMO_FECHAMENTO) ,
    DATEDIFF(ULTIMO_FECHAMENTO, DATA_ATUAL, DAY),
    BLANK()
   )
)
RETURN
DIAS_ENTRE_FALHAS
```

#### Maior_Periodo_sem_falhas
```dax
Maior_Periodo_sem_falhas = 
MAXX(
    FILTER(
        SUMMARIZE(
            TB_DIMENSAO_DATAS,
            TB_DIMENSAO_DATAS[DATA],
            "DIASENTREFALHAS", [Dias_entre_Falhas]),
            [DIASENTREFALHAS] > 0 ),
            [DIASENTREFALHAS]
)
```

#### Periodo_operacional (Medida Mais Avançada)
```dax
Periodo_operacional = 
VAR AtributoFiltrado =
    SWITCH(
        TRUE(),
        CALCULATE(
            COUNTROWS(TB_INTERMEDIARIA_SIGLA),
            ALLSELECTED(TB_INTERMEDIARIA_SIGLA[Sigla])
        ) > 0, "Sigla",
        CALCULATE(
            COUNTROWS(TB_INTERMEDIARIA_CO_IMPACTO),
            ALLSELECTED(TB_INTERMEDIARIA_CO_IMPACTO[CO_IMPACTO])
        ) > 0, "Impacto",
        CALCULATE(
            COUNTROWS(TB_INTERMEDIARIA_PRIORIDADE),
            ALLSELECTED(TB_INTERMEDIARIA_PRIORIDADE[CO_PRIORIDADE])
        ) > 0, "Prioridade",
        CALCULATE(
            COUNTROWS(TB_INTERMEDIARIA_MOTIVO_STATUS),
            ALLSELECTED(TB_INTERMEDIARIA_MOTIVO_STATUS[CO_MOTIVO_STATUS])
        ) > 0, "Motivo",
        CALCULATE(
            COUNTROWS(TB_INTERMEDIARIA_CRISE),
            ALLSELECTED(TB_INTERMEDIARIA_CRISE[DS_CRISE_GRAVE])
        ) > 0, "Crise",
        "Nenhum"
    )
RETURN
    SWITCH(
        AtributoFiltrado,
        "Sigla", CALCULATE(
            COUNTROWS(TB_DIMENSAO_DATAS),
            FILTER(
                TB_DIMENSAO_DATAS,
                [Dias_Sem_Incidente_Flag_sigla] = 0
            )
        ),
        "Impacto", CALCULATE(
            COUNTROWS(TB_DIMENSAO_DATAS),
            FILTER(
                TB_DIMENSAO_DATAS,
                [Dias_Sem_Incidente_Flag_impacto] = 0
            )
        ),
        "Prioridade", CALCULATE(
            COUNTROWS(TB_DIMENSAO_DATAS),
            FILTER(
                TB_DIMENSAO_DATAS,
                [Dias_Sem_Incidente_Flag_prioridade] = 0
            )
        ),
        "Motivo", CALCULATE(
            COUNTROWS(TB_DIMENSAO_DATAS),
            FILTER(
                TB_DIMENSAO_DATAS,
                [Dias_Sem_Incidente_Flag_motivo] = 0
            )
        ),
        "Crise", CALCULATE(
            COUNTROWS(TB_DIMENSAO_DATAS),
            FILTER(
                TB_DIMENSAO_DATAS,
                [Dias_Sem_Incidente_Flag_crise] = 0
            )
        ),
        BLANK()
    )
```

#### Periodo_total_Dias
```dax
Periodo_total_Dias = // BOLSÃO DE HORAS DO PERÍODO SELECIONADO
  DATEDIFF(
    MIN(TB_DIMENSAO_DATAS[DATA]), MAX(TB_DIMENSAO_DATAS[DATA]), DAY) + 1
```

#### Periodo_total_Horas
```dax
Periodo_total_Horas = // BOLSÃO DE HORAS DO PERÍODO SELECIONADO
  DATEDIFF(
    MIN(TB_DIMENSAO_DATAS[DATA]), MAX(TB_DIMENSAO_DATAS[DATA]), HOUR)
```

### 📈 Medidas de Contagem e Agregação

#### Total_Incidentes
```dax
Total_Incidentes = 
 COALESCE(
COUNT(TB_FATO_INCIDENTES[INCIDENT_NUMBER]), 0)
```

#### Ultimo_Período_Sem_Incidentes
```dax
Ultimo_Período_Sem_Incidentes = 
VAR DATA_FINAL = 
MAX(TB_DIMENSAO_DATAS[DATA])
VAR ULTIMO_INCIDENTE =
CALCULATE(
    MAX(TB_FATO_INCIDENTES[DATA_HORA_FECHAMENTO]),
    ALLSELECTED(TB_FATO_INCIDENTES)
)
VAR DIFERENCA_DIAS = 
DATEDIFF(ULTIMO_INCIDENTE, DATA_FINAL, DAY)
RETURN
IF(
    NOT ISBLANK(ULTIMO_INCIDENTE),
    MAX(DIFERENCA_DIAS,0),
    BLANK()
)
```

## Técnicas DAX Avançadas Utilizadas

### 1. Detecção Dinâmica de Contexto
A medida `Periodo_operacional` usa `SWITCH` aninhado com `ALLSELECTED` para detectar dinamicamente qual dimensão está sendo filtrada e aplicar a lógica correspondente.

### 2. Variáveis Complexas
Uso extensivo de `VAR` para criar lógicas complexas e melhorar performance, especialmente em `Dias_Sem_Incidentes` e `Ultimo_Período_Sem_Incidentes`.

### 3. Iteração com SUMX
A medida `Dias_Sem_Incidentes` usa `SUMX` com `SUMMARIZE` para iterar sobre registros e calcular intervalos entre falhas.

### 4. Filtros Avançados
Combinação de `FILTER`, `ALL`, `ALLSELECTED` para manipular contextos de forma sofisticada.

### 5. Tratamento de Valores Nulos
Uso consistente de `COALESCE`, `ISBLANK` e `NOT ISBLANK` para tratamento robusto de valores nulos.

### 6. Cálculos Temporais
Uso avançado de `DATEDIFF` para cálculos de intervalos temporais em diferentes granularidades.

### 7. Agregações Condicionais
Uso de `MAXX` com `FILTER` para encontrar valores máximos sob condições específicas.

## Padrões de Desenvolvimento

### Nomenclatura Consistente
- Medidas em português para alinhamento com negócio
- Prefixos descritivos (Dias_, Periodo_, Total_)
- Comentários inline para documentação

### Otimização de Performance
- Uso de variáveis para evitar recálculos
- Filtros específicos antes de agregações
- Aproveitamento de relacionamentos do modelo

### Robustez
- Tratamento consistente de valores nulos
- Validação de contextos vazios
- Fallbacks para cenários extremos

Este conjunto de medidas DAX demonstra proficiência excepcional em Business Intelligence, combinando conhecimento técnico avançado com aplicação prática em ambiente corporativo de grande porte.

