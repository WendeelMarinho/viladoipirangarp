local reasons = {
    ["Unknown"] = "Ismeretlen",
    ["Quit"] = "Kilépett",
    ["Kicked"] = "Kickelve",
    ["Banned"] = "Bannolva",
    ["Bad Connection"] = "Bad Connection",
    ["Timed out"] = "Timed out",
}

addEventHandler("onClientPlayerQuit", root, function(reason)
    local dis = exports.oCore:getDistance(localPlayer, source)
    if dis < 20 then 
        outputChatBox("[Saída]: #ffffff"..getPlayerName(source):gsub("_", " ").." #f03629saiu perto de você #ffffff"..math.floor(dis).."#f03629 yard de distância. #ffffff("..reasons[reason]..")", 240, 54, 41, true)
    end
end)