-- =====================================================
-- TABELA DIMENSÃO DATAS - ESTRUTURA TEMPORAL COMPLETA
-- Baseada na implementação real para Caixa Econômica Federal
-- Dados mascarados para portfólio
-- =====================================================

-- TB_DIMENSAO_DATAS
-- TABELA DIMENSÃO DATAS COM HIERARQUIA TEMPORAL COMPLETA
SELECT
    data,
    data as data_sem_hora,
    EXTRACT(YEAR FROM data) ano,
    TO_CHAR(data,'MM/YYYY') mes_ano,
    EXTRACT(MONTH FROM data) mes,
    EXTRACT(DAY FROM data) dia,
    TO_CHAR(data,'Q') trimestre,
    -- Campos adicionais para análise temporal avançada
    TO_CHAR(data, 'Day', 'NLS_DATE_LANGUAGE=PORTUGUESE') dia_semana,
    TO_CHAR(data, 'D') numero_dia_semana,
    TO_CHAR(data, 'WW') semana_ano,
    TO_CHAR(data, 'IW') semana_iso,
    CASE 
        WHEN TO_CHAR(data, 'D') IN ('1', '7') THEN 'S' 
        ELSE 'N' 
    END fim_semana,
    -- Identificação de feriados bancários (simplificado)
    CASE 
        WHEN TO_CHAR(data, 'MM-DD') IN ('01-01', '04-21', '09-07', '10-12', '11-02', '11-15', '12-25') THEN 'S'
        ELSE 'N'
    END feriado_nacional,
    -- Período fiscal
    CASE 
        WHEN EXTRACT(MONTH FROM data) BETWEEN 1 AND 3 THEN 1
        WHEN EXTRACT(MONTH FROM data) BETWEEN 4 AND 6 THEN 2
        WHEN EXTRACT(MONTH FROM data) BETWEEN 7 AND 9 THEN 3
        ELSE 4
    END trimestre_fiscal
-- GERANDO O INTERVALO DE TEMPO DE 01/2023 A 12/2025
FROM
    (
        SELECT
            TO_DATE('01-JAN-2023','DD-MM-YYYY') + level - 1 AS data
        FROM
            dual
        CONNECT BY
            level <= ( TO_DATE('31-12-2025','DD-MM-YYYY') - TO_DATE('01-01-2023','DD-MM-YYYY') ) + 1
    )
ORDER BY data;

