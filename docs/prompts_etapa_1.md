# Registro de Prompts - Etapa 1: Escolha do domínio e modelagem do problema

**Modelo Utilizado:** Gemini 3.1 Pro (High)
**Domínio Escolhido:** Detecção de Login Suspeito (Cibersegurança)

---

## Interação 1 - Rótulo Alvo

**Prompt do Usuário:**

> Agora vamos começar de fato a etapa 1. Para isso, crie um novo arquivo prompts_etapa_1.md para registrar as interações referentes a etapa 1 (incluindo esse prompt). Para cada pergunta
>
> 1. Qual é o rótulo alvo (o que será classificado como sim ou não)?
> 2. Quais são as 6 a 8 features mais relevantes para esse domínio?
> 3. Como cada feature pode ser discretizada em categorias significativas?
> 4. Qual é a lógica intuitiva por trás dos padrões de risco ou classificação?
>
> Eu irei fazer um prompt. Começando pela primeira
>
> 1. Qual é o rótulo alvo (o que será classificado como sim ou não)?
>    Explique o que será classificado como Sim ou Não e o significado dentro do domínio escolhido de Detecção de login suspeito

**Resposta da IA:**

> Para o domínio de **Detecção de Login Suspeito**, o rótulo alvo (nossa variável alvo que queremos prever) será **"Tentativa de Invasão"** (ou simplesmente "Login Suspeito").
>
> Como trata-se de uma classificação binária, teremos:
>
> - **SIM (ou 1):** Representa um login que destoa do comportamento habitual e seguro. Neste cenário, o classificador identificou padrões de risco, indicando que o acesso é provavelmente realizado por um atacante, um bot ou alguém não autorizado. A ação tomada pelo sistema seria bloquear o acesso ou exigir um segundo fator de autenticação (MFA).
> - **NÃO (ou 0):** Representa um login considerado legítimo e seguro. Os padrões apresentados batem com o histórico normal do dono da conta (ex: mesmo dispositivo, localização comum, horário comercial, senha acertada de primeira). O sistema simplesmente autoriza a entrada sem atritos.

---

## Interação 2 - Features Relevantes

**Prompt do Usuário:**

> a próxima pergunta é: 2. Quais são as 6 a 8 features mais relevantes para esse domínio?
> Escolha de 6 a 8 features que sejam relevantes, didáticas e coerentes com o domínio escolhido. As features escolhidas devem ser pensadas para gerar dados coerentes posteriormente na atividade

**Resposta da IA:**

> Para identificar uma tentativa de invasão, escolhi **6 features** que são as mais clássicas na área de segurança, muito didáticas para entender como a probabilidade se acumula, e perfeitas para gerar dados coerentes depois:
>
> 1. **`localizacao` (Localização Geográfica):** Avalia de onde o acesso está partindo em relação ao histórico do usuário. Invasores frequentemente usam IPs de outros países ou regiões não usuais.
> 2. **`dispositivo` (Dispositivo/Navegador):** Verifica se o login está sendo feito de um aparelho (celular/computador) já conhecido e registrado na conta ou de um aparelho totalmente novo.
> 3. **`horario` (Horário do Acesso):** Avalia se o horário do login faz sentido com a rotina da pessoa (ex: horário comercial vs. madrugada).
> 4. **`falhas_senha` (Tentativas de Falha Anteriores):** Analisa quantas vezes a senha foi digitada incorretamente antes do sucesso. Robôs (força bruta) ou pessoas tentando adivinhar senhas costumam errar várias vezes.
> 5. **`uso_vpn` (Uso de VPN ou Proxy):** Verifica se o tráfego está vindo de uma rede anonimizadora, tática muito comum usada por atacantes para esconder sua localização real.
> 6. **`reputacao_ip` (Reputação da Rede/IP):** Avalia se o IP de origem já está em alguma "lista de bloqueio" (blacklist) de segurança por atividades suspeitas anteriores (ex: IP de um botnet conhecido).

