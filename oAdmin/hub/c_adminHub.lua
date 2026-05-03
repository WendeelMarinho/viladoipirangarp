--[[
  Painel staff (Admin Hub) — UI centralizada: economia, banco, PP, itens, veículos, moderação, tema.
  /adminhub | /painelstaff | ESC fecha · Ctrl+Tab / Ctrl+1–7 navegam abas
]]

local sx, sy = guiGetScreenSize()
local myX, myY = 1600, 900

local core = exports.oCore
local color, r, g, b = core:getServerColor()
local fontTitle, fontBody, fontTab, fontSmall

local hubOpen = false
local tabIndex = 1
local tabNames = { "Jogador", "Economia", "Premium", "Itens", "Banco", "Veículos", "Moderação" }
local snapshot = nil
local animTick = 0

local theme = "dark"
local itemCatalog = nil
local itemCatalogPage = 1
local catalogRequested = false
local catalogLastFilter = ""

local function px(n) return n / myX * sx end
local function py(n) return n / myY * sy end

local PAL = {
	dark = {
		overlay = { 0, 2, 6 },
		panelBg = { 8, 12, 22 },
		card = { 18, 22, 36 },
		cardElev = { 26, 30, 48 },
		grid = 14,
		text = { 248, 250, 255 },
		muted = { 138, 150, 172 },
		line = { 48, 55, 72 },
		positive = { 52, 168, 96 },
		danger = { 210, 72, 72 },
		warn = { 214, 168, 64 },
	},
	light = {
		overlay = { 240, 242, 248 },
		panelBg = { 252, 253, 255 },
		card = { 246, 248, 252 },
		cardElev = { 255, 255, 255 },
		grid = 10,
		text = { 22, 28, 42 },
		muted = { 78, 88, 108 },
		line = { 200, 208, 220 },
		positive = { 32, 132, 68 },
		danger = { 190, 48, 48 },
		warn = { 180, 120, 32 },
	},
}

local TAB_HINTS = {
	"Carrega inventário, duty e dados do personagem (inclui banco no snapshot).",
	"Dinheiro em mão e Casino Coin. Use «Quantidade» para +/− e «Valor exato» só em Definir.",
	"Pontos premium (nível 8). Mesma lógica de quantidade / valor exato.",
	"Defina ID, valor, quantidade e duty. Catálogo à direita: clique na linha para preencher o ID.",
	"Ajustes na conta principal do snapshot. Carregue o alvo na aba Jogador antes.",
	"/makeveh — modelo GTA. Alvo = ID jogador ou facção se «Fac» = 1. Fix/Unflip usam o mesmo alvo.",
	"Admin jail: minutos + motivo. Unjail liberta o alvo indicado.",
}

local function T(c, a)
	return tocolor(c[1], c[2], c[3], math.floor(a))
end

local function panelLayout()
	local ax, ay = px(300), py(48)
	local aw, ah = px(1000), py(780)
	local tabY = ay + py(52)
	local fieldX = ax + px(18)
	local fieldW = px(460)
	local rowH = py(32)
	local gap = py(8)
	-- Faixa de dicas termina em tabY+104; +134 dá 4 px de gap (era +118, overlapping 12 px)
	local targetEditY = tabY + py(134)
	local amountEditY = targetEditY + rowH + gap
	local itemRowY = amountEditY + rowH + gap
	local filterY = itemRowY + rowH + gap
	local jailY = filterY + rowH + gap
	local vehY = jailY + rowH + gap
	local bodyY = vehY + rowH + py(20)
	return {
		ax = ax, ay = ay, aw = aw, ah = ah,
		tabY = tabY, bodyY = bodyY,
		targetEditY = targetEditY, amountEditY = amountEditY,
		itemRowY = itemRowY, filterY = filterY, jailY = jailY, vehY = vehY,
		fieldX = fieldX, fieldW = fieldW, rowH = rowH, gap = gap,
		closeX = ax + aw - px(118), closeY = ay + ah - py(46),
		themeX = ax + aw - px(200), themeY = ay + py(10),
		listX = ax + aw - px(430), listW = px(410),
		listY = bodyY, listH = ah - (bodyY - ay) - py(70),
	}
end

local function pal()
	return PAL[theme] or PAL.dark
end

local function hubAccent(a255)
	return tocolor(r, g, b, math.min(255, math.max(0, math.floor(a255))))
end

local function drawInsetCard(x, y, w, h, p, alpha, aMul)
	aMul = aMul or 1
	local fill = math.min(255, math.floor(248 * alpha * aMul))
	local edge = math.min(255, math.floor(130 * alpha * aMul))
	dxDrawRectangle(x, y, w, h, T(p.cardElev, fill))
	dxDrawRectangle(x, y, w, 1, T(p.line, edge))
	dxDrawRectangle(x, y + h - 1, w, 1, T(p.line, math.floor(edge * 0.65)))
	dxDrawRectangle(x, y, 1, h, T(p.line, math.floor(edge * 0.78)))
	dxDrawRectangle(x + w - 1, y, 1, h, T(p.line, math.floor(edge * 0.78)))
end

