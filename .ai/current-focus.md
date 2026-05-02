---
type: ai-current-focus
updated: 2026-05-01
---

# Foco Atual

**Phase:** 2 — Localization, Security (continuação) e Modernização Incremental  
**Branch ativo:** `main`

## Phase 1 — CONCLUÍDA

| Commit | Trabalho |
|---|---|
| `f048d8e` | oAccount: saver[] removido, rate limiting, source validation |
| `3241215` | oAdmin: adminSerialsCache DB-driven, /reloadadminserials |
| `65e3dd4` | Infraestrutura: CLAUDE.md, .ai/, .cursor/, docs/ |
| `459f6be` | oCore: whitelistSerials removido, pcall fail-secure |

## Phase 2 Sprint A — CONCLUÍDA

| Commit | Trabalho |
|---|---|
| `27d54f5` | oAccount: tradução PT-BR completa + tropicalização (4 arquivos, 305 linhas) |

## Próximo foco

**TD-SEC-006** — Implementação do hashing de senhas com salt por usuário  
Decisão arquitetural já aprovada: SHA-256 server-side, `password_salt VARCHAR(32) NULL`, lazy migration.

**Próxima tradução:** oDashboard + [Interface] (HUD, nametag, radar)

Ver `.ai/next-actions.md` para backlog completo.
