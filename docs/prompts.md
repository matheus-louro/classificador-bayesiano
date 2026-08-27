# Registro de Prompts - Auxílio de IA

**Modelo Utilizado:** Gemini 3.1 Pro (High)

Este documento registra os prompts e as respostas geradas durante o desenvolvimento da Atividade Prática 1 (Algoritmo Classificador Bayesiano) com o auxílio de Inteligência Artificial.

---

## Interação 1

**Prompt do Usuário:**
> Quero que você leia o PDF presente na pasta docs e entenda o objetivo da atividade. Além disso, crie dentro da pasta docs um arquivo .md para registrar os prompts que estou usando para documentar o auxílio de IA nesta atividade (incluindo esse prompt que estou mandando agora). Após ler e entender as etapas e objetivo de atividade, aguarde os próximos passos.

**Resposta da IA:**
> Li as instruções presentes no arquivo PDF sobre a **Atividade Prática 1 - Algoritmo Classificador Bayesiano**. Entendi que o objetivo é modelar um problema real de classificação binária, gerar dados de treinamento, implementar o classificador usando SQL (com suavização de Laplace e log-probabilidades) e, por fim, testar e analisar o modelo. 
> 
> Também criei o arquivo de registro solicitado em `prompts.md`, já incluindo o prompt que você acabou de me enviar.
> 
> Estou pronto! Pode mandar os próximos passos de qual domínio você quer escolher para começarmos a **Etapa 1**.

---

## Interação 2

**Prompt do Usuário (Versão Web / Contexto):**
> me ajude a escolher um contexto do mundo real para essa atividade que seja relevante e de fácil implementação. Sugira pelo menos 10 contextos que sigam essas exigências e que seja bom para gerar dados coerentes e não aleatórios. Além de sugerir o contexto, justifique a sugestão 

**Resposta da IA (Resumo do Domínio Escolhido):**
> O domínio escolhido foi **Detecção de Login Suspeito (Cibersegurança)**: Prever se um acesso é uma tentativa de invasão (Sim/Não).
> *Justificativa da IA:* Invasões seguem padrões muito lógicos (horário incomum, país de origem do IP, quantidade de falhas anteriores). A IA consegue gerar dados com correlações fortíssimas para o algoritmo aprender.

**Prompt do Usuário (Continuação no ambiente de desenvolvimento):**
> Antes de prosseguirmos na etapa 1, registre esse prompt que utilizei na versão web para escolher o domínio: [inserido acima]
> O domínio escolhido foi Detecção de Login Suspeito, com base nessa resposta de um dos contextos fornecidos pela IA: [inserido acima]

**Resposta da IA:**
> O prompt e o domínio escolhido (**Detecção de Login Suspeito**) foram registrados com sucesso no arquivo `prompts.md`. 
> 
> Excelente escolha de domínio! É um caso de uso clássico onde os dados de características (features) possuem correlações fortes e fáceis de intuir, o que tornará a modelagem bem didática para o Classificador Naive Bayes.
> 
> Para concluirmos a **Etapa 1**, precisamos responder às seguintes perguntas:
> 1. Qual é o **rótulo alvo** (o que será classificado como sim ou não)?
> 2. Quais são as **6 a 8 features** mais relevantes para esse domínio?
> 3. Como cada feature pode ser **discretizada** em categorias significativas?
> 4. Qual é a **lógica intuitiva** por trás dos padrões de risco ou classificação?
> 
> Se quiser, posso já propor essas definições para o domínio de Detecção de Login Suspeito para você validar ou ajustar. Como prefere seguir?

---

## Interação 3
**Prompt do Usuário:**
> Antes de continuar, as suas respostas aos meus prompts também devem ser documentadas, portanto registre as respostas dadas até agora. É interessante também que registre o modelo que esta sendo utilizado

**Resposta da IA:**
> Arquivo atualizado! Adicionei o modelo em uso (Gemini 3.1 Pro (High)) e reestruturei o documento para conter de forma explícita cada prompt fornecido acompanhado da respectiva resposta da IA para garantir o registro completo do nosso diálogo.
