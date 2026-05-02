# Próximas Ações

**Atualizado:** 2026-05-02

---

## Imediatas — Fix ACL oAdmin (bloqueia login developer e gestão de admins)

O `oAdmin` não tem permissões ACL suficientes. Sintoma: `addAccount`, `logIn`, `aclSave`, `aclGroupAddObject` negados no arranque.

**Fix:**
1. Parar o servidor
2. Adicionar `<object name="resource.oAdmin"></object>` ao grupo `Admin` em `acl.xml`
3. Iniciar o servidor

> **Regra obrigatória:** editar `acl.xml` APENAS com o servidor parado. Ver `docs/infra/acl-e-recursos.md`.

## Imediatas — QA login / registo de jogador

Após fix ACL, testar:
- [ ] Login de developer (serial em `adminserials`) → auto-login sem password
- [ ] Registo de novo jogador (conta normal)
- [ ] Login de jogador existente
- [ ] Criação de personagem

## Imediatas — Tabelas DB em falta

Criar as tabelas ausentes para oDrugs e oMDC (ver `docs/infra/server-setup.md` para lista completa).

---

## Próxima sessão — oAdmin

- [ ] Adicionar `resource.oAdmin` ao grupo Admin em `acl.xml`
- [ ] Verificar se `fetchRemote` precisa ser concedido a `oCore` e `oAnticheat` (meteorologia e listas negras de IP)
- [ ] Auditar manipulação de grupos ACL em `oAdmin/s_admin.lua`
- [ ] Revisar todas as validações de admin level

## Backlog técnico

- [ ] `registerOnServer`: substituir `SELECT * FROM accounts` (full table scan) por queries targetadas — branch: `performance/oAccount-register-query`
- [ ] Traduzir mensagens húngaras restantes (ver `docs/translation-roadmap.md`)
- [ ] Criar tabelas em falta: `craftingTabels`, `mdcAccounts`, `mdcWantedPersons`, `mdcWantedCars`, `mdcPenalties`
- [ ] Remover recursos duplicados em `oStarter` (`oNewPD`, `oBillboards` aparecem duas vezes)
- [ ] Remover referências a `oPlant` e `oPlaneCrash` do timer em `oStarter/server.lua:290-291`

## Dívidas abertas relevantes

Referência: [technical-debt-report.md](../technical-debt-report.md)

- TD-SEC-003: Admin serials hardcoded — **PARCIALMENTE RESOLVIDO** (serial inserido em DB; falta migração completa)
- TD-SEC-006: Hashing de senhas — requer migração de dados (planejar separadamente)
- TD-ARCH-002: Element data como estado de sessão — longo prazo
