# Cursor Context — Admin Hub v2 (Redesign Completo)

## Ler antes de implementar

1. `oAdmin/meta.xml` — entender a estrutura de arquivos atual
2. `oAdmin/hub/c_adminHub.lua` — código client atual (740 linhas) a ser substituído
3. `oAdmin/hub/s_adminHub.lua` — código server atual (464 linhas) a ser substituído
4. `oAdmin/g_admin.lua` — funções globais: `isPlayerInAdminDuty`, `getPlayerAdminLevel`
5. `oAdmin/g_commands.lua` — tabela `adminCMD` e `hasPermission(player, perm, silent)`
6. `.cursor/context/novos-sistemas.md` — padrões do servidor (exports, eventos, DB)
7. `.cursor/rules/fase4-features.md` — regras obrigatórias de código

---

## Objetivo

Substituir completamente os arquivos `hub/c_adminHub.lua` e `hub/s_adminHub.lua` por uma
arquitetura modular dividida em `hub/v2/`. O painel atual é monolítico (740 linhas num só
arquivo), sem estado centralizado, sem confirmações, sem feedback de loading, sem histórico.

O v2 deve ser:
- **Contextual** — mostra apenas o necessário na aba ativa
- **Rápido** — debounce no alvo, auto-load snapshot, presets de valor
- **Seguro** — modal de confirmação para ações críticas, preview do que será feito

---

## Estrutura de arquivos a criar

```
oAdmin/hub/v2/
├── shared_state.lua     (shared)  — HubState + constantes + utilitários de estado
├── c_layout.lua         (client)  — cálculo de layout cacheado
├── c_theme.lua          (client)  — sistema de tema + primitivas DX reutilizáveis
├── c_toast.lua          (client)  — fila de notificações toast (canto superior direito)
├── c_modal.lua          (client)  — overlay de confirmação modal
├── c_history.lua        (client)  — painel lateral de histórico (recolhível)
├── c_catalog.lua        (client)  — catálogo de itens com cache de filtro + favoritos
├── c_sidebar.lua        (client)  — sidebar fixa do perfil do jogador + ações rápidas
├── c_tabs.lua           (client)  — barra de abas inferior + hint bar
├── c_views.lua          (client)  — renderização de cada view (uma por aba)
├── c_main.lua           (client)  — orquestrador: open/close, render loop, inputs
└── s_hub.lua            (server)  — todos os eventos server-side (mantém + novos)
```

---

## Alterações em `oAdmin/meta.xml`

**Remover** as duas linhas antigas:
```xml
<script src="hub/c_adminHub.lua" type="client" cache="false"></script>
<script src="hub/s_adminHub.lua" type="server" cache="false"></script>
```

**Adicionar** em seu lugar (ordem obrigatória — cada arquivo depende do anterior):
```xml
<script src="hub/v2/shared_state.lua" type="shared"  cache="false"></script>
<script src="hub/v2/c_layout.lua"     type="client"  cache="false"></script>
<script src="hub/v2/c_theme.lua"      type="client"  cache="false"></script>
<script src="hub/v2/c_toast.lua"      type="client"  cache="false"></script>
<script src="hub/v2/c_modal.lua"      type="client"  cache="false"></script>
<script src="hub/v2/c_history.lua"    type="client"  cache="false"></script>
<script src="hub/v2/c_catalog.lua"    type="client"  cache="false"></script>
<script src="hub/v2/c_sidebar.lua"    type="client"  cache="false"></script>
<script src="hub/v2/c_tabs.lua"       type="client"  cache="false"></script>
<script src="hub/v2/c_views.lua"      type="client"  cache="false"></script>
<script src="hub/v2/c_main.lua"       type="client"  cache="false"></script>
<script src="hub/v2/s_hub.lua"        type="server"  cache="false"></script>
```

---

## 1. `shared_state.lua` (shared)

Estado global centralizado. Todos os outros arquivos leem e escrevem nesta tabela.

```lua
HubState = {
    -- Painel
    open        = false,
    animTick    = 0,       -- getTickCount() na abertura (fade-in de 600ms)
    theme       = "dark",  -- "dark" | "light"; persiste em element data local

    -- Navegação
    activeTab   = 1,       -- 1..7

    -- Alvo
    autoLoadTimer = nil,   -- handle do timer de debounce (setTimer)

    -- Snapshot (perfil carregado)
    snapshot        = nil,   -- tabela com dados do jogador ou nil
    snapshotLoading = false, -- true enquanto aguarda resposta do servidor

    -- Catálogo de itens
    catalog         = nil,   -- lista [{id, nome}] ou nil antes de carregar
    catalogLoading  = false,
    catalogFilter   = "",    -- valor atual do campo de busca
    catalogDirty    = false, -- true quando filter mudou e filtered precisa recalcular
    catalogFiltered = nil,   -- cache do resultado filtrado
    catalogPage     = 1,
    catalogFavorites = {},   -- {[itemId] = true}
    catalogRecents   = {},   -- lista de itens recentes: {{id, nome}, ...} máx 8

    -- Histórico de ações
    historyOpen = false,
    history     = {},  -- {{time, label, ok}, ...} máx 30 entradas

    -- Modal de confirmação
    modal = nil,
    -- nil OU {title="", body="", onConfirm=function, dangerLevel=1}
    -- dangerLevel: 1=normal (botão azul), 2=destrutivo (botão vermelho)

    -- Estado da aba Economia
    econType = 1,  -- 1=Dinheiro 2=Casino Coin 3=Pontos Premium 4=Banco
    econMode = 1,  -- 1=Adicionar 2=Remover 3=Definir

    -- Estado da aba Moderação
    modAction = 1,  -- 1=AJail 2=Unjail 3=Kick 4=Warn 5=Mute 6=Ban

    -- Cache de layout (invalidado quando sx/sy mudam)
    _layoutCache = nil,
    _layoutSx    = 0,
    _layoutSy    = 0,

    -- Ação em execução (bloqueia cliques duplos)
    actionPending = false,
}

-- Constantes de aba
HUB_TABS = {
    { id=1, name="Jogador",   icon="👤", perm="showinv"   },
    { id=2, name="Economia",  icon="💰", perm="givemoney"  },
    { id=3, name="Premium",   icon="⭐", perm="givepp"     },
    { id=4, name="Itens",     icon="📦", perm="giveitem"   },
    { id=5, name="Banco",     icon="🏦", perm="givemoney"  },
    { id=6, name="Veículos",  icon="🚗", perm="makeveh"    },
    { id=7, name="Moderação", icon="⚖️", perm="ajail"      },
}

-- Nomes dos recursos económicos
HUB_ECON_TYPES  = { "Dinheiro", "Casino Coin", "Pontos Premium", "Banco" }
HUB_ECON_MODES  = { "Adicionar", "Remover", "Definir" }
HUB_MOD_ACTIONS = { "AJail", "Unjail", "Kick", "Warn", "Mute", "Ban" }

-- Presets rápidos de valor (Aba Economia)
HUB_PRESETS = { 1000, 5000, 10000, 50000, 100000 }

-- Ações que requerem modal de confirmação
HUB_CRITICAL_ACTIONS = {
    setMoney=true, setCC=true, setPP=true, bankSet=true,
    kick=true, ban=true, ajail=true,
}

-- Função auxiliar: adicionar entrada ao histórico
function HubAddHistory(label, ok)
    local t = getRealTime()
    local ts = string.format("%02d:%02d", t.hour, t.minute)
    table.insert(HubState.history, 1, { time=ts, label=label, ok=ok })
    if #HubState.history > 30 then
        table.remove(HubState.history)
    end
end

-- Invalidar cache de layout quando a resolução mudar
function HubInvalidateLayout()
    HubState._layoutCache = nil
end
```

---

## 2. `c_layout.lua` (client)

Calcula o layout UMA vez por mudança de resolução. **Não recalcular a cada frame.**

```lua
local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992  -- resolução de design v2

local function px(n) return n / myX * sx end
local function py(n) return n / myY * sy end

-- Dimensões do painel
local PANEL_W = 1280
local PANEL_H = 860

function HubGetLayout()
    -- Revalidar cache apenas se resolução mudou
    local csx, csy = guiGetScreenSize()
    if HubState._layoutCache and HubState._layoutSx == csx and HubState._layoutSy == csy then
        return HubState._layoutCache
    end
    sx, sy = csx, csy

    local aw = px(PANEL_W)
    local ah = py(PANEL_H)
    local ax = (sx - aw) / 2   -- centralizado horizontalmente
    local ay = (sy - ah) / 2   -- centralizado verticalmente

    local headerH  = py(56)
    local tabBarH  = py(52)
    local footerH  = py(32)
    local sidebarW = py(250)   -- sidebar quadrada, proporcional em y
    local mainX    = ax + sidebarW + px(1)  -- 1px divisor
    local mainW    = aw - sidebarW - px(1)
    local bodyY    = ay + headerH
    local bodyH    = ah - headerH - tabBarH - footerH
    local tabBarY  = ay + ah - tabBarH - footerH
    local footerY  = ay + ah - footerH

    local L = {
        ax=ax, ay=ay, aw=aw, ah=ah,
        headerH=headerH, tabBarH=tabBarH, footerH=footerH,
        bodyY=bodyY, bodyH=bodyH,
        tabBarY=tabBarY, footerY=footerY,
        -- Sidebar
        sidebarX=ax, sidebarY=bodyY, sidebarW=sidebarW, sidebarH=bodyH,
        -- Main content
        mainX=mainX, mainY=bodyY, mainW=mainW, mainH=bodyH,
        -- Botões do header
        closeBtnX   = ax + aw - px(42),  closeBtnY = ay + py(11),
        historyBtnX = ax + aw - px(88),  historyBtnY = ay + py(11),
        themeBtnX   = ax + aw - px(154), themeBtnY = ay + py(11),
        -- Painel de histórico (slide in da direita)
        histPanelX = ax + aw,  -- posição fechada; animar para ax+aw-px(280) quando aberto
        histPanelW = px(280), histPanelH = bodyH,
        -- Helpers
        px=px, py=py,
    }

    HubState._layoutCache = L
    HubState._layoutSx = csx
    HubState._layoutSy = csy
    return L
end
```

