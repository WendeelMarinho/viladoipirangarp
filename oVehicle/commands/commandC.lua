addCommandHandler("gotocar", function(cmd, carID)

    if getElementData(localPlayer, "user:admin") > 1 then 
        carID = tonumber(carID) or 0
        
        if carID > 0 then 

            for k, v in ipairs(getElementsByType("vehicle")) do 
                if getElementData(v, "veh:id") == carID then 
                    triggerServerEvent("gotoCarOnServer", resourceRoot, localPlayer, v)
                    outputChatBox(core:getServerPrefix("server", "Veículo",3).."Você teleportou-se até o veículo "..color..carID.."#ffffff pelo ID.", 255, 255, 255, true)
                    return
                end
            end
            outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)

        else
            outputChatBox(core:getServerPrefix("server", "Veículo",3).."/gotocar [ID]", 255, 255, 255, true)
        end

    end
end)
admin:addAdminCMD("gotocar", 2, "Teleportar até veículo (ID)")

addCommandHandler("getcar", function(cmd, carID)

    if getElementData(localPlayer, "user:admin") > 1 then 
        carID = tonumber(carID) or 0
        
        if carID > 0 then 

            for k, v in ipairs(getElementsByType("vehicle")) do 
                if getElementData(v, "veh:id") == carID then 
                    if getElementData(v, "vehIsBooked") == 1 then 
                        outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Este veículo está apreendido/reservado!", 255, 255, 255, true)
                        return
                    end

                    if getElementData(v, "inCarshop") then 
                        outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Este veículo está num stand de usados!", 255, 255, 255, true)
                        return
                    end

                    triggerServerEvent("getCarOnServer", resourceRoot, localPlayer, v)
                    outputChatBox(core:getServerPrefix("server", "Veículo",3).."Veículo puxado até ti (ID "..color..carID.."#ffffff).", 255, 255, 255, true)
                    return
                end
            end
            outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)

        else
            outputChatBox(core:getServerPrefix("server", "Veículo",3).."/getcar [ID]", 255, 255, 255, true)
        end

    end

end)
admin:addAdminCMD("getcar", 2, "Puxar veículo até ti pelo ID")

addCommandHandler("setvehplatetext", function(cmd, carID, text)

    if carID and text then 
        if getElementData(localPlayer, "user:admin") >= 5 then
            
            if string.len(text) <= 8 then 

                if carID == "*" then

                    local vehicle = getPedOccupiedVehicle(localPlayer) 

                    if vehicle then 

                        triggerServerEvent("setVehiclePlateText", resourceRoot, localPlayer, vehicle, tostring(text))
                        outputChatBox(core:getServerPrefix("server", "Veículo",3).."Alterou o veículo "..color..getElementData(vehicle, "veh:id").."#ffffff (placa)! "..color.."("..text..")", 255, 255, 255, true)
                        return

                    else

                        outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Você não está num veículo!", 255, 255, 255, true)
                        return

                    end 

                else

                    carID = tonumber(carID) or 0 
                    
                    if carID > 0 then 

                        for k, v in ipairs(getElementsByType("vehicle")) do 
                            if getElementData(v, "veh:id") == carID then 
                                triggerServerEvent("setVehiclePlateText", resourceRoot, localPlayer, v, tostring(text))
                                outputChatBox(core:getServerPrefix("server", "Veículo",3).."Alterou o veículo "..color..carID.."#ffffff (placa)! "..color.."("..text..")", 255, 255, 255, true)
                                return
                            end
                        end
                        outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)
            
                    end

                end 

            else

                outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Placa longa demais!", 255, 255, 255, true)

            end

        end
    else
        outputChatBox(core:getServerPrefix("server", "Veículo",3).."/setvehplatetext [ID] [texto]", 255, 255, 255, true)
    end

end)
admin:addAdminCMD("setvehplatetext", 5, "Alterar placa do veículo")

