# Troubleshooting — MTA Ipiranga / OriginalRP stack

**Atualização:** 2026-05-02

---

## Symptom index

### A. Servidor não sobe / crash imediato MySQL

| Causa provável | Verificação | Fix outline |
|----------------|-------------|-------------|
| Credenciais erradas ou user só TCP mas script tentando `localhost` unix socket pelo CLI tooling dev | Ler `[Core]/oMysql/server.lua` / testar `-h127.0.0.1` | Ajustar user GRANT HOST |
| `libssl.so.1.1` ausente Ubuntu 24 | `ldd x64/dbconmy.so \| grep ssl` | Instalar pacote openssl1.1 conforme infra doc |
| Base `orp_main` inexistente | `SHOW DATABASES;` | Import `orp_main.sql` |

Logs: `mods/deathmatch/logs/server.log` — procurar `Failed to connect the database`.

---

### B. HTTP port (download) ocupada — clientes ficam pendurados downloading

Erro exemplo: “Could not start HTTP server on port 22005”.

| Passo |
|-------|
| `ss -lunp | grep 22005` identificar PID |
| `pkill`/finalizar processo holder antigo zombie screen |
| Ajustar **`<httpport>`** apenas se coexistência infra exigir (lembrar firewall) |

---

### C. Jogadores entram mas mundo vazio sem sistemas (sem inventário/commands)

Checklist rápido:

1. **`oStarter` arrancado?** log `[Vila RP] oStarter iniciado`.
2. **Erro avalanche export first seconds** — esperar ciclo ou reiniciar target resource após admins online.
3. **Symlinks em falta** — recurso presente apenas na pasta grande mas não nome curto sob `mods/deathmatch/resources/` → invisible para `getResourceFromName`.

---

### D. Permissões admin não aplicam após edição arquivo ACL

Motivo típico: ACL salvo pela memória de processo **`aclSave`** em stop de resource administrativo sobrescrevendo ficheiro manual offline errado momento.

Fluxo correto já documentado: **parar MTA inteiro antes de edit** → start limpo (`infra/acl-e-recursos.md`).

---

### E. Charset / texto corrompido PT-BR

Validar charset conexões (`utf8`) e colunas texto tabela (dump original); novas migrações manter UTF8MB4 policy se expandir emoji futuro RP.

---

### F. FPS massivo servidor-side (uso CPU alto estável idle)

Possíveis alvos auditoria inicial:

| Investigar |
|-------------|
| Timers densos loops `setTimer(..., 0, 0)` recém adicionados custom |
| `onColShapeHit` cascades spawning mass items |
| Shaders combinados lado cliente — não servidor mas latência perceptível relatada como “servidor lag” (ping confundido) |

Usar correlacion temporal: deploy recente Git diff near timers.

---

## Ferramentas de diagnóstico

| Ferramenta | Uso |
|------------|-----|
| `tail -f server.log` | Erros recurso unload |
| `perf`/`top` só root | hotspots binário nativo marginal — Lua hotspots via debug hooks custom |
| `rg 'FAILED\|Bad argument'` em log exportado overnight | agrupar regressões |

---

## Esclação

Issue estruturais segurança: abrir entrada em [`security/security-log.md`](security/security-log.md) com repro passos antes de patch.
