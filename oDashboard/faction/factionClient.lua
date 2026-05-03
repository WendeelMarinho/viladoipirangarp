client_faction_list = {}
client_factionMember_list = {}

addEvent("getFactionsFromServer > Return", true)
addEventHandler("getFactionsFromServer > Return", root, function(factions)
    client_faction_list = factions

    refreshFactionList()
end)

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

addEvent("getFactionMembersFromServer > Return", true)
addEventHandler("getFactionMembersFromServer > Return", root, function(factionMembers)
    client_factionMember_list = factionMembers

    for k, v in pairs(client_factionMember_list) do 
        if v then 
            table.sort(v, tableSortRanks)
        end
    end
    getPlayerFactionDatas()

    --print("client: "..toJSON(client_factionMember_list))
end)

addEventHandler("onClientResourceStart", resourceRoot, function() 
    setTimer(getPlayerAllFactions, 1000, 1)
end)

function getPlayerAllFactions(player) 

    if not player then player = localPlayer end 

    local playerFactions = {}

    for keyFaction, factions in pairs(client_factionMember_list) do 
        if factions then 
            for key, member in ipairs(factions) do 

                if member[1] == getElementData(player, "char:id") then 
                    table.insert(playerFactions, #playerFactions+1, keyFaction)
                    break
                end

            end
        end
    end

    return playerFactions
end

function isPlayerOnline(charID)
    local online = false
    local player = false

    for k, v in ipairs(getElementsByType("player")) do 
        if getElementData(v, "user:loggedin") then 
            if getElementData(v, "char:id") == charID then 
                online = true 
                player = v
                break
            end
        end
    end    

    return online, player
end

function isPlayerLeader(factionID)
    for k, v in pairs(client_factionMember_list[factionID]) do 
        if v[1] == getElementData(localPlayer, "char:id") then 
            return v[3]
        end
    end
end

function getAllPlayerInRank(factionID, rankID)
    local num = 0 

    for k, v in pairs(client_factionMember_list[factionID]) do 
        if v[2] == rankID then 
            num = num + 1
        end
    end

    return num
end

function getFactionType(factionID)
    if client_faction_list[factionID] then 
        return client_faction_list[factionID][3]
    end
end

function getDutySkinFactionPlayer(factionId)
    for k, v in pairs(client_factionMember_list[factionId]) do 
        if v[1] == getElementData(localPlayer, "char:id") then 
            return v[10]
        end
    end
end

function isPlayerFactionMember(factionID)
    local playerFactions = getPlayerAllFactions() 

    local member = false 

    for k, v in ipairs(playerFactions) do 
        if v == factionID then 
            member = true 
            break 
        end
    end

    return member
end

function isPlayerFactionTypeMember(factionTypes)
    local playerFactions = getPlayerAllFactions()

    local member = false 
    for k, v in ipairs(playerFactions) do 
        if core:tableContains(factionTypes, getFactionType(v)) then 
            member = true 
            break 
        end
    end

    return member
end

function getOnlineFactionTypeMemberCount(factionTypes)
    local count = 0
    local checkedPlayers = {}

    for k, v in ipairs(getElementsByType("player")) do 
        --for k2, v2 in ipairs(getPlayerAllFactions(v)) do 
            if not core:tableContains(checkedPlayers, v) then 
                if core:tableContains(factionTypes, getFactionType(getElementData(v, "char:duty:faction"))) then
                    count = count + 1
                    table.insert(checkedPlayers, v)
                end 
            end
        --end
    end

    return count
end

function getFactionName(factionID)
    if client_faction_list[factionID] then 
        return client_faction_list[factionID][2]
    end
end

function getPlayerRankInFaction(factionID)
    if isPlayerFactionMember(factionID) then 
        for k, v in pairs(client_factionMember_list[factionID]) do 
            if v[1] == getElementData(localPlayer, "char:id") then 
                return v[2]
            end
        end
    end
end

function getFactionMoney(factionID)
    return client_faction_list[factionID][9]
end

function getAllSkinsFromFaction(factionId)
    if client_faction_list[factionId] then
        if client_faction_list[factionId][7][getPlayerRankInFaction(factionId)][3] > 0 then
            return client_faction_list[factionId][8][client_faction_list[factionId][7][getPlayerRankInFaction(factionId)][3]][3]
        else 
            return false
        end
    end
    return false
end

function getAllowedSkinsFaction(factionId)
    if client_faction_list[factionId] then
        return client_faction_list[factionId][4]
    end
end

-- / Duty marker / --
local sx, sy = guiGetScreenSize()
local myX, myY = 1600, 900

local choosableSkins
local jelenlegiDutySkin = 1
local starterSkin

local fonts = {
    ["condensed-12"] = font:getFont("condensed", 12),
}

local dutyMarkerID = 1

function renderFactionDutyTooltip()
    core:dxDrawShadowedText(getFactionName(dutyMarkerID), 0, sy*0.79, sx, sy*0.79+sy*0.05, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 1/myX*sx, fonts["condensed-12"], "center", "center")

    if isPlayerFactionMember(dutyMarkerID) then 
        core:dxDrawShadowedText("Para entrar em serviço pressione "..color.."[E]#ffffff.", 0, sy*0.82, sx, sy*0.82+sy*0.05, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 0.8/myX*sx, fonts["condensed-12"], "center", "center", false, false, false, true)
    else
        core:dxDrawShadowedText("#bd3131Você não é membro desta organização!", 0, sy*0.82, sx, sy*0.82+sy*0.05, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 0.8/myX*sx, fonts["condensed-12"], "center", "center", false, false, false, true)
    end
end

local dutyTimer = false
local inDutyTimer = false
local inDutyTime = 0
function factionDuty()
    if isPlayerFactionMember(dutyMarkerID) then 
        local dutyState = getElementData(localPlayer, "char:duty:faction") or 0 
--        print(dutyState)
        if dutyState == 0 then -- Entrar em plantão
            if not isTimer(dutyTimer) then 
                if client_faction_list[dutyMarkerID][7][getPlayerRankInFaction(dutyMarkerID)][3] > 0 then 
                    infobox:outputInfoBox("Você entrou em serviço!", "success")
                    outputChatBox(core:getServerPrefix("green-dark", "Facção", 2).."Você entrou em serviço!", 255, 255, 255, true)
                    if #client_faction_list[dutyMarkerID][8][client_faction_list[dutyMarkerID][7][getPlayerRankInFaction(dutyMarkerID)][3]][3] == 1 then 
                        triggerServerEvent("faction > setMemberDutyState", resourceRoot, dutyMarkerID, client_faction_list[dutyMarkerID][8][client_faction_list[dutyMarkerID][7][getPlayerRankInFaction(dutyMarkerID)][3]][3][1])
                        
                        inDutyTime = 0
                        inDutyTimer = setTimer(function()
                            inDutyTime = inDutyTime + 1
                        end, core:minToMilisec(1), 0)
                    else
                        --infobox:outputInfoBox("Vá até uma loja de roupas e escolha um skin de plantão.", "warning")
                        --outputChatBox(core:getServerPrefix("red-dark", "Facção", 2).."Vá até uma loja de roupas e escolha um skin de plantão.", 255, 255, 255, true)
                        choosableSkins = client_faction_list[dutyMarkerID][8][client_faction_list[dutyMarkerID][7][getPlayerRankInFaction(dutyMarkerID)][3]][3]
                        triggerServerEvent("faction > setMemberDutyState", resourceRoot, dutyMarkerID, 0)
                        startDutySkinChoosing()

                        removeEventHandler("onClientRender", root, renderFactionDutyTooltip)
                        unbindKey("e", "up", factionDuty)

                        inDutyTime = 0
                        inDutyTimer = setTimer(function()
                            inDutyTime = inDutyTime + 1
                        end, core:minToMilisec(1), 0)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Facção", 2).."Com este posto você não pode entrar em serviço! "..color.."("..client_faction_list[dutyMarkerID][7][getPlayerRankInFaction(dutyMarkerID)][1]..")", 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Facção", 2).."Só pode entrar em serviço a cada "..color.."1 #ffffffminuto!", 255, 255, 255, true)
            end
        elseif dutyState == dutyMarkerID then -- Sair do plantão
            infobox:outputInfoBox("Você saiu do serviço!", "success")
            outputChatBox(core:getServerPrefix("green-dark", "Facção", 2).."Você saiu do serviço!", 255, 255, 255, true)

            triggerServerEvent("faction > setMemberDutyState", resourceRoot, 0, _, inDutyTime)
            inDutyTime = 0

            if isTimer(inDutyTimer) then killTimer(inDutyTimer) end

            dutyTimer = setTimer(function()
                if isTimer(dutyTimer) then 
                    killTimer(dutyTimer)
                end
            end, core:minToMilisec(1), 1)
        else -- Plantão em facção errada
            infobox:outputInfoBox("Primeiro saia do serviço na organização "..getFactionName(dutyState)..".", "error")
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 2).."Primeiro saia do serviço na organização "..color..getFactionName(dutyState).."#ffffff.", 255, 255, 255, true)
        end
    else
        outputChatBox(core:getServerPrefix("red-dark", "Facção", 2).."Você não é membro da organização "..color..getFactionName(dutyMarkerID).."#ffffff.", 255, 255, 255, true)
    end
