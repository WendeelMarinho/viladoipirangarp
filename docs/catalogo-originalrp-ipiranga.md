# Catálogo do gamemode (OriginalRP / Vale do Ipiranga RP)

**Data:** 2026-05-02  
**Pasta:** `mods/deathmatch/resources/vila-do-ipiranga-rp/`  
**Origem:** base **Original Roleplay** (MIT). Este repositório contém ~**400** recursos com `meta.xml` (~**123** ficheiros `.map` dispersos pela árvore). **O servidor em produção só carrega o que está referenciado no `oStarter`** (e o que existe como symlink em `mods/deathmatch/resources/`). Recursos apenas na pasta mas sem symlink nem arranque **não** entram no jogo até serem ligados.

---

## 1. Visão das features principais

Abaixo está o que o gamemode **oferece como produto RP**, independentemente dos ficheiros soltos na árvore.

| Área | O que faz (resumo) |
|------|--------------------|
| **Conta / personagem** | Login/registo (`oAccount`), sync de dados (`oSync`), whitelist (`oWL`/`oCore`), criação de personagens, dashboards (`oDashboard`), níveis (`oLvl`), licenças (`oLicenses`). |
| **Comunicação** | Chat RP/classic (`oChat`), telefone (`oPhone`), eventual walkie-talkie, sirenes (`oSiren`), rádio de veículos (`oVehicleRadio`), comandos extra (`oExtraCommands`). |
| **Interface** | HUD, radar personalizado (`oRadar`), velocímetro (`oSpeedo`), infobox (`oInfobox`), inventário DX (`oInventory`), marcação/nametags (`oNametag`), crosshair, scoreboard, tips. |
| **Economia** | Salário/períodos (`oPayday`), banco (`oBank`), lojas (`oShop`), mercado (`oMarket`), trabalhos diversos (`oJob`, `oJob_*`), casino/roleta, impressão (`oPrinter`), multas (`oTicket`). |
| **Veículos** | Dono/sync/lógica de veículos (`oVehicle`), concessionárias (~`oCarshop`), tuning (`oTuning`), pinturas (`oPaintjobs`), combustível/recarga Tesla (`oFuel`, `oTeslaCharger`), drive assist Tesla, traffipax (radares), placas/markers extras, handling custom (`oHandling`), extras visuais (`oVehicleExtras`), tempomat; painel para portas/comp. por modelo (**`oCVEH`** — interação modelo-a-modelo no veículo). |
| **Imóveis / interiores** | Interiores compráveis e edificação (`oInteriors`, `oInteriorBuilding`, `oGNIproperty`). |
| **Roleplay mundo aberto** | Morte/revive (`oDeath`), dano ao osso (`oBoneDamage`/`oBone`), pesca (`oFishing`), drogas/minigames, caça ao tesouro (`oTreasureHunt`), animações (`oAnims`). |
| **Forças de ordem / facções** | Script agregador (`oFactionScripts`), MDC (`oMDC`), mapas HQ (vários `*Map`), skins de facções (`oFKSkins_*`, `oNAVSkins`). |
| **Admin / anti-cheat** | Painel admin (`oAdmin`), logs (`oLogs`), antichet (`oAnticheat`, `oAnticheat2`), proteções client (`oSkinProtect`), verificação/rede (`oVerify`). |
| **Mapas mundo** | Construções custom (hospitais, delegacias, lojas de carros, tuning, trabalhos etc.) através de dezenas de recursos tipo `*[Map]*` ligados pelo `oStarter`. |
| **Shaders visuais** | Pacote principal (`oShaders`) + módulos Bloom, Depth,água HD, reflexos veículos, paleta, motion blur, vinheta, neve, FXAA, etc. |
| **Conteúdo extra / packs** | Vários sistemas sob `[Carlos]`, `[theMark]`, `[paul]`, `[Dexter]` (eventos rally/F1, peixe, Comboio, dude maps, …) — só ativos se o recurso estiver symlinkado **e** (se aplicável) `start`'ado. |

Para **profundidade de segurança e priorização de manutenção**, ver também `prioritized-resource-list.md` e `relatorio-tecnico.md`.

---

## 2. Recursos iniciados pelo `oStarter`

