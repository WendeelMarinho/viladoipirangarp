# Database architecture — `orp_main`

**Atualização:** 2026-05-02  
**Canonical schema dump:** [`../orp_main.sql`](../orp_main.sql) *(raiz pacote gamemode)* · migrações adicionais (se existirem): `sql/migrations/`.

---

## 1. Connectivity model

| Papel | Implementação típica |
|-------|------------------------|
| Conexões | Singleton(s) criados ao start de **`oMysql`** — `exports.oMysql:getDBConnection()` |
| Charset | UTF-8 configurado nos scripts starter (`SET NAMES utf8`) |
| Host | `127.0.0.1` TCP (produção documentada Ubuntu 24.x; ver `infra/server-setup.md`) |

**⚠ Credenciais** residem em `[Core]/oMysql/server.lua` — rotação requer downtime ou restart seguro; não versionar segredos de produção públicos idealmente migra‑se para variável ambiente quando MTA toolchain permitir padrão seguro na vossa pipeline.

---

## 2. Tabelas inventariadas pelo schema atual

Descrição apenas **semantic** derivada dos nomes; validar sempre colunas com `SHOW CREATE TABLE`:

| Tabela | Domínio presumido |
|--------|-------------------|
| `accounts` | Contas de login/economias base |
| `characters` | Personagens vivíveis/spawn |
| `vehicles` | Veículos possuídos / tuning serializado JSON |
| `items` catálogo + `worlditems` spawn mundo | Inventário físico disperso |
| `interiors*` imóveis | Interiores, ownership, objetos interiors |
| `factions` | Organizações (membros em JSON legado TD-ARCH-001) |
| `bank_accounts` transações texto | Histórico bancário agregado em coluna grande |
| `bans*` | Banimentos / histórico |
| `phonemessages` | SMS / voicemail pipeline |
| `mdc*` | Módulo LE terminal |
| `plants*` `pots` | Economia agrícola/drogas |
| `pets` | Animais de estimação |
| `trafficboards` `teslachargers` `fuelstations` | World services |
| `logpp` `mdclogs` | Observabilidade in-game textual |
| `adminserials` | Fonte desenvolvedores pós migração (ver security-log) |
| `blockedserials` `verifedplayers` | Anti‑abuso lista estática |
| `craftingtabels` | Craft sistema (tabela mencionada em docs infra como opcionalmente faltante) |

Lista completa alfabética extraída 2026-05-02 a partir dos `CREATE TABLE` no dump:

accounts, actionbaritems, adminserials, atms, bank_accounts, bans, bans2, bins, blockedserials, bugreports, characters, craftingtabels, elevators, factions, fuelstations, gates, interiors, interior_datas, interior_objects, items, logpp, lottery, mdcaccounts, mdclogs, mdcpenalties, mdcwantedcars, mdcwantedpersons, pendingpps, pets, phonemessages, plants, plants_containers, plants_orders, pots, printers, roulettes, serial_change, shops, szefek, teslachargers, trafficboards, usedcarshops, vehicles, vendingmachines, verifedplayers, worlditems

---

## 3. Anti patterns arquitectonicos já catalogados

| ID | Observação |
|----|-------------|
| **TD-ARCH-001** | JSON/Text agregados em VARCHAR largos (`factions.members`, tuning veículos) — migrações futuras difíceis |
| **Senhas legacy** | **TD-SEC-006**: armazenamento password sem hash forte moderno |

---

## 4. Operational queries

Saúde básica (shell MySQL):

```sql
SELECT COUNT(*) AS characters FROM characters;
SHOW TABLE STATUS LIKE 'vehicles'\G
```

Índices faltantes: auditar só após workloads reais (`EXPLAIN`), não supor apenas pelo dump.
