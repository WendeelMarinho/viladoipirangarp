--[[ Minijogo hacking — cliente ]]

local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992
local font = exports.oFont

local active = false
local tokenRef = ""
local callbackFn = nil
local barStart = 0
local cursorPos = 0
local barZones = { 0.08, 0.42, 0.58, 0.92 }
local barColors = {
	tocolor(227, 62, 50, 220),
	tocolor(227, 150, 50, 220),
	tocolor(50, 227, 121, 220),
	tocolor(227, 150, 50, 220),
	tocolor(227, 62, 50, 220),
}

local deadlineTimer = nil

local function cleanup()
	active = false
	tokenRef = ""
	callbackFn = nil
	if isTimer(deadlineTimer) then
		killTimer(deadlineTimer)
	end
	deadlineTimer = nil
	removeEventHandler("onClientRender", root, drawHack)
	removeEventHandler("onClientKey", root, hackKeys)
	unbindKey("space", "up", hackSpace)
	showCursor(false)
end

local function finish(ok)
	local cb = callbackFn
	cleanup()
	if cb then cb(ok) end
end

function hackSpace()
	if not active then return end
	local lo, hi = barZones[2], barZones[3]
	if cursorPos >= lo and cursorPos <= hi then
		finish(true)
	else
		exports.oInfobox:outputInfoBox("Fora da zona segura.", "warning")
		finish(false)
	end
end

function hackKeys(btn, press)
	if not active then return end
	if btn == "backspace" and press then
		finish(false)
	end
end

function drawHack()
	if not active then return end
	cursorPos = ((getTickCount() - barStart) / 2600) % 1
	local bx, bw = sx * 0.2, sx * 0.6
	dxDrawRectangle(bx, sy * 0.82, bw, sy * 0.06, tocolor(28, 28, 32, 230))
	for i = 1, #barZones - 1 do
		local x1 = bx + barZones[i] * bw
		local x2 = bx + barZones[i + 1] * bw
		dxDrawRectangle(x1, sy * 0.82, x2 - x1, sy * 0.06, barColors[i])
	end
	local cx = bx + cursorPos * bw
	dxDrawRectangle(cx - 2, sy * 0.795, 4, sy * 0.09, tocolor(255, 255, 255, 255))
	dxDrawText("Firewall — solta [Space] na faixa verde. Backspace cancela.", 0, sy * 0.74, sx, sy * 0.78,
		tocolor(255, 255, 255, 210), 1, font:getFont("condensed", 12 / myX * sx), "center", "bottom")
end

function heistHackBegin(durationMs, token, onDone)
	if active then finish(false) end
	active = true
	tokenRef = token or ""
	callbackFn = onDone
	barStart = getTickCount()
	showCursor(false)
	addEventHandler("onClientRender", root, drawHack)
	addEventHandler("onClientKey", root, hackKeys)
	unbindKey("space", "up", hackSpace)
	bindKey("space", "up", hackSpace)
	deadlineTimer = setTimer(function()
		if active then
			exports.oInfobox:outputInfoBox("Tempo de hacking esgotado.", "error")
			finish(false)
		end
	end, math.max(15000, durationMs or 45000), 1)
end