---

## 3. `c_theme.lua` (client)

Sistema de tema + primitivas DX. Funções puras — não guardam estado.

```lua
-- Paletas (mesmas do v1, mantidas para consistência)
local PALETTES = {
    dark = {
        overlay  = {0,2,6},
        panelBg  = {8,12,22},
        card     = {18,22,36},
        cardElev = {26,30,48},
        grid     = 12,
        text     = {248,250,255},
        muted    = {138,150,172},
        line     = {48,55,72},
        positive = {52,168,96},
        danger   = {210,72,72},
        warn     = {214,168,64},
        purple   = {130,90,220},
        sidebar  = {12,16,28},
    },
    light = {
        overlay  = {240,242,248},
        panelBg  = {252,253,255},
        card     = {246,248,252},
        cardElev = {255,255,255},
        grid     = 8,
        text     = {22,28,42},
        muted    = {78,88,108},
        line     = {200,208,220},
        positive = {32,132,68},
        danger   = {190,48,48},
        warn     = {180,120,32},
        purple   = {100,60,190},
        sidebar  = {236,240,248},
    },
}

function HubPal()
    return PALETTES[HubState.theme] or PALETTES.dark
end

-- tocolor wrapper
function HubT(c, a)
    return tocolor(c[1], c[2], c[3], math.min(255, math.floor(a)))
end

-- Cor de destaque do servidor
function HubAccent(a255)
    local c, r2, g2, b2 = exports.oCore:getServerColor()
    return tocolor(r2, g2, b2, math.min(255, math.floor(a255)))
end

-- Card com borda
function HubDrawCard(x, y, w, h, p, alpha, mul)
    mul = mul or 1
    local fill = math.min(255, math.floor(246*alpha*mul))
    local edge = math.min(255, math.floor(120*alpha*mul))
    dxDrawRectangle(x, y, w, h, HubT(p.cardElev, fill))
    dxDrawRectangle(x, y,     w, 1, HubT(p.line, edge))
    dxDrawRectangle(x, y+h-1, w, 1, HubT(p.line, math.floor(edge*0.6)))
    dxDrawRectangle(x, y,     1, h, HubT(p.line, math.floor(edge*0.75)))
    dxDrawRectangle(x+w-1, y, 1, h, HubT(p.line, math.floor(edge*0.75)))
end

-- Badge de status (texto com fundo colorido arredondado via DX)
-- type: "online"|"offline"|"ajail"|"duty"|"vehicle"
local BADGE_COLORS = {
    online  = {52,200,96},
    offline = {100,100,120},
    ajail   = {210,72,72},
    duty    = {58,118,210},
    vehicle = {214,168,64},
}
function HubDrawBadge(x, y, w, h, badgeType, alpha, font)
    local col = BADGE_COLORS[badgeType] or BADGE_COLORS.offline
    dxDrawRectangle(x, y, w, h, tocolor(col[1],col[2],col[3], math.floor(200*alpha)))
    dxDrawText(string.upper(badgeType), x, y, x+w, y+h,
        tocolor(255,255,255,math.floor(240*alpha)), 1, font, "center","center")
end

-- Botão com hover detectado via oCore:isInSlot
function HubDrawBtn(x, y, w, h, label, r2, g2, b2, alpha, font, isDestructive)
    local hover = exports.oCore:isInSlot(x, y, w, h)
    local a = hover and math.min(255, math.floor(alpha*1.15)) or math.floor(alpha)
    if isDestructive then
        dxDrawRectangle(x, y, w, h, tocolor(180,40,40, a))
    else
        dxDrawRectangle(x, y, w, h, tocolor(r2, g2, b2, a))
    end
    dxDrawRectangle(x, y, w, 2, tocolor(255,255,255, math.floor(30*alpha)))
    exports.oCore:dxDrawButton(x, y, w, h, r2, g2, b2, a, label,
        tocolor(255,255,255,255), 0.85, font, false, tocolor(0,0,0,80))
end

-- Toggle chip (botão selecionável)
function HubDrawChip(x, y, w, h, label, selected, alpha, font)
    local p = HubPal()
    local bg = selected and HubAccent(math.floor(180*alpha)) or HubT(p.cardElev, math.floor(200*alpha))
    dxDrawRectangle(x, y, w, h, bg)
    dxDrawRectangle(x, y, w, 1, HubT(p.line, math.floor(140*alpha)))
    local col = selected and tocolor(255,255,255,255) or HubT(p.muted, math.floor(220*alpha))
    dxDrawText(label, x, y, x+w, y+h, col, 1, font, "center","center")
end

-- Fundo tech com grade e pulso na barra superior
function HubDrawBackground(ax, ay, aw, ah, alpha)
    local p = HubPal()
    dxDrawRectangle(ax, ay, aw, ah, HubT(p.panelBg, math.floor(246*alpha)))
    local g = math.floor(p.grid * alpha)
    for gx = 0, aw, 48 do
        dxDrawLine(ax+gx, ay, ax+gx, ay+ah, tocolor(255,255,255,g), 1)
    end
    for gy = 0, ah, 48 do
        dxDrawLine(ax, ay+gy, ax+aw, ay+gy, tocolor(255,255,255,g), 1)
    end
    local pulse = (math.sin(getTickCount()/520)+1)*0.5
    local cr, cg, cb = exports.oCore:getServerColorRGB()
    dxDrawRectangle(ax, ay, aw, 4, tocolor(cr,cg,cb, math.floor((50+80*pulse)*alpha)))
    dxDrawRectangle(ax, ay+4, aw, 1, HubT(p.line, math.floor(180*alpha)))
end
```

---

## 4. `c_toast.lua` (client)

Fila de notificações no canto superior direito. Até 4 visíveis simultaneamente.
Duração: 3000ms. Fade-in: 200ms. Fade-out: 400ms.

```lua
local TOAST_DURATION = 3000
local TOAST_FADEIN   = 200
local TOAST_FADEOUT  = 400

-- Adicionar toast (chamado por c_main.lua após receber actionResult)
function HubToast(msg, toastType)
    -- toastType: "success" | "error" | "warning" | "info"
    table.insert(HubState.toasts, {
        msg      = msg,
        type     = toastType or "info",
        startTick = getTickCount(),
    })
    if #HubState.toasts > 5 then table.remove(HubState.toasts, 1) end
end

-- Renderizar todos os toasts ativos (chamado dentro do render loop)
function HubRenderToasts(alpha)
    local L = HubGetLayout()
    local now = getTickCount()
    local p = HubPal()
    local font = exports.oFont:getFont("condensed", math.max(10, math.floor(11/992*select(2,guiGetScreenSize()))))

    local TOAST_W = L.px(280)
    local TOAST_H = L.py(38)
    local TOAST_GAP = L.py(6)
    local startX = L.ax + L.aw - TOAST_W - L.px(16)
    local startY = L.ay + L.py(16)

    local surviving = {}
    local posY = startY
    for _, t in ipairs(HubState.toasts) do
        local elapsed = now - t.startTick
        local total = TOAST_DURATION
        if elapsed >= total + TOAST_FADEOUT then
            -- expirou, não adicionar a surviving
        else
            table.insert(surviving, t)
            -- calcular alpha do toast
            local tAlpha
            if elapsed < TOAST_FADEIN then
                tAlpha = elapsed / TOAST_FADEIN
            elseif elapsed > total then
                tAlpha = 1 - (elapsed - total) / TOAST_FADEOUT
            else
                tAlpha = 1
            end
            tAlpha = math.max(0, math.min(1, tAlpha)) * alpha

            local colors = {
                success = {52,168,96},
                error   = {210,72,72},
                warning = {214,168,64},
                info    = {58,118,210},
            }
            local col = colors[t.type] or colors.info

            dxDrawRectangle(startX, posY, TOAST_W, TOAST_H,
                HubT(p.card, math.floor(240*tAlpha)))
            dxDrawRectangle(startX, posY, 4, TOAST_H,
                tocolor(col[1],col[2],col[3], math.floor(255*tAlpha)))
            dxDrawRectangle(startX, posY, TOAST_W, 1,
                HubT(p.line, math.floor(180*tAlpha)))
            dxDrawText(t.msg, startX+L.px(12), posY, startX+TOAST_W-L.px(8), posY+TOAST_H,
                tocolor(255,255,255,math.floor(240*tAlpha)), 1, font, "left","center",
                false, false, false, true)

            posY = posY + TOAST_H + TOAST_GAP
        end
    end
    HubState.toasts = surviving
end
```

---

## 5. `c_modal.lua` (client)

Overlay semi-transparente + card de confirmação centralizado.
Bloqueia cliques no painel principal enquanto ativo.

