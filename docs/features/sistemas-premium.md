# Sistemas Premium — Sessão 2026-05-03

**Implementado por:** Claude Code (Sessão 2026-05-03)  
**Estado:** Código completo · Symlinks criados · Manifesto atualizado · **Pendente: configuração in-game**

---

## Visão geral

Quatro novos recursos foram criados do zero e integrados no servidor:

| Recurso | Localização | Função |
|---------|-------------|--------|
| `oFactionScripts` | `vila-do-ipiranga-rp/oFactionScripts/` | Scripts de gameplay para facções: algemas, grab, revivificação e 13 stubs |
| `oWanted` | `vila-do-ipiranga-rp/oWanted/` | Sistema de procurados (5 estrelas), bounty, notificação policial |
| `oTerritory` | `vila-do-ipiranga-rp/oTerritory/` | Dominação de territórios por gangues e máfias |
| `oFactionHQ` | `vila-do-ipiranga-rp/oFactionHQ/` | HQ exclusiva por facção: portões, munição, veículos |

**Ordem no `oStarter`:** `oFactionScripts` → `oWanted` → `oTerritory` → `oFactionHQ` → `oInteraction`

---

## 1. `oFactionScripts` — Scripts de facções

### Ficheiros
| Ficheiro | Tipo | Tamanho |
|----------|------|---------|
| `meta.xml` | config | 20 exports declarados |
| `global.lua` | shared | constantes ITEM_*, FACTION_TYPE_*, animações |
| `server.lua` | server | lógica cuff/grab/revive + exports API |
| `client.lua` | client | 17 funções exportadas para `oInteraction/usedButton.lua` |

### Funcionalidades implementadas
- **Algemas** (`cuffPlayer` / `cuffPlayer` uncuff): consome item 77, valida distância, sincroniza animação via `oFS > syncCuff`
- **Grab** (`grabPlayer` / `unleashPlayer`): `attachElements` offset 0.55 no eixo lateral, sincronizado via `oFS > syncGrab`
- **Revivificação** (`startPlayerRevivification`): médico consome kit 81 (item), 8s animação CPR com barra de progresso, cura para 50 HP
- **13 stubs** (`getStingerFromVeh`, `getSpeedcamFromVehicle`, `showRBSPanel`, `pickUpRBS`, `connectHose`, `connectHoseToVeh`, `unConnectHoseFromVeh`, `unConnectHose`, `attachDollyToPlayer`, `pickupDrum`, `takeDownDrum`, `pickupFuelDrum`, `takeDownFuelDrum`): retornam "em desenvolvimento" via oInfobox

### Exports de servidor
| Função | Uso |
|--------|-----|
| `isInLawEnforcementDuty(player)` | Verifica se jogador está de serviço em facção tipo 1 (forças de segurança) |
| `isInMedicalDuty(player)` | Verifica se jogador está de serviço em facção tipo 2 (saúde) |
| `getCuffedBy(player)` | Retorna o char_id do agente que algemou o jogador (ou nil) |

### Constantes (`global.lua`)
```lua
ITEM_ALGEMAS        = 77
ITEM_CHAVE_ALGEMAS  = 78
ITEM_KIT_PRIMEIROS  = 81
CUFF_MAX_DIST       = 4.0
REVIVE_DURATION_MS  = 8000
GRAB_OFFSET_X       = 0.55
FACTION_TYPE_SEGURANCA = 1  -- Forças de segurança
FACTION_TYPE_SAUDE     = 2  -- Saúde
FACTION_TYPE_LEGAL     = 3  -- Organização legal
FACTION_TYPE_GANGUE    = 4  -- Gangue
FACTION_TYPE_MAFIA     = 5  -- Máfia
```

---

## 2. `oWanted` — Sistema de Procurados

### Ficheiros
| Ficheiro | Tipo |
|----------|------|
| `meta.xml` | 5 exports servidor |
| `global.lua` | CRIMES, WANTED_COLORS, bounties, decay |
| `server.lua` | cache em memória + DB sync + decay timer |
| `client.lua` | HUD estrelas + blips + comando `/crime` |

### Funcionalidade
- **5 níveis** de procurado (1★ a 5★) com cores distintas no HUD
- **8 tipos de crime** com severidade mínima e bounty base:

