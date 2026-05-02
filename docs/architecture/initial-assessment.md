# Ipiranga Roleplay — Initial Architecture Assessment

**Data:** 2026-05-01  
**Responsável:** Principal Software Architect  
**Base:** OriginalRoleplay (Hungarian origin, 2019–2023)  
**Status:** Pre-launch modernization phase

---

## Sumário Executivo

O repositório Ipiranga Roleplay é um fork do **OriginalRoleplay**, servidor MTA:SA desenvolvido por uma equipe húngara entre 2019 e 2023, cujo código foi liberado publicamente em dezembro de 2024. O projeto contém **~1.654 arquivos Lua**, **402 recursos MTA**, **45 tabelas MySQL** e mais de 7.100 assets (imagens, modelos, sons, shaders).

A base de código é **funcionalmente rica**, cobrindo praticamente todos os sistemas esperados de um servidor RP premium: autenticação, personagens, inventário, veículos, facções, empregos, banco, casino, drogas, imóveis, sistema de telefone e muito mais. Porém, apresenta **dívida técnica significativa** acumulada ao longo de quatro anos de desenvolvimento iterativo com múltiplos colaboradores e padrões inconsistentes.

O projeto é viável para modernização incremental. Não é necessária reescrita total.

---

## Inventário de Sistemas

### Grupo [Core] — Infraestrutura Central (20 recursos, ~123 Lua)

| Recurso | Função |
|---|---|
| oCore | Bootstrap do servidor, whitelisting, player IDs, FPS lock |
| oMysql | Camada de abstração do banco de dados (wrapper dbConnect) |
| oAnticheat | Sistema anti-trapaça e verificação de jogadores |
| oAdmin | Painel administrativo completo (17 scripts, ~700+ linhas) |
| oLogs | Sistema de logging persistente |
| oChat | Sistema de chat global e proximidade |
| oBone | Sistema de dano por ossos (bone damage) |
| oFont | Gerenciamento de fontes DX |
| oDx | Utilidades de desenho na tela (DX) |
| oJSON | Serialização/deserialização JSON |
| oCompiler | Compilação de scripts em runtime |
| oLoading | Tela de carregamento |
| oMapLoader | Carregamento dinâmico de mapas |
| oDevtools | Ferramentas de desenvolvimento |
| oStarter | Inicialização e sequência de boot |
| oVerify | Verificação de jogadores via Discord |
| oSkinProtect | Proteção de skin contra alteração |
| oAntiHook | Detecção de hooks no cliente |
| oStopServer | Desligamento controlado do servidor |
| oExtraCommands | Comandos extras de servidor |

### Grupo Raiz — Sistemas de Gameplay (68 recursos)

| Categoria | Recursos |
|---|---|
| Conta & Personagem | oAccount, oIndex, oSync, oLvl |
| Interface | oDashboard, oNametag, oHud (via [Interface]) |
| Inventário | oInventory, oInteraction |
| Economia | oBank, oShop, oCarshop, oPayday |
| Veículos | oVehicle, oTuning, oPaintjobs, oTraffipax |
| Imóveis | oInteriors, oInteriorBuilding |
| Comunicação | oPhone, oSiren, oWalkietalkie |
| Facções | oCrips, oCartelHQ, oSheriffHQ, oBorder, oTambovHQ |
| Emprego | via [Jobs] (14 empregos) |
| Entretenimento | oMinigames, oDrugs, oCinema, oTreasureHunt |
| Administração | oAdmin, oLicenses, oTicket |

### Grupos Externos

| Grupo | Recursos | Descrição |
|---|---|---|
| [Carlos] | ~67 | Mayor contribuidor — veículos, armas, casino, portas, combustível |
| [Maps] | 62 | Mapas de facções, empregos, carshops |
| [Jobs] | 14 | Sistema modular de empregos |
| [Shaders] | 21 | Efeitos visuais avançados (bloom, motion blur, FXAA) |
| [Interface] | 7 | HUD, radar, scoreboard, velocímetro |
| [Jack] | 5 | Negócios, personagem customizado, SMS, roleta |
| [Dexter] | 15 | Animações, veículos customizados, impressora, corridas |
| [paul] | 21 | Placas, caça, eventos esportivos, pets |
| [theMark] | 10 | DJ, oil business, usado de carros, ingresso |
| [Old] | 28 | Sistemas legados (não removidos, apenas arquivados) |

---

## Grafo de Dependências (Sistemas Críticos)

