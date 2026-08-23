--[[ oWelcome — primitivos DX reutilizáveis ]]

WelcomeUi = WelcomeUi or {}

local function rr(x, y, w, h, borderC, bgC)
	pcall(function()
		exports.oCore:dxDrawRoundedRectangle(x, y, w, h, borderC, bgC, false)
	end)
end

function WelcomeUi.beginFrame(ctx)
	WelcomeUi._ctx = ctx
	WelcomeUi.hits = {}
	WelcomeUi._mx, WelcomeUi._my = nil, nil
	local mx, my = getCursorPosition()
	if mx and my and isCursorShowing() then
		WelcomeUi._mx, WelcomeUi._my = mx * ctx.sx, my * ctx.sy
	end
end

function WelcomeUi.scale(n)
	local sy = (WelcomeUi._ctx and WelcomeUi._ctx.sy) or 1080
	return n * (sy / 992)
end

function WelcomeUi.cursorIn(x, y, w, h)
	local mx, my = WelcomeUi._mx, WelcomeUi._my
	if not mx then return false end
	return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function WelcomeUi.addHit(x, y, w, h, fn)
	table.insert(WelcomeUi.hits, { x = x, y = y, w = w, h = h, fn = fn })
end

function WelcomeUi.processHits(cx, cy)
	for i = #WelcomeUi.hits, 1, -1 do
		local h = WelcomeUi.hits[i]
		if cx >= h.x and cx <= h.x + h.w and cy >= h.y and cy <= h.y + h.h then
			if h.fn then h.fn() end
			return true
		end
	end
	return false
end

function WelcomeUi.drawGlassPanel(x, y, w, h, alpha)
	alpha = alpha or 255
	local t = W_THEME
	dxDrawRectangle(x + WelcomeUi.scale(4), y + WelcomeUi.scale(6), w, h, tocolor(0, 0, 0, math.floor(alpha * 0.35)))
	rr(x, y, w, h, wTocolor(t.border, math.floor(alpha * 0.5)), wTocolor(t.card, math.floor(alpha * 0.94)))
end

function WelcomeUi.drawGhostBar(x, y, w, h, alpha, phase)
	local shimmer = math.floor(40 + 40 * math.sin((getTickCount() + phase) / 180))
	dxDrawRectangle(x, y, w, h, tocolor(shimmer, shimmer + 8, shimmer + 18, math.floor(alpha * 0.35)))
end

function WelcomeUi.drawButton(x, y, w, h, label, opts)
	opts = opts or {}
	local primary = opts.primary ~= false
	local disabled = opts.disabled
	local font = opts.font
	local fs = opts.fontScale or 1
	local hover = not disabled and WelcomeUi.cursorIn(x, y, w, h)
	local t = W_THEME
	local bg1, bg2, fg
	if disabled then
		bg1, bg2, fg = { 40, 44, 58 }, { 35, 38, 50 }, wTocolor(t.textMuted, 180)
	elseif primary then
		bg1 = hover and { 58, 110, 255 } or { 41, 98, 255 }
		bg2 = hover and { 70, 125, 255 } or { 52, 112, 255 }
		fg = tocolor(255, 255, 255, 255)
	else
		bg1 = hover and t.cardHover or t.card
		bg2 = bg1
		fg = wTocolor(t.text, 255)
	end
	if opts.ripple and opts.ripple.t then
		local age = (getTickCount() - opts.ripple.t) / 400
		if age < 1 then
			local rad = WelcomeAnim.lerp(0, math.max(w, h) * 0.6, WelcomeAnim.easeOutQuad(age))
			local a = math.floor(80 * (1 - age))
			dxDrawRectangle(x + w / 2 - rad, y + h / 2 - rad, rad * 2, rad * 2, tocolor(255, 255, 255, a))
		end
	end
	rr(x, y, w, h, wTocolor(t.border, 160), tocolor(bg1[1], bg1[2], bg1[3], 250))
	dxDrawRectangle(x + 2, y + 2, w - 4, h - 4, tocolor(bg2[1], bg2[2], bg2[3], 230))
	dxDrawText(label, x, y, x + w, y + h, fg, fs, font or "default", "center", "center", false, false, false, true)
	if not disabled and opts.onClick then
		WelcomeUi.addHit(x, y, w, h, opts.onClick)
	end
end

function WelcomeUi.drawIconClose(x, y, s, onClick)
	local hover = WelcomeUi.cursorIn(x, y, s, s)
	local t = W_THEME
	rr(x, y, s, s, wTocolor(t.border, 200), wTocolor(hover and t.cardHover or t.card, 250))
	dxDrawText("✕", x, y, x + s, y + s, wTocolor(t.text, 255), 1.05, WelcomeUi._ctx.fontTitle or "default", "center", "center", false, false, false, true)
	WelcomeUi.addHit(x, y, s, s, onClick)
end

function WelcomeUi.drawTabBar(px, py, pw, labels, activeIndex, onSelect, animUnderlineX, animUnderlineW)
	local t = W_THEME
	local n = #labels
	local th = WelcomeUi.scale(40)
	local tw = pw / n
	local top = py
	for i = 1, n do
		local tx = px + (i - 1) * tw
		local sel = (activeIndex == i)
		local hov = WelcomeUi.cursorIn(tx + 4, top, tw - 8, th)
		local bg = sel and t.cardHover or (hov and t.glass or t.card)
		rr(tx + 4, top, tw - 8, th, wTocolor(t.border, sel and 200 or 120), wTocolor(bg, sel and 230 or 180))
		dxDrawText(
			labels[i],
			tx,
			top,
			tx + tw,
			top + th,
			wTocolor(sel and t.text or t.textMuted, sel and 255 or 220),
			0.92,
			WelcomeUi._ctx.fontSmall or "default",
			"center",
			"center",
			false,
			false,
			false,
			true
		)
		WelcomeUi.addHit(tx + 4, top, tw - 8, th, function()
			onSelect(i)
		end)
	end
	local ux = animUnderlineX or (px + (activeIndex - 1) * tw + tw * 0.25)
	local uw = animUnderlineW or (tw * 0.5)
	dxDrawRectangle(ux, top + th - WelcomeUi.scale(3), uw, WelcomeUi.scale(3), wTocolor(t.accent2, 255))
end

function WelcomeUi.drawScrollBar(px, cty, pw, maxY, scroll, maxScroll, total)
	if maxScroll <= 0 then return end
	local trackH = maxY - cty
	local ratio = scroll / maxScroll
	local thumbH = math.max(WelcomeUi.scale(20), trackH * trackH / math.max(1, total))
	local thumbY = cty + ratio * math.max(0, trackH - thumbH)
	local t = W_THEME
	dxDrawRectangle(px + pw - WelcomeUi.scale(8), cty, WelcomeUi.scale(4), trackH, wTocolor(t.border, 100))
	dxDrawRectangle(px + pw - WelcomeUi.scale(8), thumbY, WelcomeUi.scale(4), thumbH, wTocolor(t.accent, 200))
end
