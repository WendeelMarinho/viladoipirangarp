---
type: cursor-context
updated: 2026-05-01
---

# Sprint Atual — Cursor Context

## Sprint: TD-SEC-006 + Sprint B (Dashboard / Interface)
**Branch:** trabalho local em `main` / branch de feature conforme preferência do mantenedor  
**Status:** TD-SEC-006 implementado; Sprint B parcialmente entregue (tradução PT-BR em `oDashboard/global.lua`, `dashServer.lua`, `bugReportC.lua`, branding no `client.lua`; `[Interface]` em `oInterface` + `oScoreboard`)

## Concluído nesta sprint

### TD-SEC-006 — senhas salgadas (compatível com legado)
- Coluna `password_salt VARCHAR(32) NULL` documentada em `orp_main.sql` e script `sql/migrations/td_sec_006_password_salt.sql`
- Helpers: `generatePasswordSalt()` (32 hex), `computeSaltedPassword()`, `accountUsesLegacyPasswordRow()`
- Login: `SELECT` por usuário; verificação legado (`password_salt` vazio/nulo) ou `SHA256(legacyHash .. salt)`; **migração lazy** após sucesso
- Registro e `passwordChange`: gravam hash salgado + salt (sem alterar hash no cliente)
- **Não** alterado: prefixo `originalRoleplayAccount`…`2k20` no client

### Sprint B — tropicalização / PT-BR (parcial)
- Dashboard: páginas, estatísticas, opções, facções, premium, daily gifts, tuning, `dashServer`, painel de bug report, texto de recrutamento
- Interface: widgets padrão em `oInterface/global.lua`, textos de edição em `oInterface/client.lua`, cabeçalhos em `oScoreboard/client.lua`
- `triggerHack` / salts `_OriginalRP` **intactos** (acoplamento ao anticheat)

### Documentação
- `README.md` reescrito (overview, stack, instalação, segurança, tradução, roadmap, créditos)
- Este arquivo `.cursor/context/current-sprint.md` atualizado

## Próximas ações

1. **Produção:** executar `sql/migrations/td_sec_006_password_salt.sql` em todo ambiente com DB já criado antes do deploy do `oAccount` novo
2. Completar tradução em `oDashboard/client.lua` (centenas de `outputInfoBox` / `dxDrawText` HU restantes) e `faction/*.lua`
3. Completar `[Interface]` (`oHud`, `oRadar`, `oInfobox`, `oSpeedo`, `oCrosshair`) — apenas strings visíveis ao jogador
4. Testes em servidor dev: login legado → migração; login já migrado; registro; reset de senha

## Arquivos tocados (esta entrega)

- `oAccount/server.lua` — TD-SEC-006
- `orp_main.sql`, `sql/migrations/td_sec_006_password_salt.sql`
- `oDashboard/global.lua`, `oDashboard/client.lua`, `oDashboard/dashServer.lua`, `oDashboard/bugReportC.lua`
- `[Interface]/oInterface/global.lua`, `[Interface]/oInterface/client.lua`, `[Interface]/oScoreboard/client.lua`
- `README.md`, `.cursor/context/current-sprint.md`
