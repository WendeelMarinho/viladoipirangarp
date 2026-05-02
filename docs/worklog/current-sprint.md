# Sprint Atual — Phase 2: Localização PT-BR

**Branch:** `main`  
**Início:** 2026-05-01  
**Status:** Sprint A concluída; Sprint B.2 (UI residual) concluída em 2026-05-01; **Sprint C (pré-auditoria)** documentada em 2026-05-02 (`docs/qa/pre-test-audit.md`).

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

## Próxima Sprint — TD-SEC-006 ou oDashboard

Ver `docs/worklog/next-actions.md` para prioridade atualizada.

---

## ECC — integração mínima no repositório (2026-05-02)

Integração **aditiva** (modo mínimo): comandos e agentes com prefixo `ecc-`, memória `.cursor/memory/project-state.md`, `AGENTS.md` na raiz, documentação em `docs/cursor/ecc-integration.md`. **Sem** `hooks.json`, sem MCP, sem substituir `.cursor/rules/` nem `docs/CLAUDE.md`. Detalhe: `docs/cursor/ecc-integration.md`.

---

## Sprint C — pré-auditoria pré-teste (CONCLUÍDA em 2026-05-02)

- **Entregável:** `docs/qa/pre-test-audit.md` (grep HU first-party, categorização, integridade TD-SEC/login/`_OriginalRP`, sintaxe Lua amostrada).  
- **Decisão:** **GO condicional** para QA local nas áreas Sprint A/B/TD-SEC; **NO-GO** para ship com UI PT-BR global sem nova fase de tradução.  
- **Contexto Cursor:** `.cursor/context/current-sprint.md` e `.cursor/memory/project-state.md` atualizados.