addCommandHandler("fuelveh", function(cmd, target)

    if getElementData(localPlayer, "user:admin") > 2 then 
        if target then
			local target = core:getPlayerFromPartialName(localPlayer, target)
            if target then
                if getPedOccupiedVehicle(target) then 
                    local carID = getElementData(getPedOccupiedVehicle(target), "veh:id")
                    if carID > 0 then 
                        --for k, v in ipairs(getElementsByType("vehicle")) do 
                        -- if getElementData(v, "veh:id") == carID then 
                                triggerServerEvent("fuelVehicle", resourceRoot, getPedOccupiedVehicle(target), target)
                                outputChatBox(core:getServerPrefix("server", "Veículo",3).."Encheu o tanque de "..color..getPlayerName(target):gsub("_", " ").."#ffffff (no veículo dele)!", 255, 255, 255, true)
                                return
                            --end
                        --end
                    
                    else
                        outputChatBox(core:getServerPrefix("server", "Veículo",3).."/fuelveh [jogador/ID]", 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."O jogador não está num veículo!", 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("server", "Veículo",3).."/fuelveh [jogador/ID]", 255, 255, 255, true)
            end
               
        else
            outputChatBox(core:getServerPrefix("server", "Veículo",3).."/fuelveh [jogador/ID]", 255, 255, 255, true)
        end
    end
end)
admin:addAdminCMD("fuelveh", 3, "Encher tanque do veículo do jogador")

addCommandHandler("setvehfuel", function(cmd, target, value)
    if getElementData(localPlayer, "user:admin") > 2 then 
        if target or value then
			local target = core:getPlayerFromPartialName(localPlayer, target)
            if target then
                if getPedOccupiedVehicle(target) then 
                    local carID = getElementData(getPedOccupiedVehicle(target), "veh:id")
                    if carID > 0 then 
                        --for k, v in ipairs(getElementsByType("vehicle")) do 
                        -- if getElementData(v, "veh:id") == carID then 
                                triggerServerEvent("setFuelVeh", resourceRoot, getPedOccupiedVehicle(target), target, value)
                                outputChatBox(core:getServerPrefix("server", "Veículo",3).."Encheu o tanque de "..color..getPlayerName(target):gsub("_", " ").."#ffffff (no veículo dele)!", 255, 255, 255, true)
                                return
                            --end
                        --end
                    
                    else
                        outputChatBox(core:getServerPrefix("server", "Veículo",3).."/setvehfuel [jogador] [litros]", 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."O jogador não está num veículo!", 255, 255, 255, true)
                end
            else
                outputChatBox(core:getServerPrefix("server", "Veículo",3).."/setvehfuel [jogador] [litros]", 255, 255, 255, true)
            end
               
        else
            outputChatBox(core:getServerPrefix("server", "Veículo",3).."/setvehfuel [jogador] [litros]", 255, 255, 255, true)
        end
    end
end)
admin:addAdminCMD("setvehfuel", 3, "Definir litros no veículo do jogador")

addCommandHandler("setvehcolor", function(cmd, carID, r, g, b, r1, g1, b1)

    if getElementData(localPlayer, "user:admin") > 5 then 
        if carID and r and g and b then 

                r, g, b = tonumber(r), tonumber(g), tonumber(b)
                r1, g1, b1 = tonumber(r1), tonumber(g1), tonumber(b1)
                if not r1 and g1 and b1 then 
                    r1, g1, b1 = 255, 255, 255
                else 
                    r1, g1, b1 = tonumber(r1), tonumber(g1), tonumber(b1) 
                end

                if carID == "*" then

                    local vehicle = getPedOccupiedVehicle(localPlayer) 

                    if vehicle then 

                        triggerServerEvent("setVehicleColorOnServer", resourceRoot, localPlayer, vehicle, {r, g, b, r1, g1, b1})
                        outputChatBox(core:getServerPrefix("server", "Veículo",3).."Alterou o veículo "..color..getElementData(vehicle, "veh:id").."#ffffff — cor alterada!", 255, 255, 255, true)
                        return

                    else

                        outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Você não está num veículo!", 255, 255, 255, true)
                        return

                    end 

                else

                    carID = tonumber(carID) or 0 
                    
                    if carID > 0 then 

                        for k, v in ipairs(getElementsByType("vehicle")) do 
                            if getElementData(v, "veh:id") == carID then 
                                triggerServerEvent("setVehicleColorOnServer", resourceRoot, localPlayer, v, {r, g, b, r1, g1, b1})
                                outputChatBox(core:getServerPrefix("server", "Veículo",3).."Alterou o veículo "..color..carID.."#ffffff — cor alterada!", 255, 255, 255, true)
                                return
                            end
                        end
                        outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)
            
                    end

                end
        else
            outputChatBox(core:getServerPrefix("server", "Veículo",3).."/setvehcolor [ID] [R] [G] [B] <R1 G1 B1>", 255, 255, 255, true)
        end
    end

