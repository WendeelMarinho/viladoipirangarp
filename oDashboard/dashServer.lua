for k, v in ipairs(getElementsByType("player")) do 
    setElementData(v, "dashboard:vehicleBuy", false)
end


addEvent("dash > admin > callAdmins", true)
addEventHandler("dash > admin > callAdmins", resourceRoot, function()
    for k, v in ipairs(getElementsByType("player")) do 
        local alevel = getElementData(v, "user:admin") or 0
        if alevel > 0 then 
            outputChatBox(core:getServerPrefix("red-dark", "Pedido de ajuda (admin)", 2).." O jogador "..color..getElementData(client, "char:name"):gsub("_", " ").." ("..getElementData(client, "playerid")..")#ffffff precisa de um administrador.", v, 255, 255, 255, true)
            infobox:outputInfoBox("Um jogador pediu ajuda de administrador!", "info", v)
        end
    end
end)

addEvent("premiumShop > buyPremiumItem", true)
addEventHandler("premiumShop > buyPremiumItem", resourceRoot, function(itemDatas)
    local id, price, count, value = unpack(itemDatas)

    inventory = exports.oInventory
    local itemID = inventory:giveItem(client, id, value, count, 0, _, _, _, client,1)
    setElementData(client, "char:pp", getElementData(client, "char:pp") - price)
    infobox:outputInfoBox("Compra realizada! Detalhes no chat.", "success", client)

    outputChatBox(core:getServerPrefix("server", "Premium", 2).."Olá, "..color..getPlayerName(client):gsub("_", " ").."#ffffff! Você comprou o item "..color..inventory:getItemName(id).."#ffffff." , client, 255, 255, 255, true)
    outputChatBox(core:getServerPrefix("red-dark", "Premium", 2)..color.."Guarde estas mensagens para comprovar a origem do item premium. Sem print, o item pode não ser considerado premium.", client, 255, 255, 255, true)
end)

addEvent("premiumShop > buyPremiumMoney", true)
addEventHandler("premiumShop > buyPremiumMoney", resourceRoot, function(itemDatas)
    local icon, price, count = unpack(itemDatas)

    setElementData(client, "char:pp", getElementData(client, "char:pp") - price)
    setElementData(client, "char:money", getElementData(client, "char:money") + count)
    infobox:outputInfoBox("Compra realizada! Detalhes no chat.", "success", client)

    outputChatBox(core:getServerPrefix("server", "Premium", 2).."Olá, "..color..getPlayerName(client):gsub("_", " ").."#ffffff! Você comprou "..color..count.."$#ffffff por "..color..price.." PP#ffffff." , client, 255, 255, 255, true)
end)


addEvent("premiumShop > buyPremiumPackage", true)
addEventHandler("premiumShop > buyPremiumPackage", resourceRoot, function(packageDatas)
    local name, price, items = unpack(packageDatas)

    inventory = exports.oInventory

    local player = client
    for k, v in pairs(items) do 
        --setTimer(function()
            local value
            if not v.value then 
                value = 1
            else
                value = v.value
            end
            
            local itemID = inventory:giveItem(player, v.id, value, v.count, 0, _, _, _, client,1) 
        --end, k*1000, 1)
    end
    setElementData(client, "char:pp", getElementData(client, "char:pp") - price)
    infobox:outputInfoBox("Compra realizada! Detalhes no chat.", "success", client)

    outputChatBox(core:getServerPrefix("server", "Premium", 2).."Olá, "..color..getPlayerName(client):gsub("_", " ").."#ffffff! Você comprou o pacote premium "..color..name.."#ffffff." , client, 255, 255, 255, true)
    outputChatBox(core:getServerPrefix("red-dark", "Premium", 2)..color.."Guarde estas mensagens para comprovar a origem dos itens premium. Sem print, podem não ser considerados premium.", client, 255, 255, 255, true)
end)

addEvent("slot > buySlot", true)
addEventHandler("slot > buySlot", resourceRoot, function(type, slot)
    setElementData(client, "char:pp", getElementData(client, "char:pp") - (slot * 100))
    setElementData(client, "char:"..type.."Slot", getElementData(client, "char:"..type.."Slot") + slot)
end)

addEvent("buypanel > startVehSell", true)
addEventHandler("buypanel > startVehSell", resourceRoot, function(tradePlayer, price, veh)
    setElementData(tradePlayer, "dashboard:inTrade", true)
    setElementData(client, "dashboard:inTrade", true)
    
    infobox:outputInfoBox(getPlayerName(client):gsub("_", " ").." quer te vender um veículo!", "info", tradePlayer)

    triggerClientEvent(tradePlayer, "buypanel > startbuy", tradePlayer, client, price, veh)
end)

addEvent("buypanel > startIntSell", true)
addEventHandler("buypanel > startIntSell", resourceRoot, function(tradePlayer, price, veh)
    setElementData(tradePlayer, "dashboard:inTrade", true)
    setElementData(client, "dashboard:inTrade", true)
    
    infobox:outputInfoBox(getPlayerName(client):gsub("_", " ").." quer te vender um imóvel!", "info", tradePlayer)

    triggerClientEvent(tradePlayer, "buypanel > startbuy > int", tradePlayer, client, price, veh)
end)

