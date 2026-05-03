# Regras Cursor — Fase 4 (Novos Sistemas)

## Antes de implementar qualquer feature desta fase

1. Ler `.cursor/context/novos-sistemas.md` completo
2. Ler `docs/features/roadmap-fase4.md` para a feature específica
3. Confirmar ordem: oTags → oChat3 → oWelcome → oRank → oCarTheft → oHeist

## Regras de código

- Todos os novos recursos seguem estrutura `global.lua` + `server.lua` + `client.lua` + `meta.xml`
- Validar `source` em TODOS os handlers server-side (ver padrão em `.cursor/context/novos-sistemas.md`)
- SQL sempre parametrizado: `dbQuery(conn, "... WHERE id=?", {valor})` — nunca concatenação
- Usar `exports.oMysql:getDBConnection()` — não criar nova conexão
- `luac5.1 -p <file>` antes de reportar como concluído
- Mensagens ao jogador: sempre PT-BR, sem húngaro, sem inglês

## Regras de UX

- Todos os painéis fecham com **Backspace** (padrão do servidor)
- Cursor: `showCursor(true/false)` par com cada painel
- Resolução base: `myX, myY = 1768, 992` — usar proporções relativas a `sx, sy`
- Usar fontes do servidor: `font:getFont("bebasneue", ...)` e `font:getFont("condensed", ...)`
- Cores primárias do servidor: variáveis globais `r, g, b` e `color` (string colorCode)

## Regras de integração

- oTags: SEMPRE usar `exports.oTags:getPlayerTag(player)` para ler a tag atual
- oRank: SEMPRE usar `exports.oRank:incrementStat(charId, statKey, amount)` para pontuar
- oWanted: usar `exports.oWanted:addCrime(player, "chave")` ao registar crimes
- oInventory: verificar `exports.oInventory:hasItem(player, id)` antes de consumir

## Regras de DB

- Criar tabelas com `CREATE TABLE IF NOT EXISTS`
- Usar `ADD COLUMN IF NOT EXISTS` para ALTER TABLE (MySQL 8 compatível)
- Primary keys: `INT AUTO_INCREMENT PRIMARY KEY`
- Timestamps: `TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
- JSON arrays: armazenar como `VARCHAR(N)` e usar `toJSON()` / `fromJSON()`

## Regras de segurança

- Verificar ownership antes de qualquer ação sobre veículo/item/propriedade
  ```lua
  if getElementData(vehicle, "veh:owner") ~= getElementData(player, "char:id") then return end
  ```
- Verificar nível admin antes de comandos privilegiados
  ```lua
  if getElementData(player, "user:admin") < nivelMinimo then return end
  ```
- Nunca confiar em valores de client para quantias económicas — recalcular no servidor

## Regras de performance

- Render loops (`onClientRender`): verificar `isElement` antes de iterar
- Timers de DB: mínimo 5000ms entre queries repetitivas
- Leaderboards: cache no servidor, não query por request de cliente
- `createElement` em client: sempre destruir com `destroyElement` ao fechar painel

## Adição ao oStarter

Ao criar cada recurso, adicionar linha ao `oStarter/starter_manifest.lua`:
```lua
{"oNomeRecurso", false, false},  -- na posição correta da ordem de dependências
```
E criar symlink em `mods/deathmatch/resources/`.