end

-- / Seletor de skin de plantão / --
function renderDutySkinChooser()
    core:dxDrawShadowedText("Escolha o skin de serviço com as "..color.."setas #ffffffe confirme com "..color.."[Enter]#ffffff.", 0, sy*0.79, sx, sy*0.79+sy*0.05, tocolor(255, 255, 255, 255), tocolor(0, 0, 0, 255), 1/myX*sx, fonts["condensed-12"], "center", "center", false, false, false, true)
end

function dutySkinKey(key, state)
    if state then 
        if (key == "arrow_l" or key == "a") then 
            if jelenlegiDutySkin > 1 then 
                jelenlegiDutySkin = jelenlegiDutySkin - 1 
                setElementModel(localPlayer, choosableSkins[jelenlegiDutySkin])
            end
        end

        if (key == "arrow_r" or key == "d") then 
            if jelenlegiDutySkin < #choosableSkins then 
                jelenlegiDutySkin = jelenlegiDutySkin + 1 
                setElementModel(localPlayer, choosableSkins[jelenlegiDutySkin])
            end
        end

        if key == "enter" then 
            endDutySkinChoosing()
        end
    end
end

function startDutySkinChoosing()
    setElementFrozen(localPlayer, true)
    starterSkin = getElementModel(localPlayer)
    addEventHandler("onClientRender", root, renderDutySkinChooser)
    addEventHandler("onClientKey", root, dutySkinKey)

    jelenlegiDutySkin = 1
    setElementModel(localPlayer, choosableSkins[jelenlegiDutySkin])