---

## Interação 2.1 - Ajuste de Feature

**Prompt do Usuário:**

> No lugar de uso_vpn use algo como tipo de rede/conexão, que pode englobar Rede Corporativa/Residencial Salva, Rede Móvel (4G/5G), Wi-Fi Público ou Proxy/VPN. Acho que fica mais interessante dessa forma e abrange ao mesmo tempo a questão da vpn

**Resposta da IA:**

> Excelente sugestão! O tipo de rede enriquece muito a análise, pois Wi-Fi público, por exemplo, tem um risco diferente de uma VPN.
>
> Sendo assim, substituímos a 5ª feature:
>
> 5. **`tipo_rede` (Tipo de Rede/Conexão):** Avalia a natureza da rede utilizada no acesso. Redes corporativas ou residenciais previamente salvas são muito seguras; redes móveis (4G/5G) são comuns; Wi-Fi público traz um risco moderado (frequentemente usado em ataques de interceptação); e Proxy/VPN acendem um alerta maior por ocultarem a origem.

---

## Interação 3 - Discretização das Features

**Prompt do Usuário:**

> Pode responder à pergunta 3 agora "Como cada feature pode ser discretizada em categorias significativas?"
> Para cada feature, explique a escolha de cada categoria e porque você considera ela significativa para o problema

**Resposta da IA:**

> A discretização (transformar dados contínuos/variados em categorias fixas) é essencial para o algoritmo Naive Bayes. Aqui está a categorização de cada feature e o motivo das escolhas:
>
> **1. `localizacao` (Localização Geográfica)**
>
> - **Categorias:** `Habitual`, `Nova (Nacional)`, `Internacional`.
> - **Por que é significativa:** A maioria dos usuários acessa suas contas da mesma cidade/estado. Uma localização nova no mesmo país gera um risco leve (viagem). Já um login internacional súbito é um dos maiores e mais clássicos indícios de invasão.
>
> **2. `dispositivo` (Dispositivo/Navegador)**
>
> - **Categorias:** `Conhecido`, `Novo`.
> - **Por que é significativa:** O roubo de credenciais (login e senha) geralmente ocorre sem o roubo do dispositivo físico. Se a tentativa vem de um celular ou computador que o sistema nunca viu, a probabilidade de ser um invasor salta drasticamente.
>
> **3. `horario` (Horário de Acesso)**
>
> - **Categorias:** `Comercial (08h-18h)`, `Noturno (18h-23h)`, `Madrugada (23h-08h)`.
> - **Por que é significativa:** Atacantes de outros fusos horários ou scripts automatizados (bots) costumam operar durante a madrugada da vítima. Separar o dia em blocos lógicos ajuda o algoritmo a penalizar acessos em horários onde o usuário estaria tipicamente dormindo.
>
> **4. `falhas_senha` (Tentativas de Falhas Anteriores)**
>
> - **Categorias:** `0`, `1 a 2`, `3 ou mais`.
> - **Por que é significativa:** Errar a senha 1 ou 2 vezes é um erro humano muito comum (caps lock ativado, esqueceu a senha recente). No entanto, 3 ou mais falhas seguidas indicam uma possível tentativa de adivinhação manual ou um ataque de "força bruta".
>
> **5. `tipo_rede` (Tipo de Rede)**
>
> - **Categorias:** `Confiável (Residencial/Corp)`, `Móvel (4G/5G)`, `WiFi_Publico`, `Proxy_VPN`.
> - **Por que é significativa:** Como discutimos, IPs corporativos e residenciais são estáveis e rastreáveis. Redes móveis mudam de IP, mas são seguras. Wi-Fi público tem risco de interceptação. Por fim, Proxies e VPNs são ativamente usados por cibercriminosos para ocultar rastros.
>
> **6. `reputacao_ip` (Reputação da Rede/IP)**
>
> - **Categorias:** `Limpa`, `Suspeita`.
> - **Por que é significativa:** Empresas de cibersegurança mantêm listas de IPs conhecidos por enviar spam, hospedar malware ou fazer ataques de força bruta. Se o IP do login está sujo (`Suspeita`), as chances de ser um ataque são gigantescas, mesmo que o invasor tenha a senha correta.