```lua
-- Abrir modal
-- onConfirm: function() chamada ao confirmar
-- dangerLevel: 1=normal(azul), 2=destrutivo(vermelho)
function HubOpenModal(title, body, onConfirm, dangerLevel)
    HubState.modal = {
        title       = title,
        body        = body,
        onConfirm   = onConfirm,
        dangerLevel = dangerLevel or 1,
    }
end

function HubCloseModal()
    HubState.modal = nil
end

function HubRenderModal(alpha)
    if not HubState.modal then return end
    local m = HubState.modal
    local L = HubGetLayout()
    local p = HubPal()

    local font = exports.oFont:getFont("condensed", math.max(11,math.floor(13/992*select(2,guiGetScreenSize()))))
    local fontT = exports.oFont:getFont("bebasneue", math.max(16,math.floor(20/992*select(2,guiGetScreenSize()))))

    -- Overlay escuro sobre o painel inteiro
    dxDrawRectangle(L.ax, L.ay, L.aw, L.ah, tocolor(0,0,0,math.floor(160*alpha)))

    -- Card central
    local cw = L.px(460)
    local ch = L.py(200)
    local cx = L.ax + (L.aw - cw)/2
    local cy = L.ay + (L.ah - ch)/2
    HubDrawCard(cx, cy, cw, ch, p, alpha, 1.0)

    -- Título
    dxDrawText(m.title, cx+L.px(20), cy+L.py(16), cx+cw-L.px(20), cy+L.py(50),
        HubT(p.text, 255*alpha), 1, fontT, "left","center")

    -- Body
    dxDrawText(m.body, cx+L.px(20), cy+L.py(52), cx+cw-L.px(20), cy+L.py(130),
        HubT(p.muted, 240*alpha), 1, font, "left","top", false, true)

    -- Botão Cancelar
    local btnW = L.px(140)
    local btnH = L.py(38)
    local btnY = cy + ch - L.py(54)
    local cancelX = cx + L.px(20)
    HubDrawBtn(cancelX, btnY, btnW, btnH, "Cancelar", 60,65,80, math.floor(230*alpha), font, false)

    -- Botão Confirmar
    local confirmX = cx + cw - L.px(20) - btnW
    if m.dangerLevel == 2 then
        HubDrawBtn(confirmX, btnY, btnW, btnH, "Confirmar", 180,40,40, math.floor(255*alpha), font, true)
    else
        HubDrawBtn(confirmX, btnY, btnW, btnH, "Confirmar", 52,168,96, math.floor(255*alpha), font, false)
    end
end

-- Processar cliques no modal (retorna true se consumiu o clique)
function HubModalClick(cx, cy)
    if not HubState.modal then return false end
    local m = HubState.modal
    local L = HubGetLayout()

    local cw = L.px(460)
    local ch = L.py(200)
    local panelCx = L.ax + (L.aw - cw)/2
    local panelCy = L.ay + (L.ah - ch)/2

    local btnW = L.px(140)
    local btnH = L.py(38)
    local btnY = panelCy + ch - L.py(54)

    local cancelX = panelCx + L.px(20)
    if exports.oCore:isInSlot(cancelX, btnY, btnW, btnH) then
        HubCloseModal()
        return true
    end

    local confirmX = panelCx + cw - L.px(20) - btnW
    if exports.oCore:isInSlot(confirmX, btnY, btnW, btnH) then
        if m.onConfirm then m.onConfirm() end
        HubCloseModal()
        return true
    end

    return true  -- consumir qualquer outro clique dentro do overlay
end
```

---

## 6. `c_history.lua` (client)

Painel lateral de histórico recolhível. Desliza da borda direita do painel.
`HubState.historyOpen` controla se está aberto.

```lua
function HubRenderHistory(alpha)
    if not HubState.historyOpen and #HubState.history == 0 then return end
    local L = HubGetLayout()
    local p = HubPal()
    local font = exports.oFont:getFont("condensed", math.max(9,math.floor(10/992*select(2,guiGetScreenSize()))))
    local fontS = exports.oFont:getFont("bebasneue", math.max(13,math.floor(15/992*select(2,guiGetScreenSize()))))

    -- Animação de slide: calcular X baseado em historyOpen
    local targetX = HubState.historyOpen and (L.ax + L.aw - L.histPanelW) or (L.ax + L.aw)
    -- Em produção: usar easing suave com tick. Aqui, direto para simplicidade.
    local hx = targetX
    local hy = L.bodyY
    local hw = L.histPanelW
    local hh = L.bodyH

    HubDrawCard(hx, hy, hw, hh, p, alpha, 0.9)
    dxDrawText("Histórico", hx+L.px(12), hy+L.py(8), hx+hw-L.px(12), hy+L.py(30),
        HubT(p.text, 250*alpha), 1, fontS, "left","center")

    local rowH = L.py(28)
    local startY = hy + L.py(36)
    for i, entry in ipairs(HubState.history) do
        if startY + rowH > hy + hh - L.py(10) then break end
        local col = entry.ok and HubT(p.positive, 220*alpha) or HubT(p.danger, 220*alpha)
        local icon = entry.ok and "✓" or "✕"
        dxDrawText(entry.time, hx+L.px(8), startY, hx+L.px(46), startY+rowH,
            HubT(p.muted, 200*alpha), 1, font, "left","center")
        dxDrawText(icon, hx+L.px(48), startY, hx+L.px(66), startY+rowH,
            col, 1, font, "center","center")
        dxDrawText(entry.label, hx+L.px(70), startY, hx+hw-L.px(8), startY+rowH,
            HubT(p.text, 235*alpha), 1, font, "left","center",
            false, false, false, true)
        startY = startY + rowH
    end
end
```

---

## 7. `c_catalog.lua` (client)

Catálogo de itens com cache de filtro, favoritos e recentes.

```lua
-- Recalcular lista filtrada apenas quando necessário
function HubGetFilteredCatalog()
    local filter = string.lower(
        exports.oCore:getEditboxText("hub2_itemsearch") or ""
    )
    if filter ~= HubState.catalogFilter or HubState.catalogDirty then
        HubState.catalogFilter = filter
        HubState.catalogDirty  = false
        if not HubState.catalog or #HubState.catalog == 0 then
            HubState.catalogFiltered = {}
        elseif filter == "" then
            HubState.catalogFiltered = HubState.catalog  -- sem cópia, referência direta
        else
            local out = {}
            for _, row in ipairs(HubState.catalog) do
                local line = string.lower(tostring(row[1]) .. " " .. tostring(row[2]))
                if string.find(line, filter, 1, true) then
                    out[#out+1] = row
                end
            end
            HubState.catalogFiltered = out
        end
        HubState.catalogPage = 1
    end
    return HubState.catalogFiltered or {}
end

-- Adicionar aos recentes
function HubCatalogSelectItem(itemId, itemName)
    exports.oCore:setEditboxText("hub2_itemid", tostring(itemId))
    -- remover duplicata se já existir
    for i, r in ipairs(HubState.catalogRecents) do
        if r[1] == itemId then table.remove(HubState.catalogRecents, i); break end
    end
    table.insert(HubState.catalogRecents, 1, {itemId, itemName})
    if #HubState.catalogRecents > 8 then table.remove(HubState.catalogRecents) end
end

-- Renderizar o catálogo (chamado por c_views.lua na aba Itens)
-- x, y, w, h: área disponível
function HubRenderCatalog(x, y, w, h, alpha)
    local L = HubGetLayout()
    local p = HubPal()
    local font = exports.oFont:getFont("condensed", math.max(9,math.floor(10/992*select(2,guiGetScreenSize()))))

    HubDrawCard(x, y, w, h, p, alpha, 0.6)

    if HubState.catalogLoading then
        -- Skeleton loading: linhas cinzas pulsantes
        local pulse = (math.sin(getTickCount()/400)+1)*0.5
        local sk = HubT(p.line, math.floor((80+60*pulse)*alpha))
        for i=0, 6 do
            dxDrawRectangle(x+L.px(8), y+L.py(8)+i*L.py(22), w-L.px(16), L.py(16), sk)
        end
        return
    end

    local filtered = HubGetFilteredCatalog()
    local rowH = L.py(22)
    local headerH = L.py(28)
    local footerH = L.py(44)
    local rows = math.max(1, math.floor((h - headerH - footerH) / rowH))
    local totalPages = math.max(1, math.ceil(#filtered / rows))
    if HubState.catalogPage > totalPages then HubState.catalogPage = totalPages end

    -- Header
    dxDrawText("Catálogo · " .. #filtered .. " itens",
        x+L.px(8), y+L.py(4), x+w-L.px(8), y+headerH,
        HubT(p.text, 245*alpha), 1, font, "left","center")
    dxDrawText("clique para selecionar",
        x+L.px(8), y+L.py(4), x+w-L.px(8), y+headerH,
        HubT(p.muted, 200*alpha), 1, font, "right","center")

    -- Linhas
    local startIdx = (HubState.catalogPage-1)*rows+1
    local yy = y + headerH
    for i=1, rows do
        local idx = startIdx+i-1
        local row = filtered[idx]
        if row then
            local isFav = HubState.catalogFavorites[row[1]] == true
            local curId = tonumber(exports.oCore:getEditboxText("hub2_itemid") or "")
            local isSel = curId == row[1]
            local hov   = exports.oCore:isInSlot(x+2, yy, w-4, rowH)
            if isSel then
                dxDrawRectangle(x+2, yy, w-4, rowH, HubAccent(math.floor(50*alpha)))
            elseif hov then
                dxDrawRectangle(x+2, yy, w-4, rowH, HubT(p.card, math.floor(200*alpha)))
            end
            dxDrawText("#"..row[1], x+L.px(8), yy, x+L.px(50), yy+rowH,
                HubT(p.muted, 240*alpha), 1, font, "left","center")
            dxDrawText(row[2], x+L.px(54), yy, x+w-L.px(isFav and 22 or 8), yy+rowH,
                HubT(p.text, 240*alpha), 1, font, "left","center", false, false, false, true)
            if isFav then
                dxDrawText("★", x+w-L.px(20), yy, x+w-L.px(2), yy+rowH,
                    tocolor(214,168,64,math.floor(240*alpha)), 1, font, "right","center")
            end
        end
        yy = yy + rowH
    end

    -- Paginação
    local fy = y + h - footerH
    exports.oCore:dxDrawButton(x+L.px(6), fy+L.py(8), L.px(80), L.py(28),
        48,56,74, math.floor(220*alpha), "◀", HubT(p.text,255*alpha), 0.9, font, false, tocolor(0,0,0,80))
    exports.oCore:dxDrawButton(x+w-L.px(86), fy+L.py(8), L.px(80), L.py(28),
        48,56,74, math.floor(220*alpha), "▶", HubT(p.text,255*alpha), 0.9, font, false, tocolor(0,0,0,80))
    dxDrawText(HubState.catalogPage.." / "..totalPages,
        x+L.px(92), fy+L.py(8), x+w-L.px(92), fy+L.py(36),
        HubT(p.muted,230*alpha), 1, font, "center","center")
end

-- Processar clique na área do catálogo (retorna true se consumiu)
function HubCatalogClick(ax, ay, w, h, clickX, clickY)
    local L = HubGetLayout()
    local headerH = L.py(28)
    local footerH = L.py(44)
    local rowH = L.py(22)
    local rows = math.max(1, math.floor((h - headerH - footerH) / rowH))
    local listY = ay + headerH
    local listBottom = ay + h - footerH
    local fy = ay + h - footerH

    -- Paginação
    if exports.oCore:isInSlot(ax+L.px(6), fy+L.py(8), L.px(80), L.py(28)) then
        HubState.catalogPage = math.max(1, HubState.catalogPage-1)
        return true
    end
    if exports.oCore:isInSlot(ax+w-L.px(86), fy+L.py(8), L.px(80), L.py(28)) then
        local filtered = HubGetFilteredCatalog()
        local rows2 = math.max(1, math.floor((h - headerH - footerH) / rowH))
        local totalP = math.max(1, math.ceil(#filtered / rows2))
        HubState.catalogPage = math.min(totalP, HubState.catalogPage+1)
        return true
    end

    -- Clique em linha
    if clickY >= listY and clickY <= listBottom then
        local relY = clickY - listY
        local row = math.floor(relY / rowH) + 1
        local filtered = HubGetFilteredCatalog()
        local startIdx = (HubState.catalogPage-1)*rows+1
        local item = filtered[startIdx+row-1]
        if item then
            -- Clique duplo no mesmo item → toggle favorito
            local lastSel = tonumber(exports.oCore:getEditboxText("hub2_itemid") or "")
            if lastSel == item[1] then
                HubState.catalogFavorites[item[1]] = not HubState.catalogFavorites[item[1]] or nil
            end
            HubCatalogSelectItem(item[1], item[2])
            return true
        end
    end
    return false
end

-- Scroll com roda do mouse
function HubCatalogScroll(direction)
    local L = HubGetLayout()
    local filtered = HubGetFilteredCatalog()
    local mainH = HubGetLayout().mainH
    local rowH = L.py(22)
    local rows = math.max(1, math.floor((mainH * 0.5 - L.py(72)) / rowH))
    local totalP = math.max(1, math.ceil(#filtered / rows))
    if direction == "up" then
        HubState.catalogPage = math.max(1, HubState.catalogPage-1)
    else
        HubState.catalogPage = math.min(totalP, HubState.catalogPage+1)
    end
end
```

