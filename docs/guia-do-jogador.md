# Guia do jogador — Ipiranga Roleplay (MTA:SA)

**Atualização:** 2026-05-03  
**Público:** jogadores (nível usuário), não admins.  
**Nota importante:** grande parte das **facções legais e organizações** (nomes, postos de *duty*, salários de patente) vive na **base de dados** (`factions`, membros, etc.). O que vês no jogo (painel **Organizações** no F1) é a fonte “oficial” no teu servidor. Este guia explica o **tipo de conteúdo** que o gamemode oferece e aponta **mapas físicos** extraídos dos ficheiros `.map` do projeto.

Para o motor do servidor (arranque, recursos, rede), vê [resumo-tecnico-servidor.md](resumo-tecnico-servidor.md).

---

## 1. Primeiros passos

1. **Conta e personagem** — após entrar no servidor, regista/login na UI de contas (`oAccount`). Crias ou escolhes um **personagem** (nome IC, idade, aparência, etc.).
2. **Painel F1 (`oDashboard`)** — páginas típicas:
   - **Visão geral** — stats do personagem (trabalho, organização, dinheiro, tempo até pagamento…).
   - **Patrimônio** — dinheiro na mão, banco (quando aplicável), moedas de casino, etc.
   - **Organizações** — facções das quais és membro; convites/ranks dependem da configuração do servidor.
   - **Configurações** — gráficos, personagem, mira, nametag, dicas.
3. **Telemóvel (`oPhone`)** — contactos, apps e funções sociais IC (SMS, chamadas, etc., conforme o que o servidor tiver ativo).
4. **Radar / mapa** — usa o mapa do MTA/GTA para te orientares; coordenadas abaixo seguem o eixo **X, Y, Z** do mundo San Andreas.

---

## 2. Como “funciona a vida” no jogo (loop de RP)

| Sistema | O que representa para ti |
|--------|---------------------------|
| **Dinheiro e banco (`oBank`, lojas)** | Ganhaste com trabalho, facção, vendas ou multas; retiras/depositas em ATMs/banco conforme scripts do servidor. |
| **Payday (`oPayday`)** | Ciclo periódico de salário/impostos; o dashboard mostra **tempo até o pagamento**. |
| **Fome / sede / vida (`oHud`, `oBoneDamage`)** | Necessidades e combate com consequências; trata disso com comida, hospital, RP. |
| **Morte / hospital (`oDeath`)** | Ao morreres, o fluxo de revive/hospital depende das regras do servidor (EMS, hospital no mapa custom). |
| **Inventário (`oInventory`)** | Itens, peso, armações, objectos de trabalho; interage com lojas, mercado, facções. |
| **Veículos (`oVehicle`)** | Chaves, motor, combustível (`oFuel` / Tesla `oTeslaCharger`), danos; compra/aluguer em concessionárias e mapas relacionados (`oCarshop`, tuning `oTuning`). |
| **Imóveis (`oInteriors`)** | Casas/interiores com dono; aluguer, porta, marcadores — vê anúncios IC ou comandos/UI do recurso. |
| **Mercado jogador (`oMarket`)** | Venda/compra entre jogadores. |
| **Multas (`oTicket`, radares `oTraffipax`)** | Infrações de trânsito ou outras aplicadas IC (polícia). |
| **Licenças (`oLicenses`)** | Carta de condução, porte, documentos RP; frequentemente exigidas para empregos legais ou armas.

Tudo isto deve ser jogado **in-character**: o relatório técnico e o cheat não são assunto deste guia.

---

## 3. Organizações e facções

### 3.1 O que são facções?

No painel **Organizações** do F1 (tecla) aparece a tua ligação a uma ou mais **facções**. Cada facção tem:

- **Nome e tipo** — determina a cor do uniforme/HUD e o tipo de *duty* disponível.
- **Patentes (ranks)** — cada patente tem um salário IC. Sobe de patente conforme regras IC da própria organização.
- **Serviço (duty)** — quando entras em serviço (comando `/duty` ou marcador no HQ), recebes equipamento autorizado e passas a ser contado como membro ativo para sistemas de território e procurados.

### 3.2 Facções ativas no servidor

O servidor Ipiranga Roleplay tem **10 facções reais** baseadas em organizações de São Paulo:

#### Segurança (cor azul)

| ID | Organização | Patentes (menor → maior) |
|----|------------|--------------------------|
| 74 | **PMESP** — Polícia Militar do Estado de São Paulo | Soldado PM → Cabo → Sargento (3°/2°/1°) → Subtenente → Tenente (2°/1°) → Capitão → Major → Ten.-Coronel → **Coronel PM** |
| 80 | **PCSP** — Polícia Civil do Estado de São Paulo | Investigador → Escrivão → Delegado Substituto → Delegado → Delegado Seccional → **Delegado Geral** |