Ficheiro: `[Core]/oStarter/server.lua`. A sequência abaixo é a **ordem de `startResource`**. Alguns nomes aparecem duplicados (`oNewPD`, `oBillboards`) — o segundo arranque falha silenciosamente no log como “já em execução”. No final, **todos os recursos cujo nome casa com `^oFKSkins_`** são acrescentados automaticamente.

Ao fim há um `restartResource` retardado (~10 s) sobre `oInventory`, `oSpeedo`, `oBillboards`, `oPlant`, `oPlaneCrash` — em algumas cópias do projeto **`oPlant` / `oPlaneCrash` nem existem** (geram aviso; ver `infra/acl-e-recursos.md`).

| # | Recurso | Função (resumo PT-BR) |
|----|---------|------------------------|
| 1 | `oMysql` | MySQL — conexão e queries servidor |
| 2 | `oCore` | Core — whitelist IDs jogador FPS regras base |
| 3 | `oFont` | Fontes client para DX/interfaces |
| 4 | `oCompiler` | Utilitários compilação dev |
| 5 | `oDebug` | Debug helpers |
| 6 | `oLogs` | Logging persistido |
| 7 | `oBlur` | efeito blur client |
| 8 | `oBone` | Base ossos/física animação |
| 9 | `oJSON` | JSON shared |
| 10 | `oPreview` | Preview modelos/skins (legado) |
| 11 | `oPreviewNew` | Preview nova variante |
| 12 | `oStreamer` | Streaming elementos/modelos distância |
| 13 | `oModelLoader` | Carregador modelos DFF/COL/TXD |
| 14 | `oAnticheat` | Anti-cheat camada 1 |
| 15 | `oAnticheat2` | Anti-cheat camada 2 |
| 16 | `oCustomMarker` | Marcadores mundo customizados DX |
| 17 | `oHandling` | Handling físico dos veículos (DB/arquivos export) |
| 18 | `oChat` | Chat RP / admin / comandos comunicação |
| 19 | `oSkinProtect` | Bloqueia alterações abusive em skin |
| 20 | `oLoading` | Tela entrada carregamento |
| 21 | `o3DElements` | Elementos 3D marcação texto mundo |
| 22 | `oWL` | Whitelist secundário/sincronização |
| 23 | `npc_hlc` | NPCs high-level comportamento ped |
| 24 | `oDestroyer` | Remove objectos modelo mundo default |
| 25 | `oWater` | Água ajustes remap |
| 26 | `oMapfix` | Corrige glitch colisões mapa mundo |
| 27 | `oNewDeliMap` | Mapa delicatesse / deli custom |
| 28 | `oNewCityhallMap` | Prefeitura / city hall novo layout |
| 29 | `oHospitalNewNewMap` | Hospital novo exterior/interior objeto |
| 30 | `oSampModels` | Props estilo samp (paredes objetos) |
| 31 | `oUjsag` | Banca jornal / kiosque exterior |
| 32 | `oKukaMap` | Mapa lixeira reciclagem (kuka) |
| 33 | `oFurnitures` | Catálogo props móveis mundo |
| 34 | `oBusMap` | Terminal/área autocarros |
| 35 | `oIdlewoodMarket` | Mercado Idlewood |
| 36 | `oCarshop-main` | Concessionária principal mapa |
| 37 | `oWellStackedMap` | Restaurante Well Stacked Pizza mapa |
| 38 | `oCarrentMap` | Aluguer veículos mapa |
| 39 | `oTuningMap` | Oficina tuning exterior mapa |
| 40 | `oLezarasok` | Zonas fechadas / barreiras RP |
| 41 | `oIdlewoodMap` | Idlewood custom objectos |
| 42 | `oNewPD` | Delegacia PD nova (fragmento mapa) |
| 43 | `oAlbanian-HQ` | Quartel facção albanesa |
| 44 | `oLosZetasMap` | Quartel Los Zetas |
| 45 | `oUjszerelo` | Oficina jornal/repair (nome legado HU) |
| 46 | `oPiruMap` | Área Piru gangs |
| 47 | `oPD_TrainingMap` | Treino academia polícia |
| 48 | `oCrips_HQMap` | Sede Crips exterior |
| 49 | `oPDOutsideMap` | Perímetro exterior DP |
| 50 | `oPDLefoglaltMap` | Pátio apreendidos polícia |
| 51 | `oPDInteriorMap` | Interior delegacia |
| 52 | `oHospitalTexture` | Sobreposição texturas hospital |
| 53 | `oHospitalInteriorMap` | Interior hospital custom |
| 54 | `oWahChing` | HQ Wah Ching gang |
| 55 | `oHooverHQfix` | Fix mapa Hoover/Shady |
| 56 | `oNewPD` | *(2.º start — recurso já ativo)* — delegacia nova |
| 57 | `oInfobox` | Sistema mensagens HUD infobox |
| 58 | `oRadar` | Radar custom mapa navegação |
| 59 | `oSpeedo` | Velocímetro / odómetro HUD |
| 60 | `oNametag` | Nomes placas jogador |
| 61 | `oInventory` | Inventário itens usar arrastar peso |
| 62 | `oInterface` | Gestor UI overlays gerais |
| 63 | `oHud` | Barras vida fome HUD base |
| 64 | `oCrosshair` | Mira centro ecrã |
| 65 | `oNoblur` | Desativa blur em cenários FPS |
| 66 | `oDeath` | Morte revive hospital bleedout |
| 67 | `oAccount` | Login conta personagem MySQL |
| 68 | `oVehicle` | Dono veículos chaves motor danos sync |
| 69 | `oCarshop` | Lógica compra veículos loja |
| 70 | `oNewSkinshop` | Loja skins personagem |
| 71 | `oInteriors` | Imóveis entradas interiores instâncias |
| 72 | `oAdmin` | Painel admin permissões teleports |
| 73 | `oAnims` | Animações extras menu |
| 74 | `oDashboard` | Menu F1 painel jogador stats |
| 75 | `oScoreboard` | Tab jogadores online |
| 76 | `oTips` | Dicas client rotação |
| 77 | `oJob` | Base empregos salário progresso |
| 78 | `oLicenses` | Carta porte armas documentos |
| 79 | `oCVEH` | Painel portas/comp. veículo por modelo (overlay) |
| 80 | `oLvl` | Nível XP skills softcap |
| 81 | `oBus` | Job motorista autocarro |
| 82 | `oShop` | Lojas itens gerais |
| 83 | `oElementEditor` | Edição elementos debug staff |
| 84 | `oGate` | Portões automáticos facções |
| 85 | `oIndex` | Índice lista dados jogador quick |
| 86 | `oTraffipax` | Radares multa velocidade props |
| 87 | `oJob_Newspaper` | Entrega jornal |
| 88 | `oJob_Cleaner` | Limpeza ruas |
| 89 | `oJob_PizzaMaker` | Pizzaria produção |
| 90 | `oJob_FurnitureTransport` | Mudanças móveis |
| 91 | `oPlacedo` | Colocação objectos jogador (decoração) |
| 92 | `oHifi` | Hi-fi som interior |
| 93 | `oCasino` | Apostas casino interior |
| 94 | `oTuning` | Neon airride peças tuning veículo |
| 95 | `oQuitmessage` | Mensagem saída jogador |
| 96 | `oFactionScripts` | Scripts agregados facções |
| 97 | `oInteraction` | Interação E objectos portas |
| 98 | `oBoneDamage` | Dano localizado por osso |
| 99 | `oFishing` | Pesca minigame |
| 100 | `oPhone` | Telemóvel SMS chamadas apps |
| 101 | `oMarket` | Mercado jogador venda |
| 102 | `oBank` | Banco transferências ATM |
| 103 | `oPayday` | Ciclo salário hora impostos |
| 104 | `oSiren` | Sirenes polícia EMS sons |
| 105 | `oWeaponModels` | Substitui modelos armas 3D |
| 106 | `oPaintjobs` | Texturas pintura veículos DDS |
| 107 | `oBetterRain` | Chuva melhorada |
| 108 | `oWeaponSkill` | Progressão skill armas |
| 109 | `oPayNSpray` | Oficina spray reparo rápido |
| 110 | `oJunkyard` | Sucateiro desmanche |
| 111 | `oDrugs` | Plantas venda consumo drogas |
| 112 | `oMinigames` | Mini-jogos diversos |
| 113 | `oBankrob` | Assalto banco evento |
| 114 | `oVehicleRadio` | Rádio veículo estações |
| 115 | `oJob_Cashier` | Caixa supermercado |
| 116 | `oJob_Hacker` | Trabalho hacker minigame |
| 117 | `oTempomat` | Cruise control veículo |
| 118 | `oForestAnimals` | Animais floresta ambiente |
| 119 | `oMDC` | Terminal polícia MDC consultas |
| 120 | `oFuel` | Posto combustível abastecer |
| 121 | `oTBoards` | Quadros anúncios mundo |
| 122 | `oTeslaCharger` | Postos recarga estilo Tesla |
| 123 | `oWeaponShop` | Loja armas legal |
| 124 | `oDriveschool` | Escola condução exames |
| 125 | `oVehicleExtras` | Extras veículo script visuais |
| 126 | `oTreasureHunt` | Caça tesouro evento |
| 127 | `oExtraCommands` | Comandos utilitário /id /lvl etc |
| 128 | `oGNIproperty` | Extensão propriedades GNI |
| 129 | `oPremium` | Conta premium benefícios |
| 130 | `oBag` | Mochila visual slots extra |
| 131 | `oVehicleFixMarker` | Marker reparo veículo mundo |
| 132 | `oJob_Gardener` | Jardineiro manutenção zonas |
| 133 | `oTakaritoNew` | Limpeza nova variante mapa job |
| 134 | `oWeaponSkins` | Skins armas alternativas |
| 135 | `oTeslaDriveAssist` | Assistência condução Tesla RP |
| 136 | `oPlazaMap` | Praça central mapa custom |
| 137 | `oDx` | Biblioteca desenho DX utilitários |
| 138 | `oBusinessWarhouseMap` | Armazém negócios mapa |
| 139 | `oPrinter` | Impressão documentos RP |
| 140 | `oRope` | Cordas tow attach |
| 141 | `oTicket` | Sistema multas papel |
| 142 | `oRoulette` | Roleta casino adicional |
| 143 | `oMushrooms` | Colheita cogumelos item |
| 144 | `oBankMap` | Edifício banco mapa exterior |
| 145 | `oEszakiEpitkezes` | Construção norte canteiro obras |
| 146 | `oWeaponCraft` | Crafting armas bancada |
| 147 | `oUjsagos_map` | Mapa job jornaleiro rota |
| 148 | `oBlueberryKikoto` | Zona export Blueberry |
| 149 | `oKoltoztetoMap` | Mapa mudanças transporte |
| 150 | `oGardenerMap` | Mapa job jardineiro |
| 151 | `oGarageBid_map` | Mapa leilão garagens |
| 152 | `oGarageBid` | Leilão garagens lógica |
| 153 | `oBillboards` | Outdoors dinâmicos imagens |
| 154 | `oPet` | Sistema animais estimação |
| 155 | `oDevtools` | Ferramentas desenvolvedor in-game |
| 156 | `oHospitalNewMap` | Hospital mapa variante |
| 157 | `oCharCreateMap` | Zona criação personagem mapa |
| 158 | `oErtekbecsloMap` | Avaliador bens / penhoras mapa |
| 159 | `oConstructionMap1` | Canteiro obras mapa 1 |
| 160 | `oConstructionMap2` | Canteiro obras mapa 2 |
| 161 | `oShark` | Tubarão evento praia |
| 162 | `oBaysideMap` | Bayside custom mapa |
| 163 | `oUC_map_blueberry` | Stand carros usados Blueberry |
| 164 | `oUC_map_eastls` | Stand usados East LS |
| 165 | `oSormaffiaMap` | Mapa máfia porto |
| 166 | `oCluckinbellMap` | Cluckin Bell restauração mapa |
| 167 | `oNewSzereloMap` | Oficina mecânico novo mapa |
| 168 | `oInteriorBuilding` | Construção interior dinâmica portas |
| 169 | `oPoliceCellsInterior_MAP` | Celas polícia interior |
| 170 | `oJob_Crane` | Job guindaste porto |
| 171 | `oPlaneCrash` | Mapa/evento queda avião (fallback se recurso existir) |
| 172 | `oDilimoreGasStationMap` | Posto Dilimore mapa |
| 173 | `oPlant` | Plantas/agricultura mapa (**pode não existir** recurso nesta cópia) |
| 174 | `oGoggle` | Óculos equipamento visual |
| 175 | `oBillboards` | *(2.º start)* outdoors (idempotente erro log) |
| 176 | `oMexikoHQ` | Quartel mexicano HQ |
| 177 | `oBeerMaffiaInterior` | Interior Beer Mafia |
| 178 | `oZacskosBirtok` | Rancho fazenda grande mapa |
| 179 | `oDaruparkolo` | Estacionamento guindaste job |
| 180 | `trailerDepoBuild` | Construção depósito trailers |
| 181 | `oParkolo` | Estacionamentos RP maps |
| 182 | `oLCMob` | LC Mob garagem facção mapa |
| 183 | `cigy` | Consumível cigarros |
| 184 | `oGraffiti` | Grafite spray tags mundo |
| 185 | `oVelvettFKMap` | Área Velvet FK faction |
| 186 | `oNAV` | Fiscalização tributária NAV HUD/map |
| 187 | `oNAVSkins` | Skins funcionários NAV |
| 188 | `oShaders` | Controlador shaders master |
| 189 | `oShader_Water` | Água HD shader |
| 190 | `oShader_Bloom` | Bloom pós-process |
| 191 | `oShader_Depth` | Profundidade / SSAO style |
| 192 | `oShader_HDTextures` | Texturas HD upscale |
| 193 | `oShader_VehicleReflection` | Reflexos carroçaria |
| 194 | `oShader_Palette` | Paleta cor grading |
| 195 | `oShader_MotionBlur` | Motion blur suave |
| 196 | `oShader_Vignette` | Vinheta bordas |
| 197 | `oShader_Snow` | Neve atmosfera |
| 198 | `oShader_FXAA` | Anti-aliasing FXAA |
| 199 | `dude_telep` | Parcela teleport dude evento |
| 200 | `dude_map` | Mapa cenário dude paul |
| 201 | `dude_billboard` | Outdoor dude paul |
| 202 | `serialcheck` | Verificação serial cliente servidor |
| 203 | `gtavbahama` | (interior Bahamas estilo GTA V — **nem sempre presente nesta cópia**) |
| 204 | `oFKSkins_Alban` | Skins Alban (facção) *(append automático se nome `oFKSkins_*`)* |
| 205 | `oFKSkins_Bloods` | Skins Bloods *(append automático se nome `oFKSkins_*`)* |
| 206 | `oFKSkins_Mechanic` | Skins mecânico oficina *(append automático se nome `oFKSkins_*`)* |
| 207 | `oFKSkins_Mento` | Skins ambulância EMS *(append automático se nome `oFKSkins_*`)* |
| 208 | `oFKSkins_PD` | Skins departamento polícia *(append automático se nome `oFKSkins_*`)* |
| 209 | `oFKSkins_Sheriff` | Skins sheriff *(append automático se nome `oFKSkins_*`)* |
| 210 | `oFKSkins_Turkish` | Skins Turkish (facção PK) *(append automático se nome `oFKSkins_*`)* |
| 211 | `oFKSkins_Velvet` | Skins Velvet / Velvett *(append automático se nome `oFKSkins_*`)* |


