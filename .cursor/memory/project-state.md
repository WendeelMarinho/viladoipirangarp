# Ipiranga Roleplay — estado do projecto (memória ECC)

> Ficheiro **aditivo** para contexto de sessão. Mantém-se alinhado a `docs/worklog/` e `.cursor/context/current-sprint.md`; atualizar manualmente ou ao fechar marcos.

**Última revisão:** 2026-05-02 (Sprint C — pré-auditoria)

---

## Sprint atual (resumo)

- **TD-SEC-006:** hashing de senhas com salt — documentado no README; migração SQL quando aplicável em produção.  
- **Sprint B (100%):** localização PT-BR player-facing nas áreas priorizadas.  
- **Sprint B.1:** comentários / debug não–player-facing → PT-BR.  
- **Sprint B.2:** `bugReportC.lua`, `openCreate.lua`, `panels/options.lua`, `oRadar/sourceC.lua` — UI residual HU → PT-BR.

## Marcos concluídos (recentes)

- oAccount — Sprint A PT-BR + tropicalização de marca.  
- oDashboard / Interface — blocos B, B.1, B.2 conforme `.cursor/context/current-sprint.md`.  
- Entrada `CLAUDE.md` na raiz + integração **ECC mínima** (`ecc-*`, `docs/cursor/ecc-integration.md`).  
- **Sprint C (2026-05-02):** pré-auditoria pré-teste — relatório `docs/qa/pre-test-audit.md` (**GO condicional** para QA local; **NO-GO** para zero HU global).

## Próximos marcos (alto nível)

- QA in-game (HUD, radar, dashboard, caixas) — seguir `docs/qa/pre-test-audit.md`.  
- Migração `td_sec_006_password_salt` em bases reais.  
- oAdmin — seriais, ACL, validações (`docs/worklog/next-actions.md`).  
- Tradução / auditoria remanescente no gamemode (`docs/translation-roadmap.md`) — **HU** ainda em `oAdmin`, `oPhone`, `oDrugs`, `oBank`, `oCore` (amostras), etc.

## Sistemas protegidos (não alterar sem coordenação explícita)

- **Anticheat** (`oAnticheat`, fluxos de verificação admin).  
- **`triggerHack`** e strings técnicas **`_OriginalRP`** (compatibilidade entre recursos).  
- **Nomes de eventos**, **exports** e **contratos públicos** entre recursos.  
- **Schema SQL** sem aprovação e migração documentada.  
- **Tabelas de mapeamento de teclado** (valores `ő`, `ú`, …) — dados de entrada, não apenas UI.

---

## Integração ECC (modo mínimo)

- Comandos: `.cursor/commands/ecc-*.md`  
- Agentes: `.cursor/agents/ecc-*.md`  
- Documentação: `docs/cursor/ecc-integration.md`  
- **Sem** `hooks.json` neste modo.
