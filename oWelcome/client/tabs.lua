--[[ oWelcome — conteúdo por aba ]]

WelcomeTabs = WelcomeTabs or {}

local function fmtNewsDate(ca)
	if not ca then
		return ""
	end
	local n = tonumber(ca)
	if n and n > 1000000000 then
		return os.date("%d/%m/%Y", n)
	end
	local s = tostring(ca)
	if #s >= 10 then
		return s:sub(1, 10)
	end
	return s
end

local function drawSectionTitle(x, y, w, text, font, t)
	dxDrawText(text, x, y, x + w, y + WelcomeUi.scale(22), wTocolor(t.accent2, 255), 0.95, font, "left", "top", false, false, false, true)
end

function WelcomeTabs.drawInicio(Welcome, px, py, pw, ph, cty, maxY)
	local t = W_THEME
	local itemH = WelcomeUi.scale(34)
	local firstLine = "Bem-vindo ao ambiente narrativo Ipiranga RP."
	for line in string.gmatch(WELCOME_ABOUT_TEXT, "[^\r\n]+") do
		firstLine = line
		break
	end
	local stats = string.format(
		"Destaque: %s   ·   Facção com mais territórios: %s",
		tostring(Welcome.payload and Welcome.payload.topPlayer or "—"),
		tostring(Welcome.payload and Welcome.payload.topFaction or "—")
	)
	local totalH = WelcomeUi.scale(36) + WelcomeUi.scale(40) + WelcomeUi.scale(26) + math.min(5, #WELCOME_SHORTCUTS) * itemH
	local viewH = maxY - cty
	local maxScroll = math.max(0, totalH - viewH)
	Welcome.scrollOffsets[1] = math.max(0, math.min(Welcome.scrollOffsets[1], maxScroll))

	local y = cty - Welcome.scrollOffsets[1]
	local function runBlock(h, drawFn)
		if y + h > cty and y < maxY then
			drawFn(y)
		end
		y = y + h
	end

	runBlock(WelcomeUi.scale(36), function(yy)
		WelcomeUi.drawGlassPanel(px + WelcomeUi.scale(12), yy, pw - WelcomeUi.scale(24), WelcomeUi.scale(36), 250)
		dxDrawText(firstLine, px + WelcomeUi.scale(22), yy + WelcomeUi.scale(6), px + pw - WelcomeUi.scale(22), yy + WelcomeUi.scale(34), wTocolor(t.textMuted, 240), 0.88, Welcome.fontSmall, "left", "top", false, true, false, true)
	end)
	runBlock(WelcomeUi.scale(40), function(yy)
		WelcomeUi.drawGlassPanel(px + WelcomeUi.scale(12), yy, pw - WelcomeUi.scale(24), WelcomeUi.scale(40), 250)
		dxDrawText(stats, px + WelcomeUi.scale(18), yy + WelcomeUi.scale(8), px + pw - WelcomeUi.scale(18), yy + WelcomeUi.scale(38), wTocolor(t.textMuted, 235), 0.82, Welcome.fontSmall, "left", "top", false, true, false, true)
	end)

	if y + WelcomeUi.scale(22) > cty and y < maxY then
		drawSectionTitle(px + WelcomeUi.scale(12), y, pw, "Atalhos rápidos", Welcome.fontSmall, t)
	end
	y = y + WelcomeUi.scale(26)
	for i = 1, math.min(5, #WELCOME_SHORTCUTS) do
		local row = WELCOME_SHORTCUTS[i]
		local yy = y
		if yy + itemH > cty and yy < maxY then
			WelcomeUi.drawGlassPanel(px + WelcomeUi.scale(12), yy, pw - WelcomeUi.scale(24), itemH - WelcomeUi.scale(4), 230)
			dxDrawText(row[1], px + WelcomeUi.scale(22), yy + WelcomeUi.scale(4), px + WelcomeUi.scale(72), yy + itemH, wTocolor(t.accent, 255), 0.9, Welcome.fontMain, "left", "center", false, false, false, true)
			dxDrawText(row[2], px + WelcomeUi.scale(82), yy + WelcomeUi.scale(4), px + pw - WelcomeUi.scale(18), yy + itemH, wTocolor(t.text, 245), 0.86, Welcome.fontSmall, "left", "center", false, true, false, true)
		end
		y = y + itemH
	end

	WelcomeUi.drawScrollBar(px, cty, pw, maxY, Welcome.scrollOffsets[1], maxScroll, totalH)
end

local function truncBody(s, maxLen)
	if not s then return "" end
	if utf8 and utf8.len and utf8.sub then
		if utf8.len(s) <= maxLen then return s end
		return utf8.sub(s, 1, maxLen) .. "…"
	end
	if #s <= maxLen then return s end
	return s:sub(1, maxLen) .. "…"
end

function WelcomeTabs.drawNoticias(Welcome, px, py, pw, ph, cty, maxY)
	local t = W_THEME
	local news = (Welcome.payload and Welcome.payload.news) or {}
	local cardPad = WelcomeUi.scale(12)
	local cardGap = WelcomeUi.scale(10)
	local totalH = 0
	local cards = {}
	for _, n in ipairs(news) do
		local nid = tonumber(n.id) or 0
		local expanded = Welcome.expandedNewsId == nid
		local title = tostring(n.title or "?")
		local body = tostring(n.body or "")
		local shortLen = 100
		local showBody = expanded and body or truncBody(body, shortLen)
		local author = tostring(n.created_by or "Staff")
		local when = fmtNewsDate(n.created_at)
		local ch = WelcomeUi.scale(52) + (expanded and WelcomeUi.scale(120) or WelcomeUi.scale(40))
		totalH = totalH + ch + cardGap
		table.insert(cards, { nid = nid, title = title, body = showBody, full = body, author = author, when = when, expanded = expanded, ch = ch })
	end
	if #news == 0 then
		totalH = WelcomeUi.scale(80)
	end

	local viewH = maxY - cty
	local maxScroll = math.max(0, totalH - viewH)
	Welcome.scrollOffsets[2] = math.max(0, math.min(Welcome.scrollOffsets[2], maxScroll))
	local y = cty - Welcome.scrollOffsets[2]

	if #news == 0 then
		if y + WelcomeUi.scale(80) > cty and y < maxY then
			WelcomeUi.drawGlassPanel(px + cardPad, y, pw - cardPad * 2, WelcomeUi.scale(72), 240)
			dxDrawText("Sem notícias publicadas.", px + WelcomeUi.scale(28), y + WelcomeUi.scale(22), px + pw - WelcomeUi.scale(28), y + WelcomeUi.scale(60), wTocolor(t.textMuted, 220), 0.92, Welcome.fontMain, "left", "top", false, true, false, true)
		end
	else
		for _, c in ipairs(cards) do
			local yy = y
			if yy + c.ch > cty and yy < maxY then
				WelcomeUi.drawGlassPanel(px + cardPad, yy, pw - cardPad * 2, c.ch - WelcomeUi.scale(4), 245)
				dxDrawText(c.title, px + WelcomeUi.scale(24), yy + WelcomeUi.scale(8), px + pw - WelcomeUi.scale(24), yy + WelcomeUi.scale(28), wTocolor(t.text, 255), 0.95, Welcome.fontMain, "left", "top", false, true, false, true)
				dxDrawText(c.author .. "  ·  " .. c.when, px + WelcomeUi.scale(24), yy + WelcomeUi.scale(28), px + pw - WelcomeUi.scale(24), yy + WelcomeUi.scale(44), wTocolor(t.textMuted, 220), 0.78, Welcome.fontSmall, "left", "top", false, false, false, true)
				dxDrawText(c.body, px + WelcomeUi.scale(24), yy + WelcomeUi.scale(44), px + pw - WelcomeUi.scale(24), yy + c.ch - WelcomeUi.scale(14), wTocolor(t.textMuted, 235), 0.86, Welcome.fontSmall, "left", "top", false, true, false, true)
				local btnW, btnH = WelcomeUi.scale(88), WelcomeUi.scale(24)
				local bx = px + pw - cardPad - btnW - WelcomeUi.scale(14)
				local by = yy + c.ch - WelcomeUi.scale(32)
				local lbl = c.expanded and "Recolher" or "Ler mais"
				WelcomeUi.drawButton(bx, by, btnW, btnH, lbl, {
					primary = false,
					font = Welcome.fontSmall,
					fontScale = 0.82,
					onClick = function()
						if Welcome.expandedNewsId == c.nid then
							Welcome.expandedNewsId = nil
						else
							Welcome.expandedNewsId = c.nid
						end
					end,
				})
			end
			y = y + c.ch + cardGap
		end
	end

	WelcomeUi.drawScrollBar(px, cty, pw, maxY, Welcome.scrollOffsets[2], maxScroll, totalH)
end

function WelcomeTabs.drawNovidades(Welcome, px, py, pw, ph, cty, maxY)
	local t = W_THEME
	local itemH = WelcomeUi.scale(32)
	local totalH = WelcomeUi.scale(28) + #WELCOME_SHORTCUTS * itemH + WelcomeUi.scale(34) + #WELCOME_COMMANDS * itemH

	local viewH = maxY - cty
	local maxScroll = math.max(0, totalH - viewH)
	Welcome.scrollOffsets[3] = math.max(0, math.min(Welcome.scrollOffsets[3], maxScroll))
	local y = cty - Welcome.scrollOffsets[3]

	if y + WelcomeUi.scale(22) > cty and y < maxY then
		drawSectionTitle(px + WelcomeUi.scale(12), y, pw, "Atalhos", Welcome.fontSmall, t)
	end
	y = y + WelcomeUi.scale(26)
	for _, row in ipairs(WELCOME_SHORTCUTS) do
		local yy = y
		if yy + itemH > cty and yy < maxY then
			WelcomeUi.drawGlassPanel(px + WelcomeUi.scale(12), yy, pw - WelcomeUi.scale(24), itemH - WelcomeUi.scale(4), 220)
			dxDrawText(row[1], px + WelcomeUi.scale(20), yy, px + WelcomeUi.scale(76), yy + itemH, wTocolor(t.accent, 255), 0.88, Welcome.fontMain, "left", "center", false, false, false, true)
			dxDrawText(row[2], px + WelcomeUi.scale(84), yy, px + pw - WelcomeUi.scale(16), yy + itemH, wTocolor(t.textMuted, 240), 0.82, Welcome.fontSmall, "left", "center", false, true, false, true)
		end
		y = y + itemH
	end

	if y + WelcomeUi.scale(22) > cty and y < maxY then
		drawSectionTitle(px + WelcomeUi.scale(12), y, pw, "Comandos", Welcome.fontSmall, t)
	end
	y = y + WelcomeUi.scale(26)
	for _, row in ipairs(WELCOME_COMMANDS) do
		local yy = y
		if yy + itemH > cty and yy < maxY then
			WelcomeUi.drawGlassPanel(px + WelcomeUi.scale(12), yy, pw - WelcomeUi.scale(24), itemH - WelcomeUi.scale(4), 220)
			dxDrawText(row[1], px + WelcomeUi.scale(18), yy, px + WelcomeUi.scale(118), yy + itemH, wTocolor(t.success, 240), 0.82, Welcome.fontSmall, "left", "center", false, false, false, true)
			dxDrawText(row[2], px + WelcomeUi.scale(124), yy, px + pw - WelcomeUi.scale(16), yy + itemH, wTocolor(t.textMuted, 235), 0.82, Welcome.fontSmall, "left", "center", false, true, false, true)
		end
		y = y + itemH
	end

	WelcomeUi.drawScrollBar(px, cty, pw, maxY, Welcome.scrollOffsets[3], maxScroll, totalH)
end

function WelcomeTabs.drawAjuda(Welcome, px, py, pw, ph, cty, maxY)
	local t = W_THEME
	local lineH = WelcomeUi.scale(15)
	local totalH = 0
	for _ in string.gmatch(WELCOME_ABOUT_TEXT, "[^\r\n]+") do
		totalH = totalH + lineH
	end
	totalH = totalH + WelcomeUi.scale(20)
	local bw = pw - WelcomeUi.scale(28)
	local bh = WelcomeUi.scale(34)
	local gap = WelcomeUi.scale(8)
	totalH = totalH + #WELCOME_SOCIAL_LINKS * (bh + gap)

	local viewH = maxY - cty
	local maxScroll = math.max(0, totalH - viewH)
	Welcome.scrollOffsets[4] = math.max(0, math.min(Welcome.scrollOffsets[4], maxScroll))
	local y = cty - Welcome.scrollOffsets[4]

	for line in string.gmatch(WELCOME_ABOUT_TEXT, "[^\r\n]+") do
		local yy = y
		if yy + lineH > cty and yy < maxY then
			dxDrawText(line, px + WelcomeUi.scale(18), yy, px + pw - WelcomeUi.scale(18), yy + lineH, wTocolor(t.textMuted, 245), 0.86, Welcome.fontSmall, "left", "top", false, true, false, true)
		end
		y = y + lineH
	end

	y = y + WelcomeUi.scale(12)
	if y + WelcomeUi.scale(22) > cty and y < maxY then
		drawSectionTitle(px + WelcomeUi.scale(12), y, pw, "Redes & links", Welcome.fontSmall, t)
	end
	y = y + WelcomeUi.scale(26)

	for _, s in ipairs(WELCOME_SOCIAL_LINKS) do
		local yy = y
		if yy + bh > cty and yy < maxY then
			local bx = px + WelcomeUi.scale(14)
			local hover = WelcomeUi.cursorIn(bx, yy, bw, bh)
			dxDrawRectangle(bx, yy, bw, bh, tocolor(s.r, s.g, s.b, hover and 240 or 200))
			dxDrawText(s.name .. "  ·  copiar", bx, yy, bx + bw, yy + bh, tocolor(255, 255, 255, 255), 0.9, Welcome.fontMain, "center", "center", false, false, false, true)
			WelcomeUi.addHit(bx, yy, bw, bh, function()
				setClipboard(s.url)
				exports.oInfobox:outputInfoBox("Link " .. s.name .. " copiado.", "success")
			end)
		end
		y = y + bh + gap
	end

	WelcomeUi.drawScrollBar(px, cty, pw, maxY, Welcome.scrollOffsets[4], maxScroll, totalH)
end

function WelcomeTabs.draw(Welcome, px, py, pw, ph, cty, maxY)
	if Welcome.activeTab == 1 then
		WelcomeTabs.drawInicio(Welcome, px, py, pw, ph, cty, maxY)
	elseif Welcome.activeTab == 2 then
		WelcomeTabs.drawNoticias(Welcome, px, py, pw, ph, cty, maxY)
	elseif Welcome.activeTab == 3 then
		WelcomeTabs.drawNovidades(Welcome, px, py, pw, ph, cty, maxY)
	else
		WelcomeTabs.drawAjuda(Welcome, px, py, pw, ph, cty, maxY)
	end
end
