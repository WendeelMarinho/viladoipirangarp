---
type: cursor-context
updated: 2026-05-01
---

# Sprint Atual — Cursor Context

## Sprint: Security Hardening Phase 1
**Branch:** `security/oAdmin-serial-migration` (concluída), `security/oAccount-auth-hardening` (concluída)
**Status:** Concluída — aguardando commit e testes em servidor dev

## O que foi feito nesta sprint

### oAccount — Auth Hardening
- Removido `saver[]` (cache de senhas em plaintext)
- Adicionado rate limiting: 5 tentativas / 5 min por serial
- Corrigido source spoofing em todos os event handlers de auth
- Gate `verifiedPasswordReset` para evitar bypass de troca de senha

### oAdmin — Serial Migration
- Removida tabela `adminSerials` hardcoded (7 seriais)
- Removida `highLevelAdmins` hardcoded
- Implementado `adminSerialsCache` populado do banco (`adminserials`)
- `loadAdminSerialsFromDB()` + `syncAdminACLGroup()` no boot
- `developerJoin()` agora usa o cache
- `/reloadadminserials` para reload em runtime sem restart

### oCore — Whitelist Migration
- Removida tabela `whitelistSerials` hardcoded (10 seriais)
- `onPlayerConnect` agora usa `exports.oAdmin:isSerialDeveloper(playerSerial)` com pcall
- `/acceptserial` agora persiste via `exports.oAdmin:addWhitelistedSerial()` no banco
- Novos exports em oAdmin: `isSerialDeveloper` (server), `addWhitelistedSerial` (server)
- blacklistSerials mantido (2 entradas, tratado como banning temporário)

## Próximas ações imediatas

1. Popular tabela `adminserials` com seriais dos admins do Ipiranga RP
2. Testar login de developer em servidor de desenvolvimento
3. Verificar `/reloadadminserials` e `/acceptserial` em runtime
4. Planejamento: migração de hash de senhas (TD-SEC-006)

## Arquivos modificados nesta sprint

- `oAccount/server.lua` — hardening completo
- `oAdmin/g_admin.lua` — adminSerialsCache + isSerialDeveloper
- `oAdmin/g_commands.lua` — hasPermission() com isDev() closure
- `oAdmin/s_admin.lua` — loadAdminSerialsFromDB, syncAdminACLGroup, addWhitelistedSerial, reloadadminserials
- `oAdmin/meta.xml` — exports: isSerialDeveloper, addWhitelistedSerial
- `[Core]/oCore/server.lua` — whitelist migrada para DB-driven
