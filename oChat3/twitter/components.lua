--[[ Ipiranga Tweets — primitivos DX ]]

TwUi = TwUi or {}

function TwUi.scale(sy, n)
	return n * (sy / 992)
end

function TwUi.rr(x, y, w, h, b, bg, post)
	pcall(function()
		exports.oCore:dxDrawRoundedRectangle(x, y, w, h, b, bg, post or false)
	end)
end

function TwUi.cursor(sx, sy)
	local mx, my = getCursorPosition()
	if not mx or not isCursorShowing() then return nil, nil end
	return mx * sx, my * sy
end

function TwUi.inRect(cx, cy, x, y, w, h)
	if not cx then return false end
	return cx >= x and cx <= x + w and cy >= y and cy <= y + h
end

TwUi._hits = {}

function TwUi.beginHits()
	TwUi._hits = {}
end

function TwUi.hit(x, y, w, h, fn)
	table.insert(TwUi._hits, { x = x, y = y, w = w, h = h, fn = fn })
end

function TwUi.fire(cx, cy)
	for i = #TwUi._hits, 1, -1 do
		local h = TwUi._hits[i]
		if TwUi.inRect(cx, cy, h.x, h.y, h.w, h.h) then
			if h.fn then h.fn() end
			return true
		end
	end
	return false
end

function TwUi.button(sx, sy, x, y, w, h, label, opts)
	opts = opts or {}
	local mx, my = TwUi.cursor(sx, sy)
	local hover = not opts.disabled and TwUi.inRect(mx, my, x, y, w, h)
	local t = TW_THEME
	local bg = opts.disabled and t.card or (hover and t.hover or t.card2)
	local fg = opts.disabled and twColor(t.muted, 160) or twColor(t.text, 255)
	TwUi.rr(x, y, w, h, twColor(t.border, 140), twColor(bg, 245), opts.post)
	dxDrawText(label, x, y, x + w, y + h, fg, opts.fs or 0.9, opts.font or "default", "center", "center", false, false, false, true)
	if opts.onClick and not opts.disabled then
		TwUi.hit(x, y, w, h, opts.onClick)
	end
	return hover
end
