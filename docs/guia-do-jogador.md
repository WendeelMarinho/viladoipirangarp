# Guia do jogador — Vale do Ipiranga RP (MTA:SA)

**Atualização:** 2026-05-02  
**Público:** jogadores (nível usuário), não admins.  
**Nota importante:** grande parte das **facções legais e organizações** (nomes, postos de *duty*, salários de patente) vive na **base de dados** (`factions`, membros, etc.). O que vês no jogo (painel **Organizações** no F1) é a fonte “oficial” no teu servidor. Este guia explica o **tipo de conteúdo** que o gamemode oferece e aponta **mapas físicos** extraídos dos ficheiros `.map` do projeto.

Para o motor do servidor (arranque, recursos, rede), vê [resumo-tecnico-servidor.md](resumo-tecnico-servidor.md).

---

## 1. Primeiros passos

1. **Conta e personagem** — após entrar no servidor, regista/login na UI de contas (`oAccount`). Crias ou escolhes um **personagem** (nome IC, idade, aparência, etc.).
2. **Painel F1 (`oDashboard`)** — páginas típicas:
   - **Visão geral** — stats do personagem (trabalho, organização, dinheiro, tempo até pagamento…).
   - **Patrimônio** — dinheiro na mão, banco (quando aplicável), moedas de casino, etc.
   - **Organizações** — facções das quais és membro; convites/ranks dependem da configuração do servidor.
   - **Configurações** — gráficos, personagem, mira, nametag, dicas.
3. **Telemóvel (`oPhone`)** — contactos, apps e funções sociais IC (SMS, chamadas, etc., conforme o que o servidor tiver ativo).
4. **Radar / mapa** — usa o mapa do MTA/GTA para te orientares; coordenadas abaixo seguem o eixo **X, Y, Z** do mundo San Andreas.

---

## 2. Como “funciona a vida” no jogo (loop de RP)

| Sistema | O que representa para ti |
|--------|---------------------------|
| **Dinheiro e banco (`oBank`, lojas)** | Ganhaste com trabalho, facção, vendas ou multas; retiras/depositas em ATMs/banco conforme scripts do servidor. |
| **Payday (`oPayday`)** | Ciclo periódico de salário/impostos; o dashboard mostra **tempo até o pagamento**. |
| **Fome / sede / vida (`oHud`, `oBoneDamage`)** | Necessidades e combate com consequências; trata disso com comida, hospital, RP. |
| **Morte / hospital (`oDeath`)** | Ao morreres, o fluxo de revive/hospital depende das regras do servidor (EMS, hospital no mapa custom). |
| **Inventário (`oInventory`)** | Itens, peso, armações, objectos de trabalho; interage com lojas, mercado, facções. |
| **Veículos (`oVehicle`)** | Chaves, motor, combustível (`oFuel` / Tesla `oTeslaCharger`), danos; compra/aluguer em concessionárias e mapas relacionados (`oCarshop`, tuning `oTuning`). |
| **Imóveis (`oInteriors`)** | Casas/interiores com dono; aluguer, porta, marcadores — vê anúncios IC ou comandos/UI do recurso. |
| **Mercado jogador (`oMarket`)** | Venda/compra entre jogadores. |
| **Multas (`oTicket`, radares `oTraffipax`)** | Infrações de trânsito ou outras aplicadas IC (polícia). |
| **Licenças (`oLicenses`)** | Carta de condução, porte, documentos RP; frequentemente exigidas para empregos legais ou armas.

Tudo isto deve ser jogado **in-character**: o relatório técnico e o cheat não são assunto deste guia.

---

## 3. Organizações e facções (conceito)

### 3.1 O que são “organizações” aqui?

No painel **Organizações** do F1 aparece a tua ligação a **facções** guardadas no servidor. Cada uma tem, entre outras coisas:

- **Nome e tipo** (definidos pelos admins na base dados / ferramentas de facção).
- **Patentes/ranks**, salários por rank, permissões para *duty*.
- Marcadores de **serviço** (*duty*) e por vezes equipamento/skins autorizadas.

**Não existe uma lista fixa no código-fonte** com todos os nomes que vais ver no IP do Ipiranga — isso é **por servidor**. O guia diz o **papel** de cada tipo de script:

### 3.2 Polícia e terminal MDC

O recurso **`oMDC`** (no computador dentro do veículo/puesto policial) está alinhado, no código, a identidades como:

- **Polícia Civil — 17ª DP (Ipiranga)** (`pd`)
- **Polícia Militar — PMESP** (`sd`)

Serve para **consultas** (pessoas, veículos, procurações, multas, contas internas), com campos já em português na UI. Quem pode abrir o MDC são contas/unidades autorizadas pela **organização policial** configurada na DB e pelas permissões administrativas.

### 3.3 Outras facções

Gangues, EMS, bombeiros, máfias, empresas fechadas, etc. são **facções normais** no mesmo sistema: entras por **convite RP** / líder, e o dia a dia (rotas, armário, dinheiro da facção) passa pelo painel de facção e pelos scripts agregados (`oFactionScripts`, `oGate`, skins `oFKSkins_*`, etc.).

---

## 4. Mapas de “headquarters” e zonas de gangue

Estes pontos foram obtidos a partir dos **primeiros objectos** dos ficheiros `.map` nos recursos indicados — servem como **GPS aproximado** (centro da área construída). No jogo, a entrada real pode ser um portão ou interior; **desloca-te no veículo ou a pé** até à zona e procura o edifício IC.

Coordenadas no formato **X, Y, Z** (mundo vanilla San Andreas).

