--[[ oWelcome — orquestração cliente ]]

Welcome = {
	show = false,
	payload = nil,
	activeTab = 1,
	dontShowAgain = false,
	scrollOffsets = { 0, 0, 0, 0 },
	expandedNewsId = nil,
	skeletonUntil = 0,
	openTick = 0,
	tabUnderlineX = nil,
	tabUnderlineW = nil,
	headerCloseHit = nil,
	panelHit = nil,
	sx = 1920,
	sy = 1080,
	fontHeader = nil,
	fontTitle = nil,
	fontMain = nil,
	fontSmall = nil,
	_lastTick = getTickCount(),
}

WelcomeMain = WelcomeMain or {}

local fonts = exports.oFont

local function ensureFonts()
	if not Welcome.fontHeader then
		Welcome.fontHeader = fonts:getFont("condensed", math.max(16, math.floor(Welcome.sy / 992 * 24)))
	end
	if not Welcome.fontTitle then
		Welcome.fontTitle = fonts:getFont("condensed", math.max(14, math.floor(Welcome.sy / 992 * 20)))
	end
	if not Welcome.fontMain then
		Welcome.fontMain = fonts:getFont("condensed", math.max(11, math.floor(Welcome.sy / 992 * 13)))
	end
	if not Welcome.fontSmall then
		Welcome.fontSmall = fonts:getFont("condensed", math.max(10, math.floor(Welcome.sy / 992 * 12)))
	end
end

function WelcomeMain.close()
	if not Welcome.show then return end
	if Welcome.dontShowAgain then
		triggerServerEvent("oWelcome > markSeen", resourceRoot, true)
	end
	Welcome.show = false
	Welcome.payload = nil
	Welcome.activeTab = 1
	Welcome.dontShowAgain = false
	Welcome.scrollOffsets = { 0, 0, 0, 0 }
	Welcome.expandedNewsId = nil
	Welcome.skeletonUntil = 0
	Welcome.tabUnderlineX = nil
	Welcome.tabUnderlineW = nil
	showCursor(false)
	unbindKey("escape", "down", WelcomeMain.onEscape)
end

function WelcomeMain.onEscape()
	if Welcome.show then
		WelcomeMain.close()
	end
end

addEvent("oWelcome > open", true)
addEventHandler("oWelcome > open", resourceRoot, function(data)
	Welcome.payload = data or {}
	Welcome.show = true
	Welcome.activeTab = 1
	Welcome.dontShowAgain = false
	Welcome.scrollOffsets = { 0, 0, 0, 0 }
	Welcome.expandedNewsId = nil
	Welcome.openTick = getTickCount()
	Welcome.skeletonUntil = Welcome.openTick + 180
	Welcome.tabUnderlineX = nil
	Welcome.tabUnderlineW = nil
	showCursor(true)
	ensureFonts()
	unbindKey("escape", "down", WelcomeMain.onEscape)
	bindKey("escape", "down", WelcomeMain.onEscape)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	Welcome.sx, Welcome.sy = guiGetScreenSize()
	ensureFonts()
	bindKey("backspace", "down", function()
		if Welcome.show then WelcomeMain.close() end
	end)
end)

addEventHandler("onClientRender", root, function()
	if not Welcome.show or not Welcome.payload then return end
	local now = getTickCount()
	Welcome.lastDt = math.min(0.05, (now - Welcome._lastTick) / 1000)
	Welcome._lastTick = now
	Welcome.sx, Welcome.sy = guiGetScreenSize()
	ensureFonts()
	WelcomeRenderer.draw(Welcome)
end)

addEventHandler("onClientKey", root, function(key, press)
	if not Welcome.show or not press then return end
	local step = Welcome.sy / 992 * 52
	if key == "mouse_wheel_up" then
		Welcome.scrollOffsets[Welcome.activeTab] = math.max(0, (Welcome.scrollOffsets[Welcome.activeTab] or 0) - step)
	elseif key == "mouse_wheel_down" then
		Welcome.scrollOffsets[Welcome.activeTab] = (Welcome.scrollOffsets[Welcome.activeTab] or 0) + step
	end
end)

addEventHandler("onClientClick", root, function(btn, st, cx, cy)
	if not Welcome.show or btn ~= "left" or st ~= "down" then return end
	local px, py, pw, ph = WelcomeRenderer.panelGeom(Welcome)
	if cx < px or cx > px + pw or cy < py or cy > py + ph then
		WelcomeMain.close()
		return
	end
	if WelcomeUi.processHits(cx, cy) then
		return
	end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	if Welcome.show then WelcomeMain.close() end
end)
