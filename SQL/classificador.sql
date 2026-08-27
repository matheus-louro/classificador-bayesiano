-- =========================================================================
-- ETAPA 3: Implementação do Classificador Naive Bayes em SQL Puro
-- Domínio: Detecção de Login Suspeito
-- =========================================================================

-- Utilizamos Common Table Expressions (CTE) para estruturar o algoritmo em passos lógicos.
WITH 
-- 1. ENTRADA DE DADOS (CASO DE TESTE)
-- Aqui definimos o cenário que queremos classificar. Altere os valores para testar outros perfis.
-- Este exemplo simula um 'Alto Risco'.
entrada_teste AS (
    SELECT 
        'Internacional'       AS p_localizacao,
        'Novo'                AS p_dispositivo,
        'Madrugada (23h-08h)' AS p_horario,
        '3 ou mais'           AS p_falhas_senha,
        'Proxy_VPN'           AS p_tipo_rede,
        'Suspeita'            AS p_reputacao_ip
),

-- 2. CONTAGENS GERAIS E POR CLASSE
-- Quantidade total de registros e total para cada classe (SIM e NÃO) na base de treinamento.
totais AS (
    SELECT 
        COUNT(*) AS total_registros,
        SUM(CASE WHEN tentativa_invasao = 'SIM' THEN 1 ELSE 0 END) AS total_sim,
        SUM(CASE WHEN tentativa_invasao = 'NÃO' THEN 1 ELSE 0 END) AS total_nao
    FROM tb_treinamento
),

-- 3. CARDINALIDADE DAS FEATURES (Para o cálculo da suavização de Laplace)
-- Contamos quantas categorias únicas existem para cada feature.
cardinalidade AS (
    SELECT 
        (SELECT COUNT(DISTINCT localizacao) FROM tb_treinamento) AS k_loc,
        (SELECT COUNT(DISTINCT dispositivo) FROM tb_treinamento) AS k_disp,
        (SELECT COUNT(DISTINCT horario) FROM tb_treinamento) AS k_hor,
        (SELECT COUNT(DISTINCT falhas_senha) FROM tb_treinamento) AS k_falhas,
        (SELECT COUNT(DISTINCT tipo_rede) FROM tb_treinamento) AS k_rede,
        (SELECT COUNT(DISTINCT reputacao_ip) FROM tb_treinamento) AS k_ip
),

-- 4. PROBABILIDADES A PRIORI: P(Classe) em Logaritmo
-- P(Classe) = Total da Classe / Total de Registros
-- Usamos LN() nativo do SQLite (requer Math function habilitada) para evitar underflow.
priori AS (
    SELECT
        LN(CAST(total_sim AS REAL) / total_registros) AS log_prior_sim,
        LN(CAST(total_nao AS REAL) / total_registros) AS log_prior_nao
    FROM totais
),