| Recurso (mapa) | Tema IC (legado OriginalRP / mapa) | Coordenadas aproximadas | Região GTA (orientação) |
|----------------|-------------------------------------|-------------------------|-------------------------|
| `oPDOutsideMap` | Perímetro exterior **delegacia / LSPD** | 1555, -1610, 15 | Centro de **Los Santos** (área típica da comisaria) |
| `oNewPD` + interiores `oPDInteriorMap`, etc. | Complementos **PD** (academia `oPD_TrainingMap`, pátio apreendidos `oPDLefoglaltMap`) | — | Mesma macrozona LS; explorar no radar |
| `oAlbanian-HQ` | Sede **Albanian Mafia** (mapa) | 970, -1260, 16 | **Santa Maria Beach** / oeste de LS |
| `oLosZetasMap` | Sede **Los Zetas** (mapa) | 875, -20, 63 | Colinas **a norte de LS** (zona residencial nobre, ~Richman/Mulholland) |
| `oCrips_HQMap` | Sede **Crips** | 2260, -1640, 15 | **East Los Santos** |
| `oWahChing` | Sede **Wah Ching** | 2490, -1745, 13 | **East LS** / bairro |
| `oHooverMAP` (em `oHooverMAP`) | **Hoover / Shady Eighties** (blocos) | 2485, -1410, 30 | East LS |
| `oMexikoHQ` | **Cartel / mexicano** (nome do recurso) | 330, -1510, 24 | **Temple / norte de LS** |
| `oCartelHQ` | **Cartel** (celeiro / zona rural) | 1520, 15, 23 | **Flint County** / estradas a norte de LS |
| `oTambovHQ` | **Tambov** (estrutura murada) | 1350, -1650, 13 | **Willowfield / sul LS** |
| `oSheriffHQ` | **Sheriff** (Dillimore / rural) | 620, -585, 17 | **Dillimore** (Red County) |

**Atenção:** o `oStarter` referencia ainda `oPiruMap` e `oHooverHQfix`; se no teu disco **não** existir symlink/recurso, esses mapas podem não carregar. O Piru antigo aparece só em pasta `[OLD]` nesta cópia — confirma no teu servidor com o admin se o mapa está ativo.

### Como ir até lá (jogador)

1. Abre o **mapa grande** (tecla de mapa do MTA/GTA).
2. Compara as **coordenadas** com a tua posição atual (pede ajuda ao `F1`/debug só se o servidor permitir; em puro RP usa **GPS IC** ou guia de estrada).
3. Aluga/compra carro (`oCarrentMap`, `oCarshop`), autocarro (`oBus`) ou usa **táxi RP** entre jogadores.
4. Em **zonas fechadas** (`oLezarasok` e similares), respeita regras do servidor — nem todo o terreno é público IC.

---

## 5. Empregos (trabalhos civis)

A lista principal exibida no hub de empregos vem de `[Jobs]/oJob/global.lua`. Os textos originais ainda estão em húngaro no ficheiro; abaixo está a **tradução do sentido** e a **área** indicada no script.

| # | Nome no script (HU) | Tradução / papel | Zona citada no script | Emprego ativo no `oStarter` |
|---|---------------------|------------------|----------------------|-----------------------------|
| 1 | Takarító | **Faxineiro / limpeza** (limpar casas e locais) | Los Santos, Red County | Sim (`oJob_Cleaner` + variantes como `oTakaritoNew`) |
| 2 | Pénztáros | **Caixa de supermercado** | Los Santos, Red County | Sim (`oJob_Cashier`) |
| 3 | Pizzakészítő | **Pizzaiolo / pizzaria** | Los Santos | Sim (`oJob_PizzaMaker`) |
| 4 | Etikus Hacker | **“Hacker ético”** (missões de intrusão autorizada minigame) | Los Santos | Sim (`oJob_Hacker`) |
| 5 | Újságos | **Jornaleiro** (entrega de jornais) | Red County | Sim (`oJob_Newspaper`) |
| 6 | Költöztető | **Mudanças / transporte de móveis** entre imóveis | Los Santos | Sim (`oJob_FurnitureTransport`) |
| 7 | Kertész | **Jardineiro** | Los Santos, Red County | Sim (`oJob_Gardener` + `oGardenerMap`) |
| 8 | Darukezelő | **Operador de grua** em canteiros de obras | Los Santos | Sim (`oJob_Crane` + mapas `oConstructionMap*`, `oEszakiEpitkezes`) |

**Outros empregos / atividades ligadas a mapas ou recursos:**

- **`oBus`** — motorista de autocarro (rotas no mapa `oBusMap`).
- **Entrega de comida** — existe recurso `oJob_foodDelivery` na árvore; **não** está na lista curta do `starter_manifest.lua` desta revisão — pode estar desligado ou iniciado à parte no teu host.
- **`oJob_carFactory`, `oJob_PackageTransporter`, `oJob_WaterPipeMechanic`** — presentes na pasta `[Jobs]`; confirma com o teu `oStarter` / symlinks se estão **realmente** a correr.

Normalmente **aceitas o trabalho** num NPC/marcador no mundo (cada `oJob_*` tem o seu `renderC.lua` / `client.lua` com pontos de interação). O veículo de trabalho pode ser criado via evento comum `job > createJobVehicle` (`oJob/server.lua`).

---

## 6. Onde saber mais (sem ser jogador)

- Catálogo de recursos e ordem de arranque: [catalogo-originalrp-ipiranga.md](catalogo-originalrp-ipiranga.md).
- Infra e VPS: [infra/server-setup.md](infra/server-setup.md).

---

*Documento gerado a partir do código do gamemode Vale do Ipiranga / OriginalRP. Nomes de facções “oficiais” do teu universo narrativo podem ser sobrescritos pela equipa administrativa na base de dados.*
