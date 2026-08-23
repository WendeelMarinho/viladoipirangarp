--[[ Admin Hub v2 — vistas por aba + cliques (client) ]]

-- ===== Helpers de layout (Y da editbox alinha com o desenho) =====
local function econLayout(L)
	-- Espelha HubRenderViewEconomy: título, recurso+linha de chips (+40), operação+linha (+40), rótulo «Valor», editbox.
	local cy = L.mainY + L.py(20)
	cy = cy + L.py(36)
	cy = cy + L.py(22)
	cy = cy + L.py(40)
	cy = cy + L.py(22)
	cy = cy + L.py(40)
	local editY = cy + L.py(22)
	local presetLabelY = editY + L.py(30) + L.py(8)
	local presetRowY = presetLabelY + L.py(20)
	local previewY = presetRowY + L.py(28) + L.py(42)
	local execY = previewY + L.py(38) + L.py(48)
	return editY, presetLabelY, presetRowY, previewY, execY
end

function HubEconomyEditPositions(L)
	local editY = select(1, econLayout(L))
	return L.mainX + L.px(20), editY, L.mainW - L.px(40), L.py(30)
end

local function premiumValueEditY(L)
	local cy = L.mainY + L.py(20) + L.py(36) + L.py(22) + L.py(40) + L.py(22) + L.py(40)
	return cy + L.py(22)
end

function HubPremiumEditPositions(L)
	return L.mainX + L.px(20), premiumValueEditY(L), L.mainW - L.px(40), L.py(30)
end

local function bankValueEditY(L)
	local cy = L.mainY + L.py(20) + L.py(36) + L.py(56)
	return cy + L.py(22)
end

function HubBankEditPositions(L)
	return L.mainX + L.px(20), bankValueEditY(L), L.mainW - L.px(40), L.py(30)
end

local function vehEditYs(L)
	local cy = L.mainY + L.py(20) + L.py(36) + L.py(26)
	local row = L.py(22) + L.py(38)
	return cy + row, cy + row * 2, cy + row * 3, cy + row * 4
end

function HubVehEditPositions(L)
	local y1, y2, y3, y4 = vehEditYs(L)
	local cx = L.mainX + L.px(20)
	local cw = L.mainW - L.px(40)
	local h = L.py(30)
	return cx, y1, cw, h, y2, y3, y4
end

local function modChipBottomY(L)
	return L.mainY + L.py(20) + L.py(36) + L.py(22) + L.py(32) + L.py(40)
end

local function modExecBtnY(L)
	local cy = modChipBottomY(L)
	local ma = HubState.modAction
	if ma == 1 or ma == 5 or ma == 6 then
		cy = cy + L.py(54)
	end
	if ma ~= 2 then
		cy = cy + L.py(54)
	end
	return cy + L.py(10)
end

function HubModEditPositions(L)
	local chipBottom = modChipBottomY(L)
	local ma = HubState.modAction
	local twY, rwY = nil, nil
	local base = chipBottom
	if ma == 1 or ma == 5 or ma == 6 then
		twY = base + L.py(22)
		base = base + L.py(54)
	end
	if ma ~= 2 then
		rwY = base + L.py(22)
	end
	return twY, rwY
end

local function itemsLayout(L)
	local cx = L.mainX + L.px(20)
	local cy = L.mainY + L.py(20)
	local cw = L.mainW - L.px(40)
	local gap = L.px(12)
	local catalogW = cw * 0.44
	local formW = cw - catalogW - gap
	local cataX = cx + formW + gap
	local cataH = L.mainH - L.py(40)
	return cx, cy, formW, catalogW, gap, cataX, cataH
end

--- Formulário à esquerda: cada campo com rótulo acima; botão «Dar item» e recentes abaixo (sem sobrepor edits).
function HubItemsEditPositions(L)
	local cx, cy0, formW = itemsLayout(L)
	local cw = formW
	local eh = L.py(28)
	local lab = L.py(16)
	local gap = L.py(8)
	local y = cy0 + L.py(30) + lab
	local ySearch = y
	y = y + eh + gap + lab
	local yId = y
	y = y + eh + gap + lab
	local yVal = y
	y = y + eh + gap + lab
	local yCnt = y
	y = y + eh + gap + lab
	local yDuty = y
	y = y + eh + L.py(16)
	local ySubmit = y
	return cx, ySearch, cw, eh, yId, yVal, yCnt, yDuty, ySubmit
end

