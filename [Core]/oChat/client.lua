local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992

local oocTable = {}
local showing = true

local spamTimer
local lastcmd

local core = exports.oCore
local interface = exports.oInterface
local nametag = exports.oNametag
local admin = exports.oAdmin
local fonts = exports.oFont

local function getTaggedChatPlayerName(player)
	if not isElement(player) then return "" end
	local name = getPlayerName(player):gsub("_", " ")
	local raw = getElementData(player, "player:activeTag")
	if raw and raw ~= "" and type(raw) == "string" then
		local ok, tag = pcall(fromJSON, raw)
		if ok and type(tag) == "table" and tag.text and tostring(tag.text) ~= "" then
			return "[" .. tostring(tag.text) .. "] " .. name
		end
	end
	return name
end

addEventHandler("onClientResourceStart", root, function(res)
    if getResourceName(res) == "oCore" or getResourceName(res) == "oChat" or getResourceName(res) == "oInterface" or getResourceName(res) == "oNametag" or getResourceName(res) == "oAdmin" then
		core = exports.oCore
		interface = exports.oInterface
		nametag = exports.oNametag
		admin = exports.oAdmin
	end
end)

local seatWindows = {
	[0] = 4,
	[1] = 2,
	[2] = 5,
	[3] = 3
}

local function bindRadioIfNoChat3()
	local oc3 = getResourceFromName("oChat3")
	if oc3 and getResourceState(oc3) == "running" then
		return
	end
	bindKey("y", "down", "chatbox", "Rádió")
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	bindKey("b", "down", "chatbox", "OOC")
	bindKey("t", "down", "chatbox", "Say")
	bindRadioIfNoChat3()
end)

