# Próximas Ações

**Atualizado:** 2026-05-01

---

## Imediatas (próximo commit)

- [ ] Criar branch `security/oAccount-auth-hardening` e commitar as mudanças
- [ ] Testar fluxo de login/registro em servidor de desenvolvimento
- [ ] Verificar que rate limiting não bloqueia admin login legítimo

## Próxima sessão — oAdmin

- [ ] Migrar seriais de admin hardcoded para tabela `adminserials`
- [ ] Auditar manipulação de grupos ACL
- [ ] Revisar todas as validações de admin level
- [ ] Branch: `security/oAdmin-serial-migration`

## Backlog técnico imediato

- [ ] `registerOnServer`: substituir `SELECT * FROM accounts` (full table scan) por queries targetadas — branch: `performance/oAccount-register-query`
- [ ] Traduzir mensagens de rate limiting inseridas (estão em PT-BR mas os demais ainda em húngaro)
- [ ] Auditar `oMysql` para error handling e connection drops

## Dívidas abertas relevantes

Referência: [technical-debt-report.md](../technical-debt-report.md)

- TD-SEC-003: Admin serials hardcoded — próxima sprint
- TD-SEC-006: Hashing de senhas — requer migração de dados (planejar separadamente)
- TD-ARCH-002: Element data como estado de sessão — longo prazo
