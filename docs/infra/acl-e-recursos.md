# ACL e Sistema de Recursos — Guia de Manutenção

**Atualizado:** 2026-05-02

---

## Regra de Ouro do acl.xml

> **O `acl.xml` SÓ pode ser editado com o servidor PARADO.**

### Por quê

O recurso padrão `[admin]/admin` tem este handler em `server/admin_server.lua`:

```lua
addEventHandler("onResourceStop", root, function(resource)
    -- ... salva sessões, desmuta jogadores ...
    aclSave()  -- escreve o estado em memória para o acl.xml
end)
```

`aclSave()` é chamado a **cada vez que qualquer recurso para**. Se editares o `acl.xml` com o servidor em execução, a memória interna do MTA sobrescreve o ficheiro na próxima vez que qualquer recurso parar (incluindo na sequência de shutdown).

### Procedimento correto

1. `pkill -f mta-server64` — parar completamente
2. Editar `mods/deathmatch/acl.xml`
3. Iniciar o servidor — o ficheiro é lido para memória no boot
4. As alterações persistem porque nenhum `aclSave` foi chamado antes de o ficheiro ser carregado

---

## Estado Atual do acl.xml (2026-05-02)

O grupo `Admin` foi expandido para incluir os recursos principais do gamemode:

```xml
<group name="Admin">
    <acl name="Moderator"></acl>
    <acl name="SuperModerator"></acl>
    <acl name="Admin"></acl>
    <acl name="RPC"></acl>
    <object name="resource.admin"></object>
    <object name="resource.webadmin"></object>
    <object name="resource.acpanel"></object>
    <object name="resource.vila-do-ipiranga-rp"></object>
    <object name="resource.oStarter"></object>
</group>
```

Isto dá a `oStarter` e ao recurso raiz `general.ModifyOtherObjects` e `function.startResource`, necessários para o bootstrap.

### Permissões ainda em falta

| Recurso | Permissão necessária | Efeito atual |
|---------|---------------------|--------------|
| `oAdmin` | `general.ModifyOtherObjects`, `function.aclSave`, `function.aclReload`, `function.aclGroupAddObject` | Sincronização de admins com ACL falha (avisos no log); whitelist serial funciona normalmente |
| `oCore` | `function.fetchRemote` | API de meteorologia não sincroniza |
| `oAnticheat` | `function.fetchRemote` | Listas negras de IPs/VPNs não carregam |

Para corrigir: parar servidor → adicionar estes recursos ao grupo Admin em `acl.xml` → iniciar.

---

## Estrutura de Recursos e Symlinks

Os recursos do gamemode vivem em `resources/vila-do-ipiranga-rp/` mas o MTA precisa de os ver diretamente em `resources/`. A solução é criar **symlinks individuais**.

### Por que symlinks de grupo causam problemas

Um symlink de grupo como `resources/[Carlos] → vila-do-ipiranga-rp/[Carlos]/` expõe **todos** os recursos dentro, incluindo os que conflituam com recursos padrão do MTA:

| Recurso conflituante | Conflito com |
|---------------------|-------------|
| `ajax` | `[gameplay]/ajax` |
| `ipb` | `[gameplay]/ipb` |
| `performancebrowser` | `[gameplay]/performancebrowser` |
| `helpmanager` (via `[cameratool]/helpmanager.zip`) | `[managers]/helpmanager` |
| `glue` (em `[Booms]/`) | `[gameplay]/glue` |

### Symlinks individuais criados (2026-05-02)

Removidos os symlinks de grupo:
- `resources/[Carlos]` (substituído por ~61 symlinks individuais)
- `resources/[cameratool]` (cameratool e helpmanager não estão em oStarter)
- `resources/[Booms]` (substituído por 4 symlinks, excluindo `glue`)

Para adicionar um novo recurso ao gamemode:
```bash
cd /root/multitheftauto_linux_x64/mods/deathmatch/resources
ln -s ../vila-do-ipiranga-rp/[pasta]/nomeRecurso nomeRecurso
```

---

## oStarter — Comportamentos Conhecidos

O ficheiro `[Core]/oStarter/server.lua` inicia todos os recursos em sequência.

### Manifest `oStarter` (2026-05)

A ordem de arranque vive principalmente em **`[Core]/oStarter/starter_manifest.lua`** como `ORP_ORIGINAL_RP_START_ORDER`. As duplicações **`oNewPD` / `oBillboards`** e entradas de recursos inexistentes foram retiradas do manifest (lista original ORP sanitizada para esta árvore). O **`restartResource` retardado** só volta a iniciar **`oInventory`**, **`oSpeedo`**, **`oBillboards`** quando estão RUNNING — sem tentar **`oPlant` / `oPlaneCrash`**.

### Ordem de arranque

`oInventory`, `oVehicle` e `oInteriors` iniciam **antes** de `oAdmin` na sequência. Nas primeiras execuções geram `exports: Call to non-running server resource (oAdmin)`. Após `oAdmin` iniciar (alguns segundos depois), tudo funciona normalmente.

---

## Sistema de Whitelist (oCore)

Ficheiro: `[Core]/oCore/server.lua`

```lua
local whitelistEnabled = true

addEventHandler("onPlayerConnect", getRootElement(), function(playerName, _, _, playerSerial)
    -- 1. Verifica blacklist (seriais banidos hardcoded)
    if blacklistSerials[playerSerial] then cancelEvent(true) end

    -- 2. Se whitelist ativa, verifica adminSerialsCache
    if not whitelistEnabled then return end
    local ok, isDev = pcall(function() return exports.oAdmin:isSerialDeveloper(playerSerial) end)
    if not (ok and isDev) then
        cancelEvent(true, "Em desenvolvimento...")
    end
end)
```

### Para desativar temporariamente

Comando in-game (requer estar ligado como developer): `/togwhitelist`

### Para adicionar serial à whitelist

```sql
INSERT INTO adminserials (serial, name) VALUES ('SERIAL_AQUI', 'NomeJogador');
```

Depois, reiniciar o recurso `oAdmin` para recarregar o cache, ou usar `/reloadadminserials` in-game.

**Serial do owner atual:** `CE96EC91A956F747BA88AC47DD304A02` (Wendeel) — já inserido.

---

## Login Automático de Developer

Quando um jogador com serial em `adminSerialsCache` entra no servidor, `developerJoin()` em `oAdmin/s_admin.lua` executa automaticamente:

1. Gera password aleatória de 30 caracteres
2. Cria (ou atualiza) conta MTA com o nome da tabela `adminserials`
3. Faz login automático
4. Define `elementData "aclLogin" = true`
5. Mostra mensagem no chat: "Serial de developer detetado! Bem-vindo, [nome]!"

**Não é necessário username/password manual.** A autenticação é exclusivamente por serial.
