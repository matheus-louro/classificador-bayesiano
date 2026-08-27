# Registro de Prompts - Etapa 3: Implementação do Classificador Naive Bayes

**Modelo Utilizado:** Gemini 3.1 Pro (High)
**Domínio Escolhido:** Detecção de Login Suspeito (Cibersegurança)

---

## Interação 1 - Conversão SQLite e Implementação em SQL

**Prompt do Usuário:**
> A partir de agora documente as interações em prompts_etapa_3.md. Nessa etapa, implementaremos o Classificador Naive Bayes em SQL. O algoritmo deve conter obrigatoriamente os seguintes requisitos: 
> • Cálculo das probabilidades a priori P(classe)
> • Cálculo das verossimilhanças P(feature = valor | classe) com suavização de Laplace
> • Classificação usando log-probabilidades — para evitar underflow numérico
> • Normalização do score final em probabilidade entre 0 % e 100 %
> • Saída com a probabilidade de cada classe e uma recomendação de decisão
> 
> Como o algoritmo será em SQL, precisamos pegar nossa base de dados de treinamento gerada em .csv para um .db, dessa forma podemos utilizar SQLite3 para implementação e execução do algoritmo. Primeiro converta a base de dados para um .db e depois implemente o algoritmo em SQL, colocando o script em uma pasta chamada SQL

**Resposta da IA:**
> Passos seguidos e concluídos com sucesso:
> 
> 1. **Conversão de CSV para .db:** Criei um script Python (`scripts/csv_to_sqlite.py`) que leu o nosso `dados_treinamento.csv` e criou automaticamente a tabela `tb_treinamento` dentro do banco de dados `data/classificador.db`.
> 2. **Implementação do SQL:** Criei o script `SQL/classificador.sql` com toda a lógica exigida. O código foi construído de forma limpa e modular através de *Common Table Expressions* (CTEs). 
> 
> **Como os requisitos foram atendidos no código SQL:**
> *   **Probabilidade a priori P(classe):** Feita através da contagem do total da classe SIM/NÃO dividido pelo total de linhas, e inserida na função `LN()` (Logaritmo Natural).
> *   **Suavização de Laplace:** Utilizei a fórmula exata `(Contagem_Feature + 1) / (Total_Classe + Qtd_Categorias_Possíveis)`. Calculei a Qtd de Categorias de forma dinâmica com `COUNT(DISTINCT ...)`.
> *   **Log-probabilidades:** Todo o cálculo de verossimilhança é repassado para dentro da função `LN()`. Em vez de multiplicar as frações (que causam underflow até zerar as decimais), eu simulei a multiplicação fazendo a **soma** dos logaritmos (`log_loc_sim + log_disp_sim + ...`).
> *   **Normalização (0 a 100%):** O SQL aplica a função `EXP()` (exponencial) para reverter o logaritmo, pegando a pontuação bruta, e então faz `EXP(SIM) / (EXP(SIM) + EXP(NAO)) * 100`.
> *   **Saída com Probabilidade e Recomendação:** O `SELECT` final devolve exatamente duas porcentagens (Chances de Invasão e Legítimo) e uma mensagem `CASE WHEN ... THEN ...` recomendando BLOQUEAR ou AUTORIZAR o acesso.
> 
> Tudo pronto! O arquivo de testes está no jeito.
