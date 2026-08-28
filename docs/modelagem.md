# Relatório de Modelagem - Classificador Naive Bayes
**Disciplina:** Mineração de Dados
**Domínio Escolhido:** Detecção de Login Suspeito (Cibersegurança)

---

## 1. Descrição do Problema e Rótulo Alvo
O domínio escolhido trata da segurança de contas de usuários em plataformas digitais. O objetivo do classificador é prever se um acesso é feito pelo usuário real ou se é uma tentativa de invasão (hacker/bot), configurando uma decisão binária (Sim/Não).

**Rótulo Alvo (Target):** `tentativa_invasao`
*   **SIM (1):** Representa um login que destoa do comportamento habitual e seguro. Há indícios de que é um ataque, resultando na recomendação de BLOQUEAR o acesso.
*   **NÃO (0):** Representa um acesso legítimo e seguro, que condiz com a rotina do dono da conta. O sistema deve AUTORIZAR a entrada.

---

## 2. Features e Discretização (Categorias)
Para realizar a classificação, definimos 6 características (features) altamente relevantes na área de cibersegurança. Todas foram discretizadas em categorias fixas para permitir o cálculo de probabilidades condicinais do Naive Bayes.

**1. `localizacao` (Localização Geográfica)**
*   **Categorias:** `Habitual`, `Nova (Nacional)`, `Internacional`.
*   **Justificativa:** A esmagadora maioria dos usuários acessa suas contas das mesmas cidades de sempre. Um login internacional súbito é um dos maiores indícios de invasão ou uso de proxys em outros países.

**2. `dispositivo` (Dispositivo/Navegador)**
*   **Categorias:** `Conhecido`, `Novo`.
*   **Justificativa:** O roubo de credenciais (login e senha vazados) geralmente ocorre sem o roubo do celular/PC físico. Tentativas de acesso através de um aparelho que o sistema nunca viu geram forte desconfiança.

**3. `horario` (Horário de Acesso)**
*   **Categorias:** `Comercial (08h-18h)`, `Noturno (18h-23h)`, `Madrugada (23h-08h)`.
*   **Justificativa:** Atacantes baseados em outros fusos horários ou scripts automatizados (bots) costumam operar durante a madrugada da vítima. Essa divisão penaliza acessos em horários onde o usuário tipicamente estaria inativo.

**4. `falhas_senha` (Tentativas de Falhas Anteriores)**
*   **Categorias:** `0`, `1 a 2`, `3 ou mais`.
*   **Justificativa:** Errar a senha 1 ou 2 vezes é um erro humano comum (digitação errada). No entanto, 3 ou mais falhas seguidas antes do sucesso são o rastro clássico de uma possível tentativa de ataque de "força bruta".

**5. `tipo_rede` (Tipo de Rede/Conexão)**
*   **Categorias:** `Confiável (Residencial/Corp)`, `Móvel (4G/5G)`, `WiFi_Publico`, `Proxy_VPN`.
*   **Justificativa:** Redes corporativas e residenciais (prévias) são muito seguras e estáveis. Redes móveis mudam de IP constantemente, mas de forma natural. Wi-Fi público traz riscos de interceptação. O uso de Proxy e VPNs é amplamente empregado por cibercriminosos para mascarar sua verdadeira origem.

**6. `reputacao_ip` (Reputação da Rede/IP)**
*   **Categorias:** `Limpa`, `Suspeita`.
*   **Justificativa:** Baseado em listas de bloqueios corporativas (blacklists). Se o IP do login possui histórico recente em envio de spam ou hospedagem de botnets (`Suspeita`), o alerta deve ser imediato, independentemente da senha correta.

---

## 3. Lógica Intuitiva
A lógica do classificador Bayesiano para este domínio é baseada na **acumulação de evidências**. 

*   **Padrões Normais:** Um único indício suspeito (ex: acessar de um dispositivo novo) raramente deve causar um bloqueio, afinal o usuário pode apenas ter trocado de celular. O modelo balanceia essa novidade com as demais features benignas (IP Limpo, Zero Falhas, Horário Comercial) e aprova o acesso.
*   **Padrões de Risco:** Quando múltiplas variáveis saem da normalidade simultaneamente (ex: Dispositivo Novo + Madrugada + Proxy/VPN + Múltiplas Falhas), o multiplicador do risco de fraude cresce exponencialmente. O algoritmo condensa essas anomalias e barra a tentativa, replicando a lógica de um time real de cibersegurança.
