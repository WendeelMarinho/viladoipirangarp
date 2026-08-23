--[[ oRank — categorias e chaves de estatísticas ]]

RANK_BADGE_KEY = "player:rankBadge"

--[[ tipo: stat | terr_count | faction_income ]]
RANK_CATEGORIES = {
	{ id = "economico",   label = "Económico",   abbrev = "ECO", badge = true,  type = "stat", statKey = "dinheiro_total" },
	{ id = "criminal",    label = "Criminal",    abbrev = "CRM", badge = true,  type = "stat", statKey = "crimes_totais" },
	{ id = "policial",    label = "Policial",    abbrev = "POL", badge = true,  type = "stat", statKey = "prisoes" },
	{ id = "territorial", label = "Territorial", abbrev = "TER", badge = false, type = "terr_count" },
	{ id = "social",      label = "Social",      abbrev = "SOC", badge = true,  type = "stat", statKey = "horas_online" },
	{ id = "motorista",   label = "Motorista",   abbrev = "MOT", badge = true,  type = "stat", statKey = "km_rodados" },
	{ id = "combate",     label = "Combate",     abbrev = "CMB", badge = true,  type = "stat", statKey = "mortes_causadas" },
	{ id = "faccional",   label = "Faccional",   abbrev = "FAC", badge = false, type = "faction_income" },
}

RANK_COLORS_GOLD = { color = "#ffd700", bg_color = "#2d2400", border_color = "#ffd700" }
RANK_COLORS_SILVER = { color = "#e8e8e8", bg_color = "#252525", border_color = "#c0c0c0" }
RANK_COLORS_BRONZE = { color = "#cd7f32", bg_color = "#1f1408", border_color = "#a0522d" }

RANK_CACHE_INTERVAL_MS = 300000
RANK_TOP_N = 10
