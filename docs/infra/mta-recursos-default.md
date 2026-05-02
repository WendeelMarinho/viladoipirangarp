# Recursos *default* do MTA (`mtaserver.conf`) vs gamemode

**Atualizado:** 2026-05-02

O ficheiro `mods/deathmatch/mtaserver.conf` lista recursos **`startup="1"`** além do teu **`vila-do-ipiranga-rp`**. Não fazem parte do `oStarter` — arrancam **antes** do gamemode (ordem relativamente garantida porque entram primeiro na config).

---

## Resumo recomendado (produção RP)

| Recurso | Manter ao arranque? | Motivo típico |
|---------|---------------------|---------------|
| **resourcemanager** | Sim (protecção) | Necessário para gestão/controlos internos dos recursos. |
| **resourcebrowser** | Sim (usual) | Ligado ao resource manager / proteções. Parar apenas se tens pipeline alternativo seguro. |
| **admin** | Sim na maioria | Painel/console admin MTA ACL; mesmo com **`oAdmin`**, muitos operadores continuam com este recurso ligado para ACL / auth serial. |
| **webadmin** | Opcional | Só mantém se usas browser para administração ACL. Otherwise reduz superfície. |
| **mapmanager** | Geralmente manter | Muitos servidores e scripts antigos presumem recurso registado mesmo que o RP faça pouco uso de edição dinâmica de mapas. |
| **spawnmanager** | Geralmente manter | Histórico: utilitários de spawn vanilla; **`oAccount`** efectua **`spawnPlayer`**, mas outros recursos *default* pode assumir **`spawnmanager`**. Testar bem antes de desligar. |
| **defaultstats** | Manter até testar sem | Estatísticas iniciais de ped; remoção pode afectar expectativas mínimas. |
| **joinquit** | Opcional | Mensagens vanilla join/quit — pode repetir comportamento já coberto pelo gamemode; desligável se QA confirmar não haver regressão UX. |
| **helpmanager** | Opcional | Ajuda vanilla; servidor RP costuma ter tips próprios. |
| **mapcycler** | Raramente necessário servidor RP único gamemode | Rotaciona gamemodes/maps — seguramente dispensável quando só existe **`vila-do-ipiranga-rp`**. |
| **parachute** | Opcional gameplay | Mais cosmético; ver se queres física parachute multiplayer. |
| **performancebrowser** | Desligável produção normal | Métricas dev/debug; aumenta superfície de pedidos se exposto — mantém apenas em servidor de desenvolvimento. |
| **ipb** | Desligável produção típica | Browser de IPs dev; igual racional. |
| **reload** | Útil em dev/staging | Recarrega gamemodes; produção opcional sob ACL controlada. |
| **scoreboard** | Opcional duplicado | O gamemode inclui **`oScoreboard`** no `oStarter`. O scoreboard *default MTA* pode co-existir (teclas/UI diferentes) ou duplicar; testar antes de remover. |
| **voice** | Conforme desenho servidor | Liga chat de voz MTA vanilla; remover se servidor é só texto RP. |
| **votemanager** | Geralmente desligável em RP premium | Pouco usado quando não há votações abertas. |

**Conclusão prática:** o gamemode **não parece usar `exports.spawnmanager`/…** directamente nos primeiros scans, mas remover recursos MTA pode **mudar comportamento subtil** ou quebrar dependências não pesquisadas. Faz sempre **staging** antes de mexer à lista.

Para um corte mais agressivo, comenta linhas através do XML **`<!-- -->`** com data e motivo, não apagues texto sem backup.

---

## Relação com `oStarter`

- **`vila-do-ipiranga-rp`** faz `startResource(oStarter)`, que agora usa **`starter_manifest.lua`** (+ skins `oFKSkins_*` dinamicamente).
- A lista oficial Original Roleplay (sem duplicações/recursos fantasmas) está em **`[Core]/oStarter/starter_manifest.lua`** como **`ORP_ORIGINAL_RP_START_ORDER`**.
- Perfil **`original_rp`** = paridade com essa lista. **`streamlined`** remove um subconjunto de mapas paul/dude e extras listados na tabela **`ORP_STREAMLINED_EXCLUDE`** do manifest.