-- ===== Execução com modal =====
local function runCritical(title, body, danger2, fn)
	HubOpenModal(title, body, fn, danger2 and 2 or 1)
end

local function hubTargetPartial()
	return exports.oCore:getEditboxText("hub2_target") or ""
end

-- ===== Render views =====
function HubRenderViewPlayer(alpha)
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * sy2)))
	local fontT = exports.oFont:getFont("bebasneue", math.max(16, math.floor(18 / 992 * sy2)))

	local cx = L.mainX + L.px(20)
	local cy = L.mainY + L.py(20)
	local cw = L.mainW - L.px(40)

	dxDrawText("Jogador", cx, cy, cx + cw, cy + L.py(28), HubT(p.text, 255 * alpha), 1, fontT, "left", "center")
	cy = cy + L.py(34)

	local _, r2, g2, b2 = exports.oCore:getServerColor()
	HubDrawBtn(cx, cy, L.px(220), L.py(36), "Recarregar snapshot", r2, g2, b2, math.floor(245 * alpha), font, false)
	cy = cy + L.py(48)

	dxDrawText("Ctrl+R também recarrega. Os dados financeiros aparecem na sidebar após carregar.", cx, cy, cx + cw, cy + L.py(44), HubT(p.muted, 220 * alpha), 1, font, "left", "top", false, true)
end

function HubRenderViewEconomy(alpha)
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * sy2)))
	local fontT = exports.oFont:getFont("bebasneue", math.max(16, math.floor(18 / 992 * sy2)))

	local cx = L.mainX + L.px(20)
	local cy = L.mainY + L.py(20)
	local cw = L.mainW - L.px(40)

	dxDrawText("Economia", cx, cy, cx + cw, cy + L.py(28), HubT(p.text, 255 * alpha), 1, fontT, "left", "center")
	cy = cy + L.py(36)

	dxDrawText("Recurso:", cx, cy, cx + cw, cy + L.py(18), HubT(p.muted, 220 * alpha), 1, font, "left", "center")
	cy = cy + L.py(22)
	local chipW = (cw - L.px(6) * 3) / 4
	for i, name in ipairs(HUB_ECON_TYPES) do
		local bx = cx + (i - 1) * (chipW + L.px(6))
		HubDrawChip(bx, cy, chipW, L.py(32), name, HubState.econType == i, alpha, font)
	end
	cy = cy + L.py(40)

	dxDrawText("Operação:", cx, cy, cx + cw, cy + L.py(18), HubT(p.muted, 220 * alpha), 1, font, "left", "center")
	cy = cy + L.py(22)
	local modeW = (cw - L.px(6) * 2) / 3
	local modeColors = {
		{ 52, 168, 96 },
		{ 210, 72, 72 },
		{ 58, 118, 210 },
	}
	for i, name in ipairs(HUB_ECON_MODES) do
		local bx = cx + (i - 1) * (modeW + L.px(6))
		local col = modeColors[i]
		local sel = HubState.econMode == i
		if sel then
			dxDrawRectangle(bx, cy, modeW, L.py(32), tocolor(col[1], col[2], col[3], math.floor(180 * alpha)))
		else
			dxDrawRectangle(bx, cy, modeW, L.py(32), HubT(p.cardElev, math.floor(200 * alpha)))
		end
		dxDrawRectangle(bx, cy, modeW, 1, HubT(p.line, math.floor(120 * alpha)))
		dxDrawText(name, bx, cy, bx + modeW, cy + L.py(32), sel and tocolor(255, 255, 255, 255) or HubT(p.muted, 230 * alpha), 1, font, "center", "center")
	end
	cy = cy + L.py(40)

	dxDrawText("Valor:", cx, cy, cx + cw, cy + L.py(18), HubT(p.muted, 220 * alpha), 1, font, "left", "center")
	local editY, presetLabelY, presetRowY, previewY, execY = econLayout(L)

	dxDrawText("Presets rápidos:", cx, presetLabelY, cx + cw, presetLabelY + L.py(16), HubT(p.muted, 200 * alpha), 1, font, "left", "center")
	cy = presetRowY
	local presetW = (cw - L.px(4) * 4) / 5
	for i, preset in ipairs(HUB_PRESETS) do
		local bx = cx + (i - 1) * (presetW + L.px(4))
		local label = preset >= 1000 and (preset / 1000 .. "k") or tostring(preset)
		if HubState.econMode == 2 then
			label = "-" .. label
		end
		HubDrawBtn(bx, cy, presetW, L.py(28), label, 48, 56, 74, math.floor(220 * alpha), font, false)
	end

	local targetName = HubState.snapshot and HubState.snapshot.name or "?"
	local valStr = exports.oCore:getEditboxText("hub2_econ_value") or "0"
	local previewText = (HUB_ECON_MODES[HubState.econMode] or "?") .. " " .. valStr .. " · " .. (HUB_ECON_TYPES[HubState.econType] or "?") .. " → " .. targetName
	cy = previewY
	HubDrawCard(cx, cy, cw, L.py(38), p, alpha, 0.5)
	dxDrawText("Preview: " .. previewText, cx + L.px(12), cy, cx + cw - L.px(12), cy + L.py(38), HubT(p.text, 230 * alpha), 1, font, "left", "center", false, false, false, true)
	cy = execY

	local btnColor = { 52, 168, 96 }
	if HubState.econMode == 2 then
		btnColor = { 210, 72, 72 }
	elseif HubState.econMode == 3 then
		btnColor = { 58, 118, 210 }
	end
	local critical = HubState.econMode == 3 or (HubState.econType == 4 and HubState.econMode == 3)
	HubDrawBtn(cx, cy, cw, L.py(44), "EXECUTAR AÇÃO", btnColor[1], btnColor[2], btnColor[3], math.floor(255 * alpha), font, critical)
