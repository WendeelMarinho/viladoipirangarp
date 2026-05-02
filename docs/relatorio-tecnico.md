# Relatório Técnico — Ipiranga Roleplay

**Data:** 2026-05-01  
**Versão:** 1.0  
**Escopo:** Tudo realizado desde o início do projeto de modernização

---

## 1. Contexto do Projeto

### 1.1 Origem

O Ipiranga Roleplay é um servidor **MTA:SA** (Multi Theft Auto: San Andreas) de roleplay premium brasileiro, construído sobre a base do **OriginalRoleplay** — servidor húngaro desenvolvido entre 2019 e 2023 e liberado com licença MIT em dezembro de 2024.

**Stack técnico:**
- Linguagem: Lua (MTA:SA scripting API)
- Banco de dados: MySQL (45 tabelas, schema em `orp_main.sql`)
- Assets: ~7.100 arquivos (PNG, DFF, TXD, COL, MP3, WAV, HLSL)
- MTA versão mínima requerida: 1.5.9

### 1.2 Dimensionamento do Repositório

| Métrica | Valor |
|---|---|
| Arquivos Lua | ~1.654 |
| Recursos MTA (meta.xml) | 402 |
| Tabelas MySQL | 45 |
| Strings traduzíveis (húngaro) | ~3.680 |
| Grupos de recursos | 11 grupos (`[Core]`, `[Carlos]`, `[Maps]`, `[Jobs]`, etc.) |

### 1.3 Objetivo

Transformar a base OriginalRoleplay em servidor RP premium brasileiro, adaptando idioma, segurança, arquitetura e conteúdo ao contexto nacional. Estratégia: **modernização incremental** — sem reescrita total, preservando a funcionalidade madura da base húngara.

---

## 2. Assessment Inicial (Fase de Diagnóstico)

### 2.1 Inventário de Sistemas

#### Grupo [Core] — Infraestrutura (20 recursos)

| Recurso | Função |
|---|---|
| oCore | Bootstrap, whitelist, player IDs, FPS lock |
| oMysql | Camada de abstração MySQL (dbConnect wrapper, singleton) |
| oAnticheat | Anti-trapaça e verificação de jogadores |
| oAdmin | Painel administrativo completo (~700+ linhas, 17 scripts) |
| oLogs | Logging persistente |
| oChat | Chat global e por proximidade |
| oBone | Sistema de dano por osso (bone damage) |
| oDx, oFont | Utilidades de desenho DX |
| oCompiler, oDevtools | Ferramentas de desenvolvimento |
| oLoading | Tela de carregamento |
| oVerify | Verificação via Discord |
| oSkinProtect, oAntiHook | Proteções client-side |

#### Grupo Raiz — Gameplay (68 recursos)

| Categoria | Recursos Principais |
|---|---|
| Conta e Personagem | oAccount, oIndex, oSync, oLvl |
| Interface | oDashboard, oNametag, oHud, [Interface] |
| Inventário | oInventory, oInteraction |
| Economia | oBank, oShop, oCarshop, oPayday |
| Veículos | oVehicle, oTuning, oPaintjobs, oTraffipax |
| Imóveis | oInteriors, oInteriorBuilding |
| Comunicação | oPhone, oSiren, oWalkietalkie |
| Facções | oCrips, oCartelHQ, oSheriffHQ, oBorder, oTambovHQ |
| Emprego | [Jobs] — 14 empregos modulares |
| Entretenimento | oMinigames, oDrugs, oCinema, oTreasureHunt |

#### Grupos Externos

| Grupo | Recursos | Descrição |
|---|---|---|
| [Carlos] | ~67 | Veículos, armas, casino, combustível, portas |
| [Maps] | 62 | Mapas de facções, empregos, carshops |
| [Jobs] | 14 | Empregos modulares |
| [Shaders] | 21 | Bloom, motion blur, FXAA, outros efeitos |
| [Interface] | 7 | HUD, radar, scoreboard, velocímetro |
| [Jack] | 5 | Negócios, SMS, roleta |
| [Dexter] | 15 | Animações, corridas, impressora |
| [paul] | 21 | Placas, caça, eventos esportivos, pets |
| [theMark] | 10 | DJ, oil business |
| [Old] | 28 | Sistemas legados arquivados |

