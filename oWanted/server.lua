-- ─── oWanted / server.lua ────────────────────────────────────────────────────

local conn      = exports.oMysql:getDBConnection()
local dashboard = exports.oDashboard
local core      = exports.oCore
local infobox   = exports.oInfobox
local color, r, g, b = core:getServerColor()

-- Cache em memória: char_id → { level, bounty, crimes[], expires_at, db_id }
local wantedCache = {}

addEventHandler("onResourceStart", resourceRoot, function()
    color, r, g, b = core:getServerColor()
    loadWantedFromDB()
    -- Timer de decaimento: verifica a cada minuto
    setTimer(decayWantedLevels, 60000, 0)
end)

-- ─── DB Load ─────────────────────────────────────────────────────────────────

function loadWantedFromDB()
    local q = dbQuery(conn, "SELECT * FROM wanted_active")
    local rows = dbPoll(q, 500) or {}
    local now = getRealTime().timestamp
    for _, v in ipairs(rows) do
        local cid = v.char_id
        -- Limpar expirados
        if tonumber(v.expires_at) > 0 and tonumber(v.expires_at) <= now then
            dbExec(conn, "DELETE FROM wanted_active WHERE id=?", v.id)
        else
            wantedCache[cid] = {
                level      = tonumber(v.crime_level) or 1,
                bounty     = tonumber(v.bounty)      or 0,
                crimes     = fromJSON(v.crimes)       or {},
                expires_at = tonumber(v.expires_at)  or 0,
                db_id      = tonumber(v.id),
                char_name  = v.char_name,
                skin       = tonumber(v.skin) or 0,
            }
        end
    end
    outputDebugString("[oWanted] " .. #rows .. " procurado(s) carregado(s) da DB.")
    syncAllToClients()
end

-- ─── API pública ──────────────────────────────────────────────────────────────

-- addCrime(player, crimeKey) → adiciona crime ao jogador, aumenta wanted level
function addCrime(player, crimeKey)
    if not isElement(player) or not getElementData(player, "user:loggedin") then return end
    local crimeDef = CRIMES[crimeKey]
    if not crimeDef then
        outputDebugString("[oWanted] Crime key desconhecido: " .. tostring(crimeKey), 1)
        return
    end

    local cid       = getElementData(player, "char:id")
    local charName  = (getElementData(player, "char:name") or getPlayerName(player)):gsub("_", " ")
    local skin      = getElementModel(player)
    local entry     = wantedCache[cid]
    local now       = getRealTime().timestamp

    if not entry then
        entry = { level = 0, bounty = 0, crimes = {}, expires_at = 0, db_id = nil,
                  char_name = charName, skin = skin }
        wantedCache[cid] = entry
    end

    -- Atualizar nível
    local newLevel = math.min(5, math.max(entry.level, crimeDef[2]))
    entry.level    = newLevel
    entry.bounty   = math.max(entry.bounty, WANTED_BOUNTY_MIN[newLevel])
    entry.bounty   = entry.bounty + math.floor(crimeDef[3] * 0.25)  -- bônus cumulativo
    entry.char_name = charName
    entry.skin      = skin

    -- Adicionar crime à lista (máx 8)
    local already = false
    for _, c in ipairs(entry.crimes) do
        if c == crimeDef[1] then already = true; break end
    end
    if not already then
        table.insert(entry.crimes, crimeDef[1])
        if #entry.crimes > 8 then table.remove(entry.crimes, 1) end
    end

    -- Expiração
    local decayMin = WANTED_DECAY_MIN[newLevel]
    entry.expires_at = decayMin > 0 and (now + decayMin * 60) or 0

    -- Salvar DB
    if entry.db_id then
        dbExec(conn, "UPDATE wanted_active SET crime_level=?,bounty=?,crimes=?,expires_at=?,skin=? WHERE id=?",
            entry.level, entry.bounty, toJSON(entry.crimes), entry.expires_at, entry.skin, entry.db_id)
    else
        local _, _, insertID = dbPoll(dbQuery(conn,
            "INSERT INTO wanted_active (char_id,char_name,skin,crime_level,bounty,crimes,issued_at,expires_at) VALUES (?,?,?,?,?,?,?,?)",
            cid, charName, skin, entry.level, entry.bounty, toJSON(entry.crimes), now, entry.expires_at), 200)
        entry.db_id = insertID
    end

    -- Sincronizar
    syncPlayerWanted(player, entry)
    notifyPolice(player, charName, entry)
end

-- clearWanted(player, officerName) → limpa procurado e paga bounty ao policial
function clearWanted(player, officerPlayer)
    if not isElement(player) then return end
    local cid   = getElementData(player, "char:id")
    local entry = wantedCache[cid]
    if not entry then return end

    local bounty = entry.bounty

    -- Pagar bounty ao policial ou facção
    if officerPlayer and isElement(officerPlayer) then
        local fid = getElementData(officerPlayer, "char:duty:faction") or 0
        if fid > 0 then
            local reward = math.floor(bounty * ARREST_REWARD_MULT)
            setElementData(officerPlayer, "char:money",
                (getElementData(officerPlayer, "char:money") or 0) + reward)
            infobox:outputInfoBox("Prisão efetuada! Recompensa: R$" .. reward, "success", officerPlayer)
        end
    end

    -- Limpar MDC wanted
    if entry.db_id then
        dbExec(conn, "DELETE FROM wanted_active WHERE id=?", entry.db_id)
    end
    wantedCache[cid] = nil

    -- Sincronizar clientes
    triggerClientEvent(root, "oWanted > cleared", root, getElementData(player, "char:id"))
    outputChatBox(core:getServerPrefix("blue-light-2", "Procurado", 3) ..
        color .. (entry.char_name or "?") .. " #ffffffnão é mais procurado.", root, 255, 255, 255, true)
end

function getWantedLevel(player)
    local cid = getElementData(player, "char:id")
    return (wantedCache[cid] or {}).level or 0
end

function isWanted(player)
    return getWantedLevel(player) > 0
end

function getBounty(player)
    local cid = getElementData(player, "char:id")
    return (wantedCache[cid] or {}).bounty or 0
end

-- ─── Sync ─────────────────────────────────────────────────────────────────────

function syncPlayerWanted(player, entry)
    -- Para o próprio
    triggerClientEvent(player, "oWanted > update", player,
        getElementData(player, "char:id"), entry.level, entry.bounty, entry.crimes)
    -- Para todos (blip)
    triggerClientEvent(root, "oWanted > updatePublic", root,
        getElementData(player, "char:id"), player, entry.level)
end

function syncAllToClients()
    for cid, entry in pairs(wantedCache) do
        -- Encontrar o player online
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "char:id") == cid then
                syncPlayerWanted(p, entry)
                break
            end
        end
    end