-- 5. VEROSSIMILHANÇAS: P(Feature = Valor | Classe) em Logaritmo com SUAVIZAÇÃO DE LAPLACE
-- Fórmula de Laplace: (Contagem da Feature na Classe + 1) / (Total da Classe + Número de Categorias da Feature)
verossimilhancas AS (
    SELECT
        -- Feature: Localização
        LN((SUM(CASE WHEN localizacao = p_localizacao AND tentativa_invasao = 'SIM' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_sim) + MAX(c.k_loc))) AS log_loc_sim,
        LN((SUM(CASE WHEN localizacao = p_localizacao AND tentativa_invasao = 'NÃO' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_nao) + MAX(c.k_loc))) AS log_loc_nao,
        
        -- Feature: Dispositivo
        LN((SUM(CASE WHEN dispositivo = p_dispositivo AND tentativa_invasao = 'SIM' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_sim) + MAX(c.k_disp))) AS log_disp_sim,
        LN((SUM(CASE WHEN dispositivo = p_dispositivo AND tentativa_invasao = 'NÃO' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_nao) + MAX(c.k_disp))) AS log_disp_nao,

        -- Feature: Horário
        LN((SUM(CASE WHEN horario = p_horario AND tentativa_invasao = 'SIM' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_sim) + MAX(c.k_hor))) AS log_hor_sim,
        LN((SUM(CASE WHEN horario = p_horario AND tentativa_invasao = 'NÃO' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_nao) + MAX(c.k_hor))) AS log_hor_nao,

        -- Feature: Falhas Senha
        LN((SUM(CASE WHEN falhas_senha = p_falhas_senha AND tentativa_invasao = 'SIM' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_sim) + MAX(c.k_falhas))) AS log_falhas_sim,
        LN((SUM(CASE WHEN falhas_senha = p_falhas_senha AND tentativa_invasao = 'NÃO' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_nao) + MAX(c.k_falhas))) AS log_falhas_nao,

        -- Feature: Tipo Rede
        LN((SUM(CASE WHEN tipo_rede = p_tipo_rede AND tentativa_invasao = 'SIM' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_sim) + MAX(c.k_rede))) AS log_rede_sim,
        LN((SUM(CASE WHEN tipo_rede = p_tipo_rede AND tentativa_invasao = 'NÃO' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_nao) + MAX(c.k_rede))) AS log_rede_nao,

        -- Feature: Reputacao IP
        LN((SUM(CASE WHEN reputacao_ip = p_reputacao_ip AND tentativa_invasao = 'SIM' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_sim) + MAX(c.k_ip))) AS log_ip_sim,
        LN((SUM(CASE WHEN reputacao_ip = p_reputacao_ip AND tentativa_invasao = 'NÃO' THEN 1 ELSE 0 END) + 1.0) / (MAX(t.total_nao) + MAX(c.k_ip))) AS log_ip_nao
    FROM tb_treinamento, entrada_teste, totais t, cardinalidade c
),

-- 6. SCORE FINAL EM LOG-PROBABILIDADES
-- Somamos os Logaritmos para simular a multiplicação das probabilidades (Log A * B = Log A + Log B)
score_classes AS (
    SELECT
        p.log_prior_sim + v.log_loc_sim + v.log_disp_sim + v.log_hor_sim + v.log_falhas_sim + v.log_rede_sim + v.log_ip_sim AS score_sim,
        p.log_prior_nao + v.log_loc_nao + v.log_disp_nao + v.log_hor_nao + v.log_falhas_nao + v.log_rede_nao + v.log_ip_nao AS score_nao
    FROM priori p, verossimilhancas v
),

-- 7. REVERSÃO DO LOGARITMO PARA NORMALIZAÇÃO (Aplicando a função Exponencial)
-- Precisamos dos valores "brutos" novamente para extrair a porcentagem final de probabilidade
probs_nao_normalizadas AS (
    SELECT
        EXP(score_sim) AS exp_sim,
        EXP(score_nao) AS exp_nao
    FROM score_classes
),

-- 8. NORMALIZAÇÃO FINAL (SCORE ENTRE 0% E 100%) E RECOMENDAÇÃO
-- Probabilidade da Classe = Exp(Classe) / (Exp(SIM) + Exp(NÃO))
resultado_final AS (
    SELECT
        ROUND((exp_sim / (exp_sim + exp_nao)) * 100, 2) AS chance_invasao_pct,
        ROUND((exp_nao / (exp_sim + exp_nao)) * 100, 2) AS chance_legitimo_pct,
        CASE 
            WHEN (exp_sim / (exp_sim + exp_nao)) > 0.5 THEN '🚨 BLOQUEAR ACESSO (Tentativa de Invasão Detectada)'
            ELSE '✅ AUTORIZAR ACESSO (Login Legítimo)'
        END AS decisao
    FROM probs_nao_normalizadas
)

-- Exibe o resultado final com a porcentagem e a recomendação
SELECT * FROM resultado_final;
