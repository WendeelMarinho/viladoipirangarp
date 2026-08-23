--[[ oHeist — tipos e constantes (shared) ]]

-- Opcional: reduz identificação IC (efeito narrativo; crime continua registado)
ITEM_DISGUISE = 240

HEIST_PHASE_MIN_MS = {
	hacking = 8000,
	drill = 12000,
}

HEIST_TYPE_PHASES = {
	atm = { "hacking" },
	store = { "hacking", "drill" },
	jewelry = { "hacking", "drill" },
}

--[[ Posições iniciais (interior 0) — seed na BD se vazia ]]
DEFAULT_HEIST_LOCATIONS = {
	{
		type = "atm",
		name = "ATM Idlewood",
		pos = { 1838.7, -1843.4, 13.4 },
		interior_id = 0,
		dimension_id = 0,
		cooldown_minutes = 25,
		reward_min = 500,
		reward_max = 1500,
		min_players = 1,
		police_alert_level = 2,
	},
	{
		type = "store",
		name = "Loja 24/7 (Commerce)",
		pos = { 1352.3, -1759.1, 13.5 },
		interior_id = 0,
		dimension_id = 0,
		cooldown_minutes = 40,
		reward_min = 1500,
		reward_max = 4000,
		min_players = 1,
		police_alert_level = 3,
	},
	{
		type = "jewelry",
		name = "Joalharia Vinewood",
		pos = { 1994.3, 1326.4, 10.8 },
		interior_id = 0,
		dimension_id = 0,
		cooldown_minutes = 90,
		reward_min = 8000,
		reward_max = 20000,
		min_players = 2,
		police_alert_level = 4,
	},
}

HEIST_INTERACT_M = 3.5
HEIST_CREW_RADIUS_M = 14
