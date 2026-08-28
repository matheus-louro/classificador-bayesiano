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

# Conectando ao banco e executando a query
conn = sqlite3.connect(db_path)
resultado = pd.read_sql_query(sql_script, conn)
conn.close()

# Exibindo o resultado formatado como tabela
print(resultado.to_string(index=False))
