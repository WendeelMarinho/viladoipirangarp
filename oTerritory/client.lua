-- ─── oTerritory / client.lua ─────────────────────────────────────────────────

local core   = exports.oCore
local sx, sy = guiGetScreenSize()
local myX, myY = 1600, 900
local function px(n) return n/myX*sx end
local function py(n) return n/myY*sy end

local territories  = {}   -- id → dados completos
local blips        = {}   -- id → blip
local myTerritoryID= nil  -- zona onde o localPlayer está agora
local fontTerr

local function refreshFont()
    fontTerr = exports.oFont:getFont("condensed", math.max(10, math.floor(12/myY*sy)))
end
addEventHandler("onClientResourceStart", resourceRoot, refreshFont)

-- ─── Helpers de cor ───────────────────────────────────────────────────────────

local STATE_COLORS = {
    [TERR_STATE_NEUTRAL]   = {180, 180, 180},
    [TERR_STATE_CONTESTED]  = {255, 200,  50},
    [TERR_STATE_CAPTURING]  = {255, 140,  30},
    [TERR_STATE_OWNED]      = nil,   -- usa cor da facção dona (cr/cg/cb)
}

local function terrColor(t)
    local sc = STATE_COLORS[t.state]
    if sc then return sc[1], sc[2], sc[3] end
    return t.cr or 180, t.cg or 180, t.cb or 180
end

-- ─── Sync do servidor ─────────────────────────────────────────────────────────

addEvent("oTerritory > syncAll", true)
addEventHandler("oTerritory > syncAll", root, function(data)
    -- Destruir blips antigos
    for id, blip in pairs(blips) do
        if isElement(blip) then destroyElement(blip) end
    end
    blips = {}
    territories = data

    for id, t in pairs(territories) do
        local cr, cg, cb = terrColor(t)
        local blip = createBlip(t.x, t.y, t.z, t.blip_icon or 40, 2, cr, cg, cb, 255, 0, 250)
        setBlipOrdering(blip, -1)
        blips[id] = blip
    end
end)

addEvent("oTerritory > sync", true)
addEventHandler("oTerritory > sync", root, function(id, update)
    if not territories[id] then return end
    local t = territories[id]
    t.owner    = update.owner
    t.progress = update.progress
    t.state    = update.state
    t.cap_fac  = update.cap_fac

    -- Atualizar cor do blip
    if blips[id] and isElement(blips[id]) then
        local cr, cg, cb = terrColor(t)
        setBlipColor(blips[id], cr, cg, cb, 255)
    end
end)

-- ─── Detectar entrada/saída de zona ──────────────────────────────────────────

local function checkZone()
    local px_, py_, pz_ = getElementPosition(localPlayer)
    local found = nil
    for id, t in pairs(territories) do
        if getDistanceBetweenPoints3D(px_, py_, pz_, t.x, t.y, t.z) <= t.radius then
            found = id
            break
        end
    end
    if found ~= myTerritoryID then
        myTerritoryID = found
    end
end
setTimer(checkZone, 2000, 0)

-- ─── HUD de zona ──────────────────────────────────────────────────────────────

local function renderTerritoryHUD()
    if not myTerritoryID then return end
    local t = territories[myTerritoryID]
    if not t then return end

    local bx, by = px(18), py(750)
    local bw, bh = px(230), py(64)
    local cr, cg, cb = terrColor(t)

    -- Fundo
    dxDrawRectangle(bx, by, bw, bh, tocolor(0, 0, 0, 170))
    -- Barra de cor superior
    dxDrawRectangle(bx, by, bw, py(3), tocolor(cr, cg, cb, 255))

    -- Nome do território
    dxDrawText(t.name, bx + px(8), by + py(6), bx + bw - px(8), by + py(26),
        tocolor(255, 255, 255, 245), 1, fontTerr, "left", "center")

    -- Estado
    local stateText = {
        [TERR_STATE_NEUTRAL]   = "Neutro",
        [TERR_STATE_CONTESTED]  = "Contestado!",
        [TERR_STATE_CAPTURING]  = "A ser capturado...",
        [TERR_STATE_OWNED]      = t.owner > 0 and ("Dono: Facção #" .. t.owner) or "Neutro",
    }
    dxDrawText(stateText[t.state] or t.state, bx + px(8), by + py(26), bx + bw - px(8), by + py(44),
        tocolor(cr, cg, cb, 220), 1, fontTerr, "left", "center")

    -- Barra de progresso (só aparece durante captura)
    if t.state == TERR_STATE_CAPTURING and t.progress > 0 then
        local barW = bw - px(16)
        dxDrawRectangle(bx + px(8), by + py(46), barW, py(10), tocolor(40, 40, 40, 200))
        dxDrawRectangle(bx + px(8), by + py(46), barW * (t.progress / 100), py(10),
            tocolor(cr, cg, cb, 255))
        dxDrawText(math.floor(t.progress) .. "%", bx + px(8), by + py(46), bx + bw - px(8), by + py(64),
            tocolor(255,255,255,200), 1, fontTerr, "right", "center")
    end
