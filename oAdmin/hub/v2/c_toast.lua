--[[ Admin Hub v2 — toasts (client) ]]

local TOAST_DURATION = 3000
local TOAST_FADEIN = 200
local TOAST_FADEOUT = 400

function HubToast(msg, toastType)
	table.insert(HubState.toasts, {
		msg = tostring(msg or ""),
		type = toastType or "info",
		startTick = getTickCount(),
	})
	if #HubState.toasts > 5 then
		table.remove(HubState.toasts, 1)
	end
end

function HubRenderToasts(alpha)
	local L = HubGetLayout()
	local now = getTickCount()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(10, math.floor(11 / 992 * sy2)))

	local TOAST_W = L.px(280)
	local TOAST_H = L.py(38)
	local TOAST_GAP = L.py(6)
	local startX = L.ax + L.aw - TOAST_W - L.px(16)
	local startY = L.ay + L.py(16)

	local surviving = {}
	local posY = startY
	for _, t in ipairs(HubState.toasts) do
		local elapsed = now - t.startTick
		local total = TOAST_DURATION
		if elapsed >= total + TOAST_FADEOUT then
			-- expired
		else
			table.insert(surviving, t)
			local tAlpha
			if elapsed < TOAST_FADEIN then
				tAlpha = elapsed / TOAST_FADEIN
			elseif elapsed > total then
				tAlpha = 1 - (elapsed - total) / TOAST_FADEOUT
			else
				tAlpha = 1
			end
			tAlpha = math.max(0, math.min(1, tAlpha)) * alpha

			local colors = {
				success = { 52, 168, 96 },
				error = { 210, 72, 72 },
				warning = { 214, 168, 64 },
				info = { 58, 118, 210 },
			}
			local col = colors[t.type] or colors.info

			dxDrawRectangle(startX, posY, TOAST_W, TOAST_H, HubT(p.card, math.floor(240 * tAlpha)))
			dxDrawRectangle(startX, posY, 4, TOAST_H, tocolor(col[1], col[2], col[3], math.floor(255 * tAlpha)))
			dxDrawRectangle(startX, posY, TOAST_W, 1, HubT(p.line, math.floor(180 * tAlpha)))
			dxDrawText(t.msg, startX + L.px(12), posY, startX + TOAST_W - L.px(8), posY + TOAST_H, tocolor(255, 255, 255, math.floor(240 * tAlpha)), 1, font, "left", "center", false, false, false, true)

			posY = posY + TOAST_H + TOAST_GAP
		end
	end
	HubState.toasts = surviving
end
