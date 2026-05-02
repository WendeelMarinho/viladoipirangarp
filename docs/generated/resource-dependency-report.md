# Resource dependency report

**Generated (UTC):** `2026-05-02T21:09:45.562237+00:00`  
**Scan root:** `/root/multitheftauto_linux_x64/mods/deathmatch/resources/vila-do-ipiranga-rp`  
**Starter parsed from:** `/root/multitheftauto_linux_x64/mods/deathmatch/resources/vila-do-ipiranga-rp/[Core]/oStarter/server.lua`  

## Executive summary

| Metric | Value |
|--------|------:|
| Resources with `meta.xml` | 400 |
| Effective starter order length (incl. `oFKSkins_*` on disk) | 8 |
| `exports.*:*` / `call(...)` edges | 4453 |
| Literal `getResourceFromName("...")` hits | 41 |
| Trigger/handler/addEvent records | 12343 |
| Heuristic cross-resource event edges (JSON truncado ≥8k) | 8000 |
| Heuristic event edges deduped total | 12748 |
| Undeclared / load-order **aggregated** flags | 60 |
| Undeclared raw edge rows (pre-aggregate) | 286 |
| Mutual export pairs (A↔B) | 17 |
| Largest export SCC size | 27 | (#SCCs 1)

**Critical framework resources** (prioridade revisão): `oAccount`, `oAdmin`, `oCore`, `oInventory`, `oMysql`, `oStarter`, `oVehicle`, `vila-do-ipiranga-rp`

### Limitações (ler antes de actuar)

- Análise **linha a linha**; padrões multilinha ou nomes concatenados dinamicamente **não** aparecem.
- Ramos `exports['x']:y` com `x` variável são ignorados.
- Custos **`event`**: igualdade do **nome da string** entre `trigger*` e `addEventHandler` **não** prova mesmo canal nem contrato estável.
- `undeclared_dependencies` cruzadas com **`oStarter`** apenas para raciocínio de boot; chamadas feitas minutos depois podem estar seguras mesmo com índices "invertidos".

## Top dependency consumers (distinct `exports` targets)

| Rank | Resource | # distinct providers |
|-----:|----------|----------------------:|
| 1 | `vila-do-ipiranga-rp` | 80 |
| 2 | `oInventory` | 27 |
| 3 | `oInventoryOLD` | 20 |
| 4 | `oInventoryNEW` | 14 |
| 5 | `oInteraction` | 13 |
| 6 | `oVehicle` | 13 |
| 7 | `oAccount` | 10 |
| 8 | `oAdmin` | 10 |
| 9 | `oVehicleOld` | 10 |
| 10 | `oBankrob` | 9 |
| 11 | `oDashboard` | 9 |
| 12 | `oDevtools2` | 8 |
| 13 | `oDrugs` | 8 |
| 14 | `oInteriors` | 8 |
| 15 | `oPet` | 8 |

## Top dependency providers (distinct consumers)

| Rank | Resource | # distinct consumers |
|-----:|----------|-----------------------:|
| 1 | `oAntiHook` | 228 |
| 2 | `oFont` | 62 |
| 3 | `oCore` | 57 |
| 4 | `oMysql` | 37 |
| 5 | `oInventory` | 31 |
| 6 | `oInfobox` | 29 |
| 7 | `oVehicle` | 28 |
| 8 | `oDashboard` | 22 |
| 9 | `oInterface` | 21 |
| 10 | `oChat` | 21 |
| 11 | `oAnticheat` | 17 |
| 12 | `oAdmin` | 14 |
| 13 | `oBone` | 14 |
| 14 | `oJSON` | 10 |
| 15 | `oJob` | 10 |

## Mutual export dependencies (bidirectional `exports` graph)

Pares onde **ambos** os recursos chamam um ao outro via `exports.X:Y` (candidatos a ciclos de inicialização reais mais acçãoáveis do que um SCC gigante).

| # | Resource A | Resource B |
|--:|------------|------------|
| 1 | `oAccount` | `oAdmin` |
| 2 | `oAdmin` | `oCore` |
| 3 | `oAdmin` | `oDashboard` |
| 4 | `oApiary` | `oInventory` |
| 5 | `oBank` | `oDashboard` |
| 6 | `oBank` | `oInventory` |
| 7 | `oChat` | `oInventory` |
| 8 | `oDashboard` | `oInventory` |
| 9 | `oDashboard` | `oVehicle` |
| 10 | `oHifi` | `oInventory` |
| 11 | `oInfobox` | `oInterface` |
| 12 | `oInventory` | `oLicenses` |
| 13 | `oInventory` | `oMarket` |
| 14 | `oInventory` | `oPhone` |
| 15 | `oInventory` | `oPrinter` |
| 16 | `oInventory` | `oTicket` |
| 17 | `oInventory` | `oVehicle` |

*Nota analítica:* o grafo dirigido completo pode ter uma SCC enorme (tamanho máximo **27**). Isso frequentemente reflecte um **hub** (ex.: `oCore`) mais do que um ciclo de refactor único. Priorizar triagem pelos pares mútuos acima e por `fragile_load_order` no JSON.*

## High‑risk findings (starter / load order / missing folder)

| kind | consumer | provider | #hits | functions (sample) | detail |
|------|----------|----------|------:|---------------------|--------|
| `external_or_missing_resource` | `PEDSHADER` | `shader_dynamic_sky` | 7 | `isDynamicSkyEnabled, getDynamicSunVector, getDynamicMoonVector, getMoonPhaseValue` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `ULTRAWATER` | `shader_dynamic_sky` | 7 | `isDynamicSkyEnabled, getDynamicSunVector, getDynamicMoonVector, getMoonPhaseValue` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `dynamic_lighting_nightmod` | `bone_attach` | 2 | `attachElementToBone, detachElementFromBone` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oBetaTest` | `cl_core` | 2 | `getServerColor` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oDevtools2` | `cr_core` | 2 | `getServerSyntax` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oDevtools2` | `cr_fonts` | 1 | `getFont` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oDevtools2` | `cr_logs` | 1 | `createLog` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oDevtools2` | `sarp_assets` | 1 | `getFontsDetail` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oFishingOLD` | `cl_infobox` | 3 | `outputInfoBox` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oIntCustomOLD` | `pb_interiors` | 1 | `updateInteriorPosition` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oInteraction` | `oFactionScripts` | 20 | `getMechanicFactionID, getStingerFromVeh, getSpeedcamFromVehicle, showRBSPanel, pickUpRBS, startPlayerRevivification, cuf` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oInteriorBuilding` | `object_preview` | 7 | `destroyObjectPreview, createObjectPreview` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oInventory` | `chat` | 1 | `takeMessage` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oInventory` | `oFactionScripts` | 4 | `removePoliceLightFromOccupiedVehicle, applyPoliceLightToOccupiedVehicle, removeTaxiLightFromOccupiedVehicle, applyTaxiLi` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oInventoryNEW` | `oFactionScripts` | 2 | `removePoliceLightFromOccupiedVehicle, applyPoliceLightToOccupiedVehicle` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oInventoryOLD` | `cl_admin` | 1 | `getPlayerAdminLevel` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oInventoryOLD` | `oFactionScripts` | 2 | `removePoliceLightFromOccupiedVehicle, applyPoliceLightToOccupiedVehicle` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oMDCOLD` | `oInfoBox` | 4 | `outputInfoBox` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oPhone` | `oFactionScripts` | 4 | `addFactionCall, makeTaxiCall` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oRadar` | `oFactionScripts` | 2 | `getFireFactionID` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oShader_Water` | `shader_dynamic_sky` | 7 | `isDynamicSkyEnabled, getDynamicSunVector, getDynamicMoonVector, getMoonPhaseValue` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oSkinshopOld` | `cl_core` | 1 | `getServerColor` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oSnow` | `sarp_hud` | 1 | `showInfobox` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oVehicle` | `oFactionScripts` | 1 | `detachServerSide` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oVehicleOld` | `cl_admin` | 8 | `getPlayerAdminLevel, sendMessageToAdmins` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oVehicleOld` | `cl_blur` | 1 | `createBlur` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oVehicleOld` | `cl_chat` | 16 | `sendLocalMeAction` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oVehicleOld` | `cl_core` | 1 | `getServerColor` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oVehicleOld` | `cl_font` | 3 | `getFont` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oVehicleOld` | `cl_infobox` | 11 | `outputInfoBox` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oVehicleOld` | `cl_mysql` | 1 | `getDBConnection` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oVehicleOld` | `cl_preview` | 2 | `destroyObjectPreview, createObjectPreview` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oZooCareTaker` | `bone_attach` | 2 | `attachElementToBone` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `oheadcross` | `ocore` | 2 | `getServerColor, getServerName` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `sirenpanel` | `cl_chat` | 1 | `sendLocalMeAction` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `viccelek` | `edf` | 10 | `edfGetAncestor, edfGetElementPosition` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `viccelek` | `editor_main` | 1 | `dropElement` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `bone_attach` | 4 | `attachElementToBone, detachElementFromBone` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `chat` | 1 | `takeMessage` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cl_admin` | 9 | `getPlayerAdminLevel, sendMessageToAdmins` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cl_blur` | 1 | `createBlur` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cl_chat` | 17 | `sendLocalMeAction` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cl_core` | 4 | `getServerColor` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cl_font` | 3 | `getFont` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cl_infobox` | 14 | `outputInfoBox` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cl_mysql` | 1 | `getDBConnection` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cl_preview` | 2 | `destroyObjectPreview, createObjectPreview` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cr_core` | 2 | `getServerSyntax` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cr_fonts` | 1 | `getFont` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `cr_logs` | 1 | `createLog` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `edf` | 10 | `edfGetAncestor, edfGetElementPosition` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `editor_main` | 1 | `dropElement` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `oFactionScripts` | 35 | `detachServerSide, removePoliceLightFromOccupiedVehicle, applyPoliceLightToOccupiedVehicle, removeTaxiLightFromOccupiedVe` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `oInfoBox` | 4 | `outputInfoBox` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `object_preview` | 7 | `destroyObjectPreview, createObjectPreview` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `ocore` | 2 | `getServerColor, getServerName` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `pb_interiors` | 1 | `updateInteriorPosition` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `sarp_assets` | 1 | `getFontsDetail` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `sarp_hud` | 1 | `showInfobox` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |
| `external_or_missing_resource` | `vila-do-ipiranga-rp` | `shader_dynamic_sky` | 21 | `isDynamicSkyEnabled, getDynamicSunVector, getDynamicMoonVector, getMoonPhaseValue` | Provider not found as a resource folder under scan root (may be MTA default resource, typo, or dynamic). |

## Hidden coupling: `getResourceFromName("…")` (sample)

Útil para encontrar bypass explícito a `exports.` (acoplamento menos visível nos greps antigos).

| from | target | file:line |
|------|--------|-----------|
| `oAccount` | `oAccount` | `oAccount/server.lua:110` |
| `oAccount` | `oAccount` | `oAccount/serverBK.lua:75` |
| `vila-do-ipiranga-rp` | `oAccount` | `oAccount/server.lua:110` |
| `vila-do-ipiranga-rp` | `oAccount` | `oAccount/serverBK.lua:75` |
| `oDashboard` | `oInteriors` | `oDashboard/client.lua:591` |
| `vila-do-ipiranga-rp` | `oInteriors` | `oDashboard/client.lua:591` |
| `oInventoryOLD` | `oInventory` | `[Old]/oInventoryOLD/codeS.lua:140` |
| `oInventoryOLD` | `oInventory` | `[Old]/oInventoryOLD/codeSOLD.lua:123` |
| `oInventoryOLD` | `oInventory` | `[Old]/oInventoryOLD/codeSOLD.lua:161` |
| `vila-do-ipiranga-rp` | `oInventory` | `[Old]/oInventoryOLD/codeS.lua:140` |
| `vila-do-ipiranga-rp` | `oInventory` | `[Old]/oInventoryOLD/codeSOLD.lua:123` |
| `vila-do-ipiranga-rp` | `oInventory` | `[Old]/oInventoryOLD/codeSOLD.lua:161` |
| `vila-do-ipiranga-rp` | `oStarter` | `server.lua:6` |
| `oDashboard` | `oVehicle` | `oDashboard/client.lua:411` |
| `vila-do-ipiranga-rp` | `oVehicle` | `oDashboard/client.lua:411` |
| `npc_hlc` | `server_coldata` | `[Carlos]/npc_hlc/control_npc_s.lua:14` |
| `vila-do-ipiranga-rp` | `server_coldata` | `[Carlos]/npc_hlc/control_npc_s.lua:14` |
| `PEDSHADER` | `shader_dynamic_sky` | `[Shaders]/PEDSHADER/c_sunInfluence.lua:43` |
| `ULTRAWATER` | `shader_dynamic_sky` | `[Shaders]/ULTRAWATER/c_main.lua:283` |
| `oShader_Water` | `shader_dynamic_sky` | `[Shaders]/oShader_Water/c_main.lua:361` |
| `vila-do-ipiranga-rp` | `shader_dynamic_sky` | `[Shaders]/PEDSHADER/c_sunInfluence.lua:43` |
| `vila-do-ipiranga-rp` | `shader_dynamic_sky` | `[Shaders]/ULTRAWATER/c_main.lua:283` |
| `vila-do-ipiranga-rp` | `shader_dynamic_sky` | `[Shaders]/oShader_Water/c_main.lua:361` |
| `ambient_effect` | `shader_snow_ground` | `[Shaders]/ambient_effect/rain.lua:3` |
| `ambient_effect` | `shader_snow_ground` | `[Shaders]/ambient_effect/rain.lua:127` |
| `ambient_effect` | `shader_snow_ground` | `[Shaders]/ambient_effect/rain.lua:129` |
| `ambient_effect` | `shader_snow_ground` | `[Shaders]/ambient_effect/rain.lua:130` |
| `vila-do-ipiranga-rp` | `shader_snow_ground` | `[Shaders]/ambient_effect/rain.lua:3` |
| `vila-do-ipiranga-rp` | `shader_snow_ground` | `[Shaders]/ambient_effect/rain.lua:127` |
| `vila-do-ipiranga-rp` | `shader_snow_ground` | `[Shaders]/ambient_effect/rain.lua:129` |
| `vila-do-ipiranga-rp` | `shader_snow_ground` | `[Shaders]/ambient_effect/rain.lua:130` |
| `ambient_effect` | `shader_wet_roads` | `[Shaders]/ambient_effect/rain.lua:2` |
| `ambient_effect` | `shader_wet_roads` | `[Shaders]/ambient_effect/rain.lua:48` |
| `ambient_effect` | `shader_wet_roads` | `[Shaders]/ambient_effect/rain.lua:50` |
| `ambient_effect` | `shader_wet_roads` | `[Shaders]/ambient_effect/rain.lua:53` |
| `ambient_effect` | `shader_wet_roads` | `[Shaders]/ambient_effect/rain.lua:54` |
| `vila-do-ipiranga-rp` | `shader_wet_roads` | `[Shaders]/ambient_effect/rain.lua:2` |
| `vila-do-ipiranga-rp` | `shader_wet_roads` | `[Shaders]/ambient_effect/rain.lua:48` |
| `vila-do-ipiranga-rp` | `shader_wet_roads` | `[Shaders]/ambient_effect/rain.lua:50` |
| `vila-do-ipiranga-rp` | `shader_wet_roads` | `[Shaders]/ambient_effect/rain.lua:53` |

## `meta.xml` `<include resource="…"/>` (declared)

| resource | includes |
|----------|----------|
| `dynamic_lighting_nightmod` | `dynamic_lighting` |
| `dynamic_lighting_nightmod` | `dynamic_lighting_vehicles` |
| `dynamic_lighting_nightmod` | `dynamic_lighting_projectiles` |
| `dynamic_lighting_projectiles` | `dynamic_lighting` |
| `dynamic_lighting_vehicles` | `dynamic_lighting` |
| `performancebrowser` | `ajax` |
| `titok2` | `titok` |

## Export vs `meta.xml` mismatch (sample)

Chamadas a funções **não** listadas no `meta.xml` do provider (primeiras 30). Muitas bases MTA ainda funcionam quando exports são implícitos ou meta desactualizada.

| consumer | provider | function |
|----------|----------|----------|
| `oAccount` | `oAntiHook` | `setEData` |
| `oAccount` | `oAntiHook` | `setEData` |
| `oBillboards` | `oAntiHook` | `setEData` |
| `oBillboards` | `oAntiHook` | `setEData` |
| `oChat` | `oAntiHook` | `setEData` |
| `oChat` | `oAntiHook` | `setEData` |
| `oCore` | `oInfobox` | `addInfoBox` |
| `oCore` | `oInfobox` | `addInfoBox` |
| `oDevtools2` | `oAdmin` | `sendMessageToAdmin` |
| `oDevtools2` | `oCore` | `getPlayerFromName` |
| `oDevtools2` | `oAdmin` | `sendMessageToAdmin` |
| `oDevtools2` | `oCore` | `getPlayerFronName` |
| `oDevtools2` | `oCore` | `getPlayerFronName` |
| `oGraffiti` | `oAntiHook` | `setEData` |
| `oGraffiti` | `oAntiHook` | `setEData` |
| `oHandling` | `oAntiHook` | `setEData` |
| `oHandling` | `oAntiHook` | `setEData` |
| `oHandling18` | `oAntiHook` | `setEData` |
| `oHandling18` | `oAntiHook` | `setEData` |
| `oInteraction` | `oTrailerFix` | `attachExport` |
| `oInteraction` | `oTrailerFix` | `attachExport` |
| `oInventory` | `oAntiHook` | `setEData` |
| `oInventory` | `oAntiHook` | `setEData` |
| `oNametag` | `oAntiHook` | `setEData` |
| `oNametag` | `oAntiHook` | `setEData` |
| `oNewDeliMap` | `oAntiHook` | `setEData` |
| `oNewDeliMap` | `oAntiHook` | `setEData` |
| `oShop` | `oAntiHook` | `setEData` |
| `oShop` | `oAntiHook` | `setEData` |
| `oSiren` | `oAntiHook` | `setEData` |

## Machine-readable output

Ver [`resource-dependency-graph.json`](resource-dependency-graph.json) (mesmo scan).

## Regenerar

```bash
cd mods/deathmatch/resources/vila-do-ipiranga-rp
python3 docs/tooling/resource_dependency_scan.py --write
```
