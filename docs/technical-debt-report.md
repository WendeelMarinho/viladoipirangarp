# Relatório de Dívida Técnica — Ipiranga Roleplay

**Data:** 2026-05-01  
**Base:** OriginalRoleplay (Hungarian, 2019–2023)  
**Severidade:** CRÍTICA / ALTA / MÉDIA / BAIXA

---

## 1. Dívidas de Segurança (Severidade CRÍTICA)

### TD-SEC-001 — Credenciais em Memória Plaintext
- **Arquivo:** `oAccount/server.lua` ~L688
- **Código:** `saver[iin] = user..'-'..pass`
- **Impacto:** Comprometimento de todas as senhas se o processo for inspecionado ou crashar com dump
- **Esforço de correção:** Baixo — remover a tabela `saver[]` e a função `listIT()`
- **Bloqueante de lançamento:** SIM

### TD-SEC-002 — Ausência de Rate Limiting em Login/Registro
- **Arquivo:** `oAccount/server.lua` — handler `loginOnServer`
- **Impacto:** Brute-force irrestrito de contas
- **Esforço de correção:** Médio — implementar contador por IP+serial com backoff
- **Bloqueante de lançamento:** SIM

### TD-SEC-003 — Admin Serials Hardcoded no Código-Fonte
- **Arquivos:** `oAdmin/g_admin.lua` (L1-14), `[Core]/oCore/server.lua` (L5-24)
- **Impacto:** Qualquer pessoa com acesso ao repositório conhece os seriais privilegiados
- **Esforço de correção:** Médio — migrar para tabela `adminserials` (já existe no schema)
- **Bloqueante de lançamento:** SIM

### TD-SEC-004 — Source Validation Ausente/Inconsistente
- **Arquivos:** Múltiplos event handlers cliente→servidor
- **Impacto:** Possível crash ou execução de lógica com source inválido
- **Esforço de correção:** Médio — criar wrapper `validatePlayerSource()` e aplicar em todos os handlers
- **Bloqueante de lançamento:** SIM

### TD-SEC-005 — Queries SQL Não-Parametrizadas
- **Arquivos:** `oAccount/server.lua` e outros (inconsistente por toda a codebase)
- **Impacto:** SQL injection em queries vulneráveis
- **Esforço de correção:** Alto — auditoria completa de todos os `dbQuery()`
- **Bloqueante de lançamento:** SIM

### TD-SEC-006 — Senhas Sem Hashing Adequado
- **Arquivo:** `oAccount/server.lua` — fluxo de login e registro
- **Impacto:** Se o banco vazar, senhas são legíveis
- **Nota:** O schema mostra `password varchar(250)` — sem indicação de algoritmo de hash seguro (bcrypt/Argon2)
- **Esforço de correção:** Alto — mudança de schema + migração de senhas existentes
- **Bloqueante de lançamento:** SIM

---

## 2. Dívidas de Arquitetura (Severidade ALTA)

### TD-ARCH-001 — Dados Relacionais em Colunas VARCHAR/TEXT
- **Tabelas afetadas:**
  - `factions.members` — VARCHAR(7000) com JSON de membros e ranks
  - `characters.bones` — JSON em VARCHAR(255)
  - `characters.adminDatas` — JSON em VARCHAR(500)
  - `characters.weaponStats` — JSON em VARCHAR(500)
  - `characters.timespent` — JSON em VARCHAR(255)
  - `bank_accounts.transactions` — VARCHAR(5000) com histórico
  - `vehicles.engineTunings` — VARCHAR(500) com JSON
- **Impacto:** Impossível fazer queries eficientes, sem validação de schema, risco de truncamento
- **Esforço de correção:** Alto — necessita tabelas normalizadas e migração de dados

### TD-ARCH-002 — Dependência Total de Element Data para Estado de Sessão
- **Problema:** Estado crítico de autenticação e permissões armazenado em `setElementData()` (ex: `user:loggedin`, `char:id`, `admin:level`)
- **Impacto:** Element data é sincronizado para todos os clientes por padrão — vaza informação. Pode ser manipulado via exploits de sincronização.
- **Esforço de correção:** Alto — requer redesign da camada de sessão