end)
admin:addAdminCMD("setvehcolor", 6, "Alterar cor do veículo")

addCommandHandler("delveh", function(cmd, carID)
    if getElementData(localPlayer, "user:admin") >= 7 then 
        if carID then 
            if carID == "*" then

                local vehicle = getPedOccupiedVehicle(localPlayer) 

                if vehicle then 

                    triggerServerEvent("delVehicleOnServer", resourceRoot, localPlayer, vehicle)
                    outputChatBox(core:getServerPrefix("server", "Veículo",3).."Veículo apagado (ID "..color..getElementData(vehicle, "veh:id").."#ffffff).", 255, 255, 255, true)
                    return

                else

                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Você não está num veículo!", 255, 255, 255, true)
                    return

                end 

            else

                carID = tonumber(carID) or 0 
                
                if carID > 0 then 

                    for k, v in ipairs(getElementsByType("vehicle")) do 
                        if getElementData(v, "veh:id") == carID then 
                            triggerServerEvent("delVehicleOnServer", resourceRoot, localPlayer, v)
                            outputChatBox(core:getServerPrefix("server", "Veículo",3).."Veículo apagado (ID "..color..carID.."#ffffff).", 255, 255, 255, true)
                            return
                        end
                    end
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)
        
                end

            end
        else
            outputChatBox(core:getServerPrefix("server", "Veículo",3).."/delveh [ID]", 255, 255, 255, true)
        end
    end

end)
admin:addAdminCMD("delveh", 7, "Apagar veículo da base")

addCommandHandler("setcarhp", function(cmd, carID, hp)

    if carID then 
        if getElementData(localPlayer, "user:admin") >= 7 then 

            hp = tonumber(hp)

            if carID == "*" then

                local vehicle = getPedOccupiedVehicle(localPlayer) 

                if vehicle then 

                    triggerServerEvent("setVehicleHpOnServer", resourceRoot, localPlayer, vehicle, hp)
                    outputChatBox(core:getServerPrefix("server", "Veículo",3).."Definiu a vida do veículo "..color..getElementData(vehicle, "veh:id").."#ffffff — vida: "..color.."("..hp..")", 255, 255, 255, true)
                    return

                else

                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Você não está num veículo!", 255, 255, 255, true)
                    return

                end 

            else

                carID = tonumber(carID) or 0 
                
                if carID > 0 then 

                    for k, v in ipairs(getElementsByType("vehicle")) do 
                        if getElementData(v, "veh:id") == carID then 
                            triggerServerEvent("setVehicleHpOnServer", resourceRoot, localPlayer, v, hp)
                            outputChatBox(core:getServerPrefix("server", "Veículo",3).."Definiu a vida do veículo "..color..carID.."#ffffff — vida: "..color.."("..hp..")", 255, 255, 255, true)
                            return
                        end
                    end
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)
        
                end

            end

        end
    else
        outputChatBox(core:getServerPrefix("server", "Veículo",3).."/setcarhp [ID ou *] [HP 0-1000]", 255, 255, 255, true)
    end

end)
admin:addAdminCMD("setcarhp", 7, "Definir vida (HP) do veículo")

addCommandHandler("blowveh", function(cmd, carID, hp)
    if carID then 
        if getElementData(localPlayer, "user:admin") >= 10 then 
            if carID == "*" then
                local vehicle = getPedOccupiedVehicle(localPlayer) 

                if vehicle then 

                    triggerServerEvent("blowUpVehicle", resourceRoot, localPlayer, vehicle)
                    outputChatBox(core:getServerPrefix("server", "Veículo",3).."Veículo detonado (ID "..color..getElementData(vehicle, "veh:id").."#ffffff).", 255, 255, 255, true)
                    return

                else

                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Você não está num veículo!", 255, 255, 255, true)
                    return

                end 
            else
                carID = tonumber(carID) or 0 
                
                if carID > 0 then 
                    for k, v in ipairs(getElementsByType("vehicle")) do 
                        if getElementData(v, "veh:id") == carID then 
                            triggerServerEvent("blowUpVehicle", resourceRoot, localPlayer, v)
                            outputChatBox(core:getServerPrefix("server", "Veículo",3).."Veículo detonado (ID "..color..getElementData(v, "veh:id").."#ffffff).", 255, 255, 255, true)
                            return
                        end
                    end
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)
                end
            end
        end
    else
        outputChatBox(core:getServerPrefix("server", "Veículo",3).."/blowveh [ID ou *]", 255, 255, 255, true)
    end