### 2.2 Hierarquia de Dependências

```
oCore ─────────────────────────────── (Bootstrap)
  └── oMysql ────────────────────── (Banco de dados — singleton)
        └── oAccount ────────────── (Auth, personagem)
              ├── oAdmin ────────── (Permissões, comandos)
              │     └── oAnticheat  (Verificação de jogadores)
              └── [todos os recursos de gameplay]
                    ├── oInventory
                    ├── oVehicle
                    └── oPhone ...
```

**Regra:** Qualquer recurso de gameplay depende indiretamente de `oMysql → oAccount → personagem carregado`.

### 2.3 Modelo de Permissões (Estado Inicial)

```
Serial em adminserials (DB)  →  Developer (aclLogin=true)
accounts.admin >= 1          →  Admin regular
isPlayerInAdminDuty(player)  →  Em serviço admin
```

### 2.4 Findings de Segurança Críticos (Estado Inicial)

| ID | Arquivo | Problema | Severidade |
|---|---|---|---|
| SEC-001 | `oAccount/server.lua` L688 | `saver[]` armazenava `user..'-'..pass` em memória | CRÍTICA |
| SEC-002 | `oAccount/server.lua` handler `loginOnServer` | Sem rate limiting — brute-force irrestrito | CRÍTICA |
| SEC-003 | `oAdmin/g_admin.lua` L1–14 | 7 seriais de developer hardcoded no código | CRÍTICA |
| SEC-003b | `[Core]/oCore/server.lua` L5–24 | 10 seriais na whitelist hardcoded | CRÍTICA |
| SEC-004 | Múltiplos handlers | Source validation ausente/inconsistente | ALTA |
| SEC-005 | Múltiplos recursos | Queries SQL não-parametrizadas | ALTA |
| SEC-006 | `oAccount/server.lua` | Senhas sem hashing seguro (bcrypt/Argon2) | CRÍTICA |
| SEC-007 | `oAccount/server.lua` `kickFlooder` | Evento clienteado podia kickar qualquer player | ALTA |
| SEC-008 | `oAccount/server.lua` `passwordChange` | Sem gate — podia ser triggerado sem verificação | ALTA |

### 2.5 Avaliação de Estado da Base

| Dimensão | Score |
|---|---|
| Funcionalidade | 9/10 — base madura e completa |
| Segurança | 4/10 — múltiplos críticos no estado inicial |
| Manutenibilidade | 5/10 — modular mas padrões inconsistentes |
| Localização | 0/10 — 100% em húngaro |

---

## 3. Infraestrutura de Projeto (Criada)

Antes de qualquer alteração de código, foi estabelecida a infraestrutura de documentação e governança do projeto.

### 3.1 Arquivos Criados

#### docs/CLAUDE.md
Arquivo de contexto para o agente de IA. Define:
- Stack técnico e objetivo do projeto
- Regras não-negociáveis (nunca quebrar exports, nunca modificar schema sem aprovação, sempre usar `source`)
- Padrão obrigatório para event handlers e SQL queries
- Ordem de refatoração aprovada
- Nomenclatura de branches e commits

#### .ai/ — Contexto para IA

| Arquivo | Conteúdo |
|---|---|
| `context.md` | Identidade do projeto, stack, dimensionamento, fase atual |
| `roadmap.md` | Fases 1-3 com itens concluídos/pendentes |
| `decisions.md` | Decisões arquiteturais registradas (DEC-001 a DEC-004) |
| `known-issues.md` | Issues abertas e resolvidas com rastreabilidade |
| `current-focus.md` | Foco da sessão atual |
| `next-actions.md` | Fila de próximas ações |

#### .cursor/ — Contexto para Cursor IDE