---

## Interação 4 - Lógica Intuitiva

**Prompt do Usuário:**

> Prossiga para a pergunta 4, lembrando sempre de justificar em detalhes suas respostas de maneira didática para que eu entenda perfeitamente a aplicação do algoritmo no contexto

**Resposta da IA:**

> A lógica intuitiva por trás do Classificador Naive Bayes é a **acumulação de evidências**. O algoritmo assume (de forma "ingênua", daí o nome _Naive_) que cada característica contribui de forma independente para a probabilidade final de um evento ocorrer.
>
> No nosso contexto de **Detecção de Login Suspeito**, uma feature isolada raramente é motivo para bloquear um usuário, mas a combinação delas pinta um quadro probabilístico muito claro. Veja a lógica por trás de três padrões de risco distintos:
>
> **1. Padrão de Baixo Risco (O Usuário Comum):**
>
> - _Cenário:_ Localização `Habitual`, Dispositivo `Conhecido`, Horário `Comercial`, `0` falhas de senha, Rede `Confiável`, IP com Reputação `Limpa`.
> - _Lógica Intuitiva:_ Todas as "pistas" apontam para a rotina perfeitamente normal do dono da conta. Historicamente (nos nossos dados de treinamento), a imensa maioria das vezes em que esse padrão ocorre, trata-se de um login seguro. O algoritmo multiplica essas altas probabilidades a favor da classe "NÃO" (Não é invasão) e o sistema libera o login instantaneamente.
>
> **2. Padrão de Alto Risco (O Atacante Clássico):**
>
> - _Cenário:_ Localização `Internacional`, Dispositivo `Novo`, Horário `Madrugada`, `3 ou mais` falhas de senha, Rede `Proxy_VPN`, IP com Reputação `Suspeita`.
> - _Lógica Intuitiva:_ Aqui temos uma "tempestade perfeita" de anomalias. Alguém de outro país, escondendo seu rastro (VPN) em um IP já sujo no mercado, tentando adivinhar senhas repetidas vezes de madrugada, em um aparelho que nunca vimos. Cada uma dessas variáveis, matematicamente, possui uma forte correlação histórica com a classe "SIM" (Tentativa de Invasão). Ao multiplicar o peso dessas evidências suspeitas, a probabilidade de ser fraude dispara para perto de 99%, acionando o bloqueio.
>
> **3. Padrão Ambíguo (A Área Cinzenta - Onde o Algoritmo Brilha):**
>
> - _Cenário:_ Localização `Habitual`, Dispositivo `Novo`, Horário `Comercial`, `0` falhas, Rede `WiFi_Publico`, IP `Limpo`.
> - _Lógica Intuitiva:_ É aqui que regras rígidas tradicionais (ex: _SE dispositivo novo ENTÃO bloqueia_) falham e incomodam o usuário. A pessoa pode simplesmente ter comprado um celular novo e conectado no Wi-Fi do shopping durante a tarde. O Naive Bayes vai colocar isso na balança: a feature "Dispositivo Novo" e "WiFi_Publico" puxam o risco um pouco para cima, mas as features "Localização Habitual", "Horário Comercial", "0 falhas" e "IP Limpo" puxam o risco fortemente para baixo. O peso das evidências benignas supera as suspeitas, e o sistema entende que é mais provável ser o usuário legítimo de celular novo do que um ataque direcionado.
>
> Essa é a beleza do Teorema de Bayes aplicado a problemas reais: ele toma decisões baseadas em uma **balança de probabilidades** construída a partir da frequência histórica dos dados, simulando a intuição de um analista de segurança experiente.
