# Security Log — Ipiranga Roleplay

---

## 2026-05-01 — oAccount Authentication Hardening

**Branch:** `security/oAccount-auth-hardening`  
**Arquivo:** `oAccount/server.lua`  
**Responsável:** Principal Security Engineer

### Vulnerabilidades Corrigidas

#### [CRÍTICA] V1-V3: Plaintext Password Cache Removido
- **Problema:** Tabela `saver[]` concatenava `username..'-'..password` e armazenava indefinidamente em memória. Evento `saverUSE` (clienteado) permitia qualquer cliente injetar strings. Comando `/listITme` expunha todo o conteúdo a qualquer jogador com acesso ao chat.
- **Linhas removidas:** 58 (`local saver = {}`), 685–699 (bloco completo `saverUSE/listIT`)
- **Impacto:** Comprometimento total de credenciais eliminado.

#### [CRÍTICA] V4: Rate Limiting no Login
- **Problema:** Handler `loginOnServer` sem qualquer proteção contra brute-force.
- **Solução implementada:**
  - Tabela `loginAttempts[serial]` rastreia falhas por serial de hardware
  - Limite: 5 tentativas falhas
  - Cooldown: 5 minutos desde a primeira falha (definido em `LOGIN_COOLDOWN_MS`)
  - Mensagem exibe segundos restantes ao jogador
  - Contador limpo no login bem-sucedido e no disconnect
- **Linhas adicionadas:** 60–64 (variáveis), 315–325 (check), 380–382 (incremento on fail), 370 (clear on success)

#### [ALTA] V5: Source Validation Padronizada
- **Problema:** Handlers de eventos clienteados usavam `player` (argumento enviado pelo cliente, spoofável) em vez de `source` (garantido pelo MTA como o player que enviou o pacote).
- **Handlers corrigidos:**
  - `loginOnServer` — `player` → `source`
  - `registerOnServer` — `player` → `source`
  - `createCharacterOnServer` — `player` → `source`
  - `rememberCheck` — `player` → `source`
  - `rememberCheck2` — `player` → `source`
  - `passwordChange` — `player` → `source`
  - `changeEmail` — `player` → `source`
  - `spawnPlayerOnServer` — `player` → `source`
- **Padrão aplicado:** `local player = source` + guard `if not isElement(player) or getElementType(player) ~= "player" then return end`

#### [ALTA] V6: Bounds Check em availableStartPositions
- **Problema:** `availableStartPositions[startPosition][3]` sem validação — cliente podia enviar índice fora do range causando nil panic.
- **Solução:** `if not availableStartPositions[startPosition] then return end` antes do unpack.

#### [ALTA] V7: Evento kickFlooder Removido
- **Problema:** Evento clienteado `kickFlooder` passava `player` como argumento — qualquer cliente podia kickar qualquer outro player enviando o elemento como argumento.
- **Solução:** Evento removido completamente. Rate limiting server-side torna-o desnecessário.

#### [ALTA] V9: Gate em passwordChange
- **Problema:** `passwordChange` podia ser triggerado diretamente sem ter passado pela verificação de código em `rememberCheck2`.
- **Solução:** Tabela `verifiedPasswordReset[player]` criada. `rememberCheck2` seta o gate quando código correto é enviado. `passwordChange` verifica e consome o gate. Limpeza no disconnect.

#### [MÉDIA] V8: Bug destroyCode Corrigido
- **Problema:** `destroyCode` referenciava variável global `player` (nil no escopo do timer), causando falha silenciosa ao exibir mensagem de expiração.
- **Solução:** Substituído `player` por `e` (parâmetro correto da função) com guard `isElement(e)`.

### Riscos Residuais

- Senhas ainda armazenadas sem hashing adequado no banco (TD-SEC-006) — requer migração planejada
- Admin serials hardcoded no oAdmin (TD-SEC-003) — **RESOLVIDO em 2026-05-01**
- oCore whitelist hardcoded — **RESOLVIDO em 2026-05-01**
- Element data como modelo de sessão (TD-ARCH-002) — longo prazo

### Compatibilidade

- Todos os exports preservados: `createBan`, `removeBan`, `setPlayerCharactersNameTable`, `getPlayerCharactersTable`, `getPlayerAccountsTable`
- Todos os eventos preservados com nomes idênticos
- Schema do banco de dados inalterado
- Fluxo de login/registro/character create funcionalmente idêntico

---

## 2026-05-01 — oAdmin Serial Migration

**Branch:** `security/oAdmin-serial-migration`  
**Arquivos:** `oAdmin/g_admin.lua`, `oAdmin/g_commands.lua`, `oAdmin/s_admin.lua`

### Vulnerabilidades Corrigidas

#### [CRÍTICA] Seriais hardcoded removidos do oAdmin
- **Problema:** `adminSerials` continha 7 seriais de developers em texto claro no código. `highLevelAdmins` continha os mesmos dados em formato diferente.
- **Solução:** `adminSerialsCache = {}` global populado async do banco via `loadAdminSerialsFromDB()`. Tabela `adminserials` no banco é a fonte de verdade.
- **Comportamento de falha:** Cache vazio = zero developers autorizados (fail-secure).

#### [ALTA] Dual-path client/server para verificação de serial
- `isPlayerDeveloper()` usa `aclLogin` element data no cliente, `adminSerialsCache` no servidor.
- `getPlayerAdminLevel()` e `playerHasPermission()` seguem o mesmo padrão.

#### Adicionado: `/reloadadminserials`
- Comando que recarrega a tabela do banco sem restart. Requer `aclLogin=true`.

### Compatibilidade
- Todos os exports preservados: `isPlayerDeveloper`, `isPlayerInAdminDuty`, `getPlayerAdminLevel`, `hasPermission`, `getAdminPrefix`, `getAdminColor`
- Schema do banco inalterado (`adminserials` já existia com 43 entradas)

---

## 2026-05-01 — oCore Whitelist Migration

**Branch:** `security/oCore-whitelist-migration`  
**Arquivos:** `[Core]/oCore/server.lua`, `oAdmin/g_admin.lua`, `oAdmin/s_admin.lua`, `oAdmin/meta.xml`

### Vulnerabilidades Corrigidas

#### [CRÍTICA] Whitelist hardcoded removida do oCore
- **Problema:** `whitelistSerials` continha 10 seriais de developers no código.
- **Solução:** `onPlayerConnect` chama `exports.oAdmin:isSerialDeveloper(playerSerial)` com `pcall` para fail-secure se oAdmin não estiver disponível.
- `/acceptserial` agora persiste via `exports.oAdmin:addWhitelistedSerial()` — INSERT em `adminserials` + update do cache em runtime.

### Novos exports (oAdmin)
- `isSerialDeveloper(serial)` — type="server"
- `addWhitelistedSerial(serial, name)` — type="server"

### Compatibilidade
- `blacklistSerials` mantido em oCore (2 entradas — banning temporário, escopo diferente)
- Comandos `/pendingserials`, `/acceptserial`, `/togwhitelist` preservados
- Export `setWhiteListEnable` preservado