Após esta sequência fixa (e tentativa de iniciar cada linha mesmo se duplicada), o servidor **adicionalmente arranca todos os recursos registados pelo MTA** cujo nome coincide com `^oFKSkins_` — não apenas os pacotes FK listados nos números 204–211. Novos pacotes com esse prefixo entram só com symlink correcto para `mods/deathmatch/resources/`.

---

## 3. Mapas (ficheiros `.map`)

Existem **123** ficheiros `.map` na pasta do gamemode. Cada `.map` vive dentro de um **recurso** MTA (map/editor definitions, remoção de modelo vanilla, objetos placement). Nem todos os `.map` correspondem a recursos iniciados pelo `oStarter`; alguns pertencem a recursos legados, duplicados em `[OLD]`, ou a mapas apenas usados quando o recurso pai é iniciado manualmente.

Listagem completa por caminho relativo a `vila-do-ipiranga-rp/`:

```
[Carlos]/[fishingEvent]/oHorgaszEvent/oHorgaszEvent.map
[Carlos]/oRoadfix/fixroad-map.map
[Carlos]/oSzereloteleppuj/oSzereloteleppuj.map
[Dexter]/oTrain/traincart-design-template/train-outer.map
[Maps]/[Faction]/oBeerMaffiaInterior/Beer-Mafia_vegleges.map
[Maps]/[Faction]/oBeerMaffiaInti_map/Beer_Mafia2_vegleges.map
[Maps]/[Faction]/oCartelTijuanaFatelepMap/cgi.map
[Maps]/[Faction]/oCartelTijuanaLatinMap/latinnegyed.map
[Maps]/[Faction]/oCrips_HQMap/crips-2021.map
[Maps]/[Faction]/oEastCoastMap/frakihq.map
[Maps]/[Faction]/oEastCoastMap/oEastCoastMap.map
[Maps]/[Faction]/oFireDepartmentMap_OLD/oFireDepartmentMap.map
[Maps]/[Faction]/oHooverMAP/SHADY-EIGHTIES-MAPPOLAS.map
[Maps]/[Faction]/oHospitalInteriorMap/oHospitalInteriorMap.map
[Maps]/[Faction]/oHospitalNewMap/oHospitalNew.map
[Maps]/[Faction]/oLCMOBMap/garazs.map
[Maps]/[Faction]/oLSFD1/oLSFD1.map
[Maps]/[Faction]/oLSFD2/oLSFD2.map
[Maps]/[Faction]/oLosZetasMap/Los-Zetas.map
[Maps]/[Faction]/oMechanicMap/oMechanicMap.map
[Maps]/[Faction]/oMechanicMap_OLD_OLD/oSzereloteleppuj.map
[Maps]/[Faction]/oMexikoHQ/mexikoi.map
[Maps]/[Faction]/oNAV/oNAV.map
[Maps]/[Faction]/oNAVInterior/oNAVInterior.map
[Maps]/[Faction]/oNewPD/oNewPD.map
[Maps]/[Faction]/oPDInteriorMap/oPDInteriorMap.map
[Maps]/[Faction]/oPDLefoglaltMap/oPDLefoglaltMap.map
[Maps]/[Faction]/oPDOutsideMap/oPDOutsideMap.map
[Maps]/[Faction]/oPD_TrainingMap/oKikepzo.map
[Maps]/[Faction]/oSormaffiaMap/oSormaffiaMap.map
[Maps]/[Faction]/oVelvettFKMap/valam.map
[Maps]/[Faction]/oWahChing/oWahChing.map
[Maps]/[JOB_MAPS]/oDaruparkolo/orp_daruparkolo.map
[Maps]/[JOB_MAPS]/oGardenerMap/oGardenerMap.map
[Maps]/[JOB_MAPS]/oKoltoztetoMap/original_koltozteto.map
[Maps]/[JOB_MAPS]/oUjsagos_map/original_ujsagos.map
[Maps]/[OLD]/oBahamaMapOLD/oBahamaMap.map
[Maps]/[OLD]/oBankMap_OLD/oBankMap.map
[Maps]/[OLD]/oCleanerMapOLD/oTakarito.map
[Maps]/[OLD]/oFurnitureJobMap_OLD/oFurnitureJobMap.map
[Maps]/[OLD]/oGovernmentOLD/oGovernment.map
[Maps]/[OLD]/oHospitalMapOLDOLD/oHospitalMap.map
[Maps]/[OLD]/oHospitalOutsideMap_OLD/oHospitalOutsideMap.map
[Maps]/[OLD]/oMechanicMap_OLD/oMechanicMap.map
[Maps]/[OLD]/oPiruMapOLD/oPiru.map
[Maps]/[OLD]/oPoliceInterior/oPoliceInterior.map
[Maps]/[OLD]/oPoliceMap/oPoliceMap.map
[Maps]/[OLD]/oTaxiHQOLD/oTaxiHQ.map
[Maps]/[OLD]/oUjsagOLD/oUjsag.map
[Maps]/[OLD]/oUjszerelo_OLD/oUjszerelo.map
[Maps]/[OLD]/oVH_Map_OLD/oVH_Map.map
[Maps]/[UsedCarshops]/oUC_map_blueberry/original_hautoker1.map
[Maps]/[UsedCarshops]/oUC_map_eastls/original_hautoker3.map
[Maps]/oAlbanian-HQ/oAlbanian-HQ.map
[Maps]/oBankMap/oBankMap.map
[Maps]/oBaysideMap/oBaysideMap.map
[Maps]/oBlueberryKikoto/oBlueberryKikoto.map
[Maps]/oBorderMap/oBorderMap.map
[Maps]/oBusMap/oBusMap.map
[Maps]/oBusinessWarhouseMap/oBusinessWarhouseMap.map
[Maps]/oCarrentMap/oCarrentMap.map
[Maps]/oCarshop-main/oCarshop-main.map
[Maps]/oCharCreateMap/oCharCreateMap.map
[Maps]/oCity-Main/oCity-Main.map
[Maps]/oCity-Main/oCityTrafficLight.map
[Maps]/oClub-mappolas/oClub-mappolas.map
[Maps]/oCluckinbellMap/oCluckinbellMap.map
[Maps]/oConstructionMap1/oConstructionMap1.map
[Maps]/oConstructionMap2/original_epitkezes.map
[Maps]/oDeliMap/oDeliMap.map
[Maps]/oDilimoreGasStationMap/dillmore_gas_station_map.map
[Maps]/oErtekbecsloMap/oErtekbecsloMap.map
[Maps]/oEszakiEpitkezes/oEszakiEpitkezes.map
[Maps]/oEventMap/original_monster.map
[Maps]/oF1mappolas/oF1mappolas.map
[Maps]/oFactory/factory2.map
[Maps]/oGanton/oGanton.map
[Maps]/oGarageBid_map/oGarageBid_map.map
[Maps]/oGyengelkedo/oGyengelkedo.map
[Maps]/oHospitalLV/oHospitalLV.map
[Maps]/oHospitalNewNewMap/oHospitalNewMap.map
[Maps]/oIdlewoodMap/oAmitakarsz.map
[Maps]/oIdlewoodMarket/idlewood-marketplace.map
[Maps]/oKinaipiacboltmappolas/oKinaipiacboltmappolas.map
[Maps]/oKozteruletMap/kfhq-original.map
[Maps]/oKukaMap/oKukaMap.map
[Maps]/oLCMob/oLCMob.map
[Maps]/oLezarasok/olezarasok.map
[Maps]/oMapfix/oMapfix.map
[Maps]/oMechanicLV/oMechanicLV.map
[Maps]/oNewCityhallMap/oNewCityhallMap.map
[Maps]/oNewDeliMap/oNewDeliMap.map
[Maps]/oNewSzereloMap/orp_szerelo.map
[Maps]/oParkolo/original_parkolomap1.map
[Maps]/oPatrikbirtok/oPatrikbirtok.map
[Maps]/oPlazaConstruction/oPlazaConstruction.map
[Maps]/oPlazaMap/oPlazaMap.map
[Maps]/oPoliceCellsInterior_MAP/oPoliceCellsInterior_MAP.map
[Maps]/oRally-Map/oRally-Map.map
[Maps]/oTakaritoNew/oTakaritoNew.map
[Maps]/oTuningLV/oTuningLV.map
[Maps]/oTuningMap/otuningmapnewja.map
[Maps]/oVH-LV/oVH-LV.map
[Maps]/oVhMap/orp_vh_map.map
[Maps]/oWellStackedMap/oWellStackedMap.map
[Maps]/oZacskosBirtok/birtok.map
[Old]/asd_deli/asd_deli.map
[Old]/asd_vh/asd_vh.map
[Old]/oMapfix_Map/map.map
[Old]/pizzahut2/pizzahut.map
[paul]/[dude_maps]/dude_map/halo.map
[paul]/[dude_maps]/dude_telep/dude_telep.map
[paul]/[dude_maps]/trailerDepoBuild/trailerDepoBuild.map
[paul]/dude_billboard/dude_billboard.map
[paul]/f1map2/F1_Story.map
[paul]/rallymap/rallymap.map
[theMark]/oOlajirodamap/original-oil-iroda.map
[theMark]/oOlajkiszedes/oOlajkiszedes.map
oCartelHQ/oCartel-HQ.map
oRallyMap/oRallyMap.map
oSheriffHQ/oSheriffHQ-Dilimore.map
oTambovHQ/oTambovGangHQ.map
oTraffipax/map/otraffipaxmap.map
```