```
oCore ──────────────────────────────────────────── (Bootstrap)
  └── oMysql ──────────────────────────────────── (Banco de dados)
        └── oAccount ────────────────────────── (Auth, Registration)
              ├── oAdmin ─────────────────────── (Permissões)
              │     └── oAnticheat ────────────── (Verificação)
              └── [todos os outros recursos]
                    └── oInventory ─────────────── (Items/Slots)
                          ├── oInteraction ──────── (Usar items)
                          └── oVehicle ──────────── (Documentos)
                                └── oTuning ───────── (Personalização)
```

**Regra geral:** Qualquer recurso de gameplay depende indiretamente de `oMysql` → `oAccount` → personagem carregado. A sequência de boot deve garantir essa ordem.

---

## Componentes de Alto Risco

### CRÍTICO — Risco Imediato

| Componente | Problema | Localização |
|---|---|---|
| `oAccount/server.lua` | Credenciais armazenadas em plaintext na memória (`saver[]` table) | L688-692 |
| `oAccount/server.lua` | Ausência de rate limiting no login | L301-358 |
| `oAdmin/g_admin.lua` | Seriais hardcoded de administradores no código | L1-14 |
| `[Core]/oCore/server.lua` | Whitelist de desenvolvedores hardcoded | L5-24 |
| `oAccount/server.lua` | Validação de `source` inconsistente em event handlers | vários |

### ALTO — Risco Elevado

| Componente | Problema |
|---|---|
| `oAdmin/s_admin.lua` | Manipulação direta de grupos ACL sem auditoria adequada |
| `[Core]/oMysql` | Dependência single-point: falha derruba todos os recursos |
| `oInventory` | 21 scripts — alta complexidade, alta probabilidade de bugs ocultos |
| `oVehicle` | 23 scripts — sistema crítico com muitos estados |
| Múltiplos recursos | SQL queries não-parametrizadas misturadas com parametrizadas |

### MÉDIO — Dívida Técnica

| Componente | Problema |
|---|---|
| `[Old]` (28 recursos) | Código morto consumindo diretório, risco de uso acidental |
| `characters` (SQL) | Coluna `bones` como JSON em VARCHAR — sem validação de schema |
| Múltiplos | Nomes de variáveis em húngaro (e.g., `szefek`, `kresz`) |
| `factions.members` | Coluna com 7000 chars de dados relacionais em VARCHAR |

---

## Análise de Segurança

### Findings Críticos

**SEC-001 — Passwords em Plaintext na Memória**
- Arquivo: `oAccount/server.lua` linha ~688
- Descrição: A tabela `saver[]` concatena usuário e senha (`user..'-'..pass`) para fins de debug/login rápido. Esse dado permanece na memória do servidor durante toda a sessão.
- Impacto: Comprometimento total de credenciais via dump de memória ou log acidental.
- Ação: Eliminar completamente a tabela `saver[]`. Implementar token de sessão.

**SEC-002 — Ausência de Rate Limiting no Login**
- Arquivo: `oAccount/server.lua` — handler `loginOnServer`
- Descrição: Não há throttling de tentativas de login. Um cliente malicioso pode tentar milhares de combinações por segundo.
- Impacto: Brute-force de contas de jogadores.
- Ação: Implementar contador de falhas por IP/serial com backoff exponencial.

**SEC-003 — Seriais de Admin Hardcoded**
- Arquivos: `oAdmin/g_admin.lua`, `[Core]/oCore/server.lua`
- Descrição: Seriais de hardware de desenvolvedores e administradores estão no código-fonte.
- Impacto: Qualquer pessoa com acesso ao repositório conhece os seriais privilegiados.
- Ação: Migrar para tabela `adminserials` no banco (já existe no schema) com criptografia.

**SEC-004 — Source Validation Inconsistente**
- Arquivos: Múltiplos handlers de eventos cliente→servidor
- Descrição: Nem todos os `addEventHandler` de eventos clienteados validam se `source` é realmente um player element conectado.
- Impacto: Potencial para falsificação de eventos ou crashes via source inválido.
- Ação: Padronizar wrapper de validação para todos os handlers de cliente.

**SEC-005 — Consultas SQL Mistas (parametrizadas e não-parametrizadas)**
- Arquivos: `oAccount/server.lua` e outros
- Descrição: Algumas queries usam `?` corretamente, outras concatenam strings diretamente.
- Impacto: Risco de SQL injection nas queries não-parametrizadas.
- Ação: Auditar e parametrizar 100% das queries.

### Padrão de Permissões Atual

O sistema usa um modelo híbrido com três camadas:
1. **Serial do hardware** → identificação primária (via `getPlayerSerial()`)
2. **Element data** → estado em runtime (`getElementData(source, "user:loggedin")`)
3. **ACL groups do MTA** → permissões de recursos