---

## 8. `c_sidebar.lua` (client)

Sidebar fixa com perfil do alvo. Sempre visível, atualiza automaticamente após cada ação.

```lua
-- Status derivado do snapshot
local function getSnapshotStatus()
    local s = HubState.snapshot
    if not s then return {} end
    local badges = {}
    if s.online  then badges[#badges+1] = "online"  end
    if s.ajailed then badges[#badges+1] = "ajail"   end
    if s.onDuty  then badges[#badges+1] = "duty"    end
    if s.inVeh   then badges[#badges+1] = "vehicle" end
    return badges
end

function HubRenderSidebar(alpha)
    local L = HubGetLayout()
    local p = HubPal()
    local sx2, sy2 = guiGetScreenSize()
    local font  = exports.oFont:getFont("condensed", math.max(11,math.floor(13/992*sy2)))
    local fontS = exports.oFont:getFont("condensed", math.max(9,math.floor(10/992*sy2)))
    local fontT = exports.oFont:getFont("bebasneue", math.max(14,math.floor(16/992*sy2)))

    local lx = L.sidebarX
    local ly = L.sidebarY
    local lw = L.sidebarW
    local lh = L.sidebarH

    -- Fundo sidebar (cor levemente diferente do painel)
    dxDrawRectangle(lx, ly, lw, lh, HubT(p.sidebar, math.floor(255*alpha)))
    dxDrawRectangle(lx+lw-1, ly, 1, lh, HubT(p.line, math.floor(200*alpha)))

    -- Campo de busca do alvo (topo da sidebar)
    local searchY = ly + L.py(12)
    -- editbox hub2_target posicionado aqui via positionEditboxes()

    dxDrawText("Alvo:", lx+L.px(10), searchY, lx+lw-L.px(10), searchY+L.py(18),
        HubT(p.muted, 220*alpha), 1, fontS, "left","center")

    local profileY = ly + L.py(62)

    if HubState.snapshotLoading then
        -- Skeleton loading
        local pulse = (math.sin(getTickCount()/400)+1)*0.5
        local sk = HubT(p.line, math.floor((70+50*pulse)*alpha))
        dxDrawRectangle(lx+L.px(10), profileY, lw-L.px(20), L.py(14), sk)
        dxDrawRectangle(lx+L.px(10), profileY+L.py(20), lw*0.6, L.py(10), sk)
        for i=0, 4 do
            dxDrawRectangle(lx+L.px(10), profileY+L.py(44)+i*L.py(20), lw-L.px(20), L.py(12), sk)
        end
        return
    end

    if not HubState.snapshot then
        dxDrawText("Preencha o alvo e aguarde\no carregamento automático.",
            lx+L.px(12), profileY, lx+lw-L.px(12), profileY+L.py(60),
            HubT(p.muted, 200*alpha), 1, fontS, "left","top", false, true)
        return
    end

    local s = HubState.snapshot

    -- Badges de status
    local badges = getSnapshotStatus()
    local badgeX = lx + L.px(10)
    local badgeH = L.py(18)
    local badgeW = L.px(52)
    for _, badge in ipairs(badges) do
        HubDrawBadge(badgeX, profileY, badgeW, badgeH, badge, alpha, fontS)
        badgeX = badgeX + badgeW + L.px(4)
    end
    profileY = profileY + L.py(24)

    -- Nome
    dxDrawText(s.name or "—",
        lx+L.px(10), profileY, lx+lw-L.px(10), profileY+L.py(24),
        HubT(p.text, 255*alpha), 1, fontT, "left","center", false, false, false, true)
    profileY = profileY + L.py(26)

    -- IDs
    dxDrawText("Char #"..(s.charId or "?").." · User #"..(s.userId or "?"),
        lx+L.px(10), profileY, lx+lw-L.px(10), profileY+L.py(16),
        HubT(p.muted, 220*alpha), 1, fontS, "left","center")
    profileY = profileY + L.py(22)

    -- Divisor
    dxDrawRectangle(lx+L.px(10), profileY, lw-L.px(20), 1, HubT(p.line, math.floor(160*alpha)))
    profileY = profileY + L.py(8)

    -- Stats financeiros
    local stats = {
        {"💰 Mão",  "$"..(s.money or 0),  p.positive},
        {"🏦 Banco", s.bankSerial and ("$"..(s.bankMoney or 0)) or "Sem conta", p.positive},
        {"⭐ PP",   (s.pp or 0).." PP",   p.purple or p.muted},
        {"🎰 CC",   (s.cc or 0).." CC",   p.warn},
    }
    for _, stat in ipairs(stats) do
        dxDrawText(stat[1], lx+L.px(10), profileY, lx+lw*0.52, profileY+L.py(18),
            HubT(p.muted, 220*alpha), 1, fontS, "left","center")
        dxDrawText(stat[2], lx+lw*0.52, profileY, lx+lw-L.px(10), profileY+L.py(18),
            HubT(stat[3], 255*alpha), 1, fontS, "right","center", false, false, false, true)
        profileY = profileY + L.py(20)
    end

    -- Facção
    if s.faction and s.faction ~= "" then
        profileY = profileY + L.py(4)
        dxDrawRectangle(lx+L.px(10), profileY, lw-L.px(20), 1, HubT(p.line, math.floor(120*alpha)))
        profileY = profileY + L.py(8)
        dxDrawText(s.faction or "—",
            lx+L.px(10), profileY, lx+lw-L.px(10), profileY+L.py(16),
            HubT(p.muted, 220*alpha), 1, fontS, "left","center", false, false, false, true)
        profileY = profileY + L.py(18)
        if s.factionRank and s.factionRank ~= "" then
            dxDrawText(s.factionRank,
                lx+L.px(10), profileY, lx+lw-L.px(10), profileY+L.py(14),
                HubT(p.text, 200*alpha), 1, fontS, "left","center", false, false, false, true)
            profileY = profileY + L.py(16)
        end
    end

    -- Ações rápidas
    profileY = profileY + L.py(10)
    dxDrawRectangle(lx+L.px(10), profileY, lw-L.px(20), 1, HubT(p.line, math.floor(140*alpha)))
    profileY = profileY + L.py(8)
    dxDrawText("Ações rápidas", lx+L.px(10), profileY, lx+lw-L.px(10), profileY+L.py(16),
        HubT(p.muted, 210*alpha), 1, fontS, "left","center")
    profileY = profileY + L.py(20)

    local quickActions = {
        {"Teleportar até", "goto"},
        {"Puxar", "bring"},
        {"Curar (100%)", "heal"},
        {"Congelar", "freeze"},
        {"Ver inventário", "inventory"},
    }
    for _, qa in ipairs(quickActions) do
        HubDrawBtn(lx+L.px(10), profileY, lw-L.px(20), L.py(26), qa[1],
            48,56,80, math.floor(210*alpha), fontS, false)
        profileY = profileY + L.py(30)
    end
end

-- Processar clique nas ações rápidas da sidebar
function HubSidebarClick(clickX, clickY)
    if not HubState.snapshot then return false end
    local L = HubGetLayout()
    -- calcular profileY como na renderização para encontrar os botões
    -- (simplificado — na prática, calcular as posições dos botões de ações rápidas)
    -- retornar true e disparar evento se clique em botão de ação rápida
    return false
end
```

