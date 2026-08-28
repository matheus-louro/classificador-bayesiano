# Análise Crítica - Classificador Naive Bayes

**Domínio:** Detecção de Login Suspeito

---

### 1. O modelo classificou corretamente conforme sua intuição sobre o domínio?

Sim, atendeu as expectativas. Nos cenários extremos, ele preciso e bloqueou/autorizou conforme o esperado. O mais interessante foi o comportamento nos casos ambíguos. Por exemplo, no caso do acesso de um celular novo em um Wi-Fi público (shopping); em vez de disparar um bloqueio direto como uma regra _if/else_ faria, o algoritmo avaliou as variáveis conhecidas (horário comercial, IP limpo) e liberou o acesso.
Ver a etapa de Mineração de Dados do processo KDD entregando um padrão aplicável e útil depois de termos feito toda a seleção, transformação e geração da massa de dados foi ótimo para fixar e entender melhor todo o processo.

### 2. Quais features tiveram maior log-odds (maior poder discriminativo)?

Observando os pesos e os resultados no banco, ficou claro que as features que mais jogam a probabilidade para invasão são `reputacao_ip = Suspeita`, `falhas_senha = 3 ou mais` e `localizacao = Internacional`. Isso faz sentido pois um usuário comum quase nunca erra a senha tantas vezes ou cai em uma blacklist de IP. Quando o algoritmo esbarra nessas anomalias, o impacto no cálculo do _log-odds_ se sobrepõe facilmente as outras características.

### 3. O que acontece quando você testa um perfil com valores não vistos no treinamento?

Para esse caso, foram criados 2 perfis no SQL: um perfil possuía features desconhecidas misturadas com conhecidas, e o outro perfil só tinha features desconhecidas.

- **Perfil Híbrido:** Devido à suavização de Laplace, mesmo em um perfil com valores não vistos no treinamento, o algoritmo conseguiu tomar uma decisão lógica se baseando nas variáveis que ele reconhecia (como horário e reputação limpa), e acabou autorizando.
- **Perfil Desconhecido:** Já nesse caso extremo, onde 100% dos dados eram inventados, o algoritmo tomou uma atitude curiosa e bloqueou o acesso. Como não havia evidência concreta pra lado nenhum, o cálculo da fórmula, devido ao Laplace, travou em 1. A diferença de peso ficou no denominador, que considerava o tamanho de cada classe. Como temos menos invasões do que logins legítimos no nosso banco, a classe "Invasão" levou vantagem por ter um denominador menor na conta.

### 4. Quais são as limitações do Naive Bayes neste domínio específico?

O principal ponto fraco é a própria premissa do modelo de que as variáveis são completamente independentes (o lado "ingênuo" do algoritmo). Em um ambiente de cibersegurança, as coisas têm muita correlação. Se um atacante está usando uma rede `Proxy_VPN`, existe uma chance enorme de a `Localização` dele saltar para `Internacional`. As duas coisas costumam ser causadas pela mesma ação. O Naive Bayes, porém, não saca essa ligação; ele contabiliza isso como dois problemas separados e acaba punindo artificialmente a probabilidade duas vezes. Olhando pelo ciclo do KDD, talvez numa próxima iteração na fase de transformação, a gente devesse consolidar features muito dependentes, ou simplesmente trocar para outro algoritmo (como Árvore de Decisão) que lide melhor com essas correlações.

---

### Reflexão Crítica

O modelo se saiu bem em lidar com situações ambíguas que são comuns no dia a dia, como o caso do usuário fazendo login de um celular novo em um shopping. Sem contar, é claro, as situações extremas que foram testadas. Vale ressaltar também a maneira interessante que o modelo teve ao tomar decisões lógicas mesmo quando havia valores desconhecidos, graças à suavização de Laplace.

Já a principal falha do modelo, como foi destacada na pergunta 4, é a premissa de que as variáveis são independentes. Talvez, em outro domínio, isso não seja um ponto fraco do modelo, mas para o nosso caso de Cibersegurança e detecção de login suspeito, é algo que deixa a desejar. Pensando no processo KDD, uma etapa mais rigorosa de pré-processamento para unificar features dependentes seria de grande importância para aumentar a precisão do algoritmo.
