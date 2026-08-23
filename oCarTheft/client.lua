--[[ oCarTheft — cliente ]]

local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992

local core = exports.oCore
local color, r, g, b = core:getServerColor()
local font = exports.oFont

local lockpickVeh = nil
local lockpickBar = false
local lockpickCursor = 0
local lockpickBarStart = 0

local chopUiUntil = 0
local chopStartedTick = 0
local chopTimer = nil

local insuranceOpen = false
local insuranceRows = {}
local insuranceHooks = false
local gpsTrackBlip = nil

local alarmBlips = {}

local barPositions = { 0.08, 0.42, 0.58, 0.92 }
local barColors = {
	tocolor(227, 62, 50, 220),
	tocolor(227, 150, 50, 220),
	tocolor(50, 227, 121, 220),
	tocolor(227, 150, 50, 220),
	tocolor(227, 62, 50, 220),
}

local function destroyGpsBlip()
	if isElement(gpsTrackBlip) then
		destroyElement(gpsTrackBlip)
	end
	gpsTrackBlip = nil
end

local function closeInsurance()
	if not insuranceOpen then return end
	insuranceOpen = false
	showCursor(false)
	if insuranceHooks then
		insuranceHooks = false
		removeEventHandler("onClientRender", root, drawInsurance)
		removeEventHandler("onClientKey", root, insuranceKey)
		removeEventHandler("onClientClick", root, insuranceClick)
	end
end

function insuranceKey(btn, press)
	if not insuranceOpen then return end
	if btn == "backspace" and press then
		closeInsurance()
	end
end

local function claimRow(id)
	triggerServerEvent("oCarTheft > insuranceClaim", resourceRoot, id)
end

function drawInsurance()
	local w, h = sx * 0.42, sy * 0.55
	local x, y = (sx - w) / 2, (sy - h) / 2
	dxDrawRectangle(x, y, w, h, tocolor(18, 18, 22, 245))
	dxDrawRectangle(x, y, w, sy * 0.06, tocolor(r, g, b, 90))
	dxDrawText("Seguro de veículo", x + 12, y, x + w, y + sy * 0.06, tocolor(255, 255, 255), 1,
		font:getFont("bebasneue", 18 / myX * sx), "left", "center")
	dxDrawText("Backspace — fechar", x + w - 16, y, x + w - 12, y + sy * 0.06, tocolor(200, 200, 200), 0.9,
		font:getFont("condensed", 11 / myX * sx), "right", "center")

	local ly = y + sy * 0.08
	if #insuranceRows == 0 then
		dxDrawText("Não tens sinistros pendentes.", x + 16, ly, x + w - 16, ly + h, tocolor(210, 210, 210), 1,
			font:getFont("condensed", 12 / myX * sx), "left", "top")
		return
	end

	for i, row in ipairs(insuranceRows) do
		local ry = ly + (i - 1) * sy * 0.11
		dxDrawRectangle(x + 12, ry, w - 24, sy * 0.095, tocolor(40, 40, 46, 230))
		local ready = tonumber(row.insurance_ready_unix) or 0
		local now = getRealTime().timestamp
		local okClaim = ready > 0 and now >= ready
		local txt = ("Veículo #%s | modelo %s | chopped %s"):format(
			tostring(row.veh_db_id), tostring(row.vehicle_model), tostring(row.chopped_at or "?"))
		dxDrawText(txt, x + 20, ry + 6, x + w - 120, ry + sy * 0.05, tocolor(230, 230, 230), 1,
			font:getFont("condensed", 11 / myX * sx), "left", "top")
		local sub = okClaim and "Podes reclamar." or ("Disponível em ~" .. math.max(0, ready - now) .. " s")
		dxDrawText(sub, x + 20, ry + sy * 0.042, x + w - 120, ry + sy * 0.09, tocolor(180, 180, 180), 1,
			font:getFont("condensed", 10 / myX * sx), "left", "top")
		local bx = x + w - 110
		local btnCol = okClaim and tocolor(72, 170, 92, 220) or tocolor(90, 90, 90, 160)
		dxDrawRectangle(bx, ry + sy * 0.02, 90, sy * 0.055, btnCol)
		dxDrawText("Reclamar", bx, ry + sy * 0.02, bx + 90, ry + sy * 0.075, tocolor(255, 255, 255), 1,
			font:getFont("condensed", 11 / myX * sx), "center", "center")
	end
end

local function insuranceClick(btn, state, _, _, wx, wy, wz, el)
	if not insuranceOpen or btn ~= "left" or state ~= "up" then return end
	local w, h = sx * 0.42, sy * 0.55
	local x, y = (sx - w) / 2, (sy - h) / 2
	local ly = y + sy * 0.08
	for i, row in ipairs(insuranceRows) do
		local ry = ly + (i - 1) * sy * 0.11
		local bx = x + w - 110
		if wx >= bx and wx <= bx + 90 and wy >= ry + sy * 0.02 and wy <= ry + sy * 0.075 then
			claimRow(row.id)
			break
		end
	end
