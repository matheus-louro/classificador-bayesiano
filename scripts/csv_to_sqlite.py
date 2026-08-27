import sqlite3
import csv
import os

base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
csv_path = os.path.join(base_dir, 'data', 'dados_treinamento.csv')
db_path = os.path.join(base_dir, 'data', 'classificador.db')

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

with open(csv_path, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    columns = next(reader)
    
    # Criar a tabela (todas as colunas como TEXT pois nossos dados são categóricos)
    cols_def = ", ".join([f"{col} TEXT" for col in columns])
    cursor.execute(f"DROP TABLE IF EXISTS tb_treinamento")
    cursor.execute(f"CREATE TABLE tb_treinamento ({cols_def})")
    
    # Inserir os dados
    placeholders = ", ".join(["?"] * len(columns))
    insert_sql = f"INSERT INTO tb_treinamento VALUES ({placeholders})"
    
    for row in reader:
        cursor.execute(insert_sql, row)

conn.commit()
conn.close()

print(f"Banco de dados SQLite gerado com sucesso em: {db_path}")
