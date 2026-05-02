# Ipiranga Roleplay — CLAUDE.md (canónico)

## Missão (AI / engenharia assistida)

Atuar como **engenheiro senior** em MTA:SA, Lua, arquitecturas de servidor de jogo, Linux, MySQL, segurança e documentação técnica. Objectivos neste repositório:

1. **Compreender e mapear** o ecossistema (recursos, eventos, exports, BD, arranque) sem assumir comportamento não lido no código.
2. **Documentar antes de mudar** código de produção: motivo, impacto export/event, plano rollback.
3. **Modernização incremental**, compatível com convenções Original Roleplay, mudanças mínimas quando possível.
4. **Segurança**: validação de `source`, SQL parametrizado, permissões servidor-autoritativas.

---

## Ambiente esperado

| Item | Valor |
|------|-------|
| SO | Linux (produção documentada Ubuntu 24.04) |
| Plataforma | MTA:SA dedicado (`mta-server64`) |
| Recursos (`meta.xml`) no pacote | ~400 diretórios |
| Arranque activo típico | ~**210** via **`oStarter`** + `oFKSkins_*` |
| Gamemode raíz | **`vila-do-ipiranga-rp`** (sobe **`oStarter`**) |
| Caminho físico típico | `mods/deathmatch/resources/` + symlinks individuais (ver `docs/infra/acl-e-recursos.md`) |
| BD | MySQL base **`orp_main`** |
| Runtime scripts | Lua (server/client/shared) |
| Assets | HTTP interno (`httpport` em `mtaserver.conf`) |

---

## Base de conhecimento (manter)

| Documento | Conteúdo |
|-----------|----------|
| [architecture-overview.md](architecture-overview.md) | Contexto, camadas, trust boundaries |
| [resource-map.md](resource-map.md) | Ordem `oStarter`, exports em meta, automação |
| [event-flow.md](event-flow.md) | Padrões trigger*/element data |
| [database-architecture.md](database-architecture.md) | Tabelas `orp_main` |
| [security-audit.md](security-audit.md) | Superfícies + ligação a dívida/log |
| [performance-analysis.md](performance-analysis.md) | Hotspots & medição |
| [deployment-guide.md](deployment-guide.md) | Checklists deploy, backup, incidente |
| [troubleshooting.md](troubleshooting.md) | Sintomas comuns |
| [resumo-tecnico-servidor.md](resumo-tecnico-servidor.md) | Narrativa arranque MTA |
| [catalogo-originalrp-ipiranga.md](catalogo-originalrp-ipiranga.md) | Tabela recurso×função + mapas |
| [generated/meta-export-stats.md](generated/meta-export-stats.md) | Estatísticas `<export>` (regenerável) |

Regenerar stats de export:

```bash
python3 docs/tooling/export_meta_summary.py | head -80
```

Grafo de dependências tempo-análise (consumo real `exports.`, eventos string, vs `oStarter`):

```bash
python3 docs/tooling/resource_dependency_scan.py --write
```

---

## Leitura no início da sessão

```
docs/worklog/current-sprint.md
docs/worklog/next-actions.md
.cursor/context/current-sprint.md
.cursor/context/architecture.md
```

Opcional local: `.ai/` (gitignored).

## Escrita no fim da sessão

Atualizar `docs/worklog/current-sprint.md` e `docs/worklog/next-actions.md`. Ao fechar ciclo grande de infra/docs, atualizar também a entrada relevante na base de conhecimento acima.

---

## Regras não-negociáveis

- Nunca quebrar **exports** ou **nomes de eventos** sem migração coordenada e documentação da alteração neste repositório.
- Nunca alterar **schema** MySQL ou dados destrutivos sem aprovação explícita e plano rollback.
- Não reescrever módulos estáveis de uma só vez — refactor incremental.
- Handlers cliente→servidor: **`source`** canónico + validação jogador antes de qualquer efeito.
- Queries SQL parametrizadas (`?`), sem concat de input.

---

## Padrão de handler seguro

```lua
addEvent("nomeDoEvento", true)
addEventHandler("nomeDoEvento", getRootElement(), function(arg1, arg2)
    local player = source
    if not isElement(player) or getElementType(player) ~= "player" then return end
end)
```

---

## Análise por recurso (template Markdown)

Usar quando documentar um recurso manualmente ou gerar issue de auditoria.

```markdown
# Analysis: <resource-name>

## Overview
Breve papel no gamemode e ficheiros principais.

## Dependencies
Recursos que devem estar UP antes; ordem no `oStarter` se aplicável.

## Exports provided
Funções em `meta.xml` + globals realmente chamados externamente.

## Exports consumed
`exports.other:fn(...)` encontrados por grep/review.

## Events emitted / listened
Lista parcial desde `grep` (marcar heuristic).

## Database
Queries/tabelas (nomes apenas; sem dados sensíveis).

## Security review
handlers clienteados, trust boundary, permissões económicas.

## Performance review
Timers, render pesado client, bursts SQL.

## Recommendations
Patches priorizados (S,M,L).

## Risk Level
Low | Medium | High | Critical
```

**Automatização completa (~400 dossiers)** ainda não é gerada pelo CI: construir gradualmente pipelines `grep`/`ast` conforme secção Roadmap em [resource-map.md](resource-map.md).

---

## Ordem de refatoração sugerida (histórico)

1. **oAccount** — hardening maioritariamente aplicado (ver `docs/security/security-log.md`)
2. **oAdmin** — migração seriais BD (ver mesmo log — validar estado do branch antes de declarar LIVE)
3. **oMysql** — pooling/erros centralizados
4. **oInventory**
5. **oVehicle**
6. **oPhone**

---

## Nomenclatura de branches

- `security/<resource>-<topico>`
- `refactor/<resource>`
- `performance/<resource>`
- `translation/<resource>`
- `docs/<topico>`
