# Ipiranga Roleplay

Servidor de **roleplay** para **Multi Theft Auto: San Andreas (MTA:SA)**, público **brasileiro**, com gamemode próprio mantido neste repositório.

| | |
|---|---|
| **Repositório** | `git@github.com:WendeelMarinho/viladoipirangarp.git` |
| **Motor** | MTA:SA 1.x |
| **Linguagem** | Lua 5.1 (cliente e servidor) |
| **Dados** | MySQL 5.7+ / MariaDB compatível |
| **Estado** | Desenvolvimento ativo — segurança, tradução PT-BR, hardening |

---

## Propriedade e linhagem

**Ipiranga Roleplay** é o produto e o código-base **proprietários** da equipe — incluindo o conteúdo deste repositório. O gamemode evoluiu a partir de uma **base histórica** do ecossistema **OriginalRoleplay** (MTA, 2019–2023), hoje **absorvida e operada** sob a marca, regras e roadmap **Ipiranga**. Referências técnicas legadas (nomes de salt em hash, arquivos `triggerHack.lua`, etc.) mantêm-se onde necessário para **compatibilidade entre recursos**, não como dependência de terceiros.

---

## O que o servidor é

- **Simulação de cidade** persistente: contas, personagens, economia, facções, empregos, veículos, imóveis, inventário e interações administrativas.
- **Cliente MTA** de cada jogador executa scripts **client-side** (UI, efeitos, predição leve); o **servidor dedicado** é a autoridade (estado, DB, validação, anti-abuso).
- **Monólito modular**: centenas de **recursos** MTA (`meta.xml` + scripts Lua), cada um com responsabilidade delimitada, ligados por **exports** e **eventos remotos**.

---

## Visão geral técnica

### Backend (servidor)

| Camada | Descrição |
|--------|-----------|
| **Scripts servidor** | Lua 5.1 por recurso (`*_S.lua`, `server.lua`, etc.), eventos `addEvent` / `addEventHandler`, timers, persistência. |
| **Autoridade** | Validação de inputs, permissões, economia, facções, veículos — **sempre** no servidor; `source` validado como jogador em handlers cliente→servidor. |
| **MySQL** | Um canal de conexão reutilizável via **`exports.oMysql:getDBConnection()`** — não criar conexões ad-hoc por recurso. |
| **Persistência** | Tabelas de contas, personagens, veículos, inventário, logs, etc. (schema de referência `orp_main.sql` + migrações em `sql/migrations/`). |

### Frontend (cliente)

| Camada | Descrição |
|--------|-----------|
| **Interface DX** | Desenho com `dxDraw*`, fontes via `exports.oFont`, animações e painéis (ex.: **oDashboard**, lojas, facções). |
| **Pacote [Interface]** | HUD, radar, placar, infobox, mira, velocímetro, editor de layout (**oInterface**), entre outros recursos sob `[Interface]/`. |
| **Estado local** | `elementData`, variáveis globais do recurso, sons e câmera — sempre subordinado ao que o servidor confirma em eventos. |

### “APIs” no ecossistema MTA

Não há REST exposto pelo gamemode em si: a **API pública** entre partes do código são:

1. **Exports** — `exports.nomeDoRecurso:nomeDaFuncao(...)` (contrato estável; **não renomear** sem migração).
2. **Eventos remotos** — `triggerClientEvent` / `triggerServerEvent` com nomes estáveis (muitos ofuscados via `triggerHack.lua` / `antiHook.lua` + salt `_OriginalRP` por recurso).
3. **ACL / serial** — desenvolvedores e admins reconhecidos via `oAdmin` + dados em BD (`adminserials`, `user:admin`, duty).

Lista de exports críticos e boot: **`.cursor/context/architecture.md`**.

---

## Arquitetura de recursos

### Hierarquia de arranque (ordem lógica)

```
oCore (bootstrap, FPS, IDs)
  → oMysql (conexão MySQL singleton)
    → oAccount (autenticação, personagem, save)
      → oAdmin e restantes recursos (oInventory, oVehicle, oDashboard, [Interface], …)
```

