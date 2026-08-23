--[[ oRank — cliente (/rank) ]]

local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992

local fonts = exports.oFont
local fontTitle, fontCat, fontRow, fontSmall

local rankOpen = false
local myStatsOpen = false
local lbCache = {}
local seasonNum = 1
local myStatsRows = {}
local selIdx = 1

local function scale(n)
	return n * (sy / myY)
end

local function ensureFonts()
	if not fontTitle then fontTitle = fonts:getFont("bebasneue", math.max(20, math.floor(scale(28)))) end
	if not fontCat then fontCat = fonts:getFont("condensed", math.max(12, math.floor(scale(15)))) end
	if not fontRow then fontRow = fonts:getFont("condensed", math.max(11, math.floor(scale(14)))) end
	if not fontSmall then fontSmall = fonts:getFont("condensed", math.max(10, math.floor(scale(12)))) end
end

local function closeAll()
	rankOpen = false
	myStatsOpen = false
	lbCache = {}
	myStatsRows = {}
	showCursor(false)
end

local function fmtName(n)
	return (tostring(n or "?")):gsub("_", " ")
end

addEvent("oRank > open", true)
addEventHandler("oRank > open", resourceRoot, function(cache, season)
	lbCache = cache or {}
	seasonNum = tonumber(season) or 1
	selIdx = 1
	rankOpen = true
	myStatsOpen = false
	showCursor(true)
	ensureFonts()
end)

addEvent("oRank > myStatsResult", true)
addEventHandler("oRank > myStatsResult", resourceRoot, function(rows)
	myStatsRows = rows or {}
	myStatsOpen = true
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	ensureFonts()
	bindKey("backspace", "down", function()
		if myStatsOpen then myStatsOpen = false return end
		if rankOpen then closeAll() end
	end)
end)

local function catHitboxes(px, py, pw, ph)
	local hits = {}
	local ly = py + scale(56)
	local lh = scale(36)
	for i, cat in ipairs(RANK_CATEGORIES) do
		table.insert(hits, { idx = i, x = px + scale(10), y = ly, w = pw - scale(20), h = lh })
		ly = ly + lh + scale(4)
	end
	return hits
end

local function podiumColor(pos)
	if pos == 1 then return tocolor(255, 215, 0, 230) end
	if pos == 2 then return tocolor(192, 192, 192, 220) end
	if pos == 3 then return tocolor(205, 127, 50, 220) end
	return tocolor(55, 55, 70, 200)
end

