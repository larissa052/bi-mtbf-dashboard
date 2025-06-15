-- =====================================================
-- TABELA DIMENSÃO CRISE/GRAVE
-- Baseada na implementação real para Caixa Econômica Federal
-- Classificação de severidade de incidentes
-- =====================================================

-- TB_DIMENSAO_CRISE
-- DIMENSÃO PARA CLASSIFICAÇÃO DE SEVERIDADE DE INCIDENTES
SELECT DISTINCT
    CASE
        WHEN inc.categorization_tier_1 = 'Crise'
             OR inc.categorization_tier_1 = 'Crise GGC acionado' THEN 'Crise'
        WHEN inc.categorization_tier_1 = 'Incidente Grave' THEN 'Grave'
        WHEN inc.categorization_tier_1 IS NULL THEN 'Sem Informação'
        ELSE inc.categorization_tier_1
    END ds_crise_grave,
    -- Campos adicionais para análise de impacto
    CASE
        WHEN inc.categorization_tier_1 = 'Crise'
             OR inc.categorization_tier_1 = 'Crise GGC acionado' THEN 1
        WHEN inc.categorization_tier_1 = 'Incidente Grave' THEN 2
        WHEN inc.categorization_tier_1 IS NULL THEN 99
        ELSE 3
    END co_nivel_severidade,
    -- Descrição detalhada do nível
    CASE
        WHEN inc.categorization_tier_1 = 'Crise'
             OR inc.categorization_tier_1 = 'Crise GGC acionado' THEN 'Incidente de máxima severidade com impacto crítico nos serviços'
        WHEN inc.categorization_tier_1 = 'Incidente Grave' THEN 'Incidente grave com impacto significativo nos serviços'
        WHEN inc.categorization_tier_1 IS NULL THEN 'Classificação não informada'
        ELSE 'Incidente de severidade padrão'
    END ds_detalhada_severidade,
    -- Tempo máximo de resposta em minutos
    CASE
        WHEN inc.categorization_tier_1 = 'Crise'
             OR inc.categorization_tier_1 = 'Crise GGC acionado' THEN 15
        WHEN inc.categorization_tier_1 = 'Incidente Grave' THEN 30
        ELSE 60
    END tempo_resposta_minutos,
    -- Requer escalação automática
    CASE
        WHEN inc.categorization_tier_1 = 'Crise'
             OR inc.categorization_tier_1 = 'Crise GGC acionado' THEN 'S'
        WHEN inc.categorization_tier_1 = 'Incidente Grave' THEN 'S'
        ELSE 'N'
    END escalacao_automatica,
    -- Peso para cálculos de MTBF
    CASE
        WHEN inc.categorization_tier_1 = 'Crise'
             OR inc.categorization_tier_1 = 'Crise GGC acionado' THEN 5.0
        WHEN inc.categorization_tier_1 = 'Incidente Grave' THEN 3.0
        ELSE 1.0
    END peso_mtbf
FROM
    sistema_incidentes.tb_help_desk inc  -- Tabela mascarada
WHERE
    inc.categorization_tier_1 IS NOT NULL
   OR inc.categorization_tier_1 IS NULL  -- Incluir registros sem classificação
ORDER BY co_nivel_severidade;