addEvent("buypanel > endVehSell", true)
addEventHandler("buypanel > endVehSell", resourceRoot, function(traderPlayer, type, veh, price)
    price = tonumber(price)
    setElementData(traderPlayer, "dashboard:inTrade", false)
    setElementData(client, "dashboard:inTrade", false)

    if type == 1 then -- Muito longe um do outro
        infobox:outputInfoBox("A venda foi cancelada: vocês ficaram longe demais um do outro.", "warning", traderPlayer)
    elseif type == 2 then -- Aceito
        exports.oInventory:deleteAllExisitingItemWithValue(234, getElementData(veh, "veh:id")) -- Remove todas as chaves copiadas

        infobox:outputInfoBox("Venda concluída!", "success", traderPlayer)
        setElementData(client, "char:money", getElementData(client, "char:money")-price)
        setElementData(traderPlayer, "char:money", getElementData(traderPlayer, "char:money")+price)
        setElementData(veh, "veh:owner", getElementData(client, "char:id"))

        outputChatBox(core:getServerPrefix("server", "Veículo", 3).."Você comprou o veículo ID "..color..getElementData(veh, "veh:id").." #ffffffpor "..color..price.."$#ffffff.", client, 255, 255, 255, true)
        outputChatBox(core:getServerPrefix("server", "Veículo", 3).."Você vendeu o veículo ID "..color..getElementData(veh, "veh:id").." #ffffffpor "..color..price.."$#ffffff.", traderPlayer, 255, 255, 255, true)
    elseif type == 3 then -- Dinheiro insuficiente
        infobox:outputInfoBox("O comprador não tem dinheiro suficiente!", "error", traderPlayer)
    elseif type == 4 then -- Recusado
        infobox:outputInfoBox("A proposta foi recusada!", "error", traderPlayer)
    elseif type == 4 then -- Recusado (slot)
        infobox:outputInfoBox("O comprador não tem slot de veículo suficiente!", "error", traderPlayer)
    end
end)

addEvent("buypanel > endIntSell", true)
addEventHandler("buypanel > endIntSell", resourceRoot, function(traderPlayer, type, int, price)
    price = tonumber(price)
    setElementData(traderPlayer, "dashboard:inTrade", false)
    setElementData(client, "dashboard:inTrade", false)

    if type == 1 then -- Muito longe um do outro
        infobox:outputInfoBox("A venda foi cancelada: vocês ficaram longe demais um do outro.", "warning", traderPlayer)
    elseif type == 2 then -- Aceito
        local intID = getElementData(int, "dbid")
        local newOwnerID = getElementData(client, "char:id")
        exports.oInventory:deleteAllExisitingItemWithValue(235, intID) -- Remove todas as chaves copiadas

        infobox:outputInfoBox("Venda concluída!", "success", traderPlayer)
        setElementData(client, "char:money", getElementData(client, "char:money")-price)
        setElementData(traderPlayer, "char:money", getElementData(traderPlayer, "char:money")+price)
        setElementData(int, "owner", newOwnerID)
        setElementData(getElementData(int, "other"), "owner", newOwnerID)

        dbExec(conn, "UPDATE `interiors` SET `owner` = ? WHERE id = ?", newOwnerID, intID)

        outputChatBox(core:getServerPrefix("server", "Imóvel", 3).."Você comprou o imóvel "..color..getElementData(int, "name").." #ffffffpor "..color..price.."$#ffffff.", client, 255, 255, 255, true)
        outputChatBox(core:getServerPrefix("server", "Imóvel", 3).."Você vendeu o imóvel "..color..getElementData(int, "name").." #ffffffpor "..color..price.."$#ffffff.", traderPlayer, 255, 255, 255, true)
    elseif type == 3 then -- Dinheiro insuficiente
        infobox:outputInfoBox("O comprador não tem dinheiro suficiente!", "error", traderPlayer)
    elseif type == 4 then -- Recusado
        infobox:outputInfoBox("A proposta foi recusada!", "error", traderPlayer)
    elseif type == 4 then -- Recusado (slot)
        infobox:outputInfoBox("O comprador não tem slot de imóvel suficiente!", "error", traderPlayer)
    end
end)

addEvent("dashboad > setPlayer > fightStyle", true)
addEventHandler("dashboad > setPlayer > fightStyle", resourceRoot, function(value)
    setPedFightingStyle(client, fightingStyles[value])
end)

addEvent("dashboad > setPlayer > walkStyle", true)
addEventHandler("dashboad > setPlayer > walkStyle", resourceRoot, function(value)
    setPedWalkingStyle(client, walkingStyles[value])
end)

function setDashboardRealtime()
    local realtime = getRealTime()
    setElementData(root, "dash:timestamp", getTimestamp(realtime.year + 1900, realtime.month, realtime.day, realtime.hour, realtime.minute, realtime.second))
end
setDashboardRealtime()
setTimer(setDashboardRealtime, core:minToMilisec(5), 0)