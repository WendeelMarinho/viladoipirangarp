-- ─── oFactionHQ / server.lua ─────────────────────────────────────────────────

local conn      = exports.oMysql:getDBConnection()
local dashboard = exports.oDashboard
local core      = exports.oCore
local infobox   = exports.oInfobox
local color, r, g, b = core:getServerColor()

-- hqData[faction_id] = { id, gate_ids[], ammo_x/y/z, veh_spawns[], min_rank_*, is_active }
local hqData      = {}
-- Cooldown de munição: char_id → last_ammo_tick
local ammoCooldowns = {}

addEventHandler("onResourceStart", resourceRoot, function()
    color, r, g, b = core:getServerColor()
    loadHQs()
end)

-- ─── Carregar HQs ────────────────────────────────────────────────────────────

function loadHQs()
    local rows = dbPoll(dbQuery(conn, "SELECT * FROM faction_hq WHERE is_active=1"), 500) or {}
    for _, v in ipairs(rows) do
        hqData[v.faction_id] = {
            id           = v.id,
            faction_id   = v.faction_id,
            gate_ids     = fromJSON(v.gate_ids)  or {},
            ammo_x       = v.ammo_x, ammo_y = v.ammo_y, ammo_z = v.ammo_z,
            ammo_dim     = v.ammo_dim, ammo_int = v.ammo_int,
            veh_spawns   = fromJSON(v.veh_spawns) or {},
            min_rank_gate= v.min_rank_gate,
            min_rank_ammo= v.min_rank_ammo,
            min_rank_veh = v.min_rank_veh,
        }
    end
    outputDebugString("[oFactionHQ] " .. #rows .. " HQ(s) carregada(s).")
    triggerClientEvent(root, "oFactionHQ > syncAll", root, hqData)
end

-- ─── API pública ──────────────────────────────────────────────────────────────

function canOpenGate(player, gateID)
    for fid, hq in pairs(hqData) do
        for _, gid in ipairs(hq.gate_ids) do
            if gid == gateID then
                if dashboard:isPlayerInFaction(player, fid) then
                    local rank = dashboard:getPlayerRankInFaction(fid, player) or 0
                    return rank >= hq.min_rank_gate
                end
                return false
            end
        end
    end
    return false  -- portão não pertence a nenhuma HQ registrada
end

function isInFactionHQ(player)
    local px, py, pz = getElementPosition(player)
    local pint = getElementInterior(player)
    local pdim = getElementDimension(player)
    for fid, hq in pairs(hqData) do
        if hq.ammo_x ~= 0 then
            if getDistanceBetweenPoints3D(px, py, pz, hq.ammo_x, hq.ammo_y, hq.ammo_z) <= 25
               and pint == hq.ammo_int and pdim == hq.ammo_dim then
                return fid
            end
        end
    end
    return nil
end

function getHQByFaction(fid)
    return hqData[fid]
end

-- ─── Ponto de munição ─────────────────────────────────────────────────────────

addEvent("oFactionHQ > useAmmoPoint", true)
addEventHandler("oFactionHQ > useAmmoPoint", resourceRoot, function()
    local player = client
    local fid    = nil
    -- Qual HQ está próxima?
    local px_, py_, pz_ = getElementPosition(player)
    for fid_, hq in pairs(hqData) do
        if hq.ammo_x ~= 0 and
           getDistanceBetweenPoints3D(px_, py_, pz_, hq.ammo_x, hq.ammo_y, hq.ammo_z) <= AMMO_INTERACT_DIST
           and getElementInterior(player) == hq.ammo_int
           and getElementDimension(player) == hq.ammo_dim then
            fid = fid_
            break
        end
    end

    if not fid then
        infobox:outputInfoBox("Não está num ponto de munição.", "error", player)
        return
    end

    -- Verificar se é membro da facção com rank mínimo
    if not dashboard:isPlayerInFaction(player, fid) then
        infobox:outputInfoBox("Esta HQ não é da sua facção.", "error", player)
        return
    end
    local rank = dashboard:getPlayerRankInFaction(fid, player) or 0
    if rank < hqData[fid].min_rank_ammo then
        infobox:outputInfoBox("Rank insuficiente para usar este ponto.", "warning", player)
        return
    end

    -- Cooldown
    local cid  = getElementData(player, "char:id")
    local last = ammoCooldowns[cid] or 0
    local now  = getTickCount()
    if (now - last) < AMMO_COOLDOWN_MS then
        local remaining = math.ceil((AMMO_COOLDOWN_MS - (now - last)) / 60000)
        infobox:outputInfoBox("Aguarde " .. remaining .. " min para recarregar.", "warning", player)
        return
    end
    ammoCooldowns[cid] = now

    -- Dar itens de munição conforme tipo de facção
    local ftype  = dashboard:getFactionType(fid) or 1
    local items  = HQ_AMMO_ITEMS[ftype] or HQ_AMMO_ITEMS[1]
    for _, itemID in ipairs(items) do
        exports.oInventory:giveItem(player, itemID, 100, 1, 0)
    end

    infobox:outputInfoBox("Equipamento reabastecido!", "success", player)
    outputChatBox(core:getServerPrefix("server", "HQ", 3) ..
        color .. (getElementData(player,"char:name") or "?"):gsub("_"," ") ..
        " #ffffffreabasteceu na HQ.", player, 255, 255, 255, true)
end)

-- ─── Spawn de veículos da facção ──────────────────────────────────────────────

addEvent("oFactionHQ > spawnFactionVehicle", true)
addEventHandler("oFactionHQ > spawnFactionVehicle", resourceRoot, function(spawnIndex)
    local player = client

    -- Encontrar HQ do jogador
    local myFID, myHQ = nil, nil
    for fid, hq in pairs(hqData) do
        if dashboard:isPlayerInFaction(player, fid) then
            local rank = dashboard:getPlayerRankInFaction(fid, player) or 0
            if rank >= hq.min_rank_veh and #hq.veh_spawns > 0 then
                myFID = fid; myHQ = hq; break
            end
        end
    end

    if not myHQ then
        infobox:outputInfoBox("Sem acesso a veículos de HQ.", "error", player)
        return
    end

    local spawn = myHQ.veh_spawns[spawnIndex]
    if not spawn then
        infobox:outputInfoBox("Slot de veículo inválido.", "error", player)
        return
    end

    -- Verificar se já tem veículo de serviço spawned
    if getElementData(player, "hq:activeFactionVeh") then
        infobox:outputInfoBox("Você já tem um veículo de serviço activo.", "warning", player)
        return
    end

    local veh = createVehicle(spawn.model, spawn.x, spawn.y, spawn.z, 0, 0, spawn.rot or 0)
    if not isElement(veh) then
        infobox:outputInfoBox("Falha ao criar veículo.", "error", player)
        return
    end

    setElementDimension(veh, spawn.dim or 0)
    setElementInterior(veh, spawn.int or 0)
    setElementData(veh, "veh:factionHQ",  myFID)
    setElementData(veh, "veh:owner",      getElementData(player, "char:id"))
    setElementData(player, "hq:activeFactionVeh", veh)

    infobox:outputInfoBox("Veículo de serviço criado.", "success", player)
end)

-- Destruir veículo de serviço ao sair
addEventHandler("onPlayerQuit", root, function()
    local veh = getElementData(source, "hq:activeFactionVeh")
    if veh and isElement(veh) then destroyElement(veh) end
end)

-- ─── Comandos admin para configurar HQ ───────────────────────────────────────

addCommandHandler("hqsetup", function(admin, _, fid)
    fid = tonumber(fid)
    if not fid then
        outputChatBox("[HQ] Uso: /hqsetup <faction_id>", admin)
        return
    end
    if (getElementData(admin, "user:admin") or 0) < 6 then
        outputChatBox("[HQ] Nível admin 6+ necessário.", admin)
        return
    end

    -- Criar entrada HQ para esta facção se não existir
    local _, _, insertID = dbPoll(dbQuery(conn,
        "INSERT IGNORE INTO faction_hq (faction_id, gate_ids, veh_spawns) VALUES (?,?,?)",
        fid, "[]", "[]"), 200)

    local row = dbPoll(dbQuery(conn, "SELECT * FROM faction_hq WHERE faction_id=?", fid), 200)
    if row and row[1] then
        hqData[fid] = {
            id           = row[1].id,
            faction_id   = fid,
            gate_ids     = fromJSON(row[1].gate_ids) or {},
            ammo_x=0, ammo_y=0, ammo_z=0, ammo_dim=0, ammo_int=0,
            veh_spawns   = fromJSON(row[1].veh_spawns) or {},
            min_rank_gate=1, min_rank_ammo=1, min_rank_veh=1,
        }
        outputChatBox("[HQ] HQ da facção " .. fid .. " configurada. Use /hqgate /hqammo /hqveh.", admin)
        triggerClientEvent(root, "oFactionHQ > syncAll", root, hqData)
    end
end)

addCommandHandler("hqgate", function(admin, _, fid, gateID)
    fid    = tonumber(fid)
    gateID = tonumber(gateID)
    if not fid or not gateID then outputChatBox("[HQ] Uso: /hqgate <faction_id> <gate_db_id>", admin); return end
    if (getElementData(admin, "user:admin") or 0) < 6 then return end
    if not hqData[fid] then outputChatBox("[HQ] HQ não encontrada para facção " .. fid, admin); return end

    local gates = hqData[fid].gate_ids
    -- Adicionar se não existir
    local found = false
    for _, g in ipairs(gates) do if g == gateID then found = true; break end end
    if not found then table.insert(gates, gateID) end

    dbExec(conn, "UPDATE faction_hq SET gate_ids=? WHERE faction_id=?", toJSON(gates), fid)
    outputChatBox("[HQ] Portão " .. gateID .. " adicionado à HQ da facção " .. fid .. ".", admin)
end)

addCommandHandler("hqammo", function(admin)
    if (getElementData(admin, "user:admin") or 0) < 6 then return end
    local fid = isInFactionHQ(admin)
    if not fid then
        -- Usar posição actual
        -- Perguntar para qual facção
        outputChatBox("[HQ] Não está dentro de uma HQ conhecida. Adicione primeiro via /hqsetup.", admin)
        return
    end
    local x, y, z = getElementPosition(admin)
    local int = getElementInterior(admin)
    local dim = getElementDimension(admin)
    hqData[fid].ammo_x = x; hqData[fid].ammo_y = y; hqData[fid].ammo_z = z
    hqData[fid].ammo_dim = dim; hqData[fid].ammo_int = int
    dbExec(conn, "UPDATE faction_hq SET ammo_x=?,ammo_y=?,ammo_z=?,ammo_dim=?,ammo_int=? WHERE faction_id=?",
        x, y, z, dim, int, fid)
    triggerClientEvent(root, "oFactionHQ > syncAll", root, hqData)
    outputChatBox("[HQ] Ponto de munição definido na sua posição actual (Facção " .. fid .. ").", admin)
end)

-- /hqveh <faction_id> <model> — cria spawn de veículo na posição actual do admin
addCommandHandler("hqveh", function(admin, _, fid, model)
    fid   = tonumber(fid)
    model = tonumber(model)
    if not fid or not model then outputChatBox("[HQ] Uso: /hqveh <faction_id> <model_id>", admin); return end
    if (getElementData(admin, "user:admin") or 0) < 6 then return end
    if not hqData[fid] then outputChatBox("[HQ] HQ não encontrada para facção " .. fid, admin); return end

    local x, y, z = getElementPosition(admin)
    local rot = getPedRotation(admin)
    local dim = getElementDimension(admin)
    local int = getElementInterior(admin)
    local spawns = hqData[fid].veh_spawns
    table.insert(spawns, { model=model, x=x, y=y, z=z, rot=rot, dim=dim, int=int })
    dbExec(conn, "UPDATE faction_hq SET veh_spawns=? WHERE faction_id=?", toJSON(spawns), fid)
    triggerClientEvent(root, "oFactionHQ > syncAll", root, hqData)
    outputChatBox("[HQ] Spawn de veículo " .. model .. " adicionado (slot " .. #spawns .. ").", admin)
end)
