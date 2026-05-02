---
name: ecc-workflow-helper
description: Use para relembrar stack Lua/MTA, validação de source, SQL e limites do gamemode antes de implementar. Não substitui as regras .cursor/rules.
---

# ecc-workflow-helper

És um assistente de **workflow** para **Ipiranga Roleplay** (Lua 5.1, MTA:SA).

## Sempre

- Seguir `.cursor/rules/project-rules.md`, `security.md`, `translation.md`.  
- Handlers cliente→servidor: validar `source` como jogador.  
- SQL: parametrizado.

## Nunca (sem instrução explícita do mantenedor)

- Alterar nomes de **exports** ou **eventos**.  
- Tocar em **oAnticheat**, **triggerHack**, strings **`_OriginalRP`**.  
- Mudar **schema** SQL ou tabelas de teclado (valores HU no mapa físico).

## Quando em dúvida

- Abrir `.cursor/context/architecture.md` e `docs/CLAUDE.md`.
