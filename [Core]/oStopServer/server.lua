local stopTimer;

local scriptcount = 3 

addCommandHandler("makeserverstop",function(thePlayer,cmd,time)
    if exports.oAdmin:isPlayerDeveloper(thePlayer) then
        if not time then return outputChatBox(exports.oCore:getServerPrefix("red-dark", "Servidor", 3).."Uso: /"..cmd.." [tempo em segundos]",thePlayer,255, 255, 255, true) end 
        if not tostring(time) then return outputChatBox(exports.oCore:getServerPrefix("red-dark", "Servidor", 3).."Tempo inválido!",thePlayer,255, 255, 255, true) end 
        makeStop(time)
    end 
end)

addCommandHandler("stopcountdowntimer",function(thePlayer,cmd)
    if exports.oAdmin:isPlayerDeveloper(thePlayer) then
        whenFakeStop()
        outputChatBox(exports.oCore:getServerPrefix("red-dark", "Servidor", 3).."Reinício cancelado. Bom jogo!",root,255, 255, 255, true)
        triggerClientEvent(root,"animRequest",root,false)
    end 
end)

function makeStop(time)
    triggerClientEvent(root,"stopServerRequest",root)

    setElementData(resourceRoot,"countdown:timeleft",tonumber(time)) -- 600
    setElementData(resourceRoot,"countdownScriptIsActive",true)

    stopTimer = setTimer(function()
        timeleft = getElementData(resourceRoot,"countdown:timeleft")
        setElementData(resourceRoot,"countdown:timeleft",timeleft - 1)

        if timeleft <= 120 then 
            triggerClientEvent(root,"animRequest",root,true)
        end 

        if timeleft == 1 then 
            if isTimer(stopTimer) then killTimer(stopTimer) end 
            kickPlayers()
            exports.oCore:setWhiteListEnable()
            triggerClientEvent(root,"stopRender",root)
            setElementData(resourceRoot,"countdownScriptIsActive",false)
        end 
    end,1000,0)

end 

function whenFakeStop()
    if isTimer(stopTimer) then killTimer(stopTimer) end 
    triggerClientEvent(root,"stopRender",root)
    setElementData(resourceRoot,"countdownScriptIsActive",false)
end 

function kickPlayers()
    for k,v in pairs(getElementsByType("player")) do 
        if not exports.oAdmin:isPlayerDeveloper(v) then
            kickPlayer(v,"O servidor vai reiniciar em breve.");
            --outputChatBox(exports.oCore:getServerPrefix("blue-light-2", "Szerver", 3).."Kickelve vagy!",v, 255, 255, 255, true)
        end 
    end 

    setTimer(function()
        saveScripts()
    end,1000,1)
end 

function saveScripts()
    setTimer(function()
        outputChatBox(exports.oCore:getServerPrefix("blue-light-2", "Servidor", 3).."Whitelist ativada!",root, 255, 255, 255, true)
        outputChatBox(exports.oCore:getServerPrefix("blue-light-2", "Servidor", 3).."Todos os jogadores foram desconectados. Aguardando salvamentos...",root, 255, 255, 255, true)

        --exports.oShop:saveRequest()
        --exports.oVehicle:saveRequest()
        --exports.oPlant:saveRequest()
        --exports.oDashboard:saveRequest()

        setTimer(function()
            outputChatBox(exports.oCore:getServerPrefix("blue-light-2", "Servidor", 3).."Salvamentos concluídos. O servidor pode ser encerrado.",root, 255, 255, 255, true)
        end,3000,1)
    end,5000,1)
    
end 

function syncRender(theKey, oldValue, newValue)
    if (getElementType(source) == "player") then
        if theKey == "user:loggedin" then 
            if newValue == true then 
                if getElementData(resourceRoot,"countdownScriptIsActive") then 
                    triggerClientEvent(source,"stopServerRequest",source)
                end 
            end 
        end 
    end
end
addEventHandler("onElementDataChange", root, syncRender)