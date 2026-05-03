# Guia completo de administração (PT-BR)

Documento para equipa de staff: níveis, dever (`duty`), verificação de serial, comandos registados no painel e fluxo típico de promoção.

## 1. Conceitos principais

### 1.1 Nível admin (`user:admin`)

Armazenado na conta (**MySQL** `accounts.admin`). Valor numérico; quanto maior, mais comandos ficam disponíveis (via `hasPermission`). Os nomes exibidos vêm de `adminPrefixs` em `oAdmin/g_admin.lua` (ex.: Admin 1–5, Head Admin, Developer, Owner).

### 1.2 Apelido de admin (`user:adminnick`)

Nome que aparece nas mensagens de admin. Comando típico: `/setadminnick` (nível alto).

### 1.3 Serviço admin (`user:aduty`) — `/aduty`

Na prática da script:

- **Níveis ≥ 7** são tratados como se estivessem **sempre em serviço** (`isPlayerInAdminDuty` devolve verdadeiro).
- **Níveis 2–6** devem usar **`/aduty`** para entrar/sair de serviço antes de usar a maioria dos comandos administrativos (muitos handlers começam com `if not isPlayerInAdminDuty then return end`).

### 1.4 Serial verificado (`adminserials`)

A tabela **`adminserials`** na base de dados guarda serials autorizados. No arranque, o servidor preenche `adminSerialsCache` (`oAdmin/s_admin.lua`) e o anticheat carrega os mesmos serials como lista **verified** (`[Core]/oAnticheat/antiCheatS.lua`).

- **`checkPlayerVerifiedAdminStatus`**: comandos sensíveis (dinheiro, nível admin, itens, veículos criados por admin, etc.) só prosseguem se o serial do staff estiver nessa lista. Caso contrário o jogador pode ser **kickado** com mensagem em português.
- **Developer / ACL console**: jogadores com `aclLogin == true` (login RCON/ACL típico) podem ter caminhos alternativos no código para promoções máximas; quem gere o servidor deve conhecer essa distinção.

Comandos úteis (nível/console conforme definido no script):

- Recarregar serials sem reiniciar: **`reloadadminserials`** (oAdmin) e **`reloadverifiedserials`** (oAnticheat, só com `aclLogin`).

### 1.5 Permissões por comando (`oAdmin/g_commands.lua`)

A lista `adminCMD` associa cada **nome de comando** (string) ao **nível mínimo** necessário e a uma **descrição curta** (painel/UI — agora em PT-BR).

A função **`hasPermission(element, permission)`** compara `user:admin` ao valor `permission` do comando OU concede bypass a dev (`aclLogin` no cliente ou serial em `adminSerialsCache` no servidor).

**Nota:** Existem duas entradas para `'warn'` com níveis diferentes (2 e 7); o comportamento exato ao resolver `hasPermission` depende da ordem de iteração em `pairs()` — vale manter apenas uma entrada consolidada num refactor futuro.

---

## 2. Como tornar-te admin / promover alguém

1. **Garantir serial na BD** — Inserir o serial MTA na tabela **`adminserials`** (e recarregar com o comando adequado ou reinício do recurso/servidor).
2. **`/setadminlevel` ou `/setalevel`** — Sintaxe habitual: jogador alvo + nível numérico. Apenas quem já tem nível suficiente e está **verificado** pode usar comandos que chamam `checkPlayerVerifiedAdminStatus`.
3. **Limites ao promover níveis altos** — Se o nível pretendido ultrapassa o máximo permitido pelo teu próprio nível:
   - o alvo deve ter serial em **`adminserials`**; senão a promoção é negada (mensagem já em PT-BR no fluxo normal).
4. **`/sethelper`** — Fluxo paralelo para “helper”; não uses `setadminlevel` em contas marcadas como helper conforme mensagens do script.
5. **Após nivel 0** — O script pode repor nome IC e desligar duty.

Novos staff devem:

- Entrar com serial já registado.
- Usar **`/aduty`** se o nível for &lt; 7.
- Conhecer regras internas da equipa (não faz parte deste doc).

---

## 3. Comandos listados no painel (referência rápida)

A fonte oficial é `oAdmin/g_commands.lua`. Abaixo, o mesmo conjunto para consulta rápida (nome do comando → nível mínimo → descrição).