Para regenerar (por exemplo após merges):

```bash
find mods/deathmatch/resources/vila-do-ipiranga-rp -name '*.map' | sed 's|.*/vila-do-ipiranga-rp/||' | sort
```

---

## 4. Modificações relacionadas com **carros e veículos**

### 4.1 O que há **sim** nesta cópia

| Tipo | Onde / recurso |
|------|----------------|
| **Handling** (curvas acel travagem massa…) | **`oHandling`** — export servidor `loadHandling` / reset; há também **`hedit`** (editor in-game por Remi-X) e **`oHandling18`** opcional não listado no starter. |
| **Pinturas (skin em cima dos modelos stock)** | **`oPaintjobs`** — texturas DDS por modelo; não substitui o veículo por um modelo inteiramente novo, mas renova cores/padrões. |
| **Tuning visual (neon/ar, peças mod)** | **`oTuning`** (e cópia `oTuning_bkkk`): vários `.dff` de “neon bars” cores; scripting de air ride / aftermarket. **`oVehicle`/elements**: supercharger **`block1.dff`** como peça opcional ligada aos veículos. |
| **Reflexo / shader veículos** | **`oShader_VehicleReflection`** parte do bloco shaders. |
| **Extras funcionais / UI** | `oVehicleExtras`, `oTempomat`, controlo de portas/comp. por modelo **`oCVEH`**, Traffipax (radar + recurso **`oTraffipax`** com próprio `.map`), `oFuel`, `oTeslaCharger`, `oTeslaDriveAssist`, sirenes/trânsito. |
| **Substituição completa modelo 491 Infernus** | **`oReggieEgyedi`** (`infernus.dff` + `infernus.txd` + `engineReplaceModel`). **Nota:** este recurso **não aparece na lista actual do `oStarter`** nesta revisão — só terá efeito se for iniciado manualmente ou acrescentado ao starter. |
| **Eventos com carros “mod”** | **[paul]/`oF1Event`** (hotring DFF variants), **`oRallyEvent`**/`oRallyMap` com **`wrc.dff`**, mapas forma1 vários **`oForma1Map`/mt*.DFF**. |

