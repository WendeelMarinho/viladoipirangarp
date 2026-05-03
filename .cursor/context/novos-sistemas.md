# Contexto Cursor — Novos Sistemas Fase 4

**Ler antes de implementar qualquer feature nova desta fase.**  
Spec completa: `docs/features/roadmap-fase4.md`

---

## Padrão obrigatório para novos recursos

```lua
-- meta.xml mínimo
<meta>
  <info author="Ipiranga RP" type="gamemode" />
  <script src="global.lua" type="shared" />
  <script src="server.lua" type="server" />
  <script src="client.lua" type="client" />
  <export function="nomeDoExport" type="server" />
</meta>

-- server.lua: sempre validar source
addEvent("recurso > acao", true)
addEventHandler("recurso > acao", getRootElement(), function(arg1)
  local player = source
  if not isElement(player) or getElementType(player) ~= "player" then return end
  -- lógica aqui
end)

-- DB: sempre usar exports.oMysql:getDBConnection() + dbQuery parametrizado
local conn = exports.oMysql:getDBConnection()
dbQuery(conn, "SELECT * FROM tabela WHERE id=?", {valor})
```

## Convenções de nomes de eventos

Padrão: `"recurso > acao"` (espaços ao redor do `>`)  
Exemplos: `"oTags > getPlayerTag"`, `"oHeist > startRobbery"`, `"oRank > incrementStat"`

## Integração com recursos existentes

```lua
-- Pontos premium
getElementData(player, "char:pp")
setElementData(player, "char:pp", novoValor)

-- Dinheiro
getElementData(player, "char:money")
setElementData(player, "char:money", novoValor)

-- ID do personagem
getElementData(player, "char:id")

-- Facção principal
getElementData(player, "char:mainFaction")  -- int (faction id)

-- Inventário
exports.oInventory:hasItem(player, itemId)
exports.oInventory:removeItem(player, itemId, quantidade, 0)
exports.oInventory:giveItem(player, itemId, quantidade, valor, 0)

-- Admin check
exports.oAdmin:hasPermission(player, nivelMinimo)  -- ou getElementData(player, "user:admin")

-- Wanted
exports.oWanted:addCrime(player, "chave_crime")     -- chaves: fuga_policial, resistencia, agressao, roubo, homicidio, crime_org, trafico, sequestro
exports.oWanted:clearWanted(criminal, policial)

-- FactionScripts
exports.oFactionScripts:isInLawEnforcementDuty(player)
exports.oFactionScripts:isInMedicalDuty(player)

-- Infobox
exports.oInfobox:outputInfoBox("mensagem", "success")  -- ou "error", "warning", "info"

-- Prefixo de server no chat
core:getServerPrefix("green-dark", "NomeRecurso", 3)
```

## Fontes e UI

```lua
-- Fontes disponíveis (via core font object)
font:getFont("bebasneue", tamanhoPixels)
font:getFont("condensed", tamanhoPixels)

-- Cores padrão do servidor
r, g, b  -- cor primária do servidor (variável global)
color    -- string de cor para colorCode no chat

-- Resolução de tela
sx, sy = guiGetScreenSize()
```

## Facções — leitura de cor

```lua
-- Cor da facção (campo 'color' em factions, hex string)
-- Obter no boot do servidor:
local result = dbPoll(dbQuery(conn, "SELECT id, color FROM factions"), 1000)
for _, row in ipairs(result) do
  factionColors[row.id] = row.color
end
```

---

## 1. oWelcome — Instruções de implementação

**Criar em:** `oWelcome/`

### Fluxo
1. `oAccount` dispara `onPlayerLogin` (evento customizado ou element data `user:loggedin` = true)
2. Server verifica `accounts.welcome_seen` para o jogador
3. Se 0: envia dados via `triggerClientEvent("oWelcome > open", player, payload)`
4. Payload: `{news=[], tip="...", topRich="...", topTerritory="..."}`
5. Client renderiza janela com 4 abas

### Abas (conteúdo estático em global.lua)

```lua
shortcuts = {
  {"F1", "Painel principal"},
  {"F2", "Inventário"},
  {"F4", "Telefone"},
  {"T", "Chat IC"},
  {"Y", "Twitter IC"},
  {"U", "Deep Web (requer item)"},
  {"Tab", "Jogadores online"},
  {"Backspace", "Fechar painéis"},
}

commands = {
  {"/duty", "Entrar/sair de serviço na facção"},
  {"/ajuda", "Abrir este guia"},
  {"/rank", "Ranking do servidor"},
  {"/seguro", "Acionar seguro do veículo"},
  {"/twitter", "Abrir/fechar feed Twitter"},
}
```

