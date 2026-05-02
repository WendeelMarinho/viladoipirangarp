# Integração ECC (Everything Claude Code) — modo mínimo IpirangaRP

**Data da integração:** 2026-05-02  
**Modo:** compatibilidade mínima, **aditivo apenas** (sem substituir regras ou fluxo Ipiranga).

## Objectivo

Trazer **ECC Core** como camada de augmentação para **Claude Code** e **Cursor**, num projecto **Lua / MTA:SA**, sem o pacote completo do upstream (agentes por linguagem, hooks intrusivos, MCP, etc.).

## O que foi instalado (componentes)

| Componente | Localização | Função |
|------------|-------------|--------|
| Entrada de agentes | [`AGENTS.md`](../../AGENTS.md) na raiz | Aponta para docs Ipiranga + agentes/comandos `ecc-*`. |
| Memória de projecto | [`.cursor/memory/project-state.md`](../../.cursor/memory/project-state.md) | Estado do sprint, marcos, sistemas protegidos. |
| Comandos (scaffolding) | [`.cursor/commands/ecc-context.md`](../../.cursor/commands/ecc-context.md), `ecc-workflow.md`, `ecc-memory.md`, `ecc-docs.md` | Atalhos de leitura / lembrete de workflow (slash commands no Cursor). |
| Agentes mínimos | [`.cursor/agents/ecc-documentation-helper.md`](../../.cursor/agents/ecc-documentation-helper.md), `ecc-workflow-helper.md` | Descrições para subagentes alinhados a Lua/MTA e documentação. |
| Hooks | [`.cursor/hooks/ecc-no-hooks.md`](../../.cursor/hooks/ecc-no-hooks.md) | **Documentação apenas:** confirma que não há `hooks.json` nem hooks intrusivos. |

**Prefixo obrigatório:** todos os artefactos ECC neste repo usam o prefixo **`ecc-`** no nome do ficheiro (excepto `AGENTS.md`, que é o índice nativo do ecossistema).

## O que foi deliberadamente excluído

- Agentes e regras **TypeScript / Python / Node** do ECC upstream  
- **`hooks.json`** e scripts de hook em runtime (formatação automática, bloqueios de shell, etc.)  
- **MCP** e integrações pesadas  
- **Automações** que alterem commits ou o worktree sem confirmação humana  

Para instalação “completa” do ECC oficial, ver [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) **noutro** clone ou com prefixo explícito — não misturar com este modo mínimo sem revisão.

## Estratégia de coexistência

1. **Fonte de verdade** continua a ser: `docs/CLAUDE.md`, `.cursor/rules/*.md`, `.cursor/context/`, `docs/worklog/`.  
2. **ECC** fornece: comandos opcionais, ficheiro de memória, agentes descritivos com prefixo `ecc-`.  
3. **Nunca** sobrescrever ficheiros existentes do Ipiranga ao actualizar ECC; apenas adicionar ou editar ficheiros `ecc-*` e esta documentação.  
4. **`project-state.md`** pode ser actualizado manualmente ou por agentes ao fechar tarefas — não substitui `docs/worklog/current-sprint.md` (histórico formal).

## Directrizes de uso (Claude e Cursor)

### Antes de uma sessão

- Ler `docs/CLAUDE.md` e `.cursor/context/current-sprint.md`.  
- Opcional: abrir `.cursor/memory/project-state.md` para estado resumido.

### Durante o trabalho

- Seguir **sempre** `.cursor/rules/project-rules.md`, `security.md`, `translation.md`.  
- Usar comandos **`/ecc-*`** (Cursor) só como lembrete de caminhos — não alteram o repo.  
- Invocar agentes `ecc-*` apenas para tarefas que não conflitem com “não tocar em anticheat / triggerHack / exports”.

### Ao integrar mais ECC no futuro

- Preferir `npx ecc2cursor` ou instalador oficial com **`--prefix ecc`** ou equivalente.  
- Revalidar que nada sobrescreve `CLAUDE.md`, `docs/CLAUDE.md`, ou regras `.cursor/rules/` sem PR dedicado.
