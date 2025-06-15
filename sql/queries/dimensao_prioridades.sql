-- =====================================================
-- TABELA DIMENSÃO PRIORIDADES
-- Baseada na implementação real para Caixa Econômica Federal
-- Classificação de prioridades de incidentes
-- =====================================================

-- TB_DIMENSAO_PRIORIDADES
-- DIMENSÃO PARA CLASSIFICAÇÃO DE PRIORIDADES DE INCIDENTES
SELECT DISTINCT
    inc.priority co_prioridade,
    CASE
        WHEN inc.priority = 1 THEN 'Alto'
        WHEN inc.priority = 0 THEN 'Crítico'
        WHEN inc.priority = 2 THEN 'Médio'
        WHEN inc.priority = 3 THEN 'Baixo'
        ELSE 'Não Classificado'
    END ds_prioridade,
    -- Campos adicionais para análise
    CASE
        WHEN inc.priority IN (0, 1) THEN 'ALTA_CRITICIDADE'
        WHEN inc.priority IN (2, 3) THEN 'BAIXA_CRITICIDADE'
        ELSE 'NAO_CLASSIFICADO'
    END categoria_criticidade,
    -- SLA em horas baseado na prioridade
    CASE
        WHEN inc.priority = 0 THEN 2    -- Crítico: 2 horas
        WHEN inc.priority = 1 THEN 4    -- Alto: 4 horas
        WHEN inc.priority = 2 THEN 8    -- Médio: 8 horas
        WHEN inc.priority = 3 THEN 24   -- Baixo: 24 horas
        ELSE NULL
    END sla_resolucao_horas,
    -- Peso para cálculos de impacto
    CASE
        WHEN inc.priority = 0 THEN 4    -- Crítico
        WHEN inc.priority = 1 THEN 3    -- Alto
        WHEN inc.priority = 2 THEN 2    -- Médio
        WHEN inc.priority = 3 THEN 1    -- Baixo
        ELSE 0
    END peso_prioridade
FROM
    sistema_incidentes.tb_help_desk inc  -- Tabela mascarada
WHERE
    inc.priority IS NOT NULL
ORDER BY inc.priority;