---

## 9. `c_tabs.lua` (client)

Barra de abas na **parte inferior** do painel (diferente do v1 que ficava no topo).

```lua
function HubRenderTabs(alpha)
    local L = HubGetLayout()
    local p = HubPal()
    local font = exports.oFont:getFont("condensed", math.max(10,math.floor(11/992*select(2,guiGetScreenSize()))))
    local tabCount = #HUB_TABS
    local tabW = (L.aw - L.px(4)) / tabCount
    local tabH = L.tabBarH
    local ty   = L.tabBarY

    for i, tab in ipairs(HUB_TABS) do
        local tx = L.ax + L.px(2) + (i-1)*tabW
        local on    = HubState.activeTab == i
        local hover = not on and exports.oCore:isInSlot(tx, ty, tabW-L.px(2), tabH)
        if on then
            dxDrawRectangle(tx, ty, tabW-L.px(2), tabH, HubAccent(math.floor(72*alpha)))
            dxDrawRectangle(tx, ty, tabW-L.px(2), 3, HubAccent(math.floor(255*alpha)))
            dxDrawText(tab.icon.." "..tab.name, tx, ty, tx+tabW-L.px(2), ty+tabH,
                HubT(p.text, 255*alpha), 1, font, "center","center")
        else
            dxDrawRectangle(tx, ty, tabW-L.px(2), tabH,
                HubT(p.cardElev, math.floor((hover and 200 or 160)*alpha)))
            dxDrawRectangle(tx, ty, tabW-L.px(2), 1, HubT(p.line, math.floor(120*alpha)))
            dxDrawText(tab.icon.." "..tab.name, tx, ty, tx+tabW-L.px(2), ty+tabH,
                HubT(p.muted, (hover and 255 or 210)*alpha), 1, font, "center","center")
        end
        -- Número do atalho
        dxDrawText(tostring(i), tx+tabW-L.px(16), ty+L.py(4),
            tx+tabW-L.px(4), ty+L.py(16),
            HubT(p.muted, math.floor(120*alpha)), 1, font, "right","top")
    end
end

function HubTabsClick(clickX, clickY)
    local L = HubGetLayout()
    local tabCount = #HUB_TABS
    local tabW = (L.aw - L.px(4)) / tabCount
    for i=1, tabCount do
        local tx = L.ax + L.px(2) + (i-1)*tabW
        if exports.oCore:isInSlot(tx, L.tabBarY, tabW-L.px(2), L.tabBarH) then
            HubState.activeTab = i
            HubDestroyViewEditboxes()
            HubCreateViewEditboxes(i)
            return true
        end
    end
    return false
end
```

---

## 10. `c_views.lua` (client)

Uma função de render e uma de click por aba. Campos dinâmicos: criados ao entrar na aba,
destruídos ao sair. **Não há editboxes de abas diferentes ativas ao mesmo tempo.**

### Editboxes por aba

| Aba | Editboxes criados |
|-----|-------------------|
| 1 Jogador | (nenhum — apenas botão) |
| 2 Economia | `hub2_econ_value` |
| 3 Premium | `hub2_pp_value` |
| 4 Itens | `hub2_itemid`, `hub2_itemval`, `hub2_itemcount`, `hub2_itemduty`, `hub2_itemsearch` |
| 5 Banco | `hub2_bank_value` |
| 6 Veículos | `hub2_veh_model`, `hub2_veh_faction`, `hub2_veh_plate`, `hub2_veh_color` |
| 7 Moderação | `hub2_mod_time`, `hub2_mod_reason` |

`hub2_target` é criado uma única vez na abertura do painel (sidebar) e destruído no fechamento.

### Aba 2 — Economia (view unificada)

```lua
function HubRenderViewEconomy(alpha)
    local L  = HubGetLayout()
    local p  = HubPal()
    local sx2, sy2 = guiGetScreenSize()
    local font  = exports.oFont:getFont("condensed", math.max(11,math.floor(13/992*sy2)))
    local fontT = exports.oFont:getFont("bebasneue", math.max(16,math.floor(18/992*sy2)))

    local cx = L.mainX + L.px(20)
    local cy = L.mainY + L.py(20)
    local cw = L.mainW - L.px(40)

    -- Título
    dxDrawText("Economia", cx, cy, cx+cw, cy+L.py(28),
        HubT(p.text,255*alpha), 1, fontT, "left","center")
    cy = cy + L.py(36)

    -- Toggle de recurso (Dinheiro / CC / PP / Banco)
    dxDrawText("Recurso:", cx, cy, cx+cw, cy+L.py(18),
        HubT(p.muted, 220*alpha), 1, font, "left","center")
    cy = cy + L.py(22)
    local chipW = (cw - L.px(6)*3) / 4
    for i, name in ipairs(HUB_ECON_TYPES) do
        local bx = cx + (i-1)*(chipW+L.px(6))
        HubDrawChip(bx, cy, chipW, L.py(32), name, HubState.econType==i, alpha, font)
    end
    cy = cy + L.py(40)

    -- Toggle de operação (Adicionar / Remover / Definir)
    dxDrawText("Operação:", cx, cy, cx+cw, cy+L.py(18),
        HubT(p.muted,220*alpha), 1, font, "left","center")
    cy = cy + L.py(22)
    local modeW = (cw - L.px(6)*2) / 3
    local modeColors = {
        {52,168,96},   -- Adicionar (verde)
        {210,72,72},   -- Remover (vermelho)
        {58,118,210},  -- Definir (azul)
    }
    for i, name in ipairs(HUB_ECON_MODES) do
        local bx = cx + (i-1)*(modeW+L.px(6))
        local col = modeColors[i]
        local sel = HubState.econMode == i
        if sel then
            dxDrawRectangle(bx, cy, modeW, L.py(32), tocolor(col[1],col[2],col[3],math.floor(180*alpha)))
        else
            dxDrawRectangle(bx, cy, modeW, L.py(32), HubT(p.cardElev, math.floor(200*alpha)))
        end
        dxDrawRectangle(bx, cy, modeW, 1, HubT(p.line, math.floor(120*alpha)))
        dxDrawText(name, bx, cy, bx+modeW, cy+L.py(32),
            sel and tocolor(255,255,255,255) or HubT(p.muted,230*alpha),
            1, font, "center","center")
    end
    cy = cy + L.py(40)

    -- Valor (editbox hub2_econ_value posicionado aqui)
    dxDrawText("Valor:", cx, cy, cx+cw, cy+L.py(18),
        HubT(p.muted,220*alpha), 1, font, "left","center")
    cy = cy + L.py(22)
    -- editbox hub2_econ_value renderizado pelo oCore (posição definida em createViewEditboxes)
    cy = cy + L.py(38)

    -- Presets rápidos
    dxDrawText("Presets rápidos:", cx, cy, cx+cw, cy+L.py(16),
        HubT(p.muted,200*alpha), 1, font, "left","center")
    cy = cy + L.py(20)
    local presetW = (cw - L.px(4)*4) / 5
    for i, preset in ipairs(HUB_PRESETS) do
        local bx = cx + (i-1)*(presetW+L.px(4))
        local label = preset >= 1000 and (preset/1000 .."k") or tostring(preset)
        if HubState.econMode == 2 then label = "-"..label end
        HubDrawBtn(bx, cy, presetW, L.py(28), label, 48,56,74, math.floor(220*alpha), font, false)
    end
    cy = cy + L.py(42)

    -- Preview da operação
    local targetName = HubState.snapshot and HubState.snapshot.name or "?"
    local valStr = exports.oCore:getEditboxText("hub2_econ_value") or "0"
    local modeName = HUB_ECON_MODES[HubState.econMode] or "?"
    local typeName = HUB_ECON_TYPES[HubState.econType] or "?"
    local previewText = modeName .. " " .. valStr .. " de " .. typeName .. " → " .. targetName
    HubDrawCard(cx, cy, cw, L.py(38), p, alpha, 0.5)
    dxDrawText("Preview: " .. previewText,
        cx+L.px(12), cy, cx+cw-L.px(12), cy+L.py(38),
        HubT(p.text, 230*alpha), 1, font, "left","center", false, false, false, true)
    cy = cy + L.py(48)

    -- Botão executar (ocupa toda a largura)
    local critical = HubState.econMode == 3  -- Definir é crítico
    local btnColor = {52,168,96}
    if HubState.econMode == 2 then btnColor = {210,72,72}
    elseif HubState.econMode == 3 then btnColor = {58,118,210} end
    HubDrawBtn(cx, cy, cw, L.py(44), "EXECUTAR AÇÃO",
        btnColor[1],btnColor[2],btnColor[3], math.floor(255*alpha), font, critical)
end
```

### Aba 7 — Moderação (expandida)