### TD-ARCH-003 — Acoplamento Forte via Exports Globais
- **Problema:** Recursos chamam `exports.oVehicle:getFuelLevel()` diretamente sem abstração
- **Impacto:** Qualquer renomeação/refatoração de um recurso quebra todos os dependentes
- **Esforço de correção:** Médio — criar camada de serviço intermediária

### TD-ARCH-004 — Sistema [Old] Ativo no Gamemode
- **Localização:** `[Old]/` — 28 recursos, 112 arquivos Lua
- **Impacto:** Código morto consumindo recursos, risco de conflito de eventos/exports com sistemas ativos, confusão para manutenção
- **Esforço de correção:** Baixo — mover para fora da pasta do gamemode

### TD-ARCH-005 — Ausência de Error Handling Centralizado
- **Problema:** `pcall()` raramente usado; erros de dbQuery não verificados consistentemente
- **Impacto:** Erros silenciosos ou crashes que derrubam recursos inteiros
- **Esforço de correção:** Alto — refatoração sistêmica

---

## 3. Dívidas de Qualidade de Código (Severidade MÉDIA)

### TD-CODE-001 — Nomenclatura em Húngaro
- **Escopo:** Variáveis, funções e comments em toda a codebase
- **Exemplos:** `szefek` (tabela SQL = "chefes"), `kresz` (campo = "carteira de motorista"), `szin` (cor), `iin` (índice)
- **Impacto:** Dificuldade de manutenção por equipe brasileira
- **Esforço de correção:** Muito alto (toda a codebase) — priorizar apenas variáveis de interface e funções públicas

### TD-CODE-002 — Variáveis Globais Excessivas
- **Problema:** Muitos recursos poluem o escopo global sem `local`
- **Impacto:** Conflitos de namespace entre recursos, debugging difícil
- **Esforço de correção:** Alto — auditoria por recurso

### TD-CODE-003 — Magic Numbers Sem Constantes
- **Exemplos:** `local invitationBonus = 5000`, IDs de items hardcoded, skin IDs numéricos
- **Impacto:** Manutenção difícil — mudança requer busca em toda a codebase
- **Esforço de correção:** Médio — criar arquivo `shared/constants.lua` por recurso

### TD-CODE-004 — Ausência de Validação de Input do Cliente
- **Problema:** Dados recebidos de eventos cliente são usados diretamente sem validação de tipo/bounds
- **Exemplo:** `availableStartPositions[startPosition]` — índice enviado pelo cliente usado diretamente
- **Impacto:** Crashes por nil access, exploração de lógica
- **Esforço de correção:** Médio — adicionar validação antes de usar dados de cliente

### TD-CODE-005 — Arquivos XML Duplicados
- **Problema:** 229 arquivos `.xml-old` encontrados no repositório
- **Impacto:** Confusão sobre qual versão é a ativa, tamanho desnecessário do repositório
- **Esforço de correção:** Baixo — remover todos os `.xml-old`

### TD-CODE-006 — `hedit` Ativo como Recurso do Gamemode
- **Localização:** `hedit/` — 63 arquivos Lua (editor de world objects)
- **Impacto:** Ferramenta de desenvolvimento exposta potencialmente em produção; superfície de ataque enorme
- **Esforço de correção:** Baixo — desativar/remover do `mtaserver.conf` em produção

---

## 4. Dívidas de Performance (Severidade MÉDIA)

### TD-PERF-001 — Element Data Broadcast Sem `broadcast=false`
- **Problema:** `setElementData()` sem o terceiro argumento `false` sincroniza dados para todos os clientes
- **Impacto:** Tráfego de rede excessivo, especialmente com muitos jogadores
- **Esforço de correção:** Médio — auditar todos os `setElementData` e adicionar `false` onde não precisa ser público

### TD-PERF-002 — Queries N+1 em Carregamento de Personagens
- **Problema:** Carregamento de personagem provavelmente faz múltiplas queries sequenciais (account → character → items → vehicles → factions)
- **Impacto:** Alto tempo de login com banco ocupado
- **Esforço de correção:** Médio — consolidar queries de carregamento

