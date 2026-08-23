--[[ oTags — definições partilhadas ]]

TAG_ELEMENT_KEY = "player:activeTag"

TAG_RARITY = {
	common = "Comum — disponível para todos os jogadores.",
	rare = "Rara — obtida por eventos ou conquistas especiais.",
	legendary = "Lendária — extremamente exclusiva no servidor.",
}

TAG_DEFAULT_CIVIL = {
	id = 0,
	name = "civil",
	text = "CIV",
	color = "#aaaaaa",
	bg_color = "#222222",
	border_color = "#444444",
	animated = false,
	rarity = "common",
	source = "achievement",
	faction_id = nil,
}

--[[ faction_id → texto/cores (border opcional) ]]
FACTION_TAG_DEFAULTS = {
	[74] = { text = "PM",     color = "#ffffff", bg_color = "#1a3a8f", border_color = "#0f2460" },
	[80] = { text = "PC",     color = "#ffffff", bg_color = "#2960c8", border_color = "#1a458f" },
	[75] = { text = "SAMU",   color = "#ffffff", bg_color = "#cc1a1a", border_color = "#8f1212" },
	[81] = { text = "BM",     color = "#ffffff", bg_color = "#b01010", border_color = "#7a0b0b" },
	[76] = { text = "PREF",   color = "#ffdd00", bg_color = "#005baa", border_color = "#003d75" },
	[82] = { text = "OAB",    color = "#222222", bg_color = "#b5932a", border_color = "#7d6820" },
	[77] = { text = "PCC",    color = "#dddddd", bg_color = "#6a1fc2", border_color = "#451585" },
	[83] = { text = "CV",     color = "#ffffff", bg_color = "#b71c1c", border_color = "#801414" },
	[78] = { text = "MAFIA",  color = "#dddddd", bg_color = "#311b92", border_color = "#221466" },
	[79] = { text = "YAKUZA", color = "#dddd99", bg_color = "#1b5e20", border_color = "#123f15" },
}

function shallowCopyTag(t)
	local o = {}
	for k, v in pairs(t) do
		o[k] = v
	end
	return o
end
