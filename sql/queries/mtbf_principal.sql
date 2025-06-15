-- =====================================================
-- QUERY PRINCIPAL PARA CÁLCULO DE MTBF
-- Demonstra análise de séries temporais complexa
-- Desenvolvido para Caixa Econômica Federal
-- =====================================================

WITH incidentes_processados AS (
    -- CTE para processar e classificar incidentes por sistema
    SELECT 
        i.sistema_id,
        i.servico_id,
        i.data_abertura,
        i.data_fechamento,
        i.impacto_id,
        i.prioridade_id,
        i.tipo_incidente,
        s.nome_sistema,
        srv.nome_servico,
        -- Calcula duração do incidente em minutos
        ROUND(
            (EXTRACT(DAY FROM (i.data_fechamento - i.data_abertura)) * 24 * 60) +
            (EXTRACT(HOUR FROM (i.data_fechamento - i.data_abertura)) * 60) +
            EXTRACT(MINUTE FROM (i.data_fechamento - i.data_abertura)), 2
        ) AS duracao_minutos,
        -- Identifica se é incidente crítico
        CASE 
            WHEN i.impacto_id IN (1, 2) AND i.prioridade_id IN (1, 2) THEN 'CRITICO'
            WHEN i.impacto_id = 3 AND i.prioridade_id IN (1, 2, 3) THEN 'ALTO'
            ELSE 'MEDIO'
        END AS criticidade,
        -- Calcula tempo entre incidentes usando LAG
        LAG(i.data_abertura) OVER (
            PARTITION BY i.sistema_id, i.servico_id 
            ORDER BY i.data_abertura
        ) AS incidente_anterior,
        -- Numeração sequencial para cálculos posteriores
        ROW_NUMBER() OVER (
            PARTITION BY i.sistema_id, i.servico_id 
            ORDER BY i.data_abertura
        ) AS seq_incidente
    FROM tb_incidentes i
    INNER JOIN tb_sistemas s ON i.sistema_id = s.sistema_id
    INNER JOIN tb_servicos srv ON i.servico_id = srv.servico_id
    WHERE i.data_abertura >= ADD_MONTHS(SYSDATE, -12) -- Últimos 12 meses
      AND i.status_incidente = 'FECHADO'
      AND s.ativo = 'S'
      AND srv.ativo = 'S'
),

tempo_entre_falhas AS (
    -- CTE para calcular tempo entre falhas consecutivas
    SELECT 
        sistema_id,
        servico_id,
        nome_sistema,
        nome_servico,
        data_abertura,
        data_fechamento,
        duracao_minutos,
        criticidade,
        incidente_anterior,
        seq_incidente,
        -- Calcula tempo entre falhas em horas
        CASE 
            WHEN incidente_anterior IS NOT NULL THEN
                ROUND(
                    (EXTRACT(DAY FROM (data_abertura - incidente_anterior)) * 24) +
                    EXTRACT(HOUR FROM (data_abertura - incidente_anterior)) +
                    (EXTRACT(MINUTE FROM (data_abertura - incidente_anterior)) / 60), 2
                )
            ELSE NULL
        END AS tempo_entre_falhas_horas,
        -- Calcula período operacional (tempo total - tempo de reparo)
        CASE 
            WHEN incidente_anterior IS NOT NULL THEN
                ROUND(
                    ((EXTRACT(DAY FROM (data_abertura - incidente_anterior)) * 24) +
                     EXTRACT(HOUR FROM (data_abertura - incidente_anterior)) +
                     (EXTRACT(MINUTE FROM (data_abertura - incidente_anterior)) / 60)) -
                    (duracao_minutos / 60), 2
                )
            ELSE NULL
        END AS tempo_operacional_horas
    FROM incidentes_processados
),

