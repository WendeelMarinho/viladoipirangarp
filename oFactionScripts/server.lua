-- ─── oFactionScripts / server.lua ────────────────────────────────────────────

local dashboard = exports.oDashboard
local core      = exports.oCore
local infobox   = exports.oInfobox
local color, r, g, b = core:getServerColor()

addEventHandler("onResourceStart", resourceRoot, function()
    color, r, g, b = core:getServerColor()
end)

-- ─── Helpers ─────────────────────────────────────────────────────────────────

function isInLawEnforcementDuty(player)
    local fid = getElementData(player, "char:duty:faction") or 0
    if fid == 0 then return false end
    local t = dashboard:getFactionType(fid)
    return t == FACTION_TYPE_SEGURANCA
end

function isInMedicalDuty(player)
    local fid = getElementData(player, "char:duty:faction") or 0
    if fid == 0 then return false end
    return dashboard:getFactionType(fid) == FACTION_TYPE_SAUDE
end

function getCuffedBy(player)
    return getElementData(player, "cuff:officer") or ""
end

local function pDist(a, b)
    local ax, ay, az = getElementPosition(a)
    local bx, by, bz = getElementPosition(b)
    return getDistanceBetweenPoints3D(ax, ay, az, bx, by, bz)
end

local function charName(player)
    return (getElementData(player, "char:name") or getPlayerName(player)):gsub("_", " ")
end

-- ─── Algemas ─────────────────────────────────────────────────────────────────

addEvent("oFS > cuff", true)
addEventHandler("oFS > cuff", resourceRoot, function(target)
    local officer = client
    if not isElement(target) or getElementType(target) ~= "player" then return end

    if not isInLawEnforcementDuty(officer) then
        infobox:outputInfoBox("Você precisa estar em serviço policial!", "error", officer)
        return
    end
    if pDist(officer, target) > CUFF_MAX_DIST then
        infobox:outputInfoBox("Jogador fora de alcance.", "error", officer)
        return
    end
    if getElementData(target, "cuff:cuffed") then
        infobox:outputInfoBox("Este jogador já está algemado.", "warning", officer)
        return
    end

    -- Consome a algema do inventário
    local hasItem = exports.oInventory:hasItem(ITEM_ALGEMAS, officer)
    if not hasItem then
        infobox:outputInfoBox("Você não tem algemas no inventário!", "error", officer)
        return
    end
    exports.oInventory:takeItem(ITEM_ALGEMAS, 1, nil, officer)

    setElementData(target, "cuff:cuffed",  true)
    setElementData(target, "cuff:officer", charName(officer))
    setElementData(target, "cuff:officerID", getElementData(officer, "char:id"))

    triggerClientEvent(root, "oFS > syncCuff", root, target, true)

    outputChatBox(core:getServerPrefix("blue-light-2", "Algemas", 3) ..
        color .. charName(officer) .. " #ffffffgeneralou " ..
        color .. charName(target) .. "#ffffff.", target, 255, 255, 255, true)

    infobox:outputInfoBox("Jogador algemado com sucesso.", "success", officer)
end)

-- ─── Remover algemas ─────────────────────────────────────────────────────────

addEvent("oFS > uncuff", true)
addEventHandler("oFS > uncuff", resourceRoot, function(target)
    local officer = client
    if not isElement(target) then return end
    if pDist(officer, target) > CUFF_MAX_DIST then
        infobox:outputInfoBox("Jogador fora de alcance.", "error", officer)
        return
    end
    if not getElementData(target, "cuff:cuffed") then
        infobox:outputInfoBox("Este jogador não está algemado.", "warning", officer)
        return
    end

    -- Policial ou a própria vítima com chave
    local canUncuff = isInLawEnforcementDuty(officer) or
                      (officer == target and exports.oInventory:hasItem(ITEM_CHAVE_ALGEMAS, officer))

    if not canUncuff then
        infobox:outputInfoBox("Você não tem autoridade ou chave para soltar.", "error", officer)
        return
    end

    -- Consome chave se não for policial
    if not isInLawEnforcementDuty(officer) then
        exports.oInventory:takeItem(ITEM_CHAVE_ALGEMAS, 1, nil, officer)
    end

    setElementData(target, "cuff:cuffed",   false)
    removeElementData(target, "cuff:officer")
    removeElementData(target, "cuff:officerID")

    -- Soltar grab se ainda estiver sendo arrastado
    if isElement(getElementData(target, "cuff:grabbedBy") or false) then
        local grabber = getElementData(target, "cuff:grabbedBy")
        triggerClientEvent(root, "oFS > syncGrab", root, target, grabber, false)
        removeElementData(target, "cuff:grabbedBy")
        removeElementData(grabber, "cuff:grabbing")
    end

    triggerClientEvent(root, "oFS > syncCuff", root, target, false)
    infobox:outputInfoBox("Algemas removidas.", "success", officer)
end)