A PMESP faz policiamento ostensivo (patrulha, blitz, confronto). A PCSP faz investigação, perícia e flagrante. Ambas têm acesso ao **MDC** (computador policial em veículo policial).

#### Saúde (cor vermelha)

| ID | Organização | Patentes (menor → maior) |
|----|------------|--------------------------|
| 75 | **SAMU 192** — Serviço de Atendimento Móvel de Urgência | Técnico de Emergência → Aux. Regulação Médica → Enfermeiro Socorrista → Médico Regulador → Médico Socorrista → **Coordenador SAMU** |
| 81 | **Corpo de Bombeiros Militar do Estado de SP** | Soldado BM → Cabo BM → Sargento (3°/2°/1°) → Subtenente BM → Tenente (2°/1°) → Capitão BM → **Major BM** |

SAMU atende emergências médicas, reanima jogadores inconscientes. Bombeiros atuam em resgates e incêndios.

#### Legal / Governo (cor dourada)

| ID | Organização | Patentes (menor → maior) |
|----|------------|--------------------------|
| 76 | **Prefeitura de São Paulo** | Assistente Administrativo → Assessor Municipal → Coordenador de Área → Secretário Municipal → Sub-Prefeito → **Prefeito** |
| 82 | **OAB-SP** — Ordem dos Advogados do Brasil | Estagiário → Advogado → Advogado Sênior → Sócio Associado → Sócio-Fundador → **Presidente OAB-SP** |

Prefeitura gere leis municipais, impostos e obras IC. OAB defende acusados, representa a lei civil.

#### Gangues (cor roxa)

| ID | Organização | Patentes (menor → maior) |
|----|------------|--------------------------|
| 77 | **PCC** — Primeiro Comando da Capital | Disciplina → Setor → Sintonia → Frente → Piloto → **Fundação** |
| 83 | **CV** — Comando Vermelho | Soldado → Gerente → Dono de Boca → Chefe de Área → Comando → **Alto Comando** |

Gangues capturam **territórios** no mapa (sistema `oTerritory`). Cada zona controlada gera renda IC por hora. PCC e CV competem entre si — e contra a polícia.

#### Máfia (cor roxa escura)

| ID | Organização | Patentes (menor → maior) |
|----|------------|--------------------------|
| 78 | **Família Lombardi** — Cosa Nostra SP | Associato → Soldato → Caporegime → Consigliere → Underboss → **Don** |
| 79 | **Yakuza São Paulo** — Yamaguchi-gumi BR | Trainee → Ippan Kumiin → Shateigashira → Wakagashira → Saiko-Komon → **Oyabun** |

Máfias também capturam territórios e operam crime de alto escalão. Especialidade em lavagem de dinheiro e mercado negro.

### 3.3 Como entrar numa facção

1. **Convite IC** — o líder da facção usa `/setplayerfaction` (admin) ou a própria mecânica de recrutamento IC.
2. **Duty** — ao entrar em serviço no HQ da facção, recebes uniforme e equipamento autorizado para a sua categoria.
3. **Salário** — o payday (`oPayday`) deposita automaticamente o salário da tua patente.

### 3.4 Sistema de procurados (`oWanted`)

Se cometeres crimes — resistência à prisão, assalto, homicídio, tráfico, etc. — acumulas **estrelas de procurado** (1★ a 5★):

| Nível | Crime típico | Como limpar |
|-------|-------------|------------|
| 1★–2★ | Fuga, agressão | Decai automaticamente com o tempo |
| 3★ | Roubo, crime organizado | Decai automaticamente (mais lento) |
| 4★–5★ | Homicídio, sequestro, tráfico | Só limpa ao ser preso pela polícia |

Quando és preso, o policial recebe uma **recompensa (bounty)** pelo teu nível de procurado.

### 3.5 Territórios (`oTerritory`)

Gangues e máfias podem **capturar zonas** da cidade mantendo membros presentes numa área por tempo suficiente. Territórios controlados geram **renda para a facção** a cada hora. Para capturar precisas de pelo menos 2 membros em duty na zona.

Zonas existentes: Idlewood, Grove Street, Playa del Seville, Jefferson, Las Venturas Strip, Tierra Robada, Blueberry, Palomino Creek.

### 3.6 Polícia e terminal MDC

O **MDC** (computador dentro do viatura policial) permite:
- Consultar fichas de personagens
- Ver multas, mandados e procurados
- Registar ocorrências IC

Apenas PMESP e PCSP têm acesso ao MDC.

---

## 4. Mapas e sedes de facção

As sedes de facção (HQ) são configuradas in-game pelos administradores através do sistema `oFactionHQ`. Quando uma facção tem HQ ativo, aparece um **marcador de duty** no local onde os membros entram em serviço.

### Zonas de território capturáveis

