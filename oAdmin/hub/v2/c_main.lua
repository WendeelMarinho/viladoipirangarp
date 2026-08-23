--[[ Admin Hub v2 — orquestrador (client) ]]

local function destroyAllEditboxes()
	local allBoxes = {
		"hub2_target",
		"hub2_econ_value",
		"hub2_pp_value",
		"hub2_itemid",
		"hub2_itemval",
		"hub2_itemcount",
		"hub2_itemduty",
		"hub2_itemsearch",
		"hub2_bank_value",
		"hub2_veh_model",
		"hub2_veh_faction",
		"hub2_veh_plate",
		"hub2_veh_color",
		"hub2_mod_time",
		"hub2_mod_reason",
	}
	for _, name in ipairs(allBoxes) do
		pcall(function()
			exports.oCore:deleteEditbox(name)
		end)
	end
end

function HubDestroyViewEditboxes()
	local tabBoxes = {
		[2] = { "hub2_econ_value" },
		[3] = { "hub2_pp_value" },
		[4] = { "hub2_itemid", "hub2_itemval", "hub2_itemcount", "hub2_itemduty", "hub2_itemsearch" },
		[5] = { "hub2_bank_value" },
		[6] = { "hub2_veh_model", "hub2_veh_faction", "hub2_veh_plate", "hub2_veh_color" },
		[7] = { "hub2_mod_time", "hub2_mod_reason" },
	}
	for _, list in pairs(tabBoxes) do
		for _, name in ipairs(list) do
			pcall(function()
				exports.oCore:deleteEditbox(name)
			end)
		end
	end
end

function HubCreateViewEditboxes(tabIdx)
	local L = HubGetLayout()
	local cx = L.mainX + L.px(20)
	local cw = L.mainW - L.px(40)
	local bg = { 20, 24, 38, 255 }

	if tabIdx == 2 then
		local ex, ey, ew, eh = HubEconomyEditPositions(L)
		exports.oCore:createEditbox(ex, ey, ew, eh, "hub2_econ_value", "Quantidade", "number", true, bg, 0.30, 16)
	elseif tabIdx == 3 then
		local ex, ey, ew, eh = HubPremiumEditPositions(L)
		exports.oCore:createEditbox(ex, ey, ew, eh, "hub2_pp_value", "IP+", "number", true, bg, 0.30, 16)
	elseif tabIdx == 4 then
		local cx0, y1, cw0, h1, y2, y3, y4, y5 = HubItemsEditPositions(L)
		exports.oCore:createEditbox(cx0, y1, cw0, h1, "hub2_itemsearch", "Pesquisar item…", "text", true, bg, 0.28, 48)
		exports.oCore:createEditbox(cx0, y2, cw0, h1, "hub2_itemid", "ID item", "number", true, bg, 0.30, 8)
		exports.oCore:createEditbox(cx0, y3, cw0, h1, "hub2_itemval", "Valor", "text", true, bg, 0.30, 24)
		exports.oCore:createEditbox(cx0, y4, cw0, h1, "hub2_itemcount", "Quantidade", "number", true, bg, 0.30, 8)
		exports.oCore:createEditbox(cx0, y5, cw0, h1, "hub2_itemduty", "Duty 0/1", "number", true, bg, 0.30, 2)
	elseif tabIdx == 5 then
		local ex, ey, ew, eh = HubBankEditPositions(L)
		exports.oCore:createEditbox(ex, ey, ew, eh, "hub2_bank_value", "Valor $", "number", true, bg, 0.30, 16)
	elseif tabIdx == 6 then
		local cx0, y1, cw0, h, y2, y3, y4 = HubVehEditPositions(L)
		exports.oCore:createEditbox(cx0, y1, cw0, h, "hub2_veh_model", "Modelo", "number", true, bg, 0.30, 5)
		exports.oCore:createEditbox(cx0, y2, cw0, h, "hub2_veh_faction", "Facção 0/1", "number", true, bg, 0.30, 2)
		exports.oCore:createEditbox(cx0, y3, cw0, h, "hub2_veh_plate", "Matrícula", "text", true, bg, 0.28, 12)
		exports.oCore:createEditbox(cx0, y4, cw0, h, "hub2_veh_color", "R,G,B", "text", true, bg, 0.28, 32)
	elseif tabIdx == 7 then
		local twY, rwY = HubModEditPositions(L)
		local ma = HubState.modAction
		if twY and (ma == 1 or ma == 5 or ma == 6) then
			exports.oCore:createEditbox(cx, twY, cw, L.py(30), "hub2_mod_time", ma == 6 and "Horas" or "Minutos", "number", true, bg, 0.30, 8)
		end
		if ma ~= 2 and rwY then
			exports.oCore:createEditbox(cx, rwY, cw, L.py(30), "hub2_mod_reason", "Motivo", "text", true, bg, 0.26, 120)
		end
	end
