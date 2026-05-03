-- ─── oWanted / global.lua ────────────────────────────────────────────────────

-- Tipos de crime: { nome, nível mínimo que adiciona, bounty base, expiração (min, 0=permanente) }
CRIMES = {
    ["fuga_policial"]   = { "Fuga policial",         1, 500,   10 },
    ["resistencia"]     = { "Resistência à prisão",  1, 750,   10 },
    ["agressao"]        = { "Agressão",               2, 1500,  20 },
    ["roubo"]           = { "Roubo/Assalto",          3, 3000,  40 },
    ["homicidio"]       = { "Homicídio",              4, 7500,   0 },
    ["crime_org"]       = { "Crime organizado",       5, 15000,  0 },
    ["trafico"]         = { "Tráfico de drogas",      3, 4000,  40 },
    ["sequestro"]       = { "Sequestro",              4, 8000,   0 },
}

-- Nível → cor HUD
WANTED_COLORS = {
    [1] = { 255, 220, 80  },
    [2] = { 255, 170, 40  },
    [3] = { 255, 110, 20  },
    [4] = { 220, 50,  50  },
    [5] = { 180, 0,   0   },
}

-- Bounty mínimo por nível (a parte de facção pode aumentar)
WANTED_BOUNTY_MIN = { 500, 1500, 3000, 7500, 15000 }

-- Recompensa base para quem prender (paga pelo banco da facção policial)
ARREST_REWARD_MULT = 1.2   -- 120% do bounty base

-- Decaimento de wanted (nível 1-3 decaem; 4-5 são permanentes até prisão)
WANTED_DECAY_MIN = { 10, 20, 40, 0, 0 }
