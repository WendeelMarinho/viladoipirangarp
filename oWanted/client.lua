-- ─── oWanted / client.lua ────────────────────────────────────────────────────

local core  = exports.oCore
local sx, sy = guiGetScreenSize()
local myX, myY = 1600, 900
local function px(n) return n/myX*sx end
local function py(n) return n/myY*sy end

local myWantedLevel  = 0
local myWantedBounty = 0
local myWantedCrimes = {}
local wantedBlips    = {}   -- char_id → blip element

local fontWanted

local function refreshFont()
    fontWanted = exports.oFont:getFont("condensed", math.max(11, math.floor(14/myY*sy)))
end
addEventHandler("onClientResourceStart", resourceRoot, refreshFont)

-- ─── Receber meu estado ───────────────────────────────────────────────────────

addEvent("oWanted > update", true)
addEventHandler("oWanted > update", localPlayer, function(cid, level, bounty, crimes)
    myWantedLevel  = level or 0
    myWantedBounty = bounty or 0
    myWantedCrimes = crimes or {}
end)

addEvent("oWanted > cleared", true)
addEventHandler("oWanted > cleared", root, function(cid)
    if getElementData(localPlayer, "char:id") == cid then
        myWantedLevel  = 0
        myWantedBounty = 0
        myWantedCrimes = {}
    end
    -- Remover blip
    if wantedBlips[cid] and isElement(wantedBlips[cid]) then
        destroyElement(wantedBlips[cid])
        wantedBlips[cid] = nil
    end
end)

-- Blip de procurado para polícia
addEvent("oWanted > updatePublic", true)
addEventHandler("oWanted > updatePublic", root, function(cid, wantedPlayer, level)
    if not isElement(wantedPlayer) then return end
    -- Remover blip anterior
    if wantedBlips[cid] and isElement(wantedBlips[cid]) then
        destroyElement(wantedBlips[cid])
    end
    if level > 0 then
        local blip = createBlipAttachedTo(wantedPlayer, 10, 2,
            unpack(WANTED_COLORS[level] or {255,80,80}))
        wantedBlips[cid] = blip
    end
end)

-- ─── HUD — estrelas + crimes ──────────────────────────────────────────────────

local function renderWantedHUD()
    if myWantedLevel <= 0 then return end
    local p = math.sin(getTickCount() / 300)   -- pulso
    local baseAlpha = math.floor(180 + 60 * p)

    local bx = px(18)
    local by = py(820)

    -- Fundo
    dxDrawRectangle(bx, by - py(8), px(220), py(62), tocolor(0,0,0,160))

    -- Estrelas
    local starW, starH = px(28), py(28)
    for i = 1, 5 do
        local cx = WANTED_COLORS[myWantedLevel]
        local lit = i <= myWantedLevel
        local col = lit and tocolor(cx[1], cx[2], cx[3], baseAlpha) or tocolor(80,80,80,140)
        local tx  = bx + (i-1)*(starW + px(4))
        dxDrawText("★", tx, by - py(2), tx + starW, by + starH, col, 1, fontWanted, "center", "center")
    end

    -- Crimes
    local crimeStr = #myWantedCrimes > 0 and table.concat(myWantedCrimes, " · ") or "Procurado"
    dxDrawText(crimeStr, bx, by + starH, bx + px(218), by + starH + py(22),
        tocolor(255, 220, 180, 230), 1, fontWanted, "left", "center", false, false, false, true)

    -- Bounty
    dxDrawText("Recompensa: R$" .. myWantedBounty, bx, by + starH + py(20), bx + px(218), by + py(60),
        tocolor(255, 160, 60, 220), 1, fontWanted, "left", "center")
end

addEventHandler("onClientRender", root, renderWantedHUD)

-- ─── Comando para reportar crime (teste: /crime <key>) ───────────────────────
addCommandHandler("crime", function(_, crimeKey)
    if not crimeKey or crimeKey == "" then
        outputChatBox("[oWanted] Use /crime <chave>. Ex: /crime roubo", 255,200,100)
        return
    end
    triggerServerEvent("oWanted > reportCrime", localPlayer, crimeKey)
end)

-- ─── Detecção de fuga de veículo perto de polícia ─────────────────────────────
local fleeLastReport = 0

local function checkVehicleFlee()
    if myWantedLevel >= 4 then return end  -- já muito procurado, não escala mais por fuga
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then return end
    local speed = Vector3(getElementVelocity(veh))
    local kmh = (speed.length * 3.6 * 50)  -- MTA units → km/h aprox
    if kmh < 80 then return end

    -- Verificar se há policial em serviço a menos de 60m
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= localPlayer then
            local fid = getElementData(p, "char:duty:faction") or 0
            if fid ~= 0 then
                -- Assumir que duty:faction com tipo 1 = policial (verificamos o type via element data se disponível)
                local dx, dy, dz = getElementPosition(p)
                local lx, ly, lz = getElementPosition(localPlayer)
                if getDistanceBetweenPoints3D(lx, ly, lz, dx, dy, dz) <= 60 then
                    local now = getTickCount()
                    if (now - fleeLastReport) > 30000 then
                        fleeLastReport = now
                        triggerServerEvent("oWanted > reportCrime", localPlayer, "fuga_policial")
                    end
                    break
                end
            end
        end
    end
end
setTimer(checkVehicleFlee, 2000, 0)
