-- =====================================================
-- TABELA DIMENSÃO SIGLA (SISTEMAS)
-- Baseada na implementação real para Caixa Econômica Federal
-- Mapeamento de sistemas por sigla e agrupamento por serviços
-- =====================================================

-- TB_DIMENSAO_SIGLA
-- DIMENSÃO PARA CLASSIFICAÇÃO DE SISTEMAS POR SIGLA E SERVIÇO
SELECT DISTINCT
    SUBSTR(inc.hpd_ci, 9, 5) AS sigla,
    CASE 
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SILCE', 'SISPL', 'SIMLO') THEN 'Loterias'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIIBC', 'SINBC', 'SINBM') THEN 'Internet Banking'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SIPCS' THEN 'Cartões'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIMPI', 'SISPI', 'SIMTX') THEN 'PIX'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SISAG', 'SIPNC', 'SIMAA', 'SIPNL', 'SIMTC') THEN 'Agências'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIBEC', 'SIPBS', 'SIPAS') THEN 'Benefícios Sociais'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIISO', 'SIINF', 'SIINT') THEN 'Infraestrutura'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIGOV', 'SIGEP', 'SIGDA') THEN 'Governo'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SICAC', 'SICAP', 'SICAQ') THEN 'Crédito e Financiamento'
        ELSE 'Outros Sistemas'
    END servico_agrupado,
    -- Campos adicionais para análise
    CASE 
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SILCE', 'SISPL', 'SIMLO') THEN 'LOTERIAS'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIIBC', 'SINBC', 'SINBM') THEN 'INTERNET_BANKING'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SIPCS' THEN 'CARTOES'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIMPI', 'SISPI', 'SIMTX') THEN 'PIX'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SISAG', 'SIPNC', 'SIMAA', 'SIPNL', 'SIMTC') THEN 'AGENCIAS'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIBEC', 'SIPBS', 'SIPAS') THEN 'BENEFICIOS_SOCIAIS'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIISO', 'SIINF', 'SIINT') THEN 'INFRAESTRUTURA'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIGOV', 'SIGEP', 'SIGDA') THEN 'GOVERNO'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SICAC', 'SICAP', 'SICAQ') THEN 'CREDITO_FINANCIAMENTO'
        ELSE 'OUTROS'
    END categoria_servico,
    -- Criticidade do sistema para o negócio
    CASE 
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIIBC', 'SINBC', 'SINBM', 'SIPCS', 'SIMPI', 'SISPI', 'SIMTX') THEN 'CRITICO'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SILCE', 'SISPL', 'SIMLO', 'SISAG', 'SIPNC', 'SIMAA') THEN 'ALTO'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIBEC', 'SIPBS', 'SIPAS', 'SIGOV', 'SIGEP') THEN 'MEDIO'
        ELSE 'BAIXO'
    END criticidade_negocio,
    -- SLA específico por tipo de sistema (em horas)
    CASE 
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIIBC', 'SINBC', 'SINBM', 'SIPCS', 'SIMPI', 'SISPI', 'SIMTX') THEN 1
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SILCE', 'SISPL', 'SIMLO', 'SISAG', 'SIPNC', 'SIMAA') THEN 2
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIBEC', 'SIPBS', 'SIPAS', 'SIGOV', 'SIGEP') THEN 4
        ELSE 8
    END sla_sistema_horas,
    -- Horário de funcionamento
    CASE 
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIIBC', 'SINBC', 'SINBM', 'SIPCS', 'SIMPI', 'SISPI', 'SIMTX') THEN '24x7'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SILCE', 'SISPL', 'SIMLO') THEN '06:00-24:00'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SISAG', 'SIPNC', 'SIMAA', 'SIPNL', 'SIMTC') THEN '08:00-18:00'
        ELSE '08:00-17:00'
    END horario_funcionamento,
    -- Peso para cálculos de MTBF (baseado na criticidade)
    CASE 
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIIBC', 'SINBC', 'SINBM', 'SIPCS', 'SIMPI', 'SISPI', 'SIMTX') THEN 4.0
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SILCE', 'SISPL', 'SIMLO', 'SISAG', 'SIPNC', 'SIMAA') THEN 3.0
        WHEN SUBSTR(inc.hpd_ci, 9, 5) IN ('SIBEC', 'SIPBS', 'SIPAS', 'SIGOV', 'SIGEP') THEN 2.0
        ELSE 1.0
    END peso_mtbf,
    -- Descrição completa do sistema (mascarada)
    CASE 
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SIIBC' THEN 'Sistema de Internet Banking Corporativo'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SINBC' THEN 'Sistema de Internet Banking Pessoa Física'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SIPCS' THEN 'Sistema de Processamento de Cartões'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SIMPI' THEN 'Sistema de Mensageria PIX'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SISPI' THEN 'Sistema de Processamento PIX'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SILCE' THEN 'Sistema de Loterias Eletrônicas'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SISAG' THEN 'Sistema de Gestão de Agências'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SIBEC' THEN 'Sistema de Benefícios Sociais'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SIPBS' THEN 'Sistema de Processamento de Benefícios'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SIPAS' THEN 'Sistema de Pagamentos Sociais'
        WHEN SUBSTR(inc.hpd_ci, 9, 5) = 'SIISO' THEN 'Sistema de Infraestrutura e Operações'
        ELSE 'Sistema ' || SUBSTR(inc.hpd_ci, 9, 5)
    END descricao_sistema
FROM
    sistema_incidentes.tb_help_desk inc  -- Tabela mascarada
WHERE
    SUBSTR(inc.hpd_ci, 9, 5) IN (
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
ORDER BY sigla;