addEventHandler("onClientRender", root, function()
	if not rankOpen then return end
	ensureFonts()

	local px = sx * 0.05
	local py = sy * 0.06
	local pw = sx * 0.9
	local ph = sy * 0.88

	dxDrawRectangle(0, 0, sx, sy, tocolor(0, 0, 0, 170))
	dxDrawRectangle(px, py, pw, ph, tocolor(18, 18, 24, 245))

	dxDrawText("Ranking do servidor — época " .. tostring(seasonNum), px + scale(16), py + scale(10), px + pw, py + scale(44), tocolor(240, 240, 240, 255), 1, fontTitle, "left", "center")

	local split = pw * 0.28
	local lx = px + scale(12)
	local ly = py + scale(52)
	local lw = split - scale(24)
	local rx = px + split + scale(10)
	local rw = pw - split - scale(28)

	dxDrawRectangle(lx, ly, lw, ph - scale(110), tocolor(28, 28, 36, 240))

	for i, cat in ipairs(RANK_CATEGORIES) do
		local cy = ly + scale(8) + (i - 1) * (scale(36) + scale(4))
		local sel = (selIdx == i)
		dxDrawRectangle(lx + scale(6), cy, lw - scale(12), scale(36), tocolor(45, 50, 65, sel and 255 or 180))
		dxDrawText(cat.label, lx + scale(12), cy, lx + lw - scale(12), cy + scale(36), tocolor(235, 235, 235, 255), 1, fontCat, "left", "center")
	end

	local cat = RANK_CATEGORIES[selIdx]
	local block = cat and lbCache[cat.id]
	local rows = (block and block.rows) or {}

	dxDrawText(block and block.label or "—", rx, ly + scale(6), rx + rw, ly + scale(34), tocolor(220, 230, 255, 255), 1, fontCat, "left", "top")

	local podiumY = ly + scale(42)
	local podiumW = (rw - scale(24)) / 3
	for pos = 1, 3 do
		local row = rows[pos]
		local bx = rx + (pos - 1) * (podiumW + scale(8))
		local bh = scale(pos == 1 and 72 or (pos == 2 and 58 or 50))
		local byPod = podiumY + scale(78 - pos * 6)
		dxDrawRectangle(bx, byPod, podiumW - scale(4), bh, podiumColor(pos))
		local label = row and fmtName(row.charname) or "—"
		local fac = row and row.isFaction
		if fac then label = label .. " (fac.)" end
		local val = row and tostring(row.value or 0) or "—"
		dxDrawText("#" .. pos, bx, byPod + scale(6), bx + podiumW, byPod + scale(26), tocolor(30, 30, 30, 255), 1, fontTitle, "center", "top")
		dxDrawText(label, bx + scale(4), byPod + scale(28), bx + podiumW - scale(8), byPod + bh - scale(6), tocolor(25, 25, 30, 255), 0.85, fontSmall, "center", "center", false, true, false, true)
		dxDrawText(val, bx + scale(4), byPod + bh - scale(22), bx + podiumW - scale(8), byPod + bh - scale(4), tocolor(35, 35, 40, 255), 0.8, fontSmall, "center", "center")
	end

	local listY = podiumY + scale(92)
	for i = 4, math.min(#rows, RANK_TOP_N) do
		local row = rows[i]
		dxDrawRectangle(rx, listY, rw - scale(8), scale(30), tocolor(35, 38, 48, 220))
		local nm = fmtName(row.charname)
		if row.isFaction then nm = nm .. " (fac.)" end
		dxDrawText(i .. "  " .. nm, rx + scale(10), listY, rx + rw * 0.72, listY + scale(30), tocolor(210, 210, 215, 255), 0.95, fontRow, "left", "center")
		dxDrawText(tostring(row.value or 0), rx + rw * 0.72, listY, rx + rw - scale(14), listY + scale(30), tocolor(180, 200, 255, 255), 0.95, fontRow, "right", "center")
		listY = listY + scale(32)
		if listY > py + ph - scale(120) then break end
	end

	local btnW, btnH = scale(160), scale(36)
	local btnY = py + ph - btnH - scale(14)
	local btnMy = px + pw - btnW * 2 - scale(24)
	local btnClose = px + pw - btnW - scale(14)

	dxDrawRectangle(btnMy, btnY, btnW, btnH, tocolor(70, 110, 170, 230))
	dxDrawText("Minhas stats", btnMy, btnY, btnMy + btnW, btnY + btnH, tocolor(255, 255, 255, 255), 1, fontCat, "center", "center")

	dxDrawRectangle(btnClose, btnY, btnW, btnH, tocolor(90, 70, 70, 230))
	dxDrawText("Fechar", btnClose, btnY, btnClose + btnW, btnY + btnH, tocolor(255, 255, 255, 255), 1, fontCat, "center", "center")

	dxDrawText("Top 3 ganham badge temporário no nametag (renovável a cada ciclo do ranking).", px + scale(16), btnY - scale(26), px + pw - scale(16), btnY, tocolor(160, 165, 185, 230), 0.85, fontSmall, "left", "bottom", false, true, false, true)

	if myStatsOpen then
		local mx = sx * 0.25
		local my = sy * 0.22
		local mw = sx * 0.5
		local mh = sy * 0.56
		dxDrawRectangle(mx, my, mw, mh, tocolor(12, 14, 20, 250))
		dxDrawRectangle(mx, my, mw, scale(40), tocolor(40, 55, 85, 255))
		dxDrawText("As tuas estatísticas", mx + scale(12), my, mx + mw, my + scale(40), tocolor(255, 255, 255, 255), 1, fontTitle, "left", "center")

		local y = my + scale(48)
		for _, line in ipairs(myStatsRows) do
			local txt
			if line.type == "stat" then
				txt = string.format("%s — valor: %s  |  posição estimada: #%s", line.category, tostring(line.value), tostring(line.rank))
			else
				txt = string.format("%s — %s", line.category, line.note or "")
			end
			dxDrawText(txt, mx + scale(14), y, mx + mw - scale(14), y + scale(40), tocolor(205, 208, 220, 255), 0.9, fontSmall, "left", "top", false, true, false, true)
			y = y + scale(38)
			if y > my + mh - scale(50) then break end
		end

		local bx = mx + (mw - btnW) / 2
		local by = my + mh - btnH - scale(12)
		dxDrawRectangle(bx, by, btnW, btnH, tocolor(80, 120, 80, 235))
		dxDrawText("OK", bx, by, bx + btnW, by + btnH, tocolor(255, 255, 255, 255), 1, fontCat, "center", "center")
	end
end)

addEventHandler("onClientClick", root, function(btn, st, mcx, mcy)
	if not rankOpen or btn ~= "left" or st ~= "down" then return end

	local px = sx * 0.05
	local py = sy * 0.06
	local pw = sx * 0.9
	local ph = sy * 0.88
	local split = pw * 0.28
	local lx = px + scale(12)
	local ly = py + scale(52)
	local lw = split - scale(24)

	for i in ipairs(RANK_CATEGORIES) do
		local rowTop = ly + scale(8) + (i - 1) * (scale(36) + scale(4))
		if mcx >= lx + scale(6) and mcx <= lx + lw - scale(6) and mcy >= rowTop and mcy <= rowTop + scale(36) then
			selIdx = i
			return
		end
	end

	local btnW, btnH = scale(160), scale(36)
	local btnY = py + ph - btnH - scale(14)
	local btnMy = px + pw - btnW * 2 - scale(24)
	local btnClose = px + pw - btnW - scale(14)

	if mcx >= btnClose and mcx <= btnClose + btnW and mcy >= btnY and mcy <= btnY + btnH then
		closeAll()
		return
	end

	if mcx >= btnMy and mcx <= btnMy + btnW and mcy >= btnY and mcy <= btnY + btnH then
		triggerServerEvent("oRank > refreshMyStats", resourceRoot)
		return
	end

	if myStatsOpen then
		local mx = sx * 0.25
		local my = sy * 0.22
		local mw = sx * 0.5
		local mh = sy * 0.56
		local bx = mx + (mw - btnW) / 2
		local by = my + mh - btnH - scale(12)
		if mcx >= bx and mcx <= bx + btnW and mcy >= by and mcy <= by + btnH then
			myStatsOpen = false
		end
	end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	if rankOpen then closeAll() end
end)
