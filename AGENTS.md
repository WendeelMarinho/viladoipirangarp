# Ipiranga Roleplay — agentes e contexto

Este repositório usa **fluxo próprio IpirangaRP** (`docs/CLAUDE.md`, `.cursor/rules/`, `.cursor/context/`, `docs/worklog/`).  
**Everything Claude Code (ECC)** está integrado em **modo mínimo** apenas como **camada aditiva** — ver `docs/cursor/ecc-integration.md`.

## Leitura obrigatória (mantenedor)

1. [`docs/CLAUDE.md`](docs/CLAUDE.md) — regras canónicas do projecto  
2. [`CLAUDE.md`](CLAUDE.md) — entrada na raiz (checklist + links)  
3. [`.cursor/context/current-sprint.md`](.cursor/context/current-sprint.md) — sprint operacional  
4. [`.cursor/context/architecture.md`](.cursor/context/architecture.md) — dependências e exports críticos  
5. [`.cursor/memory/project-state.md`](.cursor/memory/project-state.md) — estado do projecto (memória local ECC)

## Agentes ECC (opcionais, prefixo `ecc-`)

| Ficheiro | Uso |
|----------|-----|
| [`.cursor/agents/ecc-documentation-helper.md`](.cursor/agents/ecc-documentation-helper.md) | Alinhar mudanças a `docs/`, worklog e contexto sem alterar regras de segurança. |
| [`.cursor/agents/ecc-workflow-helper.md`](.cursor/agents/ecc-workflow-helper.md) | Lembrar stack **Lua 5.1 / MTA:SA**, validação de `source`, SQL parametrizado. |

**Não** substituem as regras em `.cursor/rules/`; reforçam o workflow Ipiranga.

## Comandos ECC (opcionais)

Ver [`.cursor/commands/`](.cursor/commands/) — ficheiros `ecc-*.md` (comandos de contexto, workflow, memória, documentação).
