# Sprint Atual — Phase 2: Localização PT-BR

**Branch:** `main`  
**Início:** 2026-05-01  
**Status:** Sprint A concluída; Sprint B.2 (UI residual) concluída em 2026-05-01; **Sprint C (pré-auditoria)** documentada em 2026-05-02 (`docs/qa/pre-test-audit.md`); **Sprint D (infraestrutura VPS)** concluída em 2026-05-02.

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

### Problemas pendentes (pós-Sprint D)

| Problema | Ficheiro | Causa |
|---------|----------|-------|
| `addAccount` / `logIn` negados para oAdmin | `oAdmin/s_admin.lua:102-105` | `resource.oAdmin` não está no grupo Admin do ACL |
| `aclSave` / `aclGroupAddObject` negados | `oAdmin/s_admin.lua:16-23` | Mesmo — falta `resource.oAdmin` no ACL Admin |
| `fetchRemote` negado (oCore) | `weatherSync.lua:153` | Falta permissão ACL para oCore |
| `fetchRemote` negado (oAnticheat) | `antiCheatS.lua:996,1015` | Falta permissão ACL para oAnticheat |
| Tabelas DB em falta (oDrugs, oMDC) | — | Schema não criado ainda |
| `oPlant`/`oPlaneCrash` inexistentes | `oStarter/server.lua:290-291` | Recursos não presentes no projeto |

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

## Próxima Sprint — Fix ACL oAdmin + QA login

Ver `docs/worklog/next-actions.md` para prioridade atualizada.
