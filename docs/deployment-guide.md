# Deployment guide — produção Vale do Ipiranga RP / MTA

**Atualização:** 2026-05-02

---

## 1. Prerequisites

| Pré‑requisito | Verificação |
|---------------|-------------|
| Ubuntu LTS recomendado (24.04 documentado infra) | `uname -a` |
| **libssl1.1** para `dbconmy.so` | Ver bloco OpenSSL em `infra/server-setup.md` |
| MySQL `orp_main` provisionado + user TCP `127.0.0.1` | `mysql -u root` local |
| Symlinks recursos em `mods/deathmatch/resources/` | Conforme `infra/acl-e-recursos.md` |
| Portas livres `serverport` + `httpport` + ASE | `ss -lun` |

---

## 2. Startup checklist (Go / No-Go)

1. [ ] Servidor **parado** se precisar editar `acl.xml`
2. [ ] Verificar `mtaserver.conf` — nome, slots, `minclientversion`
3. [ ] Conferir existência `vila-do-ipiranga-rp` + `oStarter` visíveis para MTA
4. [ ] Testar `mysql` credenciais **sem** logar segredo em chat público
5. [ ] Espaço disco logs + backups (`backup_path` config)
6. [ ] Lançar binário (screen/tmux/systemd)
7. [ ] Tail `server.log` primeiros 2 min — **zero** erros críticos MySQL
8. [ ] Join test account interno — login + spawn

### Rollback rápido

| Cenário | Passo |
|---------|-------|
| Build scripts quebrados | `pkill mta-server64` → restaurar symlink ou branch anterior |
| ACL corrompido memória | Parar serviço → restaurar `acl.xml` backup → start |
| DB migration falhou | Restaurar snapshot SQL + versão compatibilidade código |

---

## 3. Referência operacional detalhada

Comandos copy/paste, caminhos VPS, notas MySQL: **`docs/infra/server-setup.md`**.

ACL edit safety: **`docs/infra/acl-e-recursos.md`**.

---

## 4. Backup strategy (baseline)

| Artefacto | Frequência sugerida | Retenção |
|-----------|---------------------|----------|
| Dump `orp_main` (`mysqldump --single-transaction`) | Diária (off-peak) | 7–30 dias rotativo |
| `acl.xml` + `mtaserver.conf` versionados (git privado) | A cada alteração | Ilimitado leve |
| Pasta `resources/vila-do-ipiranga-rp` (ou artefact release tag) | Semanal / release | N releases |

Teste restauração trimestral mínimo (table-top exercise).

---

## 5. Disaster recovery (macro)

1. Provision fresh VPS homólogo.
2. Install MTA + libssl fix.
3. Restore MySQL dump.
4. Deploy resource tree (tag release).
5. Recreate symlinks + validate `oStarter` list.
6. Smoke test join + economy micro transaction.

RTO/RPO dependem política interna — documentar alvos fora deste repositório se compliance exigir.

---

## 6. Incident response playbook (curto)

| Severidade | Exemplo | Resposta imediata |
|------------|---------|-------------------|
| SEV1 | DB down / auth total fail | Modo manutenção mensagem + parar novos joins + investigar MySQL |
| SEV2 | Exploit económico massivo | Snapshot DB + revogar função feature flag via stop resource target se existir |
| SEV3 | Lag elevado | Coletar `server.log` últimos 10k linhas + slow query window |

Pós‑mortem: atualizar [security/security-log.md](security/security-log.md) ou worklog.

---

## 7. Continuous delivery (optional maturity)

Pipeline sugerida (não implementada por este doc):

1. Tag Git → artefact tar.gz resources
2. Staging join bot smoke (futuro)
3. Promote prod + DB migration job separado

---

## Cross links

- Troubleshooting operacional: [troubleshooting.md](troubleshooting.md)
- Arquitectura arranque: [resumo-tecnico-servidor.md](resumo-tecnico-servidor.md)