| Comando | Nível | Descrição |
|--------|------|-----------|
| fixcharger | 2 | Atualizar/colocar Tesla em estado correto |
| jailed | 2 | Listar jogadores na prisão (jail) |
| warn | 2 | Distribuir alerta de arma premium |
| fixveh | 2 | Reparar veículo |
| unflip | 2 | Desvirar veículo |
| setskin | 2 | Alterar skin do jogador |
| setarmor | 2 | Alterar colete do jogador |
| sethp | 2 | Alterar vida do jogador |
| setdrunken | 2 | Alterar nível de álcool |
| sethunger | 2 | Alterar fome |
| setthirst | 2 | Alterar sede |
| givemoney | 7 | Dar dinheiro |
| setmoney | 7 | Definir dinheiro |
| setpp | 8 | Definir pontos premium |
| givepp | 8 | Dar pontos premium |
| goto | 2 | TP até jogador |
| vhspawn | 2 | TP jogador para spawn prefeitura |
| gethere | 2 | Trazer jogador |
| setadminnick | 7 | Apelido admin |
| aduty | 2 | Entrar/sair serviço |
| setadminlevel | 7 | Definir nível admin |
| findchar | 2 | Nome pelo Char ID |
| findid | 2 | Char ID pelo nome |
| vanish | 2 | Invisível |
| kick | 2 | Expulsar |
| freeze | 2 | Congelar |
| unfreeze | 2 | Descongelar |
| recon | 1 | Observar |
| slap | 2 | Slap |
| showpms | 6 | Ver PMs |
| ajail | 2 | Admin jail |
| unjail | 2 | Soltar |
| aban | 3 | Ban |
| oban | 4 | Ban offline |
| aunban | 3 | Unban |
| setint | 5 | Interior |
| setdim | 5 | Dimensão |
| removefactionmoney | 7 | Retirar € da facção |
| givefactionmoney | 7 | Dar € à facção |
| setfactionleader | 7 | Líder facção |
| removeplayerfromallfaction | 6 | Sair de todas facções |
| removeplayerfromfaction | 6 | Sair de uma facção |
| getplayerfactions | 4 | Listar facções |
| setplayerfaction | 6 | Colocar na facção |
| fixbones | 2 | Curar ossos |
| ojail | 3 | Jail offline |
| showmydatas | 2 | Tuas stats admin |
| showadminstats | 8 | Stats todos admins |
| clearadminstats | 8 | Limpar stats admins |
| showplayers | 2 | Mapa jogadores |
| togalogs | 2 | Toggle logs admin no chat |
| setplayername | 4 | Renomear personagem |
| setaccountstate | 7 | Estado da conta |
| gotopoint | 2 | TP checkpoint |
| mypoints | 2 | Teus checkpoints |
| delpoint | 2 | Apagar checkpoint |
| addpoint | 2 | Criar checkpoint |
| fly | 2 | Fly on/off |
| playerlogs | 8 | Logs jogadores |
| bugreports | 8 | Bugs |
| debuginventory | 8 | Inventário bugado |
| takeitem | 5 | Tirar item |
| giveitem | 7 | Dar item |
| givelicense | 5 | Documento/licença |
| changelock | 7 | Tranca |
| warn | 7 | Alerta armas (entrada duplicada) |
| playerstats | 2 | Stats jogador |
| sgoto | 8 | Goto stealth |
| srecon | 8 | Recon stealth |
| delroulette | 9 | Apagar roleta |
| createroulette | 9 | Criar roleta |
| nearbyroulette | 9 | Roletas perto |
| givelincese | 7 | Licença (typo no nome do comando) |
| hideadmin | 7 | Admin oculto |
| sethelper | 6 | Helper temporário |
| setvehoil | 2 | Óleo veículo |
| resetbank | 7 | Reset banco |
| nearbygates | 7 | Portões |
| nearbysafe | 3 | Cofres |
| nearbyvehicles | 3 | Veículos |
| asay | 2 | Anúncio admin |
| showinv | 2 | Ver inventário |
| createinterior | 7 | Criar interior |
| makeveh | 7 | Criar veículo |
| anames | 2 | Nomes + vida + colete |
| addcarshopmarker | 7 | Marker stand usados |
| deletecarshopmarker | 7 | Remover marker |
| setplayercarshop | 7 | Dono stand |
| createcarshop | 9 | Criar stand |
| createlottofive | 9 | Lotto Five |
| addweaponship | 7 | Evento navio armas |
| makepet | 7 | Criar pet |
| delpet | 7 | Apagar pet |
| changepetname | 6 | Renomear pet |
| rehealpet | 6 | Reviver pet |
| setcontainerplantstate | 7 | Plantas contentor |
| setcontainerplantgrow | 7 | Crescimento |
| weedplantcontainer | 10 | Plantar contentor |
| setcontainerfanstate | 7 | Ventiladores |
| verifyplayer | 7 | Marcar verificado |
| removeplayerverify | 7 | Remover verificação |
| getplayerserial | 7 | Serial jogador |

