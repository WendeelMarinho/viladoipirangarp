function sendMessageToAdmins(player, msg)
	triggerClientEvent(getRootElement(), "sendMessageToAdmins", getRootElement(), player, msg, 2)
end

addCommandHandler("makeveh", function(player, cmd, modelId, target, isFactionVehicle, colorR, colorG, colorB, plateText)

    if getElementData(player,"user:admin") >= 7 then

        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt


        isFactionVehicle = tonumber(isFactionVehicle)
        if tonumber(modelId) and isFactionVehicle ~= nil then

            if isFactionVehicle > 1 then isFactionVehicle = 0 end
            if not tonumber(colorR) then colorR = 255 end
            if not tonumber(colorG) then colorG = 255 end
            if not tonumber(colorB) then colorB = 255 end
            if not tostring(plateText) then plateText = createRandomPlateText() end

            --[[if tostring(plateText) then
                if string.len(plateText) > 8 then
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."Placa longa demais!", player, 255, 255, 255, true)
                    return
                end
            end]]

            local color = {colorR,colorG,colorB}

            local targetName
            if isFactionVehicle == 1 then
                if not tonumber(target) or not (exports.oDashboard:isRealFaction(tonumber(target))) then
                    outputChatBox(core:getServerPrefix("red-dark", "Veículo", 3).."Não existe facção com esse ID!", player, 255, 255, 255, true)
                    return
                end
            else
                target, targetName = core:getPlayerFromPartialName(player, target)
                if not target then
                    return
                end
            end

            if tonumber(modelId) then
                modelName = getModdedVehName(tonumber(modelId))
                if not modelName then return end
            elseif tostring(modelId) then
                model = getVehicleModelFromName(modelId)
                if not model then return end
                modelName = getModdedVehName(modelId)
            end

            local playerX, playerY, playerZ

            if isFactionVehicle == 1 then
                playerX, playerY, playerZ = getElementPosition(player)
            else
                playerX, playerY, playerZ = getElementPosition(target)
            end

            local veh

            if isFactionVehicle == 1 then
                veh = createNewFactionVehicle(modelId, target, {playerX+2,playerY+2, playerZ}, {0,0,0}, {colorR, colorG, colorB}, plateText)

                setTimer(function()
                    sendMessageToAdmins(player, "criou veículo de facção #db3535"..modelName.."#557ec9 (ID "..getElementData(veh, "veh:id").."#557ec9). Facção: #db3535"..exports.oDashboard:getFactionName(tonumber(target)))
                    setElementData(player, "log:admincmd", {"Faction: "..target, cmd})
                end, 500, 1)
            else
                veh = createNewVehicle(modelId, target, {playerX+2,playerY+2, playerZ}, {0,0,0}, {colorR, colorG, colorB}, plateText)
                
                setTimer(function()
                    sendMessageToAdmins(player, "criou veículo #db3535"..modelName.."#557ec9 (ID "..getElementData(veh, "veh:id").."#557ec9). Dono: #db3535"..targetName)
                    setElementData(player, "log:admincmd", {getElementData(target, "char:id"), cmd})
                end, 500, 1)
            end

        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/makeveh [ID modelo] [ID jogador ou facção] [Veículo facção 0:não 1:sim] [R] [G] [B] [texto placa]", player, 255, 255, 255, true)
        end

    end

end)