end

addEvent("oCarTheft > insuranceData", true)
addEventHandler("oCarTheft > insuranceData", resourceRoot, function(rows)
	insuranceRows = rows or {}
end)

addEvent("oCarTheft > insuranceDataRefresh", true)
addEventHandler("oCarTheft > insuranceDataRefresh", resourceRoot, function()
	triggerServerEvent("oCarTheft > insurancePull", resourceRoot)
end)

local function openInsurancePanel()
	triggerServerEvent("oCarTheft > insurancePull", resourceRoot)
	if insuranceHooks then return end
	insuranceHooks = true
	insuranceOpen = true
	showCursor(true)
	addEventHandler("onClientRender", root, drawInsurance)
	addEventHandler("onClientKey", root, insuranceKey)
	addEventHandler("onClientClick", root, insuranceClick)
end

addEvent("oCarTheft > openInsuranceUi", true)
addEventHandler("oCarTheft > openInsuranceUi", resourceRoot, openInsurancePanel)

local function hideLockpickBarOnly()
	lockpickBar = false
	removeEventHandler("onClientRender", root, drawLockpick)
	unbindKey("space", "up", lockpickSpaceBind)
end

local function stopLockpickUi()
	hideLockpickBarOnly()
	lockpickVeh = nil
	removeEventHandler("onClientKey", root, lockpickKeys)
	showCursor(false)
end

function lockpickSpaceBind(key, keystate)
	if keystate ~= "up" then return end
	if not lockpickBar or not isElement(lockpickVeh) then return end
	local greenLo, greenHi = barPositions[2], barPositions[3]
	hideLockpickBarOnly()
	if lockpickCursor >= greenLo and lockpickCursor <= greenHi then
		triggerServerEvent("oCarTheft > lockpickAttempt", resourceRoot, lockpickVeh)
	else
		exports.oInfobox:outputInfoBox("Soltaste fora da zona segura. Tenta outra vez.", "warning")
		stopLockpickUi()
	end
end

function lockpickKeys(btn, press)
	if btn == "backspace" and press then
		stopLockpickUi()
	end
end

function drawLockpick()
	if not lockpickBar then return end
	local elapsed = (getTickCount() - lockpickBarStart) / 2600
	lockpickCursor = (elapsed % 1)
	dxDrawRectangle(sx * 0.2, sy * 0.82, sx * 0.6, sy * 0.06, tocolor(28, 28, 32, 230))
	local bx = sx * 0.2
	local bw = sx * 0.6
	for i = 1, #barPositions - 1 do
		local x1 = bx + barPositions[i] * bw
		local x2 = bx + barPositions[i + 1] * bw
		dxDrawRectangle(x1, sy * 0.82, x2 - x1, sy * 0.06, barColors[i])
	end
	local cx = bx + lockpickCursor * bw
	dxDrawRectangle(cx - 2, sy * 0.795, 4, sy * 0.09, tocolor(255, 255, 255, 255))
	dxDrawText("Solta [Space] na faixa verde. Backspace cancela.", 0, sy * 0.74, sx, sy * 0.78,
		tocolor(255, 255, 255, 200), 1, font:getFont("condensed", 12 / myX * sx), "center", "bottom")
end

addEvent("oCarTheft > lockpickAllowed", true)
addEventHandler("oCarTheft > lockpickAllowed", resourceRoot, function(veh)
	if not isElement(veh) then return end
	lockpickVeh = veh
	lockpickBar = true
	lockpickBarStart = getTickCount()
	showCursor(false)
	removeEventHandler("onClientKey", root, lockpickKeys)
	addEventHandler("onClientRender", root, drawLockpick)
	addEventHandler("onClientKey", root, lockpickKeys)
	unbindKey("space", "up", lockpickSpaceBind)
	bindKey("space", "up", lockpickSpaceBind)
end)

addEvent("oCarTheft > lockpickResult", true)
addEventHandler("oCarTheft > lockpickResult", resourceRoot, function(success, hasAnother)
	if success then
		stopLockpickUi()
		return
	end
	if hasAnother and isElement(lockpickVeh) then
		lockpickBar = true
		lockpickBarStart = getTickCount()
		removeEventHandler("onClientKey", root, lockpickKeys)
		addEventHandler("onClientRender", root, drawLockpick)
		addEventHandler("onClientKey", root, lockpickKeys)
		unbindKey("space", "up", lockpickSpaceBind)
		bindKey("space", "up", lockpickSpaceBind)
	else
		stopLockpickUi()
	end
end)