### 4.2 O que **não** há no sentido “pack de 300 car addons”

- Não há um único recurso tipo “_vehiclepack” cobrindo dezenas de modelos GTA com DFF diferentes do retail; **a maior parte do parque continua sendo veículos stock SA**.
- Props como **`oSampModels`** são **objectos/arquitectura** (estilo samp walls), não carros jogáveis como pack.
- Recursos **`oCarSoundReplace`**, **`oVehicleOld`**, outros legados podem coexistir na pasta mas **precisam** de estar no starter ou `start`.

### 4.3 Ferramentas auxiliares no disco mas fora do arranque padrão

- **`hedit`** — Metadados dizem autor Remi-X, editor de handling in-game útil admins/devs.

---

## 5. Inventário grosso dos ~400 nomes `meta.xml`

O comando abaixo lista **pastas que contêm `meta.xml`**, útil como inventário código-fonte (**inclui** subpastas de mapas/desenhos tipo `traincart-design-template`; nem todas são recurso público/linkado):

```bash
find mods/deathmatch/resources/vila-do-ipiranga-rp -name 'meta.xml' -printf '%h\n' | xargs -n1 basename | sort -u
```

Conflitos conhecidos com recursos default MTA (ex.: `ajax`, `ipb`, `glue`) estão referidos em `docs/infra/acl-e-recursos.md` — evitar symlink global de pastas `[Carlos]` inteiras sem filtragem.

---

## 6. Manutenção

- Para **mudar ordem/load**: editar apenas `[Core]/oStarter/server.lua` e documentar mudanças aqui.
- Para **mapear novos FK skins**: garantir nome `oFKSkins_<NomePacote>` ou inserção manual à lista estática — o loop automático já inclui todos os correspondentes registados pelo MTA.
- Esta página **não** substitui o `relatorio-tecnico.md` nem as checklists em `infra/`; são complementares.