end

function HubRenderViewPremium(alpha)
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * sy2)))
	local fontT = exports.oFont:getFont("bebasneue", math.max(16, math.floor(18 / 992 * sy2)))

	local cx = L.mainX + L.px(20)
	local cy = L.mainY + L.py(20)
	local cw = L.mainW - L.px(40)

	dxDrawText("Pontos Plus (loja / cosméticos)", cx, cy, cx + cw, cy + L.py(28), HubT(p.text, 255 * alpha), 1, fontT, "left", "center")
	cy = cy + L.py(36)

	dxDrawText("Operação:", cx, cy, cx + cw, cy + L.py(18), HubT(p.muted, 220 * alpha), 1, font, "left", "center")
	cy = cy + L.py(22)
	local modeW = (cw - L.px(6) * 2) / 3
	local modeColors = {
		{ 52, 168, 96 },
		{ 210, 72, 72 },
		{ 58, 118, 210 },
	}
	for i, name in ipairs(HUB_ECON_MODES) do
		local bx = cx + (i - 1) * (modeW + L.px(6))
		local col = modeColors[i]
		local sel = HubState.ppMode == i
		if sel then
			dxDrawRectangle(bx, cy, modeW, L.py(32), tocolor(col[1], col[2], col[3], math.floor(180 * alpha)))
		else
			dxDrawRectangle(bx, cy, modeW, L.py(32), HubT(p.cardElev, math.floor(200 * alpha)))
		end
		dxDrawText(name, bx, cy, bx + modeW, cy + L.py(32), sel and tocolor(255, 255, 255, 255) or HubT(p.muted, 230 * alpha), 1, font, "center", "center")
	end
	cy = cy + L.py(40)

	dxDrawText("Valor (IP+):", cx, cy, cx + cw, cy + L.py(18), HubT(p.muted, 220 * alpha), 1, font, "left", "center")
	cy = cy + L.py(54)

	local presetW = (cw - L.px(4) * 4) / 5
	for i, preset in ipairs(HUB_PRESETS) do
		local bx = cx + (i - 1) * (presetW + L.px(4))
		local label = preset >= 1000 and (preset / 1000 .. "k") or tostring(preset)
		if HubState.ppMode == 2 then
			label = "-" .. label
		end
		HubDrawBtn(bx, cy, presetW, L.py(28), label, 48, 56, 74, math.floor(220 * alpha), font, false)
	end
	cy = cy + L.py(42)

	local btnColor = { 52, 168, 96 }
	if HubState.ppMode == 2 then
		btnColor = { 210, 72, 72 }
	elseif HubState.ppMode == 3 then
		btnColor = { 58, 118, 210 }
	end
	HubDrawBtn(cx, cy, cw, L.py(44), "APLICAR IP+", btnColor[1], btnColor[2], btnColor[3], math.floor(255 * alpha), font, HubState.ppMode == 3)
end

