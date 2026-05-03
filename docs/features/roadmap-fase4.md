# Roadmap Fase 4 — Novos Sistemas Premium (Ipiranga Roleplay)

**Planejado em:** 2026-05-03  
**Nível:** Enterprise / Produto Premium  
**Autor:** Equipe Técnica

---

## Visão geral

Seis sistemas novos que transformam o Ipiranga Roleplay num produto de nível enterprise — diferenciados de qualquer servidor brasileiro pela profundidade de integração, coerência narrativa com São Paulo, e mecânicas que nenhum outro servidor tem.

Cada sistema está planejado com:
- Arquitetura de recurso MTA (ficheiros, DB, eventos)
- Integrações com recursos existentes
- Ideias premium exclusivas que excedem o básico do mercado

---

## 1. `oWelcome` — Popup de Boas-Vindas

### Proposta
Janela apresentada ao novo jogador (ou em cada sessão, configurável) com 4 abas: **Atalhos**, **Comandos**, **Informações** e **Redes Sociais**. Mais do que um tutorial estático — inclui notícias do servidor, dica do dia rotativa e destaque de jogadores.

### Diferencial premium
- **Feed de notícias dinâmico**: admins postam atualizações que aparecem nesta janela (sem precisar editar arquivos).
- **Dica do dia**: rota automática de tips da equipe. Muda a cada 24h.
- **Destaque do servidor**: mostra o #1 atual do rank, o território mais disputado e o próximo evento.
- **Checkbox "não mostrar novamente"** com opção de reabrir via `/ajuda` ou `/welcome`.

### Arquitetura de ficheiros

```
oWelcome/
  meta.xml
  client.lua     — UI: janelas, abas, animação de entrada/saída
  server.lua     — entrega conteúdo dinâmico (dicas, notícias, stats)
  global.lua     — atalhos estáticos, comandos estáticos, links sociais
```

### DB

```sql
CREATE TABLE welcome_news (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(120) NOT NULL,
  body VARCHAR(500) NOT NULL,
  created_by VARCHAR(60),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  active TINYINT DEFAULT 1
);

CREATE TABLE welcome_tips (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tip VARCHAR(300) NOT NULL,
  active TINYINT DEFAULT 1
);
```

### Coluna em `accounts`

```sql
ALTER TABLE accounts ADD COLUMN welcome_seen TINYINT DEFAULT 0;
```

### Eventos

```
oAccount → onClientResourceStart → triggerServerEvent("oWelcome > checkSeen", localPlayer)
server   → triggerClientEvent("oWelcome > open", player, {news, tip, rankStats, territories})
client   → triggerServerEvent("oWelcome > markSeen", localPlayer)
```

### Comandos admin (nível 4+)
- `/addnews <titulo> <corpo>` — adicionar notícia
- `/delnews <id>` — remover notícia
- `/addtip <texto>` — adicionar dica

### Integração oStarter
Adicionar `oWelcome` ao manifesto **após** `oAccount`.

---

## 2. `oHeist` — Sistema de Roubos Estratégicos

### Proposta
Roubos em pontos fixos do mapa com diferentes níveis de complexidade, sistema de fases, minigames exclusivos, resposta policial escalável e integração profunda com `oWanted`, `oFactionScripts` e economia do servidor.

### Tipos de roubo

| Tipo | Jogadores | Duração | Recompensa | Nível alerta |
|------|-----------|---------|-----------|-------------|
| ATM | 1 | 30s | $500–$1.500 | ★★ |
| Loja de Conveniência | 1–2 | 90s | $1.500–$4.000 | ★★★ |
| Posto de Gasolina | 1–2 | 60s | $1.000–$3.000 | ★★ |
| Loja de Joias | 2–4 | 3 min | $8.000–$20.000 | ★★★★ |
| Banco Central | 4–8 | 15–20 min | $40.000–$120.000 | ★★★★★ |
| Carro Forte | 3–5 | variável (rota) | $15.000–$50.000 | ★★★★★ |

### Mecânicas exclusivas (diferencial premium)

**Fases do banco:**
1. Planejamento — grupo define papéis (hacker, atirador, motorista, vigia)
2. Preparação — comprar itens de heist (kit de hacker, furadeira, disfarce)
3. Execução — minigame de hacking para desativar alarme (60s), minigame de furadeira para cofre (90s)
4. Fuga — janela de 3 min para sair da área de exclusão policial