end

local function positionSidebarEditbox()
	local L = HubGetLayout()
	exports.oCore:createEditbox(L.sidebarX + L.px(10), L.sidebarY + L.py(30), L.sidebarW - L.px(20), L.py(30), "hub2_target", "Nome, playerid ou char:id", "text", true, { 20, 24, 38, 255 }, 0.30, 48)
end

local function clearSnapshotTimeout()
	if HubState._snapshotTimeoutTimer and isTimer(HubState._snapshotTimeoutTimer) then
		killTimer(HubState._snapshotTimeoutTimer)
		HubState._snapshotTimeoutTimer = nil
	end
end

local function openHub()
	if HubState.open then
		return
	end
	if not hasPermission(localPlayer, "adminhub") then
		exports.oInfobox:outputInfoBox("Sem permissão para abrir o painel.", "error")
		return
	end
	if (getElementData(localPlayer, "user:admin") or 0) < 2 and not getElementData(localPlayer, "aclLogin") then
		exports.oInfobox:outputInfoBox("Nível admin insuficiente.", "error")
		return
	end
	if not isPlayerInAdminDuty(localPlayer) then
		exports.oInfobox:outputInfoBox("Entra em serviço admin (/aduty) antes.", "error")
		return
	end

	local saved = getElementData(localPlayer, "adminHub:theme")
	if saved == "light" or saved == "dark" then
		HubState.theme = saved
	end

	HubState.open = true
	HubState.animTick = getTickCount()
	HubInvalidateLayout()
	showCursor(true)
	addEventHandler("onClientRender", root, HubRenderLoop)
	positionSidebarEditbox()
	HubCreateViewEditboxes(HubState.activeTab)

	if not HubState.catalog then
		HubState.catalogLoading = true
		triggerServerEvent("adminHub2 > getCatalog", resourceRoot)
	end
end

local function closeHub()
	if not HubState.open then
		return
	end
	HubState.open = false
	HubState.modal = nil
	showCursor(false)
	removeEventHandler("onClientRender", root, HubRenderLoop)
	destroyAllEditboxes()
	HubState.snapshot = nil
	HubState.snapshotLoading = false
	HubState._lastTargetVal = ""
	if isTimer(HubState.autoLoadTimer) then
		killTimer(HubState.autoLoadTimer)
	end
	HubState.autoLoadTimer = nil
	clearSnapshotTimeout()
end

