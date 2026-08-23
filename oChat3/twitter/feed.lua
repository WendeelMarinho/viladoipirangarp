--[[ Ipiranga Tweets — feed lateral estilo X ]]

TwFeed = TwFeed or {
	visible = false,
	posts = {},
	scroll = 0,
	scrollTarget = 0,
	openTick = 0,
	likeBurst = {},
	_visUsed = TWITTER_FEED_VISIBLE_LINES,
}

local function colorizeHashtags(text)
	if not text then return "" end
	local base = "#FFFFFF"
	local out = text:gsub("#(%w+)", function(w)
		local hex = HASHTAG_COLORS[string.upper(w)]
		if hex then return hex .. "#" .. w .. base end
		return "#aaaaaa#" .. w .. base
	end)
	return base .. out
end

local function relTime(ts)
	if ts == nil then return "" end
	ts = tonumber(ts) or tonumber(tostring(ts)) or 0
	if ts <= 0 then return "" end
	local now = os.time()
	local d = math.max(0, now - ts)
	if d < 45 then return "agora" end
	if d < 3600 then return math.floor(d / 60) .. " min" end
	if d < 86400 then return math.floor(d / 3600) .. " h" end
	if d < 604800 then return math.floor(d / 86400) .. " d" end
	return os.date("%d/%m/%y", ts)
end

local function initials(name)
	name = tostring(name or "?"):gsub("%s+", "")
	if #name < 2 then return (name .. "?"):sub(1, 2) end
	return name:sub(1, 1) .. name:sub(2, 2)
end

local function hexToRgb(h)
	h = tostring(h or "#ffffff"):gsub("#", "")
	if #h < 6 then return 200, 200, 200 end
	return tonumber(h:sub(1, 2), 16) or 200, tonumber(h:sub(3, 4), 16) or 200, tonumber(h:sub(5, 6), 16) or 200
end