**Sistema de evidências:**
- Crime sem disfarce → fotografia de CCTV → `oWanted` ganha nível mesmo após fuga
- Disfarce (item de capuz/máscara) reduz chance de identificação para 30%
- PCSP (Polícia Civil) pode investigar o local depois e identificar participantes

**Sistema de testemunhas:**
- Jogadores próximos que viram o crime recebem aviso e podem `/reportar <evento_id>`
- NPCs-testemunha geram evidência automática se você não usou disfarce

**Resposta policial dinâmica:**
- Alerta cresce em 4 fases: local → backup → SWAT → roadblock
- Cada fase tem mais unidades e um nível de wanted mais alto para participantes
- Se não há policiais online: resposta atrasada (sistema funciona sem staff)

### Arquitetura de ficheiros

```
oHeist/
  meta.xml
  global.lua           — tipos de heist, posições, configs
  server.lua           — controle de estado, alertas, recompensas
  client.lua           — UI de heist, minigames, marcadores
  minigames/
    hacking.lua        — minigame de hacking (grid de senha)
    drill.lua          — minigame de furadeira (temperatura/pressão)
    lockpick.lua       — (reusado por oCarTheft)
  types/
    atm.lua            — lógica específica de ATM
    store.lua          — loja de conveniência
    bank.lua           — banco (fase completa)
    armored.lua        — carro forte (rota dinâmica)
```

### DB

```sql
CREATE TABLE heist_locations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(30) NOT NULL,
  name VARCHAR(80) NOT NULL,
  pos JSON NOT NULL,
  is_active TINYINT DEFAULT 1,
  last_robbed TIMESTAMP NULL,
  cooldown_minutes INT DEFAULT 30,
  reward_min INT DEFAULT 1000,
  reward_max INT DEFAULT 5000,
  min_players INT DEFAULT 1,
  police_alert_level INT DEFAULT 2
);

CREATE TABLE heist_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  location_id INT NOT NULL,
  participants JSON NOT NULL,
  reward_total INT DEFAULT 0,
  success TINYINT DEFAULT 0,
  started_at TIMESTAMP,
  ended_at TIMESTAMP
);
```

### Integração
- `exports.oWanted:addCrime(player, "roubo")` — ao iniciar roubo
- `exports.oFactionScripts:isInLawEnforcementDuty(p)` — para determinar se há policial online
- `oRank` — incrementar `rank_stats` de "roubos_realizados"

---

## 3. `oChat3` — Sistema de 3 Chats

### Proposta
Três canais de comunicação com identidades distintas, acionados pelas teclas **T**, **Y** e **U**.

### T — Chat Normal (aprimorado)
Enhancement do chat existente. Comandos especiais:
- `/me <ação>` — ação em terceira pessoa (cor diferente)
- `/do <descrição>` — descrição de ambiente IC
- `/b <mensagem>` — OOC entre jogadores próximos (cor cinza, entre colchetes)
- Proximidade: 20m para chat normal, 5m para sussurro (`/w`)

### Y — Twitter (@IpirangarolTweet)

**UI:** Feed vertical semi-transparente no lado direito da tela (toggle com `/twitter` ou Y no chat)

**Mecânica:**
- Post limitado a 240 caracteres
- Nome do personagem + tag da facção aparecem no post
- Outros jogadores podem dar "❤" (like) clicando no post
- Posts ficam no feed da sessão (últimos 50)
- Admins podem fixar posts (`/tweetpin <id>`) ou deletar (`/tweetdel <id>`)
- Hashtags com cor diferente: `#PCC` fica colorido na cor da facção

**DB:**
```sql
CREATE TABLE twitter_posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  char_id INT NOT NULL,
  char_name VARCHAR(60) NOT NULL,
  faction_tag VARCHAR(20),
  faction_color VARCHAR(7),
  content VARCHAR(240) NOT NULL,
  likes INT DEFAULT 0,
  is_pinned TINYINT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### U — Deep Web (404.onion)

**UI:** Estilo terminal — fundo preto, texto verde `#00ff41`, fonte monoespaçada.

