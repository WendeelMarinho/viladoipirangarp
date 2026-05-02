# Pré-auditoria pré-teste — Sprint C (Ipiranga Roleplay)

**Data:** 2026-05-02  
**Âmbito:** auditoria apenas (sem alterações a código de jogo).  
**Contexto:** após Sprint A, TD-SEC-006, Sprint B (B.1 / B.2), integração ECC mínima.

## 1. Metodologia

| Passo | Acção |
|-------|--------|
| Leitura | `project-state.md` → `current-sprint.md` → `README.md` → `docs/CLAUDE.md` → `docs/worklog/current-sprint.md` (ordem pedida). |
| Busca HU | Padrões: caracteres `őűŐŰ`, tokens frequentes (`Játékos`, `Használat`, `Nincs `, `jármű`, `Fejlesztő`, `Szerver`, etc.) em `*.lua`. |
| Exclusões | `[Old]/`, ficheiros `triggerHack.lua`, recurso/pasta **oAnticheat**, scaffolding ECC (`.cursor/commands/ecc-*`, `.cursor/agents/ecc-*`, `docs/cursor/ecc-integration.md`, `AGENTS.md`). |
| Integridade | Leitura amostral: fluxo login `originalRoleplayAccount` + `2k20` no cliente; `password_salt` / `computeSaltedPassword` no servidor; presença de salt `_OriginalRP` em `triggerHack.lua` / `antiHook.lua` (não editados). |
| Sintaxe Lua | `lua5.1 -e "assert(loadfile(...))"` em ficheiros representativos (`oAccount/client.lua`, `oAccount/server.lua`, `oAdmin/s_admin.lua`, `oDashboard/client.lua`, `oDashboard/bugReportC.lua`, `oDashboard/openCreate.lua`, `[Interface]/oRadar/sourceC.lua`) — **exit code 0** (WSL Ubuntu-22.04). |

## 2. Resultados por criticidade

### 2.1 Crítico — texto ao jogador (ou administrador em jogo) ainda em húngaro

| Área | Evidência | Nota |
|------|-----------|------|
| **oAdmin** | `s_admin.lua`, `g_commands.lua`, `c_admin.lua`, `ajail.lua`, `playerstats.lua`, `logs/c_logs.lua`, `adminStats/adminDatasC.lua` — dezenas de `outputChatBox` / mensagens com `Játékos`, `Használat`, `jármű`, `Nincs`, `Indok`, `perc`, etc. | Staff vê HU em comandos e logs; parte dos jogadores pode ver mensagens de admin. |
| **oCore** | `server.lua`: mensagem com `Nincs ilyen sorszámmal serial kérelem.` | Jogador / dev com fluxo de pedido de serial. |
| **oPhone** | `client.lua` — ocorrências com tokens HU (UI telefone). | Jogador. |
| **oDrugs** | `client.lua` / `server.lua` — strings HU remanescentes (ex.: níveis, organizações). | Jogador. |
| **oBank** | `client.lua` — termos HU (ex. `Műveletek`). | Jogador. |
| **Outros módulos** | Greps anteriores no repo: `oCarshop`, `oCinema`, `oDriveschool`, etc. — ainda com rótulos/mensagens HU. | Jogador conforme recurso activo no servidor. |

**Conclusão crítica:** o âmbito **Sprint B** cobriu prioridades (oDashboard alvo, Interface parcial, etc.); **não** há “zero HU” global no gamemode.

### 2.2 Médio — admin / debug / mensagens técnicas

| Área | Evidência |
|------|-----------|
| **oAccount/server.lua** | Linha de debug/comentário húngaro (`sor`, `valószínűleg`, `nincs sql kapcsolat`) e comentários `ellenőrzi...` junto a chamadas `oAnticheat` (o comentário não está dentro do recurso oAnticheat, mas descreve-o). |
| **oCore / oAdmin** | Mensagens de uso / erro com mistura HU para fluxos administrativos. |

