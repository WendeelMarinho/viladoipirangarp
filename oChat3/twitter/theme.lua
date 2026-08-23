--[[ Ipiranga Tweets — tokens (alinhado ao oWelcome premium) ]]

TW_THEME = {
	bg = { 10, 14, 24 },
	card = { 18, 24, 38 },
	card2 = { 24, 30, 46 },
	hover = { 32, 40, 58 },
	text = { 245, 247, 252 },
	muted = { 160, 170, 190 },
	accent = { 41, 98, 255 },
	accent2 = { 201, 164, 39 },
	danger = { 220, 75, 85 },
	like = { 244, 100, 130 },
	border = { 55, 65, 90 },
}

function twColor(c, a)
	a = a or 255
	return tocolor(c[1], c[2], c[3], a)
end