| Arquivo | Conteúdo |
|---|---|
| `rules/project-rules.md` | Padrões de código Lua, nomenclatura, proibições |
| `rules/security.md` | Checklist de segurança para event handlers e SQL |
| `rules/translation.md` | Regras de tradução e glossário canônico húngaro → PT-BR |
| `context/architecture.md` | Hierarquia de dependências, exports críticos, element data |
| `context/current-sprint.md` | Estado do sprint atual |

#### docs/ — Documentação Técnica

| Arquivo | Conteúdo |
|---|---|
| `architecture/initial-assessment.md` | Assessment completo do repositório |
| `security/security-log.md` | Log de todas as alterações de segurança |
| `worklog/current-sprint.md` | Tracking do sprint |
| `worklog/next-actions.md` | Fila de próximas ações |

#### Documentos em docs/

| Arquivo | Conteúdo |
|---|---|
| `docs/prioritized-resource-list.md` | 78 recursos em 7 tiers de prioridade |
| `docs/technical-debt-report.md` | 23 itens de dívida técnica catalogados |
| `docs/translation-roadmap.md` | Roadmap de 16 semanas, ~3.680 strings, glossário |
| `docs/README.md` | Visão geral do projeto, instalação, segurança, roadmap |

### 3.2 Decisões Arquiteturais Registradas

| ID | Decisão |
|---|---|
| DEC-001 | Refatoração incremental — não reescrita total |
| DEC-002 | `source` como identidade canônica em todos os event handlers |
| DEC-003 | `adminSerialsCache` populado do banco como modelo de autorização |
| DEC-004 | Client-side developer check via `getElementData(player, "aclLogin")` |

---

## 4. Security Hardening Phase 1

### 4.1 oAccount — Authentication Hardening

**Arquivo:** `oAccount/server.lua` (1.073 linhas originais)  
**Commit:** `f048d8e — [security] oAccount: remove plaintext cache, add rate limiting, fix source validation`

#### 4.1.1 Remoção do saver[] (SEC-001)

**Código removido:**
```lua
-- REMOVIDO:
local saver = {}
local iin = 1
function saverUSE(user,pass)
    saver[iin] = user..'-'..pass
    iin = iin + 1
end
addEvent("saverUSE", true)
addEventHandler("saverUSE", root, saverUSE)
function listIT(playerSource)
    for k,v in pairs(saver) do outputChatBox(v,playerSource) end
end
addCommandHandler("listITme", listIT)
```

**Impacto da remoção:** Eliminação do vetor de comprometimento total de credenciais. O evento `saverUSE` (clienteado) permitia que qualquer cliente injetasse strings na tabela; `/listITme` expunha o conteúdo a qualquer jogador que executasse o comando.

#### 4.1.2 Rate Limiting no Login (SEC-002)

**Variáveis adicionadas:**
```lua
local loginAttempts = {}     -- [serial] = {count, firstFailTime}
local LOGIN_MAX_ATTEMPTS = 5
local LOGIN_COOLDOWN_MS  = 5 * 60 * 1000
local verifiedPasswordReset = {}
```

**Lógica implementada no handler `loginOnServer`:**
- A cada falha de login, `loginAttempts[serial].count` é incrementado
- Se `count >= 5` e `getTickCount() - firstFailTime < 300.000ms`, o login é bloqueado com mensagem exibindo segundos restantes
- Após o cooldown expirar, o contador é resetado
- Sucesso no login: `loginAttempts[serial] = nil`
- Disconnect: limpeza de `loginAttempts[serial]` em `onPlayerQuit`

#### 4.1.3 Source Validation Padronizada (SEC-004)

**Padrão aplicado em todos os 8 handlers de autenticação:**
```lua
addEventHandler("nomeEvento", getRootElement(), function(_, arg1, arg2)
    local player = source
    if not isElement(player) or getElementType(player) ~= "player" then return end
    -- lógica aqui
end)
```

**Handlers corrigidos:**
- `loginOnServer` — argumento `player` (spoofável) substituído por `source`
- `registerOnServer` — idem
- `createCharacterOnServer` — idem + bounds check em `availableStartPositions`
- `rememberCheck` — idem
- `rememberCheck2` — idem + `verifiedPasswordReset[player] = true`
- `passwordChange` — idem + gate `verifiedPasswordReset`
- `changeEmail` — idem + nil check em `userId`
- `spawnPlayerOnServer` — idem