local function drawTechBackground(L, ax, ay, aw, ah, alpha)
	local p = pal()
	dxDrawRectangle(ax, ay, aw, ah, T(p.panelBg, math.floor(242 * alpha)))
	local g = math.floor(p.grid * alpha)
	for gx = 0, aw, 56 do
		dxDrawLine(ax + gx, ay, ax + gx, ay + ah, tocolor(255, 255, 255, g), 1)
	end
	for gy = 0, ah, 56 do
		dxDrawLine(ax, ay + gy, ax + aw, ay + gy, tocolor(255, 255, 255, g), 1)
	end
	local pulse = (math.sin(getTickCount() / 520) + 1) * 0.5
	dxDrawRectangle(ax, ay, aw, 4, tocolor(r, g, b, math.floor((55 + 75 * pulse) * alpha)))
	dxDrawRectangle(ax, ay + 4, aw, 1, T(p.line, math.floor(200 * alpha)))
end

local function drawFieldStrip(L, alpha)
	local p = pal()
	local x = L.fieldX - px(12)
	local y = L.targetEditY - py(26)
	local w = L.listX - x - px(10)
	local h = L.vehY + L.rowH + py(10) - y
	drawInsetCard(x, y, w, h, p, alpha, 0.65)
	dxDrawText("Alvo e parâmetros", x + px(12), y + py(5), x + w, y + py(24), T(p.text, 245 * alpha), 1, fontSmall, "left", "center")
	dxDrawText("Os mesmos campos servem a todas as abas.", x + px(12), y + py(5), x + w - px(12), y + py(24), T(p.muted, 200 * alpha), 1, fontSmall, "right", "center")

	-- Row-active indicators: label to the right of the fieldW area, coloured when the current tab uses that row
	local lx = L.fieldX + L.fieldW + px(4)
	local lx2 = L.listX - px(14)
	local function rowIndicator(ry, label, active)
		local col = active and hubAccent(math.floor(210 * alpha)) or T(p.muted, math.floor(110 * alpha))
		dxDrawText(label, lx, ry + py(2), lx2, ry + L.rowH - py(2), col, 1, fontSmall, "left", "center")
		if not active then
			-- Subtle dim: draw a low-alpha fill over the row so it reads as inactive
			dxDrawRectangle(x + 2, ry - py(2), w - 4, L.rowH + py(4), T(p.panelBg, math.floor(130 * alpha)))
		end
	end
	rowIndicator(L.targetEditY,  "todas",    true)
	rowIndicator(L.amountEditY,  "2 · 3 · 5", tabIndex == 2 or tabIndex == 3 or tabIndex == 5)
	rowIndicator(L.itemRowY,     "aba 4",     tabIndex == 4)
	rowIndicator(L.filterY,      "aba 4",     tabIndex == 4)
	rowIndicator(L.jailY,        "aba 7",     tabIndex == 7)
	rowIndicator(L.vehY,         "aba 6",     tabIndex == 6)
end

local function drawTabHintBar(L, alpha)
	local p = pal()
	local hint = TAB_HINTS[tabIndex] or ""
	local x = L.ax + px(14)
	local y = L.tabY + py(72)
	local w = L.aw - px(28)
	local h = py(32)
	drawInsetCard(x, y, w, h, p, alpha, 0.5)
	dxDrawText(hint, x + px(12), y + py(2), x + w - px(12), y + h - py(2), T(p.muted, 248 * alpha), 1, fontSmall, "left", "center", true, false, false, false)
end

local function drawStatChip(x, y, w, h, label, value, p, alpha, accent)
	dxDrawRectangle(x, y, w, h, T(p.cardElev, math.floor(236 * alpha)))
	dxDrawRectangle(x, y, w, 2, accent and tocolor(accent[1], accent[2], accent[3], math.floor(200 * alpha)) or T(p.line, math.floor(155 * alpha)))
	dxDrawText(label, x + px(8), y + py(6), x + w - px(8), y + py(22), T(p.muted, 235 * alpha), 1, fontSmall, "left", "center")
	dxDrawText(value, x + px(8), y + py(20), x + w - px(8), y + h - py(4), T(p.text, 255 * alpha), 1, fontBody, "left", "center", false, false, false, true)
end

local function tabRect(L, i)
	local tw = px(86)
	local g = px(5)
	if i <= 4 then
		return L.ax + px(14) + (i - 1) * (tw + g), L.tabY, tw, py(32)
	end
	return L.ax + px(14) + (i - 5) * (tw + g), L.tabY + py(38), tw, py(32)
end

local function drawTabs(L, alpha)
	local p = pal()
	for i = 1, #tabNames do
		local tx, ty, tw, th = tabRect(L, i)
		local on = tabIndex == i
		local hover = not on and core:isInSlot(tx, ty, tw, th)
		if on then
			dxDrawRectangle(tx, ty, tw, th, hubAccent(math.floor(78 * alpha)))
			dxDrawRectangle(tx, ty + th - 3, tw, 3, hubAccent(math.floor(255 * alpha)))
			dxDrawText(tabNames[i], tx, ty, tx + tw, ty + th, T(p.text, 255 * alpha), 1, fontTab, "center", "center")
		else
			dxDrawRectangle(tx, ty, tw, th, T(p.cardElev, math.floor((hover and 210 or 168) * alpha)))
			dxDrawRectangle(tx, ty, tw, 1, T(p.line, math.floor((hover and 175 or 115) * alpha)))
			dxDrawText(tabNames[i], tx, ty, tx + tw, ty + th, T(p.muted, (hover and 255 or 218) * alpha), 1, fontTab, "center", "center")
		end
		dxDrawText(tostring(i), tx + tw - px(18), ty + py(4), tx + tw - px(4), ty + py(16), T(p.muted, math.floor(130 * alpha)), 1, fontSmall, "right", "top")
	end
end

