-- ─── oFactionScripts / client.lua ────────────────────────────────────────────

local core    = exports.oCore
local infobox = exports.oInfobox

-- ─── Exports chamados por usedButton.lua ─────────────────────────────────────

function cuffPlayer(target)
    if not isElement(target) then return end
    if getElementData(target, "cuff:cuffed") then
        triggerServerEvent("oFS > uncuff", localPlayer, target)
    else
        triggerServerEvent("oFS > cuff", localPlayer, target)
    end
end

function grabPlayer(target)
    if not isElement(target) then return end
    triggerServerEvent("oFS > grab", localPlayer, target)
end

function unleashPlayer(target)
    if not isElement(target) then return end
    triggerServerEvent("oFS > unleash", localPlayer, target)
end

function startPlayerRevivification(target)
    if not isElement(target) then return end
    triggerServerEvent("oFS > revive", localPlayer, target)
end

-- Stubs — implementação futura via issues do sprint
local function stub(nome)
    return function() infobox:outputInfoBox(nome .. " — em desenvolvimento.", "info") end
end

getStingerFromVeh        = stub("Stinger")
getSpeedcamFromVehicle   = stub("Câmera de velocidade")
showRBSPanel             = stub("Painel RBS")
pickUpRBS                = stub("Pegar RBS")
connectHose              = stub("Mangueira")
connectHoseToVeh         = stub("Mangueira no veículo")
unConnectHoseFromVeh     = stub("Desligar mangueira do veículo")
unConnectHose            = stub("Desligar mangueira")
attachDollyToPlayer      = stub("Dolly")
pickupDrum               = stub("Tambor de óleo")
takeDownDrum             = stub("Baixar tambor de óleo")
pickupFuelDrum           = stub("Tambor de combustível")
takeDownFuelDrum         = stub("Baixar tambor de combustível")

-- ─── Sync de algemas (recebido do servidor) ───────────────────────────────────

addEvent("oFS > syncCuff", true)
addEventHandler("oFS > syncCuff", root, function(target, state)
    if not isElement(target) then return end
    if state then
        setPedAnimation(target, CUFF_ANIM_GROUP, CUFF_ANIM_NAME, -1, true, false, false, false)
        -- Bloquear movimento
        if target == localPlayer then
            setElementData(localPlayer, "player:animation", true)
        end
    else
        setPedAnimation(target, false)
        if target == localPlayer then
            setElementData(localPlayer, "player:animation", false)
        end
        -- Garantir que attach é removido
        if isAttached(target) then
            detachElements(target)
        end
    end
end)

-- ─── Sync de grab ─────────────────────────────────────────────────────────────

addEvent("oFS > syncGrab", true)
addEventHandler("oFS > syncGrab", root, function(target, grabber, state)
    if not isElement(target) or not isElement(grabber) then return end
    if state then
        attachElements(target, grabber, GRAB_OFFSET_X, 0.0, 0.0, 0, 0, 0)
    else
        if isAttached(target) then
            detachElements(target)
        end
    end
end)

-- ─── Sync de revivificação ─────────────────────────────────────────────────────

addEvent("oFS > syncRevive", true)
addEventHandler("oFS > syncRevive", root, function(target, medic, starting, duration)
    if not isElement(target) or not isElement(medic) then return end
    if starting then
        -- Médico agacha e faz animação de primeiros socorros
        setPedAnimation(medic, "MEDIC", "CPR", duration, false, false, false, false)
        -- Barra de progresso para o médico
        if medic == localPlayer then
            core:createProgressBar("Reanimando...", duration, "nil", true)
        end
    else
        setPedAnimation(medic, false)
        -- Levantar o paciente
        setPedAnimation(target, false)
    end
end)