local function stopChopUi()
	chopUiUntil = 0
	if isTimer(chopTimer) then
		killTimer(chopTimer)
	end
	chopTimer = nil
	removeEventHandler("onClientRender", root, drawChop)
	removeEventHandler("onClientKey", root, chopKey)
end

function chopKey(btn, press)
	if chopUiUntil <= 0 then return end
	if btn == "backspace" and press then
		triggerServerEvent("oCarTheft > chopFinish", resourceRoot, false)
		stopChopUi()
	end
end

function drawChop()
	if chopUiUntil <= 0 then return end
	local remain = math.max(0, chopUiUntil - getTickCount())
	local total = CHOP_MINIGAME_MS
	local progress = 1 - (remain / total)
	dxDrawRectangle(sx * 0.25, sy * 0.88, sx * 0.5, sy * 0.035, tocolor(30, 30, 34, 230))
	dxDrawRectangle(sx * 0.25, sy * 0.88, sx * 0.5 * progress, sy * 0.035, tocolor(r, g, b, 220))
	dxDrawText("Desmantelamento em curso… aguarda o tempo completo.", sx * 0.25, sy * 0.84, sx * 0.75, sy * 0.88,
		tocolor(255, 255, 255, 220), 1, font:getFont("condensed", 12 / myX * sx), "center", "bottom")
end

addEvent("oCarTheft > chopBeginUi", true)
addEventHandler("oCarTheft > chopBeginUi", resourceRoot, function(seconds)
	if isTimer(chopTimer) then killTimer(chopTimer) end
	removeEventHandler("onClientRender", root, drawChop)
	removeEventHandler("onClientKey", root, chopKey)
	chopStartedTick = getTickCount()
	chopUiUntil = chopStartedTick + CHOP_MINIGAME_MS
	addEventHandler("onClientRender", root, drawChop)
	addEventHandler("onClientKey", root, chopKey)
	chopTimer = setTimer(function()
		chopTimer = nil
		stopChopUi()
		triggerServerEvent("oCarTheft > chopFinish", resourceRoot, true)
	end, CHOP_MINIGAME_MS, 1)
end)

addEvent("oCarTheft > gpsPulse", true)
addEventHandler("oCarTheft > gpsPulse", resourceRoot, function(px, py, pz, dim)
	destroyGpsBlip()
	gpsTrackBlip = createBlip(px, py, pz, 41, 2, 255, 120, 0, 255, 0, 99999)
	if isElement(gpsTrackBlip) then
		setBlipVisibleDistance(gpsTrackBlip, 99999)
	end
end)

addEvent("oCarTheft > alarmBlip", true)
addEventHandler("oCarTheft > alarmBlip", resourceRoot, function(px, py, pz, durSec)
	local b = createBlip(px, py, pz, 0, 2, 255, 0, 0, 255, 0, 400)
	table.insert(alarmBlips, b)
	setTimer(function()
		if isElement(b) then destroyElement(b) end
	end, (durSec or 30) * 1000, 1)
end)

addEvent("oCarTheft > promptNearestOwnedVehicle", true)
addEventHandler("oCarTheft > promptNearestOwnedVehicle", resourceRoot, function(mode)
	local pid = getElementData(localPlayer, "char:id")
	local px, py, pz = getElementPosition(localPlayer)
	local best, bestD
	for _, v in ipairs(getElementsByType("vehicle", root, true)) do
		if tonumber(getElementData(v, "veh:owner")) == tonumber(pid) then
			local vx, vy, vz = getElementPosition(v)
			local d = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
			if not bestD or d < bestD then
				best, bestD = v, d
			end
		end
	end
	if not best or bestD > DIST_GPS_INSTALL_M + 2 then
		exports.oInfobox:outputInfoBox("Não há veículo teu perto o suficiente.", "error")
		return
	end
	if mode == "gps" then
		triggerServerEvent("oCarTheft > installGps", resourceRoot, best)
	end
end)

addEventHandler("onClientClick", root, function(btn, state, _, _, wx, wy, wz, clickedElement)
	if state ~= "down" or btn ~= "right" then return end
	if insuranceOpen then return end
	if clickedElement and getElementType(clickedElement) == "vehicle" then
		local p = localPlayer
		local vx, vy, vz = getElementPosition(clickedElement)
		local px, py, pz = getElementPosition(p)
		if getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) > DIST_LOCKPICK_M + 0.5 then return end
		triggerServerEvent("oCarTheft > requestLockpick", resourceRoot, clickedElement)
	end
end)

addCommandHandler("desmantelar", function()
	triggerServerEvent("oCarTheft > chopStart", resourceRoot)
end)
