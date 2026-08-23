--[[ oWelcome — design tokens (Ipiranga premium dark) ]]

W_THEME = {
	bgDeep = { 10, 14, 24 },
	card = { 18, 24, 38 },
	cardHover = { 28, 36, 54 },
	glass = { 22, 28, 44 },
	text = { 245, 247, 252 },
	textMuted = { 160, 170, 190 },
	accent = { 41, 98, 255 },
	accent2 = { 201, 164, 39 },
	border = { 55, 65, 90 },
	success = { 72, 199, 142 },
	danger = { 220, 80, 90 },
	radius = 12,
	radiusSm = 8,
	shadowA = 120,
}

function wTocolor(c, a)
	a = a or 255
	return tocolor(c[1], c[2], c[3], a)
end
