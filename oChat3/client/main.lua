--[[ oChat3 — cliente (Twitter IC + Deep Web) ]]

local sx, sy = guiGetScreenSize()
local fonts = exports.oFont
local fontFeed, fontDw

local deepWebOpen = false
local deepHandle = ""
local deepLines = {}
local dwInput

local function scale(v)
	return v * (sy / 992)
end

local function ensureFonts()
	if not fontFeed then fontFeed = fonts:getFont("condensed", math.max(11, math.floor(scale(13)))) end
	if not fontDw then fontDw = fonts:getFont("condensed", math.max(11, math.floor(scale(12)))) end
end

local function closeDeepWeb()
	if not deepWebOpen then return end
	deepWebOpen = false
	triggerServerEvent("oChat3 > deepWebLeave", resourceRoot)
	if dwInput and isElement(dwInput) then guiSetVisible(dwInput, false) end
	guiSetInputEnabled(false)
	showCursor(false)
	if dwInput and isElement(dwInput) then guiSetText(dwInput, "") end
end

local function openDeepWebUi()
	ensureFonts()
	deepWebOpen = true
	deepLines = {
		"> Terminal 404.onion — sessão anónima",
		"> Identidade: " .. deepHandle,
		"",
	}
	if dwInput and isElement(dwInput) then
		guiSetVisible(dwInput, true)
		guiBringToFront(dwInput)
		guiSetText(dwInput, "")
		guiSetInputEnabled(true)
		showCursor(true)
	end
end

local function layoutDeepInput()
	if dwInput and isElement(dwInput) then destroyElement(dwInput) end
	dwInput = guiCreateEdit(16, sy - scale(48), sx - 32, scale(32), "", false)
	guiSetVisible(dwInput, false)
	guiEditSetMaxCharacters(dwInput, 280)
	addEventHandler("onClientGUIAccepted", dwInput, function()
		if not deepWebOpen then return end
		local txt = guiGetText(dwInput) or ""
		txt = txt:gsub("^%s+", ""):gsub("%s+$", "")
		if txt == "" then return end
		triggerServerEvent("oChat3 > deepWebSay", resourceRoot, txt)
		guiSetText(dwInput, "")
	end, false)
end

local function chat3KeyBlockedByUi()
	if isConsoleActive() or isMainMenuActive() then return true end
	if isChatBoxInputActive() then return true end
	return false
end

local function onClientKeyChat3(button, press)
	if not press then return end
	local b = string.lower(tostring(button or ""))

	if TwComposer.visible and b == "enter" and getKeyState("lctrl") then
		TwComposer.submit()
		cancelEvent()
		return
	end

	if b == "escape" then
		if TwComposer.visible then
			TwComposer.close()
			cancelEvent()
			return
		end
		if deepWebOpen then
			closeDeepWeb()
			cancelEvent()
			return
		end
		if TwFeed.visible then
			TwFeed.close()
			cancelEvent()
			return
		end
		return
	end

	if b ~= "y" and b ~= "u" then return end
	if chat3KeyBlockedByUi() then return end
	if b == "y" and TwComposer.visible and guiGetInputEnabled() then return end
	if b == "u" and deepWebOpen and guiGetInputEnabled() then return end
	if b == "y" and not TwComposer.visible and isPedDead(localPlayer) then return end
	if b == "u" and isPedDead(localPlayer) then return end
	cancelEvent()
	if b == "y" then
		if TwComposer.visible then
			TwComposer.close()
		else
			if getElementData(localPlayer, "user:loggedin") and not isPedDead(localPlayer) then
				TwComposer.open(sx, sy)
			else
				exports.oInfobox:outputInfoBox("Entra no personagem para usar o Twitter IC.", "warning")
			end
		end
	else
		if not getElementData(localPlayer, "user:loggedin") then
			exports.oInfobox:outputInfoBox("Entra no personagem para usar a Deep Web.", "warning")
			return
		end
		if deepWebOpen then
			closeDeepWeb()
		else
			triggerServerEvent("oChat3 > deepWebJoin", resourceRoot)
		end
	end
end

