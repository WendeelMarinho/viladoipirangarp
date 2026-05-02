# Roadmap de Tradução — Ipiranga Roleplay (PT-BR)

**Data:** 2026-05-01  
**Objetivo:** Traduzir 100% do conteúdo voltado ao jogador de húngaro para Português Brasileiro  
**Regra base:** Traduzir apenas strings expostas ao jogador. Preservar nomes de variáveis, eventos e funções.

---

## Glossário Canônico de Termos RP

Antes de qualquer tradução, este glossário é a fonte da verdade. Toda a equipe deve seguir estes termos consistentemente.

| Húngaro / Inglês | Português BR | Notas |
|---|---|---|
| Account | Conta | |
| Character / Karakter | Personagem | |
| Inventory / Inventár | Inventário | |
| Vehicle / Jármű | Veículo | |
| Faction / Frakció | Facção | |
| Money / Pénz | Dinheiro | Em DB: campo `money` — não renomear |
| Admin | Administração / Admin | Manter "Admin" em contexto técnico |
| Duty | Serviço / Plantão | Contexto de facção |
| Rank | Rank / Patente | Manter "Rank" para facções policiais |
| License / Jogosítvány | Habilitação / Licença | Habilitação para dirigir; Licença para armas |
| Bank | Banco | |
| ATM | Caixa Eletrônico / ATM | ATM aceitável |
| Shop | Loja | |
| Interior / Lakás | Imóvel / Interior | Interior no sentido de propriedade RP |
| Job / Munka | Emprego | |
| Phone / Telefon | Telefone | |
| Health / Egészség | Saúde / HP | HP aceitável em UI |
| Hunger / Éhség | Fome | |
| Thirst / Szomjúság | Sede | |
| Jail / Börtön | Prisão / Detenção | |
| Fine / Bírság | Multa | |
| Ticket | Infração | Contexto de multa de trânsito |
| Ban | Banimento | |
| Kick | Expulsão | |
| Warn | Aviso | |
| PP (Premium Points) | Pontos Premium | |
| Casino | Cassino | |
| Drug / Drog | Droga | |
| Weapon / Fegyver | Arma | |
| Skin | Skin / Aparência | Manter "skin" em contexto técnico |
| Payday | Salário / Pagamento | |
| Level / Szint | Nível | |
| Serial | Serial | Termo técnico — não traduzir |
| Premium | Premium | |
| Scoreboard | Placar | |
| HUD | HUD | Termo técnico — não traduzir |

---

## Princípios de Tradução

1. **Tom:** Servidor premium brasileiro — usar português formal mas acessível. Evitar gírias excessivas.
2. **Consistência:** Use o glossário acima em 100% das traduções. Nunca use sinônimos não aprovados.
3. **Preservar variáveis:** `{player}`, `{amount}`, `{vehicle}` — manter intactos dentro das strings.
4. **Preservar comandos:** `/veh`, `/inv`, `/char` — não traduzir comandos de jogador.
5. **Não traduzir:** Nomes de funções Lua, eventos, chaves de tabela, nomes de database.
6. **Verificação de acento:** Sempre usar acentuação correta do português brasileiro.

---

## Fase 1 — Autenticação e Interface Principal (Semanas 1–2)

**Prioridade máxima** — São as primeiras telas que o jogador vê.

### oAccount
- **Escopo:** Tela de login, registro, criação de personagem, mensagens de erro
- **Arquivos:** `oAccount/client.lua`, `oAccount/shared.lua`, possivelmente HTML/UI
- **Strings estimadas:** ~150
- **Exemplos de tradução:**
  - `"Bejelentkezés"` → `"Entrar"`
  - `"Regisztráció"` → `"Registrar"`
  - `"Jelszó"` → `"Senha"`
  - `"Felhasználónév"` → `"Usuário"`
  - `"Karakterkészítés"` → `"Criação de Personagem"`
  - `"Hibás jelszó"` → `"Senha incorreta"`
  - `"Fiók nem létezik"` → `"Conta não encontrada"`
- **Responsável:** Claude Code (análise) + Cursor (execução em massa)
- **Branch:** `translation/oAccount`

### [Interface]/oHud
- **Escopo:** Labels do HUD (saúde, fome, sede, dinheiro)
- **Strings estimadas:** ~30
- **Branch:** `translation/oHud`

### [Interface]/oRadar
- **Escopo:** Labels do radar/mapa
- **Strings estimadas:** ~20
- **Branch:** `translation/oRadar`

