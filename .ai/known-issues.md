---
type: ai-known-issues
updated: 2026-05-01
---

# Issues Conhecidas

## ABERTO — Senhas sem hashing (TD-SEC-006)
- Senhas armazenadas em plaintext no banco (coluna `accounts.password`)
- Impacto: alto — se o banco vazar, todas as senhas são legíveis
- Bloqueante: SIM para lançamento em produção
- Solução requerida: migração de schema + hash de todas as senhas existentes
- Estado: pendente de planejamento detalhado

## RESOLVIDO — Whitelist hardcoded no oCore
- Data resolução: 2026-05-01
- Branch: security/oCore-whitelist-migration
- `[Core]/oCore/server.lua`: whitelistSerials removido, substituído por exports.oAdmin:isSerialDeveloper()
- /acceptserial agora persiste via exports.oAdmin:addWhitelistedSerial() no banco

## ABERTO — Element data como modelo de sessão (TD-ARCH-002)
- Estado crítico (loggedin, admin level, char id) em element data
- Element data é sincroni zado para todos os clientes por padrão
- Longo prazo: redesign da camada de sessão

## RESOLVIDO — saver[] plaintext (oAccount)
- Data resolução: 2026-05-01
- Branch: security/oAccount-auth-hardening

## RESOLVIDO — adminSerials hardcoded (oAdmin)
- Data resolução: 2026-05-01
- Branch: security/oAdmin-serial-migration
