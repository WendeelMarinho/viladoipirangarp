# Ipiranga Roleplay

Servidor de roleplay para **Multi Theft Auto: San Andreas (MTA:SA)** voltado ao público brasileiro, com economia, facções, veículos, imóveis e sistemas clássicos de RP premium. O projeto moderniza uma base histórica do ecossistema **OriginalRoleplay** (2019–2023), com foco em **segurança**, **tradução PT-BR** e **identidade Ipiranga Roleplay**.

**Repositório:** `git@github.com:WendeelMarinho/viladoipirangarp.git`

---

## Funcionalidades (visão geral)

- Autenticação de contas, personagens, inventário e economia integrados ao MySQL
- Painel do jogador (dashboard), loja premium, facções, veículos e imóveis
- Interface modular (HUD, radar, placar, infobox, mira, velocímetro)
- Permissões administrativas e anticheat acoplados aos recursos do gamemode

---

## Stack tecnológica

| Camada | Tecnologia |
|--------|------------|
| Cliente / servidor | MTA:SA 1.x, Lua 5.1 |
| Banco de dados | MySQL (via recurso `oMysql`) |
| Mapas / modelos | Recursos MTA padrão + pacotes do gamemode |

---

## Instalação

1. Instale um servidor MTA:SA dedicado conforme a [documentação oficial](https://wiki.multitheftauto.com/wiki/Main_Page).
2. Clone o repositório (ou extraia o arquivo) na pasta `resources` do servidor (ou use `mods/deathmatch/resources`).
3. Importe o schema inicial do banco (ajuste nome do database se necessário):

   - Arquivo de referência: `orp_main.sql`
   - **Obrigatório para TD-SEC-006:** aplique também `sql/migrations/td_sec_006_password_salt.sql` em bases **já existentes** (adiciona a coluna `password_salt`).

4. Configure credenciais MySQL no recurso de conexão (`oMysql` / configuração do seu ambiente).
5. Garanta a ordem de start: `oCore` → `oMysql` → `oAccount` → demais recursos (ver [`docs/CLAUDE.md`](CLAUDE.md) e `.cursor/context/architecture.md`).

---

## Fluxo de desenvolvimento

- Trabalhe em branches curtas por tema (ex.: `security/oAccount-…`, `translation/oDashboard`).
- **Não renomeie** exports, eventos ou comandos públicos sem migração coordenada.
- Prefira alterações **cirúrgicas**; mantenha compatibilidade com jogadores e com o banco em produção.
- SQL sempre **parametrizado** em `dbQuery` / `dbExec`; handlers cliente→servidor devem validar `source` como jogador.

---

## Modernização de segurança

### TD-SEC-006 — senhas com salt (SHA-256)

- O cliente continua enviando apenas o hash legado:  
  `SHA256("originalRoleplayAccount" .. senhaPlana .. "2k20")` — **sem mudança no client.**
- O servidor passa a armazenar:  
  `SHA256(legacy_client_hash .. password_salt)` com `password_salt` de **32 caracteres hexadecimais**.
- Contas antigas (`password_salt` nulo): login compara com o hash legado armazenado; após login bem-sucedido ocorre **migração preguiçosa** (gera salt, atualiza hash e coluna).
- Novos cadastros e troca de senha (fluxo já existente) já gravam hash salgado e salt.

Arquivos principais: `oAccount/server.lua`, `sql/migrations/td_sec_006_password_salt.sql`, coluna em `orp_main.sql`.

### Outras medidas (contexto do projeto)

- Rate limit de login, remoção de cache de senha em texto, hardening de handlers de auth e migração de listas sensíveis para banco (`oAdmin`, `oCore`), conforme sprints anteriores documentadas no contexto Cursor.

---

## Tradução (PT-BR)

| Área | Status |
|------|--------|
| `oAccount` | Concluído (Sprint A) |
| `oDashboard` + textos globais do painel | Em progresso neste repositório (labels, premium, bug report, servidor de compras) |
| `[Interface]` (`oInterface`, `oScoreboard`, …) | Parcial: textos de edição de HUD, placar e widgets padrão |
| Demais recursos | Roadmap |

Texto de marca: uso de **Ipiranga Roleplay** no painel (ex.: cabeçalho do dashboard). A string técnica compartilhada em `triggerHack.lua` / `antiHook.lua` (`_OriginalRP`) **não foi alterada** para manter compatibilidade com o sistema de nomes ofuscados entre recursos.

---

## Roadmap

1. Concluir varredura de strings em `oDashboard/client.lua` e subpastas (`faction`, `panels`).
2. Completar `[Interface]` (HUD, radar, infobox, speedo) onde ainda houver HU/EN visível ao jogador.
3. Auditoria global de SQL e de `source` em eventos remotos.
4. Hardening contínuo e preparação de release pública Ipiranga Roleplay.

---

## Créditos

**Base gamemode:** comunidade e autores originais do **OriginalRoleplay** (MTA), 2019–2023 — uso do código legado com modernização local.

**Repositório e fork Ipiranga Roleplay**

Wendeel Marinho  
LinkedIn: https://www.linkedin.com/in/wendeelm  
GitHub: https://github.com/WendeelMarinho  

Repositório: `git@github.com:WendeelMarinho/viladoipirangarp.git`

---

*Documentação gerada para alinhamento do projeto Ipiranga Roleplay; ajuste URLs de fórum/Discord e valores comerciais conforme o deploy oficial.*