#### 4.1.4 Remoção do kickFlooder (SEC-007)

O evento `kickFlooder` era clienteado e recebia um `player` element como argumento. Qualquer cliente podia kickar qualquer outro jogador enviando o element desejado. Evento removido completamente — o rate limiting server-side torna-o desnecessário.

#### 4.1.5 Gate em passwordChange (SEC-008)

**Problema:** `passwordChange` podia ser triggerado diretamente por qualquer cliente, sem necessidade de ter completado o fluxo de verificação de código.

**Solução:**
```lua
-- rememberCheck2 (quando código correto):
verifiedPasswordReset[player] = true

-- passwordChange:
if not verifiedPasswordReset[player] then return end
verifiedPasswordReset[player] = nil
-- continua com a troca de senha
```

#### 4.1.6 Correção de Bug Pré-existente em destroyCode

A função `destroyCode` referenciava a variável global `player` dentro de um callback de timer, onde `player` era `nil`. O parâmetro correto era `e`. Corrigido para `e` com guard `isElement(e)`.

#### 4.1.7 Limpeza no onPlayerQuit

Adicionada limpeza de todas as tabelas de sessão:
```lua
local serial = getPlayerSerial(source)
loginAttempts[serial]         = nil
verifiedPasswordReset[source] = nil
codeSpamTimers[source]        = nil
codeTimers[source]            = nil
codes[source]                 = nil
```

#### 4.1.8 Compatibilidade Preservada

- Exports intactos: `createBan`, `removeBan`, `setPlayerCharactersNameTable`, `getPlayerCharactersTable`, `getPlayerAccountsTable`
- Nomes de eventos idênticos
- Schema do banco inalterado
- Fluxo de login/registro/character create funcionalmente idêntico

---

### 4.2 oAdmin — Serial Migration

**Arquivos:** `oAdmin/g_admin.lua`, `oAdmin/g_commands.lua`, `oAdmin/s_admin.lua`  
**Commit:** `3241215 — [security] oAdmin: replace hardcoded serials with database-driven authorization`

#### 4.2.1 O Que Foi Removido

```lua
-- REMOVIDO de g_admin.lua:
local adminSerials = {
    ["<serial1>"] = "carlos",
    ["<serial2>"] = "aron",
    -- ... 7 entradas totais
}

-- REMOVIDO de s_admin.lua:
local highLevelAdmins = {
    {{"<serial1>"}},
    {{"<serial2>"}},
    -- ... duplicata dos mesmos seriais
}
```

#### 4.2.2 adminSerialsCache — Nova Arquitetura

**`oAdmin/g_admin.lua` — global compartilhado:**
```lua
-- Sempre vazio no cliente. Populado do banco no servidor.
adminSerialsCache = {}
```

**`oAdmin/s_admin.lua` — sequência de boot:**
```lua
local function loadAdminSerialsFromDB()
    dbQuery(function(qh)
        local result = dbPoll(qh, 0)
        if result then
            adminSerialsCache = {}
            for _, row in ipairs(result) do
                adminSerialsCache[row["serial"]] = row["name"]
            end
        end
        syncAdminACLGroup()
    end, conn, "SELECT serial, name FROM adminserials")
end

addEventHandler("onResourceStart", resourceRoot, function()
    loadAdminSerialsFromDB()
end)
```

**`syncAdminACLGroup()` — rebuild do grupo ACL após carga:**
```lua
local function syncAdminACLGroup()
    -- Remove todos os "user.*" do grupo Admin
    -- Re-adiciona apenas os que estão no cache
    -- Chama aclSave() + aclReload()
    -- Re-aplica developerJoin() em todos os players conectados
end
```

#### 4.2.3 Dual-Path Client/Server

Scripts em `g_admin.lua` são `type="shared"` — executam no cliente e no servidor. A solução usa dual-path:

