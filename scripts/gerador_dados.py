import csv
import random
import os

# Semente para reprodutibilidade (os mesmos dados sempre que rodar)
random.seed(42)

# Definição das categorias (Features definidas na Etapa 1)
features = {
    'localizacao': ['Habitual', 'Nova (Nacional)', 'Internacional'],
    'dispositivo': ['Conhecido', 'Novo'],
    'horario': ['Comercial (08h-18h)', 'Noturno (18h-23h)', 'Madrugada (23h-08h)'],
    'falhas_senha': ['0', '1 a 2', '3 ou mais'],
    'tipo_rede': ['Confiável (Residencial/Corp)', 'Móvel (4G/5G)', 'WiFi_Publico', 'Proxy_VPN'],
    'reputacao_ip': ['Limpa', 'Suspeita']
}

def generate_record():
    # Balanceamento de classes: ~60% Não (Legítimo), ~40% Sim (Invasão)
    # Mantemos desbalanceado mas em uma proporção razoável para o algoritmo aprender bem ambas.
    is_invasion = random.random() < 0.4
    
    if not is_invasion: # Acesso Legítimo (NÃO) - Padrão de Baixo Risco
        loc = random.choices(features['localizacao'], weights=[0.85, 0.14, 0.01])[0]
        disp = random.choices(features['dispositivo'], weights=[0.90, 0.10])[0]
        hor = random.choices(features['horario'], weights=[0.60, 0.35, 0.05])[0]
        falhas = random.choices(features['falhas_senha'], weights=[0.80, 0.19, 0.01])[0]
        # Legítimos quase nunca usam Proxy/VPN e usam muito rede confiável ou móvel
        rede = random.choices(features['tipo_rede'], weights=[0.60, 0.30, 0.09, 0.01])[0] 
        ip = random.choices(features['reputacao_ip'], weights=[0.99, 0.01])[0]
        target = 'NÃO'
        
    else: # Tentativa de Invasão (SIM) - Padrão de Alto Risco
        # Invasores frequentemente vêm do exterior, usam dispositivos novos, operam na madrugada, 
        # erram muito a senha, usam proxies e IPs que já estão em blacklists.
        loc = random.choices(features['localizacao'], weights=[0.05, 0.25, 0.70])[0]
        disp = random.choices(features['dispositivo'], weights=[0.10, 0.90])[0]
        hor = random.choices(features['horario'], weights=[0.15, 0.25, 0.60])[0]
        falhas = random.choices(features['falhas_senha'], weights=[0.10, 0.30, 0.60])[0]
        rede = random.choices(features['tipo_rede'], weights=[0.05, 0.15, 0.30, 0.50])[0]
        ip = random.choices(features['reputacao_ip'], weights=[0.30, 0.70])[0]
        target = 'SIM'
        
    return [loc, disp, hor, falhas, rede, ip, target]

# Cabeçalho do CSV
data = [
    ['localizacao', 'dispositivo', 'horario', 'falhas_senha', 'tipo_rede', 'reputacao_ip', 'tentativa_invasao']
]

# Gerar 150 registros
for _ in range(150):
    data.append(generate_record())

# Obter o caminho absoluto relativo ao local deste script
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
data_dir = os.path.join(base_dir, 'data')

# Criar a pasta data se não existir
os.makedirs(data_dir, exist_ok=True)
csv_path = os.path.join(data_dir, 'dados_treinamento.csv')

# Escrever o CSV
with open(csv_path, mode='w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerows(data)

print(f"Sucesso! Gerados {len(data)-1} registros de treinamento no arquivo:")
print(csv_path)
