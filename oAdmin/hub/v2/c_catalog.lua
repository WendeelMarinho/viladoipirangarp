--[[ Admin Hub v2 — catálogo de itens (client) ]]

function HubGetFilteredCatalog()
	local rawSearch = ""
	local ok, txt = pcall(function()
		return exports.oCore:getEditboxText("hub2_itemsearch")
	end)
	if ok and txt then
		rawSearch = txt
	end
	local filter = string.lower(rawSearch)
	if filter ~= HubState.catalogFilter or HubState.catalogDirty then
		HubState.catalogFilter = filter
		HubState.catalogDirty = false
		if not HubState.catalog or #HubState.catalog == 0 then
			HubState.catalogFiltered = {}
		elseif filter == "" then
			HubState.catalogFiltered = HubState.catalog
		else
			local out = {}
			for _, row in ipairs(HubState.catalog) do
				local line = string.lower(tostring(row[1]) .. " " .. tostring(row[2]))
				if string.find(line, filter, 1, true) then
					out[#out + 1] = row
				end
			end
			HubState.catalogFiltered = out
		end
		HubState.catalogPage = 1
	end
	return HubState.catalogFiltered or {}
end

function HubCatalogMarkFilterDirty()
	HubState.catalogDirty = true
end

function HubCatalogSelectItem(itemId, itemName)
	exports.oCore:setEditboxText("hub2_itemid", tostring(itemId))
	for i, r in ipairs(HubState.catalogRecents) do
		if r[1] == itemId then
			table.remove(HubState.catalogRecents, i)
			break
		end
	end
	table.insert(HubState.catalogRecents, 1, { itemId, itemName })
	if #HubState.catalogRecents > 8 then
		table.remove(HubState.catalogRecents)
	end
end

function HubRenderCatalog(x, y, w, h, alpha)
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(9, math.floor(10 / 992 * sy2)))

	HubDrawCard(x, y, w, h, p, alpha, 0.6)

	if HubState.catalogLoading then
		local pulse = (math.sin(getTickCount() / 400) + 1) * 0.5
		local sk = HubT(p.line, math.floor((80 + 60 * pulse) * alpha))
		for i = 0, 6 do
			dxDrawRectangle(x + L.px(8), y + L.py(8) + i * L.py(22), w - L.px(16), L.py(16), sk)
		end
		return
	end

	local filtered = HubGetFilteredCatalog()
	local rowH = L.py(22)
	local headerH = L.py(28)
	local footerH = L.py(44)
	local rows = math.max(1, math.floor((h - headerH - footerH) / rowH))
	local totalPages = math.max(1, math.ceil(#filtered / rows))
	if HubState.catalogPage > totalPages then
		HubState.catalogPage = totalPages
	end

	dxDrawText("Catálogo · " .. #filtered .. " itens", x + L.px(8), y + L.py(4), x + w - L.px(8), y + headerH, HubT(p.text, 245 * alpha), 1, font, "left", "center")
	dxDrawText("clique para selecionar", x + L.px(8), y + L.py(4), x + w - L.px(8), y + headerH, HubT(p.muted, 200 * alpha), 1, font, "right", "center")

	local startIdx = (HubState.catalogPage - 1) * rows + 1
	local yy = y + headerH
	for i = 1, rows do
		local idx = startIdx + i - 1
		local row = filtered[idx]
		if row then
			local isFav = HubState.catalogFavorites[row[1]] == true
			local curId = 0
			local ok2, tid = pcall(function()
				return exports.oCore:getEditboxText("hub2_itemid")
			end)
			if ok2 and tid then
				curId = tonumber(tid) or 0
			end
			local isSel = curId == row[1]
			local hov = exports.oCore:isInSlot(x + 2, yy, w - 4, rowH)
			if isSel then
				dxDrawRectangle(x + 2, yy, w - 4, rowH, HubAccent(math.floor(50 * alpha)))
			elseif hov then
				dxDrawRectangle(x + 2, yy, w - 4, rowH, HubT(p.card, math.floor(200 * alpha)))
			end
			dxDrawText("#" .. row[1], x + L.px(8), yy, x + L.px(50), yy + rowH, HubT(p.muted, 240 * alpha), 1, font, "left", "center")
			dxDrawText(row[2], x + L.px(54), yy, x + w - L.px(isFav and 22 or 8), yy + rowH, HubT(p.text, 240 * alpha), 1, font, "left", "center", false, false, false, true)
			if isFav then
				dxDrawText("★", x + w - L.px(20), yy, x + w - L.px(2), yy + rowH, tocolor(214, 168, 64, math.floor(240 * alpha)), 1, font, "right", "center")
			end
		end
		yy = yy + rowH
	end

	local fy = y + h - footerH
	exports.oCore:dxDrawButton(x + L.px(6), fy + L.py(8), L.px(80), L.py(28), 48, 56, 74, math.floor(220 * alpha), "◀", HubT(p.text, 255 * alpha), 0.9, font, false, tocolor(0, 0, 0, 80))
	exports.oCore:dxDrawButton(x + w - L.px(86), fy + L.py(8), L.px(80), L.py(28), 48, 56, 74, math.floor(220 * alpha), "▶", HubT(p.text, 255 * alpha), 0.9, font, false, tocolor(0, 0, 0, 80))
	dxDrawText(HubState.catalogPage .. " / " .. totalPages, x + L.px(92), fy + L.py(8), x + w - L.px(92), fy + L.py(36), HubT(p.muted, 230 * alpha), 1, font, "center", "center")
end

function HubCatalogClick(ax, ay, w, h, _, clickY)
	local L = HubGetLayout()
	local headerH = L.py(28)
	local footerH = L.py(44)
	local rowH = L.py(22)
	local rows = math.max(1, math.floor((h - headerH - footerH) / rowH))
	local listY = ay + headerH
	local listBottom = ay + h - footerH
	local fy = ay + h - footerH

	if exports.oCore:isInSlot(ax + L.px(6), fy + L.py(8), L.px(80), L.py(28)) then
		HubState.catalogPage = math.max(1, HubState.catalogPage - 1)
		return true
	end
	if exports.oCore:isInSlot(ax + w - L.px(86), fy + L.py(8), L.px(80), L.py(28)) then
		local filtered = HubGetFilteredCatalog()
		local rows2 = math.max(1, math.floor((h - headerH - footerH) / rowH))
		local totalP = math.max(1, math.ceil(#filtered / rows2))
		HubState.catalogPage = math.min(totalP, HubState.catalogPage + 1)
		return true
	end

	if clickY >= listY and clickY <= listBottom then
		local relY = clickY - listY
		local rowIdx = math.floor(relY / rowH) + 1
		local filtered = HubGetFilteredCatalog()
		local startIdx = (HubState.catalogPage - 1) * rows + 1
		local item = filtered[startIdx + rowIdx - 1]
		if item then
			local lastSel = 0
			local ok3, tid2 = pcall(function()
				return exports.oCore:getEditboxText("hub2_itemid")
			end)
			if ok3 and tid2 then
				lastSel = tonumber(tid2) or 0
			end
			if lastSel == item[1] then
				if HubState.catalogFavorites[item[1]] then
					HubState.catalogFavorites[item[1]] = nil
				else
					HubState.catalogFavorites[item[1]] = true
				end
			end
			HubCatalogSelectItem(item[1], item[2])
			return true
		end
	end
	return false
end

function HubCatalogScroll(direction)
	local L = HubGetLayout()
	local filtered = HubGetFilteredCatalog()
	local mainH = L.mainH
	local headerH = L.py(28)
	local footerH = L.py(44)
	local rowH = L.py(22)
	local catalogH = mainH * 0.52
	local rows = math.max(1, math.floor((catalogH - headerH - footerH) / rowH))
	local totalP = math.max(1, math.ceil(#filtered / rows))
	if direction == "up" then
		HubState.catalogPage = math.max(1, HubState.catalogPage - 1)
	else
		HubState.catalogPage = math.min(totalP, HubState.catalogPage + 1)
	end
end
