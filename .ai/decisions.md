---
type: ai-decisions
updated: 2026-05-01
---

# Decisões Arquiteturais

## DEC-001 — Refatoração Incremental (Não Reescrita)
**Data:** 2026-05-01  
**Decisão:** Modernizar a base OriginalRoleplay incrementalmente, preservando todos os exports, eventos e compatibilidade de schema.  
**Motivo:** Base funcional madura; reescrita total introduziria regressões e perderia funcionalidade testada em produção.

## DEC-002 — `source` como Identidade Canônica em Event Handlers
**Data:** 2026-05-01  
**Decisão:** Todos os handlers de eventos cliente→servidor usam `source` como referência ao jogador. Argumentos `player` enviados pelo cliente são descartados.  
**Motivo:** Em MTA:SA, `source` é garantido pelo runtime como o jogador que enviou o pacote; qualquer argumento adicional pode ser spoofado.

## DEC-003 — `adminSerialsCache` como Modelo de Autorização de Developers
**Data:** 2026-05-01  
**Decisão:** Substituir a tabela `adminSerials` hardcoded por `adminSerialsCache` populado a partir da tabela `adminserials` do banco de dados. Suporte a reload em runtime via `/reloadadminserials`.  
**Motivo:** Seriais hardcoded no código-fonte criam risco de segurança; qualquer pessoa com acesso ao repositório conhece os seriais privilegiados.  
**Compatibilidade:** Todos os exports e funções (`isPlayerDeveloper`, `getPlayerAdminLevel`, `hasPermission`, etc.) preservados com assinatura idêntica.

## DEC-004 — Client-Side Developer Check via Element Data
**Data:** 2026-05-01  
**Decisão:** Scripts client-side (shared) usam `getElementData(player, "aclLogin")` para verificar se um jogador é developer, em vez de verificar seriais.  
**Motivo:** Clientes não têm acesso ao banco de dados; `aclLogin` é setado exclusivamente pelo servidor em `developerJoin()`.