end

addEventHandler("onClientRender", root, renderTerritoryHUD)

-- ─── Painel /territorios ─────────────────────────────────────────────────────
local terrPanelOpen = false
local terrPanelTick = 0

local function renderTerritoriosPanel()
    if not terrPanelOpen then return end

    local bx, by = px(30), py(60)
    local bw, bh = px(500), py(500)
    local rowH   = py(34)
    local alpha  = 230

    -- Fundo principal
    dxDrawRectangle(bx, by, bw, bh, tocolor(10, 10, 10, alpha))
    dxDrawRectangle(bx, by, bw, py(40), tocolor(20, 20, 20, alpha))

    -- Título
    dxDrawText("TERRITÓRIOS", bx + px(16), by + py(8), bx + bw, by + py(40),
        tocolor(255, 255, 255, 255), 1, fontTerr, "left", "center")
    dxDrawText("[F5 para fechar]", bx, by + py(8), bx + bw - px(12), by + py(40),
        tocolor(180, 180, 180, 180), 1, fontTerr, "right", "center")

    -- Cabeçalho
    local hy = by + py(44)
    dxDrawRectangle(bx, hy, bw, rowH, tocolor(30, 30, 30, alpha))
    dxDrawText("ZONA",       bx + px(12),  hy, bx + px(180), hy + rowH, tocolor(200,200,200,200), 1, fontTerr, "left",   "center")
    dxDrawText("DONO",       bx + px(185), hy, bx + px(340), hy + rowH, tocolor(200,200,200,200), 1, fontTerr, "left",   "center")
    dxDrawText("ESTADO",     bx + px(345), hy, bx + px(450), hy + rowH, tocolor(200,200,200,200), 1, fontTerr, "left",   "center")
    dxDrawText("R$/h",       bx + px(455), hy, bx + bw - px(8), hy + rowH, tocolor(200,200,200,200), 1, fontTerr, "right", "center")

    -- Linhas
    local stateLabels = {
        [TERR_STATE_NEUTRAL]   = "Neutro",
        [TERR_STATE_CONTESTED]  = "Disputado",
        [TERR_STATE_CAPTURING]  = "Capturando",
        [TERR_STATE_OWNED]      = "Ocupado",
    }

    local sorted = {}
    for id, t in pairs(territories) do table.insert(sorted, t) end
    table.sort(sorted, function(a, b) return (a.name or "") < (b.name or "") end)

    local row = 0
    for _, t in ipairs(sorted) do
        local ry = hy + rowH + (row * rowH)
        if ry + rowH > by + bh - py(8) then break end

        local cr, cg, cb = terrColor(t)
        local bg = row % 2 == 0 and tocolor(18,18,18,alpha) or tocolor(25,25,25,alpha)
        dxDrawRectangle(bx, ry, bw, rowH, bg)
        -- Barra cor lateral
        dxDrawRectangle(bx, ry, px(3), rowH, tocolor(cr, cg, cb, 200))

        local ownerStr = t.owner > 0 and ("Facção #" .. t.owner) or "—"
        local stateStr = stateLabels[t.state] or t.state

        dxDrawText(t.name or "?",   bx + px(12),  ry, bx + px(180), ry + rowH, tocolor(255,255,255,230), 1, fontTerr, "left",  "center")
        dxDrawText(ownerStr,         bx + px(185), ry, bx + px(340), ry + rowH, tocolor(cr, cg, cb, 220), 1, fontTerr, "left",  "center")
        dxDrawText(stateStr,         bx + px(345), ry, bx + px(450), ry + rowH, tocolor(255,220,100,220), 1, fontTerr, "left",  "center")
        dxDrawText("R$" .. (t.income or 0), bx + px(455), ry, bx + bw - px(8), ry + rowH, tocolor(100,255,100,220), 1, fontTerr, "right", "center")

        row = row + 1
    end
end

addEventHandler("onClientRender", root, renderTerritoriosPanel)

addCommandHandler("territorios", function()
    terrPanelOpen = not terrPanelOpen
end)

bindKey("F5", "up", function()
    if terrPanelOpen then terrPanelOpen = false end
end)
