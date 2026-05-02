function addPlayerToFaction(player, command, target, factionID)
    if exports["oAdmin"]:hasPermission(player,"setplayerfaction") then 
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- Verifica se o jogador está na lista de admins verificados; caso contrário, kick por abuso.

        factionID, target = tonumber(factionID) or 0, tonumber(target) or 0

        if (factionID > 0) and (target > 0) then
            if isRealFaction(factionID) then
                target = core:getPlayerFromPartialName(player, target)

                if not isPlayerInFaction(target, factionID) then 
                    if getElementData(target,"hasContainer") then return outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."O jogador selecionado possui um contêiner; ele precisa encerrar o aluguel antes!", player, 255, 255, 255, true) end

                    local length = #server_factionMembers_list[factionID] or 0
                    ----- Char ID, posto, líder, nome, último login, online, tempo de serviço
                    table.insert(server_factionMembers_list[factionID], length+1, {getElementData(target, "char:id"), 1, false, getElementData(target, "char:name"), getElementData(target, "user:lastlogin") or "false", true, string.format("%04d.%02d.%02d %02d:%02d", core:getDate("year"), core:getDate("month"), core:getDate("monthday"), core:getDate("hour"), core:getDate("minute")), "Sem dados", 0})
--                    print(toJSON(server_factionMembers_list[factionID]))

                    outputChatBox(core:getServerPrefix("server", "Adicionado", 1)..color..getPlayerName(player).." #ffffffadicionou você à facção "..color..getFactionName(factionID).."#ffffff.", target, 255, 255, 255, true)
                    triggerClientEvent("sendMessageToAdmins", getRootElement(), player, "adicionou o jogador #db3535"..getPlayerName(target).." #557ec9à facção #db3535"..getFactionName(factionID).."#557ec9.")

                    triggerClientEvent(root, "getFactionMembersFromServer > Return", root, server_factionMembers_list)

                    triggerClientEvent(target, "resetPlayerFactionDatas", target)

                    setElementData(player, "log:admincmd", {getElementData(target, "char:id"), command})
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."O jogador já é membro desta facção! "..color.."("..getFactionName(factionID)..")", player, 255, 255, 255, true)  
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Esta facção não existe! "..color.."("..factionID..")", player, 255, 255, 255, true) 
            end
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..command.." [Jogador] [ID da Facção]", player, 255, 255, 255, true) 
        end
    end 
end
addCommandHandler("addplayertofaction", addPlayerToFaction)
addCommandHandler("giveplayerfaction", addPlayerToFaction)
addCommandHandler("addtofaction", addPlayerToFaction)
addCommandHandler("setplayerfaction",addPlayerToFaction)

function getPlayerFactions(player, command, target)
    if exports["oAdmin"]:hasPermission(player,"getplayerfactions") then 
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- Verifica se o jogador está na lista de admins verificados; caso contrário, kick por abuso.

        target = tonumber(target) or 0 

        if target > 0 then 
            target = core:getPlayerFromPartialName(player, target)

            local target_factions = getPlayerAllFactions(target)

            if #target_factions > 0 then 
                outputChatBox(core:getServerPrefix("server", "Facção", 3).."Facções de "..getPlayerName(target):gsub("_", " ")..":", player, 255, 255, 255, true) 
                for k, v in ipairs(target_factions) do 
                    outputChatBox(color.." ~ #ffffff"..getFactionName(v)..color.." ["..faction_types[getFactionType(v)].."] ("..v..")", player, 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-light", "Facção", 3).."Este jogador não pertence a nenhuma facção!", player, 255, 255, 255, true) 
            end
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..command.." [Jogador]", player, 255, 255, 255, true) 
        end
    end
end
addCommandHandler("getplayerfactions", getPlayerFactions)
addCommandHandler("getfactions", getPlayerFactions)

