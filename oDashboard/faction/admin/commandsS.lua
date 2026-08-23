local function adminVerifiedOrMsg(pl)
    if exports.oAnticheat:checkPlayerVerifiedAdminStatus(pl) then
        return true
    end
    outputChatBox(core:getServerPrefix("red-dark", "Anti-cheat", 3) .. "Conta admin não verificada.", pl, 255, 255, 255, true)
    return false
end

local function resolveOnlinePlayer(admin, partial)
    if partial == nil then return nil end
    local raw = tostring(partial):match("^%s*(.-)%s*$")
    if not raw or raw == "" then return nil end
    local elem = select(1, core:getPlayerFromPartialName(admin, raw, true))
    -- Nome com espaços no chat vs underscore no nick MTA (ex.: «João Silva» → João_Silva)
    if (not elem or not isElement(elem)) and not raw:find("^%d+$") then
        local underscored = raw:gsub("%s+", "_")
        if underscored ~= raw then
            elem = select(1, core:getPlayerFromPartialName(admin, underscored, true))
        end
    end
    if elem and isElement(elem) and getElementData(elem, "user:loggedin") then
        return elem
    end
    return nil
end

function addPlayerToFaction(player, command, ...)
    if not exports["oAdmin"]:hasPermission(player,"setplayerfaction", false) then return end
    if not adminVerifiedOrMsg(player) then return end

        local args = {...}
        if #args < 2 then
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..command.." [Jogador ou nome com espaços] [ID da Facção]", player, 255, 255, 255, true)
            outputChatBox("#aaaaaaEx.: #ffffff/"..command.." Medivh_Jackson 5  ou  /"..command.." 12 5 #aaaaaa(playerid/char:id/user:id)", player, 255, 255, 255, true)
            return
        end
        local factionID = tonumber(args[#args]) or 0
        local target = table.concat(args, " ", 1, #args - 1)
        target = target:match("^%s*(.-)%s*$") or target

        if factionID <= 0 or target == "" then
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..command.." [Jogador] [ID da Facção]", player, 255, 255, 255, true)
            return
        end

        local tgt = resolveOnlinePlayer(player, target)
        if not tgt then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Jogador não encontrado ou várias correspondências (usa playerid, char:id, user:id ou nome único).", player, 255, 255, 255, true)
            return
        end

        if not isRealFaction(factionID) then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Esta facção não existe! "..color.."("..factionID..")", player, 255, 255, 255, true)
            return
        end

        if isPlayerInFaction(tgt, factionID) then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."O jogador já é membro desta facção! "..color.."("..getFactionName(factionID)..")", player, 255, 255, 255, true)
            return
        end

        if getElementData(tgt,"hasContainer") then return outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."O jogador selecionado possui um contêiner; ele precisa encerrar o aluguel antes!", player, 255, 255, 255, true) end

        local memList = server_factionMembers_list[factionID]
        if type(memList) ~= "table" then
            server_factionMembers_list[factionID] = {}
            memList = server_factionMembers_list[factionID]
        end
        local length = #memList
        table.insert(memList, length + 1, {getElementData(tgt, "char:id"), 1, false, getElementData(tgt, "char:name") or getPlayerName(tgt):gsub("_", " "), getElementData(tgt, "user:lastlogin") or "false", true, string.format("%04d.%02d.%02d %02d:%02d", core:getDate("year"), core:getDate("month"), core:getDate("monthday"), core:getDate("hour"), core:getDate("minute")), "Sem dados", 0})

        outputChatBox(core:getServerPrefix("server", "Adicionado", 1)..color..getPlayerName(player).." #ffffffadicionou você à facção "..color..getFactionName(factionID).."#ffffff.", tgt, 255, 255, 255, true)
        outputChatBox(core:getServerPrefix("server", "Facção", 3).."Adicionaste "..getPlayerName(tgt):gsub("_", " ").." à facção "..color..getFactionName(factionID).."#ffffff (abre o dashboard da facção para veres a lista).", player, 255, 255, 255, true)
        exports.oAdmin:sendMessageToAdmins(player, "adicionou o jogador #db3535"..getPlayerName(tgt).." #557ec9à facção #db3535"..getFactionName(factionID).."#557ec9.", 7)

        triggerClientEvent(root, "getFactionMembersFromServer > Return", root, server_factionMembers_list)

        triggerClientEvent(tgt, "resetPlayerFactionDatas", tgt)

        setElementData(player, "log:admincmd", {getElementData(tgt, "char:id"), command})
        saveFactions()