| Zona | Região aproximada no GTA SA |
|------|-----------------------------|
| Idlewood | Sul de Los Santos |
| Grove Street | Sul de Los Santos |
| Playa del Seville | Leste de Los Santos |
| Jefferson | Centro-leste de Los Santos |
| LV Strip | Las Venturas |
| Tierra Robada | Norte de San Andreas |
| Blueberry | Red County |
| Palomino Creek | Red County |

### Mapas de edificios legados (infraestrutura existente no servidor)

| Recurso | Tema | Coordenadas aprox. |
|---------|------|--------------------|
| `oPDOutsideMap` | Delegacia / PMESP exterior | 1555, -1610, 15 |
| `oNewPD` + `oPDInteriorMap` | Interior da delegacia | — mesma zona LS |
| `oSheriffHQ` | Sheriff / zona rural | 620, -585, 17 (Dillimore) |

Para mapas de HQ de gangues e máfias (Albanian, Los Zetas, Crips, etc.), esses arquivos são legado do OriginalRP hungaro — os HQs das novas facções SP serão configurados pelos admins in-game.

### Como se locomover

1. Abre o **mapa grande** (tecla de mapa do MTA/GTA).
2. Usa **GPS IC** ou orienta-se pelas coordenadas X, Y, Z.
3. Aluga/compra carro (`oCarshop`), usa o ônibus (`oBus`) ou táxi RP entre jogadores.
4. Em **zonas fechadas**, respeita as regras IC do servidor.

---

## 5. Empregos (trabalhos civis)

A lista principal exibida no hub de empregos vem de `[Jobs]/oJob/global.lua`. Os textos originais ainda estão em húngaro no ficheiro; abaixo está a **tradução do sentido** e a **área** indicada no script.

| # | Nome no script (HU) | Tradução / papel | Zona citada no script | Emprego ativo no `oStarter` |
|---|---------------------|------------------|----------------------|-----------------------------|
| 1 | Takarító | **Faxineiro / limpeza** (limpar casas e locais) | Los Santos, Red County | Sim (`oJob_Cleaner` + variantes como `oTakaritoNew`) |
| 2 | Pénztáros | **Caixa de supermercado** | Los Santos, Red County | Sim (`oJob_Cashier`) |
| 3 | Pizzakészítő | **Pizzaiolo / pizzaria** | Los Santos | Sim (`oJob_PizzaMaker`) |
| 4 | Etikus Hacker | **“Hacker ético”** (missões de intrusão autorizada minigame) | Los Santos | Sim (`oJob_Hacker`) |
| 5 | Újságos | **Jornaleiro** (entrega de jornais) | Red County | Sim (`oJob_Newspaper`) |
| 6 | Költöztető | **Mudanças / transporte de móveis** entre imóveis | Los Santos | Sim (`oJob_FurnitureTransport`) |
| 7 | Kertész | **Jardineiro** | Los Santos, Red County | Sim (`oJob_Gardener` + `oGardenerMap`) |
| 8 | Darukezelő | **Operador de grua** em canteiros de obras | Los Santos | Sim (`oJob_Crane` + mapas `oConstructionMap*`, `oEszakiEpitkezes`) |

**Outros empregos / atividades ligadas a mapas ou recursos:**

- **`oBus`** — motorista de autocarro (rotas no mapa `oBusMap`).
- **Entrega de comida** — existe recurso `oJob_foodDelivery` na árvore; **não** está na lista curta do `starter_manifest.lua` desta revisão — pode estar desligado ou iniciado à parte no teu host.
- **`oJob_carFactory`, `oJob_PackageTransporter`, `oJob_WaterPipeMechanic`** — presentes na pasta `[Jobs]`; confirma com o teu `oStarter` / symlinks se estão **realmente** a correr.

Normalmente **aceitas o trabalho** num NPC/marcador no mundo (cada `oJob_*` tem o seu `renderC.lua` / `client.lua` com pontos de interação). O veículo de trabalho pode ser criado via evento comum `job > createJobVehicle` (`oJob/server.lua`).

---

## 6. Onde saber mais (sem ser jogador)

- Catálogo de recursos e ordem de arranque: [catalogo-originalrp-ipiranga.md](catalogo-originalrp-ipiranga.md).
- Infra e VPS: [infra/server-setup.md](infra/server-setup.md).

---

---

## 7. Dicas rápidas

| Tecla / Comando | Função |
|----------------|--------|
| F1 | Painel principal (stats, facção, configurações) |
| Right-click em NPC | Abrir interação (lojas, dealer, etc.) |
| `/duty` | Entrar/sair de serviço na facção |
| Inventário | Gerenciar itens (atalho configurado no servidor) |
| Chat IC | Comunicação in-character |

Para dúvidas sobre o servidor, contacta um administrador in-game.

---

*Ipiranga Roleplay — baseado no gamemode OriginalRP, tropicalizado para São Paulo. Facções baseadas em organizações reais de SP.*
