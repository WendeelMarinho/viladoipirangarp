--[[ Admin Hub v2 — tema + primitivas DX (client) ]]

local PALETTES = {
	dark = {
		overlay = { 0, 2, 6 },
		panelBg = { 8, 12, 22 },
		card = { 18, 22, 36 },
		cardElev = { 26, 30, 48 },
		grid = 12,
		text = { 248, 250, 255 },
		muted = { 138, 150, 172 },
		line = { 48, 55, 72 },
		positive = { 52, 168, 96 },
		danger = { 210, 72, 72 },
		warn = { 214, 168, 64 },
		purple = { 130, 90, 220 },
		sidebar = { 12, 16, 28 },
	},
	light = {
		overlay = { 240, 242, 248 },
		panelBg = { 252, 253, 255 },
		card = { 246, 248, 252 },
		cardElev = { 255, 255, 255 },
		grid = 8,
		text = { 22, 28, 42 },
		muted = { 78, 88, 108 },
		line = { 200, 208, 220 },
		positive = { 32, 132, 68 },
		danger = { 190, 48, 48 },
		warn = { 180, 120, 32 },
		purple = { 100, 60, 190 },
		sidebar = { 236, 240, 248 },
	},
}

function HubPal()
	return PALETTES[HubState.theme] or PALETTES.dark
end

function HubT(c, a)
	return tocolor(c[1], c[2], c[3], math.min(255, math.floor(a)))
end

function HubAccent(a255)
	local _, r2, g2, b2 = exports.oCore:getServerColor()
	return tocolor(r2, g2, b2, math.min(255, math.floor(a255)))
end

function HubDrawCard(x, y, w, h, p, alpha, mul)
	mul = mul or 1
	local fill = math.min(255, math.floor(246 * alpha * mul))
	local edge = math.min(255, math.floor(120 * alpha * mul))
	dxDrawRectangle(x, y, w, h, HubT(p.cardElev, fill))
	dxDrawRectangle(x, y, w, 1, HubT(p.line, edge))
	dxDrawRectangle(x, y + h - 1, w, 1, HubT(p.line, math.floor(edge * 0.6)))
	dxDrawRectangle(x, y, 1, h, HubT(p.line, math.floor(edge * 0.75)))
	dxDrawRectangle(x + w - 1, y, 1, h, HubT(p.line, math.floor(edge * 0.75)))
end

local BADGE_COLORS = {
	online = { 52, 200, 96 },
	offline = { 100, 100, 120 },
	ajail = { 210, 72, 72 },
	duty = { 58, 118, 210 },
	vehicle = { 214, 168, 64 },
}

function HubDrawBadge(x, y, w, h, badgeType, alpha, font)
	local col = BADGE_COLORS[badgeType] or BADGE_COLORS.offline
	dxDrawRectangle(x, y, w, h, tocolor(col[1], col[2], col[3], math.floor(200 * alpha)))
	dxDrawText(string.upper(badgeType), x, y, x + w, y + h, tocolor(255, 255, 255, math.floor(240 * alpha)), 1, font, "center", "center")
end

function HubDrawBtn(x, y, w, h, label, r2, g2, b2, alpha, font, isDestructive)
	local hover = exports.oCore:isInSlot(x, y, w, h)
	local a = hover and math.min(255, math.floor(alpha * 1.15)) or math.floor(alpha)
	if isDestructive then
		dxDrawRectangle(x, y, w, h, tocolor(180, 40, 40, a))
	else
		dxDrawRectangle(x, y, w, h, tocolor(r2, g2, b2, a))
	end
	dxDrawRectangle(x, y, w, 2, tocolor(255, 255, 255, math.floor(30 * alpha)))
	exports.oCore:dxDrawButton(x, y, w, h, r2, g2, b2, a, label, tocolor(255, 255, 255, 255), 0.85, font, false, tocolor(0, 0, 0, 80))
end

function HubDrawChip(x, y, w, h, label, selected, alpha, font)
	local p = HubPal()
	local bg = selected and HubAccent(math.floor(180 * alpha)) or HubT(p.cardElev, math.floor(200 * alpha))
	dxDrawRectangle(x, y, w, h, bg)
	dxDrawRectangle(x, y, w, 1, HubT(p.line, math.floor(140 * alpha)))
	local col = selected and tocolor(255, 255, 255, 255) or HubT(p.muted, math.floor(220 * alpha))
	dxDrawText(label, x, y, x + w, y + h, col, 1, font, "center", "center")
end

function HubDrawBackground(ax, ay, aw, ah, alpha)
	local p = HubPal()
	dxDrawRectangle(ax, ay, aw, ah, HubT(p.panelBg, math.floor(246 * alpha)))
	local g = math.floor(p.grid * alpha)
	for gx = 0, aw, 48 do
		dxDrawLine(ax + gx, ay, ax + gx, ay + ah, tocolor(255, 255, 255, g), 1)
	end
	for gy = 0, ah, 48 do
		dxDrawLine(ax, ay + gy, ax + aw, ay + gy, tocolor(255, 255, 255, g), 1)
	end
	local pulse = (math.sin(getTickCount() / 520) + 1) * 0.5
	local _, cr, cg, cb = exports.oCore:getServerColor()
	dxDrawRectangle(ax, ay, aw, 4, tocolor(cr, cg, cb, math.floor((50 + 80 * pulse) * alpha)))
	dxDrawRectangle(ax, ay + 4, aw, 1, HubT(p.line, math.floor(180 * alpha)))
end
