--script by theMark
addEvent("playSoundVid", true)
addEventHandler("playSoundVid", root, function(player, url)
    if getElementDimension(player) == 262 and getElementInterior(player) == 3 then
        triggerClientEvent(root, "playVid", root, url)
        print("[DJ]: Transmitindo URL para os clientes: " .. url)
    end
end)