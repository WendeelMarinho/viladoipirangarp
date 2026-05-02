# Governança de arquitetura, tooling e arranque (mapas + oStarter)

**Atualização:** 2026-05-02  
**Escopo:** pacote gamemode `vila-do-ipiranga-rp` (referência também em [README.md](README.md), [resource-map.md](resource-map.md)).

---

## 1. Fluxo oficial de análise (arquitetura)

A partir da raíz do recurso (`mods/deathmatch/resources/vila-do-ipiranga-rp`):

```bash
python3 docs/tooling/resource_dependency_scan.py --write
python3 docs/tooling/architecture_risk_analyzer.py --write
```

**Saídas principais:**

| Artefacto | Descrição |
|-----------|-----------|
| `docs/generated/resource-dependency-graph.json` (+ `.md`) | Grafo determinístico (exports, refs, undeclared, `starter_order`). |
| `docs/generated/architecture-risk-report.json` (+ `.md`) | Relatório **v3.1.0**: métricas por recurso, SCCs Tarjan, SPOFs, heatmap de risco, tendência histórica, **Cₐ/Cₑ** (instabilidade Martin), regressão vs snapshot anterior, scorecard executivo. |
| `docs/generated/history/architecture-risk-*.json` | Até **50** snapshots completos por execução do analyzer (`--write`). |

**Retrocompatibilidade:** snapshots **`analyzer_version` &lt; 3.1.0** não disparam regressão de *blast radius* por recurso (evita falsos positivos); comparações de **instabilidade** (derivadas de graus de entrada/saída) mantêm‑se válidas.

Código‑fonte: [tooling/architecture_risk_analyzer.py](tooling/architecture_risk_analyzer.py) (stdlib, Python 3.10+, escritas atómicas).

---

## 2. O que acontece quando o servidor “abre” o gamemode

1. **`mtaserver.conf`** inicia `vila-do-ipiranga-rp` (recurso de arranque do gamemode).
2. **`vila-do-ipiranga-rp/server.lua`** usa `startResource(getResourceFromName("oStarter"))`; se falhar ou o recurso não existir, o log indica erro crítico (ver próprio `server.lua`).
3. **`[Core]/oStarter/server.lua`**:
   - Lê **`ORP_STARTER_PROFILE`** (`original_rp` por defeito ou `streamlined` com filtros opcionais).
   - Obtém **`ORP_ORIGINAL_RP_START_ORDER`** de `../[Core]/oStarter/starter_manifest.lua` através de **`orpFilterStarterProfile`** (remove entradas periféricas só no perfil *streamlined*).
   - Anexa recursos **`oFKSkins_*`** detectados pelo MTA ao fim da fila (comportamento legado Original RP).
   - Para cada nome na lista: `getResourceFromName` → `startResource`; recursos ausentes geram **`[STARTER]: AVISO`** e são ignorados; falhas reportam **`FALHA`**.
   - Após ~10 s, **restarts** retardados opcionais: `oInventory`, `oSpeedo`, `oBillboards` (mantém compatibilidade com scripts que assumem outros já correram antes).

Ou seja: **o “orquestrador” não varre pastas nem carrega todos os `.map` automaticamente** — só são iniciados os recursos listados nesta manifest (mais FK skins dinâmicas). Pastas órfãs com `.map` **não** entram até serem registados no manifest e existir symlink/pasta válida sob `mods/deathmatch/resources/`.

---

## 3. Mapas instalados versus mapas arrancados pelo oStarter

- **“.map instalado”** aqui significa: existe ficheiro **`*.map`** dentro de algum recurso cujo pai contém **`meta.xml`** (árvore `vila-do-ipiranga-rp/`).
- **“Pronto para rodar”** no arranque canónico: o **nome do recurso** (pasta, ex. `oNewDeliMap`) está em **`ORP_ORIGINAL_RP_START_ORDER`** (após filtro de perfil) **e** o servidor consegue resolver o recurso via `getResourceFromName` (tipicamente symlink em `mods/deathmatch/resources/<nome>` apontando para esta árvore).

**Números (inventário automático 2026‑05‑02, cópia de trabalho):**

| Métrica | Valor |
|--------|------:|
| Entradas em `ORP_ORIGINAL_RP_START_ORDER` | 199 |
| Recursos com pelo menos um `.map` + `meta.xml` no pacote | **121** |
| Intersecção: recursos com `.map` **e** presentes na lista do oStarter | **58** |

Os restantes **~63** recursos com ficheiro `.map` estão no disco (souvente `[Maps]/[OLD]`, `[paul]`, HQs alternativas, eventos) mas **não** são dados `start` pelo manifest actual — podem ser usados por eventos, por arranque manual, ou ser legado.

**Nota de integridade:** o manifest referencia **`oPiruMap`**, mas **não existe** recurso/pasta `oPiruMap` nesta árvore (há apenas legado `oPiruMapOLD` com `.map`). O oStarter imprime **`[STARTER]: AVISO — resource 'oPiruMap' não encontrado`** em runtime; corrigir incluindo o recurso em falta ou ajustando a lista ao nome real disponível no `mods/deathmatch/resources`.

Catálogo legível recurso‑a‑recurso: [catalogo-originalrp-ipiranga.md](catalogo-originalrp-ipiranga.md).

---

## 4. Documentação relacionada

- [architecture-overview.md](architecture-overview.md) — contexto técnico e risco estrutural.  
- [resumo-tecnico-servidor.md](resumo-tecnico-servidor.md) — processo MTA, starters, ACL.  
- [infra/acl-e-recursos.md](infra/acl-e-recursos.md) — symlinks e papel do `oStarter`.

Este guia está indexado em [README.md](README.md) (tabela de ficheiros).

---

_Se este ficheiro estiver versionado junto ao gamemode, regenere os artefactos `docs/generated/` após alterações em Lua/`meta.xml` para manter o observatório coerente com o código._