**Comandos adicionais de veículo** (recurso `oVehicle`, registados com `admin:addAdminCMD`) incluem por exemplo: `getcar`, `gotocar`, `setvehplatetext`, `fuelveh`, `setvehfuel`, `setvehcolor`, `delveh`, `blowveh`, `respawnveh`, `warp`, `setcarhp`, `protectveh`, `rtc`, etc. — vê `oVehicle/commands/commandC.lua` para sintaxe exata e níveis.

---

## 4. Logs e boas práticas

- Muitos comandos definem `log:admincmd` ou enviam `sendMessageToAdmins` — usa-os de forma responsável.
- Mantém **`togglelogs`** coerente com a política da equipa (spam vs visibilidade).
- **Recon:** desativa recon antes de mudar de alvo (mensagem no cliente já em PT-BR).

---

## 5. Ficheiros relevantes

| Ficheiro | Função |
|----------|--------|
| `oAdmin/g_admin.lua` | Prefixos de nível, `isPlayerInAdminDuty`, `getPlayerAdminLevel` |
| `oAdmin/g_commands.lua` | Lista `adminCMD` + `hasPermission` |
| `oAdmin/s_admin.lua` | Handlers de comandos admin, `adminserials`, `setadminlevel` |
| `[Core]/oAnticheat/antiCheatS.lua` | Serials verificados, kick se não autorizado |
| `oVehicle/commands/commandC.lua` | Comandos client-side de veículo + `admin:addAdminCMD` |
| `oVehicle/commands/commandS.lua` | Validação servidor eventos veículo |

---

## 6. Facções — IDs e gestão

### 6.1 Facções ativas (criadas em 2026-05-03)

| ID | Nome | Tipo | Salário mín → máx |
|----|------|------|-------------------|
| 74 | PMESP — Polícia Militar do Estado de SP | 1 — Segurança | 3.500$ → 35.000$ |
| 80 | PCSP — Polícia Civil do Estado de SP | 1 — Segurança | 4.000$ → 32.000$ |
| 75 | SAMU 192 | 2 — Saúde | 3.000$ → 22.000$ |
| 81 | Corpo de Bombeiros Militar do Estado de SP | 2 — Saúde | 3.000$ → 24.000$ |
| 76 | Prefeitura de São Paulo | 3 — Legal/Governo | 2.500$ → 35.000$ |
| 82 | OAB-SP | 3 — Legal | 2.000$ → 32.000$ |
| 77 | PCC | 4 — Gangue | 2.000$ → 22.000$ |
| 83 | CV — Comando Vermelho | 4 — Gangue | 2.000$ → 25.000$ |
| 78 | Família Lombardi | 5 — Máfia | 2.500$ → 35.000$ |
| 79 | Yakuza São Paulo | 5 — Máfia | 2.500$ → 32.000$ |

**Cores por tipo** (sem colunas de cor no DB — atribuídas por `type` no código `factionClient.lua`):
- Tipo 1: Azul | Tipo 2: Vermelho | Tipo 3: Dourado | Tipo 4/5: Roxo

### 6.2 Comandos de gestão de facção

