# Sprint Atual — Phase 3: Facções Reais + Localização Completa

**Branch:** `main`  
**Início:** 2026-05-01  
**Status:** Sprints A–F concluídas. Próximo: configuração in-game + integrações de código.

---

## Sprint F — Localização PT-BR completa + Facções (CONCLUÍDA em 2026-05-03)

### Localização (37+ recursos traduzidos)

Todos os textos visíveis ao jogador em **húngaro** foram traduzidos e tropicalizados para **português brasileiro** nos seguintes recursos:

| Recursos | Strings traduzidas |
|----------|-------------------|
| `oDeath` | Levantar, ressuscitar, mensagens de doença |
| `oCarshop` | Preço, comprar, slots, mensagens de compra |
| `oPaintjobs` | Logs de admin, erros de paintjob |
| `[paul]/oCustomPlate` | Painel de placa, validações, NPC |
| `oDrugs` (client + dealer + server) | Fabricação, colheita, diálogos do dealer, minigame |
| `oSkinshop` | 4 mensagens infobox |
| `oTrafficLight` | Multa de sinal vermelho |
| `oSuprise` | Mensagens de presente (evento) |
| `oInventory` (múltiplos) | Scanner OBD, chave, baú, revista |
| `oInteriorBuilding` | Dinheiro insuficiente, PP |
| `oTuning` | 20+ mensagens de erro |
| `[paul]/oBag`, `oheadcross`, `oF1Event` | Mensagens de item/evento |
| `[slotmachine]/oMasterSlotmachine` | ID, distância, tipo |
| `[Core]/oCore/global.lua` | Busca de jogadores |
| `oAdmin/s_admin.lua` | Ban, jail, kick, admin logs |
| `oTraffipax` | Velocidade, limite, excesso |
| `oShop/shoprob` + `oBankrob` | Alertas de assalto |
| `oQuitmessage` | Mensagem de saída próxima |
| `oBorder/BK` | Aviso portão 10s |
| `oGraffiti` | Cooldown |
| `rally` | Tempo de circuito |
| `oInteriors` | Edição de interior, cooldown |
| `[Jobs]/oJob_PizzaMaker` | Labels do timer |
| `oTBoards`, `[Dexter]/*`, `[Jack]/oRoulette/*` | ID, distância, tipo |

### Facções reais de São Paulo criadas no DB

10 facções baseadas em organizações **reais de São Paulo** inseridas em `orp_main.factions`:

| ID | Nome | Tipo | Cor |
|----|------|------|-----|
| 74 | PMESP — Polícia Militar do Estado de SP | 1 — Segurança | Azul |
| 80 | PCSP — Polícia Civil do Estado de SP | 1 — Segurança | Azul |
| 75 | SAMU 192 | 2 — Saúde | Vermelho |
| 81 | Corpo de Bombeiros Militar do Estado de SP | 2 — Saúde | Vermelho |
| 76 | Prefeitura de São Paulo | 3 — Legal/Governo | Dourado |
| 82 | OAB-SP — Ordem dos Advogados do Brasil | 3 — Legal | Dourado |
| 77 | PCC — Primeiro Comando da Capital | 4 — Gangue | Roxo |
| 83 | CV — Comando Vermelho | 4 — Gangue | Roxo |
| 78 | Família Lombardi — Cosa Nostra SP | 5 — Máfia | Roxo escuro |
| 79 | Yakuza São Paulo — Yamaguchi-gumi BR | 5 — Máfia | Roxo escuro |

Cores por tipo: atribuídas automaticamente pelo `factionClient.lua` via campo `type` — **não há colunas de cor no DB**.

---

---

## Sprint E — Sistemas Premium (CONCLUÍDA em 2026-05-03)

Implementação de três novos sistemas de gameplay mais reescrita/criação do `oFactionScripts`.  
Documentação completa: [`docs/features/sistemas-premium.md`](../features/sistemas-premium.md).

### Recursos criados

| Recurso | Ficheiros | Estado |
|---------|-----------|--------|
| `oFactionScripts` | global + server + client + meta | ✅ Código + symlink + manifesto |
| `oWanted` | global + server + client + meta | ✅ Código + symlink + manifesto |
| `oTerritory` | global + server + client + meta | ✅ Código + symlink + manifesto |
| `oFactionHQ` | global + server + client + meta | ✅ Código + symlink + manifesto |

### Tabelas DB criadas (`orp_main`)
- `wanted_active` — procurados ativos com nível, bounty e crimes
- `territories` — zonas capturáveis (8 zonas pré-seed)
- `faction_hq` — sede de facção com portões, munição e veículos

