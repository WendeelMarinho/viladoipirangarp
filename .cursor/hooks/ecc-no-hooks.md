# ECC — hooks desactivados (modo mínimo IpirangaRP)

Neste repositório **não** existe `hooks.json` nem scripts de hook em runtime como parte da integração ECC mínima.

## Motivo

- Evitar automações intrusivas (shell, formatação forçada, bloqueios) que possam interferir com o fluxo **Lua / MTA** e com o trabalho no Cursor.  
- Manter **100% aditivo** face a `docs/CLAUDE.md` e `.cursor/rules/`.

## Se precisares de hooks no futuro

1. Revisar a documentação oficial [everything-claude-code](https://github.com/affaan-m/everything-claude-code) e o perfil desejado.  
2. Introduzir apenas ficheiros com prefixo **`ecc-`** ou um `hooks.json` **separado** avaliado em PR.  
3. Nunca sobrescrever configuração existente sem backup e revisão.
