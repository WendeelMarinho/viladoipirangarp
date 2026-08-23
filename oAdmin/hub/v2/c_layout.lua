--[[ Admin Hub v2 — layout cache (client) ]]

local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992

local function px(n)
	return n / myX * sx
end

local function py(n)
	return n / myY * sy
end

local PANEL_W = 1280
local PANEL_H = 860

function HubGetLayout()
	local csx, csy = guiGetScreenSize()
	if HubState._layoutCache and HubState._layoutSx == csx and HubState._layoutSy == csy then
		return HubState._layoutCache
	end
	sx, sy = csx, csy

	local aw = px(PANEL_W)
	local ah = py(PANEL_H)
	local ax = (sx - aw) / 2
	local ay = (sy - ah) / 2

	local headerH = py(56)
	local tabBarH = py(52)
	local footerH = py(32)
	local sidebarW = py(250)
	local mainX = ax + sidebarW + px(1)
	local mainW = aw - sidebarW - px(1)
	local bodyY = ay + headerH
	local bodyH = ah - headerH - tabBarH - footerH
	local tabBarY = ay + ah - tabBarH - footerH
	local footerY = ay + ah - footerH

	local L = {
		ax = ax,
		ay = ay,
		aw = aw,
		ah = ah,
		headerH = headerH,
		tabBarH = tabBarH,
		footerH = footerH,
		bodyY = bodyY,
		bodyH = bodyH,
		tabBarY = tabBarY,
		footerY = footerY,
		sidebarX = ax,
		sidebarY = bodyY,
		sidebarW = sidebarW,
		sidebarH = bodyH,
		mainX = mainX,
		mainY = bodyY,
		mainW = mainW,
		mainH = bodyH,
		closeBtnX = ax + aw - px(42),
		closeBtnY = ay + py(11),
		historyBtnX = ax + aw - px(88),
		historyBtnY = ay + py(11),
		themeBtnX = ax + aw - px(154),
		themeBtnY = ay + py(11),
		histPanelX = ax + aw,
		histPanelW = px(280),
		histPanelH = bodyH,
		px = px,
		py = py,
	}

	HubState._layoutCache = L
	HubState._layoutSx = csx
	HubState._layoutSy = csy
	return L
end