| Chave | Crime | Nível mín. | Bounty base |
|-------|-------|-----------|-------------|
| `fuga_policial` | Fuga da polícia | 1 | R$500 |
| `resistencia` | Resistência à prisão | 2 | R$1.500 |
| `agressao` | Agressão | 1 | R$500 |
| `roubo` | Roubo | 2 | R$1.500 |
| `homicidio` | Homicídio | 3 | R$3.000 |
| `crime_org` | Crime organizado | 3 | R$3.000 |
| `trafico` | Tráfico | 4 | R$7.500 |
| `sequestro` | Sequestro | 4 | R$7.500 |

- **Decaimento automático**: timer cada 60s verifica expiração. Níveis 1–3 decaem um por um com cooldown (10/20/40 min). Níveis 4–5 não decaem automaticamente (requerem prisão)
- **Bounty**: pago ao policial (`ARREST_REWARD_MULT = 1.2`) quando prende via `oWanted > arrest`
- **Notificação policial**: chat colorido para todos os jogadores em serviço tipo 1 com nome, nível e bounty
- **HUD pulsante**: estrelas animadas com pulse `sin(tick/300)`, lista de crimes e bounty abaixo
- **Blip no mapa** para polícia (blip tipo 10, vermelho)
- **Persistência**: tabela `wanted_active` em `orp_main`

### Exports de servidor
```lua
exports.oWanted:addCrime(player, crimeKey)   -- adiciona crime
exports.oWanted:clearWanted(player, officer) -- limpa e paga bounty
exports.oWanted:getWantedLevel(player)       -- retorna 0-5
exports.oWanted:isWanted(player)             -- boolean
exports.oWanted:getBounty(player)            -- valor em $
```

### Tabela DB
```sql
CREATE TABLE wanted_active (
    id INT AUTO_INCREMENT PRIMARY KEY,
    char_id INT NOT NULL,
    char_name VARCHAR(64),
    skin INT DEFAULT 0,
    crime_level TINYINT DEFAULT 1,
    bounty INT DEFAULT 0,
    crimes TEXT,
    issued_at INT DEFAULT 0,
    expires_at INT DEFAULT 0,
    faction_id INT DEFAULT 0,
    officer_name VARCHAR(64),
    note VARCHAR(255)
);
```

### Comando de teste (admin)
```
/crime <chave>    → adiciona crime ao próprio jogador (teste)
Exemplos: /crime roubo   /crime homicidio
```

---

## 3. `oTerritory` — Dominação de Territórios

### Ficheiros
| Ficheiro | Tipo |
|----------|------|
| `meta.xml` | 4 exports servidor |
| `global.lua` | estados, constantes de tempo |
| `server.lua` | captura tick + income timer |
| `client.lua` | blips + HUD + checkZone |

### Funcionalidade
- **8 zonas pré-configuradas** baseadas em áreas clássicas do GTA:SA:

| Zona | Área GTA:SA | Raio | Captura | Income/h |
|------|------------|------|---------|---------|
| Idlewood | Idlewood | 80m | 90s | R$5.000 |
| Grove Street | East Los Santos | 70m | 90s | R$6.000 |
| Playa del Seville | South East LS | 70m | 90s | R$5.500 |
| Jefferson | Jefferson | 75m | 90s | R$5.000 |
| Las Venturas Strip | LV Strip | 100m | 120s | R$8.000 |
| Tierra Robada | Norte | 90m | 120s | R$4.500 |
| Blueberry | Red County | 80m | 90s | R$4.000 |
| Palomino Creek | Red County | 75m | 90s | R$4.000 |

- **Estados**: `neutral` → `capturing` → `owned` / `contested`
- **Mecânica de captura**:
  - Mínimo de `min_members` jogadores da mesma facção dentro do raio
  - Apenas facções de tipo 4 (Gangue) ou 5 (Máfia) podem capturar (configurável via `allowed_types`)
  - Defensor captura 1.5× mais rápido (`DEFEND_SPEED_MULT`)
  - Se duas ou mais facções estiverem presentes → `contested` (progresso para)
  - Zona vazia → progresso retrocede gradualmente
