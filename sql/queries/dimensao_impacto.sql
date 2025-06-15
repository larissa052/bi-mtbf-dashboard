-- =====================================================
-- TABELA DIMENSÃO IMPACTO
-- Baseada na implementação real para Caixa Econômica Federal
-- Classificação de níveis de impacto de incidentes
-- =====================================================

-- TB_DIMENSAO_IMPACTO
-- DIMENSÃO PARA CLASSIFICAÇÃO DE IMPACTO DE INCIDENTES
SELECT DISTINCT
    inc.impact co_impacto,
    CASE inc.impact
        WHEN 1000 THEN '1 - Extensivo/difundido'
        WHEN 2000 THEN '2 - Significativo/grande'
        WHEN 3000 THEN '3 - Moderado/limitado'
        WHEN 4000 THEN '4 - Menor/localizado'
        ELSE 'Impacto Não Classificado'
    END ds_impacto,
    -- Campos adicionais para análise
    CASE inc.impact
        WHEN 1000 THEN 'EXTENSIVO'
        WHEN 2000 THEN 'SIGNIFICATIVO'
        WHEN 3000 THEN 'MODERADO'
        WHEN 4000 THEN 'MENOR'
        ELSE 'NAO_CLASSIFICADO'
    END categoria_impacto,
    -- Nível numérico para ordenação
    CASE inc.impact
        WHEN 1000 THEN 1
        WHEN 2000 THEN 2
        WHEN 3000 THEN 3
        WHEN 4000 THEN 4
        ELSE 5
    END nivel_impacto,
    -- Descrição detalhada do impacto
    CASE inc.impact
        WHEN 1000 THEN 'Impacto extensivo afetando múltiplos serviços e grande número de usuários'
        WHEN 2000 THEN 'Impacto significativo afetando serviços importantes ou muitos usuários'
        WHEN 3000 THEN 'Impacto moderado com efeito limitado em serviços ou usuários específicos'
        WHEN 4000 THEN 'Impacto menor localizado em funcionalidades ou usuários específicos'
        ELSE 'Impacto não foi classificado adequadamente'
    END descricao_detalhada,
    -- Tempo máximo de resolução baseado no impacto (em horas)
    CASE inc.impact
        WHEN 1000 THEN 1   -- Extensivo: 1 hora
        WHEN 2000 THEN 2   -- Significativo: 2 horas
        WHEN 3000 THEN 4   -- Moderado: 4 horas
        WHEN 4000 THEN 8   -- Menor: 8 horas
        ELSE 24            -- Não classificado: 24 horas
    END sla_resolucao_horas,
    -- Requer comunicação externa
    CASE inc.impact
        WHEN 1000 THEN 'S'  -- Extensivo: Sim
        WHEN 2000 THEN 'S'  -- Significativo: Sim
        WHEN 3000 THEN 'N'  -- Moderado: Não
        WHEN 4000 THEN 'N'  -- Menor: Não
        ELSE 'N'            -- Não classificado: Não
    END requer_comunicacao_externa,
    -- Peso para cálculos de disponibilidade
    CASE inc.impact
        WHEN 1000 THEN 4.0  -- Extensivo
        WHEN 2000 THEN 3.0  -- Significativo
        WHEN 3000 THEN 2.0  -- Moderado
        WHEN 4000 THEN 1.0  -- Menor
        ELSE 0.5            -- Não classificado
    END peso_disponibilidade,
    -- Percentual estimado de usuários afetados
    CASE inc.impact
        WHEN 1000 THEN 75   -- Extensivo: 75%+
        WHEN 2000 THEN 50   -- Significativo: 50%+
        WHEN 3000 THEN 25   -- Moderado: 25%+
        WHEN 4000 THEN 5    -- Menor: 5%+
        ELSE 0              -- Não classificado: 0%
    END percentual_usuarios_afetados,
    -- Requer escalação imediata
    CASE inc.impact
        WHEN 1000 THEN 'S'  -- Extensivo: Sim
        WHEN 2000 THEN 'S'  -- Significativo: Sim
        WHEN 3000 THEN 'N'  -- Moderado: Não
        WHEN 4000 THEN 'N'  -- Menor: Não
        ELSE 'N'            -- Não classificado: Não
    END escalacao_imediata,
    -- Cor para visualização (hex)
    CASE inc.impact
        WHEN 1000 THEN '#FF0000'  -- Vermelho (Extensivo)
        WHEN 2000 THEN '#FF6600'  -- Laranja (Significativo)
        WHEN 3000 THEN '#FFCC00'  -- Amarelo (Moderado)
        WHEN 4000 THEN '#00CC00'  -- Verde (Menor)
        ELSE '#CCCCCC'            -- Cinza (Não classificado)
    END cor_visualizacao
FROM
    sistema_incidentes.tb_help_desk inc  -- Tabela mascarada
WHERE
    inc.impact IS NOT NULL
ORDER BY inc.impact;