end
addCommandHandler("addplayertofaction", addPlayerToFaction)
addCommandHandler("giveplayerfaction", addPlayerToFaction)
addCommandHandler("addtofaction", addPlayerToFaction)
addCommandHandler("setplayerfaction",addPlayerToFaction)
addCommandHandler("setfaccao", addPlayerToFaction)
addCommandHandler("definirfaccao", addPlayerToFaction)
addCommandHandler("adicionarfaccao", addPlayerToFaction)

function getPlayerFactions(player, command, target)
    if not exports["oAdmin"]:hasPermission(player,"getplayerfactions", false) then return end
    if not adminVerifiedOrMsg(player) then return end

        if target == nil or tostring(target):match("^%s*$") then
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..command.." [Jogador]", player, 255, 255, 255, true)
            return
        end

        local tgt = resolveOnlinePlayer(player, target)
        if not tgt then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Jogador não encontrado ou várias correspondências.", player, 255, 255, 255, true)
            return
        end

        local target_factions = getPlayerAllFactions(tgt)

        if #target_factions > 0 then 
            outputChatBox(core:getServerPrefix("server", "Facção", 3).."Facções de "..getPlayerName(tgt):gsub("_", " ")..":", player, 255, 255, 255, true) 
            for k, v in ipairs(target_factions) do 
                outputChatBox(color.." ~ #ffffff"..getFactionName(v)..color.." ["..faction_types[getFactionType(v)].."] ("..v..")", player, 255, 255, 255, true)
            end
        else
            outputChatBox(core:getServerPrefix("red-light", "Facção", 3).."Este jogador não pertence a nenhuma facção!", player, 255, 255, 255, true) 
        end
end
addCommandHandler("getplayerfactions", getPlayerFactions)
addCommandHandler("getfactions", getPlayerFactions)
addCommandHandler("listarfaccoes", getPlayerFactions)
addCommandHandler("faccoesjogador", getPlayerFactions)

function removePlayerFromFaction(player, command, target, factionID)
    if not exports["oAdmin"]:hasPermission(player,"removeplayerfromfaction", false) then return end
    if not adminVerifiedOrMsg(player) then return end

        factionID = tonumber(factionID) or 0
        if factionID <= 0 or target == nil or tostring(target):match("^%s*$") then
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..command.." [Jogador] [ID da Facção]", player, 255, 255, 255, true)
            return
        end

        local tgt = resolveOnlinePlayer(player, target)
        if not tgt then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Jogador não encontrado ou várias correspondências.", player, 255, 255, 255, true)
            return
        end

        if not isRealFaction(factionID) then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Esta facção não existe! "..color.."("..factionID..")", player, 255, 255, 255, true)
            return
        end

        local isInFaction, factionListNumber = isPlayerInFaction(tgt, factionID)
        if not isInFaction then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."O jogador não é membro desta facção! "..color.."("..getFactionName(factionID)..")", player, 255, 255, 255, true)
            return
        end

        outputChatBox(core:getServerPrefix("server", "Adicionado", 1)..color..getPlayerName(player).." #ffffffremoveu você da facção "..color..getFactionName(factionID).."#ffffff.", tgt, 255, 255, 255, true)
        exports.oAdmin:sendMessageToAdmins(player, "removeu o jogador #db3535"..getPlayerName(tgt).." #557ec9da facção #db3535"..getFactionName(factionID).."#557ec9.", 7)

        local memRm = server_factionMembers_list[factionID]
        if type(memRm) == "table" then
            for k, v in ipairs(memRm) do 
                if v[1] == getElementData(tgt, "char:id") then 
                    table.remove(memRm, k)
                    break
                end
            end
        end

        triggerClientEvent(root, "getFactionMembersFromServer > Return", root, server_factionMembers_list)
        triggerClientEvent(tgt, "resetPlayerFactionDatas", tgt)

        setElementData(player, "log:admincmd", {getElementData(tgt, "char:id"), command})
        saveFactions()
end 
addCommandHandler("removeplayerfromfaction", removePlayerFromFaction)
addCommandHandler("removefromfaction", removePlayerFromFaction)
addCommandHandler("removerfaccao", removePlayerFromFaction)
addCommandHandler("removerdafaccao", removePlayerFromFaction)