- **Cooldown**: 30 min após captura
- **Notificação**: chat colorido vermelho para líderes (rank ≥ 2) da facção dona quando atacada
- **Anúncio server-wide** quando captura completa
- **Income territorial**: timer a cada hora deposita renda no banco de cada facção dona (`dashboard:setFactionBankMoney(fid, amount, "add")`)
- **HUD de zona**: ao entrar numa zona, painel DX mostra nome, estado, barra de progresso e dono
- **Blips no mapa**: atualizados em tempo real com cor da facção ou do estado

### Exports de servidor
```lua
exports.oTerritory:getTerritoryOwner(id)         -- faction_id ou 0
exports.oTerritory:getPlayerTerritory(player)    -- id da zona ou nil
exports.oTerritory:getAllTerritories()            -- tabela completa
exports.oTerritory:getTerritoryPaydayBonus(fid)  -- R$ bônus acumulado
```

### Constantes (`global.lua`)
```lua
CAPTURE_TICK_MS          = 1000      -- avalia a cada 1s
DEFEND_SPEED_MULT        = 1.5       -- defensores capturam 1.5×
COOLDOWN_AFTER_CAP       = 1800      -- 30 min cooldown
MIN_MEMBERS_CAP          = 2         -- mínimo para capturar
TERRITORY_INCOME_INTERVAL_MS = 3600000  -- income a cada hora
DEFAULT_ALLOWED_TYPES    = { 4, 5 }  -- gangue + máfia
```

### Tabela DB
```sql
CREATE TABLE territories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    zone_x FLOAT, zone_y FLOAT, zone_z FLOAT,
    zone_radius FLOAT DEFAULT 50,
    owner_faction INT DEFAULT 0,
    last_captured INT DEFAULT 0,
    cooldown_secs INT DEFAULT 1800,
    income_payday INT DEFAULT 0,
    allowed_types TEXT,
    blip_icon INT DEFAULT 40,
    color_r INT DEFAULT 180, color_g INT DEFAULT 180, color_b INT DEFAULT 180,
    min_members INT DEFAULT 2,
    capture_secs INT DEFAULT 60
);
```

---

## 4. `oFactionHQ` — Sede de Facção

### Ficheiros
| Ficheiro | Tipo |
|----------|------|
| `meta.xml` | 3 exports servidor |
| `global.lua` | `HQ_AMMO_ITEMS` por tipo, cooldown |
| `server.lua` | load + ponto munição + spawn veículo + cmds admin |
| `client.lua` | markers + MarkerHit + hint "[E] Reabastecer" |

### Funcionalidade

#### Portões
- `canOpenGate(player, gateID)` — verifica se o jogador pertence à facção dona do portão E tem rank mínimo (`min_rank_gate`)
- `gate_ids` é uma lista JSON de IDs de portões da tabela `gates`
- A integração com o sistema de portões (`oGate`) requer chamada ao export (ver secção Pendente)

#### Ponto de Munição
- Marker verde (cylinder) na posição configurada
- Hint "[E] Reabastecer" aparece quando a ≤6m
- Ao entrar no marker: valida facção, rank (`min_rank_ammo`) e cooldown (5 min padrão)
- Repõe itens conforme tipo de facção:

| Tipo | Itens |
|------|-------|
| 1 — Segurança | Colt-45 (37), M4 (28), Espingarda (34) |
| 2 — Saúde | Remédio (76), Kit primeiros socorros (81) |
| 3 — Legal | Colt-45 (37) |
| 4 — Gangue | AK-47 (27), Desert Eagle (30), Tec9/UZI (40) |
| 5 — Máfia | AK-47 (27), M4 (28), Rifle de precisão (38) |

- Cada item é dado com quantidade 100 via `exports.oInventory:giveItem`

#### Spawn de Veículos
- Markers azuis (arrow) em cada slot de veículo configurado
- Ao entrar: valida rank (`min_rank_veh`), verifica se já tem veículo ativo (`hq:activeFactionVeh`)
- Cria veículo com `createVehicle` nas coordenadas do slot com rotação
- Veículo destruído automaticamente ao jogador sair (`onPlayerQuit`)

### Exports de servidor
```lua
exports.oFactionHQ:canOpenGate(player, gateID)   -- boolean
exports.oFactionHQ:isInFactionHQ(player)         -- faction_id ou nil
exports.oFactionHQ:getHQByFaction(fid)           -- tabela HQ ou nil
```

