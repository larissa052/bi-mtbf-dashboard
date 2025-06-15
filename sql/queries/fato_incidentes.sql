-- =====================================================
-- TABELA FATO INCIDENTES - QUERY PRINCIPAL
-- Baseada na implementação real para Caixa Econômica Federal
-- Extração complexa de dados de incidentes com transformações avançadas
-- =====================================================

-- TB_FATO_INCIDENTES
-- QUERY DA TABELA FATO QUE CONTÉM OS EVENTOS PRINCIPAIS
-- COMPOSTA POR INCIDENTES, INCLUINDO INFORMAÇÕES TEMPORAIS E MÉTRICAS

WITH incidentes_associados AS (
    -- CTE para filtrar incidentes não associados (evitar duplicações)
    SELECT DISTINCT
        incident_number
    FROM
        sistema_incidentes.tb_help_desk  -- Tabela mascarada
    WHERE
        reported_date >= 1704067200  -- FILTRANDO OS INCIDENTES A PARTIR DE 01/01/2024 00:00:00
        AND status <> 6              -- FILTRANDO OS INCIDENTES QUE NÃO FORAM CANCELADOS
    MINUS
    SELECT
        i.incident_number
    FROM
        sistema_incidentes.tb_help_desk i,
        sistema_incidentes.tb_associations a  -- Tabela mascarada
    WHERE
        i.incident_number = a.request_id02
        AND i.reported_date >= 1704067200
        AND i.status <> 6
        AND a.request_type01 = 9000
        AND a.association_type01 = 2000
),

