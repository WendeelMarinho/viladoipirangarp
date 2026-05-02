# Documentação (`/docs`)

O **README principal** exibido na página inicial do repositório no GitHub está na **raiz**: [**README.md**](../README.md).

Use esta pasta para documentação complementar e worklogs.

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| [CLAUDE.md](CLAUDE.md) | Regras de desenvolvimento, segurança e fluxo de trabalho (canónico) |
| [../CLAUDE.md](../CLAUDE.md) | Entrada na raiz para Claude Code / Cursor (ponteiro + checklist) |
| [translation-roadmap.md](translation-roadmap.md) | Roadmap e glossário de tradução PT-BR |
| [technical-debt-report.md](technical-debt-report.md) | Dívida técnica e riscos |
| [prioritized-resource-list.md](prioritized-resource-list.md) | Lista priorizada de recursos |
| [relatorio-tecnico.md](relatorio-tecnico.md) | Relatório técnico / auditoria |
| [resumo-tecnico-servidor.md](resumo-tecnico-servidor.md) | Como o servidor MTA arranca e encaixa (processo, oStarter, MySQL, rede, comunicação Lua) |
| [catalogo-originalrp-ipiranga.md](catalogo-originalrp-ipiranga.md) | Inventário: recursos do `oStarter`, mapas `.map`, mods veículos |
| [guia-do-jogador.md](guia-do-jogador.md) | Guia para jogadores: vida IC, organizações, empregos, HQ (coordenadas dos mapas) |
| [guia-administracao-completo.md](guia-administracao-completo.md) | Guia de staff: níveis, duty, adminserials, lista de comandos, ficheiros-chave |
| **Base de conhecimento (engineering)** | |
| [governanca-tooling-mapas-e-arranque.md](governanca-tooling-mapas-e-arranque.md) | **Operação:** analyzer v3.1, regeneração `docs/generated/`, fluxo `vila-do-ipiranga-rp` → `oStarter`, mapas no disco vs manifest |
| [architecture-overview.md](architecture-overview.md) | Vista arquitectónica, camadas, trust boundaries |
| [resource-map.md](resource-map.md) | Ordem `oStarter`, exports em `meta.xml`, tooling |
| [event-flow.md](event-flow.md) | `trigger*` / elementData / checklist handlers |
| [database-architecture.md](database-architecture.md) | MySQL `orp_main`, tabelas, conectividade |
| [security-audit.md](security-audit.md) | Superfícies segurança + pontos auditoria continuada |
| [performance-analysis.md](performance-analysis.md) | Hotspots performance e medição staging |
| [deployment-guide.md](deployment-guide.md) | Deploy, rollback, backup, incidente |
| [troubleshooting.md](troubleshooting.md) | Diagnóstico problemas típicos |
| [generated/meta-export-stats.md](generated/meta-export-stats.md) | Resumo máquina: tags `<export>` por recurso |
| [generated/resource-dependency-graph.json](generated/resource-dependency-graph.json) | Scanner dependências tempo-compilação (exports, events, undeclared vs `oStarter`) |
| [generated/resource-dependency-report.md](generated/resource-dependency-report.md) | Relatório executivo gerado pelo scanner |
| [generated/architecture-risk-report.json](generated/architecture-risk-report.json) · [architecture-risk-report.md](generated/architecture-risk-report.md) | **Risk intel v3.1** — tudo v3.0 (histórico, `trend_analysis`, `risk_heatmap`, smells, ownership, roadmap) + **`coupling_analysis`** (C<sub>a</sub>/C<sub>e</sub>, instabilidade Martin, rankings) + **`regression_analysis`** (`regression_events`, `regression_score` 0–100, `regression_severity`; blast vs baseline só desde **v3.1.0** nos snapshots) + **`executive_scorecard`** (saúde, maturidade, resiliência operacional, segurança de mudanças, pressão de dívida técnica) |
| [tooling/export_meta_summary.py](tooling/export_meta_summary.py) | Script regenerar estatísticas de export |
| [tooling/rebuild_orp_map_wave.py](tooling/rebuild_orp_map_wave.py) | Regenera `starter_manifest.lua`: onda de mapas `<map>` cedo + exclusões legado ORP |
| [tooling/resource_dependency_scan.py](tooling/resource_dependency_scan.py) | Scanner completo deps inter-recursos |
| [tooling/architecture_risk_analyzer.py](tooling/architecture_risk_analyzer.py) | Analyzer corporativo **v3.1.0** (`--write` \| `--input` \| `--json-output` \| `--md-output`; stdlib; escrita atómica; histórico últimos 50; baseline v3.0.x compatível sem falsos positivos de blast) |
| [worklog/current-sprint.md](worklog/current-sprint.md) | Sprint atual |
| [worklog/next-actions.md](worklog/next-actions.md) | Próximas ações |
| [cursor/ecc-integration.md](cursor/ecc-integration.md) | ECC (Everything Claude Code) — modo mínimo no Cursor/Claude |
| [qa/pre-test-audit.md](qa/pre-test-audit.md) | Sprint C — pré-auditoria pré-teste (GO/NO-GO) |
| [architecture/](architecture/) | Documentos de arquitetura |
| [security/](security/) | Log e notas de segurança |
| [infra/mta-recursos-default.md](infra/mta-recursos-default.md) | Avaliação `mtaserver.conf` vs gamemode (admin, spawnmanager, scoreboard, …) |
| [infra/acl-e-recursos.md](infra/acl-e-recursos.md) | ACL, symlinks e comportamento `oStarter` |

**Regeneração (grafo → risco):**

```bash
cd mods/deathmatch/resources/vila-do-ipiranga-rp
python3 docs/tooling/resource_dependency_scan.py --write
python3 docs/tooling/architecture_risk_analyzer.py --write
```
