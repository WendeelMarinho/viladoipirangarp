# Security Rules — Cursor

## Verificações Obrigatórias em Todo Event Handler Cliente→Servidor

1. `local player = source` — usar source, não argumento
2. `if not isElement(player) or getElementType(player) ~= "player" then return end`
3. Validar todos os inputs numéricos com `tonumber()` e bounds check
4. Validar todos os inputs de string com length check
5. Nunca usar índices de array enviados pelo cliente sem validação

## SQL

- 100% parametrizado — sem concatenação de strings em queries
- Usar `dbExec` para INSERT/UPDATE/DELETE
- Usar `dbQuery` com callback para SELECT
- Sempre verificar `result` antes de iterar

## Permissões

- Verificar `getElementData(player, "user:admin")` no servidor
- Verificar `isPlayerInAdminDuty(player)` para comandos admin
- Verificar `exports.oAnticheat:checkPlayerVerifiedAdminStatus(player)` para ações de risco alto
- NUNCA confiar em dados de permissão enviados pelo cliente

## Developer Access

- Verificar `adminSerialsCache[getPlayerSerial(player)]` no servidor
- Verificar `getElementData(player, "aclLogin") == true` no cliente
- A tabela `adminserials` no banco é a fonte de verdade
- Usar `/reloadadminserials` para atualizar em runtime