function gotoCar(player, veh)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    local vX, vY, vZ = getElementPosition(veh)
    setElementPosition(player, vX+2, vY+2, vZ, true)

    if getElementData(player, "char:id") == getElementData(veh, "veh:owner") then
        sendMessageToAdmins(player, "teleportou-se ao veículo #db3535"..getElementData(veh,"veh:id").."#557ec9. #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(player, "teleportou-se ao veículo #db3535"..getElementData(veh,"veh:id").."#557ec9.")
    end
end
addEvent("gotoCarOnServer", true)
addEventHandler("gotoCarOnServer", resourceRoot, gotoCar)

function getCar(player, veh)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    local pX, pY, pZ = getElementPosition(player)
    setElementPosition(veh, pX+2, pY+2, pZ, true)
    setElementDimension(veh, getElementDimension(player))
    setElementInterior(veh, getElementInterior(player))

    if getElementData(player, "char:id") == getElementData(veh, "veh:owner") then
        sendMessageToAdmins(player, "teleportou o veículo #db3535"..getElementData(veh,"veh:id").."#557ec9 até si. #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(player, "teleportou o veículo #db3535"..getElementData(veh,"veh:id").."#557ec9 até si.")
    end
end
addEvent("getCarOnServer", true)
addEventHandler("getCarOnServer", resourceRoot, getCar)

function setVehPlateText(player, veh, text)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    setVehiclePlateText(veh, text)

    if getElementData(player, "char:id") == getElementData(veh, "veh:owner") then
        sendMessageToAdmins(player, "alterou a placa do veículo #db3535"..getElementData(veh,"veh:id").."#557ec9. Nova: #db3535"..text.." #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(player, "alterou a placa do veículo #db3535"..getElementData(veh,"veh:id").."#557ec9. Nova placa: #db3535"..text)
    end

    setElementData(player, "log:admincmd", {"Veh: "..getElementData(veh, "veh:id"), "setvehplatetext"})
end
addEvent("setVehiclePlateText", true)
addEventHandler("setVehiclePlateText", resourceRoot, setVehPlateText)

function setVehColor(player, veh, color)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    setVehicleColor(veh, color[1], color[2], color[3], color[4], color[5], color[6])

    if getElementData(player, "char:id") == getElementData(veh, "veh:owner") then
        sendMessageToAdmins(player, "alterou a cor do veículo #db3535"..getElementData(veh,"veh:id").."#557ec9. "..RGBToHex(color[1], color[2], color[3]).."("..color[1]..", "..color[2]..", "..color[3]..") #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(player, "alterou a cor do veículo #db3535"..getElementData(veh,"veh:id").."#557ec9. "..RGBToHex(color[1], color[2], color[3]).."("..color[1]..", "..color[2]..", "..color[3]..")")
    end

    setElementData(player, "log:admincmd", {"Veh: "..getElementData(veh,"veh:id"), "setvehcolor"})
end
addEvent("setVehicleColorOnServer", true)
addEventHandler("setVehicleColorOnServer", resourceRoot, setVehColor)

function delVeh(player, vehicle)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    if getElementData(player, "char:id") == getElementData(vehicle, "veh:owner") then
        sendMessageToAdmins(player, "removeu o veículo #db3535"..getElementData(vehicle,"veh:id").."#557ec9. #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(player, "removeu o veículo #db3535"..getElementData(vehicle,"veh:id").."#557ec9.")
    end
    setElementData(player, "log:admincmd", {"Veh"..getElementData(vehicle,"veh:id"), "delveh"})

    deleteVehicle(vehicle)
end
addEvent("delVehicleOnServer", true)
addEventHandler("delVehicleOnServer", resourceRoot, delVeh)

function setVehHP(player, veh, hp)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    setElementHealth(veh, hp)
    setVehicleDamageProof(veh, false)

    if getElementData(player, "char:id") == getElementData(veh, "veh:owner") then
        sendMessageToAdmins(player, "alterou a vida do veículo #db3535"..getElementData(veh,"veh:id").."#557ec9 para #db3535("..hp..") #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(player, "alterou a vida do veículo #db3535"..getElementData(veh,"veh:id").."#557ec9 para #db3535("..hp..")")
    end

end
addEvent("setVehicleHpOnServer", true)
addEventHandler("setVehicleHpOnServer", resourceRoot, setVehHP)

function warpPedToVehicleOnServerFunc(player, vehicle)
    if not getPedOccupiedVehicle(player) then
        warpPedIntoVehicle(player,vehicle)
    else
        removePedFromVehicle(player)
        local pos = Vector3(getElementPosition(player))

        setElementPosition(player, pos.x, pos.y, pos.z + 3)
    end
end
addEvent("warpPedToVehicleOnServer", true)
addEventHandler("warpPedToVehicleOnServer", resourceRoot, warpPedToVehicleOnServerFunc)

function rtcVehicles(player, cars)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    for k, v in ipairs(cars) do
        if not getVehicleOccupant(v) then
            setElementDimension(v, getElementData(v, "veh:owner"))

            if getElementData(player, "char:id") == getElementData(v, "veh:owner") then
                sendMessageToAdmins(player, "fez RTC no veículo #db3535"..getElementData(v,"veh:id").."#557ec9. #db3535[Próprio veículo!]")
            else
                sendMessageToAdmins(player, "fez RTC no veículo #db3535"..getElementData(v,"veh:id").."#557ec9.")
            end
        end
    end
end
addEvent("rtcVehiclesOnServer", true)
addEventHandler("rtcVehiclesOnServer", resourceRoot, rtcVehicles)

function protectVeh(car)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(client) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    setElementData(car, "veh:protected", 1)

    if getElementData(client, "char:id") == getElementData(car, "veh:owner") then
        sendMessageToAdmins(client, "protegeu o veículo #db3535"..getElementData(car,"veh:id").."#557ec9. #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(client, "protegeu o veículo #db3535"..getElementData(car,"veh:id").."#557ec9.")
    end
end
addEvent("protectVehicleOnServer", true)
addEventHandler("protectVehicleOnServer", resourceRoot, protectVeh)

function unprotectVeh(car)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(client) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    setElementData(car, "veh:protected", 0)

    if getElementData(client, "char:id") == getElementData(car, "veh:owner") then
        sendMessageToAdmins(client, "removeu a proteção do veículo #db3535"..getElementData(car,"veh:id").."#557ec9. #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(client, "removeu a proteção do veículo #db3535"..getElementData(car,"veh:id").."#557ec9.")
    end
end
addEvent("unprotectVehicleOnServer", true)
addEventHandler("unprotectVehicleOnServer", resourceRoot, unprotectVeh)

function fuelVeh(car, target)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(client) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    setElementData(car, "veh:fuel", getElementData(car, "veh:maxFuel"))
    setElementData(car, "veh:lastFuelType", getElementData(car, "veh:fuelType"))


    if getElementData(client, "char:id") == getElementData(car, "veh:owner") then
        sendMessageToAdmins(client, "encheu o tanque do jogador #db3535"..getPlayerName(target):gsub("_", " ").."#557ec9. #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(client, "encheu o tanque do jogador #db3535"..getPlayerName(target):gsub("_", " ").."#557ec9.")
    end
end
addEvent("fuelVehicle", true)
addEventHandler("fuelVehicle", resourceRoot, fuelVeh)

function setFuelVeh(car, target, value)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(client) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    if tonumber(value) > getElementData(car, "veh:maxFuel") then
        setElementData(car, "veh:fuel", getElementData(car, "veh:maxFuel"))
        value = getElementData(car, "veh:maxFuel")
    else
        setElementData(car, "veh:fuel", value)
    end

    setElementData(car, "veh:lastFuelType", getElementData(car, "veh:fuelType"))


    if getElementData(client, "char:id") == getElementData(car, "veh:owner") then
        sendMessageToAdmins(client, "definiu combustível (".. value .." L) no veículo de #db3535"..getPlayerName(target):gsub("_", " ").."#557ec9. #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(client, "definiu combustível (".. value .." L) no veículo de #db3535"..getPlayerName(target):gsub("_", " ").."#557ec9.")
    end
end
addEvent("setFuelVeh", true)
addEventHandler("setFuelVeh", resourceRoot, setFuelVeh)

addEvent("takeOutFromVehicle", true)
addEventHandler("takeOutFromVehicle", resourceRoot, function(target)
    chat:sendLocalMeAction(client, "retirou "..getPlayerName(target):gsub("_", " ").." de um veículo próximo.")
    removePedFromVehicle(target)

    local targetPos = Vector3(getElementPosition(target))

    setElementPosition(target, targetPos.x, targetPos.y, targetPos.z+1)
end)

function blowVeh(target, car)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(client) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    blowVehicle(car)

    if getElementData(client, "char:id") == getElementData(car, "veh:owner") then
        sendMessageToAdmins(client, "detonou o veículo #db3535"..getElementData(car, "veh:id").."#557ec9. #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(client, "detonou o veículo #db3535"..getElementData(car, "veh:id").."#557ec9.")
    end
end
addEvent("blowUpVehicle", true)
addEventHandler("blowUpVehicle", resourceRoot, blowVeh)

function respawnVeh(target, car)
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(client) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    respawnVehicle(car)

    if getElementData(client, "char:id") == getElementData(car, "veh:owner") then
        sendMessageToAdmins(client, "deu respawn no veículo #db3535"..getElementData(car, "veh:id").."#557ec9. #db3535[Próprio veículo!]")
    else
        sendMessageToAdmins(client, "deu respawn no veículo #db3535"..getElementData(car, "veh:id").."#557ec9.")
    end
end
addEvent("respawnVeh", true)
addEventHandler("respawnVeh", resourceRoot, respawnVeh)
