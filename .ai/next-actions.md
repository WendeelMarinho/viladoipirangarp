---
type: ai-next-actions
updated: 2026-05-01
---

# Próximas Ações — Phase 2

## Bloqueante de Produção — TD-SEC-006 (senha hashing)

**Decisão aprovada:** SHA-256 server-side com salt por usuário, lazy migration.

- [ ] Adicionar coluna `password_salt VARCHAR(32) NULL` em `accounts` (requer aprovação de schema)
- [ ] Migração online: rehash no próximo login bem-sucedido
- [ ] Atualizar handler `loginOnServer` em `oAccount/server.lua`
- [ ] Atualizar handler `registerOnServer` em `oAccount/server.lua`
- [ ] Branch: `security/oAccount-password-hashing`

## Segurança — Backlog

- [ ] Auditoria global de source validation (todos os ~400 recursos) — grande, para Cursor
- [ ] Auditoria de SQL parameterization em toda a codebase — grande, para Cursor
- [ ] Migrar `blacklistSerials` hardcoded de oCore para sistema de bans do oAccount

## Localização PT-BR (Phase 2)

Prioridade definida no roadmap:
1. [x] oAccount — strings de autenticação (login, registro, personagem) — **CONCLUÍDO** `27d54f5`
2. [ ] oDashboard + [Interface] — HUD, nametag, radar
3. [ ] oInventory
4. [ ] oVehicle + oCarshop + oTuning
5. [ ] oPhone + oChat

Regras em: `.cursor/rules/translation.md`
Glossário em: `.cursor/rules/translation.md` (seção Glossário Obrigatório)

## Documentação — Pendente

- [ ] `docs/resources/oAdmin.md` — documentação do recurso
- [ ] `docs/resources/oAccount.md` — documentação do recurso

## Modernização Incremental — Backlog

Ordem aprovada (CLAUDE.md):
1. oAccount — refatoração de arquitetura de sessão (longo prazo)
2. oInventory — modularização
3. oVehicle — performance
4. oPhone — modernização