```lua
function isPlayerDeveloper(player)
    if localPlayer then
        -- Cliente: verifica element data setado pelo servidor
        return getElementData(player, "aclLogin") == true
    end
    -- Servidor: verifica cache do banco
    return adminSerialsCache[getPlayerSerial(player)] ~= nil
end
```

O mesmo padrão foi aplicado em `getPlayerAdminLevel()` e `playerHasPermission()`.

#### 4.2.4 hasPermission() — isDev() Closure

Em `g_commands.lua`, a função `hasPermission()` foi atualizada com uma closure que isola o dual-path:

```lua
function hasPermission(element, permission)
    local function isDev()
        if localPlayer then
            return getElementData(element, "aclLogin") == true
        end
        return adminSerialsCache[getPlayerSerial(element)] ~= nil
    end
    -- ...
end
```

#### 4.2.5 setAdminLevel — Substituição do Loop

```lua
-- ANTES:
for k,v in ipairs(highLevelAdmins) do
    if v[1] == serial then volt = true break end
end

-- DEPOIS:
local volt = adminSerialsCache[serial] ~= nil
```

Complexidade reduzida de O(n) para O(1).

#### 4.2.6 Comando /reloadadminserials

```lua
addCommandHandler("reloadadminserials", function(player, cmd)
    if getElementData(player, "aclLogin") then
        loadAdminSerialsFromDB()
        outputChatBox("[Admin]: Seriais de administrador recarregados.", player, r, g, b, true)
    end
end)
```

Permite atualizar a lista de seriais autorizados sem reiniciar o servidor.

#### 4.2.7 Comportamento de Falha

Se o banco de dados não responder ao carregar `adminSerialsCache`:
- Cache permanece vazio
- Zero developers autorizados
- Falha segura (fail-secure) — nunca autoriza por padrão

#### 4.2.8 Compatibilidade Preservada

- Schema inalterado: `adminserials` já existia com 43 entradas
- Todos os exports preservados: `isPlayerDeveloper`, `isPlayerInAdminDuty`, `getPlayerAdminLevel`, `hasPermission`, `getAdminPrefix`, `getAdminColor`
- Assinaturas de função idênticas

---

### 4.3 oCore — Whitelist Migration

**Arquivos:** `[Core]/oCore/server.lua`, `oAdmin/g_admin.lua`, `oAdmin/s_admin.lua`, `oAdmin/meta.xml`  
**Commit:** `459f6be — [security] oCore: replace hardcoded whitelist with database-driven serial check`

#### 4.3.1 O Que Foi Removido

```lua
-- REMOVIDO de [Core]/oCore/server.lua (linhas 5–24):
local whitelistSerials = {
    ["52E602241DC69E45929DF7CA9DCDDE54"] = true, --carlos
    ["E2582905A1146DE0D09B6C6C406772B2"] = true, --aron
    ["A106718E8295717F198A146B8EC62DB3"] = true, --carlos laptop
    ["CEA522BAC3269175C7A200BBD3EA04F0"] = true, --costa
    ["FCF1E89E7894C8C58287D9B121B978B2"] = true, --kondor
    ["3C4EDBBC959CD9DBFF7E4E35F46B94B2"] = true, --paul
    ["10D1C517DCD4E19401F635E6DB9D93F4"] = true, --paul laptop
    ["659E685D624B685B93585B2EE40820A2"] = true, --patrik
    ["FADD74F89263F9BEE73931EDAFB178A1"] = true, --daniel
    ["A51AEA488C429FDF52385CC085F80134"] = true, --keichii
    -- TESZTEREK + ADMINOK (vazio)
}
```

#### 4.3.2 onPlayerConnect — Nova Lógica

```lua
addEventHandler("onPlayerConnect", getRootElement(), function(playerName, _, _, playerSerial)
    if blacklistSerials[playerSerial] then
        cancelEvent(true)
    end

    if not whitelistEnabled then return end
    local ok, isDev = pcall(function()
        return exports.oAdmin:isSerialDeveloper(playerSerial)
    end)
    if not (ok and isDev) then
        cancelEvent(true, "Jelenleg fejlesztés alatt...")
        -- notifica developers conectados + adiciona a pendingSerials
    end
end)
```

