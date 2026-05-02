---
type: ai-current-focus
updated: 2026-05-01
---

# Foco Atual

**Branch:** `security/oAdmin-serial-migration`  
**Phase:** 1 — Security Hardening  
**Recurso:** oAdmin

## O que foi feito nesta sessão

- Migração de `adminSerials` hardcoded → `adminSerialsCache` (DB-backed)
- Remoção de `highLevelAdmins` hardcoded
- Adição de `loadAdminSerialsFromDB()` com callback assíncrono
- Adição de `syncAdminACLGroup()` executado após carregamento do cache
- `developerJoin()` agora usa `adminSerialsCache` diretamente
- `hasPermission()` (shared) usa dual-path: server → cache, client → element data
- `isPlayerDeveloper()`, `getPlayerAdminLevel()`, `playerHasPermission()` atualizados com dual-path
- Comando `/reloadadminserials` adicionado para gestão em runtime

## Arquivos modificados

- `oAdmin/g_admin.lua` — reescrito com adminSerialsCache
- `oAdmin/g_commands.lua` — hasPermission() atualizado
- `oAdmin/s_admin.lua` — DB loading, developerJoin, highLevelAdmins removido

## Estado: IMPLEMENTAÇÃO CONCLUÍDA, documentação em andamento
