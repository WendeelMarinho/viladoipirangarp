--[[ Admin Hub v2 — estado central (shared) ]]

HubState = {
	open = false,
	animTick = 0,
	theme = "dark",

	activeTab = 1,

	autoLoadTimer = nil,

	snapshot = nil,
	snapshotLoading = false,

	catalog = nil,
	catalogLoading = false,
	catalogFilter = "",
	catalogDirty = true,
	catalogFiltered = nil,
	catalogPage = 1,
	catalogFavorites = {},
	catalogRecents = {},

	historyOpen = false,
	history = {},

	modal = nil,

	toasts = {},

	econType = 1,
	econMode = 1,

	modAction = 1,

	ppMode = 1,

	_layoutCache = nil,
	_layoutSx = 0,
	_layoutSy = 0,

	actionPending = false,

	_lastTargetVal = "",
}

HUB_TABS = {
	{ id = 1, name = "Jogador", icon = "👤", perm = "adminhub" },
	{ id = 2, name = "Economia", icon = "💰", perm = "givemoney" },
	{ id = 3, name = "Pontos Plus", icon = "⭐", perm = "givepp" },
	{ id = 4, name = "Itens", icon = "📦", perm = "giveitem" },
	{ id = 5, name = "Banco", icon = "🏦", perm = "givemoney" },
	{ id = 6, name = "Veículos", icon = "🚗", perm = "makeveh" },
	{ id = 7, name = "Moderação", icon = "⚖️", perm = "ajail" },
}

HUB_ECON_TYPES = { "Dinheiro (mão)", "Fichas cassino", "Pontos Plus", "Banco" }
HUB_ECON_MODES = { "Adicionar", "Remover", "Definir" }
HUB_MOD_ACTIONS = { "AJail", "Unjail", "Kick", "Warn", "Mute", "Ban" }

HUB_PRESETS = { 1000, 5000, 10000, 50000, 100000 }

HUB_CRITICAL_ACTIONS = {
	setMoney = true,
	setCC = true,
	setPP = true,
	bankSet = true,
	kick = true,
	ban = true,
	ajail = true,
}

function HubAddHistory(label, ok)
	local t = getRealTime()
	local ts = string.format("%02d:%02d", t.hour, t.minute)
	table.insert(HubState.history, 1, { time = ts, label = tostring(label or ""), ok = ok and true or false })
	if #HubState.history > 30 then
		table.remove(HubState.history)
	end
end

function HubInvalidateLayout()
	HubState._layoutCache = nil
end