end)
admin:addAdminCMD("blowveh", 10, "Explodir veículo")

addCommandHandler("respawnveh", function(cmd, carID, hp)
    if carID then 
        if getElementData(localPlayer, "user:admin") >= 2 then 
            if carID == "*" then
                local vehicle = getPedOccupiedVehicle(localPlayer) 

                if vehicle then 

                    triggerServerEvent("respawnVeh", resourceRoot, localPlayer, vehicle)
                    outputChatBox(core:getServerPrefix("server", "Veículo",3).."Respawn aplicado (ID "..color..getElementData(vehicle, "veh:id").."#ffffff).", 255, 255, 255, true)
                    return

                else

                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Você não está num veículo!", 255, 255, 255, true)
                    return

                end 
            else
                carID = tonumber(carID) or 0 
                
                if carID > 0 then 
                    for k, v in ipairs(getElementsByType("vehicle")) do 
                        if getElementData(v, "veh:id") == carID then 
                            triggerServerEvent("respawnVeh", resourceRoot, localPlayer, v)
                            outputChatBox(core:getServerPrefix("server", "Veículo",3).."Respawn aplicado (ID "..color..getElementData(v, "veh:id").."#ffffff).", 255, 255, 255, true)
                            return
                        end
                    end
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)
                end
            end
        end
    else
        outputChatBox(core:getServerPrefix("server", "Veículo",3).."/respawnveh [ID ou *]", 255, 255, 255, true)
    end
end)
admin:addAdminCMD("respawnveh", 2, "Respawn do veículo")

addCommandHandler("warp", function(cmd)

    if getElementData(localPlayer, "user:admin") >= 2 then 

        triggerServerEvent("warpPedToVehicleOnServer", resourceRoot, localPlayer, getNearestVehicle(localPlayer, 25))

    end

end)
admin:addAdminCMD("warp", 2, "Entrar no veículo mais próximo")

