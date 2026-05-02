# Ipiranga Roleplay

Servidor de **roleplay** para **Multi Theft Auto: San Andreas (MTA:SA)**, voltado ao público **brasileiro**. O gamemode moderniza uma base histórica do ecossistema **OriginalRoleplay** (2019–2023), com foco em **segurança**, **tradução PT-BR** e identidade **Ipiranga Roleplay**.

| | |
|---|---|
| **Repositório** | `git@github.com:WendeelMarinho/viladoipirangarp.git` |
| **Stack** | MTA:SA 1.x · Lua 5.1 · MySQL |
| **Estado** | Desenvolvimento ativo (modernização + tropicalização) |

---

## Visão geral

O projeto é um **gamemode completo** de RP: contas e personagens, economia, inventário, veículos, imóveis, facções, empregos, interface (HUD, radar, placar), administração e integrações com banco de dados. A arquitetura segue o padrão clássico de recursos MTA (`meta.xml`, cliente/servidor, exports entre recursos).

---

## Funcionalidades

- Autenticação de contas, criação/carregamento de personagens, integração **MySQL**
- **oDashboard**: painel do jogador, loja premium, facções, patrimônio, configurações
- **Interface**: HUD, radar, placar, infobox, mira, velocímetro, editor de layout (`oInterface`)
- **oAdmin** / **oCore**: permissões, serials de desenvolvedor, whitelist e boot do servidor
- **oAnticheat** e padrões de **eventos remotos** com validação de `source`

---

## Requisitos

- [Servidor dedicado MTA:SA](https://wiki.multitheftauto.com/wiki/Main_Page) (Linux ou Windows)
- **MySQL** 5.7+ ou MariaDB compatível
- Cliente MTA:SA atualizado (jogadores)

---

## Instalação (resumo)

1. **Clone** o repositório na pasta de recursos do servidor (ex.: `mods/deathmatch/resources/` ou a árvore que o seu `mtaserver.conf` usa).

   ```bash
   git clone git@github.com:WendeelMarinho/viladoipirangarp.git
   ```

2. **Banco de dados**
   - Importe o schema de referência: **`orp_main.sql`** (ajuste o nome do database se necessário).
   - Em bases **já existentes**, aplique a migração de senhas: **`sql/migrations/td_sec_006_password_salt.sql`** (coluna `password_salt` na tabela `accounts`).

3. **MySQL** — configure usuário, senha e host no recurso **`oMysql`** (ou no mecanismo de config que o seu fork usar).

4. **Ordem de start recomendada** (dependências críticas):

   `oCore` → `oMysql` → `oAccount` → demais recursos.

   Detalhes de dependências e exports críticos: **`.cursor/context/architecture.md`** (no repositório) e **`docs/CLAUDE.md`**.

5. Ative os recursos no **`mtaserver.conf`** conforme a lista do seu deploy (não é obrigatório subir todos os recursos de uma vez em ambiente de teste).

---

## Fluxo de desenvolvimento

- Branches por tema: `security/…`, `translation/…`, `refactor/…`, `docs/…`
- **Não renomear** exports, eventos ou comandos públicos sem coordenação e migração.
- Preferir mudanças **pequenas e reversíveis**; manter compatibilidade com jogadores e com o banco em produção.
- **SQL**: usar sempre queries **parametrizadas** (`dbQuery` / `dbExec` com `?`).
- **Handlers cliente → servidor**: validar `source` como jogador (`isElement`, `getElementType`).

---

## Segurança (modernização)

### TD-SEC-006 — senhas com salt (SHA-256), compatível com legado

| Etapa | Comportamento |
|--------|----------------|
| **Cliente** | Continua enviando apenas `SHA256("originalRoleplayAccount" .. senha .. "2k20")` — **sem alteração no client.** |
| **Servidor** | Armazena `SHA256(legacy_client_hash .. password_salt)` com salt **hex de 32 caracteres**. |
| **Contas antigas** | `password_salt` nulo: login igual ao legado; após sucesso, **migração lazy** (gera salt e atualiza hash). |
| **Novos cadastros / troca de senha** | Já gravam hash salgado + salt. |

**Arquivos-chave:** `oAccount/server.lua`, `sql/migrations/td_sec_006_password_salt.sql`, coluna em `orp_main.sql`.

### Outras linhas de hardening (contexto)

- Rate limit de login, remoção de cache de senha em texto, validação de `source` em auth, migração de listas sensíveis para banco (`oAdmin`, `oCore`), etc. — ver worklog em **`docs/worklog/`** e **`docs/security/`** quando existirem.

### Repositório e pastas locais

- **`.gitignore`** ignora pastas de assistentes locais (ex.: **`.ai/`**, **`.claude/`**) para não poluir o histórico.
- A pasta **`.cursor/`** pode ser versionada com regras e contexto do time (ajuste o `.gitignore` se quiser ignorá-la).

---

## Tradução (PT-BR)

| Área | Status |
|------|--------|
| `oAccount` | Sprint A — textos ao jogador em PT-BR |
| `oDashboard` | Em progresso (`global.lua`, servidor de compras, bug report, etc.; ainda há strings em `client.lua` / facções) |
| `[Interface]` | Parcial (`oInterface`, `oScoreboard`, …) |
| Restante do gamemode | Roadmap (ver `docs/translation-roadmap.md`) |

**Marca:** **Ipiranga Roleplay** na UI. A string técnica em vários `triggerHack.lua` / `antiHook.lua` (`_OriginalRP`) permanece por **compatibilidade** com o mecanismo de nomes ofuscados entre recursos.

---

## Documentação no repositório

| Documento | Conteúdo |
|-----------|----------|
| [**docs/CLAUDE.md**](docs/CLAUDE.md) | Regras do projeto, handlers, ordem de refatoração, branches |
| [**docs/translation-roadmap.md**](docs/translation-roadmap.md) | Glossário e fases de tradução |
| [**docs/technical-debt-report.md**](docs/technical-debt-report.md) | Dívida técnica e itens de segurança/arquitetura |
| [**docs/prioritized-resource-list.md**](docs/prioritized-resource-list.md) | Priorização de recursos |
| [**docs/relatorio-tecnico.md**](docs/relatorio-tecnico.md) | Relatório técnico / auditoria (quando aplicável) |
| [**docs/worklog/**](docs/worklog/) | Sprints e próximas ações |

Índice da pasta `docs/`: [**docs/README.md**](docs/README.md).

---

## Roadmap (alto nível)

1. Completar tradução em **`oDashboard/client.lua`** e **`oDashboard/faction/*`**
2. Completar **`[Interface]`** (HUD, radar, infobox, speedo, etc.)
3. Auditoria global de **SQL** e de **`source`** em eventos remotos
4. Hardening contínuo e release pública **Ipiranga Roleplay**

---

## Créditos e base

**Base gamemode:** comunidade e autores do **OriginalRoleplay** (MTA), 2019–2023 — código legado modernizado para o contexto brasileiro deste fork.

**Repositório e fork Ipiranga Roleplay**

**Wendeel Marinho**  
LinkedIn: https://www.linkedin.com/in/wendeelm  
GitHub: https://github.com/WendeelMarinho  

Repositório: `git@github.com:WendeelMarinho/viladoipirangarp.git`

---

*Ajuste fórum, Discord, valores comerciais e `mtaserver.conf` conforme o seu ambiente de produção.*