end

function notifyPolice(criminal, criminalName, entry)
    local crimesStr = table.concat(entry.crimes, ", ")
    local cx, cy = getElementPosition(criminal)
    for _, p in ipairs(getElementsByType("player")) do
        if exports.oFactionScripts:isInLawEnforcementDuty(p) then
            outputChatBox(core:getServerPrefix("blue-light-2", "Procurado", 3) ..
                color .. criminalName .. " #ffffff[" .. entry.level .. "★] — " ..
                crimesStr .. " — Bounty: R$" .. entry.bounty, p, 255, 255, 255, true)
        end
    end
end

-- ─── Decaimento automático ────────────────────────────────────────────────────

function decayWantedLevels()
    local now = getRealTime().timestamp
    for cid, entry in pairs(wantedCache) do
        if entry.expires_at > 0 and entry.expires_at <= now then
            -- Nível decai 1 patamar
            if entry.level > 1 then
                entry.level    = entry.level - 1
                entry.bounty   = WANTED_BOUNTY_MIN[entry.level]
                local decayMin = WANTED_DECAY_MIN[entry.level]
                entry.expires_at = decayMin > 0 and (now + decayMin * 60) or 0
                dbExec(conn, "UPDATE wanted_active SET crime_level=?,bounty=?,expires_at=? WHERE id=?",
                    entry.level, entry.bounty, entry.expires_at, entry.db_id)
                -- Sync
                for _, p in ipairs(getElementsByType("player")) do
                    if getElementData(p, "char:id") == cid then
                        syncPlayerWanted(p, entry)
                        break
                    end
                end
            else
                -- Nível 1 expirou: remover
                dbExec(conn, "DELETE FROM wanted_active WHERE id=?", entry.db_id)
                wantedCache[cid] = nil
                triggerClientEvent(root, "oWanted > cleared", root, cid)
            end
        end
    end