```lua
function HubRenderViewModeration(alpha)
    local L  = HubGetLayout()
    local p  = HubPal()
    local sx2, sy2 = guiGetScreenSize()
    local font  = exports.oFont:getFont("condensed", math.max(11,math.floor(13/992*sy2)))
    local fontT = exports.oFont:getFont("bebasneue", math.max(16,math.floor(18/992*sy2)))

    local cx = L.mainX + L.px(20)
    local cy = L.mainY + L.py(20)
    local cw = L.mainW - L.px(40)

    dxDrawText("Moderação", cx, cy, cx+cw, cy+L.py(28),
        HubT(p.text,255*alpha), 1, fontT, "left","center")
    cy = cy + L.py(36)

    -- Seletor de ação
    dxDrawText("Ação:", cx, cy, cx+cw, cy+L.py(18),
        HubT(p.muted,220*alpha), 1, font, "left","center")
    cy = cy + L.py(22)

    local modColors = {
        {214,168,64},  -- AJail (amarelo)
        {52,168,96},   -- Unjail (verde)
        {58,118,210},  -- Kick (azul)
        {180,120,200}, -- Warn (roxo claro)
        {160,80,180},  -- Mute (roxo)
        {210,72,72},   -- Ban (vermelho)
    }
    local modW = (cw - L.px(4)*5) / 6
    for i, name in ipairs(HUB_MOD_ACTIONS) do
        local bx = cx + (i-1)*(modW+L.px(4))
        local col = modColors[i]
        local sel = HubState.modAction == i
        if sel then
            dxDrawRectangle(bx, cy, modW, L.py(32), tocolor(col[1],col[2],col[3],math.floor(180*alpha)))
        else
            dxDrawRectangle(bx, cy, modW, L.py(32), HubT(p.cardElev, math.floor(200*alpha)))
        end
        dxDrawText(name, bx, cy, bx+modW, cy+L.py(32),
            sel and tocolor(255,255,255,255) or HubT(p.muted,220*alpha),
            1, font, "center","center")
    end
    cy = cy + L.py(40)

    -- Campos contextuais (apenas os relevantes para a ação selecionada)
    local showTime   = (HubState.modAction == 1 or HubState.modAction == 5 or HubState.modAction == 6)
    local showReason = (HubState.modAction ~= 2)  -- Unjail não precisa de motivo

    if showTime then
        local label = HubState.modAction == 1 and "Minutos:"
                   or HubState.modAction == 5 and "Minutos:"
                   or "Horas (0 = permanente):"
        dxDrawText(label, cx, cy, cx+cw, cy+L.py(18),
            HubT(p.muted,220*alpha), 1, font, "left","center")
        cy = cy + L.py(22)
        -- editbox hub2_mod_time posicionado aqui
        cy = cy + L.py(38)
    end
    if showReason then
        dxDrawText("Motivo:", cx, cy, cx+cw, cy+L.py(18),
            HubT(p.muted,220*alpha), 1, font, "left","center")
        cy = cy + L.py(22)
        -- editbox hub2_mod_reason posicionado aqui
        cy = cy + L.py(38)
    end
    cy = cy + L.py(10)

    -- Botão executar
    local col = modColors[HubState.modAction]
    local isDanger = (HubState.modAction == 6) -- Ban é vermelho
    HubDrawBtn(cx, cy, cw, L.py(44), "EXECUTAR AÇÃO",
        col[1],col[2],col[3], math.floor(255*alpha), font, isDanger)
end
```

---

## 11. `c_main.lua` (client)

Orquestrador principal. Importa tudo, registra handlers globais, gerencia ciclo de vida.

```lua
local sx, sy = guiGetScreenSize()

local function refreshFonts()
    -- reinicializar se oCore/oFont reiniciarem
end

local function positionSidebarEditbox()
    local L = HubGetLayout()
    exports.oCore:createEditbox(
        L.sidebarX + L.px(10),
        L.sidebarY + L.py(30),
        L.sidebarW - L.px(20),
        L.py(30),
        "hub2_target", "ID ou nome do jogador", "text", true, {20,24,38,255}, 0.30, 32
    )
end

local function destroyAllEditboxes()
    local allBoxes = {
        "hub2_target",
        "hub2_econ_value", "hub2_pp_value",
        "hub2_itemid", "hub2_itemval", "hub2_itemcount", "hub2_itemduty", "hub2_itemsearch",
        "hub2_bank_value",
        "hub2_veh_model", "hub2_veh_faction", "hub2_veh_plate", "hub2_veh_color",
        "hub2_mod_time", "hub2_mod_reason",
    }
    for _, name in ipairs(allBoxes) do
        pcall(function() exports.oCore:deleteEditbox(name) end)
    end
end

function HubDestroyViewEditboxes()
    -- destruir apenas os da aba anterior (exceto hub2_target que é permanente)
    local tabBoxes = {
        [2] = {"hub2_econ_value"},
        [3] = {"hub2_pp_value"},
        [4] = {"hub2_itemid","hub2_itemval","hub2_itemcount","hub2_itemduty","hub2_itemsearch"},
        [5] = {"hub2_bank_value"},
        [6] = {"hub2_veh_model","hub2_veh_faction","hub2_veh_plate","hub2_veh_color"},
        [7] = {"hub2_mod_time","hub2_mod_reason"},
    }
    for _, list in pairs(tabBoxes) do
        for _, name in ipairs(list) do
            pcall(function() exports.oCore:deleteEditbox(name) end)
        end
    end
end

function HubCreateViewEditboxes(tabIdx)
    local L = HubGetLayout()
    local cx = L.mainX + L.px(20)
    -- cada aba define o Y exato onde posicionar seus campos
    -- (calcular com base no layout da view correspondente)
    -- Aba 2: hub2_econ_value
    -- Aba 4: hub2_itemsearch no topo, depois os 4 campos de item
    -- etc.
end

local function openHub()
    if HubState.open then return end
    if (getElementData(localPlayer,"user:admin") or 0) < 2
       and not getElementData(localPlayer,"aclLogin") then
        exports.oInfobox:outputInfoBox("Nível admin insuficiente.", "error")
        return
    end
    if not isPlayerInAdminDuty(localPlayer) then
        exports.oInfobox:outputInfoBox("Entre em serviço admin (/aduty) antes.", "error")
        return
    end

    local saved = getElementData(localPlayer, "adminHub:theme")
    if saved == "light" or saved == "dark" then HubState.theme = saved end

    HubState.open = true
    HubState.animTick = getTickCount()
    HubInvalidateLayout()
    showCursor(true)
    addEventHandler("onClientRender", root, HubRenderLoop)
    positionSidebarEditbox()
    HubCreateViewEditboxes(HubState.activeTab)
    -- Pedir catálogo se ainda não foi carregado
    if not HubState.catalog then
        HubState.catalogLoading = true
        triggerServerEvent("adminHub2 > getCatalog", resourceRoot)
    end
end

local function closeHub()
    if not HubState.open then return end
    HubState.open = false
    HubState.modal = nil
    showCursor(false)
    removeEventHandler("onClientRender", root, HubRenderLoop)
    destroyAllEditboxes()
    HubState.snapshot = nil
    HubState.snapshotLoading = false
end

function HubRenderLoop()
    if not HubState.open then return end
    local t = (getTickCount() - HubState.animTick) / 600
    local alpha = math.min(1, t)
    local L = HubGetLayout()
    local p = HubPal()

    -- Dim de fundo
    dxDrawRectangle(0, 0, guiGetScreenSize(), 0, tocolor(0,0,0,math.floor(165*alpha)))
    -- Mas guiGetScreenSize retorna dois valores, então:
    local w2, h2 = guiGetScreenSize()
    dxDrawRectangle(0, 0, w2, h2, tocolor(0,0,0,math.floor(165*alpha)))

    -- Fundo do painel
    HubDrawBackground(L.ax, L.ay, L.aw, L.ah, alpha)
    -- Borda
    HubDrawCard(L.ax+1, L.ay+1, L.aw-2, L.ah-2, p, alpha, 0.9)

    -- Header
    local fontT = exports.oFont:getFont("bebasneue", math.max(18,math.floor(22/992*h2)))
    local fontB = exports.oFont:getFont("condensed", math.max(11,math.floor(13/992*h2)))
    dxDrawText("Admin Hub v2", L.ax+L.px(20), L.ay+L.py(12),
        L.ax+L.aw, L.ay+L.headerH, HubT(p.text,255*alpha), 1, fontT, "left","center")

    -- Botões do header
    HubDrawBtn(L.closeBtnX, L.closeBtnY, L.px(34), L.py(32), "✕", 60,65,80, math.floor(215*alpha), fontB, false)
    HubDrawBtn(L.historyBtnX, L.historyBtnY, L.px(34), L.py(32), "⏱", 60,65,80, math.floor(215*alpha), fontB, false)
    HubDrawBtn(L.themeBtnX, L.themeBtnY, L.px(58), L.py(32), "🌙/☀", 60,65,80, math.floor(215*alpha), fontB, false)

    -- Sidebar
    HubRenderSidebar(alpha)

    -- Divisor sidebar/conteúdo
    dxDrawRectangle(L.mainX-1, L.bodyY, 1, L.bodyH, HubT(p.line, math.floor(200*alpha)))

    -- View da aba ativa
    if     HubState.activeTab == 1 then HubRenderViewPlayer(alpha)
    elseif HubState.activeTab == 2 then HubRenderViewEconomy(alpha)
    elseif HubState.activeTab == 3 then HubRenderViewPremium(alpha)
    elseif HubState.activeTab == 4 then HubRenderViewItems(alpha)
    elseif HubState.activeTab == 5 then HubRenderViewBank(alpha)
    elseif HubState.activeTab == 6 then HubRenderViewVehicles(alpha)
    elseif HubState.activeTab == 7 then HubRenderViewModeration(alpha)
    end

    -- Barra de abas inferior
    HubRenderTabs(alpha)

    -- Footer (atalhos)
    local fText = "Ctrl+1~7: abas  ·  Ctrl+R: recarregar  ·  Ctrl+F: pesquisar  ·  ESC: fechar"
    dxDrawText(fText, L.ax+L.px(12), L.footerY, L.ax+L.aw-L.px(12), L.ay+L.ah,
        HubT(p.muted, math.floor(170*alpha)), 1,
        exports.oFont:getFont("condensed",math.max(9,math.floor(10/992*h2))),
        "center","center")

    -- Histórico (slide-in)
    HubRenderHistory(alpha)

    -- Modal (acima de tudo)
    HubRenderModal(alpha)

    -- Toasts (acima do modal)
    HubRenderToasts(alpha)
end

-- Handler de clique
addEventHandler("onClientClick", root, function(button, state, cx, cy)
    if not HubState.open or button ~= "left" or state ~= "down" then return end
    local L = HubGetLayout()

    -- Modal tem prioridade
    if HubState.modal then
        HubModalClick(cx, cy)
        return
    end

    -- Botões do header
    if exports.oCore:isInSlot(L.closeBtnX, L.closeBtnY, L.px(34), L.py(32)) then
        closeHub(); return
    end
    if exports.oCore:isInSlot(L.historyBtnX, L.historyBtnY, L.px(34), L.py(32)) then
        HubState.historyOpen = not HubState.historyOpen; return
    end
    if exports.oCore:isInSlot(L.themeBtnX, L.themeBtnY, L.px(58), L.py(32)) then
        HubState.theme = (HubState.theme=="dark") and "light" or "dark"
        setElementData(localPlayer,"adminHub:theme",HubState.theme,false); return
    end

    -- Abas
    if HubTabsClick(cx, cy) then return end

    -- Ações rápidas da sidebar
    if HubSidebarClick(cx, cy) then return end

    -- Views
    HubViewClick(HubState.activeTab, cx, cy)
end)

-- Handler de teclado
addEventHandler("onClientKey", root, function(key, down)
    if not HubState.open or not down then return end
    if key == "escape" then
        cancelEvent()
        if HubState.modal then HubCloseModal()
        else closeHub() end
        return
    end
    local ctrl = getKeyState("lctrl") or getKeyState("rctrl")
    if ctrl then
        if key == "r" then cancelEvent()
            -- Recarregar snapshot
            local target = exports.oCore:getEditboxText("hub2_target") or ""
            if target ~= "" then
                HubState.snapshotLoading = true
                triggerServerEvent("adminHub2 > snapshot", resourceRoot, target)
            end
            return
        end
        if key == "f" then cancelEvent()
            -- Focar pesquisa (aba itens)
            if HubState.activeTab ~= 4 then HubState.activeTab = 4 end
            -- oCore:focusEditbox("hub2_itemsearch")
            return
        end
        if key == "tab" then
            cancelEvent()
            local dir = (getKeyState("lshift") or getKeyState("rshift")) and -1 or 1
            HubState.activeTab = ((HubState.activeTab - 1 + dir) % #HUB_TABS) + 1
            HubDestroyViewEditboxes()
            HubCreateViewEditboxes(HubState.activeTab)
            return
        end
        local n = tonumber(key)
        if n and n >= 1 and n <= #HUB_TABS then
            cancelEvent()
            HubState.activeTab = n
            HubDestroyViewEditboxes()
            HubCreateViewEditboxes(n)
            return
        end
    end
    -- Roda do mouse no catálogo
    if HubState.activeTab == 4 then
        if key == "mouse_wheel_up"   then HubCatalogScroll("up")   return end
        if key == "mouse_wheel_down" then HubCatalogScroll("down") return end
    end
end)

-- Debounce do alvo: ao parar de digitar por 800ms, auto-load snapshot
local function onTargetChange()
    if HubState.autoLoadTimer then
        killTimer(HubState.autoLoadTimer)
        HubState.autoLoadTimer = nil
    end
    local val = exports.oCore:getEditboxText("hub2_target") or ""
    if val == "" then HubState.snapshot = nil; return end
    HubState.autoLoadTimer = setTimer(function()
        HubState.autoLoadTimer = nil
        local cur = exports.oCore:getEditboxText("hub2_target") or ""
        if cur == "" then return end
        HubState.snapshotLoading = true
        triggerServerEvent("adminHub2 > snapshot", resourceRoot, cur)
    end, 800, 1)
end

-- Monitorar mudança no campo do alvo a cada 300ms quando painel aberto
local function watchTargetField()
    if not HubState.open then return end
    local cur = exports.oCore:getEditboxText("hub2_target") or ""
    if cur ~= (HubState._lastTargetVal or "") then
        HubState._lastTargetVal = cur
        onTargetChange()
    end
end
setTimer(watchTargetField, 300, 0)

-- Receber resultado do snapshot
addEvent("adminHub2 > snapshotResult", true)
addEventHandler("adminHub2 > snapshotResult", resourceRoot, function(ok, data)
    HubState.snapshotLoading = false
    if ok then
        HubState.snapshot = data
    else
        HubState.snapshot = nil
        HubToast(tostring(data or "Erro ao carregar dados."), "error")
    end
end)

-- Receber resultado de ação
addEvent("adminHub2 > actionResult", true)
addEventHandler("adminHub2 > actionResult", resourceRoot, function(ok, msg, updatedSnapshot)
    HubState.actionPending = false
    if ok then
        HubToast(msg or "OK", "success")
        HubAddHistory(msg or "Ação", true)
        -- Atualizar snapshot parcialmente se o servidor enviou dados novos
        if updatedSnapshot and HubState.snapshot then
            for k, v in pairs(updatedSnapshot) do
                HubState.snapshot[k] = v
            end
        end
    else
        HubToast(msg or "Erro", "error")
        HubAddHistory(msg or "Erro", false)
    end
end)

-- Receber catálogo
addEvent("adminHub2 > catalogResult", true)
addEventHandler("adminHub2 > catalogResult", resourceRoot, function(list)
    HubState.catalogLoading = false
    HubState.catalog = (type(list) == "table") and list or {}
    HubState.catalogDirty = true
end)

addCommandHandler("adminhub",    function() if HubState.open then closeHub() else openHub() end end)
addCommandHandler("painelstaff", function() if HubState.open then closeHub() else openHub() end end)

addEventHandler("onClientResourceStop", resourceRoot, closeHub)
addEventHandler("onClientResourceStart", resourceRoot, refreshFonts)
addEventHandler("onClientResourceStart", root, function(res)
    if res == getResourceFromName("oCore") or res == getResourceFromName("oAdmin") then
        refreshFonts()
    end
end)
```