base_incidentes AS (
    -- CTE para processamento principal dos incidentes
    SELECT
        inc.incident_number,
        inc.submit_date,
        -- Conversão de timestamp Unix para datetime com ajuste de fuso horário
        TO_TIMESTAMP('1970-01-01 00:00:00.0','YYYY-MM-DD HH24:MI:SS.FF') + 
        NUMTODSINTERVAL(inc.submit_date,'SECOND') - INTERVAL '3' HOUR AS data_hora_abertura,
        
        TO_TIMESTAMP('1970-01-01 00:00:00.0','YYYY-MM-DD HH24:MI:SS.FF') + 
        NUMTODSINTERVAL(inc.last_resolved_date,'SECOND') - INTERVAL '3' HOUR AS data_hora_fechamento,
        
        inc.priority co_prioridade,
        
        -- Classificação complexa de crise/grave
        CASE
            WHEN inc.categorization_tier_1 = 'Crise'
                 OR inc.categorization_tier_1 = 'Crise GGC acionado' THEN 'Crise'
            WHEN inc.categorization_tier_1 = 'Incidente Grave' THEN 'Grave'
            WHEN inc.categorization_tier_1 IS NULL THEN 'Sem Informação'
            ELSE inc.categorization_tier_1
        END ds_crise_grave,
        
        inc.service_type co_tipo_incidente,
        
        -- Extração da sigla do sistema (posições 9-13 do campo hpd_ci)
        SUBSTR(inc.hpd_ci, 9, 5) AS sigla,
        
        -- Tratamento de valores nulos para motivo de status
        CASE
            WHEN inc.status_reason IS NULL THEN 0
            ELSE inc.status_reason
        END co_motivo_status,
        
        inc.impact co_impacto,
        
        -- Campos calculados adicionais para análise
        CASE 
            WHEN inc.last_resolved_date IS NOT NULL AND inc.submit_date IS NOT NULL THEN
                ROUND(
                    (inc.last_resolved_date - inc.submit_date) / 3600, 2
                ) -- Duração em horas
            ELSE NULL
        END duracao_resolucao_horas,
        
        -- Classificação de horário de abertura
        CASE 
            WHEN EXTRACT(HOUR FROM (TO_TIMESTAMP('1970-01-01 00:00:00.0','YYYY-MM-DD HH24:MI:SS.FF') + 
                 NUMTODSINTERVAL(inc.submit_date,'SECOND') - INTERVAL '3' HOUR)) BETWEEN 8 AND 18 THEN 'HORARIO_COMERCIAL'
            WHEN EXTRACT(HOUR FROM (TO_TIMESTAMP('1970-01-01 00:00:00.0','YYYY-MM-DD HH24:MI:SS.FF') + 
                 NUMTODSINTERVAL(inc.submit_date,'SECOND') - INTERVAL '3' HOUR)) BETWEEN 19 AND 23 THEN 'HORARIO_NOTURNO'
            ELSE 'MADRUGADA'
        END periodo_abertura,
        
        -- Identificação de fim de semana
        CASE 
            WHEN TO_CHAR((TO_TIMESTAMP('1970-01-01 00:00:00.0','YYYY-MM-DD HH24:MI:SS.FF') + 
                 NUMTODSINTERVAL(inc.submit_date,'SECOND') - INTERVAL '3' HOUR), 'D') IN ('1', '7') THEN 'S'
            ELSE 'N'
        END fim_semana,
        
        -- Score de criticidade composto
        CASE 
            WHEN inc.priority = 0 AND inc.impact = 1000 THEN 10  -- Crítico + Extensivo
            WHEN inc.priority = 0 AND inc.impact = 2000 THEN 9   -- Crítico + Significativo
            WHEN inc.priority = 1 AND inc.impact = 1000 THEN 8   -- Alto + Extensivo
            WHEN inc.priority = 1 AND inc.impact = 2000 THEN 7   -- Alto + Significativo
            WHEN inc.priority = 0 AND inc.impact = 3000 THEN 6   -- Crítico + Moderado
            WHEN inc.priority = 1 AND inc.impact = 3000 THEN 5   -- Alto + Moderado
            WHEN inc.priority = 0 AND inc.impact = 4000 THEN 4   -- Crítico + Menor
            WHEN inc.priority = 1 AND inc.impact = 4000 THEN 3   -- Alto + Menor
            ELSE 1
        END score_criticidade
        
    FROM
        sistema_incidentes.tb_help_desk inc  -- Tabela mascarada
    WHERE
        inc.status <> 6  -- FILTRANDO OS QUE NÃO FORAM CANCELADOS 
        AND inc.priority IN (0, 1)  -- FILTRANDO APENAS INCIDENTES DE PRIORIDADE ALTA E CRÍTICA
        AND SUBSTR(inc.hpd_ci, 9, 5) IN (
            -- FILTRO COMPLETO DE SISTEMAS (lista mascarada)
            'SISPI', 'SIMPI', 'SIMTX', 'SIAAF', 'SIABE', 'SIACC', 'SIACI', 'SIACL', 'SIACM', 'SIACN',
            'SIADC', 'SIADJ', 'SIADT', 'SIAFG', 'SIAME', 'SIAOI', 'SIAPF', 'SIAPI', 'SIAPX', 'SIARA',
            'SIARC', 'SIARP', 'SIART', 'SIATC', 'SIATR', 'SIAUT', 'SIAVL', 'SIB24', 'SIB2B', 'SIBAR',
            'SIBEC', 'SIBOT', 'SIBSA', 'SICAC', 'SICAP', 'SICAQ', 'SICCP', 'SICCR', 'SICDC', 'SICEX',
            'SICFM', 'SICIA', 'SICID', 'SICLG', 'SICLI', 'SICNL', 'SICNS', 'SICOB', 'SICOV', 'SICPF',
            'SICPU', 'SICQL', 'SICSD', 'SICTB', 'SICTD', 'SICTM', 'SID00', 'SID01', 'SID05', 'SID09',
            'SIDDA', 'SIDEC', 'SIDEO', 'SIDMF', 'SIDMP', 'SIDOC', 'SIDON', 'SIDPN', 'SIDRE', 'SIDUN',
            'SIECM', 'SIEFI', 'SIEMP', 'SIEXC', 'SIFEC', 'SIFES', 'SIFGE', 'SIFGI', 'SIFGS', 'SIFIX',
            'SIFMP', 'SIFUG', 'SIGAP', 'SIGAT', 'SIGCB', 'SIGCX', 'SIGDA', 'SIGDU', 'SIGEC', 'SIGEL',
            'SIGEP', 'SIGIP', 'SIGLM', 'SIGMC', 'SIGMS', 'SIGOT', 'SIGOV', 'SIGPI', 'SIGQI', 'SIGSJ',
            'SIGTA', 'SIIAC', 'SIIBS', 'SIICO', 'SIINF', 'SIINT', 'SIISO', 'SIJAD', 'SILCE', 'SIMAA',
            'SIMCF', 'SIMCN', 'SIMLO', 'SIMOB', 'SIMPI', 'SIMTC', 'SIMTR', 'SIMTX', 'SINA1', 'SINAC',
            'SINAF', 'SINAT', 'SINAV', 'SINBC', 'SINDA', 'SIOBA', 'SIOBS', 'SIOCR', 'SIOMS', 'SIOPI',
            'SIORM', 'SIOUV', 'SIPAN', 'SIPAS', 'SIPBS', 'SIPCS', 'SIPCV', 'SIPDC', 'SIPEF', 'SIPEN',
            'SIPER', 'SIPES', 'SIPGE', 'SIPNC', 'SIPNL', 'SIPOS', 'SIRAN', 'SIRFE', 'SIRIC', 'SIRIM',
            'SIROT', 'SIRUC', 'SISAG', 'SISDE', 'SISET', 'SISFG', 'SISFI', 'SISGR', 'SISIB', 'SISPB',
            'SISPI', 'SISPL', 'SISR2', 'SISR4', 'SISRH', 'SITAE', 'SITAG', 'SITAX', 'SITEC', 'SITEF',
            'SITLO', 'SITMN', 'SITRC', 'SITRF', 'SIVAT', 'SIWIC', 'SIWPC'
        )
        AND TRUNC(TO_TIMESTAMP('1970-01-01 00:00:00.0','YYYY-MM-DD HH24:MI:SS.FF') + 
            NUMTODSINTERVAL(inc.submit_date,'SECOND') - INTERVAL '3' HOUR) >= TO_DATE('01/01/2024', 'DD/MM/YYYY')
        AND (TO_TIMESTAMP('1970-01-01 00:00:00.0','YYYY-MM-DD HH24:MI:SS.FF') + 
             NUMTODSINTERVAL(inc.last_resolved_date,'SECOND') - INTERVAL '3' HOUR) IS NOT NULL
)