### 2.3 Baixo — comentários, nomes internos, dados de teclado

| Área | Evidência |
|------|-----------|
| **oAccount/client.lua** | Comentários HU (`INNEN KEZDŐDIK A LOGIN`, `jelszó emlékeztető`, etc.). |
| **oDashboard** | Valores de mapa de teclado `"ő"`, `"ű"` em `global.lua` / `aClient.lua` — **dados de entrada**, não UI (alinhado a regra de não traduzir mapeamento). |
| **oDashboard/client.lua** | Identificador `ingatlanCount` — nome de variável legado (interno). |

## 3. Sistemas protegidos (integridade — apenas verificação)

| Sistema | Resultado |
|---------|-----------|
| **Login cliente (hash legado)** | `oAccount/client.lua` e `changePW.lua` / `clientBK.lua`: `hash("sha256", "originalRoleplayAccount"..pass.."2k20")` enviado ao servidor — **inalterado** face à especificação TD-SEC-006 no README. |
| **TD-SEC-006 servidor** | `oAccount/server.lua`: uso de `password_salt`, `computeSaltedPassword`, `INSERT`/`UPDATE` com campos `password_salt` — presente. |
| **triggerHack / _OriginalRP** | Amostragem: `triggerHack.lua` em recursos contém `local salt = "..._OriginalRP"`; `oAccount/triggerHack.lua` inicia com bloco comentado — **não auditados para alteração** (exclusão explícita). Nenhuma modificação feita nesta sprint C. |
| **oAnticheat** | Excluído da análise de strings; chamadas `exports.oAnticheat:checkPlayerVerifiedAdminStatus` mantêm-se em ficheiros revistos. |

## 4. ECC e `.cursor`

- Integração **mínima** documentada; nenhum `hooks.json` no repo.  
- Nenhuma alteração de lógica ligada ao ECC.

## 5. Sintaxe Lua (amostra)

Ficheiros críticos dos sprints A/B carregados com `loadfile` sem erro de parse (ambiente WSL + `lua5.1`). **Não** foi feita validação exaustiva de todos os `*.lua` do repositório.

## 6. Recomendação formal **GO / NO-GO** (testes locais)

| Critério | Decisão |
|----------|---------|
| **Testes locais / QA** focados em **oAccount**, **TD-SEC-006** (login/registo/troca de senha), **oDashboard** e **áreas [Interface] já traduzidas**, regressão mínima em **radar / caixas / opções** | **GO (condicional)** — pode iniciar-se campanha de testes manuais no servidor de desenvolvimento. |
| **Critério “ship” com UI 100% PT-BR para jogador em todo o gamemode** | **NO-GO** — permanecem módulos first-party com HU (oAdmin, oPhone, oDrugs, oBank, oCore mensagem citada, lojas, cinema, autoescola, etc.). |
| **Release pública BR sem passagem de tradução adicional** | **NO-GO** até roadmap em `docs/translation-roadmap.md` cobrir os módulos listados. |

### Resumo executivo

**GO** para **pré-teste local** das entregas Sprint A + TD-SEC-006 + Sprint B nas áreas já trabalhadas, assumindo que o objectivo do teste **não** é “zero húngaro global”.  
**NO-GO** como barreira de **qualidade de idioma** para experiência completa do jogador até nova fase de tradução.

---

## 7. Próximas acções sugeridas (pós-auditoria)

1. Definir **checklist de QA manual** (login, registo, troca de senha, painel, radar, caixas).  
2. Planear **Sprint de tradução** para `oAdmin`, `oPhone`, economia (`oBank`), e restantes conforme roadmap.  
3. Opcional: `rg` / CI com lista de tokens HU bloqueados em PRs que toquem `oDashboard` / `[Interface]`.

**Responsável pela auditoria:** agente Sprint C (documento gerado; sem commits de código de gameplay).