function TwFeed.setPosts(rows)
	TwFeed.posts = type(rows) == "table" and rows or {}
	local vis = TwFeed._visUsed or TWITTER_FEED_VISIBLE_LINES
	local maxS = math.max(0, #TwFeed.posts - vis)
	if TwFeed.scroll > maxS then TwFeed.scroll = maxS end
	if TwFeed.scrollTarget > maxS then TwFeed.scrollTarget = maxS end
end

function TwFeed.toggle()
	TwFeed.visible = not TwFeed.visible
	if TwFeed.visible then
		TwFeed.openTick = getTickCount()
	end
end

function TwFeed.close()
	TwFeed.visible = false
	if not TwComposer.visible then
		guiSetInputEnabled(false)
		showCursor(false)
	end
end

function TwFeed.layout(sx, sy)
	local fw = math.min(sx * 0.30, 420)
	local fh = sy * 0.62
	local fx = sx - fw - TwUi.scale(sy, 16)
	local fy = TwUi.scale(sy, 36)
	return fx, fy, fw, fh
end

function TwFeed.draw(sx, sy, font)
	if not TwFeed.visible then return end
	local fx, fy, fw, fh = TwFeed.layout(sx, sy)
	local t = TW_THEME
	local ease = TwAnim.easeOut(math.min(1, (getTickCount() - (TwFeed.openTick or 0)) / 200))
	local al = math.floor(230 * ease)

	TwFeed.scroll = TwFeed.scroll + (TwFeed.scrollTarget - TwFeed.scroll) * math.min(1, 0.22)

	dxDrawRectangle(fx + 4, fy + 6, fw, fh, tocolor(0, 0, 0, math.floor(70 * ease)), false)
	TwUi.rr(fx, fy, fw, fh, twColor(t.border, 180), twColor(t.card, math.min(250, al + 30)), false)

	dxDrawRectangle(fx + 2, fy + 2, fw - 4, TwUi.scale(sy, 44), twColor(t.card2, 245))
	dxDrawText("Ipiranga Tweets", fx + TwUi.scale(sy, 12), fy + 4, fx + fw - TwUi.scale(sy, 52), fy + TwUi.scale(sy, 44), twColor(t.text, 255), 0.95, font, "left", "center", false, false, false, true)

	local bx = fx + fw - TwUi.scale(sy, 42)
	local by = fy + TwUi.scale(sy, 8)
	local bs = TwUi.scale(sy, 30)
	local mx, my = TwUi.cursor(sx, sy)
	local hovX = TwUi.inRect(mx, my, bx, by, bs, bs)
	dxDrawRectangle(bx, by, bs, bs, twColor(hovX and t.hover or t.card, 230))
	dxDrawText("✕", bx, by, bx + bs, by + bs, twColor(t.text, 255), 0.95, font, "center", "center", false, false, false, true)
	TwUi.hit(bx, by, bs, bs, function()
		TwFeed.close()
	end)

	local nbY = fy + TwUi.scale(sy, 48)
	local nbH = TwUi.scale(sy, 36)
	local nbHover = TwUi.inRect(mx, my, fx + TwUi.scale(sy, 10), nbY, fw - TwUi.scale(sy, 20), nbH)
	TwUi.rr(fx + TwUi.scale(sy, 10), nbY, fw - TwUi.scale(sy, 20), nbH, twColor(t.border, 120), twColor(nbHover and t.hover or t.card2, 220), false)
	dxDrawText("+ Novo tweet", fx + TwUi.scale(sy, 10), nbY, fx + fw - TwUi.scale(sy, 10), nbY + nbH, twColor(t.accent, 255), 0.88, font, "center", "center", false, false, false, true)
	TwUi.hit(fx + TwUi.scale(sy, 10), nbY, fw - TwUi.scale(sy, 20), nbH, function()
		if TwComposer.open(sx, sy) then end
	end)

	local row0 = nbY + nbH + TwUi.scale(sy, 6)
	local lineH = TwUi.scale(sy, 76)
	local availH = fy + fh - row0 - TwUi.scale(sy, 26)
	local vis = math.max(3, math.min(TWITTER_FEED_VISIBLE_LINES, math.floor(availH / lineH)))
	local maxS = math.max(0, #TwFeed.posts - vis)
	TwFeed.scrollTarget = math.max(0, math.min(TwFeed.scrollTarget, maxS))
	TwFeed.scroll = math.max(0, math.min(TwFeed.scroll, maxS))
	TwFeed._visUsed = vis

	local first = math.floor(TwFeed.scroll + 0.5) + 1
	local last = math.min(#TwFeed.posts, first + vis - 1)

	if #TwFeed.posts == 0 then
		dxDrawText("Sem publicações.", fx + 16, row0 + 20, fx + fw - 16, fy + fh - 20, twColor(t.muted, 200), 0.88, font, "center", "top", false, true, false, true)
	end

	for idx = first, last do
		local row = TwFeed.posts[idx]
		if row then
			local ry = row0 + (idx - first) * lineH
			local pin = tonumber(row.is_pinned) == 1
			local cardA = pin and 255 or 235
			TwUi.rr(fx + 8, ry, fw - 16, lineH - 6, twColor(t.border, 100), twColor(pin and t.card2 or t.card, cardA), false)

			local av = TwUi.scale(sy, 40)
			local ax = fx + 16
			local ay = ry + 8
			local tr, tg, tb = hexToRgb(row.faction_color)
			dxDrawRectangle(ax, ay, av, av, tocolor(tr, tg, tb, 220))
			dxDrawText(initials(row.char_name), ax, ay, ax + av, ay + av, tocolor(0, 0, 0, 255), 0.75, font, "center", "center", false, false, false, true)

			local tx = ax + av + 10
			local pinTxt = pin and "[FIX] " or ""
			dxDrawText(pinTxt .. (row.char_name or "?"), tx, ry + 8, fx + fw - 60, ry + 28, twColor(t.text, 255), 0.9, font, "left", "top", false, false, false, true)
			local tag = tostring(row.faction_tag or "")
			dxDrawText(tag .. " · " .. relTime(row.ts), tx, ry + 26, fx + fw - 60, ry + 44, twColor(t.muted, 210), 0.75, font, "left", "top", false, false, false, true)

			local body = colorizeHashtags(row.content or "")
			dxDrawText(body, tx, ry + 44, fx + fw - 56, ry + lineH - 14, twColor(t.text, 250), 0.82, font, "left", "top", true, true, false, true)

			local hxX = fx + fw - 52
			local hxY = ry + lineH - 30
			local hxW, hxH = 44, 22
			local burst = TwFeed.likeBurst[tonumber(row.id) or 0]
			local pulse = 1
			if burst then
				local ag = (getTickCount() - burst) / 320
				if ag < 1 then pulse = 1 + 0.12 * math.sin(ag * math.pi) end
			end
			local likes = tonumber(row.likes) or 0
			dxDrawText("♥ " .. tostring(likes), hxX - 4, hxY - 2, hxX + hxW + 4, hxY + hxH + 2, twColor(t.like, math.floor(220 * pulse)), 0.82, font, "center", "center", false, false, false, true)
			TwUi.hit(hxX, hxY, hxW, hxH, function()
				TwFeed.likeBurst[tonumber(row.id) or 0] = getTickCount()
				triggerServerEvent("oChat3 > twitterLike", resourceRoot, tonumber(row.id))
			end)
		end
	end

	dxDrawText("Esc · Backspace · /twitter", fx + 10, fy + fh - TwUi.scale(sy, 22), fx + fw - 10, fy + fh - 4, twColor(t.muted, 160), 0.7, font, "center", "bottom", false, true, false, true)
end