---

## 12. `s_hub.lua` (server)

**Manter todos os handlers do `s_adminHub.lua` existente** (nomes de eventos com prefixo `adminHub >`
continuam funcionando para compatibilidade). Adicionar novos handlers com prefixo `adminHub2 >`.

```lua
-- COPIAR INTEGRALMENTE o conteúdo de s_adminHub.lua como base.
-- Em seguida, ADICIONAR:

-- Auto-push de snapshot após cada ação bem-sucedida
-- Em cada handler que altera dinheiro/cc/pp/banco, após a operação:
local function pushSnapshotUpdate(admin, target)
    if not isElement(target) then return end
    triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Operação concluída.", {
        money    = tonumber(getElementData(target,"char:money")) or 0,
        pp       = tonumber(getElementData(target,"char:pp"))    or 0,
        cc       = tonumber(getElementData(target,"char:cc"))    or 0,
    })
end

-- Novos eventos adminHub2 > (versão v2, mesma lógica mas com pushSnapshot)

addEvent("adminHub2 > snapshot", true)
addEventHandler("adminHub2 > snapshot", resourceRoot, function(partial)
    -- idêntico ao "adminHub > snapshot" mas também retorna:
    -- online=true/false, ajailed, onDuty, inVeh, faction, factionRank
    if client ~= source then return end
    local admin = client
    local ok, err = adminGate(admin)
    if not ok then
        triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, false, err)
        return
    end
    if not exports.oAdmin:hasPermission(admin, "showinv", true) then
        triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, false, "Sem permissão.")
        return
    end
    if not partial or partial == "" then
        triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, false, "Indica o alvo.")
        return
    end
    local target, terr = resolveTarget(admin, partial)
    if not target then
        triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, false, terr)
        return
    end
    -- Banco
    local bankSerial, bankMoney = false, 0
    local ob = getResourceFromName("oBank")
    if ob and getResourceState(ob)=="running" and exports.oBank and exports.oBank.getMainBankAccountForChar then
        local cid = getElementData(target,"char:id")
        local s2ok, a, bv = pcall(function() return exports.oBank:getMainBankAccountForChar(cid) end)
        if s2ok and a and a~=false then bankSerial,bankMoney = a, tonumber(bv) or 0 end
    end
    -- Facção
    local factionName, factionRank = "", ""
    local fid = getElementData(target,"char:mainFaction")
    -- (opcional: lookup na DB ou element data)

    triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, true, {
        name        = getElementData(target,"char:name") or getPlayerName(target),
        charId      = getElementData(target,"char:id"),
        userId      = getElementData(target,"user:id"),
        money       = tonumber(getElementData(target,"char:money")) or 0,
        pp          = tonumber(getElementData(target,"char:pp")) or 0,
        cc          = tonumber(getElementData(target,"char:cc")) or 0,
        bankSerial  = bankSerial,
        bankMoney   = bankMoney,
        online      = true,
        ajailed     = getElementData(target,"char:jailed") and true or false,
        onDuty      = getElementData(target,"char:duty:faction") ~= nil,
        inVeh       = isElement(getPedOccupiedVehicle(target)) and true or false,
        faction     = factionName,
        factionRank = factionRank,
    })
end)

addEvent("adminHub2 > getCatalog", true)
addEventHandler("adminHub2 > getCatalog", resourceRoot, function()
    if client ~= source then return end
    local admin = client
    local ok, err = adminGate(admin)
    if not ok then
        triggerClientEvent(admin, "adminHub2 > catalogResult", resourceRoot, {})
        return
    end
    local inv = getResourceFromName("oInventory")
    if not inv or getResourceState(inv)~="running" or not exports.oInventory or not exports.oInventory.getItemCatalogMini then
        triggerClientEvent(admin, "adminHub2 > catalogResult", resourceRoot, {})
        return
    end
    triggerClientEvent(admin, "adminHub2 > catalogResult", resourceRoot,
        exports.oInventory:getItemCatalogMini() or {})
end)

-- adminHub2 > kick
addEvent("adminHub2 > kick", true)
addEventHandler("adminHub2 > kick", resourceRoot, function(partial, reason)
    if client ~= source then return end
    local admin = client
    local ok, err = adminGate(admin)
    if not ok then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,err)
        return
    end
    if not exports.oAdmin:hasPermission(admin,"kick",true) then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,"Sem permissão (kick).")
        return
    end
    local target,terr = resolveTarget(admin,partial)
    if not target then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,terr)
        return
    end
    reason = tostring(reason or "Kick administrativo")
    kickPlayer(target, admin, reason)
    sendMessageToAdmins(admin, "kickou " .. (getElementData(target,"char:name") or "?") .. ". Motivo: " .. reason, 3)
    setElementData(admin,"log:admincmd",{getElementData(target,"char:id"),"adminhub2_kick"})
    triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,true,"Jogador kickado.")
end)

-- adminHub2 > warn
addEvent("adminHub2 > warn", true)
addEventHandler("adminHub2 > warn", resourceRoot, function(partial, reason)
    if client ~= source then return end
    local admin = client
    local ok, err = adminGate(admin)
    if not ok then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,err)
        return
    end
    if not exports.oAdmin:hasPermission(admin,"warn",true) then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,"Sem permissão (warn).")
        return
    end
    local target,terr = resolveTarget(admin,partial)
    if not target then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,terr)
        return
    end
    reason = tostring(reason or "Aviso administrativo")
    outputChatBox(exports.oCore:getServerPrefix("server","Admin",1)
        .. "#ff6666Você recebeu um aviso: #ffffff" .. reason, target, 255,255,255,true)
    sendMessageToAdmins(admin, "avisou " .. (getElementData(target,"char:name") or "?") .. ": " .. reason, 2)
    setElementData(admin,"log:admincmd",{getElementData(target,"char:id"),"adminhub2_warn"})
    triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,true,"Aviso enviado.")
end)

-- adminHub2 > economy (unificado: dinheiro, CC, PP, banco)
addEvent("adminHub2 > economy", true)
addEventHandler("adminHub2 > economy", resourceRoot, function(partial, econType, econMode, value)
    if client ~= source then return end
    local admin = client
    local ok, err = adminGate(admin)
    if not ok then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,err)
        return
    end
    -- econType: 1=dinheiro 2=CC 3=PP 4=banco
    -- econMode: 1=adicionar 2=remover 3=definir
    value = tonumber(value)
    econType = tonumber(econType)
    econMode = tonumber(econMode)
    if not value or value < 0 or not econType or not econMode then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,"Dados inválidos.")
        return
    end
    -- Mapear para eventos existentes do adminHub v1 para reutilizar lógica já validada
    if econType == 1 then
        if econMode == 3 then
            executeCommandHandler(admin,"setmoney",partial,tostring(math.floor(value)))
        else
            executeCommandHandler(admin,"givemoney",partial,tostring(econMode),tostring(math.floor(value)))
        end
    elseif econType == 2 then
        local target,terr = resolveTarget(admin,partial)
        if not target then
            triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,terr); return
        end
        local cur = tonumber(getElementData(target,"char:cc")) or 0
        local newv
        if econMode==1 then newv=cur+math.floor(value)
        elseif econMode==2 then newv=math.max(0,cur-math.floor(value))
        else newv=math.floor(value) end
        setElementData(target,"char:cc",newv)
        sendMessageToAdmins(admin,"ajustou CC de "..(getElementData(target,"char:name") or "?").." para "..newv..".",7)
        local updated = {cc=newv}
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,true,"CC: "..newv,updated)
        return
    elseif econType == 3 then
        if econMode == 3 then
            executeCommandHandler(admin,"setpp",partial,tostring(math.floor(value)))
        else
            executeCommandHandler(admin,"givepp",partial,tostring(econMode),tostring(math.floor(value)))
        end
    elseif econType == 4 then
        -- banco: precisa do serial do snapshot
        -- por limitação, usar resolveTarget e depois oBank
    end
    -- Para econType 1 e 3, o executeCommandHandler já dispara actionResult via oAdmin
    -- Para CC e banco, triggerClientEvent manual acima
end)
```

