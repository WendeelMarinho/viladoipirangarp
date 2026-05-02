# Performance analysis — hotspots & optimisation backlog

**Atualização:** 2026-05-02

---

## Executive posture

Este gamemode é **latency-sensitive** em três pontos: **frame client** (`onClientRender` pesado), **tick servidor** (`setTimer`/handlers globais) e **`dbPoll` bursts** quando muitos jogadores autenticam/submetem comandos económicos.

Sem APM oficial integrado ao MTA, qualquer número absoluto aqui permanece qualitativo até instrumentação própria (timestamps `getTickCount` guardados periodicamente ou export debug).

---

## 1. Boot path

| Fase | Observação perf |
|------|-----------------|
| `oStarter` sequencial | Startup **O(n)** em número recursos grandes — CPU spike único típico 10–120s VPS fraca dependendo HDD |
| `restartResource` retardado (+10 s) | Pode causar micro-stagger player experience se primeiro join coincide |
| Downloads HTTP paralelos client-side | Stress banda inicial — considerar CDN extern (`httpdownloadurl`) em produção pública alta slot |

Mitigações possíveis (low risk primeiro):

1. Medições log timestamp antes/after loop starter.
2. Separar shaders pesados tardios apenas após warmup (⚠ comportamento perceptível ao jogador atual).

---

## 2. Client rendering & DX overload

Clusters frequentes RP:

- Inventário redraw contínuo se não há cache texturas.
- Radar custom + minimap hooks.
- Shaders combinados Bloom + Reflection + Depth no hardware fraco.

**Sinal vermelho qualitativo:** FPS < 35 estável cidade cheia apenas com shaders — normalizar tiers gráficos (server-side toggle por preferência quando existir recurso opcional futuro).

---

## 3. Element data chatter

Alto volume `setElementData` em loops (exemplo hipotético: refresh plate veículos massivos por tick) gera churn sync.

Orientação modernização incremental:

| Ação | Benefício esperado |
|------|---------------------|
| Batching updates (mudar apenas dirty fields) | ↓pacotes redes |
| `synced=false` onde client não deve ver | segurança perf dupla ganho |

Cross-check com **TD-ARCH-002** (privacy + churn).

---

## 4. Database query patterns

Riscos comuns já identificados na dívida:

| Sintoma conceitual | Efeito |
|--------------------|--------|
| SELECT grande em login sem índices alinhados | Latência entrada picos spike |
| JSON parse server-side repetitivo membros factions | CPU micro por operação faction UI |
| Queries non prepared mix | Auditoria segurança + plano caches imprevisíveis |

Índices: auditar apenas com **explain real** usando workload de staging.

---

## 5. Measurement recipes (staging)

Minimal intrusive:

```lua
-- pseudo pattern (don't paste blindly prod)
local t0=getTickCount()
-- heavy block
outputDebugString(('blockMs=%sms'):format(getTickCount()-t0))
```

Macro:

1. Snapshot `mods/deathmatch/logs/server.log` size hourly during load test synthetic (fake clients limited tools).
2. Profiling MySQL slow query log ativo apenas em janelas curtas QA.

---

## 6. Quick wins backlog (risk sorted)

| Item | Difficulty | Perf gain potential |
|------|-------------|---------------------|
| Desligar recurso shaders redundante duplicado | Low | médio GPUs fracos |
| Cache consultas dashboards estáticos (TTL curto in-memory LRU) | Med | alto picos comandos repetidos `/stats` clones |
| Desacoplar tick jobs meia-noite económica stagger | Med | suavização CPU |

---

## Relacionamento

Para dependências cargas paralelas revisar também [architecture-overview.md](architecture-overview.md) & [database-architecture.md](database-architecture.md).