**Mecânica:**
- Nome exibido como `[usr_XXXX]` (hash aleatória baseada no char_id, muda a cada sessão)
- Zero persistência: mensagens não são salvas no DB
- Só disponível para jogadores com item "Dispositivo Criptografado" (item ID a definir em oInventory) **OU** dentro de zonas específicas no mapa (lan house clandestina, por exemplo)
- Admins vêem o nome real no painel (via log separado no servidor)

**Differentials:**
- Posts podem ter `[RECOMPENSA: $X]` — cria uma bounty automaticamente no oWanted
- Jogadores podem vender itens ilegais aqui com `/post vendo lockpick $500` — cria listagem temporária

### Arquitetura

```
oChat3/
  meta.xml
  client.lua     — captura teclas T/Y/U, renderiza UIs, animações
  server.lua     — roteamento de mensagens, persist Twitter, log Deep Web
  global.lua     — configs, filtros de linguagem, limites
```

### Integração
- `oTags` — tag da facção aparece no Y-chat
- `oWanted` — bounty via deep web
- `oInventory` — checar item "Dispositivo Criptografado" para U-chat

---

## 4. `oTags` — Sistema de Tags

### Proposta
Cada jogador tem uma **tag** que aparece no nametag, no chat, no MDC e no painel de facção. Tags têm cor, fundo, borda e podem ser animadas. Facções têm tag automática; admins podem criar e distribuir tags customizadas.

### Estrutura de uma tag

```lua
{
  id = 1,
  name = "PMESP",            -- nome interno
  text = "PM",               -- texto exibido
  color = "#ffffff",         -- cor do texto
  bg_color = "#1a3a8f",      -- fundo
  border_color = "#4466cc",  -- borda
  animated = false,          -- efeito de brilho pulsante
  rarity = "common",         -- common | rare | legendary
  source = "faction",        -- faction | admin | achievement | rank | event
  faction_id = 74,           -- se source=faction
}
```

### Sistema de prioridade