end

-- ─── Eventos de crime automáticos ─────────────────────────────────────────────
-- Outros recursos chamam addCrime via export. Este bloco adiciona listners diretos.

-- Fugir do policial (detecção simples: policial a <15m e jogador não-policial correu)
addEvent("oWanted > reportCrime", true)
addEventHandler("oWanted > reportCrime", resourceRoot, function(crimeKey)
    if client ~= source then return end
    addCrime(client, crimeKey)
end)

-- Prisão efetuada via cuff + detain (chamado por oFactionScripts quando preso na cela)
addEvent("oWanted > arrest", true)
addEventHandler("oWanted > arrest", resourceRoot, function(criminal)
    if not isElement(criminal) then return end
    clearWanted(criminal, client)
end)

-- Quando jogador faz login: sync do wanted se tiver
addEventHandler("onElementDataChange", root, function(key, old, new)
    if key == "user:loggedin" and new == true then
        local player = source
        local cid    = getElementData(player, "char:id")
        if wantedCache[cid] then
            local entry = wantedCache[cid]
            setTimer(function()
                if isElement(player) then
                    syncPlayerWanted(player, entry)
                end
            end, 500, 1)
            setTimer(function()
                if isElement(player) then
                    local stars = string.rep("★", entry.level) .. string.rep("☆", 5 - entry.level)
                    outputChatBox(core:getServerPrefix("red-dark", "Procurado", 3) ..
                        "#ff4444Você ainda é procurado! " .. stars ..
                        " · Bounty: R$" .. entry.bounty ..
                        " · Crimes: " .. table.concat(entry.crimes, ", "), player, 255, 255, 255, true)
                end
            end, 3000, 1)
        end
    end
end)

-- Quando policial mata alguém, registar homicídio automaticamente
addEventHandler("onPlayerWasted", root, function(totalAmmo, killer, killerWeapon, bodypart)
    local victim = source
    if not isElement(victim) or not isElement(killer) then return end
    if getElementType(killer) ~= "player" then return end
    if killer == victim then return end
    -- Só regista se o assassino é policial de serviço
    if exports.oFactionScripts:isInLawEnforcementDuty(killer) then return end
    -- Vítima é policial? Não registar
    if exports.oFactionScripts:isInLawEnforcementDuty(victim) then return end
    addCrime(victim, "homicidio")
end)

-- Policial mata civil → registar na vítima como morto por policial (para jail)
addEventHandler("onPlayerWasted", root, function(totalAmmo, killer, killerWeapon, bodypart)
    local victim = source
    if not isElement(victim) or not isElement(killer) then return end
    if getElementType(killer) ~= "player" then return end
    if killer == victim then return end
    if not exports.oFactionScripts:isInLawEnforcementDuty(killer) then return end
    -- Policial matou alguém que tinha wanted → bonus de bounty ao policial
    local cid = getElementData(victim, "char:id")
    if wantedCache[cid] then
        clearWanted(victim, killer)
    end
end)