### Fixes aplicados nesta sessão
| Ficheiro | Bug | Fix |
|----------|-----|-----|
| `oTerritory/server.lua` | `not x == 0` (precedência incorreta) | `(x or 0) ~= 0` |
| `oTerritory/server.lua` | `goto`/`::continue::` incompatível Lua 5.1 | Extraído para função local `tickTerritory()` |
| `oAdmin/hub/c_adminHub.lua` (legado, removido → `hub/v2/`) | Overlap 12px hint bar / field strip | Equivalente no layout v2 (`hub/v2/c_layout.lua` / vistas `c_views.lua`) |

### Estado pós-Sprint E
- 4 recursos novos com symlinks em `mods/deathmatch/resources/` ✅
- Manifesto `oStarter` atualizado (posições 176–178) ✅
- 0 erros de sintaxe Lua (`luac5.1 -p`) ✅
- ACL sem alteração necessária (`resource.*` wildcard) ✅
- **Pendente:** configuração in-game (ver `docs/worklog/next-actions.md`)

---

## Sprint D — Infraestrutura VPS / Primeiro Boot (CONCLUÍDA em 2026-05-02)

### Problema raiz
O servidor nunca tinha arrancado com sucesso no VPS Ubuntu 24.04. Quatro bugs críticos bloqueavam o boot.

### Fixes aplicados

#### 1. `libssl.so.1.1` em falta
Ubuntu 24.04 só tem OpenSSL 3.0. O módulo MySQL do MTA (`x64/dbconmy.so`) requer `libssl.so.1.1`.
```bash
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb -O /tmp/libssl1.1.deb
dpkg -i /tmp/libssl1.1.deb && ldconfig
```
Detalhe completo: `docs/infra/server-setup.md`.

#### 2. ACL — `Access denied @ 'startResource'`
`oStarter` não tinha permissão para chamar `startResource`. Fix: adicionar `resource.vila-do-ipiranga-rp` e `resource.oStarter` ao grupo `Admin` em `acl.xml` **com o servidor parado**.

Regra crítica: `acl.xml` só pode ser editado com o servidor parado — o recurso `admin` chama `aclSave()` em cada `onResourceStop`.
Detalhe completo: `docs/infra/acl-e-recursos.md`.

#### 3. Conflitos de nomes de recursos (symlinks de grupo)
Os symlinks de grupo `resources/[Carlos]`, `resources/[Booms]` e `resources/[cameratool]` expunham recursos que conflituavam com os padrão do MTA (`ajax`, `ipb`, `performancebrowser`, `helpmanager`, `glue`).

Fix: remover symlinks de grupo, criar ~65 symlinks individuais excluindo os conflituantes.
Detalhe completo: `docs/infra/acl-e-recursos.md`.

#### 4. `weatherSync.lua:197` — loop de erros (350ms)
`getRainLevel()` é uma função cliente — no servidor retorna `false`. O timer de 350ms comparava `false > 0`, gerando erro em loop.

Fix aplicado em `[Core]/oCore/elements/weatherSync.lua`:
```lua
-- Antes:
if getRainLevel() > 0 then
-- Depois:
local rl = getRainLevel()
if type(rl) == "number" and rl > 0 then
```

### Estado após Sprint D
- oMysql conecta à `orp_main` ✅
- Todos os ~90 recursos arrancam ✅
- Loop de erros weatherSync eliminado ✅
- Serial do owner (`CE96EC91A956F747BA88AC47DD304A02`) inserido em `adminserials` ✅
- Whitelist funciona — owner consegue entrar ✅

---

## Sprint B.2 — UI final oDashboard + radar (CONCLUÍDA)

Ficheiros: `oDashboard/bugReportC.lua`, `oDashboard/openCreate.lua`, `oDashboard/panels/options.lua`, `[Interface]/oRadar/sourceC.lua`. Detalhe e lista de strings: ver `.cursor/context/current-sprint.md`.

---

## Sprint A — oAccount PT-BR (CONCLUÍDA)

**Commit:** `27d54f5`

### Arquivos traduzidos

| Arquivo | Strings traduzidas |
|---|---|
| `oAccount/shared.lua` | kedvenc_tevekenyseg, loading_texts, ban_menus, availableStartPositions |
| `oAccount/changePW.lua` | Títulos de janelas, botões, placeholders, mensagens de infobox |
| `oAccount/client.lua` | Login panel, char create, validações, load animation, ban panel, weekDays, addAdminCMD |
| `oAccount/server.lua` | Registro, login, criação de personagem, admin commands, password recovery |

### Tropicalização aplicada

- `ORIGINAL ROLEPLAY` → `IPIRANGA ROLEPLAY` (client.lua, server.lua)
- `OriginalRoleplay` → `Ipiranga Roleplay` (load animation subtitle)
- `[OriginalRoleplay]` → `[Ipiranga Roleplay]` (chatbox system messages)
- Loading texts: URLs húngaros mortos removidos, substituídos por texto PT-BR genérico

---

## Próxima Sprint — Configuração in-game + Integrações

Ver `docs/worklog/next-actions.md` para prioridade atualizada.