### DB a criar
```sql
ALTER TABLE accounts ADD COLUMN IF NOT EXISTS welcome_seen TINYINT DEFAULT 0;
CREATE TABLE IF NOT EXISTS welcome_news (...);  -- ver spec completa
CREATE TABLE IF NOT EXISTS welcome_tips (...);  -- ver spec completa
```

---

## 2. oHeist — Instruções de implementação

**Criar em:** `oHeist/`

### Prioridade de implementação
Começar por: **ATM** e **Loja de Conveniência** (mais simples). Banco (heist completo) é fase posterior.

### Estado de roubo (server-side table)
```lua
activeHeists = {}
-- activeHeists[locationId] = {
--   participants = {player1, player2},
--   phase = "active",  -- ou "cooldown"
--   startTime = getTickCount(),
--   reward = 0,
-- }
```

### Minigame lockpick (reusável por oCarTheft)
- Barra de timing (igual ao dealer de drogas — ver `oDrugs/dealer/client.lua`)
- Verde = sucesso, vermelho = falha
- Parâmetros configuráveis: `successZoneSize`, `speed`

### Posições de locais (seed inicial em global.lua)
```lua
heistLocations = {
  {id=1, type="atm",   name="ATM Willowfield",      pos={2180, -1410, 25}, reward_min=500,   reward_max=1500,  min_players=1, cooldown=20},
  {id=2, type="store", name="Loja Idlewood",         pos={2020, -1755, 13}, reward_min=1500,  reward_max=4000,  min_players=1, cooldown=30},
  {id=3, type="store", name="Loja Jefferson",        pos={2270, -1660, 14}, reward_min=1500,  reward_max=4000,  min_players=1, cooldown=30},
  {id=4, type="bank",  name="Banco Central de LS",   pos={1491, -1022, 24}, reward_min=40000, reward_max=120000,min_players=4, cooldown=90},
}
```

---

## 3. oChat3 — Instruções de implementação

**Criar em:** `oChat3/`

### Captura de teclas (client)
```lua
-- Impedir que o chat padrão do MTA abra com Y e U
-- Usar bindKey + showChat(false) quando necessário
bindKey("y", "down", function() openCustomChat("twitter") end)
bindKey("u", "down", function() openCustomChat("deepweb") end)
-- T mantém o comportamento padrão do MTA (ou override conforme necessário)
```

### Feed do Twitter (renderização)
- Posição: `sx*0.72, sy*0.05` (superior direito, semi-transparente)
- Largura: `sx*0.26`
- Cada post: avatar da tag + nome + texto + ❤ count
- Scroll com roda do mouse se > 8 posts visíveis

### Deep Web — handle de anonimização (server)
```lua
-- Gerar handle consistente por sessão (não persiste)
function getAnonHandle(charId)
  local seed = charId * 7919 + sessionSeed  -- sessionSeed = math.random em onResourceStart
  return string.format("[usr_%04x]", seed % 65536)
end
```

---

## 4. oTags — Instruções de implementação

**Criar em:** `oTags/`

### Boot: popular tags de facção
```lua
-- No onResourceStart do servidor:
-- 1. Ler factions (id, name, color) da DB
-- 2. Para cada facção, criar/atualizar tag correspondente em tabela tags
-- 3. Cachear em factionTags[fid] = tagData
```

### Nametag rendering (client)
```lua
-- Em onClientRender (somente para jogadores visíveis no radar):
for k, player in ipairs(getElementsByType("player")) do
  local tag = getElementData(player, "player:activeTag")
  if tag then
    -- dxDrawRectangle para fundo
    -- dxDrawText para texto da tag
    -- Posicionar acima do nametag vanilla
  end
end
```

### Sincronização
- Server mantém `player:activeTag` como element data (JSON serializado)
- Atualizar ao: login, join faction, leave faction, givetag, rank update

### Export público
```lua
-- meta.xml: <export function="getPlayerTag" type="server" />
-- meta.xml: <export function="setPlayerTag" type="server" />
function getPlayerTag(player)
  return getElementData(player, "player:activeTag")
end
```

---

## 5. oCarTheft — Instruções de implementação

