# Registro de Prompts - Etapa 2: Geração da massa de dados de treinamento

**Modelo Utilizado:** Gemini 3.1 Pro (High)
**Domínio Escolhido:** Detecção de Login Suspeito (Cibersegurança)

---

## Interação 1 - Geração de Dados
**Prompt do Usuário:**
> Agora para a etapa 2, documente nossa interação em um arquivo prompts_etapa_2.md. As instruções para a etapa 2 são:
> - Conter padrões intencionais e realistas (não aleatórios)
> - Ter distribuição razoável entre as classes — evitar dados completamente desbalanceados
> - Usar apenas as features discretizadas definidas na Etapa 1
> 
> Para essa etapa, crie um script em python em uma pasta scripts para popular um .csv que ficará na pasta data. Você deve gerar utilizando exclusivamente as features definidas e o rótulo alvo. Essa segunda etapa deve ser coerente com tudo que foi definida na etapa 1 (consultar prompts_etapa_1.md em caso de perda de contexto). Gere pelo menos 120 registros

**Resposta da IA:**
> Recebido! Para garantir a coerência e os padrões intencionais, criei um script Python (`scripts/gerador_dados.py`) que utiliza probabilidades definidas para forçar a simulação realista que descrevemos na Etapa 1.
> 
> **Como o script garante as regras da Etapa 2:**
> 1. **Padrões Intencionais:** Se a classe for `NÃO` (Legítimo), o script dá pesos gigantescos para *Localização Habitual*, *Dispositivo Conhecido*, *0 falhas*, etc. Se for `SIM` (Invasão), ele inverte os pesos e força a geração de anomalias (ex: 70% de chance de ser *Internacional*, 90% de ser *Dispositivo Novo*). Isso garante que o Naive Bayes terá padrões matemáticos muito claros para aprender.
> 2. **Distribuição Razoável:** Configurei a chance geral de invasão para ~40% e de acessos legítimos para ~60%. Isso reflete o mundo real (onde a maioria é legítima) sem criar um dataset tão desbalanceado a ponto de atrapalhar o algoritmo.
> 3. **Apenas as features da Etapa 1:** O script utiliza estritamente o nosso dicionário final (incluindo o `tipo_rede` no lugar do uso de VPN).
> 
> O script foi executado e gerou um arquivo com **150 registros** na pasta `data/dados_treinamento.csv`. Além disso, criei este arquivo de documentação para a Etapa 2!
