# Ipiranga Roleplay

Este ficheiro na **raiz do repositório** existe para **Claude Code**, **Cursor** e outras ferramentas que procuram `CLAUDE.md` no directório de trabalho (equivalente a expor “todo o contexto” do projecto ao agente via ficheiro standard).

**Documentação canónica (editar aqui as regras completas):** [`docs/CLAUDE.md`](docs/CLAUDE.md)

---

## Leitura mínima por sessão

| Ficheiro | Nota |
|----------|------|
| [`docs/worklog/current-sprint.md`](docs/worklog/current-sprint.md) | Sprint / estado |
| [`docs/worklog/next-actions.md`](docs/worklog/next-actions.md) | Próximos passos |
| [`.cursor/context/current-sprint.md`](.cursor/context/current-sprint.md) | Contexto Cursor (espelho operacional) |
| [`.cursor/context/architecture.md`](.cursor/context/architecture.md) | Dependências e exports críticos |

**Regras Cursor adicionais:** [`.cursor/rules/project-rules.md`](.cursor/rules/project-rules.md) · [`.cursor/rules/security.md`](.cursor/rules/security.md) · [`.cursor/rules/translation.md`](.cursor/rules/translation.md)

---

## Resumo executivo (não substitui `docs/CLAUDE.md`)

- Não quebrar **exports** nem **nomes de eventos** sem migração coordenada.
- Handlers **cliente → servidor:** validar `source` como jogador (`isElement`, `getElementType`).
- **SQL** sempre parametrizado (`?`).
- **Schema DB** e mudanças destrutivas só com aprovação explícita.

→ **Detalhe, padrões de código e ordem de refatoração:** abrir [`docs/CLAUDE.md`](docs/CLAUDE.md).

---

## Pasta local `.ai/` (opcional, não versionada)

O [`.gitignore`](.gitignore) ignora `.ai/` e `.claude/`. Se quiseres notas só na tua máquina, cria por exemplo:

```
.ai/
  context.md          # resumo do que estás a fazer
  current-focus.md    # ficheiro actual
  next-actions.md     # espelho opcional de docs/worklog/next-actions.md
```

Nada disso entra no `git clone`; o repositório “oficial” continua a ser `docs/` + `.cursor/context/`.