metricas_mtbf AS (
    -- CTE para calcular métricas MTBF por sistema/serviço
    SELECT 
        sistema_id,
        servico_id,
        nome_sistema,
        nome_servico,
        COUNT(*) as total_incidentes,
        COUNT(tempo_entre_falhas_horas) as incidentes_com_intervalo,
        -- MTBF em horas (média do tempo entre falhas)
        ROUND(AVG(tempo_entre_falhas_horas), 2) as mtbf_horas,
        -- MTBF em dias
        ROUND(AVG(tempo_entre_falhas_horas) / 24, 2) as mtbf_dias,
        -- Tempo médio de reparo (MTTR)
        ROUND(AVG(duracao_minutos) / 60, 2) as mttr_horas,
        -- Disponibilidade calculada
        ROUND(
            (AVG(tempo_operacional_horas) / 
             NULLIF(AVG(tempo_entre_falhas_horas), 0)) * 100, 4
        ) as disponibilidade_percentual,
        -- Métricas de variabilidade
        ROUND(STDDEV(tempo_entre_falhas_horas), 2) as desvio_padrao_mtbf,
        ROUND(
            CASE 
                WHEN AVG(tempo_entre_falhas_horas) > 0 THEN
                    (STDDEV(tempo_entre_falhas_horas) / AVG(tempo_entre_falhas_horas)) * 100
                ELSE NULL
            END, 2
        ) as coeficiente_variacao,
        -- Período de análise
        MIN(data_abertura) as periodo_inicio,
        MAX(data_abertura) as periodo_fim,
        -- Classificação de criticidade predominante
        MODE() WITHIN GROUP (ORDER BY criticidade) as criticidade_predominante
    FROM tempo_entre_falhas
    WHERE tempo_entre_falhas_horas IS NOT NULL
    GROUP BY sistema_id, servico_id, nome_sistema, nome_servico
),

ranking_sistemas AS (
    -- CTE para ranking de sistemas por confiabilidade
    SELECT 
        m.*,
        -- Ranking por MTBF (maior é melhor)
        RANK() OVER (ORDER BY mtbf_dias DESC) as rank_mtbf,
        -- Ranking por disponibilidade (maior é melhor)
        RANK() OVER (ORDER BY disponibilidade_percentual DESC) as rank_disponibilidade,
        -- Score composto de confiabilidade
        ROUND(
            (mtbf_dias * 0.4) + 
            (disponibilidade_percentual * 0.4) + 
            ((100 - coeficiente_variacao) * 0.2), 2
        ) as score_confiabilidade,
        -- Classificação de maturidade do sistema
        CASE 
            WHEN mtbf_dias >= 30 AND disponibilidade_percentual >= 99.5 THEN 'EXCELENTE'
            WHEN mtbf_dias >= 15 AND disponibilidade_percentual >= 99.0 THEN 'BOM'
            WHEN mtbf_dias >= 7 AND disponibilidade_percentual >= 98.0 THEN 'REGULAR'
            ELSE 'CRITICO'
        END as classificacao_maturidade
    FROM metricas_mtbf m
    WHERE total_incidentes >= 3 -- Mínimo de incidentes para análise estatística
)

-- QUERY PRINCIPAL - Resultado final com todas as métricas
SELECT 
    r.sistema_id,
    r.servico_id,
    r.nome_sistema,
    r.nome_servico,
    r.total_incidentes,
    r.mtbf_dias,
    r.mttr_horas,
    r.disponibilidade_percentual,
    r.desvio_padrao_mtbf,
    r.coeficiente_variacao,
    r.score_confiabilidade,
    r.classificacao_maturidade,
    r.rank_mtbf,
    r.rank_disponibilidade,
    r.criticidade_predominante,
    TO_CHAR(r.periodo_inicio, 'DD/MM/YYYY') as periodo_inicio_fmt,
    TO_CHAR(r.periodo_fim, 'DD/MM/YYYY') as periodo_fim_fmt,
    -- Indicadores de tendência (comparação com período anterior)
    LAG(r.mtbf_dias, 1) OVER (
        PARTITION BY r.sistema_id, r.servico_id 
        ORDER BY r.periodo_fim
    ) as mtbf_periodo_anterior,
    -- Cálculo de tendência
    CASE 
        WHEN LAG(r.mtbf_dias, 1) OVER (
            PARTITION BY r.sistema_id, r.servico_id 
            ORDER BY r.periodo_fim
        ) IS NOT NULL THEN
            ROUND(
                ((r.mtbf_dias - LAG(r.mtbf_dias, 1) OVER (
                    PARTITION BY r.sistema_id, r.servico_id 
                    ORDER BY r.periodo_fim
                )) / LAG(r.mtbf_dias, 1) OVER (
                    PARTITION BY r.sistema_id, r.servico_id 
                    ORDER BY r.periodo_fim
                )) * 100, 2
            )
        ELSE NULL
    END as variacao_percentual_mtbf,
    -- Projeção de próxima falha (baseada em MTBF)
    CASE 
        WHEN r.mtbf_dias > 0 THEN
            TO_CHAR(
                r.periodo_fim + r.mtbf_dias, 
                'DD/MM/YYYY HH24:MI'
            )
        ELSE NULL
    END as proxima_falha_estimada
FROM ranking_sistemas r
ORDER BY 
    r.score_confiabilidade DESC,
    r.mtbf_dias DESC,
    r.disponibilidade_percentual DESC;

