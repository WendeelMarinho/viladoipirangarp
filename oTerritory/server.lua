-- ─── oTerritory / server.lua ─────────────────────────────────────────────────

local conn      = exports.oMysql:getDBConnection()
local dashboard = exports.oDashboard
local core      = exports.oCore
local color, r, g, b = core:getServerColor()

-- territories[id] = { id, name, x,y,z, radius, owner, last_captured, cooldown,
--                     income, allowed_types, blip_icon, cr, cg, cb, min_members, capture_secs,
--                     progress, capturing_faction, state }
local territories = {}

addEventHandler("onResourceStart", resourceRoot, function()
    color, r, g, b = core:getServerColor()
    loadTerritories()
    setTimer(captureTick, CAPTURE_TICK_MS, 0)
    setTimer(distributeIncomes, TERRITORY_INCOME_INTERVAL_MS, 0)
end)

-- ─── Carregar da DB ───────────────────────────────────────────────────────────

function loadTerritories()
    local rows = dbPoll(dbQuery(conn, "SELECT * FROM territories"), 500) or {}
    for _, v in ipairs(rows) do
        local allowed = fromJSON(v.allowed_types) or DEFAULT_ALLOWED_TYPES
        territories[v.id] = {
            id               = v.id,
            name             = v.name,
            x                = v.zone_x, y = v.zone_y, z = v.zone_z,
            radius           = v.zone_radius,
            owner            = v.owner_faction,
            last_captured    = v.last_captured,
            cooldown         = v.cooldown_secs,
            income           = v.income_payday,
            allowed_types    = allowed,
            blip_icon        = v.blip_icon,
            cr = v.color_r, cg = v.color_g, cb = v.color_b,
            min_members      = v.min_members,
            capture_secs     = v.capture_secs,
            -- Runtime
            progress         = 0,
            capturing_faction= 0,
            state            = v.owner_faction > 0 and TERR_STATE_OWNED or TERR_STATE_NEUTRAL,
        }
    end
    outputDebugString("[oTerritory] " .. #rows .. " território(s) carregado(s).")
    syncAll()
end

-- ─── API pública ──────────────────────────────────────────────────────────────

function getTerritoryOwner(id)
    return territories[id] and territories[id].owner or 0
end

function getPlayerTerritory(player)
    local px, py, pz = getElementPosition(player)
    for _, t in pairs(territories) do
        if getDistanceBetweenPoints3D(px, py, pz, t.x, t.y, t.z) <= t.radius then
            return t.id
        end
    end
    return nil
end

function getAllTerritories()
    return territories
end

-- Retorna bônus de payday (em $) para uma facção baseado nos territórios possuídos
function getTerritoryPaydayBonus(factionID)
    local bonus = 0
    for _, t in pairs(territories) do
        if t.owner == factionID then bonus = bonus + t.income end
    end
    return bonus
end

-- ─── Lógica de captura ────────────────────────────────────────────────────────

local function getPlayersInTerritory(t)
    local inside = {}   -- faction_id → { count, factionType }
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "user:loggedin") and (getElementData(p, "char:duty:faction") or 0) ~= 0 then
            local px, py, pz = getElementPosition(p)
            if getDistanceBetweenPoints3D(px, py, pz, t.x, t.y, t.z) <= t.radius then
                -- Verificar se a facção é permitida
                local factions = dashboard:getPlayerAllFactions(p)
                for _, fid in ipairs(factions) do
                    local ftype = dashboard:getFactionType(fid)
                    local allowed = false
                    for _, at in ipairs(t.allowed_types) do
                        if ftype == at then allowed = true; break end
                    end
                    if allowed then
                        if not inside[fid] then inside[fid] = { count=0, type=ftype } end
                        inside[fid].count = inside[fid].count + 1
                    end
                end
            end
        end
    end
    return inside
end

local function countFactions(tbl)
    local n = 0
    for _ in pairs(tbl) do n = n + 1 end
    return n
end

local function tickTerritory(id, t, now)
    -- Cooldown pós-captura
    if t.last_captured > 0 and (now - t.last_captured) < t.cooldown then
        if t.state ~= TERR_STATE_OWNED then
            t.state = TERR_STATE_OWNED
            syncTerritory(id)
        end
        return
    end

    local inside  = getPlayersInTerritory(t)
    local numFacs = countFactions(inside)

    if numFacs == 0 then
        if t.progress > 0 and t.capturing_faction ~= t.owner then
            t.progress = math.max(0, t.progress - (100 / t.capture_secs))
            if t.progress <= 0 then
                t.capturing_faction = 0
                t.state = t.owner > 0 and TERR_STATE_OWNED or TERR_STATE_NEUTRAL
            end
            syncTerritory(id)
        end
    elseif numFacs > 1 then
        if t.state ~= TERR_STATE_CONTESTED then
            t.state = TERR_STATE_CONTESTED
            syncTerritory(id)
        end
    else
        local fid, fdata = next(inside)
        if fdata.count < t.min_members and t.owner ~= fid then return end

        local isDefender   = fid == t.owner
        local speedMult    = isDefender and DEFEND_SPEED_MULT or 1.0
        local progressGain = (100 / t.capture_secs) * speedMult

        if t.capturing_faction ~= fid and not isDefender then
            t.capturing_faction = fid
            t.progress = 0
            t.state = TERR_STATE_CAPTURING
            notifyOwner(t, fid)
        end

        if not isDefender then
            t.progress = math.min(100, t.progress + progressGain)
            t.state = TERR_STATE_CAPTURING
            syncTerritory(id)
            if t.progress >= 100 then
                captureComplete(id, fid)
            end
        else
            if t.state ~= TERR_STATE_OWNED then
                t.state = TERR_STATE_OWNED
                syncTerritory(id)
            end
        end
    end