function removePlayerFromFaction(player, command, target, factionID)
    if exports["oAdmin"]:hasPermission(player,"removeplayerfromfaction") then 
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- Verifica se o jogador está na lista de admins verificados; caso contrário, kick por abuso.

        factionID, target = tonumber(factionID) or 0, tonumber(target) or 0

        if (factionID > 0) and (target > 0) then
            if isRealFaction(factionID) then
                target = core:getPlayerFromPartialName(player, target)

                if target then 
                    local isInFaction, factionListNumber = isPlayerInFaction(target, factionID)
                    if isInFaction then 

                        outputChatBox(core:getServerPrefix("server", "Adicionado", 1)..color..getPlayerName(player).." #ffffffremoveu você da facção "..color..getFactionName(factionID).."#ffffff.", target, 255, 255, 255, true)
                        triggerClientEvent("sendMessageToAdmins", getRootElement(), player, "removeu o jogador #db3535"..getPlayerName(target).." #557ec9da facção #db3535"..getFactionName(factionID).."#557ec9.")

                        for k, v in ipairs(server_factionMembers_list[factionID]) do 
                            if v[1] == getElementData(target, "char:id") then 
                                table.remove(server_factionMembers_list[factionID], k)
                            end
                        end

                        triggerClientEvent(root, "getFactionMembersFromServer > Return", root, server_factionMembers_list)
                        triggerClientEvent(target, "resetPlayerFactionDatas", target)
                       
                        setElementData(player, "log:admincmd", {getElementData(target, "char:id"), command})
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."O jogador não é membro desta facção! "..color.."("..getFactionName(factionID)..")", player, 255, 255, 255, true) 
                    end
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Esta facção não existe! "..color.."("..factionID..")", player, 255, 255, 255, true) 
            end
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..command.." [Jogador] [ID da Facção]", player, 255, 255, 255, true) 
        end
    end
end 
addCommandHandler("removeplayerfromfaction", removePlayerFromFaction)
addCommandHandler("removefromfaction", removePlayerFromFaction)

function removePlayerFromAllFaction(player, command, target)
    if exports["oAdmin"]:hasPermission(player,"removeplayerfromallfaction") then 
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- Verifica se o jogador está na lista de admins verificados; caso contrário, kick por abuso.

        target = tonumber(target) or 0

        if (target > 0) then
            target = core:getPlayerFromPartialName(player, target)
            local factions, factionId, key = getPlayerAllFactions(target)
            for k, v in pairs(factions) do 
                for a, b in pairs(server_factionMembers_list[v]) do 
                    if b[1] == getElementData(target, "char:id") then 
                        table.remove(server_factionMembers_list[v], a)
                    end
                end
            end
          --  iprint(server_factionMembers_list)
            triggerClientEvent(root, "getFactionMembersFromServer > Return", root, server_factionMembers_list)
            triggerClientEvent(target, "resetPlayerFactionDatas", target)
            outputChatBox(core:getServerPrefix("server", 2)..color..getPlayerName(player).." #ffffffremoveu você de todas as facções.", target, 255, 255, 255, true)
            triggerClientEvent("sendMessageToAdmins", getRootElement(), player, "removeu o jogador #db3535"..getPlayerName(target).." #557ec9de todas as facções.")

            setElementData(player, "log:admincmd", {getElementData(target, "char:id"), command})
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..command.." [Jogador]", player, 255, 255, 255, true) 
        end
    end
end
addCommandHandler("removeplayerfromallfaction", removePlayerFromAllFaction)
addCommandHandler("removefromallfaction", removePlayerFromAllFaction)

