---
description: Lembrete de workflow Lua/MTA e validações obrigatórias (ECC mínimo)
---

# ecc-workflow — workflow IpirangaRP

## Ao editar handlers remotos

- `local player = source`  
- `if not isElement(player) or getElementType(player) ~= "player" then return end`  
- Validar inputs (limites, `tonumber`, comprimento de strings).

## SQL

- Apenas queries **parametrizadas** (`?` com `dbQuery` / `dbExec`).

## Tradução

- Ver `.cursor/rules/translation.md`: só strings **ao jogador**; preservar eventos, exports, nomes de recursos.

## Não tocar (sem coordenação)

- Anticheat, `triggerHack`, salt/hashing `_OriginalRP`, nomes de eventos/exports.
