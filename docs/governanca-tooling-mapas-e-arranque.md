# Governança de arquitetura, tooling e arranque (mapas + oStarter)

**Atualização:** 2026-05-02 · fase mapas cedo (orquestrador)  
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

## 3. Mapas: política “no início” e alinhamento Original Roleplay

### 3.1 Modelo MTA (referência externa)

No MTA, [**mapas são recursos próprios**](https://wiki.multitheftauto.com/wiki/Writing_Gamemodes) com `<map>` em `meta.xml`; o gamemode deve carregá‑los (aqui via `oStarter`, não via *mapmanager* clássico). O repositório público [**FZoltanI/originalroleplay**](https://github.com/FZoltanI/originalroleplay) documenta a linhagem **Original Roleplay** (equipa histórica Carlos, Paul, Dexter, Jack — objectos e mapas em pacotes dedicados), de onde deriva a árvore analisada.

### 3.2 O que mudou no `oStarter` (Vale do Ipiranga)

Em [`[Core]/oStarter/starter_manifest.lua`](../%5BCore%5D/oStarter/starter_manifest.lua), após a **infra mínima até `npc_hlc`**, aplicam‑se:

1. **`oDestroyer`**, **`oWater`** — preparação de mundo (Original RP costumava colocar destruidor/água cedo).
2. **`oMapfix`**, **`oSampModels`** — colisões/modelos de apoio aos mapas.
3. **Onda única de mapas** — todos os recursos cujo `meta.xml` declara **`<map`** (descoberta recursiva na raíz do gamemode), **exceto** lista negra em [tooling/rebuild_orp_map_wave.py](tooling/rebuild_orp_map_wave.py) (legados `[OLD]` de teste, `asd_*`, paul `f1map2`/`rallymap`, *template* Dexter, recurso colidente `map` sob `oTraffipax`, etc.), **ordenados alfabéticamente** (determinístico).
4. **Ordem canónica preservada** para o restante (UI, economia, shaders, etc.), retirando duplicados já movidos para a onda de mapas.

**Correções de integridade:**

- **`oPiruMap` → `oPiruMapOLD`** (único recurso com `.map` presente no pacote para essa área).
- **Mapas adicionados** que já existiam em pastas típicas **`[Maps]/`**, **`[Maps]/[Faction]/`**, etc., mas faltavam no manifest antigo: exemplo **`oCity-Main`**, **`oBorderMap`**, **`oClub-mappolas`**, **`oDeliMap`**, **`oEastCoastMap`**, **`oLSFD1`/`oLSFD2`**, **`oNAVInterior`**, **`oCartelTijuana*Map`**, **`oMechanicLV`**, **`oBeerMaffiaInti_map`**, **`oHooverMAP`** (mapeamento físico; **`oHooverHQfix`** mantém‑se depois como recurso de correção), **`oLCMOBMap`**, **`oRally-Map`**, etc.

**Regenerar a lista** (após adicionar/remover recursos‑mapa):

```bash
python3 docs/tooling/rebuild_orp_map_wave.py
python3 docs/tooling/resource_dependency_scan.py --write
```

### 3.3 Números (cópia de trabalho, 2026‑05‑02)

| Métrica | Valor |
|--------|------:|
| Entradas totais em `ORP_ORIGINAL_RP_START_ORDER` | **229** |
| Recursos com `<map>` no `meta.xml` considerados na onda | **89** (após exclusões) |
| Índice aproximado de **`oInfobox`** na fila (~início HUD pesado) | **~121** (mapas ficam antes) |

Perfis **`streamlined`** continuam a filtrar `dude_telep`, `dude_map`, `dude_billboard` na função `orpFilterStarterProfile` (**não listar no EXCLUDE**, para esse perfil continuar válido).

Catálogo recurso‑a‑recurso (tabela mais extensa — pode estar parcialmente desfasada dos números acima): [catalogo-originalrp-ipiranga.md](catalogo-originalrp-ipiranga.md).

---

## 4. Documentação relacionada

- [architecture-overview.md](architecture-overview.md) — contexto técnico e risco estrutural.  
- [resumo-tecnico-servidor.md](resumo-tecnico-servidor.md) — processo MTA, starters, ACL.  
- [infra/acl-e-recursos.md](infra/acl-e-recursos.md) — symlinks e papel do `oStarter`.

Este guia está indexado em [README.md](README.md) (tabela de ficheiros).

---

_Se este ficheiro estiver versionado junto ao gamemode, regenere os artefactos `docs/generated/` após alterações em Lua/`meta.xml` para manter o observatório coerente com o código._