function setPlayerFactionLeader(player, cmd, target, targetFaction) 
    if exports["oAdmin"]:hasPermission(player,"setfactionleader") then 
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- Verifica se o jogador está na lista de admins verificados; caso contrário, kick por abuso.

        target = tonumber(target) or 0
        targetFaction = tonumber(targetFaction) or 0 

        if (target > 0) and (targetFaction > 0) then
            if isRealFaction(targetFaction) then 
                target = core:getPlayerFromPartialName(player, target)

                local targetFactions = getPlayerAllFactions(target)

                local talalt = false
                for k, v in pairs(targetFactions) do 
                    if tonumber(v) == targetFaction then 
                        talalt = true 
                        break
                    end
                end

                if talalt then 

                    for k, v in pairs(server_factionMembers_list[targetFaction]) do 
                        if v[1] == getElementData(target, "char:id") then 
                            v[3] = not v[3]
                            print(tostring(v[3]))

                            if v[3] then 
                                outputChatBox(core:getServerPrefix("server", "Adicionado", 1)..color..getPlayerName(player).." #ffffffconcedeu função de líder na facção "..color..getFactionName(targetFaction).."#ffffff.", target, 255, 255, 255, true)
                                triggerClientEvent("sendMessageToAdmins", getRootElement(), player, "concedeu função de líder ao jogador #db3535"..getPlayerName(target).." #557ec9na facção #db3535"..getFactionName(targetFaction).."#557ec9.")
                            else
                                outputChatBox(core:getServerPrefix("server", "Adicionado", 1)..color..getPlayerName(player).." #ffffffremoveu sua função de líder na facção "..color..getFactionName(targetFaction).."#ffffff.", target, 255, 255, 255, true)
                                triggerClientEvent("sendMessageToAdmins", getRootElement(), player, "removeu a função de líder do jogador #db3535"..getPlayerName(target).." #557ec9na facção #db3535"..getFactionName(targetFaction).."#557ec9.")
                            end

                            triggerClientEvent(root, "getFactionMembersFromServer > Return", root, server_factionMembers_list)
                            setElementData(player, "log:admincmd", {getElementData(target, "char:id"), cmd})

                            break
                        end
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."O jogador não é membro desta facção. "..color.."("..getFactionName(targetFaction)..")", player, 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("red-dark", "Facção", 3).."Esta facção não existe!", player, 255, 255, 255, true)
            end
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [Jogador] [ID da Facção]", player, 255, 255, 255, true) 
        end
    end
end
addCommandHandler("setfactionleader", setPlayerFactionLeader)

function addMoneyToFaction(player, cmd, factionID, money)
    if exports["oAdmin"]:hasPermission(player,"givefactionmoney") then 
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- Verifica se o jogador está na lista de admins verificados; caso contrário, kick por abuso.

        factionID = tonumber(factionID) or 0
        money = tonumber(money) or 0 

        if (factionID > 0) and (money > 0) then
            setFactionBankMoney(factionID, money, "add")
            triggerClientEvent("sendMessageToAdmins", getRootElement(), player, "depositou dinheiro na facção #db3535"..getFactionName(factionID).."#557ec9. Valor: #db3535"..money.."$ #557ec9| Novo saldo: #db3535"..getFactionBankMoney(factionID).."$#557ec9.")
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [ID da Facção] [Valor]", player, 255, 255, 255, true) 
        end 
    end
end
addCommandHandler("givefactionmoney", addMoneyToFaction)

function removeMoneyToFaction(player, cmd, factionID, money)
    if exports["oAdmin"]:hasPermission(player,"removefactionmoney") then 
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- Verifica se o jogador está na lista de admins verificados; caso contrário, kick por abuso.

        factionID = tonumber(factionID) or 0
        money = tonumber(money) or 0 

        if (factionID > 0) and (money > 0) then
            setFactionBankMoney(factionID, money, "remove")
            triggerClientEvent("sendMessageToAdmins", getRootElement(), player, "retirou dinheiro da facção #db3535"..getFactionName(factionID).."#557ec9. Valor: #db3535(-)"..money.."$ #557ec9| Novo saldo: #db3535"..getFactionBankMoney(factionID).."$#557ec9.")
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [ID da Facção] [Valor]", player, 255, 255, 255, true) 
        end 
    end
end
addCommandHandler("removefactionmoney", removeMoneyToFaction)
