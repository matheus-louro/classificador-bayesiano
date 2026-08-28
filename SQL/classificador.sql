-- =========================================================================
-- ETAPA 3 e 4: Classificador Naive Bayes em SQL Puro (Múltiplos Testes)
-- Domínio: Detecção de Login Suspeito
-- =========================================================================

WITH 
-- 1. ENTRADA DE DADOS: 5 CASOS DE TESTE COM PERFIS DISTINTOS
casos_teste AS (
    -- Caso 1: Usuário Habitual (Baixo Risco) -> Padrão de rotina normal
    SELECT 1 AS caso, 'Baixo Risco (Usuário Habitual)' AS perfil, 
    'Habitual' AS localizacao, 'Conhecido' AS dispositivo, 'Comercial (08h-18h)' AS horario, '0' AS falhas_senha, 'Confiável (Residencial/Corp)' AS tipo_rede, 'Limpa' AS reputacao_ip 
    UNION ALL
    
    -- Caso 2: Atacante Clássico (Alto Risco) -> Padrão óbvio de invasor
    SELECT 2 AS caso, 'Alto Risco (Atacante)' AS perfil, 
    'Internacional' AS localizacao, 'Novo' AS dispositivo, 'Madrugada (23h-08h)' AS horario, '3 ou mais' AS falhas_senha, 'Proxy_VPN' AS tipo_rede, 'Suspeita' AS reputacao_ip 
    UNION ALL
    
    -- Caso 3: Ambíguo (Viagem Nacional) -> Saiu da rotina, mas características são razoáveis
    SELECT 3 AS caso, 'Ambíguo (Viagem Nacional)' AS perfil, 
    'Nova (Nacional)' AS localizacao, 'Conhecido' AS dispositivo, 'Noturno (18h-23h)' AS horario, '1 a 2' AS falhas_senha, 'Móvel (4G/5G)' AS tipo_rede, 'Limpa' AS reputacao_ip 
    UNION ALL
    
    -- Caso 4: Ambíguo (Celular Novo no Shopping) -> Dispositivo novo em rede de risco moderado, mas localização e hora normais
    SELECT 4 AS caso, 'Ambíguo (Celular Novo)' AS perfil, 
    'Habitual' AS localizacao, 'Novo' AS dispositivo, 'Comercial (08h-18h)' AS horario, '0' AS falhas_senha, 'WiFi_Publico' AS tipo_rede, 'Limpa' AS reputacao_ip 
    UNION ALL
    
    -- Caso 5: Força Bruta Local -> Alguém próximo (ou botnet local) tentando adivinhar senha
    SELECT 5 AS caso, 'Ataque Local (Força Bruta)' AS perfil, 
    'Habitual' AS localizacao, 'Conhecido' AS dispositivo, 'Madrugada (23h-08h)' AS horario, '3 ou mais' AS falhas_senha, 'Confiável (Residencial/Corp)' AS tipo_rede, 'Suspeita' AS reputacao_ip
    UNION ALL
    
    -- Caso 6: Teste Laplace -> Contém features completamente malucas/inéditas não presentes na base
    SELECT 6 AS caso, 'Valores Inéditos (Laplace)' AS perfil, 
    'Marte (Espaço)' AS localizacao, 'Geladeira Smart' AS dispositivo, 'Comercial (08h-18h)' AS horario, '0' AS falhas_senha, 'Satélite Starlink' AS tipo_rede, 'Limpa' AS reputacao_ip
    UNION ALL
    
    -- Caso 7: Teste Laplace Extremo -> NENHUMA feature é conhecida no treinamento
    SELECT 7 AS caso, 'Tudo Inédito (Laplace Extremo)' AS perfil, 
    'Narnia' AS localizacao, 'Torradeira' AS dispositivo, 'Hora do Chá' AS horario, '-1' AS falhas_senha, 'Telepatia' AS tipo_rede, 'Desconhecida' AS reputacao_ip
),

-- 2. CONTAGENS GERAIS E POR CLASSE
totais AS (
    SELECT 
        COUNT(*) * 1.0 AS total,
        SUM(CASE WHEN tentativa_invasao = 'SIM' THEN 1 ELSE 0 END) * 1.0 AS total_sim,
        SUM(CASE WHEN tentativa_invasao = 'NÃO' THEN 1 ELSE 0 END) * 1.0 AS total_nao
    FROM tb_treinamento
),