function HubRenderLoop()
	if not HubState.open then
		return
	end
	local t = (getTickCount() - HubState.animTick) / 600
	local alpha = math.min(1, t)
	local L = HubGetLayout()
	local p = HubPal()
	local w2, h2 = guiGetScreenSize()

	dxDrawRectangle(0, 0, w2, h2, tocolor(0, 0, 0, math.floor(165 * alpha)))

	HubDrawBackground(L.ax, L.ay, L.aw, L.ah, alpha)
	HubDrawCard(L.ax + 1, L.ay + 1, L.aw - 2, L.ah - 2, p, alpha, 0.9)

	local fontT = exports.oFont:getFont("bebasneue", math.max(18, math.floor(22 / 992 * h2)))
	local fontB = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * h2)))
	dxDrawText("Admin Hub v2", L.ax + L.px(20), L.ay + L.py(12), L.ax + L.aw, L.ay + L.headerH, HubT(p.text, 255 * alpha), 1, fontT, "left", "center")

	HubDrawBtn(L.closeBtnX, L.closeBtnY, L.px(34), L.py(32), "✕", 60, 65, 80, math.floor(215 * alpha), fontB, false)
	HubDrawBtn(L.historyBtnX, L.historyBtnY, L.px(34), L.py(32), "⏱", 60, 65, 80, math.floor(215 * alpha), fontB, false)
	HubDrawBtn(L.themeBtnX, L.themeBtnY, L.px(58), L.py(32), "🌙/☀", 60, 65, 80, math.floor(215 * alpha), fontB, false)

	HubRenderSidebar(alpha)

	dxDrawRectangle(L.mainX - 1, L.bodyY, 1, L.bodyH, HubT(p.line, math.floor(200 * alpha)))

	if HubState.activeTab == 1 then
		HubRenderViewPlayer(alpha)
	elseif HubState.activeTab == 2 then
		HubRenderViewEconomy(alpha)
	elseif HubState.activeTab == 3 then
		HubRenderViewPremium(alpha)
	elseif HubState.activeTab == 4 then
		HubRenderViewItems(alpha)
	elseif HubState.activeTab == 5 then
		HubRenderViewBank(alpha)
	elseif HubState.activeTab == 6 then
		HubRenderViewVehicles(alpha)
	elseif HubState.activeTab == 7 then
		HubRenderViewModeration(alpha)
	end

	HubRenderTabs(alpha)

	local fText = "Ctrl+1–7: abas · Ctrl+R: recarregar snapshot · Ctrl+F: ir à aba Itens · ESC: fechar"
	dxDrawText(fText, L.ax + L.px(12), L.footerY, L.ax + L.aw - L.px(12), L.ay + L.ah, HubT(p.muted, math.floor(170 * alpha)), 1, exports.oFont:getFont("condensed", math.max(9, math.floor(10 / 992 * h2))), "center", "center")

	HubRenderHistory(alpha)
	HubRenderModal(alpha)
	HubRenderToasts(alpha)
end

addEventHandler("onClientClick", root, function(button, state, cx, cy)
	if not HubState.open or button ~= "left" or state ~= "down" then
		return
	end
	local L = HubGetLayout()

	if HubState.modal then
		HubModalClick(cx, cy)
		return
	end

	if exports.oCore:isInSlot(L.closeBtnX, L.closeBtnY, L.px(34), L.py(32)) then
		closeHub()
		return
	end
	if exports.oCore:isInSlot(L.historyBtnX, L.historyBtnY, L.px(34), L.py(32)) then
		HubState.historyOpen = not HubState.historyOpen
		return
	end
	if exports.oCore:isInSlot(L.themeBtnX, L.themeBtnY, L.px(58), L.py(32)) then
		HubState.theme = (HubState.theme == "dark") and "light" or "dark"
		setElementData(localPlayer, "adminHub:theme", HubState.theme, false)
		return
	end

	if HubTabsClick(cx, cy) then
		return
	end

	if HubSidebarClick(cx, cy) then
		return
	end

	if HubViewClick(HubState.activeTab, cx, cy) then
		return
	end
end)