O `pcall` garante comportamento fail-secure: se oAdmin não estiver disponível, o jogador é bloqueado.

#### 4.3.3 /acceptserial — Persistência no Banco

```lua
-- ANTES:
whitelistSerials[(pendingSerials[tonumber(id)][2])] = true

-- DEPOIS:
exports.oAdmin:addWhitelistedSerial(entry[2], entry[1])
```

O novo fluxo persiste o serial no banco via `addWhitelistedSerial()`:
```lua
function addWhitelistedSerial(serial, name)
    if adminSerialsCache[serial] then return true end
    adminSerialsCache[serial] = name
    dbExec(conn, "INSERT INTO adminserials (serial, name) VALUES (?, ?)", serial, name)
    syncAdminACLGroup()
    return true
end
```

O serial aceito sobrevive a reinicializações do servidor.

#### 4.3.4 Novos Exports em oAdmin

| Função | Tipo | Descrição |
|---|---|---|
| `isSerialDeveloper(serial)` | server | Verifica serial diretamente no cache sem exigir player element |
| `addWhitelistedSerial(serial, name)` | server | Insere serial no banco e atualiza cache em runtime |

Ambos declarados em `oAdmin/meta.xml`.

#### 4.3.5 O Que Permaneceu

`blacklistSerials` foi mantido em oCore com suas 2 entradas. É um mecanismo diferente (ban temporário hardcoded), de escopo diferente da whitelist de desenvolvimento. A migração para o sistema de bans do `oAccount` é uma tarefa futura.

---

## 5. Estado Atual

### 5.1 Git Log

```
459f6be  [security] oCore: replace hardcoded whitelist with database-driven serial check
65e3dd4  [docs] infrastructure: add project context files, security log, and Cursor rules
3241215  [security] oAdmin: replace hardcoded serials with database-driven authorization
f048d8e  [security] oAccount: remove plaintext cache, add rate limiting, fix source validation
01b5025  OriginalRoleplay  (base original)
```

### 5.2 Issues de Segurança — Status

| ID | Problema | Status | Commit |
|---|---|---|---|
| SEC-001 | saver[] plaintext cache | **RESOLVIDO** | f048d8e |
| SEC-002 | Sem rate limiting no login | **RESOLVIDO** | f048d8e |
| SEC-003 | Admin serials hardcoded (oAdmin) | **RESOLVIDO** | 3241215 |
| SEC-003b | Whitelist hardcoded (oCore) | **RESOLVIDO** | 459f6be |
| SEC-004 | Source validation ausente | **RESOLVIDO** em oAccount | f048d8e |
| SEC-005 | SQL não-parametrizado | **ABERTO** — auditoria global pendente | — |
| SEC-006 | Senhas sem hashing seguro | **ABERTO** — bloqueante de produção | — |
| SEC-007 | kickFlooder event | **RESOLVIDO** | f048d8e |
| SEC-008 | passwordChange sem gate | **RESOLVIDO** | f048d8e |

### 5.3 Issues Abertas (Bloqueantes de Produção)

#### TD-SEC-006 — Senhas sem hashing adequado
- **Problema:** Coluna `accounts.password` armazena senhas sem algoritmo de hash seguro (bcrypt/Argon2). Qualquer vazamento de banco expõe todas as senhas em plaintext.
- **Impacto:** CRÍTICO para lançamento
- **Solução requerida:** Migração de schema + hash de todas as senhas existentes
- **Estado:** Pendente de planejamento detalhado — próxima sprint de segurança

#### TD-ARCH-002 — Element data como modelo de sessão
- **Problema:** Estado crítico (`user:loggedin`, `user:admin`, `char:id`) em element data, que é sincronizado para todos os clientes por padrão no MTA:SA.
- **Impacto:** Exposição de dados de sessão para todos os peers
- **Estado:** Longo prazo — requer redesign da camada de sessão

