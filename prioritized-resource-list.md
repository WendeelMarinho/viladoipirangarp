# Lista de Recursos Prioritizada — Ipiranga Roleplay

**Data:** 2026-05-01  
**Critérios de priorização:** Segurança > Dependências críticas > Volume de jogadores impactados > Complexidade de tradução

---

## Tier 0 — Bloqueantes de Lançamento (Não lançar sem corrigir)

| # | Recurso | Caminho | Problema | Ação |
|---|---|---|---|---|
| 1 | **oAccount** | `oAccount/` | Passwords em memória, sem rate limiting, source validation inconsistente | Security hardening |
| 2 | **oAdmin** | `oAdmin/` | Seriais hardcoded, ACL manipulation sem audit | Security hardening + migração |
| 3 | **oAnticheat** | `[Core]/oAnticheat/` | Sistema central de segurança — deve ser revisado antes de abrir ao público | Auditoria |
| 4 | **oCore** | `[Core]/oCore/` | Whitelist hardcoded, arquitetura de boot | Refactor + segurança |
| 5 | **oMysql** | `[Core]/oMysql/` | Ponto único de falha, sem connection pooling visível | Hardening + error handling |

---

## Tier 1 — Sistemas Críticos de Jogabilidade

Esses recursos são usados por 100% dos jogadores a cada sessão.

| # | Recurso | Caminho | Lua Files | Prioridade | Motivo |
|---|---|---|---|---|---|
| 6 | **oInventory** | `oInventory/` | 21 | ALTA | Usado constantemente; bugs aqui quebram gameplay |
| 7 | **oVehicle** | `oVehicle/` | 23 | ALTA | Sistema central; performance crítica |
| 8 | **oDashboard** | `oDashboard/` | 16 | ALTA | Interface principal do jogador |
| 9 | **oCharacter** (via oAccount) | `oAccount/` | 4 | ALTA | Criação/carregamento de personagem |
| 10 | **oChat** | `[Core]/oChat/` | ? | ALTA | Comunicação — primeiro recurso que jogador usa |
| 11 | **oNametag** | `oNametag/` | 4 | MÉDIA-ALTA | Identificação visual de jogadores |
| 12 | **oPayday** | `oPayday/` | 5 | MÉDIA-ALTA | Economia base |
| 13 | **oBank** | `oBank/` | 7 | MÉDIA-ALTA | Sistema financeiro |
| 14 | **oHud** | `[Interface]/oHud/` | ? | MÉDIA-ALTA | HUD — visível o tempo todo |
| 15 | **oRadar** | `[Interface]/oRadar/` | ? | MÉDIA-ALTA | Mapa/radar do jogador |

---

## Tier 2 — Sistemas de Roleplay Essenciais

| # | Recurso | Caminho | Lua Files | Prioridade | Motivo |
|---|---|---|---|---|---|
| 16 | **oPhone** | `oPhone/` | 7 | MÉDIA | Comunicação RP — muito usado |
| 17 | **oInteriors** | `oInteriors/` | 9 | MÉDIA | Sistema de imóveis |
| 18 | **oShop** | `oShop/` | 8 | MÉDIA | Comércio de items |
| 19 | **oCarshop** | `oCarshop/` | 7 | MÉDIA | Compra de veículos |
| 20 | **oTuning** | `oTuning/` | 13 | MÉDIA | Customização veicular |
| 21 | **oLicenses** | `oLicenses/` | 7 | MÉDIA | Licenças de habilitação, armas |
| 22 | **oDeath** | `oDeath/` | 6 | MÉDIA | Sistema de morte/hospital |
| 23 | **oSiren** | `oSiren/` | 6 | MÉDIA | Sirenes para policiais/EMS |
| 24 | **oTraffipax** | `oTraffipax/` | 12 | MÉDIA | Multas de velocidade |
| 25 | **oLvl** | `oLvl/` | 5 | MÉDIA | Sistema de nível |
| 26 | **oTicket** | `oTicket/` | 5 | MÉDIA | Sistema de multas RP |

---

## Tier 3 — Sistemas de Facção e Organização