### oNametag
- **Escopo:** Formato de exibição de nomes sobre personagens
- **Strings estimadas:** ~10
- **Branch:** `translation/oNametag`

---

## Fase 2 — Dashboard e Inventário (Semanas 3–4)

### oDashboard
- **Escopo:** Painel principal do personagem, informações de facção, stats
- **Arquivos:** 16 scripts Lua + UI assets
- **Strings estimadas:** ~200
- **Exemplos:**
  - `"Karakter információk"` → `"Informações do Personagem"`
  - `"Frakció"` → `"Facção"`
  - `"Rang"` → `"Rank"`
  - `"Szolgálati idő"` → `"Tempo de Serviço"`
- **Branch:** `translation/oDashboard`

### oInventory
- **Escopo:** UI do inventário, nomes de ações (usar, dropar, equipar), tooltips
- **Arquivos:** 21 scripts Lua
- **Strings estimadas:** ~300
- **Exemplos:**
  - `"Inventár"` → `"Inventário"`
  - `"Tárgy használata"` → `"Usar Item"`
  - `"Eldobás"` → `"Descartar"`
  - `"Tárgy átadása"` → `"Transferir Item"`
- **Branch:** `translation/oInventory`

---

## Fase 3 — Veículos e Economia (Semanas 5–6)

### oVehicle
- **Escopo:** Mensagens de motor, combustível, dano, documentação
- **Arquivos:** 23 scripts Lua
- **Strings estimadas:** ~250
- **Exemplos:**
  - `"Motor"` → `"Motor"`  (igual)
  - `"Üzemanyag"` → `"Combustível"`
  - `"Zárva"` → `"Trancado"`
  - `"Nyitva"` → `"Destrancado"`
  - `"Gépjármű dokumentumok"` → `"Documentos do Veículo"`
- **Branch:** `translation/oVehicle`

### oCarshop
- **Escopo:** Interface da concessionária
- **Strings estimadas:** ~80
- **Branch:** `translation/oCarshop`

### oTuning
- **Escopo:** Menu de customização de veículos
- **Strings estimadas:** ~100
- **Branch:** `translation/oTuning`

### oBank
- **Escopo:** Interface bancária, mensagens de transação
- **Strings estimadas:** ~100
- **Branch:** `translation/oBank`

### oShop
- **Escopo:** Lojas, preços, mensagens de compra
- **Strings estimadas:** ~80
- **Branch:** `translation/oShop`

### oPayday
- **Escopo:** Mensagem de pagamento de salário
- **Strings estimadas:** ~20
- **Branch:** `translation/oPayday`

---

## Fase 4 — Comunicação e RP Core (Semanas 7–8)

### oPhone
- **Escopo:** Interface do celular, SMS, contatos, apps
- **Arquivos:** 7 scripts + assets de UI
- **Strings estimadas:** ~200
- **Exemplos:**
  - `"Üzenetek"` → `"Mensagens"`
  - `"Névjegyek"` → `"Contatos"`
  - `"Hívás"` → `"Ligar"`
  - `"Üzenet küldése"` → `"Enviar Mensagem"`
- **Branch:** `translation/oPhone`

### oChat
- **Escopo:** Prefixos de chat, mensagens de sistema
- **Strings estimadas:** ~50
- **Branch:** `translation/oChat`

### oSiren
- **Escopo:** Interface de sirene policial/EMS
- **Strings estimadas:** ~30
- **Branch:** `translation/oSiren`

### oLicenses
- **Escopo:** Interface de habilitação, exame de direção
- **Strings estimadas:** ~80
- **Branch:** `translation/oLicenses`

### oDriveschool
- **Escopo:** Escola de condução
- **Strings estimadas:** ~60
- **Branch:** `translation/oDriveschool`

---

## Fase 5 — Administração e Moderação (Semanas 9–10)

**Nota:** A tradução de ferramentas admin pode ser parcial — muitos administradores preferem termos técnicos em inglês.

### oAdmin
- **Escopo:** Comandos administrativos, painéis, mensagens de punição
- **Arquivos:** 14 scripts Lua
- **Strings estimadas:** ~400
- **Estratégia:** Traduzir mensagens voltadas ao jogador; manter interface admin em inglês/PT-BR técnico
- **Exemplos:**
  - `"Kitiltva"` → `"Banido"`
  - `"Figyelmeztetés"` → `"Aviso"`
  - `"Rúgás"` → `"Expulsão"`
  - Mensagem de ban ao jogador: em PT-BR completo
  - Interface de painel admin: PT-BR técnico
