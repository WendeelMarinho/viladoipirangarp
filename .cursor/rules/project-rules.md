# Ipiranga Roleplay — Cursor Project Rules

## Linguagem e Stack
- Lua (MTA:SA)
- MySQL via exports.oMysql
- Modular resource architecture

## Padrões de Código

### Event Handlers (OBRIGATÓRIO)
```lua
-- SEMPRE usar source, NUNCA confiar em argumento player do cliente
addEvent("nomeEvento", true)
addEventHandler("nomeEvento", getRootElement(), function(arg1, arg2)
    local player = source
    if not isElement(player) or getElementType(player) ~= "player" then return end
    -- lógica aqui
end)
```

### SQL Queries (OBRIGATÓRIO)
```lua
-- SEMPRE parametrizado, NUNCA concatenação
dbExec(conn, "UPDATE tabela SET campo = ? WHERE id = ?", valor, id)
dbQuery(function(qh) ... end, conn, "SELECT * FROM tabela WHERE campo = ?", valor)
```

### Variáveis
- Usar `local` sempre que possível
- Evitar poluição do escopo global

## Nomenclatura
- Branches: `security/`, `refactor/`, `translation/`, `performance/`, `docs/`
- Commits: `[type] resource: summary`

## Proibições
- Nunca remover exports sem aprovação explícita
- Nunca renomear eventos sem approval
- Nunca modificar schema do banco sem autorização
- Nunca confiar em dados do cliente sem validação server-side
