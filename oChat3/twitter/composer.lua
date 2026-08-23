--[[ Ipiranga Tweets — compositor (memo + cromado DX) ]]

TwComposer = TwComposer or {
	visible = false,
	memo = nil,
	geom = nil,
	openTick = 0,
	_hits = {},
}

function TwComposer.init()
	if TwComposer.memo and isElement(TwComposer.memo) then return end
	TwComposer.memo = guiCreateMemo(0, 0, 200, 120, "", false)
	guiSetVisible(TwComposer.memo, false)
	guiSetFont(TwComposer.memo, "default-bold-small")
	addEventHandler("onClientGUIChanged", TwComposer.memo, function()
		local t = guiGetText(TwComposer.memo) or ""
		if utf8 and utf8.len and utf8.len(t) > TWITTER_MAX_CHARS then
			guiSetText(TwComposer.memo, utf8.sub(t, 1, TWITTER_MAX_CHARS))
		elseif #t > TWITTER_MAX_CHARS then
			guiSetText(TwComposer.memo, t:sub(1, TWITTER_MAX_CHARS))
		end
	end, false)
end

function TwComposer.destroy()
	if TwComposer.memo and isElement(TwComposer.memo) then
		destroyElement(TwComposer.memo)
	end
	TwComposer.memo = nil
end

function TwComposer.layout(sx, sy)
	local pw = math.min(sx * 0.44, 540)
	local ph = sy * 0.44
	local px = (sx - pw) / 2
	local py = (sy - ph) / 2 - sy * 0.04
	local titleH = TwUi.scale(sy, 46)
	local footH = TwUi.scale(sy, 54)
	local margin = TwUi.scale(sy, 14)
	local memoX = math.floor(px + margin)
	local memoY = math.floor(py + titleH + TwUi.scale(sy, 6))
	local memoW = math.floor(pw - margin * 2)
	local memoH = math.floor(ph - titleH - footH - TwUi.scale(sy, 12))
	TwComposer.geom = {
		px = px,
		py = py,
		pw = pw,
		ph = ph,
		memoX = memoX,
		memoY = memoY,
		memoW = memoW,
		memoH = memoH,
		titleH = titleH,
		footH = footH,
		margin = margin,
	}
end

function TwComposer.open(sx, sy)
	if not getElementData(localPlayer, "user:loggedin") then
		outputChatBox("#888888[oChat3]#FFFFFF Entra no personagem para usar o Twitter IC.", 255, 255, 255, true)
		return false
	end
	if isPedDead(localPlayer) then return false end
	if not TwComposer.memo or not isElement(TwComposer.memo) then
		outputChatBox("#888888[oChat3]#FFFFFF Compositor indisponível. /restart oChat3", 255, 255, 255, true)
		return false
	end
	TwComposer.layout(sx, sy)
	local g = TwComposer.geom
	guiSetPosition(TwComposer.memo, g.memoX, g.memoY, false)
	guiSetSize(TwComposer.memo, g.memoW, g.memoH, false)
	guiSetText(TwComposer.memo, "")
	guiSetVisible(TwComposer.memo, true)
	guiBringToFront(TwComposer.memo)
	guiSetInputEnabled(true)
	showCursor(true)
	TwComposer.visible = true
	TwComposer.openTick = getTickCount()
	return true
end

function TwComposer.close()
	if not TwComposer.visible then return end
	TwComposer.visible = false
	if TwComposer.memo and isElement(TwComposer.memo) then
		guiSetVisible(TwComposer.memo, false)
		guiSetText(TwComposer.memo, "")
	end
	if not TwFeed.visible then
		guiSetInputEnabled(false)
		showCursor(false)
	end
end

function TwComposer.submit()
	if not TwComposer.memo or not isElement(TwComposer.memo) then return end
	local txt = guiGetText(TwComposer.memo) or ""
	txt = txt:gsub("^%s+", ""):gsub("%s+$", "")
	local len = (utf8 and utf8.len(txt)) or #txt
	if len < 1 then return end
	triggerServerEvent("oChat3 > twitterPost", resourceRoot, txt)
	TwComposer.close()
end

function TwComposer.tryClick(cx, cy)
	for i = #TwComposer._hits, 1, -1 do
		local h = TwComposer._hits[i]
		if TwUi.inRect(cx, cy, h.x, h.y, h.w, h.h) then
			if h.fn then h.fn() end
			return true
		end
	end
	return false
end

