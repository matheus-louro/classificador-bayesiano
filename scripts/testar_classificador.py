import sqlite3
import pandas as pd
import os

# Caminhos dos arquivos
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
db_path = os.path.join(base_dir, 'data', 'classificador.db')
sql_path = os.path.join(base_dir, 'SQL', 'classificador.sql')

# Lendo o script SQL
with open(sql_path, 'r', encoding='utf-8') as file:
    sql_script = file.read()

# Separando as queries (já que temos duas saídas SELECT diferentes no mesmo arquivo)
# Dividimos pelo ponto e vírgula, ignorando espaços vazios no final
queries = [q.strip() for q in sql_script.split(';') if q.strip()]

conn = sqlite3.connect(db_path)

# Executando a primeira query (Classificação dos casos)
print("\n=== RESULTADO DOS TESTES (CLASSIFICAÇÃO) ===")
resultado_casos = pd.read_sql_query(queries[0], conn)
print(resultado_casos.to_string(index=False))

# Executando a segunda query (Análise de Log-Odds)
print("\n\n=== TOP 5 FEATURES COM MAIOR PODER DISCRIMINATIVO (LOG-ODDS) ===")
resultado_log_odds = pd.read_sql_query(queries[1], conn)
print(resultado_log_odds.to_string(index=False))
print("\n")

conn.close()
