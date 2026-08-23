--[[ oHeist — cliente (marcadores + interação) ]]

local sx, sy = guiGetScreenSize()

local markers = {}
local locs = {}
local nearest = nil
local lastNearScan = 0

local function rebuildMarkers()
	for _, m in ipairs(markers) do
		if isElement(m) then
			destroyElement(m)
		end
	end
	markers = {}
	local color, r, g, b = exports.oCore:getServerColor()
	for _, L in ipairs(locs) do
		local mk = createMarker(L.pos[1], L.pos[2], L.pos[3] - 1, "cylinder", 1.35, r, g, b, 95)
		setElementInterior(mk, L.interior_id or 0)
		setElementDimension(mk, L.dimension_id or 0)
		setElementData(mk, "heist:locId", L.id)
		markers[#markers + 1] = mk
	end
end

local function refreshNearest()
	local now = getTickCount()
	if now - lastNearScan < 160 then
		return
	end
	lastNearScan = now
	nearest = nil
	local px, py, pz = getElementPosition(localPlayer)
	local pint = getElementInterior(localPlayer)
	local pdim = getElementDimension(localPlayer)
	local bestd = HEIST_INTERACT_M + 3
	for _, L in ipairs(locs) do
		if pint == (L.interior_id or 0) and pdim == (L.dimension_id or 0) then
			local d = getDistanceBetweenPoints3D(px, py, pz, L.pos[1], L.pos[2], L.pos[3])
			if d <= HEIST_INTERACT_M and d < bestd then
				bestd = d
				nearest = L
			end
		end
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	triggerServerEvent("oHeist > pullLocs", resourceRoot)
end)

addEvent("oHeist > syncLocs", true)
addEventHandler("oHeist > syncLocs", resourceRoot, function(pack)
	locs = pack or {}
	rebuildMarkers()
end)

local font = exports.oFont
local myX, myY = 1768, 992

addEventHandler("onClientRender", root, function()
	if #locs == 0 then return end
	refreshNearest()
	if nearest then
		dxDrawText(
			"[E] Iniciar assalto: " .. (nearest.name or "?") .. " (" .. (nearest.type or "") .. ")",
			0,
			sy * 0.86,
			sx,
			sy,
			tocolor(255, 255, 255, 235),
			1,
			font:getFont("condensed", 13 / myX * sx),
			"center",
			"top",
			false,
			false,
			false,
			true
		)
	end
end)

bindKey("e", "down", function()
	if nearest then
		triggerServerEvent("oHeist > requestStart", resourceRoot, nearest.id)
	end
end)

addEvent("oHeist > beginPhase", true)
addEventHandler("oHeist > beginPhase", resourceRoot, function(phase, dur, token)
	if phase == "hacking" then
		heistHackBegin(dur, token, function(ok)
			triggerServerEvent("oHeist > phaseComplete", resourceRoot, token, ok)
		end)
	elseif phase == "drill" then
		heistDrillBegin(dur, token, function(ok)
			triggerServerEvent("oHeist > phaseComplete", resourceRoot, token, ok)
		end)
	end
end)