- **Branch:** `translation/oAdmin`

### oTicket
- **Escopo:** Sistema de multas/infrações RP
- **Strings estimadas:** ~50
- **Branch:** `translation/oTicket`

---

## Fase 6 — Empregos (Semanas 11–12)

Cada emprego tem sua própria branch.

| Emprego | Strings Est. | Branch |
|---|---|---|
| oJob (base) | ~100 | `translation/oJob-base` |
| oJob_PizzaMaker | ~40 | `translation/oJob-pizza` |
| oJob_Cashier | ~40 | `translation/oJob-cashier` |
| oJob_Builder | ~50 | `translation/oJob-builder` |
| oJob_Hacker | ~60 | `translation/oJob-hacker` |
| oJob_Cleaner | ~40 | `translation/oJob-cleaner` |
| oJob_Newspaper | ~50 | `translation/oJob-newspaper` |
| oJob_Gardener | ~40 | `translation/oJob-gardener` |
| oJob_FurnitureTransport | ~50 | `translation/oJob-furniture` |
| oJob_foodDelivery | ~50 | `translation/oJob-delivery` |
| Demais empregos | ~200 | Respectivos |

---

## Fase 7 — Sistemas Periféricos (Semanas 13–14)

### [Carlos] — Subsistemas
- **oFuel** → Combustível, mensagens de posto
- **oCasino** → Interface de cassino (blackjack, pôquer, caça-níquel)
- **oWeapons** → Loja de armas, craft, mensagens
- **oDoors/oGates** → Mensagens de porta/portão
- **Strings totais estimadas:** ~500

### Outros sistemas
- `oDrugs` — Interface de drogas (~80 strings)
- `oTreasureHunt` — Caça ao tesouro (~40 strings)
- `oDeath` — Sistema de morte/hospital (~50 strings)
- `oGraffiti` — Interface de grafite (~20 strings)
- `oAlcohol` — Sistema de álcool (~30 strings)
- `oCinema` — Interface do cinema (~30 strings)

---

## Fase 8 — Revisão e QA (Semanas 15–16)

- [ ] Revisão de consistência do glossário em toda a codebase
- [ ] Teste em servidor de desenvolvimento com jogadores beta
- [ ] Verificação de encoding (UTF-8 em todos os arquivos)
- [ ] Verificação de strings esquecidas via grep de termos húngaros comuns
- [ ] Documentar termos aprovados adicionados ao glossário

### Script de verificação de strings húngaras residuais

Após cada fase, executar grep para termos comuns em húngaro:
```
-- Termos húngaros para verificar:
-- "Hiba", "Karakter", "Jelszó", "Felhasználó", "Sikeres",
-- "Inventár", "Jármű", "Frakció", "Rang", "Pénz"
```

---

## Não Traduzir

Os seguintes conteúdos **não devem ser traduzidos**:

- **`[Old]/`** — 28 recursos deprecados — arquivar sem traduzir
- **`hedit/`** — Ferramenta de editor interno — desativar em produção
- **Nomes de eventos MTA** — `onPlayerJoin`, `onResourceStart`, etc.
- **Nomes de funções Lua** — preservar exatamente
- **Chaves de tabelas de banco de dados** — `charname`, `money`, etc.
- **Nomes de exports** — preservar para compatibilidade entre recursos
- **Comentários de código** — traduzir somente se necessário para manutenção

---

## Estimativa de Esforço Total

| Fase | Semanas | Strings | Recursos |
|---|---|---|---|
| Fase 1 | 1–2 | ~210 | 4 |
| Fase 2 | 3–4 | ~500 | 2 |
| Fase 3 | 5–6 | ~630 | 6 |
| Fase 4 | 7–8 | ~420 | 5 |
| Fase 5 | 9–10 | ~450 | 2 |
| Fase 6 | 11–12 | ~720 | 14 |
| Fase 7 | 13–14 | ~750 | ~20 |
| Fase 8 | 15–16 | Revisão | Todos |
| **Total** | **16 semanas** | **~3.680 strings** | **~53 recursos** |

---

## Ferramentas Recomendadas

- **Claude Code:** Análise de contexto, identificação de strings, tradução de blocos complexos
- **Cursor:** Execução em massa de substituições repetitivas
- **grep/ripgrep:** Encontrar strings residuais em húngaro
- **Git diff:** Revisão de cada PR de tradução antes de merge