addEventHandler("onClientKey", root, function(key, press)
	if not HubState.open or not press then
		return
	end
	if key == "escape" then
		cancelEvent()
		if HubState.modal then
			HubCloseModal()
		else
			closeHub()
		end
		return
	end
	local ctrl = getKeyState("lctrl") or getKeyState("rctrl")
	if ctrl then
		if key == "r" then
			cancelEvent()
			local target = exports.oCore:getEditboxText("hub2_target") or ""
			if target ~= "" then
				HubState.snapshotLoading = true
				triggerServerEvent("adminHub2 > snapshot", resourceRoot, target)
			end
			return
		end
		if key == "f" then
			cancelEvent()
			if HubState.activeTab ~= 4 then
				HubState.activeTab = 4
				HubDestroyViewEditboxes()
				HubCreateViewEditboxes(4)
			end
			return
		end
		if key == "tab" then
			cancelEvent()
			local dir = (getKeyState("lshift") or getKeyState("rshift")) and -1 or 1
			HubState.activeTab = ((HubState.activeTab - 1 + dir - 1) % #HUB_TABS) + 1
			HubDestroyViewEditboxes()
			HubCreateViewEditboxes(HubState.activeTab)
			return
		end
		local n = tonumber(key)
		if n and n >= 1 and n <= #HUB_TABS then
			cancelEvent()
			HubState.activeTab = n
			HubDestroyViewEditboxes()
			HubCreateViewEditboxes(n)
			return
		end
	end
	if HubState.activeTab == 4 then
		if key == "mouse_wheel_up" then
			HubCatalogScroll("up")
			return
		elseif key == "mouse_wheel_down" then
			HubCatalogScroll("down")
			return
		end
	end
end)

local function onTargetChange()
	if HubState.autoLoadTimer and isTimer(HubState.autoLoadTimer) then
		killTimer(HubState.autoLoadTimer)
		HubState.autoLoadTimer = nil
	end
	clearSnapshotTimeout()
	local val = exports.oCore:getEditboxText("hub2_target") or ""
	if val == "" then
		HubState.snapshot = nil
		HubState.snapshotLoading = false
		return
	end
	HubState.autoLoadTimer = setTimer(function()
		HubState.autoLoadTimer = nil
		local cur = exports.oCore:getEditboxText("hub2_target") or ""
		if cur == "" then
			return
		end
		HubState.snapshotLoading = true
		clearSnapshotTimeout()
		HubState._snapshotTimeoutTimer = setTimer(function()
			HubState._snapshotTimeoutTimer = nil
			if HubState.snapshotLoading then
				HubState.snapshotLoading = false
				HubToast("Timeout: servidor não respondeu ao snapshot. Verifica ACL/adminhub ou reconecta.", "error")
			end
		end, 12000, 1)
		triggerServerEvent("adminHub2 > snapshot", resourceRoot, cur)
	end, 800, 1)
end

local function watchTargetField()
	if not HubState.open then
		return
	end
	local cur = exports.oCore:getEditboxText("hub2_target") or ""
	if cur ~= (HubState._lastTargetVal or "") then
		HubState._lastTargetVal = cur
		onTargetChange()
	end
end

local function watchItemSearch()
	if not HubState.open or HubState.activeTab ~= 4 then
		return
	end
	local cur = exports.oCore:getEditboxText("hub2_itemsearch") or ""
	if cur ~= (HubState._lastSearchVal or "") then
		HubState._lastSearchVal = cur
		HubCatalogMarkFilterDirty()
	end
end

setTimer(watchTargetField, 300, 0)
setTimer(watchItemSearch, 350, 0)

addEvent("adminHub2 > snapshotResult", true)
addEventHandler("adminHub2 > snapshotResult", resourceRoot, function(ok, data)
	clearSnapshotTimeout()
	HubState.snapshotLoading = false
	if ok then
		HubState.snapshot = data
	else
		HubState.snapshot = nil
		HubToast(tostring(data or "Erro ao carregar dados."), "error")
	end
end)

addEvent("adminHub2 > actionResult", true)
addEventHandler("adminHub2 > actionResult", resourceRoot, function(ok, msg, updatedSnapshot)
	HubState.actionPending = false
	if ok then
		HubToast(msg or "OK", "success")
		HubAddHistory(msg or "Ação", true)
		if updatedSnapshot and HubState.snapshot then
			for k, v in pairs(updatedSnapshot) do
				HubState.snapshot[k] = v
			end
		end
	else
		HubToast(msg or "Erro", "error")
		HubAddHistory(msg or "Erro", false)
	end
end)

addEvent("adminHub2 > catalogResult", true)
addEventHandler("adminHub2 > catalogResult", resourceRoot, function(list)
	HubState.catalogLoading = false
	HubState.catalog = (type(list) == "table") and list or {}
	HubState.catalogDirty = true
end)

addEvent("adminHub2 > openShowinv", true)
addEventHandler("adminHub2 > openShowinv", resourceRoot, function(partial)
	HubState.actionPending = false
	if partial and partial ~= "" then
		executeCommandHandler("showinv", partial)
	end
end)

addCommandHandler("adminhub", function()
	if HubState.open then
		closeHub()
	else
		openHub()
	end
end)
addCommandHandler("painelstaff", function()
	if HubState.open then
		closeHub()
	else
		openHub()
	end
end)

addEventHandler("onClientResourceStop", resourceRoot, closeHub)
