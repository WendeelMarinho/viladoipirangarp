# Próximas Ações

**Atualizado:** 2026-05-03

---

## ALTA PRIORIDADE — Fase 4: Novos Sistemas (implementação)

Spec completa: `docs/features/roadmap-fase4.md`  
Contexto para Cursor: `.cursor/context/novos-sistemas.md`  
Regras Cursor: `.cursor/rules/fase4-features.md`

### Ordem de implementação

| # | Recurso | Dependências | Prioridade |
|---|---------|-------------|-----------|
| 1 | `oTags` | oAccount, factions.color (DB ✅) | P1 — base de todos |
| 2 | `oChat3` | oTags | P1 — UX imediata |
| 3 | `oWelcome` | oAccount, oChat3 | P1 — onboarding |
| 4 | `oRank` | oAccount, oTags | P2 |
| 5 | `oCarTheft` | oRank, oWanted, oInventory | P2 |
| 6 | `oHeist` | oCarTheft, oRank, oWanted, oFactionScripts | P3 |

### Diferencial enterprise (fase posterior)
- `oReputation` — reputação IC com facções
- `oEvidence` — evidências forenses (PCSP investigativa)
- `oTribunal` — sistema de tribunal OAB vs PCSP
- `oElections` — eleições para Prefeitura SP
- `oMedia` — jornal e rádio IC

---

## ALTA PRIORIDADE — Configuração in-game (novos sistemas)

Os 4 novos recursos (`oWanted`, `oTerritory`, `oFactionHQ`, `oFactionScripts`) estão no servidor mas precisam de configuração dentro do jogo para funcionar completamente.

### HQ de Facção — Comandos admin (nível 6)

Para **cada facção** que terá HQ:

```
1. /hqsetup <faction_id>           → registar a facção na tabela faction_hq
2. Ir até ao ponto de munição desejado e: /hqammo
3. Para cada portão: /hqgate <faction_id> <gate_db_id>
4. Para cada veículo: ir até ao slot e: /hqveh <faction_id> <model_id>
```

Faction IDs (da DB — todos criados em 2026-05-03):
- 74: PMESP — Polícia Militar do Estado de SP
- 75: SAMU 192
- 76: Prefeitura de São Paulo
- 77: PCC — Primeiro Comando da Capital
- 78: Família Lombardi — Cosa Nostra SP
- 79: Yakuza São Paulo — Yamaguchi-gumi BR
- 80: PCSP — Polícia Civil do Estado de SP
- 81: Corpo de Bombeiros Militar do Estado de SP
- 82: OAB-SP — Ordem dos Advogados do Brasil
- 83: CV — Comando Vermelho

### Territórios

- [ ] Verificar as 8 zonas pré-seed com `/tp` para confirmar coordenadas
- [ ] Ajustar `allowed_types` via DB se alguma facção de tipo diferente precisar capturar:
  ```sql
  UPDATE territories SET allowed_types='[1,4,5]' WHERE id=X;
  ```
- [ ] Ajustar `min_members` se quiser 1 só jogador para teste:
  ```sql
  UPDATE territories SET min_members=1 WHERE id <= 8;
  ```

---

## ALTA PRIORIDADE — Integrações de código (programador)

### 1. `oGate` + `oFactionHQ` (portões de HQ)

Em `oGate/server.lua`, antes de abrir um portão, verificar:
```lua
-- Adicionar no handler que decide se abre o portão:
if exports.oFactionHQ:canOpenGate(player, gateID) then
    -- abrir portão
end
```

### 2. `oDeath` + `oWanted` (morte por policial → regista crime)

Em `oDeath/server.lua`, no handler de morte/kill:
```lua
-- Quando jogador morto por policial:
local killer = ... -- quem matou
if exports.oFactionScripts:isInLawEnforcementDuty(killer) then
    exports.oWanted:addCrime(deadPlayer, "homicidio")
end
```

### 3. `oWanted` + `oFactionScripts` (prisão → limpa wanted)

Em `oFactionScripts/server.lua`, quando criminal é detido na cela:
```lua
triggerServerEvent("oWanted > arrest", resourceRoot, criminalPlayer)
-- ou diretamente:
exports.oWanted:clearWanted(criminalPlayer, officerPlayer)
```

---

## MÉDIA PRIORIDADE — Fix ACL oAdmin

O `oAdmin` não tem permissões ACL suficientes. Sintoma: `addAccount`, `logIn`, `aclSave`, `aclGroupAddObject` negados.

**Fix (servidor parado):**
1. Parar o servidor
2. Adicionar `<object name="resource.oAdmin"></object>` ao grupo `Admin` em `acl.xml`
3. Iniciar o servidor

> **Regra obrigatória:** editar `acl.xml` APENAS com o servidor parado.

---

## MÉDIA PRIORIDADE — QA login / registo

Após fix ACL oAdmin, testar:
- [ ] Login de developer (serial em `adminserials`) → auto-login sem password
- [ ] Registo de novo jogador (conta normal)
- [ ] Login de jogador existente
- [ ] Criação de personagem

---

## MÉDIA PRIORIDADE — oFactionScripts stubs

As seguintes funções retornam "em desenvolvimento" e precisam de implementação real:

| Função | Sistema | Prioridade |
|--------|---------|-----------|
| `getStingerFromVeh` | Colocar/recolher stinger na estrada | P1 (polícia usa) |
| `getSpeedcamFromVehicle` | Câmara de velocidade móvel | P2 |
| `showRBSPanel` | Painel bloqueio de rua | P2 |
| `pickUpRBS` / resto RBS | Sistema Road Block Setup | P2 |
| `connectHose` / `unConnectHose` | Mangueira dos bombeiros | P3 |
| `connectHoseToVeh` / `unConnectHoseFromVeh` | Mangueira veículo | P3 |
| `attachDollyToPlayer` | Sistema dolly (reboque manual) | P3 |
| `pickupDrum`/`takeDownDrum`/`pickupFuelDrum`/`takeDownFuelDrum` | Tambores combustível | P3 |

---

## BAIXA PRIORIDADE — Backlog técnico

- [ ] Traduzir mensagens húngaras em `oPayday/client.lua` ("Fizetés", "Jármű adó", "Ingatlan adó", "Banki kamat") e `oPayday/server.lua` ("Fizetésed")
- [ ] `registerOnServer` em `oAccount`: substituir `SELECT * FROM accounts` por query targetada
- [ ] Criar tabelas em falta: `craftingTabels` (para oDrugs)
- [ ] Remover recursos duplicados em `oStarter` (`oNewPD` aparece 2× no manifesto)
- [ ] Remover referências a `oPlant` e `oPlaneCrash` do timer retardado em `oStarter/server.lua:290-291`
- [ ] `fetchRemote` para `oCore` e `oAnticheat` (meteorologia e listas negras de IP)
- [ ] Verificar `dutyPos` de facção 74 — coordenadas `[[216.8,-40.8,1001.8,14,3]]` precisam de confirmação in-game

## Dívidas abertas relevantes

- TD-SEC-003: Admin serials hardcoded — PARCIALMENTE RESOLVIDO (serial inserido em DB)
- TD-SEC-006: Hashing de senhas — requer migração de dados
- TD-ARCH-002: Element data como estado de sessão — longo prazo