### TD-PERF-003 — `items` Table Crescendo Sem Limite
- **Problema:** AUTO_INCREMENT em 533.337 — sem purge de itens descartados ou expirados
- **Impacto:** Queries na tabela ficam mais lentas com o tempo; backup do banco cresce indefinidamente
- **Esforço de correção:** Médio — implementar rotina de limpeza + soft delete

### TD-PERF-004 — Charset Inconsistente nas Tabelas
- **Problema:** Tabelas usam mistura de `latin1`, `utf8`, `utf8mb4` e `utf8_bin`
- **Impacto:** Conversões implícitas em JOINs, impossibilidade de armazenar alguns caracteres (emojis, acentos especiais)
- **Esforço de correção:** Alto — migração de charset de todas as tabelas para `utf8mb4`

---

## 5. Dívidas de Documentação (Severidade BAIXA)

### TD-DOC-001 — Ausência de Documentação Técnica
- **Problema:** Nenhuma documentação de arquitetura, APIs ou fluxos de dados
- **Impacto:** Onboarding lento de novos desenvolvedores; risco de regressão em manutenção
- **Esforço de correção:** Alto mas paralelo — criar docs incrementalmente por recurso

### TD-DOC-002 — Sem Comentários em Código Complexo
- **Problema:** Funções complexas sem qualquer comentário explicativo
- **Esforço de correção:** Médio — adicionar comentários somente onde o WHY é não-óbvio

---

## Quadro Resumo de Prioridades

| ID | Categoria | Severidade | Esforço | Bloqueante |
|---|---|---|---|---|
| TD-SEC-001 | Segurança | CRÍTICA | Baixo | SIM |
| TD-SEC-002 | Segurança | CRÍTICA | Médio | SIM |
| TD-SEC-003 | Segurança | CRÍTICA | Médio | SIM |
| TD-SEC-004 | Segurança | CRÍTICA | Médio | SIM |
| TD-SEC-005 | Segurança | CRÍTICA | Alto | SIM |
| TD-SEC-006 | Segurança | CRÍTICA | Alto | SIM |
| TD-ARCH-001 | Arquitetura | ALTA | Alto | NÃO (progressivo) |
| TD-ARCH-002 | Arquitetura | ALTA | Alto | NÃO |
| TD-ARCH-003 | Arquitetura | ALTA | Médio | NÃO |
| TD-ARCH-004 | Arquitetura | ALTA | Baixo | NÃO |
| TD-ARCH-005 | Arquitetura | ALTA | Alto | NÃO |
| TD-CODE-001 | Código | MÉDIA | Muito alto | NÃO |
| TD-CODE-002 | Código | MÉDIA | Alto | NÃO |
| TD-CODE-003 | Código | MÉDIA | Médio | NÃO |
| TD-CODE-004 | Código | MÉDIA | Médio | NÃO |
| TD-CODE-005 | Código | BAIXA | Baixo | NÃO |
| TD-CODE-006 | Código | MÉDIA | Baixo | SIM |
| TD-PERF-001 | Performance | MÉDIA | Médio | NÃO |
| TD-PERF-002 | Performance | MÉDIA | Médio | NÃO |
| TD-PERF-003 | Performance | MÉDIA | Médio | NÃO |
| TD-PERF-004 | Performance | MÉDIA | Alto | NÃO |
| TD-DOC-001 | Documentação | BAIXA | Alto | NÃO |
| TD-DOC-002 | Documentação | BAIXA | Médio | NÃO |

---

## Quick Wins (Baixo esforço, alto impacto)

Ações que podem ser feitas imediatamente sem risco de regressão:

1. **TD-SEC-001** — Remover tabela `saver[]` (10 min, zero risco)
2. **TD-CODE-006** — Desativar `hedit` no servidor de produção (5 min)
3. **TD-ARCH-004** — Mover `[Old]` para fora do gamemode (15 min)
4. **TD-CODE-005** — Deletar todos os `.xml-old` do repositório (5 min via git)
5. **TD-SEC-003** — Esvaziar tabela hardcoded de seriais e apontar para banco (30 min)