#### TD-SEC-005 — SQL não-parametrizado (escopo global)
- **Problema:** Queries sem parametrização identificadas em múltiplos recursos
- **Estado:** Auditoria global pendente

### 5.4 Arquivos Modificados por Sprint

#### Security Hardening — oAccount
- `oAccount/server.lua` — 107 linhas modificadas (+70 / -37)

#### Security Hardening — oAdmin
- `oAdmin/g_admin.lua` — reescrito com adminSerialsCache e dual-path
- `oAdmin/g_commands.lua` — hasPermission() com isDev() closure
- `oAdmin/s_admin.lua` — loadAdminSerialsFromDB, syncAdminACLGroup, reloadadminserials

#### Security Hardening — oCore
- `[Core]/oCore/server.lua` — whitelist migrada para DB-driven (+pcall)
- `oAdmin/g_admin.lua` — isSerialDeveloper() adicionado
- `oAdmin/s_admin.lua` — addWhitelistedSerial() adicionado
- `oAdmin/meta.xml` — 2 novos exports declarados

#### Infraestrutura (criados do zero)
- `docs/CLAUDE.md`
- `.ai/context.md`, `.ai/roadmap.md`, `.ai/decisions.md`, `.ai/known-issues.md`, `.ai/current-focus.md`, `.ai/next-actions.md` *(pasta `.ai/` ignorada pelo git — apenas local opcional)*
- `.cursor/rules/project-rules.md`, `.cursor/rules/security.md`, `.cursor/rules/translation.md`
- `.cursor/context/architecture.md`, `.cursor/context/current-sprint.md`
- `docs/architecture/initial-assessment.md`
- `docs/security/security-log.md`
- `docs/worklog/current-sprint.md`, `docs/worklog/next-actions.md`
- `docs/prioritized-resource-list.md`, `docs/technical-debt-report.md`, `docs/translation-roadmap.md`

---

## 6. Arquitetura de Autorização — Estado Atual

```
onPlayerConnect (oCore)
  └── exports.oAdmin:isSerialDeveloper(serial)  ← via pcall (fail-secure)
        └── adminSerialsCache[serial] ~= nil

developerJoin() (oAdmin/s_admin.lua)
  └── adminSerialsCache[getPlayerSerial(player)]
        ├── SIM → setElementData(player, "aclLogin", true) + ACL group
        └── NÃO → setElementData(player, "aclLogin", nil)

isPlayerDeveloper(player) (oAdmin/g_admin.lua — shared)
  ├── [servidor] adminSerialsCache[getPlayerSerial(player)] ~= nil
  └── [cliente]  getElementData(player, "aclLogin") == true

adminserials (MySQL) ← fonte de verdade
  └── loadAdminSerialsFromDB() → adminSerialsCache
        └── syncAdminACLGroup() → ACL group "Admin"
```

---

## 7. Próximas Ações

### Imediato (antes do primeiro teste em servidor)

1. **Popular `adminserials`** com os seriais do time Ipiranga RP (substituir as 43 entradas húngaras)
2. **Testar fluxo de developer** — login, `aclLogin`, comandos admin
3. **Verificar `/reloadadminserials`** e `/acceptserial` em runtime

### Sprint Seguinte — TD-SEC-006

Planejamento e execução da migração de senhas:
1. Definir algoritmo de hash (bcrypt via biblioteca Lua ou hash SHA-256 com salt por conta)
2. Alterar schema: `accounts.password` → campo de hash + campo de salt separado
3. Migrar senhas existentes (rehash na próxima autenticação bem-sucedida)
4. Atualizar handlers `loginOnServer` e `registerOnServer`

### Médio Prazo

- Auditoria global de source validation (todos os 400+ recursos)
- Auditoria de SQL parameterization
- Migrar `blacklistSerials` de oCore para o sistema de bans do oAccount
- Phase 2: Refatoração de oInventory e oVehicle

### Longo Prazo

- Phase 3: Localização PT-BR (~3.680 strings, 16 semanas estimadas)
- Redesign da camada de sessão (TD-ARCH-002)
- Normalização de schema (TD-ARCH-001 — dados JSON em VARCHAR)
