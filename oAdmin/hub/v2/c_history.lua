--[[ Admin Hub v2 — painel histórico (client) ]]

function HubRenderHistory(alpha)
	if not HubState.historyOpen then
		return
	end
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(9, math.floor(10 / 992 * sy2)))
	local fontS = exports.oFont:getFont("bebasneue", math.max(13, math.floor(15 / 992 * sy2)))

	local targetX = L.ax + L.aw - L.histPanelW
	local hx = targetX
	local hy = L.bodyY
	local hw = L.histPanelW
	local hh = L.bodyH

	HubDrawCard(hx, hy, hw, hh, p, alpha, 0.9)
	dxDrawText("Histórico", hx + L.px(12), hy + L.py(8), hx + hw - L.px(12), hy + L.py(30), HubT(p.text, 250 * alpha), 1, fontS, "left", "center")

	local rowH = L.py(28)
	local startY = hy + L.py(36)
	for _, entry in ipairs(HubState.history) do
		if startY + rowH > hy + hh - L.py(10) then
			break
		end
		local col = entry.ok and HubT(p.positive, 220 * alpha) or HubT(p.danger, 220 * alpha)
		local icon = entry.ok and "✓" or "✕"
		dxDrawText(entry.time, hx + L.px(8), startY, hx + L.px(46), startY + rowH, HubT(p.muted, 200 * alpha), 1, font, "left", "center")
		dxDrawText(icon, hx + L.px(48), startY, hx + L.px(66), startY + rowH, col, 1, font, "center", "center")
		dxDrawText(entry.label, hx + L.px(70), startY, hx + hw - L.px(8), startY + rowH, HubT(p.text, 235 * alpha), 1, font, "left", "center", false, false, false, true)
		startY = startY + rowH
	end
end