Este modelo tem problemas: element data pode ser manipulado via sync, e serial pode ser falsificado em clientes modificados. O anticheat (`oAnticheat`) mitiga parcialmente, mas não elimina o risco.

---

## Hotspots de Performance

### DATABASE
- **`factions.members`** — VARCHAR(7000) com dados relacionais como JSON — leitura/escrita cara
- **`characters`** — 60+ colunas com múltiplos campos JSON (bones, adminDatas, weaponStats) — objeto grande por select
- **`items`** — AUTO_INCREMENT em 533.337 — tabela crescendo continuamente sem purge
- **`roulettes`** — AUTO_INCREMENT em 55.392 — alta frequência de insert/delete

### LUA RUNTIME
- `oInventory` (21 scripts) — sistema de items com alta frequência de eventos
- `oVehicle` (23 scripts) — estado de veículo sincronizado continuamente
- `[Shaders]` (21 recursos de shaders) — processamento visual cliente-side intensivo
- `hedit` (63 scripts) — editor world completo, possivelmente ativo em produção

### REDE
- Element data sincronizados globalmente para todos os jogadores — `setElementData` sem `broadcast=false` envia para todos
- Eventos de veículo e posição potencialmente excessivos sem throttling

---

## Oportunidades de Refatoração (Prioritizadas)

| Prioridade | Recurso | Tipo | Impacto |
|---|---|---|---|
| P0 | `oAccount` | Security hardening | Crítico |
| P0 | `oAdmin` | Security hardening | Crítico |
| P1 | `oMysql` | Wrapper + error handling | Alta disponibilidade |
| P1 | `oInventory` | Modularização, testes | Estabilidade |
| P2 | `oVehicle` | Performance, modularização | Performance |
| P2 | `oCore` | Remoção de whitelist hardcoded | Segurança |
| P3 | `oPhone` | Tradução + modernização | UX |
| P3 | `[Old]` | Arquivamento e remoção | Manutenibilidade |
| P4 | `[Shaders]` | Revisão de performance cliente | Performance |
| P4 | `oInteriors` | Schema normalização | Escalabilidade |

---

## Escopo de Tradução

### Volume Estimado

| Categoria | Arquivos Lua | Strings Estimadas | Complexidade |
|---|---|---|---|
| oAccount | ~4 | ~150 | Alta (auth messages) |
| oAdmin | ~14 | ~400 | Muito alta (comandos, logs) |
| oInventory | ~21 | ~300 | Alta (items, slots) |
| oVehicle | ~23 | ~250 | Alta |
| oPhone | ~7 | ~200 | Média |
| [Interface] | ~29 | ~180 | Média (HUD, radar) |
| [Jobs] | ~71 | ~350 | Média |
| [Carlos] ~armas/veículos | ~100 | ~500 | Média |
| oChat | ~? | ~50 | Baixa |
| [Old] | 112 | N/A | Não traduzir (deprecado) |

**Total estimado:** ~3.000–4.000 strings traduzíveis em toda a codebase ativa.

---

## Próximas Ações Recomendadas

### Semana 1 — Segurança Crítica
1. `[SEC-001]` Eliminar tabela `saver[]` em `oAccount/server.lua`
2. `[SEC-002]` Implementar rate limiting no handler `loginOnServer`
3. `[SEC-003]` Migrar admin serials hardcoded para banco de dados
4. Criar branch `security/oAccount` para essas correções

### Semana 2 — Fundação
5. Auditar 100% das queries SQL por injection
6. Padronizar validação de `source` em todos os event handlers
7. Criar template de event handler seguro como referência

### Semana 3-4 — Tradução Fase 1
8. Iniciar tradução de `oAccount` (autenticação é o primeiro contato do jogador)
9. Iniciar tradução de `oDashboard` e `[Interface]`

### Contínuo
10. Arquivar grupo `[Old]` (mover para pasta separada fora do gamemode)
11. Normalizar colunas JSON no banco (factions.members, characters.bones)
12. Documentar cada recurso crítico em `docs/resources/`

---

## Avaliação Geral

| Dimensão | Nota | Comentário |
|---|---|---|
| Funcionalidade | 9/10 | Base extremamente completa e madura |
| Segurança | 3/10 | Múltiplos vetores de ataque identificados |
| Manutenibilidade | 5/10 | Estrutura modular mas padrões inconsistentes |
| Performance | 6/10 | Funcional, mas sem otimização deliberada |
| Documentação | 2/10 | Quase nenhuma documentação técnica |
| Localização | 0/10 | Totalmente em húngaro — zero strings em PT-BR |

**Veredicto:** Base sólida, risco de segurança inaceitável para produção. Modernização incremental é o caminho correto. Não reescrever.