function TwComposer.pointInPanel(cx, cy)
	local g = TwComposer.geom
	if not g then return false end
	return TwUi.inRect(cx, cy, g.px, g.py, g.pw, g.ph)
end

function TwComposer.draw(sx, sy, font)
	TwComposer._hits = {}
	if not TwComposer.visible then return end
	TwComposer.layout(sx, sy)
	local g = TwComposer.geom
	if not g or not TwComposer.memo or not isElement(TwComposer.memo) then return end
	guiSetPosition(TwComposer.memo, g.memoX, g.memoY, false)
	guiSetSize(TwComposer.memo, g.memoW, g.memoH, false)
	local t = TW_THEME
	local ease = TwAnim.easeOut(math.min(1, (getTickCount() - TwComposer.openTick) / 220))
	local al = math.floor(210 * ease)
	dxDrawRectangle(0, 0, sx, sy, tocolor(t.bg[1], t.bg[2], t.bg[3], math.floor(165 * ease)), false)
	dxDrawRectangle(g.px + 5, g.py + 8, g.pw, g.ph, tocolor(0, 0, 0, math.floor(85 * ease)), false)
	TwUi.rr(g.px, g.py, g.pw, g.ph, twColor(t.border, 200), twColor(t.card, math.min(252, al + 50)), false)

	dxDrawRectangle(g.px + 2, g.py + 2, g.pw - 4, g.titleH - 2, twColor(t.card2, 245))
	dxDrawText("Novo Tweet", g.px + g.margin, g.py + TwUi.scale(sy, 6), g.px + g.pw, g.py + g.titleH, twColor(t.text, 255), 0.95, font, "left", "center", false, false, false, true)
	dxDrawText("O que está a acontecer no Ipiranga?", g.px + g.margin, g.py + TwUi.scale(sy, 24), g.px + g.pw, g.py + g.titleH, twColor(t.muted, 220), 0.78, font, "left", "bottom", false, false, false, true)

	local bx = g.px + g.pw - TwUi.scale(sy, 42)
	local by = g.py + TwUi.scale(sy, 8)
	local bs = TwUi.scale(sy, 30)
	local mx, my = TwUi.cursor(sx, sy)
	local hovX = TwUi.inRect(mx, my, bx, by, bs, bs)
	dxDrawRectangle(bx, by, bs, bs, twColor(hovX and t.hover or t.card, 240))
	dxDrawText("✕", bx, by, bx + bs, by + bs, twColor(t.text, 255), 1, font, "center", "center", false, false, false, true)
	table.insert(TwComposer._hits, { x = bx, y = by, w = bs, h = bs, fn = function()
		TwComposer.close()
	end })

	local footY = g.py + g.ph - g.footH
	dxDrawRectangle(g.px + 2, footY, g.pw - 4, g.footH - 2, twColor(t.card2, 240))
	local txt = (TwComposer.memo and isElement(TwComposer.memo)) and (guiGetText(TwComposer.memo) or "") or ""
	local len = (utf8 and utf8.len(txt)) or #txt
	local left = tostring(len) .. " / " .. tostring(TWITTER_MAX_CHARS)
	dxDrawText(left, g.px + g.margin, footY, g.px + g.pw * 0.5, footY + g.footH, twColor(t.muted, 230), 0.82, font, "left", "center", false, false, false, true)
	dxDrawText("Ctrl+Enter · publicar", g.px + g.margin, footY + TwUi.scale(sy, 2), g.px + g.pw * 0.55, footY + g.footH - 2, twColor(t.muted, 150), 0.68, font, "left", "bottom", false, true, false, true)

	local btnW, btnH = TwUi.scale(sy, 112), TwUi.scale(sy, 36)
	local btnX = g.px + g.pw - btnW - g.margin
	local btnY = footY + (g.footH - btnH) / 2
	local disabled = len < 1
	local mx, my = TwUi.cursor(sx, sy)
	local hovB = not disabled and TwUi.inRect(mx, my, btnX, btnY, btnW, btnH)
	local bgB = disabled and t.card or (hovB and t.hover or t.accent)
	TwUi.rr(btnX, btnY, btnW, btnH, twColor(t.border, 120), twColor(bgB, disabled and 160 or 245), false)
	dxDrawText("Tweet", btnX, btnY, btnX + btnW, btnY + btnH, twColor(disabled and t.muted or t.text, disabled and 140 or 255), 0.92, font, "center", "center", false, false, false, true)
	if not disabled then
		table.insert(TwComposer._hits, { x = btnX, y = btnY, w = btnW, h = btnH, fn = TwComposer.submit })
	end
end