function removePlayerFromAllFaction(player, command, target)
    if not exports["oAdmin"]:hasPermission(player,"removeplayerfromallfaction", false) then return end
    if not adminVerifiedOrMsg(player) then return end

        if target == nil or tostring(target):match("^%s*$") then
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..command.." [Jogador]", player, 255, 255, 255, true)
            return
        end

        local tgt = resolveOnlinePlayer(player, target)
        if not tgt then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Jogador não encontrado ou várias correspondências.", player, 255, 255, 255, true)
            return
        end

        local factions = getPlayerAllFactions(tgt)
        for k, v in pairs(factions) do 
            local memAll = server_factionMembers_list[v]
            if type(memAll) == "table" then
                for a, b in pairs(memAll) do 
                    if b[1] == getElementData(tgt, "char:id") then 
                        table.remove(memAll, a)
                        break
                    end
                end
            end
        end
        triggerClientEvent(root, "getFactionMembersFromServer > Return", root, server_factionMembers_list)
        triggerClientEvent(tgt, "resetPlayerFactionDatas", tgt)
        outputChatBox(core:getServerPrefix("server", 2)..color..getPlayerName(player).." #ffffffremoveu você de todas as facções.", tgt, 255, 255, 255, true)
        exports.oAdmin:sendMessageToAdmins(player, "removeu o jogador #db3535"..getPlayerName(tgt).." #557ec9de todas as facções.", 7)

        setElementData(player, "log:admincmd", {getElementData(tgt, "char:id"), command})
        saveFactions()
end
addCommandHandler("removeplayerfromallfaction", removePlayerFromAllFaction)
addCommandHandler("removefromallfaction", removePlayerFromAllFaction)
addCommandHandler("removerdetodasfaccoes", removePlayerFromAllFaction)

function setPlayerFactionLeader(player, cmd, target, targetFaction) 
    if not exports["oAdmin"]:hasPermission(player,"setfactionleader", false) then return end
    if not adminVerifiedOrMsg(player) then return end

        targetFaction = tonumber(targetFaction) or 0
        if targetFaction <= 0 or target == nil or tostring(target):match("^%s*$") then
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [Jogador] [ID da Facção]", player, 255, 255, 255, true)
            return
        end

        local tgt = resolveOnlinePlayer(player, target)
        if not tgt then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Jogador não encontrado ou várias correspondências (usa playerid, char:id, user:id ou nome único).", player, 255, 255, 255, true)
            return
        end

        if not isRealFaction(targetFaction) then 
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Esta facção não existe!", player, 255, 255, 255, true)
            return
        end

        local targetFactions = getPlayerAllFactions(tgt)
        local talalt = false
        for k, v in pairs(targetFactions) do 
            if tonumber(v) == targetFaction then 
                talalt = true 
                break
            end
        end

        if not talalt then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."O jogador não é membro desta facção. "..color.."("..getFactionName(targetFaction)..")", player, 255, 255, 255, true)
            return
        end

        local toggled = false
        local memLead = server_factionMembers_list[targetFaction]
        if type(memLead) ~= "table" then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Lista de membros desta facção está corrompida ou vazia no servidor. Reinicia oDashboard.", player, 255, 255, 255, true)
            return
        end
        for k, v in pairs(memLead) do 
            if v[1] == getElementData(tgt, "char:id") then 
                v[3] = not v[3]
                toggled = true

                if v[3] then 
                    outputChatBox(core:getServerPrefix("server", "Adicionado", 1)..color..getPlayerName(player).." #ffffffconcedeu função de líder na facção "..color..getFactionName(targetFaction).."#ffffff.", tgt, 255, 255, 255, true)
                    outputChatBox(core:getServerPrefix("server", "Facção", 3).."Passaste a líder da facção "..color..getFactionName(targetFaction).."#ffffff.", player, 255, 255, 255, true)
                    exports.oAdmin:sendMessageToAdmins(player, "concedeu função de líder ao jogador #db3535"..getPlayerName(tgt).." #557ec9na facção #db3535"..getFactionName(targetFaction).."#557ec9.", 7)
                else
                    outputChatBox(core:getServerPrefix("server", "Adicionado", 1)..color..getPlayerName(player).." #ffffffremoveu sua função de líder na facção "..color..getFactionName(targetFaction).."#ffffff.", tgt, 255, 255, 255, true)
                    outputChatBox(core:getServerPrefix("server", "Facção", 3).."Removeste o estatuto de líder desse jogador em "..color..getFactionName(targetFaction).."#ffffff.", player, 255, 255, 255, true)
                    exports.oAdmin:sendMessageToAdmins(player, "removeu a função de líder do jogador #db3535"..getPlayerName(tgt).." #557ec9na facção #db3535"..getFactionName(targetFaction).."#557ec9.", 7)
                end

                triggerClientEvent(root, "getFactionMembersFromServer > Return", root, server_factionMembers_list)
                setElementData(player, "log:admincmd", {getElementData(tgt, "char:id"), cmd})
                saveFactions()
                break
            end
        end

        if not toggled then
            outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Registo do membro não encontrado na lista da facção (sincroniza / reinicia recurso oDashboard).", player, 255, 255, 255, true)
        end
