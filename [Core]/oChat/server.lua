local rpLOGS = {}

addEventHandler("onPlayerChat", root, function(msg, type)
	cancelEvent()
end)

function sendLocalMeAction(thePlayer, msg)
	triggerClientEvent(getNearestPlayers(thePlayer), "outputChatMessage", thePlayer, thePlayer, msg, 6)
end

function sendLocalDoAction(thePlayer, msg)
	triggerClientEvent(getNearestPlayers(thePlayer), "outputChatMessage", thePlayer, thePlayer, msg, 7)
end

addEvent("sendChatMessage", true)
addEventHandler("sendChatMessage", getRootElement(), function(msg, tbl, type)
	--if type == 8 then return end 

	if type == 8 then 
		if (getElementData(client, "user:admin") or 0) < 2 then 
			return 
		end

		if (not exports.oAnticheat:checkPlayerVerifiedAdminStatus(client)) then 
			return 
		end
	end

	if not (type == 9 or type == 10) then
		local muteUntil = tonumber(getElementData(client, "adminChatMuteUntil")) or 0
		if muteUntil > getRealTime().timestamp then
			outputChatBox(exports.oCore:getServerPrefix("red-dark", "Chat", 3) .. "Estás silenciado (admin). Aguarda o tempo expirar.", client, 255, 80, 80, true)
			return
		end

		local playerid = getElementData(client, "char:id")

		if not rpLOGS[playerid] then 
			rpLOGS[playerid] = {}
		end

		local date = getRealTime()
		table.insert(rpLOGS[playerid], 1, {msg, type, string.format("%02d. %02d. %02d:%02d:%02d", date.month + 1, date.monthday, date.hour, date.minute, date.second)})
	end

	if string.find(msg, "kinyitja egy") then 
		if getElementData(client, "user:aduty") then 
			triggerClientEvent(getRootElement(), "sendMessageToAdmins", getRootElement(), client, "kinyitotta egy jármű ajtaját.")
		end
	end

	if (getElementData(client, "chat:lastMessgage") or "") == msg then 

		if not string.find(msg, "meglocsolt egy növényt.") then
			local floodCount = getElementData(client, "chat:floodCount")
			setElementData(client, "chat:floodCount", floodCount + 1)

			if (floodCount + 1) >= 20 then 
				kickPlayer(client, "Flood.")
			end 

			--print(floodCount + 1)
		end
	else
		--print("reset")
		setElementData(client, "chat:floodCount", 0)
		setElementData(client, "chat:lastMessgage", msg)
	end 

	triggerClientEvent(tbl, "outputChatMessage", client, client, msg, type)
end)

addEvent("oChat > staffResfrenteLog", true)
addEventHandler("oChat > staffResfrenteLog", resourceRoot, function(resName, elType, hx, hy, hz)
	if not client or not isElement(client) or getElementType(client) ~= "player" then
		return
	end
	if not ((getElementData(client, "user:admin") or 0) > 1) then
		return
	end
	local n = getPlayerName(client):gsub("_", " ")
	outputDebugString(
		"[oChat/resfrente] " .. n .. " → recurso=" .. tostring(resName) .. " tipo=" .. tostring(elType) .. " hit="
			.. string.format("%.1f,%.1f,%.1f", tonumber(hx) or 0, tonumber(hy) or 0, tonumber(hz) or 0),
		2
	)
end)

addEvent("executeChatCommand", true)
addEventHandler("executeChatCommand", getRootElement(), function(cmd, params)
	--[[ Comandos só-cliente: o cliente já tratou; se ainda chegam aqui, evitar ACL "Access denied" no log. ]]
	cmd = tostring(cmd or ""):lower()
	if cmd == "resfrente" or cmd == "recursoafrente" or cmd == "frontresource" then
		return
	end
	local ok = pcall(function()
		executeCommandHandler(cmd, client, params)
	end)
	if not ok then
		outputDebugString("[oChat] executeChatCommand falhou: " .. tostring(cmd), 2)
	end
end)

function removeHex(msg)
    return msg:gsub("#" .. (6 and string.rep("%x", 6) or "%x+"), "")
end

addEvent("rpLOG > getPlayerRPLogs", true)
addEventHandler("rpLOG > getPlayerRPLogs", resourceRoot, function(playerid)
	if rpLOGS[playerid] then 
		triggerClientEvent(client, "rpLOG > sendPlayerRPLogs", client, rpLOGS[playerid])
	else
		triggerClientEvent(client, "rpLOG > sendPlayerRPLogs", client, {})
	end
end)