function HubRenderViewItems(alpha)
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * sy2)))
	local fontT = exports.oFont:getFont("bebasneue", math.max(16, math.floor(18 / 992 * sy2)))

	local cx, cy0, formW, catalogW, gap, cataX, cataH = itemsLayout(L)
	local lab = L.py(16)
	local cxF, ySearch, cwF, _, yId, yVal, yCnt, yDuty, ySubmit = HubItemsEditPositions(L)

	dxDrawText("Itens", cx, cy0, cx + formW, cy0 + L.py(28), HubT(p.text, 255 * alpha), 1, fontT, "left", "center")

	dxDrawText("Pesquisar catálogo", cxF, ySearch - lab, cxF + cwF, ySearch, HubT(p.muted, 210 * alpha), 1, font, "left", "bottom")
	dxDrawText("ID do item", cxF, yId - lab, cxF + cwF, yId, HubT(p.muted, 210 * alpha), 1, font, "left", "bottom")
	dxDrawText("Valor (estado)", cxF, yVal - lab, cxF + cwF, yVal, HubT(p.muted, 210 * alpha), 1, font, "left", "bottom")
	dxDrawText("Quantidade", cxF, yCnt - lab, cxF + cwF, yCnt, HubT(p.muted, 210 * alpha), 1, font, "left", "bottom")
	dxDrawText("Duty (0 ou 1)", cxF, yDuty - lab, cxF + cwF, yDuty, HubT(p.muted, 210 * alpha), 1, font, "left", "bottom")

	local _, r2, g2, b2 = exports.oCore:getServerColor()
	HubDrawBtn(cxF, ySubmit, cwF, L.py(38), "Dar item", r2, g2, b2, math.floor(248 * alpha), font, false)

	if #HubState.catalogRecents > 0 then
		local ry = ySubmit + L.py(44)
		dxDrawText("Recentes (atalhos)", cxF, ry, cxF + cwF, ry + L.py(16), HubT(p.muted, 200 * alpha), 1, font, "left", "center")
	end

	HubRenderCatalog(cataX, cy0, catalogW, cataH, alpha)
end

function HubRenderViewBank(alpha)
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * sy2)))
	local fontT = exports.oFont:getFont("bebasneue", math.max(16, math.floor(18 / 992 * sy2)))

	local cx = L.mainX + L.px(20)
	local cy = L.mainY + L.py(20)
	local cw = L.mainW - L.px(40)

	dxDrawText("Banco (conta do snapshot)", cx, cy, cx + cw, cy + L.py(28), HubT(p.text, 255 * alpha), 1, fontT, "left", "center")
	cy = cy + L.py(36)

	local s = HubState.snapshot
	if s and s.bankSerial then
		HubDrawCard(cx, cy, cw, L.py(48), p, alpha, 0.55)
		dxDrawText("Conta " .. tostring(s.bankSerial), cx + L.px(12), cy + L.py(6), cx + cw - L.px(12), cy + L.py(26), HubT(p.muted, 235 * alpha), 1, font, "left", "center")
		dxDrawText("$" .. tostring(s.bankMoney or 0), cx + L.px(12), cy + L.py(22), cx + cw - L.px(12), cy + L.py(44), HubT(p.text, 255 * alpha), 1, font, "left", "center")
		cy = cy + L.py(56)

		dxDrawText("Valor:", cx, cy, cx + cw, cy + L.py(18), HubT(p.muted, 220 * alpha), 1, font, "left", "center")
		cy = cy + L.py(54)

		local bw = (cw - L.px(8) * 2) / 3
		HubDrawBtn(cx, cy, bw, L.py(34), "Adicionar $", 52, 168, 96, math.floor(240 * alpha), font, false)
		HubDrawBtn(cx + bw + L.px(8), cy, bw, L.py(34), "Remover $", 210, 72, 72, math.floor(240 * alpha), font, false)
		HubDrawBtn(cx + (bw + L.px(8)) * 2, cy, bw, L.py(34), "Definir $", 58, 118, 210, math.floor(240 * alpha), font, false)
	else
		HubDrawCard(cx, cy, cw, L.py(72), p, alpha, 0.45)
		dxDrawText("Carrega um jogador com conta bancária no snapshot.", cx + L.px(14), cy + L.py(16), cx + cw - L.px(14), cy + L.py(60), HubT(p.muted, 230 * alpha), 1, font, "left", "top", false, true)
	end
end

