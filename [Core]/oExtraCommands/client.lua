addCommandHandler("id", function(command, ...)
    if not ... then return outputChatBox(exports.oCore:getServerPrefix("red-dark", "Uso:", 3).."/"..command.." [nome/ID]", 255, 255, 255, true) end

    local text = ...
    local count = 0
    local color, r, g, b = exports.oCore:getServerColor()

    for k,v in pairs(getElementsByType("player")) do 
        if getElementData(v,"user:loggedin") then 
            local name = getPlayerName(v)
            local id = getElementData(v,"playerid")
            local string = string.find(name,text) or false

            if string then 
                count = count + 1
                outputChatBox(exports.oCore:getServerPrefix("server", "Busca", 3).."ID de "..utf8.gsub(name,"_"," ")..": "..color..id..".", 255, 255, 255, true)
            elseif id == tonumber(text) then 
                count = count + 1
                outputChatBox(exports.oCore:getServerPrefix("server", "Busca", 3).."Jogador com ID "..id..": "..color..utf8.gsub(name,"_"," ")..".", 255, 255, 255, true)
            end
        end 
    end 

    if count == 0 then 
        outputChatBox(exports.oCore:getServerPrefix("red-dark", "Busca", 3).."Não há jogador com esse nome/ID ou a grafia está errada (atenção a "..color.."maiúsculas#ffffff e "..color.."minúsculas#ffffff)!", 255, 255, 255, true)
    end

    count = 0

end)

addCommandHandler("lvl",function(command,...)
    if not ... then return outputChatBox(exports.oCore:getServerPrefix("red-dark", "Uso:", 3).."/"..command.." [nome/ID]", 255, 255, 255, true) end

    local text = ...
    local count = 0
    local color, r, g, b = exports.oCore:getServerColor()

    for k,v in pairs(getElementsByType("player")) do 
        if getElementData(v,"user:loggedin") then 
            local name = getPlayerName(v)
            local id = getElementData(v,"playerid")
            local string = string.find(name,text) or false
            local playedTime = getElementData(v,"char:playedTime")
            local lvl = tonumber(exports.oLvl:countPlayerLevel(playedTime[1] or 0))
            
            if string then 
                count = count + 1
                outputChatBox(exports.oCore:getServerPrefix("server", "Nível", 3)..utf8.gsub(name,"_"," ")..": nível "..color..lvl..".", 255, 255, 255, true)
            elseif id == tonumber(text) then 
                count = count + 1
                outputChatBox(exports.oCore:getServerPrefix("server", "Nível", 3)..utf8.gsub(name,"_"," ")..": nível "..color..lvl..".", 255, 255, 255, true)
            end
        end 
    end 

    if count == 0 then 
        outputChatBox(exports.oCore:getServerPrefix("red-dark", "Busca", 3).."Não há jogador com esse nome/ID ou a grafia está errada (atenção a "..color.."maiúsculas#ffffff e "..color.."minúsculas#ffffff)!", 255, 255, 255, true)
    end

    count = 0

end)