end

function captureTick()
    local now = getRealTime().timestamp
    for id, t in pairs(territories) do
        tickTerritory(id, t, now)
    end
end

function captureComplete(id, newOwner)
    local t   = territories[id]
    local old = t.owner
    t.owner            = newOwner
    t.progress         = 0
    t.capturing_faction= 0
    t.state            = TERR_STATE_OWNED
    t.last_captured    = getRealTime().timestamp

    -- Salvar DB
    dbExec(conn, "UPDATE territories SET owner_faction=?,last_captured=? WHERE id=?",
        newOwner, t.last_captured, id)

    -- Anunciar no chat
    local ownerName = dashboard:getFactionName(newOwner) or ("Facção #" .. newOwner)
    local oldName   = (old > 0) and (dashboard:getFactionName(old) or ("Facção #" .. old)) or "nenhuma"
    local msg = core:getServerPrefix("server", "Território", 3) ..
        color .. ownerName .. " #ffffffconquistou " ..
        color .. t.name .. " #ffffff(antes: " .. oldName .. ")."
    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox(msg, p, 255, 255, 255, true)
    end

    syncTerritory(id)
end

function notifyOwner(t, attackerFID)
    if t.owner == 0 then return end
    local ownerName    = dashboard:getFactionName(attackerFID) or "Desconhecido"
    local attackerName = ownerName

    -- SMS via oPhone para líderes da facção dona
    for _, p in ipairs(getElementsByType("player")) do
        if dashboard:isPlayerInFaction(p, t.owner) then
            local rank = dashboard:getPlayerRankInFaction(t.owner, p)
            if rank and rank >= 2 then   -- rank 2+ = liderança
                outputChatBox(core:getServerPrefix("red-dark", "Território", 3) ..
                    color .. t.name .. " #ffffffestá a ser atacada por " ..
                    color .. attackerName .. "#ffffff!", p, 255, 255, 255, true)
            end
        end
    end
end

-- ─── Sync ─────────────────────────────────────────────────────────────────────

function syncTerritory(id)
    local t = territories[id]
    if not t then return end
    triggerClientEvent(root, "oTerritory > sync", root, id, {
        owner    = t.owner,
        progress = t.progress,
        state    = t.state,
        cap_fac  = t.capturing_faction,
    })
end

function syncAll()
    local lite = {}
    for id, t in pairs(territories) do
        lite[id] = {
            id=t.id, name=t.name, x=t.x, y=t.y, z=t.z, radius=t.radius,
            owner=t.owner, progress=t.progress, state=t.state, cap_fac=t.capturing_faction,
            income=t.income, blip_icon=t.blip_icon, cr=t.cr, cg=t.cg, cb=t.cb,
        }
    end
    triggerClientEvent(root, "oTerritory > syncAll", root, lite)
end

addEventHandler("onElementDataChange", root, function(key, old, new)
    if key == "user:loggedin" and new == true then
        setTimer(function()
            if isElement(source) then syncAll() end
        end, 800, 1)
    end
end)

-- ─── Distribuição de renda de território ──────────────────────────────────────
-- Deposita income no banco de cada facção dona de territórios (a cada hora)
function distributeIncomes()
    local earned = {}   -- faction_id → total
    for _, t in pairs(territories) do
        if t.owner > 0 and t.income > 0 then
            earned[t.owner] = (earned[t.owner] or 0) + t.income
        end
    end

    for fid, amount in pairs(earned) do
        dashboard:setFactionBankMoney(fid, amount, "add")
        -- Notificar membros online
        for _, p in ipairs(getElementsByType("player")) do
            if dashboard:isPlayerInFaction(p, fid) then
                outputChatBox(core:getServerPrefix("server", "Território", 3) ..
                    color .. amount .. "$ #ffffffdepositado no banco da facção " ..
                    color .. (dashboard:getFactionName(fid) or "#"..fid) ..
                    " #ffffff(renda territorial).", p, 255, 255, 255, true)
            end
        end
    end
end