- **`[Core]/`** — núcleo (`oCore`, `oMysql`, `oChat`, `oAnticheat`, shaders globais, etc.).
- **Raiz e pastas temáticas** — `oAccount/`, `oDashboard/`, `oPhone/`, `[Jobs]/`, `[Maps]/`, `[Interface]/`, etc.
- **`[Old]/`** — legado desactivado / referência; **não** usar como base para features novas.

### Modelo de permissões (resumo)

- Serial registado em **`adminserials`** (BD) → developer (`aclLogin`).
- `user:admin` ≥ 1 → níveis de staff; **`isPlayerInAdminDuty`** para ações em serviço.
- **`exports.oAnticheat:checkPlayerVerifiedAdminStatus`** em fluxos sensíveis.

### Estado de sessão (exemplos de `element data`)

| Chave | Uso |
|-------|-----|
| `user:loggedin` | Conta autenticada |
| `user:id` / `char:id` | IDs no MySQL |
| `user:admin` | Nível administrativo |
| `char:money` / `char:pp` | Economia |
| `aclLogin` | Developer autorizado |

Detalhe: **`.cursor/context/architecture.md`**.

---

## Infraestrutura de deploy

| Componente | Notas |
|------------|--------|
| **Servidor dedicado MTA** | Linux ou Windows; [documentação MTA](https://wiki.multitheftauto.com/wiki/Main_Page). |
| **Pasta de resources** | Clone do repo na árvore de recursos do servidor (`mods/deathmatch/resources/` ou equivalente). |
| **`mtaserver.conf`** | Lista de `start` / dependências; pode subir subconjuntos em **dev**. |
| **MySQL** | Instância acessível ao host do servidor; credenciais no recurso **oMysql** (ou config do teu ambiente). |
| **Backup** | BD + arquivos de configuração antes de migrações em produção. |

### Instalação rápida

1. `git clone git@github.com:WendeelMarinho/viladoipirangarp.git`
2. Importar **`orp_main.sql`** (ajustar nome da base).
3. Aplicar **`sql/migrations/td_sec_006_password_salt.sql`** em bases já existentes (coluna `password_salt` em `accounts`).
4. Configurar **oMysql** e subir **`oCore` → `oMysql` → `oAccount`** antes dos restantes.

---

## Segurança e autenticação

### TD-SEC-006 — senhas com salt (SHA-256), compatível com legado

| Etapa | Comportamento |
|--------|----------------|
| **Cliente** | Envia `SHA256("originalRoleplayAccount" .. senha .. "2k20")` — contrato legado **inalterado** no client. |
| **Servidor** | Armazena `SHA256(legacy_client_hash .. password_salt)` com salt hex de 32 caracteres. |
| **Contas antigas** | `password_salt` nulo: login legado; após sucesso, **migração lazy** para hash salgado. |
| **Novos / troca de senha** | Hash salgado + salt desde o registo. |

Ficheiros: `oAccount/server.lua`, `sql/migrations/td_sec_006_password_salt.sql`, `orp_main.sql`.

### Outras linhas de hardening

Rate limiting de login, remoção de cache de senha em texto, validação de `source`, listas sensíveis em BD (`oAdmin`, `oCore`) — ver **`docs/worklog/`**, **`docs/security/`**, **`docs/technical-debt-report.md`**.

---

## Domínios de jogo (o que existe no repo)

| Domínio | Recursos / pastas (exemplos) |
|---------|-------------------------------|
| **Conta e personagem** | `oAccount/` |
| **Painel do jogador** | `oDashboard/` (loja, facções, patrimônio, opções, bug report) |
| **Inventário e economia** | `oInventory/`, `oBank/`, `oPayday/`, `oShop/`, … |
| **Veículos e mundo** | `oVehicle/`, `oTuning/`, `oCarshop/`, mapas em `[Maps]/` |
| **Interface** | `[Interface]/oHud`, `oRadar`, `oScoreboard`, `oInterface`, … |
| **Empregos** | `[Jobs]/oJob_*` |
| **Administração** | `oAdmin/` |
| **Anti-abuso** | `[Core]/oAnticheat/` (revisão cuidadosa antes de produção pública) |

Priorização e tiers: **`docs/prioritized-resource-list.md`**.

---

## Tradução e idioma (PT-BR)

| Área | Estado (alto nível) |
|------|---------------------|
| `oAccount` | Sprint A — UI jogador em PT-BR |
| `oDashboard` | Sprints B / B.1 / B.2 nas áreas priorizadas; revisão contínua em `client.lua` e restantes |
| `[Interface]` | Parcial — vários módulos já em PT-BR |
| **Restante** | `docs/translation-roadmap.md` |

**Marca:** **Ipiranga Roleplay** na UI. Pré-auditoria pré-teste: **`docs/qa/pre-test-audit.md`**.

---

## Documentação no repositório

| Documento | Conteúdo |
|-----------|----------|
| [**docs/CLAUDE.md**](docs/CLAUDE.md) | Regras do projeto, handlers, branches (canônico) |
| [**CLAUDE.md**](CLAUDE.md) (raiz) | Entrada Claude Code / Cursor → `docs/CLAUDE.md` |
| [**docs/README.md**](docs/README.md) | Índice da pasta `docs/` |
| [**docs/translation-roadmap.md**](docs/translation-roadmap.md) | Roadmap PT-BR |
| [**docs/technical-debt-report.md**](docs/technical-debt-report.md) | Dívida técnica e riscos |
| [**docs/prioritized-resource-list.md**](docs/prioritized-resource-list.md) | Priorização de recursos |
| [**docs/relatorio-tecnico.md**](docs/relatorio-tecnico.md) | Relatório técnico / auditoria |
| [**docs/worklog/**](docs/worklog/) | Sprints e próximas ações |
| [**docs/cursor/ecc-integration.md**](docs/cursor/ecc-integration.md) | ECC em modo mínimo (Cursor / Claude) |
| [**docs/qa/pre-test-audit.md**](docs/qa/pre-test-audit.md) | Auditoria pré-teste (GO/NO-GO) |
| [**AGENTS.md**](AGENTS.md) | Índice de agentes + ECC `ecc-*` |
| [**`.cursor/context/architecture.md`**](.cursor/context/architecture.md) | Dependências e exports críticos |

---

## Fluxo de desenvolvimento

- Branches: `security/…`, `translation/…`, `refactor/…`, `docs/…`
- **Não renomear** exports, eventos públicos ou schema SQL sem coordenação e migração.
- **SQL** sempre parametrizado (`?` com `dbQuery` / `dbExec`).
- **Handlers remotos:** validar `source` como jogador.
- **`.gitignore`:** pastas locais de IA (`.ai/`, `.claude/`); **`.cursor/`** pode ser versionada com regras da equipa.

---

## Roadmap (alto nível)

1. Continuar **tradução** e revisão de UI (`docs/translation-roadmap.md`).
2. **QA in-game** alinhado a `docs/qa/pre-test-audit.md`.
3. Auditoria global de **SQL** e **`source`** em eventos remotos.
4. Hardening contínuo (**oAdmin**, **oMysql**, **oAnticheat**) e release pública **Ipiranga Roleplay**.

---

## Equipa e contacto

**Wendeel Marinho**  
- LinkedIn: https://www.linkedin.com/in/wendeelm  
- GitHub: https://github.com/WendeelMarinho  

Repositório: `git@github.com:WendeelMarinho/viladoipirangarp.git`

---

## Créditos técnicos (linhagem)

A arquitetura original do gamemode MTA beneficia do trabalho da comunidade e dos autores do **OriginalRoleplay** (2019–2023). O **Ipiranga Roleplay** mantém, evolui e distribui o código sob sua própria operação e responsabilidade.

---

*Ajuste fórum, Discord, IP do servidor, `mtaserver.conf` e políticas comerciais conforme o teu ambiente de produção.*
