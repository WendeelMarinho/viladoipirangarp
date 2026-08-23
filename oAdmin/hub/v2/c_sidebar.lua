--[[ Admin Hub v2 — sidebar perfil + ações rápidas (client) ]]

HubSidebarQuickBtns = HubSidebarQuickBtns or {}

local function getSnapshotStatus()
	local s = HubState.snapshot
	if not s then
		return {}
	end
	local badges = {}
	if s.online then
		badges[#badges + 1] = "online"
	end
	if s.ajailed then
		badges[#badges + 1] = "ajail"
	end
	if s.onDuty then
		badges[#badges + 1] = "duty"
	end
	if s.inVeh then
		badges[#badges + 1] = "vehicle"
	end
	return badges
end

function HubRenderSidebar(alpha)
	HubSidebarQuickBtns = {}
	local L = HubGetLayout()
	local p = HubPal()
	local _, sy2 = guiGetScreenSize()
	local font = exports.oFont:getFont("condensed", math.max(11, math.floor(13 / 992 * sy2)))
	local fontS = exports.oFont:getFont("condensed", math.max(9, math.floor(10 / 992 * sy2)))
	local fontT = exports.oFont:getFont("bebasneue", math.max(14, math.floor(16 / 992 * sy2)))

	local lx = L.sidebarX
	local ly = L.sidebarY
	local lw = L.sidebarW
	local lh = L.sidebarH

	dxDrawRectangle(lx, ly, lw, lh, HubT(p.sidebar, math.floor(255 * alpha)))
	dxDrawRectangle(lx + lw - 1, ly, 1, lh, HubT(p.line, math.floor(200 * alpha)))

	local searchY = ly + L.py(12)
	dxDrawText("Alvo:", lx + L.px(10), searchY, lx + lw - L.px(10), searchY + L.py(18), HubT(p.muted, 220 * alpha), 1, fontS, "left", "center")

	local profileY = ly + L.py(62)

	if HubState.snapshotLoading then
		local pulse = (math.sin(getTickCount() / 400) + 1) * 0.5
		local sk = HubT(p.line, math.floor((70 + 50 * pulse) * alpha))
		dxDrawRectangle(lx + L.px(10), profileY, lw - L.px(20), L.py(14), sk)
		dxDrawRectangle(lx + L.px(10), profileY + L.py(20), lw * 0.6, L.py(10), sk)
		for i = 0, 4 do
			dxDrawRectangle(lx + L.px(10), profileY + L.py(44) + i * L.py(20), lw - L.px(20), L.py(12), sk)
		end
		return
	end

	if not HubState.snapshot then
		dxDrawText("Preencha o alvo e aguarde\no carregamento automático.", lx + L.px(12), profileY, lx + lw - L.px(12), profileY + L.py(60), HubT(p.muted, 200 * alpha), 1, fontS, "left", "top", false, true)
		return
	end

	local s = HubState.snapshot

	local badges = getSnapshotStatus()
	local badgeX = lx + L.px(10)
	local badgeH = L.py(18)
	local badgeW = L.px(52)
	for _, badge in ipairs(badges) do
		HubDrawBadge(badgeX, profileY, badgeW, badgeH, badge, alpha, fontS)
		badgeX = badgeX + badgeW + L.px(4)
	end
	profileY = profileY + L.py(24)

	dxDrawText(s.name or "—", lx + L.px(10), profileY, lx + lw - L.px(10), profileY + L.py(24), HubT(p.text, 255 * alpha), 1, fontT, "left", "center", false, false, false, true)
	profileY = profileY + L.py(26)

	dxDrawText("Char #" .. (s.charId or "?") .. " · User #" .. (s.userId or "?"), lx + L.px(10), profileY, lx + lw - L.px(10), profileY + L.py(16), HubT(p.muted, 220 * alpha), 1, fontS, "left", "center")
	profileY = profileY + L.py(22)

	dxDrawRectangle(lx + L.px(10), profileY, lw - L.px(20), 1, HubT(p.line, math.floor(160 * alpha)))
	profileY = profileY + L.py(8)

	local stats = {
		{ "💰 Mão", "$" .. (s.money or 0), p.positive },
		{ "🏦 Banco", s.bankSerial and ("$" .. (s.bankMoney or 0)) or "Sem conta", p.positive },
		{ "⭐ Pontos Plus", (s.pp or 0) .. " IP+", p.purple },
		{ "🎰 Fichas cassino", (s.cc or 0) .. " FC", p.warn },
	}
	for _, stat in ipairs(stats) do
		dxDrawText(stat[1], lx + L.px(10), profileY, lx + lw * 0.52, profileY + L.py(18), HubT(p.muted, 220 * alpha), 1, fontS, "left", "center")
		dxDrawText(stat[2], lx + lw * 0.52, profileY, lx + lw - L.px(10), profileY + L.py(18), HubT(stat[3], 255 * alpha), 1, fontS, "right", "center", false, false, false, true)
		profileY = profileY + L.py(20)
	end

	if s.faction and s.faction ~= "" then
		profileY = profileY + L.py(4)
		dxDrawRectangle(lx + L.px(10), profileY, lw - L.px(20), 1, HubT(p.line, math.floor(120 * alpha)))
		profileY = profileY + L.py(8)
		dxDrawText(s.faction, lx + L.px(10), profileY, lx + lw - L.px(10), profileY + L.py(16), HubT(p.muted, 220 * alpha), 1, fontS, "left", "center", false, false, false, true)
		profileY = profileY + L.py(18)
		if s.factionRank and s.factionRank ~= "" then
			dxDrawText(s.factionRank, lx + L.px(10), profileY, lx + lw - L.px(10), profileY + L.py(14), HubT(p.text, 200 * alpha), 1, fontS, "left", "center", false, false, false, true)
			profileY = profileY + L.py(16)
		end
	end

	profileY = profileY + L.py(10)
	dxDrawRectangle(lx + L.px(10), profileY, lw - L.px(20), 1, HubT(p.line, math.floor(140 * alpha)))
	profileY = profileY + L.py(8)
	dxDrawText("Ações rápidas", lx + L.px(10), profileY, lx + lw - L.px(10), profileY + L.py(16), HubT(p.muted, 210 * alpha), 1, fontS, "left", "center")
	profileY = profileY + L.py(20)

	local quickActions = {
		{ "Teleportar até", "goto" },
		{ "Puxar", "bring" },
		{ "Curar (100%)", "heal" },
		{ "Congelar", "freeze" },
		{ "Ver inventário", "inventory" },
	}
	for _, qa in ipairs(quickActions) do
		local bx, by, bw, bh = lx + L.px(10), profileY, lw - L.px(20), L.py(26)
		HubDrawBtn(bx, by, bw, bh, qa[1], 48, 56, 80, math.floor(210 * alpha), fontS, false)
		HubSidebarQuickBtns[#HubSidebarQuickBtns + 1] = { bx, by, bw, bh, qa[2] }
		profileY = profileY + L.py(30)
	end
end

function HubSidebarClick(cx, cy)
	if not HubState.snapshot then
		return false
	end
	for _, btn in ipairs(HubSidebarQuickBtns) do
		local bx, by, bw, bh, action = btn[1], btn[2], btn[3], btn[4], btn[5]
		if cx >= bx and cy >= by and cx <= bx + bw and cy <= by + bh then
			local partial = exports.oCore:getEditboxText("hub2_target") or ""
			if partial == "" then
				HubToast("Indica o alvo.", "warning")
				return true
			end
			if HubState.actionPending then
				return true
			end
			HubState.actionPending = true
			if action == "goto" then
				triggerServerEvent("adminHub2 > teleport", resourceRoot, partial, 1)
			elseif action == "bring" then
				triggerServerEvent("adminHub2 > teleport", resourceRoot, partial, 2)
			elseif action == "heal" then
				triggerServerEvent("adminHub2 > heal", resourceRoot, partial)
			elseif action == "freeze" then
				triggerServerEvent("adminHub2 > freeze", resourceRoot, partial)
			elseif action == "inventory" then
				triggerServerEvent("adminHub2 > showinv", resourceRoot, partial)
			end
			return true
		end
	end
	return false
end