### Comandos admin (nível 6+)
```
/hqsetup <faction_id>          → cria entrada HQ na DB para a facção
/hqgate <faction_id> <gate_id> → associa portão DB à HQ
/hqammo                        → define ponto de munição na posição atual do admin
/hqveh <faction_id> <model_id> → adiciona slot de veículo na posição atual do admin
```

### Tabela DB
```sql
CREATE TABLE faction_hq (
    id INT AUTO_INCREMENT PRIMARY KEY,
    faction_id INT NOT NULL UNIQUE,
    gate_ids TEXT DEFAULT '[]',
    ammo_x FLOAT DEFAULT 0, ammo_y FLOAT DEFAULT 0, ammo_z FLOAT DEFAULT 0,
    ammo_dim INT DEFAULT 0, ammo_int INT DEFAULT 0,
    veh_spawns TEXT DEFAULT '[]',
    min_rank_gate INT DEFAULT 1,
    min_rank_ammo INT DEFAULT 1,
    min_rank_veh INT DEFAULT 1,
    is_active TINYINT DEFAULT 1
);
```

---

## Infraestrutura de suporte

### Symlinks criados
```bash
resources/oFactionScripts → vila-do-ipiranga-rp/oFactionScripts/
resources/oWanted         → vila-do-ipiranga-rp/oWanted/
resources/oTerritory      → vila-do-ipiranga-rp/oTerritory/
resources/oFactionHQ      → vila-do-ipiranga-rp/oFactionHQ/
```

### Posição no `starter_manifest.lua`
```lua
"oFactionScripts",   -- #175
"oWanted",           -- #176  ← novo
"oTerritory",        -- #177  ← novo
"oFactionHQ",        -- #178  ← novo
"oInteraction",      -- #179
```

### ACL
Nenhuma entrada manual necessária — o grupo `Everyone` já tem `resource.*` wildcard.

### Bugs corrigidos durante a sessão
| Ficheiro | Bug | Fix |
|----------|-----|-----|
| `oTerritory/server.lua` | `not x == 0` (precedência) | `(x or 0) ~= 0` |
| `oTerritory/server.lua` | `goto`/`::continue::` (Lua 5.1 incompatível) | Extraído para `tickTerritory()` local |
| `oAdmin/hub/c_adminHub.lua` (substituído por `hub/v2/`) | 12px overlap entre hint bar e faixa de campos | Layout v2 modular (`c_layout.lua` / `c_views.lua`) |

---

## Pendente — Configuração in-game

### Obrigatório antes de usar em produção

| # | Ação | Como | Quem |
|---|------|------|------|
| 1 | Configurar HQ de cada facção | `/hqsetup <faction_id>` para cada facção ativa | Admin nível 6 |
| 2 | Definir ponto de munição | Admin vai à posição, `/hqammo` | Admin nível 6 |
| 3 | Adicionar portões | `/hqgate <faction_id> <gate_db_id>` | Admin nível 6 |
| 4 | Adicionar spawns de veículos | Admin vai à posição, `/hqveh <faction_id> <model>` | Admin nível 6 |
| 5 | Integrar `canOpenGate` no `oGate` | Chamar `exports.oFactionHQ:canOpenGate(player, gateID)` antes de abrir portão | Programador |
| 6 | Integrar `addCrime` no `oDeath` | Quando criminal morto por polícia → `exports.oWanted:addCrime(criminal, "homicidio")` | Programador |

### Stubs a implementar (oFactionScripts)
Estas funções retornam "em desenvolvimento" e precisam de lógica real:
`getStingerFromVeh`, `getSpeedcamFromVehicle`, `showRBSPanel`, `pickUpRBS`, `connectHose`, `connectHoseToVeh`, `unConnectHoseFromVeh`, `unConnectHose`, `attachDollyToPlayer`, `pickupDrum`, `takeDownDrum`, `pickupFuelDrum`, `takeDownFuelDrum`

### Verificações in-game recomendadas
- [ ] Verificar que `oDashboard:getPlayerRankInFaction(fid, player)` retorna o rank correto para a estrutura de dados das facções existentes
- [ ] Testar algemas com agente e civil (rank, item 77, distância)
- [ ] Testar ponto de munição (cooldown 5 min reset entre tentativas)
- [ ] Verificar income territorial — depositar no banco correto (precisar de `faction_id` válido na DB)
- [ ] Testar captura de território com 2+ jogadores da mesma gangue