```
/setplayerfaction <player> <faction_id>    — colocar jogador na facção (nível 6)
/removeplayerfromfaction <player>          — remover jogador de uma facção (nível 6)
/removeplayerfromallfaction <player>       — remover jogador de todas (nível 6)
/getplayerfactions <player>               — listar facções do jogador (nível 4)
/setfactionleader <player>                — promover a líder (nível 7)
/givefactionmoney <faction_id> <valor>    — dar dinheiro à facção (nível 7)
/removefactionmoney <faction_id> <valor>  — retirar dinheiro (nível 7)
```

---

## 7. Novos sistemas (2026-05-03)

### 7.1 oWanted — Sistema de procurados

Gerir o sistema de 5★ de procurados.

**Crimes disponíveis:** `fuga_policial`, `resistencia`, `agressao`, `roubo`, `homicidio`, `crime_org`, `trafico`, `sequestro`

```lua
-- Adicionar crime (server-side):
exports.oWanted:addCrime(player, "homicidio")

-- Limpar procurado (policial prende):
exports.oWanted:clearWanted(criminalPlayer, officerPlayer)
```

**Decay automático:** Níveis 1–3 decaem por tempo (10/20/40 min). Níveis 4–5 só limpam por prisão.

**DB:** Tabela `wanted_active` em `orp_main`.

### 7.2 oTerritory — Territórios capturáveis

Apenas tipos **4 (Gangue)** e **5 (Máfia)** capturam por padrão.

```sql
-- Ajustar para teste (1 só membro):
UPDATE territories SET min_members=1 WHERE id <= 8;

-- Permitir tipo 1 capturar também (ex. zona policial):
UPDATE territories SET allowed_types='[1,4,5]' WHERE id=X;
```

**Income automático:** Timer de 1h deposita no banco da facção dona da zona.

**8 zonas pré-seed:** Idlewood, Grove, Playa del Seville, Jefferson, LV Strip, Tierra Robada, Blueberry, Palomino Creek.

### 7.3 oFactionHQ — Sede de facção

Configuração **totalmente in-game** por admin nível 6:

```
/hqsetup <faction_id>          → registar facção na tabela faction_hq
/hqammo                        → definir ponto de munição (posição atual)
/hqgate <faction_id> <gate_id> → associar portão DB
/hqveh <faction_id> <model>    → adicionar slot veículo no HQ
```

**Munição por tipo de facção:**
- Segurança (1): pistola (37), Deagle (28), shotgun (34)
- Saúde (2): kit médico (76), item ressurreição (81)
- Legal (3): pistola (37)
- Gangue (4): pistola (27), Uzi (30), AK (40)
- Máfia (5): pistola (27), Deagle (28), M4 (38)

**Integração pendente:** Em `oGate/server.lua` adicionar verificação `exports.oFactionHQ:canOpenGate(player, gateID)`.

### 7.4 oFactionScripts — Scripts de fação

Funcionalidades ativas:
- **Algemas** (item 77) — só policiais em serviço
- **Grab** — segurar suspeito (attachElements)
- **Revivificação** (item 81) — 8 segundos, 50 HP

Exports do servidor:
```lua
exports.oFactionScripts:isInLawEnforcementDuty(player)  -- bool
exports.oFactionScripts:isInMedicalDuty(player)          -- bool
exports.oFactionScripts:getCuffedBy(player)               -- player ou false
```

Funções em desenvolvimento (retornam mensagem): stinger, câmara velocidade, RBS, mangueiras, dolly, tambores.

---

## 8. Alterações recentes de idioma (2026-05-03)

**37+ recursos** completamente traduzidos para PT-BR nesta sessão:

- Todos os textos visíveis ao jogador (infobox, chat, UI) em `oDeath`, `oCarshop`, `oPaintjobs`, `oCustomPlate`, `oDrugs`, `oSkinshop`, `oTrafficLight`, `oSuprise`, `oInventory`, `oInteriorBuilding`, `oTuning`, `oAdmin`, `oTraffipax`, `oShop`, `oBankrob` e +20 outros
- Diálogos do dealer de drogas com gíria carioca/paulistana autentica
- **Painel de comandos admin**: descrições em PT-BR
- **Anticheat**: mensagens de kick/log em PT-BR

Para detalhes de arquitetura geral do servidor, vê também [resumo-tecnico-servidor.md](resumo-tecnico-servidor.md) e [database-architecture.md](database-architecture.md).
