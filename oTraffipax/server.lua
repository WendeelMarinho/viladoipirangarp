local lastTicket = {}

local mysql = exports.oMysql:getDBConnection()

addEvent("traffipax > moneyminus", true)
addEventHandler("traffipax > moneyminus", resourceRoot, function(money)

    local vehPlate = getVehiclePlateText(getPedOccupiedVehicle(client))

    if not lastTicket[client] then 
        lastTicket[client] = getTickCount()
        dbExec(mysql, "INSERT INTO mdclogs SET reason=?, other=?, owner=?", "Excesso de velocidade", money .. "$", vehPlate)
    elseif getTickCount() - lastTicket[client] > 3600000 then 
        lastTicket[client] = getTickCount()
        dbExec(mysql, "INSERT INTO mdclogs SET reason=?, other=?, owner=?", "Excesso de velocidade", money .. "$", vehPlate)
    end
    
    setElementData(client, "char:money", getElementData(client, "char:money")-money)
    exports.oDashboard:setFactionBankMoney(1, math.floor(money*0.2), "add")

    local reason = exports.oMDC:getCarWantedReason(vehPlate)

    if reason then 
        reason = reason
    end

    if exports.oMDC:getCarIsWanted(vehPlate) then 
        for k, v in pairs(getElementsByType("player")) do 
            local faction = getElementData(v, "char:duty:faction") or 0
            if faction > 0 then 
                if exports.oDashboard:getFactionType(faction) == 1 then
                    outputChatBox(core:getServerPrefix("server", "Veículo procurado", 3).."Veículo procurado detectado num ponto de monitoramento!", v, 255, 255, 255, true)
                    outputChatBox(core:getServerPrefix("server", "Veículo procurado", 3).."Local: "..color..""..getZoneName(getElementPosition(client)), v, 255, 255, 255, true)
                    outputChatBox(core:getServerPrefix("server", "Veículo procurado", 3).."Placa: "..color..""..vehPlate.." #ffffff modelo: "..color..""..exports.oVehicle:getModdedVehName(getElementModel(getPedOccupiedVehicle(client))), v, 255, 255, 255, true)
                    outputChatBox(core:getServerPrefix("server", "Veículo procurado", 3).."Motivo: "..color..""..reason, v, 255, 255, 255, true)
                    
                    if isElement(blip) then 
                        for k, v in pairs(getElementsByType("blip")) do 
                            if getElementData(v, "blip:owner:id") then    
                                if getElementData(v, "blip:owner:id") == getElementData(client, "char:id") then 
                                    destroyElement(blip)
                                end
                            end
                        end
                    end 

                    pos = Vector3(getElementPosition(client))
                    blip = createBlip(pos.x, pos.y, pos.z, 5)
                    setElementData(blip, "blip:name", "Veículo procurado")
                    setElementData(blip, "blip:owner:id", getElementData(client, "char:id"))
                    attachElementToElement(blip, client)  

                    setTimer(function()
                        if isElement(blip) then       
                            destroyElement(blip)   
                        end
                    end, 10000, 1)      
                end 
            end
        end
    end
end)