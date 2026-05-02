# Infraestrutura do Servidor — VPS Ubuntu 24.04

**Atualizado:** 2026-05-02

---

## Ambiente

| Item | Valor |
|------|-------|
| SO | Ubuntu 24.04 LTS |
| IP público | 72.61.40.180 |
| Porta jogo | 22003 |
| Porta HTTP | 22005 |
| Porta ASE | 22006 |
| Caminho MTA | `/root/multitheftauto_linux_x64/` |
| Caminho recursos | `/root/multitheftauto_linux_x64/mods/deathmatch/resources/` |
| Log do servidor | `mods/deathmatch/logs/server.log` |

---

## MySQL

| Item | Valor |
|------|-------|
| Host (MTA usa) | `127.0.0.1` (TCP, **não** socket) |
| Banco principal | `orp_main` |
| Banco de logs | `orp_main` (mesma conexão) |
| Usuário MTA | `ipirangaroleplay@127.0.0.1` |
| Acesso root CLI | `mysql -u root orp_main` (socket, sem senha) |

> **Atenção:** `mysql -u ipirangaroleplay -p...` falha no CLI porque o usuário só tem permissão via TCP (`127.0.0.1`), não via socket (`localhost`). Sempre usar root para operações manuais no terminal.

---

## Dependência Crítica — libssl1.1

Ubuntu 24.04 vem apenas com OpenSSL 3.0. O módulo MySQL do MTA (`x64/dbconmy.so`) exige `libssl.so.1.1` (OpenSSL 1.1.x).

**Fix aplicado (2026-05-02):**
```bash
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb -O /tmp/libssl1.1.deb
dpkg -i /tmp/libssl1.1.deb
ldconfig
```

Se o servidor migrar de VPS ou reinstalar o SO, este passo é obrigatório antes de iniciar o MTA.

---

## Iniciar o Servidor

```bash
cd /root/multitheftauto_linux_x64
screen -S mta -dm bash -c './mta-server64 2>&1 | tee /tmp/mta_live.log'
```

Para ver o log em tempo real:
```bash
tail -f /root/multitheftauto_linux_x64/mods/deathmatch/logs/server.log
```

Para parar:
```bash
pkill -f mta-server64
# Se não parar:
kill -9 $(pgrep -f mta-server64)
```

> **Nota:** O pipe `| tee` desconecta o stdin do MTA, impossibilitando comandos interativos pelo console. Para enviar comandos via console, iniciar sem o pipe, ou usar um método alternativo (RCON, script in-game).

---

## Tabelas DB em falta (2026-05-02)

As seguintes tabelas são referenciadas mas não existem na `orp_main`:

| Tabela | Recurso | Impacto |
|--------|---------|---------|
| `craftingTabels` | oDrugs | Sistema de craft de drogas desativado |
| `mdcAccounts` | oMDC | MDC (Mobile Data Computer) sem dados |
| `mdcWantedPersons` | oMDC | Procurados no MDC indisponíveis |
| `mdcWantedCars` | oMDC | Veículos procurados indisponíveis |
| `mdcPenalties` | oMDC | Multas MDC indisponíveis |

Estas tabelas precisam ser criadas via schema SQL (a obter nos recursos respetivos).