-- QUERY PRINCIPAL - RESULTADO FINAL DA TABELA FATO
SELECT DISTINCT
    asso.incident_number,                                    -- CHAVE PRIMÁRIA
    TO_CHAR(base.data_hora_abertura, 'YYYY/MM/DD HH24:MI:SS') data_hora_abertura,  -- MÉTRICA TEMPORAL
    base.data_hora_fechamento,                               -- MÉTRICA TEMPORAL PARA CALCULAR TEMPO OPERACIONAL
    base.co_prioridade,                                      -- CHAVE ESTRANGEIRA DA TB_DIMENSAO_PRIORIDADES
    base.ds_crise_grave,                                     -- CHAVE ESTRANGEIRA DA TB_DIMENSAO_CRISE
    base.co_tipo_incidente,                                  -- CHAVE ESTRANGEIRA DA TB_DIMENSAO_TIPO_INCIDENTE
    base.sigla,                                              -- CHAVE ESTRANGEIRA DA TB_DIMENSAO_SIGLA
    base.co_motivo_status,                                   -- CHAVE ESTRANGEIRA DA TB_DIMENSAO_MOTIVO_STATUS
    base.co_impacto,                                         -- CHAVE ESTRANGEIRA DA TB_DIMENSAO_IMPACTO
    -- Métricas calculadas adicionais
    base.duracao_resolucao_horas,                            -- MÉTRICA: Tempo de resolução
    base.periodo_abertura,                                   -- DIMENSÃO: Período do dia
    base.fim_semana,                                         -- DIMENSÃO: Indicador de fim de semana
    base.score_criticidade,                                  -- MÉTRICA: Score composto de criticidade
    -- Chave para dimensão de tempo
    TRUNC(base.data_hora_abertura) AS data_abertura,         -- CHAVE ESTRANGEIRA DA TB_DIMENSAO_DATAS
    -- Métricas para cálculo de MTBF
    1 AS contador_incidentes,                                -- MÉTRICA: Contador para agregações
    CASE 
        WHEN base.duracao_resolucao_horas IS NOT NULL THEN base.duracao_resolucao_horas
        ELSE 0
    END AS tempo_indisponibilidade                           -- MÉTRICA: Tempo de indisponibilidade
FROM
    incidentes_associados asso
    INNER JOIN base_incidentes base ON asso.incident_number = base.incident_number
ORDER BY 
    base.data_hora_abertura DESC,
    base.score_criticidade DESC;