| Prioridade | Tipo | Exemplo |
|-----------|------|---------|
| 100 | Admin atribuída | [OWNER], [DEV] |
| 80 | Evento temporário | [NATAL 2026] |
| 60 | Rank sazonal (top 3) | [#1 RICO] |
| 40 | Conquista | [MILIONÁRIO], [SEM LEI] |
| 10 | Facção | [PM], [PCC], [YAKUZA] |
| 0 | Padrão | [CIV] |

### Exibição

- **Nametag:** tag aparece à esquerda do nome do personagem
- **Chat (T, Y):** `[PM] Carlos Silva: mensagem`
- **MDC:** campo "tag" na ficha
- **Leaderboard (oRank):** tag aparece ao lado do nome

### DB

```sql
CREATE TABLE tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(40) NOT NULL,
  text VARCHAR(20) NOT NULL,
  color VARCHAR(7) DEFAULT '#ffffff',
  bg_color VARCHAR(7) DEFAULT '#333333',
  border_color VARCHAR(7) DEFAULT '#555555',
  animated TINYINT DEFAULT 0,
  rarity ENUM('common','rare','legendary') DEFAULT 'common',
  source ENUM('faction','admin','achievement','rank','event') DEFAULT 'admin',
  faction_id INT DEFAULT NULL,
  created_by VARCHAR(60),
  expires_at TIMESTAMP NULL
);

CREATE TABLE player_tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  char_id INT NOT NULL,
  tag_id INT NOT NULL,
  is_active TINYINT DEFAULT 1,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NULL,
  UNIQUE KEY unique_char_tag (char_id, tag_id)
);
```

### Tags de facção pré-configuradas

Geradas automaticamente na tabela `tags` para cada facção:

| faction_id | text | color | bg_color |
|-----------|------|-------|---------|
| 74 | PM | #ffffff | #1a3a8f |
| 80 | PC | #ffffff | #2960c8 |
| 75 | SAMU | #ffffff | #cc1a1a |
| 81 | BM | #ffffff | #b01010 |
| 76 | PREF | #ffdd00 | #005baa |
| 82 | OAB | #222222 | #b5932a |
| 77 | PCC | #dddddd | #6a1fc2 |
| 83 | CV | #ffffff | #b71c1c |
| 78 | MAFIA | #dddddd | #311b92 |
| 79 | YAKUZA | #dddd99 | #1b5e20 |

### Comandos admin

```
/createtag <nome> <texto> <#cor_texto> <#cor_fundo>     — nível 7
/givetag <player> <tag_id>                               — nível 6
/removetag <player> <tag_id>                             — nível 6
/listtags                                                — nível 4
/deletetag <tag_id>                                      — nível 8
```

### Automações

- Ao entrar em facção (`setplayerfaction`) → atribuir tag da facção automaticamente
- Ao sair de facção → desativar tag da facção
- Ao atingir top 3 no `oRank` → atribuir tag temporária `[#1 RICO]` etc. (renovar semanalmente)

### Arquitetura

```
oTags/
  meta.xml
  global.lua     — definições de raridade, constantes
  server.lua     — CRUD tags, atribuição automática por facção
  client.lua     — renderização nametag, integração chat
```

---

## 5. `oCarTheft` — Sistema de Roubo de Carros

### Proposta
Ecossistema completo de roubo de carros: lockpick vendida só por máfias, minigame de arrombamento, alarmes, GPS tracker, chop shops e seguro. Integra toda a cadeia económica — mafia vende, ladrão executa, mecânico desmonta, dono aciona seguro.

### Fluxo completo

```
MAFIA vende lockpick (item 95) → LADRÃO compra
→ se aproxima do carro alheio (2m) → rightclick → "Tentar arrombar"
→ minigame (3-5 tentativas, cada uma consome 1 lockpick)
  ↓ falha       → alarme dispara (30s) → notifica dono online
  ↓ 3 falhas    → carro entra em "modo seguro" por 5 min
  ↓ sucesso     → carro como "roubado" (veh:isStolen=true)
→ ladrão dirige ao CHOP SHOP (interior de mecânica criminal)
→ minigame de desmontagem (90s)
→ ladrão recebe $2.000–$8.000 (70%) + chop shop recebe 30%
→ carro é destruído (deleteElement)

DONO:
→ recebe alerta em tempo real se online
→ se GPS Tracker instalado → vê carro no mapa por 10 min após roubo
→ após carro destruído → aciona /seguro → recebe 60% do valor em 5 min
```

### Mecânica de lockpick
- Item 95 = "Lockpick Artesanal"
- Cada lockpick = 1 tentativa
- Probabilidade de sucesso por tentativa: 30% (aumenta com skill se `oRank` tiver stat "arrombamentos")
- Alarme ao falhar: 45% de chance
- Alarme dura 30s, é visível para todos no mapa como blip vermelho piscando

### GPS Tracker
- Item 96 = "Rastreador GPS"
- Owner instala via rightclick no carro próprio
- Se instalado: quando carro é roubado, owner recebe localização atualizada a cada 10s por 10 min
- Item 97 = "Detector de Rastreador" — ladrão pode usar dentro do carro para descobrir e remover GPS

### Chop Shop
- Interiors configurados por admin: `/addchopshop` (nível 7)
- Requer: jogador dentro do interior + carro roubado na garagem/marcador
- Organização dona do chop shop (type 4/5) recebe porcentagem automática
- DB: tabela `chop_shops` — id, org_id, interior_id, pos (JSON), rate (percentual para org)

### Seguro de carro
- Coluna `veh:insuranceValue` no element data (calculado ao criar veículo: 40% do preço original)
- `/seguro` abre painel — mostra carros roubados/destruídos com botão de reclamar
- Cooldown por carro: 24h reais
- Pagamento imediato ao char:money

### DB

```sql
ALTER TABLE vehicles ADD COLUMN insurance_claimed_at TIMESTAMP NULL;

CREATE TABLE stolen_vehicles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  veh_db_id INT NOT NULL,
  stolen_by INT NOT NULL,
  stolen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  chopped_at TIMESTAMP NULL,
  recovered_at TIMESTAMP NULL,
  reward_paid INT DEFAULT 0
);

CREATE TABLE chop_shops (
  id INT AUTO_INCREMENT PRIMARY KEY,
  org_id INT NOT NULL,
  name VARCHAR(60),
  pos JSON NOT NULL,
  interior_id INT DEFAULT 0,
  dimension_id INT DEFAULT 0,
  rate FLOAT DEFAULT 0.3,
  active TINYINT DEFAULT 1
);
```

### Arquitetura

```
oCarTheft/
  meta.xml
  global.lua        — item IDs, probabilidades, config
  server.lua        — eventos de roubo, chop, seguro, GPS
  client.lua        — UI, minigame lockpick (reusar drill de oHeist), alertas
```

### Integração
- `oInventory:hasItem(player, 95)` — checar lockpick
- `oInventory:removeItem(player, 95, 1)` — consumir lockpick
- `oWanted:addCrime(player, "roubo")` — ao roubar
- `oRank` — incrementar stat "carros_roubados"
- Venda de lockpick: configurar no NPC da facção Máfia (tipo 5) via `oInventory` shop

---

## 6. `oRank` — Sistema de Rankings

### Proposta
Placar de líderes multi-dimensional com resetagem sazonal, recompensas exclusivas e integração com `oTags`. Top 3 de cada categoria recebem tags douradas temporárias.

### Categorias

| Categoria | Stats rastreados |
|-----------|----------------|
| **Econômico** | dinheiro em mãos, patrimônio total (bens + dinheiro), transações |
| **Criminal** | procurados totais, crimes, roubos, carros furtados, nível máximo de wanted |
| **Policial** | prisões efetuadas, multas emitidas, horas em serviço, bounty total arrecadado |
| **Territorial** | territórios controlados (facção), tempo de domínio (semanas), defesas bem-sucedidas |
| **Social** | horas online, tweets publicados, likes recebidos, amigos adicionados |
| **Motorista** | km rodados, km sem infração, velocidade máxima registrada |
| **Combate** | mortes, assassinatos, KDA (kills/deaths), armas mais usadas |
| **Faccional** | facção com maior saldo, maior n° membros ativos, mais territórios |

### Sistema sazonal

- Temporada = 1 mês (configurável por admin)
- Ao fim da temporada: vencedor de cada categoria vai para `rank_hall_of_fame`
- Reset de stats em `rank_stats`
- Vencedores recebem: tag exclusiva da temporada + item comemorativo

### UI (`/rank`)

- Tela cheia com fundo animated
- Selector de categoria (lateral esquerda)
- Top 10 da categoria com animação de entrada
- Top 3 com display em podium (ouro/prata/bronze)
- Botão "Minhas Stats" — mostra posição e progresso do próprio jogador
- Atualizado a cada 5 minutos (cache no servidor, não query em tempo real)

### DB

```sql
CREATE TABLE rank_stats (
  id INT AUTO_INCREMENT PRIMARY KEY,
  char_id INT NOT NULL,
  stat_key VARCHAR(60) NOT NULL,
  value BIGINT DEFAULT 0,
  season INT DEFAULT 1,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_char_stat_season (char_id, stat_key, season)
);

CREATE TABLE rank_seasons (
  id INT AUTO_INCREMENT PRIMARY KEY,
  season_number INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status ENUM('active','closed') DEFAULT 'active'
);

CREATE TABLE rank_hall_of_fame (
  id INT AUTO_INCREMENT PRIMARY KEY,
  season_id INT NOT NULL,
  category VARCHAR(60) NOT NULL,
  char_id INT NOT NULL,
  char_name VARCHAR(60) NOT NULL,
  value BIGINT NOT NULL,
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Arquitetura

```
oRank/
  meta.xml
  global.lua     — categorias, configs de temporada, funções utilitárias
  server.lua     — incremento de stats, cache periódico, handler de temporada
  client.lua     — UI completa, animações de podium
```

### Integração
- `exports.oRank:incrementStat(charId, statKey, amount)` — export público para todos os recursos
- `oWanted` → incrementar `crimes`, `nivel_maximo_wanted`
- `oCarTheft` → incrementar `carros_roubados`
- `oHeist` → incrementar `roubos_realizados`
- `oFactionScripts` → incrementar `prisoes`
- `oTerritory` → dados de `territorios_controlados` vindos de query da tabela territories

---

## 7. Ideias Exclusivas — Diferencial Enterprise

Estas ideias vão além do que qualquer servidor brasileiro oferece. Implementar após os 6 sistemas base.

### A. `oReputation` — Sistema de Reputação IC (Relações com Facções)

Cada personagem tem uma pontuação de reputação (−100 a +100) com cada facção.

- Ajudar a polícia → rep PMESP +5, rep PCC −3
- Comprar da mafia → rep Lombardi +2, rep PCSP −1
- Ser preso por PM → rep PMESP −10

**Efeitos:**
- Rep alta na PMESP → preço menor em armas legais, acesso a zonas restritas
- Rep alta no PCC → desconto no mercado negro, proteção de membros
- Rep negativa → NPCs hostis, preços majorados, expulsão do território

**Único no mercado brasileiro** — cria escolhas narrativas reais.

### B. `oEvidence` — Sistema de Evidências Forenses

Crimes deixam pistas no mundo:
- Arma disparada → cápsulas no chão (objeto coletável, some em 5 min)
- Carro arrombado → arranhões visíveis na porta
- Roubo → testemunha (jogador próximo) pode `/ confirmar` gerando evidência ligada ao char_id

PCSP pode abrir `/ investigar <local>` e ver lista de evidências, depois usar `/indiciar <char_id>` para gerar mandado de prisão — ativo mesmo sem flagrante.

**Único no mercado** — cria roleplay investigativo genuíno.

### C. `oTribunal` — Sistema de Tribunal

Quando um jogador está preso, a OAB pode pedir revisão:

```
/tribunal <prisoner_char_id>
```

Marca sessão no próximo horário disponível. Sala de tribunal (interior específico) é aberta. Defesa (OAB) e acusação (PCSP) têm 5 min cada para apresentar IC. Admin ou jogador eleito como juiz dá veredito.

- Absolvição → wanted limpa, preso solto
- Culpado → pena mantida ou aumentada

**Nenhum servidor brasileiro tem** sistema legal IC deste nível.

### D. `oElections` — Sistema de Eleições Municipais

Prefeitura de São Paulo tem cargos eleitos:

- Campanha (3 dias): candidatos fazem discursos IC, postam no Y-chat, distribuem "panfletos" (item)
- Votação (1 dia): `/votar <nome_candidato>`
- Vencedor → automaticamente promovido a "Prefeito" na facção 76
- Mandato de 2 semanas reais

Cria engajamento político e conteúdo de RP espontâneo.

### E. `oMedia` — Mídia IC (Jornal + Rádio)

- Jogadores com profissão "Jornalista" podem usar câmera (item) para tirar screenshots IC
- Escrever artigo via interface: título + corpo de texto
- Artigo publicado → vira item "Jornal" no inventário, distribuível a outros jogadores
- Radio IC: player com microfone pode transmitir para todos em duty de mídia

---

## 8. Plano de implementação sugerido

### Fase 4.1 (imediato)
1. `oTags` — base para todos os outros sistemas (chat, rank, nametag)
2. `oChat3` — impacto imediato de UX
3. `oWelcome` — onboarding de novos jogadores

### Fase 4.2
4. `oRank` — sistema de progressão
5. `oCarTheft` — nova atividade económica

### Fase 4.3
6. `oHeist` — sistema mais complexo, requer oCarTheft e oRank
7. `oReputation` — depende de oHeist, oCarTheft, oWanted estarem maduros

### Fase 4.4 (diferencial enterprise)
8. `oEvidence` + `oTribunal`
9. `oElections`
10. `oMedia`

---

## 9. Cor das facções (implementado em DB)

Coluna `color` (hex) adicionada à tabela `factions`:

| ID | Facção | Cor |
|----|--------|-----|
| 74 | PMESP | `#1a3a8f` — azul naval |
| 80 | PCSP | `#2960c8` — azul real |
| 75 | SAMU | `#cc1a1a` — vermelho emergência |
| 81 | Bombeiros | `#b01010` — vermelho profundo |
| 76 | Prefeitura SP | `#005baa` — azul institucional |
| 82 | OAB-SP | `#b5932a` — dourado advocatício |
| 77 | PCC | `#6a1fc2` — roxo profundo |
| 83 | CV | `#b71c1c` — carmesim |
| 78 | Família Lombardi | `#311b92` — índigo escuro |
| 79 | Yakuza SP | `#1b5e20` — verde escuro tradicional |

Leitura no código: `exports.oMysql:queryFetch("SELECT color FROM factions WHERE id=?", {fid})`  
Ou: via element data `faction:color` populado no boot.

---

*Documento de arquitetura — Ipiranga Roleplay. Para spec técnica por feature, ver `.cursor/context/novos-sistemas.md`.*