**Criar em:** `oCarTheft/`

### Item IDs (registrar em oInventory)
- Item 95: "Lockpick Artesanal" — consumível, 1 tentativa, só mafia vende
- Item 96: "Rastreador GPS" — instalável em veículo próprio
- Item 97: "Detector de Rastreador" — uso único, detecta e remove GPS

### Handler de arrombamento (server)
```lua
addEvent("oCarTheft > attemptLockpick", true)
addEventHandler("oCarTheft > attemptLockpick", getRootElement(), function(vehicle)
  local player = source
  if not isElement(player) or not isElement(vehicle) then return end
  -- checar: player tem item 95?
  -- checar: carro a < 3m?
  -- checar: carro não é do player?
  -- checar: carro não está em "modo seguro"?
  -- removeItem(player, 95, 1)
  -- calcular sucesso (30% base)
  -- triggerClientEvent resultado
end)
```

### Alarme
- `triggerClientEvent(getRootElement(), "oCarTheft > alarmSound", getRootElement(), vehPos)` — toca som para todos próximos
- Notificar dono se online: `triggerClientEvent(owner, "oCarTheft > ownerAlert", owner, vehId)`
- Blip vermelho piscando no mapa por 30s

### Integração com oWanted
```lua
-- Ao roubo bem-sucedido:
exports.oWanted:addCrime(player, "roubo")
exports.oRank:incrementStat(getElementData(player,"char:id"), "carros_roubados", 1)
```

---

## 6. oRank — Instruções de implementação

**Criar em:** `oRank/`

### Export público (central para outros recursos)
```lua
-- meta.xml: <export function="incrementStat" type="server" />
function incrementStat(charId, statKey, amount)
  local conn = exports.oMysql:getDBConnection()
  dbExec(conn, 
    "INSERT INTO rank_stats (char_id, stat_key, value, season) VALUES (?,?,?,?) "..
    "ON DUPLICATE KEY UPDATE value=value+?, last_updated=NOW()",
    {charId, statKey, amount, currentSeason, amount}
  )
end
```

### Cache de leaderboard (servidor)
```lua
-- Atualizar a cada 5 minutos
leaderboardCache = {}
setTimer(function()
  for cat, config in pairs(rankCategories) do
    local result = dbPoll(dbQuery(conn, 
      "SELECT r.char_id, c.nome as char_name, r.value FROM rank_stats r "..
      "JOIN characters c ON c.id=r.char_id "..
      "WHERE r.stat_key=? AND r.season=? ORDER BY r.value DESC LIMIT 10",
      {config.statKey, currentSeason}
    ), 1000)
    leaderboardCache[cat] = result
  end
end, 300000, 0)
```

### Rank tags automáticas (integração oTags)
```lua
-- Após atualizar cache, para cada categoria:
-- Top 1 → tag "[#1 NOME_CAT]" dourada por 5 min até próximo update
-- Top 2 → tag "[#2]" prateada
-- Top 3 → tag "[#3]" bronzeada
```

---

## Ordem de criação recomendada

1. **oTags** (sem dependências externas novas)
2. **oChat3** (usa oTags para exibir tag no feed)
3. **oWelcome** (usa oTags, usa stats de oRank — pode deixar placeholder)
4. **oRank** (exporta incrementStat para os outros)
5. **oCarTheft** (usa oRank, oWanted, oInventory)
6. **oHeist** (usa tudo acima)

## Adição ao oStarter

Após criar cada recurso e testar individualmente, adicionar ao `oStarter/starter_manifest.lua`:
```lua
-- oTags: após oAccount (linha ~50)
-- oChat3: após oTags
-- oWelcome: após oChat3
-- oRank: após oWelcome
-- oCarTheft: após oRank + oWanted (já existe)
-- oHeist: por último desta fase (mais dependências)
```

## Symlinks necessários (após criar os recursos)

```bash
cd /root/multitheftauto_linux_x64/mods/deathmatch/resources/
ln -s ../vila-do-ipiranga-rp/oTags oTags
ln -s ../vila-do-ipiranga-rp/oChat3 oChat3
ln -s ../vila-do-ipiranga-rp/oWelcome oWelcome
ln -s ../vila-do-ipiranga-rp/oRank oRank
ln -s ../vila-do-ipiranga-rp/oCarTheft oCarTheft
ln -s ../vila-do-ipiranga-rp/oHeist oHeist
```
