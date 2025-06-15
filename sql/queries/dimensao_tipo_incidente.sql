-- =====================================================
-- TABELA DIMENSÃO TIPO DE INCIDENTE
-- Baseada na implementação real para Caixa Econômica Federal
-- Classificação de tipos de serviço de incidentes
-- =====================================================

-- TB_DIMENSAO_TIPO_INCIDENTE
-- DIMENSÃO PARA CLASSIFICAÇÃO DE TIPOS DE INCIDENTE
SELECT DISTINCT
    inc.service_type co_tipo_incidente,
    CASE inc.service_type
        WHEN 0 THEN 'Restauração de Serviço do Usuário'
        WHEN 1 THEN 'Solicitação de Serviço do Usuário'
        WHEN 2 THEN 'Restauração de infraestrutura'
        WHEN 3 THEN 'Evento de infraestrutura'
        ELSE 'Tipo Não Classificado'
    END ds_tipo_incidente,
    -- Campos adicionais para análise
    CASE inc.service_type
        WHEN 0 THEN 'RESTAURACAO_USUARIO'
        WHEN 1 THEN 'SOLICITACAO_USUARIO'
        WHEN 2 THEN 'RESTAURACAO_INFRA'
        WHEN 3 THEN 'EVENTO_INFRA'
        ELSE 'NAO_CLASSIFICADO'
    END categoria_tipo,
    -- Classificação por área de impacto
    CASE inc.service_type
        WHEN 0 THEN 'USUARIO_FINAL'
        WHEN 1 THEN 'USUARIO_FINAL'
        WHEN 2 THEN 'INFRAESTRUTURA'
        WHEN 3 THEN 'INFRAESTRUTURA'
        ELSE 'INDEFINIDO'
    END area_impacto,
    -- Prioridade padrão por tipo
    CASE inc.service_type
        WHEN 0 THEN 1  -- Restauração usuário: Alta
        WHEN 1 THEN 2  -- Solicitação usuário: Média
        WHEN 2 THEN 0  -- Restauração infra: Crítica
        WHEN 3 THEN 1  -- Evento infra: Alta
        ELSE 3         -- Não classificado: Baixa
    END prioridade_padrao,
    -- SLA padrão em horas por tipo
    CASE inc.service_type
        WHEN 0 THEN 4   -- Restauração usuário: 4h
        WHEN 1 THEN 24  -- Solicitação usuário: 24h
        WHEN 2 THEN 2   -- Restauração infra: 2h
        WHEN 3 THEN 8   -- Evento infra: 8h
        ELSE 48         -- Não classificado: 48h
    END sla_padrao_horas,
    -- Indica se afeta MTBF
    CASE inc.service_type
        WHEN 0 THEN 'S'  -- Restauração usuário: Sim
        WHEN 1 THEN 'N'  -- Solicitação usuário: Não
        WHEN 2 THEN 'S'  -- Restauração infra: Sim
        WHEN 3 THEN 'S'  -- Evento infra: Sim
        ELSE 'N'         -- Não classificado: Não
    END afeta_mtbf,
    -- Peso para cálculos de disponibilidade
    CASE inc.service_type
        WHEN 0 THEN 2.0  -- Restauração usuário
        WHEN 1 THEN 0.0  -- Solicitação usuário (não afeta)
        WHEN 2 THEN 3.0  -- Restauração infra
        WHEN 3 THEN 1.5  -- Evento infra
        ELSE 0.5         -- Não classificado
    END peso_disponibilidade
FROM
    sistema_incidentes.tb_help_desk inc  -- Tabela mascarada
WHERE
    inc.service_type IS NOT NULL
ORDER BY inc.service_type;

