---
type: ai-next-actions
updated: 2026-05-01
---

# Próximas Ações

## Imediato (próximo commit)
- [ ] Popular a tabela `adminserials` com os seriais dos administradores do Ipiranga Roleplay
- [ ] Testar login de developer em servidor de desenvolvimento
- [ ] Verificar que `/reloadadminserials` recarrega corretamente

## Próxima sprint — oCore Whitelist
- [ ] Remover whitelist de developers hardcoded em `[Core]/oCore/server.lua` (linhas 5–24)
- [ ] Integrar com a tabela `adminserials` já migrada
- [ ] Branch: `security/oCore-whitelist-migration`

## Backlog de segurança
- [ ] Auditoria global de source validation (todos os ~400 recursos)
- [ ] Auditoria de SQL parameterization em toda a codebase
- [ ] TD-SEC-006: Planejar migração de hashing de senhas

## Backlog de infraestrutura
- [ ] Criar `.cursor/rules/project-rules.md`
- [ ] Criar `.cursor/context/architecture.md`
- [ ] Criar `docs/resources/oAdmin.md`
- [ ] Criar `docs/resources/oAccount.md`
