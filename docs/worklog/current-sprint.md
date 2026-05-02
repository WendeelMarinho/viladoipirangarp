# Sprint Atual — Security Hardening

**Branch:** `security/oAccount-auth-hardening`  
**Início:** 2026-05-01  
**Status:** Em progresso

---

## Objetivo

Hardening de segurança do recurso `oAccount` — os três bloqueantes críticos de lançamento.

---

## Tarefas

| # | Tarefa | Status |
|---|---|---|
| 1 | Remover `saver[]` / `saverUSE` / `listITme` | ✅ Concluído |
| 2 | Implementar rate limiting no login | ✅ Concluído |
| 3 | Padronizar `source` validation em todos os handlers | ✅ Concluído |
| 4 | Remover `kickFlooder` (permite cliente kickar terceiros) | ✅ Concluído |
| 5 | Corrigir bug `destroyCode` (variável `player` nil no escopo) | ✅ Concluído |
| 6 | Gate de verificação em `passwordChange` | ✅ Concluído |
| 7 | Bounds check em `availableStartPositions` | ✅ Concluído |
| 8 | Limpeza de estado no disconnect do jogador | ✅ Concluído |
| 9 | Documentação + commit message | 🔄 Em andamento |

---

## Arquivos Modificados

- `oAccount/server.lua` — hardening completo

---

## Vulnerabilidades Fechadas

| ID | Descrição |
|---|---|
| V1 | `saver[]` armazenando user/pass concatenados em memória |
| V2 | Evento `saverUSE` aberto a qualquer cliente |
| V3 | Comando `/listITme` expondo credenciais a qualquer jogador |
| V4 | Brute-force irrestrito no login |
| V5 | Argumento `player` controlado pelo cliente em todos os handlers |
| V6 | Nil panic em `availableStartPositions[startPosition]` |
| V7 | Evento `kickFlooder` permitindo kick remoto de qualquer player |
| V8 | Bug: `destroyCode` referenciando `player` nil |
| V9 | `passwordChange` sem verificação prévia do código de reset |