end

function endDutySkinChoosing()
    setElementModel(localPlayer, starterSkin)
    setElementFrozen(localPlayer, false)
    removeEventHandler("onClientRender", root, renderDutySkinChooser)
    removeEventHandler("onClientKey", root, dutySkinKey)

    triggerServerEvent("faction > setPlayerDutySkin", localPlayer, localPlayer,dutyMarkerID ,choosableSkins[jelenlegiDutySkin])
end
----------------------------

addEventHandler("onClientMarkerHit", root, function(player, mdim)
    if player == localPlayer then
        if mdim then
            if source then 
                if (getElementData(source, "dutyMarker:id") or 0) > 0 then 
                    if core:getDistance(source, localPlayer) < 2 then 
                        dutyMarkerID = getElementData(source, "dutyMarker:id")
                        addEventHandler("onClientRender", root, renderFactionDutyTooltip)
                        bindKey("e", "up", factionDuty)
                    end
                end
            end
        end
    end
end)

addEventHandler("onClientMarkerLeave", root, function(player, mdim)
    if player == localPlayer then
        if mdim then 
            if getElementData(source, "dutyMarker:id") then 
                removeEventHandler("onClientRender", root, renderFactionDutyTooltip)
                unbindKey("e", "up", factionDuty)
            end
        end
    end
end)

addEventHandler("onClientElementDataChange", root, function(key, old, new)
    if source == localPlayer then
        if key == "char:name" then
            local factions = getPlayerAllFactions()

            for k, v in pairs(factions) do
                --outputChatBox(v)
                for k2, v2 in pairs(client_factionMember_list[v]) do
                    if v2[1] == getElementData(localPlayer, "char:id") then
                        if not (v2[3] == new) then
                            v2[3] = new
                            triggerServerEvent("faction > updatePlayerName", resourceRoot, v, getElementData(localPlayer, "char:id"), new, old)
                        end
                        break
                    end
                end
            end
        end
    end
end)

-- ─── Overlay de serviço (/duty badge) ────────────────────────────────────────
local dutyOverlayFont = exports.oFont:getFont("condensed", math.max(10, math.floor(11/900*sy)))

addEventHandler("onClientElementDataChange", root, function(key, old, new)
    if source == localPlayer and key == "char:duty:faction" then
        -- Atualizar fonte se necessário
        dutyOverlayFont = exports.oFont:getFont("condensed", math.max(10, math.floor(11/900*sy)))
    end
end)

local function renderDutyBadge()
    local fid = getElementData(localPlayer, "char:duty:faction") or 0
    if fid == 0 then return end

    local fname = getFactionName(fid) or "Em Serviço"
    local ftype = getFactionType(fid) or 0

    -- Cor por tipo de facção
    local br, bg_, bb
    if     ftype == 1 then br,bg_,bb = 60,120,220    -- azul polícia
    elseif ftype == 2 then br,bg_,bb = 220,60,60     -- vermelho saúde
    elseif ftype == 3 then br,bg_,bb = 220,180,60    -- dourado legal
    else                   br,bg_,bb = 180,60,220    -- roxo outros
    end

    local bx = sx - px(190)
    local by = py(14)
    local bw = px(178)
    local bh = py(28)

    -- Fundo arredondado simulado
    dxDrawRectangle(bx,         by,         bw,    bh,    tocolor(10, 10, 10, 200))
    dxDrawRectangle(bx,         by,         bw,    py(2), tocolor(br, bg_, bb, 255))
    -- Barra colorida lateral
    dxDrawRectangle(bx,         by + py(2), px(3), bh - py(2), tocolor(br, bg_, bb, 220))

    -- Ícone "●" + texto
    dxDrawText("●", bx + px(6), by + py(2), bx + px(22), by + bh,
        tocolor(br, bg_, bb, 255), 1, dutyOverlayFont, "left", "center")
    dxDrawText("EM SERVIÇO", bx + px(22), by + py(2), bx + bw - px(6), by + bh,
        tocolor(255, 255, 255, 240), 1, dutyOverlayFont, "left", "center")
    dxDrawText(fname, bx + px(22), by + py(14), bx + bw - px(6), by + bh + py(4),
        tocolor(br + 50 > 255 and 255 or br + 50, bg_ + 50 > 255 and 255 or bg_ + 50, bb + 50 > 255 and 255 or bb + 50, 200),
        0.85, dutyOverlayFont, "left", "center")
end

addEventHandler("onClientRender", root, renderDutyBadge)