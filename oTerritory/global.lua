-- ─── oTerritory / global.lua ─────────────────────────────────────────────────

CAPTURE_TICK_MS          = 1000         -- avalia presença a cada 1 s
DEFEND_SPEED_MULT        = 1.5          -- defensores capturam 1.5× mais rápido
COOLDOWN_AFTER_CAP       = 1800         -- 30 min de cooldown após captura
MIN_MEMBERS_CAP          = 2            -- mínimo de membros para começar captura
TERRITORY_INCOME_INTERVAL_MS = 3600000  -- deposita renda no banco da facção a cada hora

-- Estados de território
TERR_STATE_NEUTRAL   = "neutral"
TERR_STATE_CONTESTED = "contested"
TERR_STATE_CAPTURING = "capturing"
TERR_STATE_OWNED     = "owned"

-- Tipos permitidos por defeito (gangues + máfias)
DEFAULT_ALLOWED_TYPES = { 4, 5 }
