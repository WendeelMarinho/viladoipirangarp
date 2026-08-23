--[[ Minijogo furadeira — cliente (agulha + zona verde móvel) ]]

local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992
local font = exports.oFont

local active = false
local callbackFn = nil
local needle = 0.5
local zoneCenter = 0.5
local zoneHalf = 0.07
local velZone = 0
local barStart = 0
local checkTimer = nil
local deadlineTimer = nil

local function cleanup()
	active = false
	callbackFn = nil
	if isTimer(checkTimer) then
		killTimer(checkTimer)
	end
	if isTimer(deadlineTimer) then
		killTimer(deadlineTimer)
	end
	checkTimer = nil
	deadlineTimer = nil
	removeEventHandler("onClientRender", root, drawDrill)
	removeEventHandler("onClientKey", root, drillKeys)
	showCursor(false)
end

local function finish(ok)
	local cb = callbackFn
	cleanup()
	if cb then cb(ok) end
end

function drillKeys(btn, press)
	if not active or not press then return end
	if btn == "a" or btn == "arrow_l" then
		velZone = velZone - 0.035
	end
	if btn == "d" or btn == "arrow_r" then
		velZone = velZone + 0.035
	end
	if btn == "backspace" then
		finish(false)
	end
end

function drawDrill()
	if not active then return end
	local t = (getTickCount() - barStart) / 1000
	needle = 0.5 + math.sin(t * 2.8) * 0.42
	zoneCenter = math.max(zoneHalf + 0.02, math.min(1 - zoneHalf - 0.02, zoneCenter + velZone))
	velZone = velZone * 0.92

	local bx, bw = sx * 0.18, sx * 0.64
	dxDrawRectangle(bx, sy * 0.8, bw, sy * 0.045, tocolor(26, 26, 30, 235))
	local zx = bx + (zoneCenter - zoneHalf) * bw
	dxDrawRectangle(zx, sy * 0.8, zoneHalf * 2 * bw, sy * 0.045, tocolor(60, 180, 90, 140))
	local nx = bx + needle * bw
	dxDrawRectangle(nx - 3, sy * 0.785, 6, sy * 0.075, tocolor(255, 220, 120, 255))
	dxDrawText("[A][D] ou setas — mantém a zona sob a agulha. Backspace cancela.", 0, sy * 0.73, sx, sy * 0.78,
		tocolor(255, 255, 255, 210), 1, font:getFont("condensed", 12 / myX * sx), "center", "bottom")
end

function heistDrillBegin(durationMs, token, onDone)
	if active then finish(false) end
	active = true
	callbackFn = onDone
	barStart = getTickCount()
	zoneCenter = 0.5
	velZone = 0
	showCursor(false)
	addEventHandler("onClientRender", root, drawDrill)
	addEventHandler("onClientKey", root, drillKeys)

	local accumOk = 0
	checkTimer = setTimer(function()
		if not active then
			return
		end
		if math.abs(needle - zoneCenter) <= zoneHalf then
			accumOk = accumOk + 120
		else
			accumOk = math.max(0, accumOk - 80)
		end
		if accumOk >= 8500 then
			finish(true)
		end
	end, 120, 0)

	deadlineTimer = setTimer(function()
		if active then
			exports.oInfobox:outputInfoBox("Pressão da furadeira instável — falhou.", "error")
			finish(false)
		end
	end, math.max(20000, durationMs or 65000), 1)
end