-- ─── Grab (arrastar algemado) ─────────────────────────────────────────────────

addEvent("oFS > grab", true)
addEventHandler("oFS > grab", resourceRoot, function(target)
    local grabber = client
    if not isElement(target) then return end
    if not getElementData(target, "cuff:cuffed") then
        infobox:outputInfoBox("O jogador precisa estar algemado!", "warning", grabber)
        return
    end
    if pDist(grabber, target) > CUFF_MAX_DIST then
        infobox:outputInfoBox("Jogador fora de alcance.", "error", grabber)
        return
    end
    if getElementData(grabber, "cuff:grabbing") then
        infobox:outputInfoBox("Você já está a arrastar alguém.", "warning", grabber)
        return
    end

    setElementData(target,  "cuff:grabbedBy", grabber)
    setElementData(grabber, "cuff:grabbing",  target)

    triggerClientEvent(root, "oFS > syncGrab", root, target, grabber, true)
    infobox:outputInfoBox("A arrastar " .. charName(target) .. ".", "success", grabber)
end)

-- ─── Unleash (largar algemado) ────────────────────────────────────────────────

addEvent("oFS > unleash", true)
addEventHandler("oFS > unleash", resourceRoot, function(target)
    local grabber = client
    if not isElement(target) then return end

    removeElementData(target,  "cuff:grabbedBy")
    removeElementData(grabber, "cuff:grabbing")

    triggerClientEvent(root, "oFS > syncGrab", root, target, grabber, false)
    infobox:outputInfoBox("Jogador largado.", "success", grabber)
end)

-- ─── Revivificação (médico) ───────────────────────────────────────────────────

addEvent("oFS > revive", true)
addEventHandler("oFS > revive", resourceRoot, function(target)
    local medic = client
    if not isElement(target) or getElementType(target) ~= "player" then return end

    if not isInMedicalDuty(medic) then
        infobox:outputInfoBox("Apenas médicos de plantão podem reanimar!", "error", medic)
        return
    end
    if pDist(medic, target) > REVIVE_MAX_DIST then
        infobox:outputInfoBox("Paciente fora de alcance.", "error", medic)
        return
    end
    if not getElementData(target, "playerInAnim") then
        infobox:outputInfoBox("O jogador não precisa de reanimação.", "warning", medic)
        return
    end
    if getElementData(target, "revive:inProgress") then
        infobox:outputInfoBox("Reanimação já em curso.", "warning", medic)
        return
    end

    -- Consome kit de primeiros socorros (opcional: se tiver)
    local usedKit = false
    if exports.oInventory:hasItem(ITEM_KIT_PRIMEIROS, medic) then
        exports.oInventory:takeItem(ITEM_KIT_PRIMEIROS, 1, nil, medic)
        usedKit = true
    end

    setElementData(target, "revive:inProgress", true)
    setElementData(target, "revive:medic", getElementData(medic, "char:id"))

    triggerClientEvent(root, "oFS > syncRevive", root, target, medic, true, REVIVE_DURATION_MS)

    setTimer(function()
        if not isElement(target) or not isElement(medic) then return end
        -- Reanimação concluída
        setElementData(target, "playerInAnim",     false)
        setElementData(target, "revive:inProgress",false)
        removeElementData(target, "revive:medic")

        setElementHealth(target, 50)
        setElementData(target, "char:blood", math.max(30, getElementData(target, "char:blood") or 30))

        triggerClientEvent(root, "oFS > syncRevive", root, target, medic, false, 0)

        outputChatBox(core:getServerPrefix("green-dark", "Médico", 2) ..
            color .. charName(medic) .. " #ffffffreanimou " ..
            color .. charName(target) .. "#ffffff.", target, 255, 255, 255, true)

        local score = (getElementData(medic, "rp:activityScore") or 0) + 2
        setElementData(medic, "rp:activityScore", score)
        infobox:outputInfoBox("Reanimação concluída!", "success", medic)
    end, REVIVE_DURATION_MS, 1)
end)