addEvent("outputChatMessage", true)
addEventHandler("outputChatMessage", getRootElement(), function(player, msg, type)
	local distance = core:getDistance(player, localPlayer)

	if getElementData(localPlayer, "recon:startpos") then
		local x1, y1 = getElementPosition(player)
		local x2, y2 = getElementPosition(getElementData(localPlayer, "recon:reconedPlayer"))
		distance = getDistanceBetweenPoints2D(x1, y1, x2, y2)
	end

	if type == 1 then
		local sourceVehicle = getPedOccupiedVehicle(player)
		local currentVehicle = getPedOccupiedVehicle(localPlayer)

		if sourceVehicle then
			if not (getVehicleType(sourceVehicle) == "Automobile") then
				sourceVehicle = false
			end
		end

		if currentVehicle then
			if not (getVehicleType(currentVehicle) == "Automobile") then
				currentVehicle = false
			end
		end

		if sourceVehicle then
			if currentVehicle then
				local windows = {false, false}
				if currentVehicle then
					local windowStates = getElementData(currentVehicle, "veh:windowStates") or {false, false, false, false}

					for k, v in pairs(windowStates) do
						if v then
							windows[1] = true
							break
						end
					end
				end

				if sourceVehicle then
					local windowStates = getElementData(sourceVehicle, "veh:windowStates") or {false, false, false, false}

					for k, v in pairs(windowStates) do
						if v then
							windows[2] = true
							break
						end
					end
				end


				if windows[1] and windows[2] then
					if distance < 5 then
						outputChatBox(getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
						nametag:addBubble(player, msg, 255, 255, 255)
					elseif distance > 5 and distance < 10 then
						outputChatBox("#b9b9b9"..getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
						nametag:addBubble(player, msg, 255, 255, 255)
					elseif distance > 10 and distance < 13 then
						outputChatBox("#868686"..getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
						nametag:addBubble(player, msg, 255, 255, 255)
					elseif distance > 13 and distance <= 20 then
						outputChatBox("#545454"..getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
						nametag:addBubble(player, msg, 255, 255, 255)
					end
				else
					return
				end
			else
				local canSee = false
				if sourceVehicle then
					local windowStates = getElementData(sourceVehicle, "veh:windowStates") or {false, false, false, false}

					for k, v in pairs(windowStates) do
						if v then
							canSee = true
							break
						end
					end
				end

				if getElementData(localPlayer, "recon:startpos") then
					canSee = true
				end

				if canSee then
					if distance < 5 then
						outputChatBox(getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
						nametag:addBubble(player, msg, 255, 255, 255)
					elseif distance > 5 and distance < 10 then
						outputChatBox("#b9b9b9"..getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
						nametag:addBubble(player, msg, 255, 255, 255)
					elseif distance > 10 and distance < 13 then
						outputChatBox("#868686"..getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
						nametag:addBubble(player, msg, 255, 255, 255)
					elseif distance > 13 and distance <= 20 then
						outputChatBox("#545454"..getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
						nametag:addBubble(player, msg, 255, 255, 255)
					end
				end
			end
		else
			if currentVehicle then
				local see = false

				local windowStates = getElementData(currentVehicle, "veh:windowStates") or {false, false, false, false}

				for k, v in pairs(windowStates) do
					if v then
						see = true
						break
					end
				end

				if getElementData(localPlayer, "recon:startpos") then
					canSee = true
				end

				if not see then return end
			end

			local group, anim = unpack(exports.oDashboard:getTalkingAnimation(getElementData(player, "char:talkAnimation")))
			if not (group == "") then
				setPedAnimation(player, group, anim, string.len(msg)*500, false, false, _, false)
			end



			if string.lower(msg) == "xd" then
				if distance < 12 then
					setElementData(player, "animation:emoji", "xd", false)
					setElementData(player, "animation:start", getTickCount(), false)
					outputChatBox("*** "..getTaggedChatPlayerName(player).." não para de rir.", 194, 162, 218)
				end
			elseif string.lower(msg) == "love" then
				setElementData(player, "animation:emoji", "love", false)
				setElementData(player, "animation:start", getTickCount(), false)
      elseif string.lower(msg) == "<3" then
        setElementData(player, "animation:emoji", "love", false)
        setElementData(player, "animation:start", getTickCount(), false)
      elseif string.lower(msg) == ":(" then
        setElementData(player, "animation:emoji", "sad", false)
        setElementData(player, "animation:start", getTickCount(), false)
      elseif string.lower(msg) == "sad" then
        setElementData(player, "animation:emoji", "sad", false)
        setElementData(player, "animation:start", getTickCount(), false)
      elseif string.lower(msg) == "cry" then
        setElementData(player, "animation:emoji", "cry", false)
        setElementData(player, "animation:start", getTickCount(), false)
      elseif string.lower(msg) == ";(" then
        setElementData(player, "animation:emoji", "cry", false)
        setElementData(player, "animation:start", getTickCount(), false)
			else
				if distance < 5 then
					outputChatBox(getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
					nametag:addBubble(player, msg, 255, 255, 255)
				elseif distance > 5 and distance < 10 then
					outputChatBox("#b9b9b9"..getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
					nametag:addBubble(player, msg, 255, 255, 255)
				elseif distance > 10 and distance < 13 then
					outputChatBox("#868686"..getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
					nametag:addBubble(player, msg, 255, 255, 255)
				elseif distance > 13 and distance <= 20 then
					outputChatBox("#545454"..getTaggedChatPlayerName(player).." diz: "..firstUpper(msg), 255, 255, 255, true)
					nametag:addBubble(player, msg, 255, 255, 255)
				end
			end
		end
	elseif type == 2 then
		outputChatBox(getTaggedChatPlayerName(player).." diz (no veículo): "..firstUpper(msg), 255, 255, 255, true)
	elseif type == 3 then
		if distance < 10 then
			outputChatBox(getTaggedChatPlayerName(player).." grita: "..firstUpper(msg), 255, 255, 255, true)
		elseif distance > 10 and distance < 15 then
			outputChatBox("#b9b9b9"..getTaggedChatPlayerName(player).." grita: "..firstUpper(msg), 255, 255, 255, true)
		elseif distance > 15 and distance < 18 then
			outputChatBox("#868686"..getTaggedChatPlayerName(player).." grita: "..firstUpper(msg), 255, 255, 255, true)
		elseif distance > 18 and distance < 20 then
			outputChatBox("#545454"..getTaggedChatPlayerName(player).." grita: "..firstUpper(msg), 255, 255, 255, true)
		end

		--if not getPedOccupiedVehicle(player) then
			--setPedAnimation(player, "on_lookers", "shout_01", 750, false, false, _, false)
		--end
	elseif type == 4 then
		if distance < 3 then
			outputChatBox("#868686"..getTaggedChatPlayerName(player).." sussurra: "..firstUpper(msg), 255, 255, 255, true)
			playSound("files/pszt.wav")
		elseif distance >= 3 and distance < 6 then
			outputChatBox("#747474"..getTaggedChatPlayerName(player).." sussurra: "..firstUpper(msg), 255, 255, 255, true)
			setSoundVolume(playSound("files/pszt.wav"), 0.55)
		elseif distance >= 6 and distance < 9 then
			outputChatBox("#626262"..getTaggedChatPlayerName(player).." sussurra: "..firstUpper(msg), 255, 255, 255, true)
		elseif distance >= 9 and distance <= 10 then
			outputChatBox("#505050"..getTaggedChatPlayerName(player).." sussurra: "..firstUpper(msg), 255, 255, 255, true)
		end
	elseif type == 25 then
		if distance <= 5 then
			if distance < 2 then
				outputChatBox("#919191"..getTaggedChatPlayerName(player).." sussurra (/w): "..firstUpper(msg), 255, 255, 255, true)
				playSound("files/pszt.wav")
			elseif distance < 3.5 then
				outputChatBox("#7d7d7d"..getTaggedChatPlayerName(player).." sussurra (/w): "..firstUpper(msg), 255, 255, 255, true)
				setSoundVolume(playSound("files/pszt.wav"), 0.45)
			else
				outputChatBox("#696969"..getTaggedChatPlayerName(player).." sussurra (/w): "..firstUpper(msg), 255, 255, 255, true)
			end
		end
	elseif type == 5 then
		if #oocTable >= countOOCChatLines() then
			table.remove(oocTable, 1)
		end
		local message

		if getElementData(player,"user:aduty") then
			message  = admin:getAdminColor(getElementData(player, "user:admin")).."["..admin:getAdminPrefix(getElementData(player, "user:admin")).."] "..getElementData(player, "user:adminnick"):gsub("_", " ")..": (( "..msg.." ))"
		else
			message  = "#bdbdbd"..getTaggedChatPlayerName(player).." #ababab(( "..msg.." ))"
		end
		table.insert(oocTable, message)
		outputConsole("[OOC] "..message:gsub("#%x%x%x%x%x%x",""))
	elseif type == 6 then
		outputChatBox("*** "..getTaggedChatPlayerName(player).." "..msg, 194, 162, 218)
		nametag:addBubble(player, msg, 194, 162, 218)
	elseif type == 7 then
		outputChatBox(" *"..firstUpper(msg).." (("..getTaggedChatPlayerName(player).."))", 255, 51, 102)

		nametag:addBubble(player, msg, 255, 51, 102)
	elseif type == 8 then
		local adminname = getElementData(player, "user:adminnick") or ""

		if string.len(adminname) > 2 then
			if (getElementData(player, "user:admin") or 0) > 2 then
				outputChatBox(" ")
				outputChatBox(admin:getAdminColor(getElementData(player, "user:admin")).."["..admin:getAdminPrefix(getElementData(player, "user:admin")).." - Chamado público] "..getElementData(player, "user:adminnick").." ~ #ffffff"..msg, 255, 255, 255, true)
				outputChatBox(" ")

				exports.oInfobox:outputInfoBox(getElementData(player, "user:adminnick").." abriu um chamado público. Veja o chat.", "info")
			end
		end
	elseif type == 9 then
		if getElementData(player, "user:idgAs") then
			outputChatBox(core:getServerPrefix("red-dark", "Chat ajudante", 3)..admin:getAdminColor(getElementData(player, "user:admin")).."[Ajudante temporário] "..getElementData(player, "char:name")..": #ffffff"..msg, 255, 0, 0, true)
		else
			outputChatBox(core:getServerPrefix("red-dark", "Chat ajudante", 3)..admin:getAdminColor(getElementData(player, "user:admin")).."["..admin:getAdminPrefix(getElementData(player, "user:admin")).."] "..getElementData(player, "user:adminnick")..": #ffffff"..msg, 255, 0, 0, true)
		end
	elseif type == 10 then
		outputChatBox(core:getServerPrefix("red-dark", "Admin Chat", 3)..admin:getAdminColor(getElementData(player, "user:admin")).."["..admin:getAdminPrefix(getElementData(player, "user:admin")).."] "..getElementData(player, "user:adminnick")..": #ffffff"..msg, 255, 0, 0, true)
	elseif type == 11 then
		outputChatBox(" ")
		outputChatBox(core:getServerColor().."[Administrador - Chamado público] ~ #ffffff"..msg, 255, 255, 255, true)
		outputChatBox(" ")

		exports.oInfobox:outputInfoBox("Administrador abriu um chamado público. Veja o chat.", "info")
	elseif type == 12 then
		outputChatBox("*** "..getTaggedChatPlayerName(player).." tenta "..msg.." e consegue.", 80, 191, 110)
	elseif type == 13 then
		outputChatBox("*** "..getTaggedChatPlayerName(player).." tenta "..msg.." e não consegue.", 204, 84, 78)
	elseif type == 14 then
		outputChatBox(admin:getAdminColor(getElementData(player, "user:admin")).."["..admin:getAdminPrefix(getElementData(player, "user:admin")).."] "..getTaggedChatPlayerName(player)..": #ffffff(( "..msg.." )) ", 255, 255, 255, true)
	elseif type == 15 then
		if distance < 5 then
			outputChatBox(getTaggedChatPlayerName(player).." diz (no telefone): "..firstUpper(msg), 255, 255, 255, true)
		elseif distance > 5 and distance < 10 then
			outputChatBox("#b9b9b9"..getTaggedChatPlayerName(player).." diz (no telefone): "..firstUpper(msg), 255, 255, 255, true)
		elseif distance > 10 and distance < 13 then
			outputChatBox("#868686"..getTaggedChatPlayerName(player).." diz (no telefone): "..firstUpper(msg), 255, 255, 255, true)
		elseif distance > 13 and distance <= 20 then
			outputChatBox("#545454"..getTaggedChatPlayerName(player).." diz (no telefone): "..firstUpper(msg), 255, 255, 255, true)
		end
	elseif type == 16 then
		if not (player == localPlayer) then
			if distance < 5 then
				outputChatBox(getTaggedChatPlayerName(player).." fala no rádio: "..firstUpper(msg), 255, 255, 255, true)
				nametag:addBubble(player, msg, 255, 255, 255)
			elseif distance > 5 and distance < 10 then
				outputChatBox("#b9b9b9"..getTaggedChatPlayerName(player).." fala no rádio: "..firstUpper(msg), 255, 255, 255, true)
				nametag:addBubble(player, msg, 255, 255, 255)
			elseif distance > 10 and distance < 13 then
				outputChatBox("#868686"..getTaggedChatPlayerName(player).." fala no rádio: "..firstUpper(msg), 255, 255, 255, true)
				nametag:addBubble(player, msg, 255, 255, 255)
			elseif distance > 13 and distance <= 20 then
				outputChatBox("#545454"..getTaggedChatPlayerName(player).." fala no rádio: "..firstUpper(msg), 255, 255, 255, true)
				nametag:addBubble(player, msg, 255, 255, 255)
			end
		end
	elseif type == 17 then
		outputChatBox("(("..getTaggedChatPlayerName(player)..")) Megafone <O: "..firstUpper(msg), 235, 146, 52, true)
	elseif type == 18 then
		outputChatBox(">> "..getTaggedChatPlayerName(player).." "..msg, 131, 98, 162)

		nametag:addBubble(player, msg, 194, 162, 218)
	end
end)

function chatMessage(_, ...)
	if not isSpam(_) then
		if ... then
			local msg = table.concat({...}, " ")
			if msg:sub(0, 1) == "/" then
				local cmd, params = "", ""
				for k, v in ipairs(split(msg:sub(2), " ")) do
					if k == 1 then
						cmd = v
					else
						params = params.." "..v
					end
				end
				params = params:sub(2)
				cmd = (cmd or ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
				--[[ Mesmo fluxo que /getpos: implementação no oCore (executeCommandHandler directo).
				    Aqui só cobre se a mensagem vier pelo handler Say em vez do routing MTA. ]]
				if cmd == "resfrente" or cmd == "recursoafrente" or cmd == "frontresource" then
					local okr, err = pcall(function()
						exports.oCore:runStaffResourceInFrontRaycast()
					end)
					if not okr then
						outputChatBox(
							"#cc4444[oChat]#ffffff /resfrente: "
								.. tostring(err)
								.. " — reinicia oCore ou verifica meta export.",
							255,
							255,
							255,
							true
						)
					end
					return
				end
				if not executeCommandHandler(cmd, params) then
					triggerServerEvent("executeChatCommand", localPlayer, cmd, params)
				end
			else
				if isPedDead(localPlayer) then return end

				local veh = getPedOccupiedVehicle(localPlayer)
				if veh then
					if not (getVehicleType(veh) == "Automobile") then
						veh = false
					end
				end

				if getElementData(localPlayer, "user:aduty") then
					triggerServerEvent("sendChatMessage", localPlayer, removeHex(msg), getNearestPlayers(localPlayer), 14)
				else
					if veh then
						local windowsUp = true
						local windowStates = getElementData(veh, "veh:windowStates") or {false, false, false, false}

						for k, v in pairs(windowStates) do
							if v then
								windowsUp = false
								break
							end
						end

						if windowsUp then
							if getElementData(localPlayer, "recon:reconerPlayer") then
								local players = {}
								players = getVehicleOccupants(veh)
								table.insert(players,  getElementData(localPlayer, "recon:reconerPlayer"))
								triggerServerEvent("sendChatMessage", localPlayer, removeHex(msg), players, 2)
							else
								triggerServerEvent("sendChatMessage", localPlayer, removeHex(msg), getVehicleOccupants(veh), 2)
							end
						else
							triggerServerEvent("sendChatMessage", localPlayer, removeHex(msg), getNearestPlayers(localPlayer), 1)
						end
					else
						triggerServerEvent("sendChatMessage", localPlayer, removeHex(msg), getNearestPlayers(localPlayer), 1)
					end
				end
			end
		end
	end
end
addCommandHandler("say", chatMessage)
addCommandHandler("Say", chatMessage)

local lastRadioInteraction = 0
function radioChatMessage(_, ...)
	if not isSpam(_) then
		if ... then
			local msg = table.concat({...}, " ")
			if not (msg:sub(0, 1) == "/") then
				if isPedDead(localPlayer) then return end
        if getElementData(localPlayer,"cuff:cuffed") then return outputChatBox(core:getServerPrefix("red-dark", "Rádio", 2).."Algemado você não pode usar o rádio!", 255, 255, 255, true) end

				if exports.oInventory:hasItem(154) then
					if tonumber(getElementData(localPlayer, "char:radioStation")) > 0 then
						local msg = table.concat({...}, " ")
						if msg then
							if string.len(msg) > 0 then
								if lastRadioInteraction + 500 < getTickCount() then
									triggerServerEvent("sendChatMessage", localPlayer, removeHex(msg), getNearestPlayers(localPlayer), 16)
									triggerServerEvent("walkiTalkie > sendChatMessage", root, msg, tonumber(getElementData(localPlayer, "char:radioStation")))
									lastRadioInteraction = getTickCount()
								end
							else
								outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [mensagem]", 255, 255, 255, true)
							end
						else
							outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [mensagem]", 255, 255, 255, true)
						end
					else
						outputChatBox(core:getServerPrefix("red-dark", "Rádio", 2).."Nenhuma frequência do rádio definida (/tuneradio)!", 255, 255, 255, true)
					end
				else
					outputChatBox(core:getServerPrefix("red-dark", "Rádio", 2).."Você não tem um rádio!", 255, 255, 255, true)
				end

			end
		end
	end
end
addCommandHandler("Rádió", radioChatMessage)
addCommandHandler("rádió", radioChatMessage)
addCommandHandler("radio", radioChatMessage)
addCommandHandler("r", radioChatMessage)

addEventHandler("onClientRender", getRootElement(), function()
	if getElementData(localPlayer,"user:loggedin") then
		if interface:getInterfaceElementData(13, "showing") then
			if showing then
				local posX, posY = interface:getInterfaceElementData(13, "posX"), interface:getInterfaceElementData(13, "posY")
				local w, h = interface:getInterfaceElementData(13, "width"), interface:getInterfaceElementData(13, "height")

				dxDrawText("(( Chat OOC (ocultar: /togooc) ))", sx*posX + 1, sy*posY + 1, 0, 0, tocolor(0, 0, 0), 1, "default-bold")
				dxDrawText("(( Chat OOC (ocultar: /togooc) ))", sx*posX, sy*posY, 0, 0, tocolor(255, 255, 255), 1, "default-bold")
				for i, v in ipairs(oocTable) do
					if i > countOOCChatLines() then
						table.remove(oocTable, i)
					end
					--v:gsub("#%x%x%x%x%x%x","")
					--dxDrawText(v:gsub("#%x%x%x%x%x%x",""), sx*posX+1, sy*posY + 6 + dxGetFontHeight()*i, sx*posX+1+sx*w, 0, tocolor(0, 0, 0), 1, "default-bold", _, _, true)
					dxDrawText(v:gsub("#%x%x%x%x%x%x",""),  sx*posX+1, sy*posY + 6 + dxGetFontHeight()*i, sx*posX+sx*w+1, 0, tocolor(0, 0, 0), 1, "default-bold",_,_,true,false,false,true)
					dxDrawText(v,  sx*posX, sy*posY + 5 + dxGetFontHeight()*i, sx*posX+sx*w, 0, tocolor(255, 255, 255), 1, "default-bold",_,_, true, true, false, true)
				end
			end
		end
    end
end)

function countOOCChatLines()
	local height = interface:getInterfaceElementData(13, "height")*dxGetFontHeight()*3
	height = math.ceil(height)

	--dxGetFontHeight()
	--print(height, dxGetFontHeight())
	return height
end

function clearChat()
	for i = 1, getChatboxLayout().chat_lines do outputChatBox("") end
	--outputChatBox(core:getServerPrefix("server", "clear", 1).."IC Chat sikeresen kiűrítve!", 255, 255, 255, true)
end
addCommandHandler("cc", clearChat)
addCommandHandler("clearchat", clearChat)

function clearOOC()
	oocTable = {}
	outputChatBox(core:getServerPrefix("server", "clear", 1).."Chat OOC limpo!", 255, 255, 255, true)
end
addCommandHandler("clearooc", clearOOC)
addCommandHandler("cooc", clearOOC)
addCommandHandler("co", clearOOC)

addCommandHandler("togooc", function()
	showing = not showing
end)

function isSpam(cmd)
	if not getElementData(localPlayer, "user:loggedin") then
		return true
	elseif lastcmd == "Say" then
		lastcmd = nil
		return false
	elseif isTimer(spamTimer) then
		return true
	else
		lastcmd = cmd
		spamTimer = setTimer(function() end, 1000, 1)
		return false
	end
end

function sendLocalMeAction(msg)
	triggerServerEvent("sendChatMessage", localPlayer, removeHex(msg), getNearestPlayers(localPlayer), 6)
end

function sendLocalDoAction(msg)
	triggerServerEvent("sendChatMessage", localPlayer, removeHex(msg), getNearestPlayers(localPlayer), 7)
end

function getAdminPlayers(level)
	local playerCache = {}

	for k, v in ipairs(getElementsByType("player")) do
		if (tonumber(getElementData(v, "user:admin")) or 0) >= level then
			table.insert(playerCache, v)
		end
	end
	return playerCache
end

function getASORIDG(level)
	local playerCache = {}
	for k, v in ipairs(getElementsByType("player")) do
		if (tonumber(getElementData(v, "user:admin")) or 0) >= level or getElementData(v, "user:idgAs") then
			table.insert(playerCache, v)
		end
	end
	return playerCache
end

function firstUpper(msg)
    return msg:gsub("^%l", string.upper)
end

function removeHex(msg)
    return msg:gsub("#" .. (6 and string.rep("%x", 6) or "%x+"), "")
end

addCommandHandler("showchat", function()
	showChat(not isChatVisible())
	showing = isChatVisible()
end)

-- rp log
local rpLOG = {}
local rplogShowing = false

local scrollMenu = 0

local color, r, g, b = core:getServerColor()

function renderRPLOG()
	dxDrawRectangle(sx*0.2, sy*0.25, sx*0.6, sy*0.402, tocolor(30, 30, 30, 150))
    dxDrawRectangle(sx*0.2 + 2/myX*sx, sy*0.25 + 2/myY*sy, sx*0.6 - 4/myX*sx, sy*0.402 - 4/myY*sy, tocolor(35, 35, 35, 255))

	if #rpLOG == 0 then
		dxDrawText("Sem dados para exibir! :(", sx*0.4, sy*0.25, sx*0.6, sy*0.65, tocolor(255, 59, 59, 200), 1/myX*sx, fonts:getFont("condensed", 15), "center", "center")
	else
		local lineHeight = math.min(18 / #rpLOG, 1)

		dxDrawRectangle(sx*0.795, sy*0.255, sx*0.002, sy*0.4 - 8/myY*sy, tocolor(30, 30, 30, 255))
		dxDrawRectangle(sx*0.795, sy*0.255 + ((sy*0.4 - 8/myY*sy) * (lineHeight * scrollMenu / 18)), sx*0.002, (sy*0.4 - 8/myY*sy) * lineHeight, tocolor(r, g, b, 255))

		local searchText = core:getEditboxText("rplog-search")
		local loopTable = {}

		if string.len(searchText) == 0 then
			loopTable = rpLOG
		else
			for k, v in ipairs(rpLOG) do
				local prefix = ""

				if v[2] == 1 or v[2] == 2 then
					prefix = prefix .. "diz: "
				elseif v[2] == 3 then
					prefix = prefix .. "grita: "
				elseif v[2] == 4 then
					prefix = prefix .. "sussurra: "
				elseif v[2] == 5 then
					prefix = "OOC: "
				elseif v[2] == 6 then
					prefix = "*** "
				elseif v[2] == 7 then
					prefix = "* "
				elseif v[2] == 8 or v[2] == 11 then
					prefix = "CHAMADO ADMIN: "
				elseif v[2] == 12 then
					prefix = "CONSEGUE: "
				elseif v[2] == 13 then
					prefix = "NÃO CONSEGUE: "
				elseif v[2] == 16 then
					prefix = prefix .. "fala no rádio: "
				elseif v[2] == 17 then
					prefix = "Megafone <O: "
				elseif v[2] == 18 then
					prefix = "** "
				end

				local text = "["..v[3].."]: "..prefix..v[1]

				if string.find(string.lower(text), string.lower(searchText)) then
					table.insert(loopTable, 1, v)
				end
			end
		end


		local startY = sy*0.255
		for k, v in ipairs(loopTable) do
			if scrollMenu < k and k <= 18 + scrollMenu then
				local lineAlpha = 255

				if (k % 2) == 0 then
					lineAlpha = 155
				end

				dxDrawRectangle(sx*0.2 + 4/myX*sx, startY, sx*0.6 - 15/myX*sx, sy*0.02, tocolor(30, 30, 30, lineAlpha))

				local prefix = "#ffffff"

				if v[2] == 1 or v[2] == 2 then
					prefix = prefix .. "diz: "
				elseif v[2] == 3 then
					prefix = prefix .. "grita: "
				elseif v[2] == 4 then
					prefix = prefix .. "sussurra: "
				elseif v[2] == 5 then
					prefix = "#fc7358OOC: "
				elseif v[2] == 6 then
					prefix = "#c2a2da*** "
				elseif v[2] == 7 then
					prefix = "#ff3366* "
				elseif v[2] == 8 or v[2] == 11 then
					prefix = "#ffaa33CHAMADO ADMIN: "
				elseif v[2] == 12 then
					prefix = "#50bf6eCONSEGUE: "
				elseif v[2] == 13 then
					prefix = "#cc544eNÃO CONSEGUE: "
				elseif v[2] == 16 then
					prefix = prefix .. "fala no rádio: "
				elseif v[2] == 17 then
					prefix = "#eb9234Megafone <O: "
				elseif v[2] == 18 then
					prefix = "#8362a2** "
				end
				dxDrawText("#666666["..v[3].."]: "..prefix..v[1], sx*0.203 + 4/myX*sx, startY, sx*0.2 + 4/myX*sx+sx*0.6 - 15/myX*sx, startY+sy*0.02, tocolor(255, 255, 255, 255), 1/myX*sx, fonts:getFont("condensed", 10), "left", "center", false, false, false, true)

				startY = startY + sy*0.022
			end
		end
	end
end

addCommandHandler("getrplog", function(cmd, id)
	if (getElementData(localPlayer, "user:admin") or 0) >= 2 then
		if not rplogShowing then
			if tonumber(id) then
				local player = core:getPlayerFromPartialName(localPlayer, id, false, 2)

				if player then
					triggerServerEvent("rpLOG > getPlayerRPLogs", resourceRoot, getElementData(player, "char:id"))
				end
			else
				outputChatBox(core:getServerPrefix("red-dark", "RP-LOG", 2).."/"..cmd.." [ID do personagem]", 255, 255, 255, true)
			end
		else
			rplogShowing = false
			removeEventHandler("onClientRender", root, renderRPLOG)
			core:deleteEditbox("rplog-search")
		end
	end
end)

bindKey("mouse_wheel_down", "down", function()
	if rpLOG[scrollMenu + 19] then
		scrollMenu = scrollMenu + 1
	end
end)

bindKey("mouse_wheel_up", "down", function()
	if scrollMenu > 0 then
		scrollMenu = scrollMenu - 1
	end
end)

addEvent("rpLOG > sendPlayerRPLogs", true)
addEventHandler("rpLOG > sendPlayerRPLogs", root, function(table)
	rpLOG = table
	scrollMenu = 0
	rplogShowing = true
	core:deleteEditbox("rplog-search")
	core:createEditbox(sx*0.2, sy*0.66, sx*0.6, sy*0.03, "rplog-search", "Buscar...", "text")
	addEventHandler("onClientRender", root, renderRPLOG)
end)