local function getFilteredItems()
	if not itemCatalog or #itemCatalog == 0 then return {} end
	local q = string.lower(exports.oCore:getEditboxText("hub_itemsearch") or "")
	if q == "" then return itemCatalog end
	local out = {}
	for _, row in ipairs(itemCatalog) do
		local line = string.lower(tostring(row[1]) .. " " .. tostring(row[2]))
		if string.find(line, q, 1, true) then
			out[#out + 1] = row
		end
	end
	return out
end

local function catalogLayout(L)
	local fx, fy, fw, fh = L.listX, L.listY, L.listW, L.listH
	local footerH = py(50)
	local headerH = py(28)
	local rowH = py(22)
	local rows = math.max(1, math.floor((fh - headerH - footerH) / rowH))
	return fx, fy, fw, fh, rows, headerH, footerH, rowH
end

local function syncCatalogFilterPage()
	local q = exports.oCore:getEditboxText("hub_itemsearch") or ""
	if q ~= catalogLastFilter then
		catalogLastFilter = q
		itemCatalogPage = 1
	end
end

local function drawItemBrowser(L, alpha)
	local p = pal()
	local fx, fy, fw, fh, rows, headerH, footerH, rowH = catalogLayout(L)
	dxDrawRectangle(fx, fy, fw, fh, T(p.cardElev, 0.95 * alpha))
	dxDrawRectangle(fx, fy, fw, 1, T(p.line, 200 * alpha))
	dxDrawRectangle(fx, fy + fh - 1, fw, 1, T(p.line, 120 * alpha))
	dxDrawRectangle(fx, fy, 1, fh, T(p.line, 130 * alpha))
	dxDrawRectangle(fx + fw - 1, fy, 1, fh, T(p.line, 130 * alpha))
	dxDrawText("Catálogo de itens", fx + px(10), fy + py(4), fx + fw - px(10), fy + headerH, T(p.text, 250 * alpha), 1, fontSmall, "left", "center")
	dxDrawText("Clique na linha · rodinha muda página", fx + px(10), fy + py(4), fx + fw - px(10), fy + headerH, T(p.muted, 210 * alpha), 1, fontSmall, "right", "center")
	local filtered = getFilteredItems()
	local totalPages = math.max(1, math.ceil(#filtered / rows))
	if itemCatalogPage > totalPages then itemCatalogPage = totalPages end
	if itemCatalogPage < 1 then itemCatalogPage = 1 end
	local startIdx = (itemCatalogPage - 1) * rows + 1
	local y = fy + headerH + py(4)
	for i = 1, rows do
		local idx = startIdx + i - 1
		local row = filtered[idx]
		if row then
			local sel = tonumber(exports.oCore:getEditboxText("hub_itemid") or "") == row[1]
			local hoverRow = core:isInSlot(fx + 3, y - py(1), fw - 6, rowH)
			if sel then
				dxDrawRectangle(fx + 3, y - py(1), fw - 6, rowH, hubAccent(math.floor(48 * alpha)))
			elseif hoverRow then
				dxDrawRectangle(fx + 3, y - py(1), fw - 6, rowH, T(p.card, math.floor(195 * alpha)))
			end
			dxDrawText("#" .. row[1], fx + px(10), y, fx + px(52), y + rowH, T(p.muted, 255 * alpha), 1, fontSmall, "left", "center")
			dxDrawText(row[2], fx + px(56), y, fx + fw - px(10), y + rowH, T(p.text, 255 * alpha), 1, fontSmall, "left", "center", false, false, false, true)
		end
		y = y + rowH
	end
	local pyg = fy + fh - footerH + py(4)
	core:dxDrawButton(fx + px(8), pyg, px(108), py(28), 48, 56, 74, math.floor(230 * alpha), "◀ Anterior", T(p.text, 255 * alpha), 0.78, fontSmall, false, tocolor(0, 0, 0, 88))
	core:dxDrawButton(fx + fw - px(116), pyg, px(108), py(28), 48, 56, 74, math.floor(230 * alpha), "Seguinte ▶", T(p.text, 255 * alpha), 0.78, fontSmall, false, tocolor(0, 0, 0, 88))
	dxDrawText(#filtered .. " itens  ·  " .. itemCatalogPage .. " / " .. totalPages, fx + px(124), pyg, fx + fw - px(128), pyg + py(28), T(p.muted, 235 * alpha), 1, fontSmall, "center", "center")
end

local function drawSidebarPlaceholder(L, alpha)
	if tabIndex == 4 then return end
	local p = pal()
	local fx, fy, fw, fh = L.listX, L.listY, L.listW, L.listH
	drawInsetCard(fx, fy, fw, fh, p, alpha, 0.4)
	dxDrawText("Painel lateral", fx + px(12), fy + py(12), fx + fw - px(12), fy + py(36), T(p.text, 230 * alpha), 1, fontSmall, "left", "center")
	dxDrawText("Na aba Itens aparece o catálogo completo com pesquisa e paginação.", fx + px(12), fy + py(40), fx + fw - px(12), fy + fh - py(16), T(p.muted, 220 * alpha), 1, fontSmall, "left", "top", false, true)
end

local function drawPanel(alpha)
	local L = panelLayout()
	local ax, ay, aw, ah = L.ax, L.ay, L.aw, L.ah
	local p = pal()
	drawTechBackground(L, ax, ay, aw, ah, alpha)
	drawInsetCard(ax + px(2), ay + py(2), aw - px(4), ah - py(4), p, alpha, 0.85)

	dxDrawText("Painel staff", ax + px(18) + 1, ay + py(10) + 1, ax + aw, ay + py(46), tocolor(0, 0, 0, math.floor(120 * alpha)), 1, fontTitle, "left", "center")
	dxDrawText("Painel staff", ax + px(18), ay + py(10), ax + aw, ay + py(46), T(p.text, 255 * alpha), 1, fontTitle, "left", "center")
	dxDrawText("Admin Hub · tema " .. (theme == "dark" and "escuro" or "claro"), ax + px(18), ay + py(38), ax + aw, ay + py(58), T(p.muted, 235 * alpha), 1, fontBody, "left", "center")

	core:dxDrawButton(L.themeX, L.themeY, px(188), py(34), 44, 48, 64, math.floor(215 * alpha), "Tema claro / escuro", T(p.text, 255 * alpha), 0.8, fontSmall, false, tocolor(0, 0, 0, 85))

	drawTabs(L, alpha)
	drawTabHintBar(L, alpha)
	drawFieldStrip(L, alpha)

	local cx, cy = L.fieldX, L.bodyY
	local cw = L.listX - cx - px(16)

	if tabIndex == 1 then
		dxDrawText("Snapshot do personagem", cx, cy, cx + cw, cy + py(26), T(p.text, 250 * alpha), 1, fontSmall, "left", "center")
		cy = cy + py(28)
		core:dxDrawButton(cx, cy, px(188), L.rowH + py(6), r, g, b, math.floor(255 * alpha), "Carregar dados do alvo", T(p.text, 255 * alpha), 0.86, fontBody, false, tocolor(0, 0, 0, 100))
		cy = cy + L.rowH + py(52)
		if snapshot then
			drawInsetCard(cx, cy, cw, py(56), p, alpha, 0.55)
			dxDrawText("Personagem", cx + px(12), cy + py(6), cx + cw - px(12), cy + py(22), T(p.muted, 240 * alpha), 1, fontSmall, "left", "center")
			dxDrawText(color .. snapshot.name .. "#ffffff  ·  Char #" .. tostring(snapshot.charId), cx + px(12), cy + py(22), cx + cw - px(12), cy + py(50), T(p.text, 255 * alpha), 1, fontBody, "left", "center", false, false, false, true)
			cy = cy + py(62)
			local gap = px(8)
			local chipW = (cw - gap * 3) / 4
			local bh = py(52)
			drawStatChip(cx, cy, chipW, bh, "Em mão", "$" .. tostring(snapshot.money), p, alpha, p.positive)
			drawStatChip(cx + chipW + gap, cy, chipW, bh, "Casino Coin", tostring(snapshot.cc), p, alpha, p.warn)
			drawStatChip(cx + 2 * (chipW + gap), cy, chipW, bh, "Pontos prem.", tostring(snapshot.pp), p, alpha, nil)
			local bankLabel = "Banco"
			local bankVal = snapshot.bankSerial and ("$" .. tostring(snapshot.bankMoney or 0)) or "Sem conta"
			drawStatChip(cx + 3 * (chipW + gap), cy, chipW, bh, bankLabel, bankVal, p, alpha, snapshot.bankSerial and p.positive or nil)
			cy = cy + bh + py(10)
			if snapshot.bankSerial then
				dxDrawText("Conta: " .. tostring(snapshot.bankSerial), cx, cy, cx + cw, cy + py(20), T(p.muted, 210 * alpha), 1, fontSmall, "left", "center")
			end
		else
			drawInsetCard(cx, cy, cw, py(88), p, alpha, 0.45)
			dxDrawText("Nenhum dado carregado", cx + px(14), cy + py(14), cx + cw - px(14), cy + py(40), T(p.muted, 245 * alpha), 1, fontBody, "left", "top", false, true)
			dxDrawText("Preencha o alvo acima e use «Carregar dados do alvo».", cx + px(14), cy + py(44), cx + cw - px(14), cy + py(80), T(p.muted, 200 * alpha), 1, fontSmall, "left", "top", false, true)
		end
	elseif tabIndex == 2 then
		dxDrawText("Dinheiro em mão", cx, cy, cx + cw, cy + py(22), T(p.text, 245 * alpha), 1, fontSmall, "left", "center")
		cy = cy + py(26)
		core:dxDrawButton(cx, cy, px(132), L.rowH + 2, p.positive[1], p.positive[2], p.positive[3], math.floor(255 * alpha), "Dar +$", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
		core:dxDrawButton(cx + px(142), cy, px(132), L.rowH + 2, p.danger[1], p.danger[2], p.danger[3], math.floor(255 * alpha), "Retirar $", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
		core:dxDrawButton(cx + px(284), cy, px(150), L.rowH + 2, 58, 118, 210, math.floor(255 * alpha), "Definir $", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
		cy = cy + L.rowH + py(30)
		dxDrawText("Casino Coin (CC)", cx, cy, cx + cw, cy + py(22), T(p.text, 245 * alpha), 1, fontSmall, "left", "center")
		cy = cy + py(26)
		core:dxDrawButton(cx, cy, px(132), L.rowH + 2, p.positive[1], p.positive[2], p.positive[3], math.floor(255 * alpha), "Dar +CC", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
		core:dxDrawButton(cx + px(142), cy, px(132), L.rowH + 2, p.danger[1], p.danger[2], p.danger[3], math.floor(255 * alpha), "Retirar CC", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
		core:dxDrawButton(cx + px(284), cy, px(150), L.rowH + 2, 58, 118, 210, math.floor(255 * alpha), "Definir CC", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
	elseif tabIndex == 3 then
		dxDrawText("Pontos premium (nível 8)", cx, cy, cx + cw, cy + py(24), T(p.text, 245 * alpha), 1, fontSmall, "left", "center")
		cy = cy + py(28)
		core:dxDrawButton(cx, cy, px(132), L.rowH + 2, p.positive[1], p.positive[2], p.positive[3], math.floor(255 * alpha), "Dar +PP", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
		core:dxDrawButton(cx + px(142), cy, px(132), L.rowH + 2, p.danger[1], p.danger[2], p.danger[3], math.floor(255 * alpha), "Retirar PP", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
		core:dxDrawButton(cx + px(284), cy, px(150), L.rowH + 2, 58, 118, 210, math.floor(255 * alpha), "Definir PP", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
	elseif tabIndex == 4 then
		dxDrawText("Enviar item ao inventário (/giveitem)", cx, cy, cx + cw, cy + py(26), T(p.text, 245 * alpha), 1, fontSmall, "left", "center")
		cy = cy + py(32)
		core:dxDrawButton(cx, cy, px(210), L.rowH + py(8), r, g, b, math.floor(255 * alpha), "Dar item agora", T(p.text, 255 * alpha), 0.88, fontBody, false, tocolor(0, 0, 0, 110))
		drawItemBrowser(L, alpha)
	elseif tabIndex == 5 then
		dxDrawText("Conta bancária (snapshot)", cx, cy, cx + cw, cy + py(24), T(p.text, 245 * alpha), 1, fontSmall, "left", "center")
		cy = cy + py(30)
		if snapshot and snapshot.bankSerial then
			drawInsetCard(cx, cy, cw, py(48), p, alpha, 0.5)
			dxDrawText("Conta " .. tostring(snapshot.bankSerial), cx + px(12), cy + py(8), cx + cw - px(12), cy + py(26), T(p.muted, 240 * alpha), 1, fontSmall, "left", "center")
			dxDrawText("$" .. tostring(snapshot.bankMoney or 0), cx + px(12), cy + py(22), cx + cw - px(12), cy + py(44), T(p.text, 255 * alpha), 1, fontBody, "left", "center")
			cy = cy + py(56)
			core:dxDrawButton(cx, cy, px(132), L.rowH + 2, p.positive[1], p.positive[2], p.positive[3], math.floor(255 * alpha), "Banco +$", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
			core:dxDrawButton(cx + px(142), cy, px(132), L.rowH + 2, p.danger[1], p.danger[2], p.danger[3], math.floor(255 * alpha), "Banco −$", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
			core:dxDrawButton(cx + px(284), cy, px(150), L.rowH + 2, 58, 118, 210, math.floor(255 * alpha), "Definir saldo", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
		else
			drawInsetCard(cx, cy, cw, py(72), p, alpha, 0.45)
			dxDrawText("Sem conta no snapshot.", cx + px(14), cy + py(16), cx + cw - px(14), cy + py(60), T(p.muted, 235 * alpha), 1, fontBody, "left", "top", false, true)
		end
	elseif tabIndex == 6 then
		dxDrawText("Veículos (/makeveh, reparo)", cx, cy, cx + cw, cy + py(24), T(p.text, 245 * alpha), 1, fontSmall, "left", "center")
		cy = cy + py(30)
		core:dxDrawButton(cx, cy, px(148), L.rowH + 2, r, g, b, math.floor(255 * alpha), "Criar veículo", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 100))
		core:dxDrawButton(cx + px(160), cy, px(124), L.rowH + 2, 58, 118, 200, math.floor(255 * alpha), "Reparar (fix)", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
		core:dxDrawButton(cx + px(294), cy, px(124), L.rowH + 2, 58, 118, 200, math.floor(255 * alpha), "Desvirar", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 95))
	elseif tabIndex == 7 then
		dxDrawText("Prisão administrativa", cx, cy, cx + cw, cy + py(24), T(p.text, 245 * alpha), 1, fontSmall, "left", "center")
		cy = cy + py(30)
		core:dxDrawButton(cx, cy, px(148), L.rowH + py(6), p.danger[1], p.danger[2], p.danger[3], math.floor(255 * alpha), "Prender (ajail)", T(p.text, 255 * alpha), 0.85, fontBody, false, tocolor(0, 0, 0, 100))
		core:dxDrawButton(cx + px(160), cy, px(138), L.rowH + py(6), p.positive[1], p.positive[2], p.positive[3], math.floor(255 * alpha), "Soltar (unjail)", T(p.text, 255 * alpha), 0.85, fontBody, false, tocolor(0, 0, 0, 100))
	end

	drawSidebarPlaceholder(L, alpha)

	local footY = L.closeY + py(2)
	dxDrawText("Ctrl+Tab / Ctrl+Shift+Tab: abas  ·  Ctrl+1…7: ir para aba  ·  Roda: páginas (Itens)  ·  ESC: fechar", L.ax + px(16), footY, L.closeX - px(12), footY + py(28), T(p.muted, math.floor(188 * alpha)), 1, fontSmall, "left", "center", true)

	core:dxDrawButton(L.closeX, L.closeY, px(120), L.rowH + py(6), 48, 52, 68, math.floor(230 * alpha), "Fechar", T(p.text, 255 * alpha), 0.84, fontBody, false, tocolor(0, 0, 0, 92))
end

local function renderHub()
	if not hubOpen then return end
	syncCatalogFilterPage()
	local t = (getTickCount() - animTick) / 700
	local alpha = math.min(1, t)
	local p = pal()
	local dim = theme == "dark" and 175 or 125
	dxDrawRectangle(0, 0, sx, sy, tocolor(0, 0, 0, math.floor(dim * alpha)))
	drawPanel(alpha)
end

local function positionEditboxes()
	local L = panelLayout()
	local fx = L.fieldX
	exports.oCore:createEditbox(fx, L.targetEditY, L.fieldW, L.rowH, "hub_target", "ID ou nome do jogador", "text", true, { 24, 28, 40, 255 }, 0.34, 32)
	exports.oCore:createEditbox(fx, L.amountEditY, px(220), L.rowH, "hub_amount", "Quantidade (+/−)", "number", true, { 24, 28, 40, 255 }, 0.32, 12)
	exports.oCore:createEditbox(fx + px(232), L.amountEditY, px(220), L.rowH, "hub_setvalue", "Valor exato (set)", "number", true, { 24, 28, 40, 255 }, 0.32, 12)
	exports.oCore:createEditbox(fx, L.itemRowY, px(110), L.rowH, "hub_itemid", "Item ID", "number", true, { 24, 28, 40, 255 }, 0.32, 8)
	exports.oCore:createEditbox(fx + px(118), L.itemRowY, px(210), L.rowH, "hub_itemval", "Valor item", "text", true, { 24, 28, 40, 255 }, 0.32, 32)
	exports.oCore:createEditbox(fx + px(336), L.itemRowY, px(80), L.rowH, "hub_itemcount", "Qtd", "number", true, { 24, 28, 40, 255 }, 0.32, 6)
	exports.oCore:createEditbox(fx + px(424), L.itemRowY, px(56), L.rowH, "hub_duty", "0/1", "number", true, { 24, 28, 40, 255 }, 0.32, 1)
	exports.oCore:createEditbox(fx, L.filterY, L.fieldW, L.rowH, "hub_itemsearch", "Pesquisar item (nome ou ID)", "text", true, { 24, 28, 40, 255 }, 0.32, 40)
	exports.oCore:createEditbox(fx, L.jailY, px(90), L.rowH, "hub_jail_time", "Minutos", "number", true, { 24, 28, 40, 255 }, 0.32, 5)
	exports.oCore:createEditbox(fx + px(100), L.jailY, L.fieldW - px(100), L.rowH, "hub_jail_motivo", "Motivo admin jail", "text", true, { 24, 28, 40, 255 }, 0.3, 80)
	exports.oCore:createEditbox(fx, L.vehY, px(120), L.rowH, "hub_veh_model", "Modelo ID", "number", true, { 24, 28, 40, 255 }, 0.32, 5)
	exports.oCore:createEditbox(fx + px(128), L.vehY, px(64), L.rowH, "hub_veh_faction", "Fac 0/1", "number", true, { 24, 28, 40, 255 }, 0.32, 1)
	exports.oCore:createEditbox(fx + px(200), L.vehY, L.fieldW - px(200), L.rowH, "hub_veh_plate", "Placa (opcional)", "text", true, { 24, 28, 40, 255 }, 0.3, 10)
end

local function destroyHubEditboxes()
	for _, name in ipairs({
		"hub_target", "hub_amount", "hub_setvalue", "hub_itemid", "hub_itemval", "hub_itemcount", "hub_duty",
		"hub_itemsearch", "hub_jail_time", "hub_jail_motivo", "hub_veh_model", "hub_veh_faction", "hub_veh_plate",
	}) do
		pcall(function() exports.oCore:deleteEditbox(name) end)
	end
end

local function requestCatalog()
	if catalogRequested then return end
	catalogRequested = true
	triggerServerEvent("adminHub > getCatalog", resourceRoot)
end

local function openHub()
	if hubOpen then return end
	if not hasPermission(localPlayer, "adminhub") then
		exports.oInfobox:outputInfoBox("Sem permissão para abrir o painel.", "error")
		return
	end
	if (getElementData(localPlayer, "user:admin") or 0) < 2 and not getElementData(localPlayer, "aclLogin") then
		exports.oInfobox:outputInfoBox("Nível admin insuficiente.", "error")
		return
	end
	local saved = getElementData(localPlayer, "adminHub:theme")
	if saved == "light" or saved == "dark" then theme = saved end
	hubOpen = true
	animTick = getTickCount()
	itemCatalogPage = 1
	catalogLastFilter = ""
	showCursor(true)
	addEventHandler("onClientRender", root, renderHub)
	positionEditboxes()
	requestCatalog()
end

local function closeHub()
	if not hubOpen then return end
	hubOpen = false
	showCursor(false)
	removeEventHandler("onClientRender", root, renderHub)
	destroyHubEditboxes()
	snapshot = nil
	catalogRequested = false
	catalogLastFilter = ""
end

local function toggleHub()
	if hubOpen then closeHub() else openHub() end
end

local function getTargetStr()
	return exports.oCore:getEditboxText("hub_target") or ""
end

local function getAmountNum()
	return tonumber(exports.oCore:getEditboxText("hub_amount") or "") or 0
end

local function getSetNum()
	return tonumber(exports.oCore:getEditboxText("hub_setvalue") or "")
end

local function itemListClick(L, cx, cy)
	local fx, fy, fw, fh, rows, headerH, footerH, rowH = catalogLayout(L)
	local listTop = fy + headerH + py(4)
	local listBottom = fy + fh - footerH
	if not core:isInSlot(fx, listTop, fw, listBottom - listTop) then return false end
	if cy < listTop or cy > listBottom then return false end
	local relY = cy - listTop
	local row = math.floor(relY / rowH) + 1
	if row < 1 or row > rows then return false end
	local filtered = getFilteredItems()
	local startIdx = (itemCatalogPage - 1) * rows + 1
	local idx = startIdx + row - 1
	local rowd = filtered[idx]
	if rowd then
		exports.oCore:setEditboxText("hub_itemid", tostring(rowd[1]))
		return true
	end
	return false
end

local function catalogPagerClick(L)
	local fx, fy, fw, fh, rows, headerH, footerH = catalogLayout(L)
	local pyg = fy + fh - footerH + py(4)
	if core:isInSlot(fx + px(8), pyg, px(108), py(28)) then
		itemCatalogPage = math.max(1, itemCatalogPage - 1)
		return true
	end
	if core:isInSlot(fx + fw - px(116), pyg, px(108), py(28)) then
		local filtered = getFilteredItems()
		local totalPages = math.max(1, math.ceil(#filtered / rows))
		itemCatalogPage = math.min(totalPages, itemCatalogPage + 1)
		return true
	end
	return false
end

function hubClick(button, state, absoluteX, absoluteY)
	if not hubOpen or button ~= "left" or state ~= "down" then return end
	local L = panelLayout()

	if core:isInSlot(L.themeX, L.themeY, px(188), py(34)) then
		theme = (theme == "dark") and "light" or "dark"
		setElementData(localPlayer, "adminHub:theme", theme, false)
		return
	end

	for i = 1, #tabNames do
		local tx, ty, tw, th = tabRect(L, i)
		if core:isInSlot(tx, ty, tw, th) then
			tabIndex = i
			return
		end
	end

	if core:isInSlot(L.closeX, L.closeY, px(120), L.rowH + py(6)) then
		closeHub()
		return
	end

	local fieldX = L.fieldX
	if tabIndex == 4 then
		if catalogPagerClick(L) then return end
		if itemListClick(L, absoluteX, absoluteY) then return end
	end

	if tabIndex == 1 then
		local by = L.bodyY + py(28)
		if core:isInSlot(fieldX, by, px(188), L.rowH + py(6)) then
			triggerServerEvent("adminHub > snapshot", resourceRoot, getTargetStr())
		end
	elseif tabIndex == 2 then
		local tgt = getTargetStr()
		local amt = getAmountNum()
		local rowY = L.bodyY + py(26)
		if core:isInSlot(fieldX, rowY, px(132), L.rowH + 2) then
			triggerServerEvent("adminHub > giveMoney", resourceRoot, tgt, 1, amt)
		elseif core:isInSlot(fieldX + px(142), rowY, px(132), L.rowH + 2) then
			triggerServerEvent("adminHub > giveMoney", resourceRoot, tgt, 2, amt)
		elseif core:isInSlot(fieldX + px(284), rowY, px(150), L.rowH + 2) then
			local v = getSetNum()
			if v then triggerServerEvent("adminHub > setMoney", resourceRoot, tgt, v) end
		end
		rowY = rowY + L.rowH + py(30) + py(26)
		if core:isInSlot(fieldX, rowY, px(132), L.rowH + 2) then
			triggerServerEvent("adminHub > giveCC", resourceRoot, tgt, 1, amt)
		elseif core:isInSlot(fieldX + px(142), rowY, px(132), L.rowH + 2) then
			triggerServerEvent("adminHub > giveCC", resourceRoot, tgt, 2, amt)
		elseif core:isInSlot(fieldX + px(284), rowY, px(150), L.rowH + 2) then
			local v = getSetNum()
			if v then triggerServerEvent("adminHub > setCC", resourceRoot, tgt, v) end
		end
	elseif tabIndex == 3 then
		local rowY = L.bodyY + py(28)
		local tgt = getTargetStr()
		local amt = getAmountNum()
		if core:isInSlot(fieldX, rowY, px(132), L.rowH + 2) then
			triggerServerEvent("adminHub > givePP", resourceRoot, tgt, 1, amt)
		elseif core:isInSlot(fieldX + px(142), rowY, px(132), L.rowH + 2) then
			triggerServerEvent("adminHub > givePP", resourceRoot, tgt, 2, amt)
		elseif core:isInSlot(fieldX + px(284), rowY, px(150), L.rowH + 2) then
			local v = getSetNum()
			if v then triggerServerEvent("adminHub > setPP", resourceRoot, tgt, v) end
		end
	elseif tabIndex == 4 then
		local rowY = L.bodyY + py(32)
		if core:isInSlot(fieldX, rowY, px(210), L.rowH + py(8)) then
			local tgt = getTargetStr()
			local id = tonumber(exports.oCore:getEditboxText("hub_itemid") or "")
			local val = exports.oCore:getEditboxText("hub_itemval") or "1"
			local cnt = tonumber(exports.oCore:getEditboxText("hub_itemcount") or "")
			local duty = tonumber(exports.oCore:getEditboxText("hub_duty") or "0") or 0
			triggerServerEvent("adminHub > giveItem", resourceRoot, tgt, id, val, cnt, duty)
		end
	elseif tabIndex == 5 then
		if snapshot and snapshot.bankSerial then
			local rowY = L.bodyY + py(30) + py(56)
			local amt = getAmountNum()
			local ser = tostring(snapshot.bankSerial)
			if core:isInSlot(fieldX, rowY, px(132), L.rowH + 2) then
				triggerServerEvent("adminHub > bankDelta", resourceRoot, ser, amt)
			elseif core:isInSlot(fieldX + px(142), rowY, px(132), L.rowH + 2) then
				triggerServerEvent("adminHub > bankDelta", resourceRoot, ser, -amt)
			elseif core:isInSlot(fieldX + px(284), rowY, px(150), L.rowH + 2) then
				local v = getSetNum()
				if v then triggerServerEvent("adminHub > bankSet", resourceRoot, ser, v) end
			end
		end
	elseif tabIndex == 6 then
		local rowY = L.bodyY + py(30)
		local tgt = getTargetStr()
		if core:isInSlot(fieldX, rowY, px(148), L.rowH + 2) then
			local model = tonumber(exports.oCore:getEditboxText("hub_veh_model") or "")
			local fac = tonumber(exports.oCore:getEditboxText("hub_veh_faction") or "0") or 0
			local plate = exports.oCore:getEditboxText("hub_veh_plate") or ""
			triggerServerEvent("adminHub > makeveh", resourceRoot, tgt, model, fac, plate)
		elseif core:isInSlot(fieldX + px(160), rowY, px(124), L.rowH + 2) then
			triggerServerEvent("adminHub > fixveh", resourceRoot, tgt)
		elseif core:isInSlot(fieldX + px(294), rowY, px(124), L.rowH + 2) then
			triggerServerEvent("adminHub > unflip", resourceRoot, tgt)
		end
	elseif tabIndex == 7 then
		local rowY = L.bodyY + py(30)
		local tgt = getTargetStr()
		local mins = tonumber(exports.oCore:getEditboxText("hub_jail_time") or "")
		local mot = exports.oCore:getEditboxText("hub_jail_motivo") or ""
		if core:isInSlot(fieldX, rowY, px(148), L.rowH + py(6)) then
			triggerServerEvent("adminHub > ajail", resourceRoot, tgt, mins, mot)
		elseif core:isInSlot(fieldX + px(160), rowY, px(138), L.rowH + py(6)) then
			triggerServerEvent("adminHub > unjail", resourceRoot, tgt)
		end
	end
end

local function hubKey(button, press)
	if not hubOpen or not press then return end
	if button == "escape" then
		cancelEvent()
		closeHub()
		return
	end
	local ctrl = getKeyState("lctrl") or getKeyState("rctrl")
	if ctrl and button == "tab" then
		cancelEvent()
		if getKeyState("lshift") or getKeyState("rshift") then
			tabIndex = tabIndex - 1
			if tabIndex < 1 then tabIndex = #tabNames end
		else
			tabIndex = tabIndex + 1
			if tabIndex > #tabNames then tabIndex = 1 end
		end
		return
	end
	if ctrl then
		local n = tonumber(button)
		if n and n >= 1 and n <= #tabNames then
			cancelEvent()
			tabIndex = n
			return
		end
	end
	if tabIndex ~= 4 then return end
	if button ~= "mouse_wheel_up" and button ~= "mouse_wheel_down" then return end
	local L = panelLayout()
	local fx, fy, fw, fh, rows = catalogLayout(L)
	if not core:isInSlot(fx, fy, fw, fh) then return end
	local filtered = getFilteredItems()
	local totalPages = math.max(1, math.ceil(#filtered / rows))
	if button == "mouse_wheel_up" then
		itemCatalogPage = math.max(1, itemCatalogPage - 1)
	else
		itemCatalogPage = math.min(totalPages, itemCatalogPage + 1)
	end
end

addEvent("adminHub > snapshotResult", true)
addEventHandler("adminHub > snapshotResult", resourceRoot, function(ok, data)
	if ok then
		snapshot = data
		exports.oInfobox:outputInfoBox("Dados do jogador carregados.", "success")
	else
		snapshot = nil
		exports.oInfobox:outputInfoBox(tostring(data or "Erro"), "error")
	end
end)

addEvent("adminHub > actionResult", true)
addEventHandler("adminHub > actionResult", resourceRoot, function(ok, msg)
	if ok then
		exports.oInfobox:outputInfoBox(msg or "OK", "success")
	else
		exports.oInfobox:outputInfoBox(msg or "Erro", "error")
	end
end)

addEvent("adminHub > catalogResult", true)
addEventHandler("adminHub > catalogResult", resourceRoot, function(list)
	if type(list) ~= "table" then
		itemCatalog = {}
	else
		itemCatalog = list
	end
	itemCatalogPage = 1
end)

addEvent("adminHub > snapshotBank", true)
addEventHandler("adminHub > snapshotBank", resourceRoot, function(serial, newMoney)
	if not snapshot or not serial then return end
	if tostring(snapshot.bankSerial) == tostring(serial) then
		snapshot.bankMoney = tonumber(newMoney) or snapshot.bankMoney
	end
end)

local function refreshFontsAndColor()
	core = exports.oCore
	color, r, g, b = core:getServerColor()
	fontTitle = exports.oFont:getFont("bebasneue", math.max(16, math.floor(22 / myY * sy)))
	fontBody = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / myY * sy)))
	fontTab = exports.oFont:getFont("condensed", math.max(10, math.floor(11 / myY * sy)))
	fontSmall = exports.oFont:getFont("condensed", math.max(9, math.floor(10 / myY * sy)))
end

addEventHandler("onClientResourceStart", resourceRoot, refreshFontsAndColor)
addEventHandler("onClientResourceStart", root, function(res)
	if res == getResourceFromName("oCore") or res == getResourceFromName("oAdmin") then
		refreshFontsAndColor()
	end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	closeHub()
end)

addCommandHandler("adminhub", toggleHub)
addCommandHandler("painelstaff", toggleHub)

addEventHandler("onClientClick", root, hubClick)
addEventHandler("onClientKey", root, hubKey)