---

## 13. Contrato de eventos (client ↔ server)

### Novos eventos `adminHub2 >`

| Evento | Direção | Argumentos |
|--------|---------|------------|
| `adminHub2 > snapshot` | C→S | `partial` |
| `adminHub2 > snapshotResult` | S→C | `ok, data` |
| `adminHub2 > economy` | C→S | `partial, econType, econMode, value` |
| `adminHub2 > getCatalog` | C→S | — |
| `adminHub2 > catalogResult` | S→C | `list` |
| `adminHub2 > actionResult` | S→C | `ok, msg, updatedSnapshot?` |
| `adminHub2 > kick` | C→S | `partial, reason` |
| `adminHub2 > warn` | C→S | `partial, reason` |
| `adminHub2 > ban` | C→S | `partial, durationHours, reason` |
| `adminHub2 > mute` | C→S | `partial, durationMinutes, reason` |
| `adminHub2 > giveItem` | C→S | `partial, id, val, count, duty` |
| `adminHub2 > makeveh` | C→S | `partial, modelId, isFaction, plate, colorR, colorG, colorB` |
| `adminHub2 > fixveh` | C→S | `partial` |
| `adminHub2 > unflip` | C→S | `partial` |
| `adminHub2 > ajail` | C→S | `partial, minutes, reason` |
| `adminHub2 > unjail` | C→S | `partial` |
| `adminHub2 > teleport` | C→S | `partial, mode` (mode: 1=ir até alvo, 2=puxar alvo) |
| `adminHub2 > heal` | C→S | `partial` |
| `adminHub2 > freeze` | C→S | `partial, state` |

### Eventos v1 preservados
Todos os `adminHub > *` do `s_adminHub.lua` atual **continuam funcionando** sem alteração.
O `s_hub.lua` deve incluir o conteúdo completo do `s_adminHub.lua` original como base.

---

## 14. Segurança (obrigatório em TODOS os handlers)

```lua
-- Padrão obrigatório — não omitir nenhuma camada:
addEvent("adminHub2 > nomeAcao", true)
addEventHandler("adminHub2 > nomeAcao", resourceRoot, function(arg1, arg2)
    if client ~= source then return end          -- 1. anti-spoofing
    local admin = client
    local ok, err = adminGate(admin)             -- 2. em /aduty + conta verificada
    if not ok then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,err)
        return
    end
    if not exports.oAdmin:hasPermission(admin,"permissao",true) then   -- 3. nível
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,"Sem permissão.")
        return
    end
    -- 4. Validar argumentos antes de usar
    arg1 = tostring(arg1 or "")
    arg2 = tonumber(arg2)
    if not arg2 or arg2 < 0 then
        triggerClientEvent(admin,"adminHub2 > actionResult",resourceRoot,false,"Dados inválidos.")
        return
    end
    -- lógica aqui
end)
```

---

## 15. Performance (obrigatório)

```lua
-- Layout: NUNCA recalcular a cada frame
-- OK:
function HubGetLayout()
    if HubState._layoutCache then return HubState._layoutCache end
    -- ... calcular ...
    HubState._layoutCache = L
    return L
end

-- Catálogo: NUNCA filtrar a cada frame
-- OK: usar HubState.catalogDirty para saber quando recalcular
-- Flag dirty quando o texto do campo muda (detectado a cada 300ms via setTimer)

-- onClientRender: NÃO fazer gsub, table.sort, toJSON, fromJSON dentro do handler
-- Usar cache e atualizar via setTimer ou eventos

-- Toasts: remover da lista quando expirarem (dentro de HubRenderToasts)
```

---

## 16. Ordem de implementação recomendada

| # | Arquivo | Dependências |
|---|---------|-------------|
| 1 | `shared_state.lua` | — |
| 2 | `c_layout.lua` | shared_state |
| 3 | `c_theme.lua` | c_layout |
| 4 | `c_toast.lua` | c_theme, c_layout |
| 5 | `c_modal.lua` | c_theme, c_layout |
| 6 | `c_history.lua` | c_theme, c_layout |
| 7 | `c_catalog.lua` | c_theme, c_layout |
| 8 | `c_sidebar.lua` | c_theme, c_layout, c_catalog |
| 9 | `c_tabs.lua` | c_theme, c_layout |
| 10 | `c_views.lua` | todos os componentes |
| 11 | `c_main.lua` | tudo client |
| 12 | `s_hub.lua` | — (cópia de s_adminHub.lua + novos eventos) |
| 13 | `meta.xml` | após todos os arquivos criados |

Implementar e testar cada arquivo com `luac5.1 -p` antes de avançar.
Após criar os 12 arquivos, atualizar `meta.xml` e testar in-game.

---

## 17. Checklist antes de declarar concluído

- [ ] `luac5.1 -p` sem erros em todos os 12 arquivos
- [ ] `meta.xml` atualizado com todas as entradas na ordem correta
- [ ] Painel abre/fecha sem erros no console
- [ ] Snapshot carrega automaticamente ao digitar o alvo (debounce 800ms)
- [ ] Sidebar atualiza após cada ação econômica
- [ ] Modal aparece em ações críticas (Definir, Kick, Ban, AJail)
- [ ] Toasts aparecem após cada ação (success/error)
- [ ] Histórico registra todas as ações da sessão
- [ ] Catálogo filtra sem travar (cache de filtro funcionando)
- [ ] Aba Itens: catálogo com favoritos e recentes
- [ ] Aba Moderação: Kick, Warn, Mute, Ban funcionando
- [ ] Todos os handlers v1 (`adminHub > *`) ainda funcionam
- [ ] Teclas Ctrl+1~7, Ctrl+R, Ctrl+F, ESC funcionando
- [ ] Tema claro/escuro persiste entre sessões
