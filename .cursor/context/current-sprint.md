---
type: cursor-context
updated: 2026-05-02
---

# Sprint Atual — Cursor Context

## Sprint: TD-SEC-006 + **Sprint B (100%)** + Sprint B.1 + **Sprint B.2** + **Sprint C (auditoria)**
**Branch:** trabalho local conforme o mantenedor  
**Status:** **Sprint C concluído (auditoria apenas)** — relatório `docs/qa/pre-test-audit.md`: **GO condicional** para testes locais nas áreas já entregues; **NO-GO** para critério de zero húngaro global no gamemode. Nenhuma alteração a lógica de jogo nesta sprint.

**Sprint B.2 (referência):** últimas strings húngaras **visíveis ao jogador** nos ficheiros alvo foram traduzidas para PT-BR (Ipiranga Roleplay), sem alterar lógica de jogo, eventos, exports, anticheat, `triggerHack`, salt `_OriginalRP` nem tabelas de mapeamento de teclado.

---

## Sprint B.2 — UI final (2026-05-01)

### Ficheiros modificados
| Ficheiro | Alteração |
|----------|-----------|
| `oDashboard/bugReportC.lua` | Lista de bugs (subtítulo), tooltip “copiar URL”, “Data do envio”, “Enviado por” + largura do tooltip alinhada ao novo texto |
| `oDashboard/openCreate.lua` | Botão “Abrir”, janela “Itens disponíveis”, rótulos de slots (imóvel/veículo), mensagens `outputChatBox` das caixas |
| `oDashboard/panels/options.lua` | Títulos “Configurações”, mensagem fora de época natalina, “Padrão” no slider; comparações de opções de neve alinhadas a `global.lua` (`Neve`, `Intensidade da neve`); “Desligado” no lugar de “Ki” |
| `[Interface]/oRadar/sourceC.lua` | Fallback de tooltip `"Sem dados"` (2 ocorrências) |

### Strings traduzidas (resumo)
- Bug list: descrição da lista; rótulos de envio/data; acção de cópia de URL da imagem.
- Caixas: “Abrir”, painel de loot, slots de imóvel/veículo, cinco variantes de mensagem no chat ao abrir caixa.
- Opções: cabeçalhos do painel, aviso natalino, texto do slider vazio, rótulo “Desligado”; **correção de consistência**: condições que ainda comparavam nomes HU com dados já em PT em `options` (neve).

### Validação B.2
- `loadfile` / sintaxe Lua 5.1 nos quatro ficheiros: OK.
- Grep nos ficheiros alvo: sem restos HU óbvios (`Nincs adat`, `Beállítások`, `Kinyitottál`, etc.).

---

## Sprint B.1 (referência)
Comentários e `outputDebugString` não–player-facing → PT-BR nos recursos first-party já listados em sessões anteriores.

---

## Sprint B — percentual final
- **Sprint B (localização UI first-party mantida):** **100%** nos âmbitos B + B.1 + B.2 entregues.
- **QA in-game:** recomendado validar layout (comprimento de strings) no painel de opções, lista de bugs (admin) e abertura de caixas.

## Próximas ações
1. QA in-game em HUD/radar/dashboard.
2. Produção: migração `td_sec_006_password_salt` onde aplicável.
3. Varredura ocasional em recursos não listados (fora do âmbito deste sprint) se surgirem forks antigos com HU.

---

## ECC — integração mínima (2026-05-02)

**Modo:** compatibilidade mínima; **sem** sobrescrever regras, `CLAUDE.md`, ou conteúdo de sprint acima.

| Instalado | Caminho |
|-----------|---------|
| Índice de agentes | `AGENTS.md` (raiz) |
| Memória | `.cursor/memory/project-state.md` |
| Comandos | `.cursor/commands/ecc-context.md`, `ecc-workflow.md`, `ecc-memory.md`, `ecc-docs.md` |
| Agentes | `.cursor/agents/ecc-documentation-helper.md`, `ecc-workflow-helper.md` |
| Hooks | `.cursor/hooks/ecc-no-hooks.md` (doc: **sem** `hooks.json`) |
| Documentação | `docs/cursor/ecc-integration.md` |

**Excluído:** hooks runtime, MCP, agentes TS/Python/Node do upstream, automações pesadas. Ver `docs/cursor/ecc-integration.md`.

---

## Sprint C — pré-auditoria pré-teste (2026-05-02)

| Entregável | Caminho |
|------------|---------|
| Relatório formal | `docs/qa/pre-test-audit.md` |
| Memória atualizada | `.cursor/memory/project-state.md` |

**Resumo:** HU remanescente catalogado (crítico: `oAdmin`, `oPhone`, `oDrugs`, `oBank`, `oCore` amostra; médio/baixo: comentários, variáveis legadas, teclas `ő`/`ű`). Integridade TD-SEC-006 + login legado + `_OriginalRP` verificada por inspecção (sem modificar `triggerHack`). Sintaxe Lua amostrada com `loadfile` — OK.
