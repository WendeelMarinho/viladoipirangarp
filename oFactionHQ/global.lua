-- ─── oFactionHQ / global.lua ─────────────────────────────────────────────────

GATE_OPEN_DIST   = 8.0    -- distância para o portão abrir
AMMO_INTERACT_DIST = 3.0  -- distância para o ponto de munição
VEH_SPAWN_DIST   = 5.0    -- distância para o marker de spawn de veículo

-- Itens de munição que o ponto de HQ repõe, por tipo de facção
HQ_AMMO_ITEMS = {
    [1] = { 37, 28, 34 },    -- Forças de segurança: Colt-45, M4, Espingarda
    [2] = { 76, 81 },         -- Saúde: Remédio, Kit primeiros socorros
    [3] = { 37 },             -- Org. legal: Colt-45
    [4] = { 27, 30, 40 },    -- Gangue: AK-47, Desert Eagle, Tec9/UZI
    [5] = { 27, 28, 38 },    -- Máfia: AK-47, M4, Rifle de precisão
}

AMMO_COOLDOWN_MS = 300000  -- 5 min entre recargas