| # | Recurso | Caminho | Prioridade | Motivo |
|---|---|---|---|---|
| 27 | **Factions** (via oDashboard) | Sistema de facções | MÉDIA | Central para gameplay de grupos |
| 28 | **oSheriffHQ** | `oSheriffHQ/` | MÉDIA | Policia — sistema RP crítico |
| 29 | **oCrips / oCartelHQ** | Respectivos paths | BAIXA-MÉDIA | Facções criminosas |
| 30 | **oBorder** | `oBorder/` | BAIXA-MÉDIA | Controle de fronteira |
| 31 | **[Interface]/oScoreboard** | `[Interface]/oScoreboard/` | BAIXA-MÉDIA | Placar de jogadores |

---

## Tier 4 — Empregos

| # | Recurso | Caminho | Lua Files | Prioridade |
|---|---|---|---|---|
| 32 | **oJob** (base) | `[Jobs]/oJob/` | ? | MÉDIA (base para todos) |
| 33 | **oJob_PizzaMaker** | `[Jobs]/oJob_PizzaMaker/` | ? | BAIXA |
| 34 | **oJob_Cashier** | `[Jobs]/oJob_Cashier/` | ? | BAIXA |
| 35 | **oJob_Builder** | `[Jobs]/oJob_Builder/` | ? | BAIXA |
| 36 | **oJob_Hacker** | `[Jobs]/oJob_Hacker/` | ? | BAIXA |
| 37 | **oJob_Cleaner** | `[Jobs]/oJob_Cleaner/` | ? | BAIXA |
| 38 | Demais empregos (8) | `[Jobs]/` | ? | BAIXA |

---

## Tier 5 — Entretenimento e Minigames

| # | Recurso | Caminho | Prioridade |
|---|---|---|---|
| 39 | **oDrugs** | `oDrugs/` | MÉDIA (alto impacto RP) |
| 40 | **oCinema** | `oCinema/` | BAIXA |
| 41 | **oTreasureHunt** | `oTreasureHunt/` | BAIXA |
| 42 | **oMinigames** | `oMinigames/` | BAIXA |
| 43 | **Casino** ([Carlos]) | Blackjack/Poker/Slot | BAIXA |
| 44 | **oRallyEvent** | `oRallyEvent/` | BAIXA |
| 45 | **Fishing** ([Carlos]) | Pesca | BAIXA |

---

## Tier 6 — Visuais e Efeitos

| # | Recurso | Caminho | Prioridade |
|---|---|---|---|
| 46 | **[Shaders]** (21 recursos) | `[Shaders]/` | BAIXA |
| 47 | **oSnow / oBlur / oNoblur** | Respectivos | BAIXA |
| 48 | **oStreetlamps** | `oStreetlamps/` | BAIXA |
| 49 | **[Interface]/oCrosshair** | `[Interface]/oCrosshair/` | BAIXA |
| 50 | **[Interface]/oSpeedo** | `[Interface]/oSpeedo/` | BAIXA |

---

## Tier 7 — Deprecados / Arquivamento

| # | Recurso | Caminho | Ação Recomendada |
|---|---|---|---|
| 51–78 | **[Old]** (28 recursos) | `[Old]/` | Mover para fora do gamemode; não traduzir; não manter |

---

## Resumo por Fase de Trabalho

### Fase 1 — Segurança (Semanas 1–2)
Tier 0 completo: oAccount, oAdmin, oAnticheat, oCore, oMysql

### Fase 2 — Tradução Core (Semanas 3–6)
Tier 1 completo + oPhone: 10 recursos, ~1.500 strings estimadas

### Fase 3 — Tradução Roleplay (Semanas 7–10)
Tier 2 + Tier 3: ~18 recursos, ~2.000 strings estimadas

### Fase 4 — Empregos e Entretenimento (Semanas 11–14)
Tier 4 + Tier 5: ~18 recursos, ~1.500 strings estimadas

### Fase 5 — Polimento (Semanas 15–16)
Tier 6 + revisão geral + testes

---

## Critérios de Conclusão por Recurso

Um recurso é considerado **pronto para produção** quando:
- [ ] Sem strings em húngaro expostas ao jogador
- [ ] Sem SQL queries não-parametrizadas
- [ ] Todos os event handlers de cliente validam `source`
- [ ] Nenhum dado sensível em element data não-encriptado
- [ ] Documentação em `docs/resources/<nome>.md` criada
