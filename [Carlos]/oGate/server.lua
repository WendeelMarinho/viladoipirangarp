local connection

addEventHandler("onResourceStart", resourceRoot, function()
    connection = exports.oMysql:getDBConnection()
    loadGates()
end)

addEvent("gate > createGateOnServer", true)
addEventHandler("gate > createGateOnServer", resourceRoot, function(gatePositions, modelID, int, dim) 
    if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(client) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

    local obj = createObject(modelID, gatePositions["close"]["x"], gatePositions["close"]["y"], gatePositions["close"]["z"], gatePositions["close"]["rx"], gatePositions["close"]["ry"], gatePositions["close"]["rz"])

    local closePos = {gatePositions["close"]["x"], gatePositions["close"]["y"], gatePositions["close"]["z"], gatePositions["close"]["rx"], gatePositions["close"]["ry"], gatePositions["close"]["rz"]}
    local openPos = {gatePositions["open"]["x"], gatePositions["open"]["y"], gatePositions["open"]["z"], gatePositions["open"]["rx"], gatePositions["open"]["ry"], gatePositions["open"]["rz"]}

    setElementData(obj, "gate:closePos", closePos)
    setElementData(obj, "gate:openPos", openPos)
    setElementData(obj, "gate:inMove", false)
    setElementData(obj, "gate:state", true) -- true: zárva, false: nyitva
    setElementData(obj, "isGate", true)

    setElementInterior(obj, int)
    setElementDimension(obj, dim)

    local insertResult, _, insertID = dbPoll(dbQuery(connection, "INSERT INTO gates SET modelID=?, closePos=?, openPos=?, interior = ?, dimension = ? ", modelID, toJSON(closePos), toJSON(openPos), int, dim), 250)

    setElementData(obj, "gate:id", insertID)

    exports.oAdmin:sendMessageToAdmins(client, "criou um portão. #db3535(ID: "..insertID..")")
    outputChatBox(core:getServerPrefix("green-dark", "Portão", 2).."Portão criado com sucesso. "..color.."(ID: "..insertID..")", client, 255, 255, 255, true)
end)

function loadGates() 
    query = dbQuery(connection, 'SELECT * FROM gates')
    result = dbPoll(query, 255)

    if result then 
        for k, v in ipairs(result) do 
            local gateID = v["id"]
            local modelID = v["modelID"]
            local closePos = fromJSON(v["closePos"])
            local openPos = fromJSON(v["openPos"])

            local int = v["interior"]
            local dim = v["dimension"]
          
            local obj = createObject(modelID, closePos[1], closePos[2], closePos[3], closePos[4], closePos[5], closePos[6])

            setElementData(obj, "isGate", true)
            setElementData(obj, "gate:id", gateID)
            setElementData(obj, "gate:closePos", closePos)
            setElementData(obj, "gate:openPos", openPos)
            setElementData(obj, "gate:inMove", false)
            setElementData(obj, "gate:state", true)

            setElementInterior(obj, int)
            setElementDimension(obj, dim)
        end
    end
end

function delGate(player, cmd, target)
    if getElementData(player, "user:admin") >= 7 then 
        if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

        if tonumber(target) then 
            local gate = false

            target = tonumber(target)

            local allGate = getAllGates()
            for k, v in pairs(allGate) do 
                if getElementData(v, "gate:id") == target then 
                    gate = v 
                    break
                end
            end

            if gate then 
                dbExec(connection, "DELETE FROM gates WHERE id=?", target)
                destroyElement(gate)

                exports.oAdmin:sendMessageToAdmins(player, "eliminou um portão. #db3535(ID: "..target..")")
                outputChatBox(core:getServerPrefix("green-dark", "Portão", 2).."Portão eliminado com sucesso. "..color.."(ID: "..target..")", player, 255, 255, 255, true)
            else
                outputChatBox(core:getServerPrefix("red-dark", "Portão", 2).."Não existe portão com esse ID! "..color.."("..target..")", player, 255, 255, 255, true)
            end 
        else
            outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [ID do portão]", player, 255, 255, 255, true)
        end
    end
end
addCommandHandler("delgate", delGate) 

local gateTimers = {}
addEvent("gate > setGateState", true)
addEventHandler("gate > setGateState", resourceRoot, function(gate)
    -- Verificar permissão de facção (apenas para portões registados numa HQ)
    local gateID = getElementData(gate, "gate:id")
    if gateID and exports.oFactionHQ and exports.oFactionHQ.isHQGate then
        local ok, isHQ = pcall(function() return exports.oFactionHQ:isHQGate(gateID) end)
        if ok and isHQ then
            local ok2, canOpen = pcall(function() return exports.oFactionHQ:canOpenGate(client, gateID) end)
            if ok2 and not canOpen then
                outputChatBox(core:getServerPrefix("red-dark", "Portão", 2) ..
                    "#ffffffSem permissão de facção para operar este portão.", client, 255, 255, 255, true)
                return
            end
        end
    end

    if not isTimer(gateTimers[gate]) then
        local gate = gate
        gateTimers[gate] = setTimer(function()
            if isTimer(gateTimers[gate]) then
                killTimer(gateTimers[gate])
            end
        end, gateMoveingTime + 1000, 1)
        setElementData(gate, "gate:inMove", true)
        local state =  getElementData(gate, "gate:state")

        local newpos
        local oldpos

        local modelName = "portão"

        local model = getElementModel(gate)

        if model == 3089 then
            modelName = "porta"
        elseif model == 968 then
            modelName = "cancela"
        end

        if state then
            newpos = getElementData(gate, "gate:openPos")
            oldpos = getElementData(gate, "gate:closePos")
            exports.oChat:sendLocalMeAction(client, "abre o " .. modelName .. " próximo.")
        else
            newpos = getElementData(gate, "gate:closePos")
            oldpos = getElementData(gate, "gate:openPos")
            exports.oChat:sendLocalMeAction(client, "fecha o " .. modelName .. " próximo.")
        end

        setElementData(gate, "gate:state", not state)

        if model == 3089 then 
            if state then 
                moveObject(gate, gateMoveingTime/2, newpos[1], newpos[2], newpos[3], 0, 0, 75)
            else
                moveObject(gate, gateMoveingTime/2, newpos[1], newpos[2], newpos[3], 0, 0, -75)
            end
        elseif model == 968 then 
            if state then 
                moveObject(gate, gateMoveingTime, newpos[1], newpos[2], newpos[3], 0, -75, 0)
            else
                moveObject(gate, gateMoveingTime, newpos[1], newpos[2], newpos[3], 0, 75, 0)
            end
        else
            moveObject(gate, gateMoveingTime, newpos[1], newpos[2], newpos[3])
        end

        setTimer(function() setElementData(gate, "gate:inMove", false) end, gateMoveingTime + 1000, 1)
    end
end)