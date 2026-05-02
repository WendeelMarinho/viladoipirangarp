# Security audit ledger — consolidated view

**Atualização:** 2026-05-02  
**Fontes primárias:** [technical-debt-report.md](technical-debt-report.md) · [security/security-log.md](security/security-log.md)

---

## 1. Metodologia

| Nível | O que cobre esta versão doc |
|-------|------------------------------|
| Arquitectónico | Superfícies confiança, ACL, modelo BD |
| Código já mitigado (2026-05) | Itens marcados ✅ no log |
| Pendências | Requer passe manual contínuo (grep audits) |

Este ficheiro **substitui** ruído de re-enumerar tudo sempre — actualizar apenas quando há findings novos OU fechamentos.

---

## 2. Superfícies críticas (checklist evergreen)

### 2.1 Event integrity

| Vetor | Pergunta auditor |
|-------|-------------------|
| `triggerServerEvent` | Handler valida `source` como jogador e limita permissões económicas? |
| spoof args | Algum código usa `arguments[1]` como player em vez do `source`? |
| `addEvent(, true)` | Eventos marcados bubble client → confirmar apenas handlers server-side seguram trust |

### 2.2 Data layer

| Vetor | Pergunta |
|-------|-----------|
| Concat SQL | Ainda há `.. userInput ..` em consultas dinâmicas? |
| ORM próprio ausente | Toda nova query deve ser param (`?`). |

### 2.3 AuthZ

| Vetor | Pergunta |
|-------|-----------|
| Admin actions | Paths verificam `getPlayerAdminLevel` / ACL real além da UI cliente? |
| developer serial cache | Estado coerência após migrações base `adminserials` |

### 2.4 Files / deserialization

| Vetor | Pergunta |
|-------|-----------|
| Uploads texto | Parsing ingênuo pode DoS servidor pequenas VPS |
| Logs sensíveis | Evitar registrar tokens em `outputConsole` público |

---

## 3. Findings já mitigadas (snapshot)

Registrar aqui apenas **titulo** — detalhes no log datado:

| Tema | Status |
|------|--------|
| Cache plaintext credenciais + eventos sabotáveis `/listITme` (`saver`) | **Removido** (security-log oAccount wave) |
| Login brute-force livre | **Rate limit serial** aplicado |
| Kick arbitrário cliente (`kickFlooder`) | Evento eliminado |
| Seriais admins hardcoded oAdmin/oCore migrados | ✅ DB / cache (**verificar branch actual vs repo público antes de declarar LIVE**) |

*(Se houver discrepância entre branch local e público ao reler este doc anos depois → re-validar arquivo fonte Git.)*

---

## 4. Riscos **ainda típicos** em forks OriginalRP

| ID legado TD | Estado conceptual |
|--------------|-------------------|
| TD-SEC-006 hashing senhas forte | Migrar bcrypt/argon2 + coluna versioning |
| TD-SEC-005 SQL parametrização completa sweep | Pendente automatizado grep |
| TD-ARCH-002 element data sensitiva | Auditoria granular flag sync |

Exploit scenario genérico (documentação conscientização):

> Jogador com cliente manipulado envia payloads até encontrar handlers sem throttle ou validação suficiente; economia falsificável se o servidor usar dados não autoritários (ex.: confiar apenas em eco client-side ou argumentos spoofáveis).

Mitigação: **validação server authoritative** sempre que alteração `char:money`/items persistidos.

---

## 5. Próximo ciclo automatizado recomendado

```bash
# SQL concat risk heuristic
rg "db(Query|Exec|Poll)\([^)]*\.\.|dbQuery\(.*\.." --glob '*.lua'

# Potential missing source guard heuristic (manual double-check!)
rg 'addEvent\([^)]*true\)' --glob '*.lua' | wc -l
```

Resultados tratados como *triage*, não prova matemática.

---

## Related

- Incident response playbook: [deployment-guide.md](deployment-guide.md) § Incidentes
- Performance stress surfaces: [performance-analysis.md](performance-analysis.md)