function HubRenderViewVehicles(alpha)
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * sy2)))
	local fontT = exports.oFont:getFont("bebasneue", math.max(16, math.floor(18 / 992 * sy2)))

	local cx = L.mainX + L.px(20)
	local cy = L.mainY + L.py(20)
	local cw = L.mainW - L.px(40)

	dxDrawText("Veículos", cx, cy, cx + cw, cy + L.py(28), HubT(p.text, 255 * alpha), 1, fontT, "left", "center")
	cy = cy + L.py(36)

	local row = L.py(22) + L.py(38)
	dxDrawText("Modelo GTA · Facção (0/1) · Matrícula · Cor R,G,B", cx, cy, cx + cw, cy + L.py(20), HubT(p.muted, 215 * alpha), 1, font, "left", "center")
	cy = cy + row * 4 + L.py(16)

	local _, r2, g2, b2 = exports.oCore:getServerColor()
	local bw = (cw - L.px(8) * 2) / 3
	HubDrawBtn(cx, cy, bw, L.py(36), "Criar (/makeveh)", r2, g2, b2, math.floor(248 * alpha), font, false)
	HubDrawBtn(cx + bw + L.px(8), cy, bw, L.py(36), "Reparar", 58, 118, 200, math.floor(248 * alpha), font, false)
	HubDrawBtn(cx + (bw + L.px(8)) * 2, cy, bw, L.py(36), "Desvirar", 58, 118, 200, math.floor(248 * alpha), font, false)
end

function HubRenderViewModeration(alpha)
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * sy2)))
	local fontT = exports.oFont:getFont("bebasneue", math.max(16, math.floor(18 / 992 * sy2)))

	local cx = L.mainX + L.px(20)
	local cy = L.mainY + L.py(20)
	local cw = L.mainW - L.px(40)

	dxDrawText("Moderação", cx, cy, cx + cw, cy + L.py(28), HubT(p.text, 255 * alpha), 1, fontT, "left", "center")
	cy = cy + L.py(36)

	dxDrawText("Ação:", cx, cy, cx + cw, cy + L.py(18), HubT(p.muted, 220 * alpha), 1, font, "left", "center")
	cy = cy + L.py(22)

	local modColors = {
		{ 214, 168, 64 },
		{ 52, 168, 96 },
		{ 58, 118, 210 },
		{ 180, 120, 200 },
		{ 160, 80, 180 },
		{ 210, 72, 72 },
	}
	local modW = (cw - L.px(4) * 5) / 6
	for i, name in ipairs(HUB_MOD_ACTIONS) do
		local bx = cx + (i - 1) * (modW + L.px(4))
		local col = modColors[i]
		local sel = HubState.modAction == i
		if sel then
			dxDrawRectangle(bx, cy, modW, L.py(32), tocolor(col[1], col[2], col[3], math.floor(180 * alpha)))
		else
			dxDrawRectangle(bx, cy, modW, L.py(32), HubT(p.cardElev, math.floor(200 * alpha)))
		end
		dxDrawText(name, bx, cy, bx + modW, cy + L.py(32), sel and tocolor(255, 255, 255, 255) or HubT(p.muted, 220 * alpha), 1, font, "center", "center")
	end
	cy = cy + L.py(40)

	local ma = HubState.modAction
	local showTime = (ma == 1 or ma == 5 or ma == 6)
	local showReason = (ma ~= 2)

	if showTime then
		local label = (ma == 6) and "Horas (0 = permanente):" or "Minutos:"
		dxDrawText(label, cx, cy, cx + cw, cy + L.py(18), HubT(p.muted, 220 * alpha), 1, font, "left", "center")
		cy = cy + L.py(54)
	end
	if showReason then
		dxDrawText("Motivo:", cx, cy, cx + cw, cy + L.py(18), HubT(p.muted, 220 * alpha), 1, font, "left", "center")
		cy = cy + L.py(54)
	end
	cy = cy + L.py(10)

	local col = modColors[HubState.modAction]
	local isDanger = (HubState.modAction == 6)
	HubDrawBtn(cx, cy, cw, L.py(44), "EXECUTAR AÇÃO", col[1], col[2], col[3], math.floor(255 * alpha), font, isDanger)
end

-- ===== Cliques =====
local function hitChip(mx, my, leftX, chipW, gap, rowH, rowY, index)
	local bx = leftX + (index - 1) * (chipW + gap)
	return my >= rowY and my <= rowY + rowH and mx >= bx and mx <= bx + chipW
end

