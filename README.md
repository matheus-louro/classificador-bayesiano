# Algoritmo Classificador Bayesiano em SQL 🛡️

Este projeto é uma implementação de um **Classificador Naive Bayes** feito em **SQL Puro**, desenvolvido como Atividade Prática para a disciplina de Mineração de Dados.

O objetivo do modelo é atuar em um cenário real de Cibersegurança: prever e detectar se uma tentativa de login é legítima ou se é um ataque de invasão (força bruta, roubo de credencial, etc.), baseando-se no histórico de comportamento e em padrões de segurança (Localização, Horário, Dispositivo, Uso de VPN e Falhas de senha).

## 🗂️ Estrutura do Repositório

* **`docs/`**: Contém toda a documentação passo-a-passo da modelagem (`prompts_etapa_X.md`), e o documento de Reflexão e Análise Crítica do classificador (`analise.md`).
* **`data/`**: Contém a nossa base de dados de treinamento com padrões probabilísticos intencionais (`dados_treinamento.csv`) e o próprio banco de dados SQLite utilizado pelo algoritmo (`classificador.db`).
* **`SQL/`**: Hospeda o "coração" do projeto. O arquivo `classificador.sql` contém toda a matemática do Teorema de Bayes implementada exclusivamente em SQL (incluindo cálculo a priori, Suavização de Laplace e log-probabilidades para evitar underflow).
* **`scripts/`**: Código-fonte secundário em Python usado para gerar e popular os dados de forma realista e automatizar o teste do banco.

## 🚀 Como Executar e Testar

Como os dados de treinamento e o banco SQLite já estão estruturados no repositório, você não precisa configurar servidores de banco de dados nem gerar as informações do zero. 

O arquivo SQL possui uma entrada parametrizada (através de tabelas temporárias *CTE*) avaliando **7 casos de teste simultâneos** de uma vez só (testando desde padrões normais e perfis ambíguos até casos extremos utilizando features não vistas no treinamento).

Para executar o classificador e ver a saída como uma tabela, basta possuir o Python com a biblioteca **Pandas** e executar o script de teste na raiz do repositório:

```bash
# Se não possuir o pandas: pip install pandas
python scripts/testar_classificador.py
```
