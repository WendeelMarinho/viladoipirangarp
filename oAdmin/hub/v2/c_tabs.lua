--[[ Admin Hub v2 — barra de abas inferior (client) ]]

function HubRenderTabs(alpha)
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(10, math.floor(11 / 992 * sy2)))
	local tabCount = #HUB_TABS
	local tabW = (L.aw - L.px(4)) / tabCount
	local tabH = L.tabBarH
	local ty = L.tabBarY

	for i, tab in ipairs(HUB_TABS) do
		local tx = L.ax + L.px(2) + (i - 1) * tabW
		local on = HubState.activeTab == i
		local hover = not on and exports.oCore:isInSlot(tx, ty, tabW - L.px(2), tabH)
		if on then
			dxDrawRectangle(tx, ty, tabW - L.px(2), tabH, HubAccent(math.floor(72 * alpha)))
			dxDrawRectangle(tx, ty, tabW - L.px(2), 3, HubAccent(math.floor(255 * alpha)))
			dxDrawText(tab.icon .. " " .. tab.name, tx, ty, tx + tabW - L.px(2), ty + tabH, HubT(p.text, 255 * alpha), 1, font, "center", "center")
		else
			dxDrawRectangle(tx, ty, tabW - L.px(2), tabH, HubT(p.cardElev, math.floor((hover and 200 or 160) * alpha)))
			dxDrawRectangle(tx, ty, tabW - L.px(2), 1, HubT(p.line, math.floor(120 * alpha)))
			dxDrawText(tab.icon .. " " .. tab.name, tx, ty, tx + tabW - L.px(2), ty + tabH, HubT(p.muted, (hover and 255 or 210) * alpha), 1, font, "center", "center")
		end
		dxDrawText(tostring(i), tx + tabW - L.px(16), ty + L.py(4), tx + tabW - L.px(4), ty + L.py(16), HubT(p.muted, math.floor(120 * alpha)), 1, font, "right", "top")
	end
end

function HubTabsClick(clickX, clickY)
	local L = HubGetLayout()
	local tabCount = #HUB_TABS
	local tabW = (L.aw - L.px(4)) / tabCount
	for i = 1, tabCount do
		local tx = L.ax + L.px(2) + (i - 1) * tabW
		if clickX >= tx and clickX <= tx + tabW - L.px(2) and clickY >= L.tabBarY and clickY <= L.tabBarY + L.tabBarH then
			HubState.activeTab = i
			HubDestroyViewEditboxes()
			HubCreateViewEditboxes(i)
			return true
		end
	end
	return false
end
