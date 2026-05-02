# Estatísticas de `<export>` em `meta.xml` (gerado)

**Gerado:** 2026-05-02  
**Fonte:** `find vila-do-ipiranga-rp -name meta.xml` + parse XML.

| Métrica | Valor |
|---------|-------|
| Recursos com pelo menos uma tag `<export>` | **89** |
| Declarações `<export>` (soma única grep/regex nos `meta.xml`) | **~581** *(varia com corpus; regenerar)* |
| Recursos com `meta.xml` no pacote (~) | ~400 |

**Limitações:** Recursos Lua que apenas expõem funções auxiliares via `globals`/`load`, ou utilizam apenas eventos (`addEvent`/handlers) **sem** tag `<export>`, não aparecem aqui. Use `grep -R "exports\."` sobre `.lua` para dependências consumidas.

## Top exporters (por número de funções declaradas)

| Recurso | # exports |
|---------|-----------|
| dynamic_light | 46 |
| dynamic_lighting | 46 |
| oInventory | 42 |
| oInventoryNEW | 41 |
| oInventoryOLD | 41 |
| oCore | 37 |
| oDashboard | 25 |
| npc_hlc | 16 |
| oVehicle | 16 |
| oBoneOLD | 13 |
| … | *(ver comando de regeração)* |

## Regenerar

```bash
cd mods/deathmatch/resources/vila-do-ipiranga-rp
python3 docs/tooling/export_meta_summary.py   # quando existir; ou repetir comando no CLAUDE interno
```

*(O script tooling pode ser adicionado posteriormente para substituir o one-off em Python utilizado uma vez para este ficheiro.)*