local function bindChat3Keys()
	unbindKey("y", "down", "chatbox")
	unbindKey("y", "down")
	unbindKey("u", "down", "chatbox")
	unbindKey("u", "down")
	toggleControl("radio_next", false)
	toggleControl("radio_previous", false)
	unbindKey("t", "down")
	bindKey("t", "down", "chatbox", "Say")
	bindKey("backspace", "down", function()
		if isChatBoxInputActive() or isConsoleActive() or isMainMenuActive() then return end
		if TwFeed.visible then
			TwFeed.close()
		end
	end)
	bindKey("mouse_wheel_up", "down", function()
		if not TwFeed.visible then return end
		local vis = TwFeed._visUsed or TWITTER_FEED_VISIBLE_LINES
		if #TwFeed.posts > vis then
			TwFeed.scrollTarget = math.max(0, TwFeed.scrollTarget - 1)
		end
	end)
	bindKey("mouse_wheel_down", "down", function()
		if not TwFeed.visible then return end
		local vis = TwFeed._visUsed or TWITTER_FEED_VISIBLE_LINES
		if #TwFeed.posts > vis then
			local maxS = math.max(0, #TwFeed.posts - vis)
			TwFeed.scrollTarget = math.min(maxS, TwFeed.scrollTarget + 1)
		end
	end)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	sx, sy = guiGetScreenSize()
	ensureFonts()
	TwComposer.init()
	layoutDeepInput()
	bindChat3Keys()
	addEventHandler("onClientKey", root, onClientKeyChat3, true, "high")
end)

addEventHandler("onClientResourceStart", root, function(res)
	if getResourceName(res) == "oChat" then
		setTimer(bindChat3Keys, 400, 1)
	end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	removeEventHandler("onClientKey", root, onClientKeyChat3)
	TwComposer.destroy()
	closeDeepWeb()
	if dwInput and isElement(dwInput) then destroyElement(dwInput) end
end)

addEvent("oChat3 > twitterSetFeed", true)
addEventHandler("oChat3 > twitterSetFeed", resourceRoot, function(rows)
	TwFeed.setPosts(rows)
end)

addEvent("oChat3 > twitterLikeResult", true)
addEventHandler("oChat3 > twitterLikeResult", resourceRoot, function(postId, likes)
	postId = tonumber(postId)
	likes = tonumber(likes)
	if not postId then return end
	for _, row in ipairs(TwFeed.posts) do
		if tonumber(row.id) == postId then row.likes = likes break end
	end
end)

addEvent("oChat3 > twitterToggleFeed", true)
addEventHandler("oChat3 > twitterToggleFeed", resourceRoot, function()
	TwFeed.toggle()
end)

addEvent("oChat3 > deepWebOpen", true)
addEventHandler("oChat3 > deepWebOpen", resourceRoot, function(handle)
	deepHandle = handle or "[usr_????]"
	openDeepWebUi()
end)

addEvent("oChat3 > deepWebLine", true)
addEventHandler("oChat3 > deepWebLine", resourceRoot, function(handle, text)
	if type(handle) ~= "string" or type(text) ~= "string" then return end
	table.insert(deepLines, handle .. " » " .. text)
	while #deepLines > 80 do table.remove(deepLines, 1) end
end)

addEvent("oChat3 > deepWebForceClose", true)
addEventHandler("oChat3 > deepWebForceClose", resourceRoot, function()
	closeDeepWeb()
end)

addEventHandler("onClientRender", root, function()
	sx, sy = guiGetScreenSize()
	ensureFonts()
	if TwFeed.visible or TwComposer.visible then
		TwUi.beginHits()
		if TwFeed.visible then
			TwFeed.draw(sx, sy, fontFeed)
		end
		if TwComposer.visible then
			TwComposer.draw(sx, sy, fontFeed)
		end
	end

	if deepWebOpen then
		dxDrawRectangle(0, 0, sx, sy, tocolor(8, 8, 8, 230))
		local ty = scale(40)
		for _, ln in ipairs(deepLines) do
			dxDrawText(ln, scale(24), ty, sx - scale(24), ty + scale(20), tocolor(0, 255, 65, 245), 1, fontDw, "left", "top", false, false, false, true)
			ty = ty + scale(18)
			if ty > sy - scale(80) then break end
		end
		dxDrawText("404.onion — Escape para sair | Enter para enviar", scale(16), sy - scale(70), sx, sy, tocolor(0, 200, 55, 200), 0.85, fontDw, "left", "top")
	end
end)

addEventHandler("onClientClick", root, function(btn, st, cx, cy)
	if btn ~= "left" or st ~= "down" then return end
	if TwComposer.visible then
		if TwComposer.tryClick(cx, cy) then return end
		if TwComposer.pointInPanel(cx, cy) then return end
		TwComposer.close()
		return
	end
	if TwFeed.visible then
		local fx, fy, fw, fh = TwFeed.layout(sx, sy)
		if cx < fx or cx > fx + fw or cy < fy or cy > fy + fh then
			TwFeed.close()
			return
		end
		if TwUi.fire(cx, cy) then return end
	end
end)
