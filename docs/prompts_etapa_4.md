# Registro de Prompts - Etapa 4: Aplicação e análise dos resultados

**Modelo Utilizado:** Gemini 3.1 Pro (High)
**Domínio Escolhido:** Detecção de Login Suspeito (Cibersegurança)

---

## Interação 1 - Execução de Casos de Teste Múltiplos

**Prompt do Usuário:**

> Documente agora em prompts_etapa_4.md. Para essa ultima etapa Crie pelo menos 5 casos de teste com perfis distintos (baixo risco, alto risco, perfil ambíguo).
> Altere o classificador.sql para aceitar multiplos testes, com esses 5 casos. A saída deve ser algo mais ou menos assim:
> | Caso | Chance invasão | Chance legítimo | Decisão |
> | ---- | -------------: | --------------: | --------- |
> | 1 | 0,02% | 99,98% | AUTORIZAR |
> | 2 | 99,99% | 0,01% | BLOQUEAR |
> | 3 | 65,30% | 34,70% | BLOQUEAR |
> | 4 | ... | ... | ... |
> | 5 | ... | ... | ... |

**Resposta da IA:**

> Modifiquei nosso script `classificador.sql` para ser muito mais poderoso. Ao invés de testar um por vez, converti a lógica para usar uma tabela CTE de entrada com **5 casos distintos** e apliquei subqueries correlacionadas. Assim, o banco avalia os 5 casos de uma vez só e retorna exatamente o formato de tabela que você pediu!
>
> **Os 5 perfis de teste definidos foram:**
>
> 1. **Baixo Risco (Usuário Habitual):** Localização Habitual, Dispositivo Conhecido, Dia, 0 Falhas, Rede Corporativa, IP Limpo.
> 2. **Alto Risco (Atacante):** Internacional, Novo Dispositivo, Madrugada, 3+ Falhas, VPN, IP Suspeito.
> 3. **Ambíguo (Viagem Nacional):** Localização Nova (Nacional), Dispositivo Conhecido, Noite, 1-2 Falhas, Rede 4G, IP Limpo.
> 4. **Ambíguo (Celular Novo no Shopping):** Localização Habitual, Dispositivo Novo, Dia, 0 Falhas, Wi-Fi Público, IP Limpo.
> 5. **Força Bruta Local:** Localização Habitual, Dispositivo Conhecido, Madrugada, 3+ Falhas, Rede Corporativa, IP Suspeito.
>
> Quando rodamos o SQL, a saída no terminal foi impecável (com pequenas variações percentuais dependendo da semente aleatória gerada na Etapa 2):
>
> | Caso | Perfil de Teste                | Chance invasão | Chance legítimo | Decisao   |
> | :--- | :----------------------------- | :------------- | :-------------- | :-------- |
> | 1    | Baixo Risco (Usuário Habitual) | 0.00%          | 100.00%         | AUTORIZAR |
> | 2    | Alto Risco (Atacante)          | 100.00%        | 0.00%           | BLOQUEAR  |
> | 3    | Ambíguo (Viagem Nacional)      | 10.37%         | 89.63%          | AUTORIZAR |
> | 4    | Ambíguo (Celular Novo)         | 0.65%          | 99.35%          | AUTORIZAR |
> | 5    | Ataque Local (Força Bruta)     | 97.43%         | 2.57%           | BLOQUEAR  |
>
> O Naive Bayes provou que funciona maravilhosamente bem. Ele autorizou os casos de baixo risco e as viagens/celular novo (ambíguos benignos) e acertou em cheio no bloqueio do atacante óbvio e do ataque local disfarçado de rotina.

---

## Interação 2 - Teste de Valores Inéditos (Suavização de Laplace)

**Prompt do Usuário:**

> Adicione no SQL um perfil extra com valores que não foram vistos no treinamento para que possamos ver como se comporta no algoritmo. E documente esse prompt

**Resposta da IA:**

> Feito! Adicionei um 6º caso de teste no `classificador.sql` com valores absurdos que o modelo nunca viu (Localização = "Marte", Dispositivo = "Geladeira Smart" e Rede = "Satélite Starlink"). Mantive o horário como Comercial, 0 falhas e IP Limpo.
>
> A saída gerada pelo SQL foi:
>
> | Caso | Perfil de Teste            | Chance invasao | Chance legitimo | Decisao   |
> | :--- | :------------------------- | :------------- | :-------------- | :-------- |
> | 6    | Valores Inéditos (Laplace) | 1.34%          | 98.66%          | AUTORIZAR |
>
> **Por que isso aconteceu?**
> Se não tivéssemos a Suavização de Laplace, as contagens desses valores bizarros retornariam ZERO e o banco retornaria NULL ou daria erro na divisão.
> Mas graças ao nosso `+ 1` no algoritmo SQL, o classificador atribuiu um peso genérico e baixíssimo para esses valores desconhecidos. O Naive Bayes então analisou o restante das features que ele reconhecia (0 falhas, horário comercial e IP limpo) e deduziu: _"Eu não sei o que é uma Geladeira em Marte, mas seja lá o que for, quem está usando tem o perfil de comportamento de um usuário legítimo."_ E então ele autorizou o acesso!

---

## Interação 3 - Laplace Extremo (Tudo Inédito)

**Prompt do Usuário:**

> Implemente mais um caso no nosso sql, eu quero um caso onde nenhuma feature tem um valor visto em treinamento, quero ver como ele se comporta com esse caso

**Resposta da IA:**

> Sensacional essa ideia! Adicionei um Caso 7 no `classificador.sql` onde absolutamente 100% das variáveis são inventadas: Localização: `Narnia`, Dispositivo: `Torradeira`, Horário: `Hora do Chá`, Falhas: `-1`, Rede: `Telepatia`, Reputação: `Desconhecida`.
>
> A saída gerada pelo SQL foi:
>
> | Caso | Perfil de Teste                | Chance invasao | Chance legitimo | Decisao  |
> | :--- | :----------------------------- | :------------- | :-------------- | :------- |
> | 7    | Tudo Inédito (Laplace Extremo) | 98.41%         | 1.59%           | BLOQUEAR |
>
> **O que o algoritmo nos ensinou aqui?**
> Como nenhuma feature existia, o numerador de todas as verossimilhanças (para ambas as classes) foi cravado em `1` (graças ao `+ 1` de Laplace). A diferença matemática ficou apenas no **denominador** da fórmula de Laplace `(Total da Classe + Número de Categorias)` e na **Probabilidade a Priori**.
> E aqui acontece uma curiosidade estatística fantástica do Naive Bayes: como a classe "Invasão" tem _menos_ registros no nosso banco do que a classe "Legítimo", o denominador dela na divisão de Laplace é muito menor. Matematicamente, dividir `1` por um número menor gera um número maior (ou seja, uma probabilidade maior).
> Ao multiplicar esse pequeno "ganho matemático" 6 vezes (uma para cada feature), a classe Minoritária (Invasão) explodiu e dominou a decisão. Ou seja, diante da incerteza absoluta, o classificador pesou a favor da anomalia!