-- 3. CARDINALIDADE DAS FEATURES (Para Laplace)
cardinalidade AS (
    SELECT 
        (SELECT COUNT(DISTINCT localizacao) FROM tb_treinamento) AS k_loc,
        (SELECT COUNT(DISTINCT dispositivo) FROM tb_treinamento) AS k_disp,
        (SELECT COUNT(DISTINCT horario) FROM tb_treinamento) AS k_hor,
        (SELECT COUNT(DISTINCT falhas_senha) FROM tb_treinamento) AS k_falhas,
        (SELECT COUNT(DISTINCT tipo_rede) FROM tb_treinamento) AS k_rede,
        (SELECT COUNT(DISTINCT reputacao_ip) FROM tb_treinamento) AS k_ip
),

-- 4. PROBABILIDADES A PRIORI (Logaritmo)
priori AS (
    SELECT 
        LN(total_sim / total) AS log_prior_sim,
        LN(total_nao / total) AS log_prior_nao
    FROM totais
),

-- 5. CÁLCULO DAS VEROSSIMILHANÇAS POR CASO DE TESTE (Usando subqueries correlacionadas para Laplace)
score_por_caso AS (
    SELECT 
        teste.caso,
        teste.perfil,
        
        -- Somatório dos Logs para a classe SIM
        (SELECT log_prior_sim FROM priori)
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'SIM' AND localizacao = teste.localizacao) + 1.0 ) / ( (SELECT total_sim FROM totais) + (SELECT k_loc FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'SIM' AND dispositivo = teste.dispositivo) + 1.0 ) / ( (SELECT total_sim FROM totais) + (SELECT k_disp FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'SIM' AND horario = teste.horario) + 1.0 ) / ( (SELECT total_sim FROM totais) + (SELECT k_hor FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'SIM' AND falhas_senha = teste.falhas_senha) + 1.0 ) / ( (SELECT total_sim FROM totais) + (SELECT k_falhas FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'SIM' AND tipo_rede = teste.tipo_rede) + 1.0 ) / ( (SELECT total_sim FROM totais) + (SELECT k_rede FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'SIM' AND reputacao_ip = teste.reputacao_ip) + 1.0 ) / ( (SELECT total_sim FROM totais) + (SELECT k_ip FROM cardinalidade) ))
        AS score_sim,

        -- Somatório dos Logs para a classe NÃO
        (SELECT log_prior_nao FROM priori)
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'NÃO' AND localizacao = teste.localizacao) + 1.0 ) / ( (SELECT total_nao FROM totais) + (SELECT k_loc FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'NÃO' AND dispositivo = teste.dispositivo) + 1.0 ) / ( (SELECT total_nao FROM totais) + (SELECT k_disp FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'NÃO' AND horario = teste.horario) + 1.0 ) / ( (SELECT total_nao FROM totais) + (SELECT k_hor FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'NÃO' AND falhas_senha = teste.falhas_senha) + 1.0 ) / ( (SELECT total_nao FROM totais) + (SELECT k_falhas FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'NÃO' AND tipo_rede = teste.tipo_rede) + 1.0 ) / ( (SELECT total_nao FROM totais) + (SELECT k_rede FROM cardinalidade) ))
        + LN(( (SELECT COUNT(*) FROM tb_treinamento WHERE tentativa_invasao = 'NÃO' AND reputacao_ip = teste.reputacao_ip) + 1.0 ) / ( (SELECT total_nao FROM totais) + (SELECT k_ip FROM cardinalidade) ))
        AS score_nao

    FROM casos_teste teste
),

-- 6. REVERTER O LOG (Exponencial) PARA NORMALIZAR
probs_nao_normalizadas AS (
    SELECT 
        caso,
        perfil,
        EXP(score_sim) AS exp_sim,
        EXP(score_nao) AS exp_nao
    FROM score_por_caso
)

-- 7. NORMALIZAÇÃO (0 a 100%) E RECOMENDAÇÃO (Saída Formatada)
SELECT 
    caso AS 'Caso',
    perfil AS 'Perfil de Teste',
    PRINTF('%.2f%%', (exp_sim / (exp_sim + exp_nao)) * 100) AS 'Chance invasao',
    PRINTF('%.2f%%', (exp_nao / (exp_sim + exp_nao)) * 100) AS 'Chance legitimo',
    CASE 
        WHEN (exp_sim / (exp_sim + exp_nao)) > 0.5 THEN 'BLOQUEAR'
        ELSE 'AUTORIZAR'
    END AS 'Decisao'
FROM probs_nao_normalizadas
ORDER BY caso;