addCommandHandler("rtc", function(cmd)

    if getElementData(localPlayer, "user:admin") >= 3 then

        local rtc_needed_vehicles = {}
        local playerDim, playerInt = getElementDimension(localPlayer), getElementInterior(localPlayer)

        for k, v in ipairs(getElementsByType("vehicle")) do 

            if core:getDistance(localPlayer, v) <= 15 then 

                if getElementDimension(v) == playerDim and getElementInterior(v) == playerInt then 

                    table.insert(rtc_needed_vehicles, #rtc_needed_vehicles+1, v)

                end

            end

        end

        if #rtc_needed_vehicles > 0 then 
            triggerServerEvent("rtcVehiclesOnServer", resourceRoot, localPlayer, rtc_needed_vehicles)
        else
            outputChatBox(core:getServerPrefix("red-dark", "RTC", 3).."Não há veículos por perto!", 255, 255, 255, true)
        end
    end 

end)
admin:addAdminCMD("rtc", 3, "RTC — veículos vazios por perto (sem ocupante)")

addCommandHandler("nearbyvehicles", function(cmd)
    if getElementData(localPlayer, "user:admin") >= 3 then

        local playerDim, playerInt = getElementDimension(localPlayer), getElementInterior(localPlayer)
        outputChatBox(color.."<===== [Veículos próximos] =====>", 255, 255, 255, true)

        for k, vehicle in pairs(getElementsByType("vehicle")) do 
            if core:getDistance(localPlayer, vehicle) <= 15 then 
                if getElementDimension(vehicle) == playerDim and getElementInterior(vehicle) == playerInt then 
                    print(tonumber(getElementData(vehicle,"veh:isFactionVehicle")))

                    if not (getElementData(vehicle,"veh:isFactionVehicle") == 1) then
                        for k,v in pairs(getElementsByType("player")) do 
                            if getElementData(v,"char:id") == getElementData(vehicle, "veh:owner") then 
                                ownerPlayer = v
                                print(getElementData(v,"char:id"))
                            end 
                        end 
                    
                        text = ""

                        if ownerPlayer then
                            local playerid = getElementData(ownerPlayer,"playerid")
                            local charname = getElementData(ownerPlayer,"char:name")
                            text = charname.." ["..playerid.."]"
                        elseif not ownerPlayer then 
                            text = getElementData(vehicle,"veh:owner").." [CHAR offline ou facção]"
                        end 

                        outputChatBox(core:getServerPrefix("blue-dark", getElementData(vehicle, "veh:id"), 3).."Modelo: "..color..getModdedVehName(getElementModel(vehicle)).." #ffffffDono: "..color..text, 255, 255, 255, true)
                        ownerPlayer = nil
                    else 
                        text = getElementData(vehicle,"veh:owner").." [FACÇÃO]"
                        outputChatBox(core:getServerPrefix("blue-dark", getElementData(vehicle, "veh:id"), 3).."Modelo: "..color..getModdedVehName(getElementModel(vehicle)).." #ffffffDono: "..color..text, 255, 255, 255, true)
                    end
                end    
            end
        end
    end
end)
admin:addAdminCMD("nearbyvehicles", 3, "Listar veículos próximos")

addCommandHandler("getvehid", function(cmd)
    if getElementData(localPlayer, "user:admin") >= 2 then

        local veh = getPedOccupiedVehicle(localPlayer) or false
        if veh then 
            outputChatBox(core:getServerPrefix("server", "Veículo", 3).."ID veículo: "..color..getElementData(veh, "veh:id").." #ffffffModelo: "..color..getVehicleName(veh) .." #ffffffDono: "..color..getElementData(veh, "veh:owner").." #ffffffID modelo GTA: "..color..getElementModel(veh), 255, 255, 255, true)
        else
            outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."Você não está num veículo!", 255, 255, 255, true)
        end
    end
end)
admin:addAdminCMD("getvehid", 2, "Ver ID do veículo atual")

admin:addAdminCMD("makeveh", 7, "Criar veículo (admin)")

addCommandHandler("protectveh", function(cmd, vehID)
    if vehID then 
        if getElementData(localPlayer, "user:admin") >= 7 then 

            if vehID == "*" then

                local vehicle = getPedOccupiedVehicle(localPlayer) 

                if vehicle then 

                    if getElementData(vehicle, "veh:protected") == 0 then 
                        triggerServerEvent("protectVehicleOnServer", resourceRoot, vehicle)
                        outputChatBox(core:getServerPrefix("server", "Veículo",3).."Proteção ativada (ID "..color..getElementData(vehicle, "veh:id").."#ffffff).", 255, 255, 255, true)
                        return
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."Este veículo já está protegido!", 255, 255, 255, true)
                    end

                else

                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Você não está num veículo!", 255, 255, 255, true)
                    return

                end 

            else

                vehID = tonumber(carID) or 0 
                
                if vehID > 0 then 

                    for k, v in ipairs(getElementsByType("vehicle")) do 
                        if getElementData(v, "veh:id") == vehID then 
                            if getElementData(v, "veh:protected") == 0 then 
                                triggerServerEvent("protectVehicleOnServer", resourceRoot, v)
                                outputChatBox(core:getServerPrefix("server", "Veículo",3).."Proteção ativada (ID "..color..getElementData(v, "veh:id").."#ffffff).", 255, 255, 255, true)
                                return
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."Este veículo já está protegido!", 255, 255, 255, true)
                            end
                        end
                    end
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)
        
                end

            end

        end
    else
        outputChatBox(core:getServerPrefix("server", "Veículo",3).."/"..cmd.." [ID]", 255, 255, 255, true)
    end
end)
admin:addAdminCMD("protectveh", 7, "Marcar veículo como protegido")