end
addCommandHandler("setfactionleader", setPlayerFactionLeader)
addCommandHandler("liderfac", setPlayerFactionLeader)
addCommandHandler("definirliderfac", setPlayerFactionLeader)

--- Lista no chat todos os IDs de facção carregados (tabela `factions` / `server_faction_list`).
function listFactionIds(player, command)
    if not exports["oAdmin"]:hasPermission(player, "setfactionleader", true) then
        outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Este comando exige nível de admin 7 (ou ACL dev) e permissão setfactionleader.", player, 255, 255, 255, true)
        return
    end
    if not adminVerifiedOrMsg(player) then return end

    outputChatBox(core:getServerPrefix("server", "Facção", 3).."IDs e nomes (uso em /setfactionleader [jogador] [id]):", player, 255, 255, 255, true)
    local count = 0
    for _, v in pairs(server_faction_list) do
        if v and type(v) == "table" and v[1] then
            count = count + 1
            local t = tonumber(v[3]) or 0
            local typeLabel = faction_types[t] or ("tipo " .. tostring(t))
            outputChatBox(color .. "#" .. v[1] .. " #ffffff— " .. tostring(v[2] or "?") .. " " .. color .. "(" .. typeLabel .. ")", player, 255, 255, 255, true)
        end
    end
    if count == 0 then
        outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Nenhuma facção carregada (tabela `factions` vazia ou recurso oDashboard sem dados). Cria facções pelo painel admin ou insere na DB.", player, 255, 255, 255, true)
    end
end
addCommandHandler("listfactionids", listFactionIds)
addCommandHandler("idsfaccoes", listFactionIds)
addCommandHandler("listarfaccoesids", listFactionIds)

function addMoneyToFaction(player, cmd, factionID, money)
    if not exports["oAdmin"]:hasPermission(player,"givefactionmoney", false) then return end
    if not adminVerifiedOrMsg(player) then return end

        factionID = tonumber(factionID) or 0
        money = tonumber(money) or 0 

        if (factionID > 0) and (money > 0) then
            setFactionBankMoney(factionID, money, "add")
            exports.oAdmin:sendMessageToAdmins(player, "depositou dinheiro na facção #db3535"..getFactionName(factionID).."#557ec9. Valor: #db3535"..money.."$ #557ec9| Novo saldo: #db3535"..getFactionBankMoney(factionID).."$#557ec9.", 7)
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [ID da Facção] [Valor]", player, 255, 255, 255, true) 
        end 
end
addCommandHandler("givefactionmoney", addMoneyToFaction)
addCommandHandler("dardinheirofaccao", addMoneyToFaction)

function removeMoneyToFaction(player, cmd, factionID, money)
    if not exports["oAdmin"]:hasPermission(player,"removefactionmoney", false) then return end
    if not adminVerifiedOrMsg(player) then return end

        factionID = tonumber(factionID) or 0
        money = tonumber(money) or 0 

        if (factionID > 0) and (money > 0) then
            setFactionBankMoney(factionID, money, "remove")
            exports.oAdmin:sendMessageToAdmins(player, "retirou dinheiro da facção #db3535"..getFactionName(factionID).."#557ec9. Valor: #db3535(-)"..money.."$ #557ec9| Novo saldo: #db3535"..getFactionBankMoney(factionID).."$#557ec9.", 7)
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [ID da Facção] [Valor]", player, 255, 255, 255, true) 
        end 
end
addCommandHandler("removefactionmoney", removeMoneyToFaction)
addCommandHandler("retirardinheirofaccao", removeMoneyToFaction)
