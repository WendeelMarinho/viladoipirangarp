# Ipiranga Roleplay — CLAUDE.md

## Projeto

Servidor MTA:SA de roleplay premium brasileiro, baseado no OriginalRoleplay (húngaro, 2019–2023).

**Stack:** MTA:SA + Lua + MySQL  
**Target:** Lançamento como servidor RP premium no Brasil

---

## Leitura Obrigatória no Início de Cada Sessão

```
.ai/context.md
.ai/current-focus.md
.ai/next-actions.md
docs/worklog/current-sprint.md
```

## Escrita Obrigatória no Final de Cada Sessão

```
docs/worklog/current-sprint.md
docs/worklog/next-actions.md
.ai/current-focus.md
.ai/next-actions.md
.ai/known-issues.md
```

---

## Regras Não-Negociáveis

- Nunca quebrar exports ou nomes de eventos
- Nunca modificar schema do banco sem aprovação explícita
- Nunca reescrever módulos estáveis por completo — refatoração incremental
- Nunca commitar sem gerar a mensagem de commit completa
- Sempre usar `source` em handlers de eventos cliente→servidor
- Sempre parametrizar queries SQL
- Sempre validar `isElement(source)` e `getElementType(source) == "player"` nos handlers

---

## Padrão de Segurança para Event Handlers

```lua
addEvent("nomeDoEvento", true)
addEventHandler("nomeDoEvento", getRootElement(), function(arg1, arg2)
    local player = source
    if not isElement(player) or getElementType(player) ~= "player" then return end
    -- lógica segura aqui
end)
```

---

## Ordem de Refatoração Aprovada

1. oAccount ✅ (security hardening concluído)
2. oAdmin 🔄 (serial migration em andamento)
3. oMysql
4. oInventory
5. oVehicle
6. oPhone

---

## Nomenclatura de Branches

- `security/<resource>-<topico>`
- `refactor/<resource>`
- `performance/<resource>`
- `translation/<resource>`
- `docs/<topico>`