addCommandHandler("unprotectveh", function(cmd, vehID)
    if vehID then 
        if getElementData(localPlayer, "user:admin") >= 7 then 

            if vehID == "*" then

                local vehicle = getPedOccupiedVehicle(localPlayer) 

                if vehicle then 

                    if getElementData(vehicle, "veh:protected") == 1 then 
                        triggerServerEvent("unprotectVehicleOnServer", resourceRoot, vehicle)
                        outputChatBox(core:getServerPrefix("server", "Veículo",3).."Removeste a proteção do veículo "..color..getElementData(vehicle, "veh:id").."#ffffff!", 255, 255, 255, true)
                        return
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."Este veículo não está protegido!", 255, 255, 255, true)
                    end

                else

                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Você não está num veículo!", 255, 255, 255, true)
                    return

                end 

            else

                vehID = tonumber(carID) or 0 
                
                if vehID > 0 then 

                    for k, v in ipairs(getElementsByType("vehicle")) do 
                        if getElementData(v, "veh:id") == vehID then 
                            if getElementData(v, "veh:protected") == 1 then 
                                triggerServerEvent("unprotectVehicleOnServer", resourceRoot, v)
                                outputChatBox(core:getServerPrefix("server", "Veículo",3).."Removeste a proteção do veículo "..color..getElementData(v, "veh:id").."#ffffff!", 255, 255, 255, true)
                                return
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."Este veículo não está protegido!", 255, 255, 255, true)
                            end
                        end
                    end
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo",3).."Não há veículo com esse ID!", 255, 255, 255, true)
        
                end

            end

        end
    else
        outputChatBox(core:getServerPrefix("server", "Veículo",3).."/"..cmd.." [ID]", 255, 255, 255, true)
    end
end)
admin:addAdminCMD("unprotectveh", 7, "Remover proteção do veículo")

---------[ Civil commands ]---------
--kiszed
addCommandHandler("kiszed", function(cmd, id)
    if id then 
        if not getPedOccupiedVehicle(localPlayer) then 
            if tonumber(id) > 0 then 
                local target, targetName = core:getPlayerFromPartialName(localPlayer, id)

                if core:getDistance(localPlayer, target) <= 3 then
                    local targetVehicle = getPedOccupiedVehicle(target)
                    if targetVehicle then
                        if not (getElementData(targetVehicle, "veh:locked")) then 
                            if not (getElementData(target, "vehicle:seatbeltState")) then 
                                triggerServerEvent("takeOutFromVehicle", resourceRoot, target)
                            else
                                outputChatBox(core:getServerPrefix("red-dark", "Retirar", 2).."O jogador está com o cinto afivelado!", 255, 255, 255, true)
                            end
                        else
                            outputChatBox(core:getServerPrefix("red-dark", "Retirar", 2).."As portas do veículo estão trancadas!", 255, 255, 255, true)
                        end 
                    else
                        outputChatBox(core:getServerPrefix("red-dark", "Retirar", 2).."Este jogador não está num veículo!", 255, 255, 255, true)
                    end
                else
                    outputChatBox(core:getServerPrefix("red-dark", "Retirar", 2).."Você está longe demais!", 255, 255, 255, true)
                end 
            else
                outputChatBox(core:getServerPrefix("red-dark", "Retirar", 2).."Use o ID numérico do jogador.", 255, 255, 255, true)
            end
        else
            outputChatBox(core:getServerPrefix("red-dark", "Retirar", 2).."Este comando só funciona fora de veículo.", 255, 255, 255, true)
        end
    else
        outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [ID]", 255, 255, 255, true)
    end
end)
--öv elvágása

addEventHandler("onClientVehicleStartEnter", root, function(player, seat, door)
    if player == localPlayer then 
        if seat == 0 then 
            local occupants = getVehicleOccupants(source)
            
            if occupants[0] then
                outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."Entrar assim é anti-RP — use "..color.."/kiszed #ffffffpara retirar o condutor IC.", 255, 255, 255, true) 
                cancelEvent()
            end
        end
    end
end)

-- park 
--[[addCommandHandler("park", function()
    local occupiedVeh = getPedOccupiedVehicle(localPlayer)

    if occupiedVeh then 
        if getElementData(occupiedVeh, "veh:isFactionVehice") == 0 then 
            if getElementData(occupiedVeh, "veh:owner") == getElementData(localPlayer, "char:id") then 
                local x, y, z = getElementPosition(occupiedVeh)
                setElementData(occupiedVeh, "veh:parkPos", {x, y, z, getElementInterior(occupiedVeh), getElementDimension(occupiedVeh)})
                outputChatBox(core:getServerPrefix("green-dark", "Veículo", 3).."Veículo estacionado.", 255, 255, 255, true) 
            end
        end
    end
end)]]