--[[ Admin Hub v2 — modal de confirmação (client) ]]

function HubOpenModal(title, body, onConfirm, dangerLevel)
	HubState.modal = {
		title = title,
		body = body,
		onConfirm = onConfirm,
		dangerLevel = dangerLevel or 1,
	}
end

function HubCloseModal()
	HubState.modal = nil
end

function HubRenderModal(alpha)
	if not HubState.modal then
		return
	end
	local m = HubState.modal
	local L = HubGetLayout()
	local p = HubPal()

	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * sy2)))
	local fontT = exports.oFont:getFont("bebasneue", math.max(16, math.floor(20 / 992 * sy2)))

	dxDrawRectangle(L.ax, L.ay, L.aw, L.ah, tocolor(0, 0, 0, math.floor(160 * alpha)))

	local cw = L.px(460)
	local ch = L.py(200)
	local cx = L.ax + (L.aw - cw) / 2
	local cy = L.ay + (L.ah - ch) / 2
	HubDrawCard(cx, cy, cw, ch, p, alpha, 1.0)

	dxDrawText(m.title, cx + L.px(20), cy + L.py(16), cx + cw - L.px(20), cy + L.py(50), HubT(p.text, 255 * alpha), 1, fontT, "left", "center")

	dxDrawText(m.body, cx + L.px(20), cy + L.py(52), cx + cw - L.px(20), cy + L.py(130), HubT(p.muted, 240 * alpha), 1, font, "left", "top", false, true)

	local btnW = L.px(140)
	local btnH = L.py(38)
	local btnY = cy + ch - L.py(54)
	local cancelX = cx + L.px(20)
	HubDrawBtn(cancelX, btnY, btnW, btnH, "Cancelar", 60, 65, 80, math.floor(230 * alpha), font, false)

	local confirmX = cx + cw - L.px(20) - btnW
	if m.dangerLevel == 2 then
		HubDrawBtn(confirmX, btnY, btnW, btnH, "Confirmar", 180, 40, 40, math.floor(255 * alpha), font, true)
	else
		HubDrawBtn(confirmX, btnY, btnW, btnH, "Confirmar", 52, 168, 96, math.floor(255 * alpha), font, false)
	end
end

function HubModalClick(_, _)
	if not HubState.modal then
		return false
	end
	local m = HubState.modal
	local L = HubGetLayout()

	local cw = L.px(460)
	local ch = L.py(200)
	local panelCx = L.ax + (L.aw - cw) / 2
	local panelCy = L.ay + (L.ah - ch) / 2

	local btnW = L.px(140)
	local btnH = L.py(38)
	local btnY = panelCy + ch - L.py(54)

	local cancelX = panelCx + L.px(20)
	if exports.oCore:isInSlot(cancelX, btnY, btnW, btnH) then
		HubCloseModal()
		return true
	end

	local confirmX = panelCx + cw - L.px(20) - btnW
	if exports.oCore:isInSlot(confirmX, btnY, btnW, btnH) then
		if m.onConfirm then
			m.onConfirm()
		end
		HubCloseModal()
		return true
	end

	return true
end