local function executeEconomy()
	local partial = hubTargetPartial()
	if partial == "" then
		HubToast("Indica o alvo.", "error")
		return
	end
	local v = tonumber(exports.oCore:getEditboxText("hub2_econ_value") or "")
	if not v or v < 0 then
		HubToast("Valor inválido.", "error")
		return
	end
	local crit = HubState.econMode == 3 or (HubState.econType == 4 and HubState.econMode == 3)
	local go = function()
		HubState.actionPending = true
		triggerServerEvent("adminHub2 > economy", resourceRoot, partial, HubState.econType, HubState.econMode, math.floor(v))
	end
	if crit then
		runCritical("Confirmar economia", "Operação: " .. (HUB_ECON_MODES[HubState.econMode] or "") .. " em " .. (HUB_ECON_TYPES[HubState.econType] or "") .. "\nValor: " .. tostring(math.floor(v)), true, go)
	else
		go()
	end
end

local function executePremium()
	local partial = hubTargetPartial()
	if partial == "" then
		HubToast("Indica o alvo.", "error")
		return
	end
	local v = tonumber(exports.oCore:getEditboxText("hub2_pp_value") or "")
	if not v or v < 0 then
		HubToast("Valor de Pontos Plus inválido.", "error")
		return
	end
	local go = function()
		HubState.actionPending = true
		triggerServerEvent("adminHub2 > economy", resourceRoot, partial, 3, HubState.ppMode, math.floor(v))
	end
	if HubState.ppMode == 3 then
		runCritical("Definir Pontos Plus", "Definir saldo IP+ para " .. tostring(math.floor(v)) .. "?", true, go)
	else
		go()
	end
end

local function executeBank(modeNum)
	local partial = hubTargetPartial()
	if partial == "" then
		HubToast("Indica o alvo.", "error")
		return
	end
	local v = tonumber(exports.oCore:getEditboxText("hub2_bank_value") or "")
	if not v or v < 0 then
		HubToast("Valor inválido.", "error")
		return
	end
	local go = function()
		HubState.actionPending = true
		triggerServerEvent("adminHub2 > bank", resourceRoot, partial, modeNum, math.floor(v))
	end
	if modeNum == 3 then
		runCritical("Definir saldo bancário", "Definir saldo para $" .. tostring(math.floor(v)) .. "?", true, go)
	else
		go()
	end
end

local function executeMod()
	local partial = hubTargetPartial()
	if partial == "" then
		HubToast("Indica o alvo.", "error")
		return
	end
	local ma = HubState.modAction
	local reason = exports.oCore:getEditboxText("hub2_mod_reason") or ""
	local t = tonumber(exports.oCore:getEditboxText("hub2_mod_time") or "")
	local function goKick()
		HubState.actionPending = true
		triggerServerEvent("adminHub2 > kick", resourceRoot, partial, reason ~= "" and reason or "Kick administrativo")
	end
	local function goWarn()
		HubState.actionPending = true
		triggerServerEvent("adminHub2 > warn", resourceRoot, partial, reason ~= "" and reason or "Aviso administrativo")
	end
	local function goUnjail()
		HubState.actionPending = true
		triggerServerEvent("adminHub2 > unjail", resourceRoot, partial)
	end

	if ma == 1 then
		if not t or t < 1 or reason == "" then
			HubToast("AJail: minutos (>0) e motivo obrigatórios.", "error")
			return
		end
		runCritical("Admin jail", "Prender " .. partial .. " por " .. tostring(math.floor(t)) .. " min?", false, function()
			HubState.actionPending = true
			triggerServerEvent("adminHub2 > ajail", resourceRoot, partial, math.floor(t), reason)
		end)
	elseif ma == 2 then
		goUnjail()
	elseif ma == 3 then
		runCritical("Kick", "Expulsar " .. partial .. "?", true, goKick)
	elseif ma == 4 then
		goWarn()
	elseif ma == 5 then
		if not t or t < 1 then
			HubToast("Mute: minutos inválidos.", "error")
			return
		end
		HubState.actionPending = true
		triggerServerEvent("adminHub2 > mute", resourceRoot, partial, math.floor(t), reason ~= "" and reason or "Mute administrativo")
	elseif ma == 6 then
		if reason == "" then
			HubToast("Ban: motivo obrigatório.", "error")
			return
		end
		local hours = tonumber(t) or 0
		runCritical("Ban", "Banir " .. partial .. "? Horas: " .. tostring(hours) .. " (0 = duracao ampla)", true, function()
			HubState.actionPending = true
			triggerServerEvent("adminHub2 > ban", resourceRoot, partial, hours, reason)
		end)
	end