-- Cleanup ao desconectar
addEventHandler("onPlayerQuit", root, function()
    local player = source
    -- Soltar quem estava a ser arrastado
    local grabbing = getElementData(player, "cuff:grabbing")
    if grabbing and isElement(grabbing) then
        removeElementData(grabbing, "cuff:grabbedBy")
        triggerClientEvent(root, "oFS > syncGrab", root, grabbing, player, false)
    end
end)

-- ─── Prisão / Detenção ────────────────────────────────────────────────────────
-- /prender — oficial processa o jogador algemado
addCommandHandler("prender", function(officer, _, targetPartial)
    if not isInLawEnforcementDuty(officer) then
        infobox:outputInfoBox("Precisa estar em serviço policial.", "error", officer)
        return
    end

    -- Encontrar target próximo e algemado
    local target = nil
    if targetPartial then
        for _, p in ipairs(getElementsByType("player")) do
            local n = (getElementData(p, "char:name") or getPlayerName(p)):lower()
            if n:find(targetPartial:lower(), 1, true) and getElementData(p, "cuff:cuffed") then
                target = p; break
            end
        end
    else
        -- Target mais próximo algemado
        local ox, oy, oz = getElementPosition(officer)
        local best = CUFF_MAX_DIST * 3
        for _, p in ipairs(getElementsByType("player")) do
            if p ~= officer and getElementData(p, "cuff:cuffed") then
                local d = getDistanceBetweenPoints3D(ox, oy, oz, getElementPosition(p))
                if d < best then best = d; target = p end
            end
        end
    end

    if not target then
        infobox:outputInfoBox("Nenhum detido próximo encontrado.", "warning", officer)
        return
    end

    local officerName = (getElementData(officer, "char:name") or getPlayerName(officer)):gsub("_", " ")
    local targetName  = (getElementData(target,  "char:name") or getPlayerName(target)):gsub("_", " ")

    -- Limpar algemas
    setElementData(target, "cuff:cuffed",  false)
    removeElementData(target, "cuff:officer")
    removeElementData(target, "cuff:officerID")
    triggerClientEvent(root, "oFS > syncCuff", root, target, false)

    -- Limpar wanted
    if exports.oWanted:isWanted(target) then
        exports.oWanted:clearWanted(target, officer)
        infobox:outputInfoBox("Detido processado e wanted limpo.", "success", officer)
    else
        infobox:outputInfoBox("Detido processado (sem wanted ativo).", "success", officer)
    end

    -- Anunciar
    outputChatBox(core:getServerPrefix("blue-light-2", "Prisão", 2) ..
        color .. officerName .. " #ffffffdeteve " ..
        color .. targetName .. "#ffffff.", root, 255, 255, 255, true)

    -- Contar atividade RP do policial
    local score = (getElementData(officer, "rp:activityScore") or 0) + 3
    setElementData(officer, "rp:activityScore", score)
end)

-- Contar atividade RP por algema
addEventHandler("onElementDataChange", root, function(key, old, new)
    if key == "cuff:cuffed" and new == true then
        local officerID = getElementData(source, "cuff:officerID")
        if officerID then
            for _, p in ipairs(getElementsByType("player")) do
                if getElementData(p, "char:id") == officerID then
                    local score = (getElementData(p, "rp:activityScore") or 0) + 1
                    setElementData(p, "rp:activityScore", score)
                    break
                end
            end
        end
    end
end)
