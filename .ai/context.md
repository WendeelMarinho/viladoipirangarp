---
type: ai-context
updated: 2026-05-01
---

# Contexto do Projeto

## Identidade
- **Nome:** Ipiranga Roleplay
- **Tipo:** Servidor MTA:SA de roleplay premium brasileiro
- **Base:** OriginalRoleplay (equipe húngara, 2019–2023, MIT license)
- **Objetivo:** Lançamento como plataforma RP premium no Brasil

## Stack Técnico
- Linguagem: Lua (MTA:SA scripting)
- Banco de dados: MySQL (45 tabelas, schema em `orp_main.sql`)
- Assets: ~7.100 arquivos (PNG, DFF, TXD, COL, MP3, WAV, FX)
- MTA versão mínima: 1.5.9

## Números
- ~1.654 arquivos Lua
- 402 recursos MTA (cada um com meta.xml)
- 45 tabelas MySQL
- ~3.680 strings traduzíveis (húngaro → PT-BR)

## Estado da Base de Código
- **Funcionalidade:** 9/10 — base madura e completa
- **Segurança:** 4/10 — críticos corrigidos no oAccount, mais pendentes
- **Manutenibilidade:** 5/10 — modular mas padrões inconsistentes
- **Localização:** 0/10 — 100% em húngaro

## Fase Atual
Phase 1 — Security Hardening

## Branch Ativo
`security/oAdmin-serial-migration`
