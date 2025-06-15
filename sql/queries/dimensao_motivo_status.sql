-- =====================================================
-- TABELA DIMENSÃO MOTIVO STATUS
-- Baseada na implementação real para Caixa Econômica Federal
-- Mapeamento detalhado dos códigos de status de resolução
-- =====================================================

-- TB_DIMENSAO_MOTIVO_STATUS
-- DIMENSÃO PARA CLASSIFICAÇÃO DE MOTIVOS DE STATUS DE RESOLUÇÃO
SELECT DISTINCT
    CASE
        WHEN inc.status_reason IS NULL THEN 0
        ELSE inc.status_reason
    END co_motivo_status,
    CASE
        WHEN inc.status_reason = 1000  THEN 'Mudança de Infraestrutura Criada'
        WHEN inc.status_reason = 6000  THEN 'Contato de Suporte em Espera'
        WHEN inc.status_reason = 7000  THEN 'Ação Requerida de Fornecedor'
        WHEN inc.status_reason = 8000  THEN 'Ação do Cliente Requerida'
        WHEN inc.status_reason = 11000 THEN 'Melhorias Futuras'
        WHEN inc.status_reason = 12000 THEN 'Incidente Original Pendente'
        WHEN inc.status_reason = 14000 THEN 'Monitorando Incidente'
        WHEN inc.status_reason = 15000 THEN 'Acompanhamento do Cliente'
        WHEN inc.status_reason = 16000 THEN 'Ação Corretiva Temporária'
        WHEN inc.status_reason = 17000 THEN 'Nenhuma Outra Ação Requerida'
        WHEN inc.status_reason = 18000 THEN 'Resolvido pelo Incidente Original'
        WHEN inc.status_reason = 19000 THEN 'Resolução Automatizada Informada'
        WHEN inc.status_reason = 20000 THEN 'Não é mais um IC Causal'
        WHEN inc.status_reason = 21000 THEN 'Solução Definitiva'
        WHEN inc.status_reason = 22000 THEN 'Solução de Contorno'
        WHEN inc.status_reason IS NULL THEN 'Motivo Não Informado'
        ELSE 'Outros'
    END ds_motivo_status,
    -- Campos adicionais para análise
    CASE
        WHEN inc.status_reason IN (21000, 17000, 19000) THEN 'RESOLVIDO_DEFINITIVO'
        WHEN inc.status_reason IN (22000, 16000) THEN 'RESOLVIDO_TEMPORARIO'
        WHEN inc.status_reason IN (18000, 20000) THEN 'RESOLVIDO_RELACIONADO'
        WHEN inc.status_reason IN (7000, 8000, 6000, 15000) THEN 'AGUARDANDO_TERCEIROS'
        WHEN inc.status_reason IN (1000, 11000, 12000, 14000) THEN 'EM_ANDAMENTO'
        WHEN inc.status_reason IS NULL THEN 'NAO_INFORMADO'
        ELSE 'OUTROS'
    END categoria_resolucao,
    -- Indica se a resolução é definitiva
    CASE
        WHEN inc.status_reason IN (21000, 17000, 19000) THEN 'S'
        ELSE 'N'
    END resolucao_definitiva,
    -- Indica se requer acompanhamento
    CASE
        WHEN inc.status_reason IN (14000, 15000, 16000, 22000) THEN 'S'
        ELSE 'N'
    END requer_acompanhamento,
    -- Peso para cálculos de efetividade
    CASE
        WHEN inc.status_reason IN (21000, 17000, 19000) THEN 1.0  -- Resolução definitiva
        WHEN inc.status_reason IN (22000, 16000) THEN 0.7         -- Resolução temporária
        WHEN inc.status_reason IN (18000, 20000) THEN 0.9         -- Resolução relacionada
        WHEN inc.status_reason IN (7000, 8000, 6000, 15000) THEN 0.5  -- Aguardando terceiros
        WHEN inc.status_reason IN (1000, 11000, 12000, 14000) THEN 0.3 -- Em andamento
        WHEN inc.status_reason IS NULL THEN 0.1                   -- Não informado
        ELSE 0.2                                                  -- Outros
    END peso_efetividade,
    -- Tempo estimado para resolução final (em horas)
    CASE
        WHEN inc.status_reason IN (21000, 17000, 19000) THEN 0    -- Já resolvido
        WHEN inc.status_reason IN (22000, 16000) THEN 24          -- Resolução temporária
        WHEN inc.status_reason IN (18000, 20000) THEN 4           -- Resolução relacionada
        WHEN inc.status_reason IN (7000, 8000, 6000, 15000) THEN 72  -- Aguardando terceiros
        WHEN inc.status_reason IN (1000, 11000, 12000, 14000) THEN 48 -- Em andamento
        ELSE 96                                                   -- Outros/Não informado
    END tempo_estimado_resolucao_horas
FROM
    sistema_incidentes.tb_help_desk inc  -- Tabela mascarada
ORDER BY co_motivo_status;

