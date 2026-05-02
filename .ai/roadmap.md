---
type: ai-roadmap
updated: 2026-05-01
---

# Roadmap Técnico

## Phase 1 — Security Hardening

### Concluído
- [x] oAccount: remover saver[], rate limiting, source validation (branch: security/oAccount-auth-hardening)

### Em andamento
- [ ] oAdmin: migração de seriais hardcoded para banco (branch: security/oAdmin-serial-migration)

### Pendente nesta fase
- [ ] Auditoria global de source validation (todos os recursos)
- [ ] Auditoria de SQL parameterization (todos os recursos)
- [ ] oCore: remover whitelist de desenvolvedores hardcoded

---

## Phase 2 — Core Modernization

Ordem aprovada:
1. oAccount — refatoração de arquitetura de sessão
2. oInventory — modularização
3. oVehicle — performance e modularização
4. oPhone — modernização
5. oAdmin — refatoração geral

---

## Phase 3 — Localization (PT-BR)

Prioridade de tradução:
1. oAccount (autenticação)
2. oDashboard + [Interface]
3. oInventory
4. oVehicle + oCarshop + oTuning
5. oPhone + oChat
6. oAdmin
7. [Jobs]
8. Periféricos

Glossário canônico: `docs/translations/glossario.md`

---

## Dívidas Técnicas Abertas

Ver: `docs/technical-debt-report.md`

Críticas não resolvidas:
- TD-SEC-006: Senhas sem hashing adequado (requer migração de dados)
- TD-ARCH-001: Dados relacionais em VARCHAR/TEXT
- TD-ARCH-002: Element data como modelo de sessão