end

function HubViewClick(tab, cx, cy)
	local L = HubGetLayout()
	local mainX, mainY, mainW, mainH = L.mainX, L.mainY, L.mainW, L.mainH
	if cx < mainX or cx > mainX + mainW or cy < mainY or cy > mainY + mainH then
		return false
	end

	if tab == 1 then
		local bx = L.mainX + L.px(20)
		local by = L.mainY + L.py(20) + L.py(34)
		if exports.oCore:isInSlot(bx, by, L.px(220), L.py(36)) then
			local partial = hubTargetPartial()
			if partial == "" then
				HubToast("Indica o alvo.", "warning")
				return true
			end
			HubState.snapshotLoading = true
			triggerServerEvent("adminHub2 > snapshot", resourceRoot, partial)
			return true
		end
	elseif tab == 2 then
		local cx0 = L.mainX + L.px(20)
		local cy0 = L.mainY + L.py(20) + L.py(36)
		local cw = L.mainW - L.px(40)
		-- chips recurso
		local chipW = (cw - L.px(6) * 3) / 4
		local rowY = cy0 + L.py(22)
		for i = 1, 4 do
			if hitChip(cx, cy, cx0, chipW, L.px(6), L.py(32), rowY, i) then
				HubState.econType = i
				return true
			end
		end
		-- chips modo
		rowY = rowY + L.py(40) + L.py(22)
		local modeW = (cw - L.px(6) * 2) / 3
		for i = 1, 3 do
			if hitChip(cx, cy, cx0, modeW, L.px(6), L.py(32), rowY, i) then
				HubState.econMode = i
				return true
			end
		end
		local _, _, presetRowY2, _, execY2 = econLayout(L)
		rowY = presetRowY2
		local presetW = (cw - L.px(4) * 4) / 5
		for i = 1, #HUB_PRESETS do
			local bx = cx0 + (i - 1) * (presetW + L.px(4))
			if exports.oCore:isInSlot(bx, rowY, presetW, L.py(28)) then
				local val = HUB_PRESETS[i]
				exports.oCore:setEditboxText("hub2_econ_value", tostring(val))
				return true
			end
		end
		if exports.oCore:isInSlot(cx0, execY2, cw, L.py(44)) then
			if HubState.actionPending then
				return true
			end
			executeEconomy()
			return true
		end
	elseif tab == 3 then
		local cx0 = L.mainX + L.px(20)
		local cw = L.mainW - L.px(40)
		local cy0 = L.mainY + L.py(20) + L.py(36)
		local 		rowY = cy0 + L.py(22)
		local modeW = (cw - L.px(6) * 2) / 3
		for i = 1, 3 do
			if hitChip(cx, cy, cx0, modeW, L.px(6), L.py(32), rowY, i) then
				HubState.ppMode = i
				return true
			end
		end
		rowY = premiumValueEditY(L) + L.py(20)
		local presetW = (cw - L.px(4) * 4) / 5
		for i = 1, #HUB_PRESETS do
			local bx = cx0 + (i - 1) * (presetW + L.px(4))
			if exports.oCore:isInSlot(bx, rowY, presetW, L.py(28)) then
				exports.oCore:setEditboxText("hub2_pp_value", tostring(HUB_PRESETS[i]))
				return true
			end
		end
		rowY = rowY + L.py(42)
		if exports.oCore:isInSlot(cx0, rowY, cw, L.py(44)) then
			if HubState.actionPending then
				return true
			end
			executePremium()
			return true
		end
	elseif tab == 4 then
		local cx0, cy0, formW, catalogW, gap, cataX, cataH = itemsLayout(L)
		if HubCatalogClick(cataX, cy0, catalogW, cataH, cx, cy) then
			return true
		end
		local cxF, _, cwF, _, _, _, _, _, ySubmit = HubItemsEditPositions(L)
		if exports.oCore:isInSlot(cxF, ySubmit, cwF, L.py(38)) then
			if HubState.actionPending then
				return true
			end
			local partial = hubTargetPartial()
			local itemId = tonumber(exports.oCore:getEditboxText("hub2_itemid") or "")
			local val = exports.oCore:getEditboxText("hub2_itemval") or "1"
			local count = tonumber(exports.oCore:getEditboxText("hub2_itemcount") or "")
			local duty = tonumber(exports.oCore:getEditboxText("hub2_itemduty") or "0") or 0
			if partial == "" or not itemId or not count or count < 1 then
				HubToast("Alvo, ID e quantidade obrigatórios.", "error")
				return true
			end
			HubState.actionPending = true
			triggerServerEvent("adminHub2 > giveItem", resourceRoot, partial, itemId, val, count, duty)
			return true
		end
		-- recentes
		if #HubState.catalogRecents > 0 then
			local ry = ySubmit + L.py(44) + L.py(16)
			local chipW = (cwF - L.px(6) * 3) / 4
			for i, rec in ipairs(HubState.catalogRecents) do
				if i > 4 then
					break
				end
				local bx = cxF + ((i - 1) % 4) * (chipW + L.px(6))
				local by = ry + math.floor((i - 1) / 4) * L.py(30)
				if exports.oCore:isInSlot(bx, by, chipW, L.py(26)) then
					HubCatalogSelectItem(rec[1], rec[2])
					return true
				end
			end
		end
	elseif tab == 5 then
		local s = HubState.snapshot
		if not (s and s.bankSerial) then
			if cx >= L.mainX and cx <= L.mainX + L.mainW and cy >= L.mainY and cy <= L.mainY + L.mainH then
				HubToast("Carrega o jogador na aba «Jogador» (snapshot) para ver a conta bancária.", "warning")
			end
			return true
		end
		local cx0 = L.mainX + L.px(20)
		local cw = L.mainW - L.px(40)
		local cyB = L.mainY + L.py(20) + L.py(36) + L.py(56) + L.py(54)
		local bw = (cw - L.px(8) * 2) / 3
		if exports.oCore:isInSlot(cx0, cyB, bw, L.py(34)) then
			executeBank(1)
			return true
		end
		if exports.oCore:isInSlot(cx0 + bw + L.px(8), cyB, bw, L.py(34)) then
			executeBank(2)
			return true
		end
		if exports.oCore:isInSlot(cx0 + (bw + L.px(8)) * 2, cyB, bw, L.py(34)) then
			executeBank(3)
			return true
		end
	elseif tab == 6 then
		local cx0 = L.mainX + L.px(20)
		local cw = L.mainW - L.px(40)
		local cyB = L.mainY + L.py(20) + L.py(36) + (L.py(22) + L.py(38)) * 4 + L.py(16)
		local bw = (cw - L.px(8) * 2) / 3
		local partial = hubTargetPartial()
		if partial == "" then
			return false
		end
		if exports.oCore:isInSlot(cx0, cyB, bw, L.py(36)) then
			if HubState.actionPending then
				return true
			end
			local modelId = tonumber(exports.oCore:getEditboxText("hub2_veh_model") or "")
			local fac = tonumber(exports.oCore:getEditboxText("hub2_veh_faction") or "0") or 0
			local plate = exports.oCore:getEditboxText("hub2_veh_plate") or ""
			local colStr = exports.oCore:getEditboxText("hub2_veh_color") or "255,255,255"
			if not modelId then
				HubToast("Modelo inválido.", "error")
				return true
			end
			HubState.actionPending = true
			triggerServerEvent("adminHub2 > makeveh", resourceRoot, partial, modelId, fac, plate, colStr)
			return true
		end
		if exports.oCore:isInSlot(cx0 + bw + L.px(8), cyB, bw, L.py(36)) then
			HubState.actionPending = true
			triggerServerEvent("adminHub2 > fixveh", resourceRoot, partial)
			return true
		end
		if exports.oCore:isInSlot(cx0 + (bw + L.px(8)) * 2, cyB, bw, L.py(36)) then
			HubState.actionPending = true
			triggerServerEvent("adminHub2 > unflip", resourceRoot, partial)
			return true
		end
	elseif tab == 7 then
		local cx0 = L.mainX + L.px(20)
		local cw = L.mainW - L.px(40)
		local cy0 = L.mainY + L.py(20) + L.py(36)
		local 		rowY = cy0 + L.py(22)
		local modW = (cw - L.px(4) * 5) / 6
		for i = 1, 6 do
			if hitChip(cx, cy, cx0, modW, L.px(4), L.py(32), rowY, i) then
				HubState.modAction = i
				HubDestroyViewEditboxes()
				HubCreateViewEditboxes(7)
				return true
			end
		end
		local btnY = modExecBtnY(L)
		if exports.oCore:isInSlot(cx0, btnY, cw, L.py(44)) then
			if HubState.actionPending then
				return true
			end
			executeMod()
			return true
		end
	end
	return false
end
