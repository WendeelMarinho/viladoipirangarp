-- ─── oFactionHQ / client.lua ─────────────────────────────────────────────────

local core    = exports.oCore
local infobox = exports.oInfobox
local sx, sy  = guiGetScreenSize()
local myX, myY = 1600, 900
local function px(n) return n/myX*sx end
local function py(n) return n/myY*sy end

local hqData    = {}   -- faction_id → dados da HQ
local ammoMarkers  = {}
local vehMarkers   = {}
local fontHQ

local function refreshFont()
    fontHQ = exports.oFont:getFont("condensed", math.max(10, math.floor(12/myY*sy)))
end
addEventHandler("onClientResourceStart", resourceRoot, refreshFont)

-- ─── Sync do servidor ─────────────────────────────────────────────────────────

addEvent("oFactionHQ > syncAll", true)
addEventHandler("oFactionHQ > syncAll", root, function(data)
    -- Limpar markers anteriores
    for _, m in pairs(ammoMarkers) do if isElement(m) then destroyElement(m) end end
    for _, m in pairs(vehMarkers) do if isElement(m) then destroyElement(m) end end
    ammoMarkers = {}; vehMarkers = {}
    hqData = data

    for fid, hq in pairs(hqData) do
        -- Marker ponto de munição
        if hq.ammo_x and hq.ammo_x ~= 0 then
            local m = createMarker(hq.ammo_x, hq.ammo_y, hq.ammo_z - 1, "cylinder", 1.0, 60, 180, 60, 150)
            setElementInterior(m, hq.ammo_int or 0)
            setElementDimension(m, hq.ammo_dim or 0)
            setElementData(m, "hqMarker:type", "ammo")
            setElementData(m, "hqMarker:fid",  fid)
            ammoMarkers[fid] = m
        end

        -- Markers de spawn de veículos
        vehMarkers[fid] = {}
        for i, spawn in ipairs(hq.veh_spawns or {}) do
            local m = createMarker(spawn.x, spawn.y, spawn.z - 1, "arrow", 1.2, 80, 80, 200, 150)
            setElementInterior(m, spawn.int or 0)
            setElementDimension(m, spawn.dim or 0)
            setElementData(m, "hqMarker:type",  "veh")
            setElementData(m, "hqMarker:fid",   fid)
            setElementData(m, "hqMarker:index", i)
            table.insert(vehMarkers[fid], m)
        end
    end
end)

-- ─── Interação com markers ─────────────────────────────────────────────────────

addEventHandler("onClientMarkerHit", root, function(player, matchDim)
    if player ~= localPlayer or not matchDim then return end
    local mtype = getElementData(source, "hqMarker:type")
    if not mtype then return end

    local fid   = getElementData(source, "hqMarker:fid")

    if mtype == "ammo" then
        triggerServerEvent("oFactionHQ > useAmmoPoint", localPlayer)
    elseif mtype == "veh" then
        local idx = getElementData(source, "hqMarker:index")
        triggerServerEvent("oFactionHQ > spawnFactionVehicle", localPlayer, idx)
    end
end)

-- ─── HUD mini quando perto de ponto de munição ────────────────────────────────

local function renderHQHint()
    for fid, marker in pairs(ammoMarkers) do
        if isElement(marker) and isElementStreamedIn(marker) then
            local mx, my, mz = getElementPosition(marker)
            local px_, py_, pz_ = getElementPosition(localPlayer)
            if getDistanceBetweenPoints3D(px_, py_, pz_, mx, my, mz) <= 6 then
                local sx2, sy2, sz2, vis = getScreenFromWorldPosition(mx, my, mz + 1.5)
                if sx2 and vis then
                    dxDrawText("[E] Reabastecer", sx2 - px(60), sy2 - py(10), sx2 + px(60), sy2 + py(10),
                        tocolor(60, 200, 80, 240), 1, fontHQ, "center", "center")
                end
            end
        end
    end
end
addEventHandler("onClientRender", root, renderHQHint)
