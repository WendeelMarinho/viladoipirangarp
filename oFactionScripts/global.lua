-- ─── oFactionScripts / global.lua ────────────────────────────────────────────
-- Constantes partilhadas entre cliente e servidor.

ITEM_ALGEMAS        = 77    -- "Algemas"
ITEM_CHAVE_ALGEMAS  = 78    -- "Chave de algemas"
ITEM_KIT_PRIMEIROS  = 81    -- "Kit de primeiros socorros"

CUFF_ANIM_GROUP     = "CrckIdle"
CUFF_ANIM_NAME      = "crckidle4"
GRAB_OFFSET_X       = 0.55   -- attach offset: lado do policial
CUFF_MAX_DIST       = 4.0
REVIVE_MAX_DIST     = 4.0
REVIVE_DURATION_MS  = 8000   -- 8 s de animação de revivificação

-- Tipos de facção (mirror de factionGlobal.lua)
FACTION_TYPE_SEGURANCA  = 1
FACTION_TYPE_SAUDE      = 2
FACTION_TYPE_LEGAL      = 3
FACTION_TYPE_GANGUE     = 4
FACTION_TYPE_MAFIA      = 5
