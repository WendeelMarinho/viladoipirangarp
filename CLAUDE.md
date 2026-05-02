# Vale do Ipiranga RP — entrada `CLAUDE.md` (raiz pacote gamemode)

Este ficheiro existe para ferramentas (Claude Code, Cursor, outros) que procuram **`CLAUDE.md`** no directório raiz **do recurso**/trabalho.

**Políticas, obrigações e template de auditoria recurso‑a‑recurso:** [`docs/CLAUDE.md`](docs/CLAUDE.md) — este é o ficheiro canónico para seguir sempre.

---

## Base de conhecimento (rápido)

| | |
|--|--|
| Arquitectura | [`docs/architecture-overview.md`](docs/architecture-overview.md) |
| Mapa recursos / `oStarter` | [`docs/resource-map.md`](docs/resource-map.md) |
| Eventos cliente/servidor | [`docs/event-flow.md`](docs/event-flow.md) |
| Base de dados | [`docs/database-architecture.md`](docs/database-architecture.md) |
| Segurança | [`docs/security-audit.md`](docs/security-audit.md) · [`docs/security/security-log.md`](docs/security/security-log.md) |
| Performance | [`docs/performance-analysis.md`](docs/performance-analysis.md) |
| Deploy | [`docs/deployment-guide.md`](docs/deployment-guide.md) · [`docs/infra/server-setup.md`](docs/infra/server-setup.md) |
| Falhas típicas | [`docs/troubleshooting.md`](docs/troubleshooting.md) |
| Índice `docs/` | [`docs/README.md`](docs/README.md) |

---

## Leitura mínima sessão operacional

| Ficheiro | Nota |
|----------|------|
| [`docs/worklog/current-sprint.md`](docs/worklog/current-sprint.md) | Estado sprint |
| [`docs/worklog/next-actions.md`](docs/worklog/next-actions.md) | Fila próximos passos |
| [`.cursor/context/architecture.md`](.cursor/context/architecture.md) | Exports críticos & element data |

**Regras extras Cursor:** `.cursor/rules/project-rules.md` · `.cursor/rules/security.md` · `.cursor/rules/translation.md`

---

## Resumo de regras (não substitui `docs/CLAUDE.md`)

- Handlers **client → server**: validar `source`.
- SQL parametrizado; schema apenas com aprovação explícita.
- Não quebrar **exports**/nomes de eventos sem migração planeado.

Pastas opcionais locais ignoradas pelo git (notas próprias): `.ai/` (ver texto longo em `docs/CLAUDE.md`).
