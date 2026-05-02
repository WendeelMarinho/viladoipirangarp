# Architecture Context — Cursor

## Hierarquia de Dependências

```
oCore (bootstrap) → oMysql (DB) → oAccount (auth) → [tudo mais]
oAdmin (permissões) — depende de oAccount estar carregado
```

## Recursos Críticos

| Recurso | Caminho | Papel |
|---|---|---|
| oCore | `[Core]/oCore/` | Boot, FPS, player IDs |
| oMysql | `[Core]/oMysql/` | Conexão DB (singleton) |
| oAccount | `oAccount/` | Auth, personagem, save |
| oAdmin | `oAdmin/` | Permissões, comandos admin |
| oAnticheat | `[Core]/oAnticheat/` | Verificação de jogadores |
| oInventory | `oInventory/` | Sistema de items |
| oVehicle | `oVehicle/` | Veículos |

## Modelo de Permissões

```
Serial em adminserials (DB) → Developer (aclLogin=true)
accounts.admin >= 1         → Admin regular
isPlayerInAdminDuty()       → Em serviço admin
```

## Padrão de DB Connection

```lua
local conn = exports.oMysql:getDBConnection()
-- conn é um objeto de conexão reutilizável
-- NÃO criar novas conexões por recurso
```

## Estado de Sessão (Element Data)

- `user:loggedin` — boolean, jogador autenticado
- `user:id` — account ID no banco
- `user:admin` — nível de admin (0 = jogador)
- `char:id` — character ID no banco
- `char:money` — dinheiro atual
- `aclLogin` — true se developer serial (setado pelo oAdmin)

## Exports Críticos (NÃO ALTERAR NOMES)

**oAdmin:**
- `isPlayerDeveloper(player)`
- `isPlayerInAdminDuty(player)`
- `getPlayerAdminLevel(player)`
- `hasPermission(element, permission)`
- `getAdminPrefix(rankNum)`
- `getAdminColor(rankNum)`

**oAccount:**
- `createBan(username, userID, serial, admin, year, month, day, hour, min, sec, reason)`
- `removeBan(id)`
- `getPlayerAccountsTable(player, id)`
- `getPlayerCharactersTable(player, id)`
- `setPlayerCharactersNameTable(player, id, newName)`
