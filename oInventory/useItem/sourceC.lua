local usespam = nil;
local lastLuckyGame = 0
local lastCigaret = 0
local lastFuelCan = 0
local pdaInUse = false
local flexInUse = false
local flexObject = false

local fireworkSpam = false

local monthDays = {
	[1] = 31, -- jan
	[2] = 28, -- feb
	[3] = 31, -- márc
	[4] = 30, -- ápr
	[5] = 31, -- máj
	[6] = 30, -- jún
	[7] = 31, -- júl
	[8] = 31, -- aug
	[9] = 30, -- szept
	[10] = 31, -- okt
	[11] = 30, -- nov
	[12] = 31, -- dec
}

local forgalmiCol = createColSphere(1476.9519042969,-1778.3323974609,25.603584289551, 10)

function setPhoneActive(slot, value)
	cache.inventory.active.phone = value
end

func.useItem = function(slot,data)
	if cache.inventory.itemMove then
		cache.inventory.itemMove = false
		cache.inventory.movedSlot = -1
	end

	if getElementData(localPlayer, "playerInDead") then return end
	if data.item == 1 then
		if getElementData(localPlayer, "adminJail.IsAdminJail") then return end
		if getElementData(localPlayer, "pd:jail") then return end

		exports.oPhone:setPhoneVisible(data.value, data.slot)
	elseif availableItems[data.item].eat then
		if not isTimer(usespam) then
			if data.count == 1 then
				if getElementData(localPlayer,"char:hunger") < 100 then
					chat:sendLocalMeAction("come um(a) "..getItemName(data.item)..".")
					triggerServerEvent("eatingAnimation",localPlayer,localPlayer,"food",data.item)
					--func.setItemCount(slot,data.count-1)
					func.setItemState(slot, data.state - availableItems[data.item].eatPercent)
					setElementData(localPlayer,"char:hunger", math.min(getElementData(localPlayer,"char:hunger")+math.random(6,10), 100))
					if getElementData(localPlayer,"char:hunger") >= 100 then
						setElementData(localPlayer,"char:hunger",100)
					end

					usespam = setTimer(function()
						killTimer(usespam)
					end,4200, 1)
				else
					outputChatBox(core:getServerPrefix("red-dark", "Inventory", 3).."Você não está com fome.",246,137,52,true)
				end
			else
				outputChatBox(core:getServerPrefix("red-dark", "Inventory", 3).."Só pode comer se houver apenas um no slot.",246,137,52,true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Inventory", 3).."Aguarde alguns segundos.",246,137,52,true)
		end
	elseif availableItems[data.item].drink then
		if not isTimer(usespam) then
			if data.count == 1 then
				if getElementData(localPlayer,"char:thirst") < 100 then
					chat:sendLocalMeAction("bebe um(a) "..getItemName(data.item)..".")
					triggerServerEvent("eatingAnimation",localPlayer,localPlayer,"drink",data.item)

					func.setItemState(slot, data.state - availableItems[data.item].drinkPercent)

					setElementData(localPlayer,"char:thirst", math.min(getElementData(localPlayer,"char:thirst")+math.random(4,8), 100))

					usespam = setTimer(function()
						killTimer(usespam)
					end,1700,1)
				else
					outputChatBox(core:getServerPrefix("red-dark", "Inventory", 3).."Você não está com sede.",246,137,52,true)
				end
			else
				outputChatBox(core:getServerPrefix("red-dark", "Inventory", 3).."Só pode beber se houver apenas um no slot.",246,137,52,true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Inventory", 3).."Aguarde alguns segundos.",246,137,52,true)
		end
	elseif availableItems[data.item].skill then
		triggerServerEvent("setPlayerStat",localPlayer,localPlayer,availableItems[data.item].skill)
		exports["chat"]:takeMessage("me","leu um livro.")
		outputChatBox(core:getServerPrefix("green-dark", "Inventory", 3).."Você aprendeu com sucesso: #f68934"..getItemName(data.item).."#ffffff.",220,20,60,true)
		func.setItemCount(slot,data.count-1)
	elseif data.item == 44 then -- pénzkazetta
		if exports.oBank:startMoneyCaseOpen() then
			func.setItemCount(slot,data.count-1)

			if not hasItem(44) then
				setElementData(localPlayer, "atmRob:hasMoneyCaset", false)
			end
		end
	elseif data.item == 55 then
		if hasItem(72) then
			if exports.oDrugs:useDrug("joint") then
				func.setItemCount(slot,data.count-1)

				chat:sendLocalMeAction("fumou um cigarro de maconha.")
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Inventory", 2).."Você não tem um isqueiro.", 61, 122, 188, true)
		end
	elseif data.item == 56 then
		if exports.oDrugs:useDrug("heroin") then
			func.setItemCount(slot,data.count-1)

			chat:sendLocalMeAction("se aplica uma injeção com uma seringa de heroína.")
		end
	elseif data.item == 57 then
		if exports.oDrugs:useDrug("cocaine") then
			func.setItemCount(slot,data.count-1)

			chat:sendLocalMeAction("cheirou um pouco de cocaína.")
		end
	elseif data.item == 106 then
		if exports.oDrugs:useDrug("speed") then
			func.setItemCount(slot,data.count-1)

			chat:sendLocalMeAction("engoliu um comprimido de LSD.")
		end
	elseif data.item == 65 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local state = exports.oLicenses:toggleCard(65, data.value, data.dbid)
			if not state then
				cache.inventory.active.identity = -1
				chat:sendLocalMeAction("guarda um documento de identidade.")
				setElementData(localPlayer, "active:itemValue", false)
			else
				cache.inventory.active.identity = slot
				chat:sendLocalMeAction("pega um documento de identidade.")
				setElementData(localPlayer, "active:itemValue", data.value)
			end
		end
	elseif data.item == 66 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local state = exports.oLicenses:toggleCard(66, data.value, data.dbid)
			if not state then
				cache.inventory.active.identity = -1
				chat:sendLocalMeAction("guarda uma carteira de motorista.")
				setElementData(localPlayer, "active:itemValue", false)
			else
				cache.inventory.active.identity = slot
				chat:sendLocalMeAction("pega uma carteira de motorista.")
				setElementData(localPlayer, "active:itemValue", data.value)
			end
		end
	elseif data.item == 68 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local state = exports.oLicenses:toggleCard(68, data.value, data.dbid)
			if not state then
				cache.inventory.active.identity = -1
				chat:sendLocalMeAction("guarda uma licença de arma.")
				setElementData(localPlayer, "active:itemValue", false)
			else
				cache.inventory.active.identity = slot
				chat:sendLocalMeAction("pega uma licença de arma.")
				setElementData(localPlayer, "active:itemValue", data.value)
			end
		end
	elseif data.item == 69 then
		if not isTimer(badge_timer) then
			if getElementData(localPlayer, "badgeInUse") then
				setElementData(localPlayer, "badgeInUse", false)
				setElementData(localPlayer, "badgeText", "nan")
				chat:sendLocalMeAction("tira um distintivo.")
				cache.inventory.active.badge = -1
			else
				setElementData(localPlayer, "badgeInUse", true)
				setElementData(localPlayer, "badgeText", data.value)
				chat:sendLocalMeAction("coloca um distintivo.")
				cache.inventory.active.badge = slot
			end

			badge_timer = setTimer(function()
				if isTimer(badge_timer) then
					killTimer(badge_timer)
				end
			end, 500, 1)
		end
	elseif data.item == 71 then
		if not isTimer(usespam) then
			func.setItemCount(slot,data.count-1)

			chat:sendLocalMeAction("fuma um cigarro.")

			if not getPedOccupiedVehicle(localPlayer) then
				triggerServerEvent("eatingAnimation",localPlayer,localPlayer,"smoke",data.item)
			end

			usespam = setTimer(function()
				killTimer(usespam)
			end, 6000, 1)
		end
	elseif data.item == 73 then
		if not elementInProtectedPlace(localPlayer) then
			if not getPedOccupiedVehicle(localPlayer) then
				local playerPos = Vector3(getElementPosition(localPlayer))

				local placeEnabled = true
				for k, v in ipairs(getElementsByType("object")) do
					if core:getDistance(v, localPlayer) < 10 then
						if getElementData(v, "isHifi") then
							placeEnabled = false
							break
						end
					end
				end

				if placeEnabled then
					func.setItemCount(slot,data.count-1)
					chat:sendLocalMeAction("coloca um hifi.")
					triggerServerEvent("createHifi", resourceRoot)
				else
					outputChatBox(core:getServerPrefix("red-dark", "Hifi", 2).."Já há um hifi colocado perto de você!", 255, 255, 255, true)
				end
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Hifi", 2).."Você não pode colocar o hifi em um local protegido!", 255, 255, 255, true)
		end
	elseif data.item == 74 then
		if (cache.inventory.active.weapon == slot) or (cache.inventory.active.weapon  == -1) then
			if not isTimer(weapon_timer) then
				weapon_timer = setTimer(function()
					if isTimer(weapon_timer) then
						killTimer(weapon_timer)
					end
				end, 500, 1)

				if getElementData(localPlayer, "hasFishingRod") then
					chat:sendLocalMeAction("guarda uma vara de pesca.")
					cache.inventory.active.weapon  = -1
				else
					if not getPedOccupiedVehicle(localPlayer) then
						chat:sendLocalMeAction("pega uma vara de pesca.")
						cache.inventory.active.weapon  = slot
					else
						return
					end
				end

				triggerServerEvent("giveFishingRod", resourceRoot)
			end
		end
	elseif data.item == 76 then
		if not isTimer(gyogyszer_timer) then
			if getElementHealth(localPlayer) < 95 then
				setElementHealth(localPlayer, getElementHealth(localPlayer) + 35)
				setElementData(localPlayer, "char:health", getElementHealth(localPlayer))
				chat:sendLocalMeAction("tomou um remédio.")

				func.setItemCount(slot,data.count-1)

				gyogyszer_timer = setTimer(function()
					if isTimer(gyogyszer_timer) then
						killTimer(gyogyszer_timer)
					end
				end, core:minToMilisec(5), 1)
			else
				outputChatBox(core:getServerPrefix("red-dark", "Remédio", 3).."Você não precisa de remédio.", 255, 255, 255, true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Remédio", 3).."Você só pode usar remédio a cada "..core:getServerColor().."5 #ffffffminutos.", 255, 255, 255, true)
		end
	elseif data.item == 79 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local state = exports.oLicenses:toggleCard(79, data.value, data.dbid)
			if not state then
				chat:sendLocalMeAction("guarda uma licença de caça.")
				setElementData(localPlayer, "active:itemValue", false)
				cache.inventory.active.identity = -1
			else
				chat:sendLocalMeAction("pega uma licença de caça.")
				setElementData(localPlayer, "active:itemValue", data.value)
				cache.inventory.active.identity = slot
			end
		end
	elseif data.item == 146 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local state = exports.oLicenses:toggleCard(146, data.value, data.dbid)
			if not state then
				chat:sendLocalMeAction("guarda uma licença de pesca.")
				setElementData(localPlayer, "active:itemValue", false)
				cache.inventory.active.identity = -1
			else
				chat:sendLocalMeAction("pega uma licença de pesca.")
				setElementData(localPlayer, "active:itemValue", data.value)
				cache.inventory.active.identity = slot
			end
		end
	elseif data.item == 82 then
		if not getPedOccupiedVehicle(localPlayer) then return end

		if (((getElementData(localPlayer, "lastFixCardUse") or 0) + 120000) < getTickCount() )then
			if getPedOccupiedVehicleSeat(localPlayer) == 0 then
				func.setItemCount(slot,data.count-1)

				triggerServerEvent("inv > unflipVehicle", resourceRoot, getPedOccupiedVehicle(localPlayer))

				setElementData(localPlayer, "lastFixCardUse", getTickCount())
				chat:sendLocalMeAction("usou um cartão unflip.")
			else
				outputChatBox(core:getServerPrefix("red-dark", "Cartão Unflip", 2).."Esta operação só funciona no assento do motorista.", 255, 255, 255, true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Cartão Premium", 2).."Ainda não se passaram "..color.."2 #ffffffminutos desde o último uso.", 255, 255, 255, true)
		end
	elseif data.item == 83 then
		if isTimer(policeLight_timer) then return end
		if not getPedOccupiedVehicle(localPlayer) then return end
		if getPedOccupiedVehicleSeat(localPlayer) >= 2 then return end
		if data.state == 2 then
			if exports.oFactionScripts:removePoliceLightFromOccupiedVehicle() then
				chat:sendLocalMeAction("removeu do teto do veículo um giroflex policial.")
				func.setItemState(slot, 1)
				policeLight_timer = setTimer(function()
					if isTimer(policeLight_timer) then killTimer(policeLight_timer) end
				end, 1000, 1)
			end
		else
			if exports.oFactionScripts:applyPoliceLightToOccupiedVehicle() then
				chat:sendLocalMeAction("colocou no teto do veículo um giroflex policial.")
				func.setItemState(slot, 2)
				policeLight_timer = setTimer(function()
					if isTimer(policeLight_timer) then killTimer(policeLight_timer) end
				end, 1000, 1)
			end
		end
	elseif data.item == 89 then
		if getElementData(localPlayer, "playerInDead") then
			outputChatBox(core:getServerPrefix("red-dark", "Cartão de Cura", 2).."Este cartão não pode ser usado durante a morte.", 255, 255, 255, true)
			return
		end

		if (((getElementData(localPlayer, "lastFixCardUse") or 0) + 120000) < getTickCount() )then
			func.setItemCount(slot,data.count-1)

			triggerServerEvent("inv > userInstantHealCard", resourceRoot)

			setElementData(localPlayer, "lastFixCardUse", getTickCount())
			chat:sendLocalMeAction("usou um cartão de cura instantânea.")
		else
			outputChatBox(core:getServerPrefix("red-dark", "Cartão Premium", 2).."Ainda não se passaram "..color.."2 #ffffffminutos desde o último uso.", 255, 255, 255, true)
		end
	elseif data.item == 90 then
		if not getPedOccupiedVehicle(localPlayer) then return end

		if (((getElementData(localPlayer, "lastFixCardUse") or 0) + 120000) < getTickCount() )then
			if getPedOccupiedVehicleSeat(localPlayer) == 0 then
				func.setItemCount(slot,data.count-1)

				triggerServerEvent("inv > fixVehicle", resourceRoot, getPedOccupiedVehicle(localPlayer))

				setElementData(localPlayer, "lastFixCardUse", getTickCount())
				chat:sendLocalMeAction("usou uma caixa de ferramentas premium.")
			else
				outputChatBox(core:getServerPrefix("red-dark", "Caixa de Ferramentas", 2).."Esta operação só funciona no assento do motorista.", 255, 255, 255, true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Cartão Premium", 2).."Ainda não se passaram "..color.."2 #ffffffminutos desde o último uso.", 255, 255, 255, true)
		end
	elseif data.item == 200 then
		if not isTimer(usespam) then
			usespam = setTimer(function()
				killTimer(usespam)
			end,1500,1)

			func.setItemCount(slot,data.count-1)

			--
			--outputChatBox(randomDrop[randomNumber])
			local percent = math.random(1,100);

			local a = 100 - percent;

			local b = math.random(1,#randomTable);
			local gived = false;

			for k,v in pairs(giftDrop) do
				if k == a and k ~= 75 then
					local droppedCache = math.random(1,#giftDrop[k]);
					for i = 1, #giftDrop[k] do
						if i == droppedCache then
							if not gived then
								local count = 1;
								if giftDrop[k][i].maxcount then
									count = math.random(1,giftDrop[k][i].maxcount);
								end
								triggerServerEvent("giveItem", resourceRoot, localPlayer, giftDrop[k][i].id,1,count,0)
								chat:sendLocalMeAction("abriu um presente.")
								outputChatBox(core:getServerPrefix("green-dark", "Presente", 3).."Você abriu com sucesso "..color..count.."#ffffff unidade(s) de "..color..getItemName(giftDrop[k][i].id).."#ffffff.", 255, 255, 255, true)
								gived = true;
							end
						end
					end
				end
			end

			for k,v in pairs(giftDrop) do
				if k ~= a and k == 75 then
					if randomTable[b] == k and k ~= a then
						local droppedCache = math.random(1,#giftDrop[k]);
						for i = 1, #giftDrop[k] do
							if i == droppedCache then
								if not gived then
									local count = 1;
									if giftDrop[k][i].maxcount then
										count = math.random(1,giftDrop[k][i].maxcount);
									end
									triggerServerEvent("giveItem", resourceRoot, localPlayer, giftDrop[k][i].id,1,count,0)
									chat:sendLocalMeAction("abriu um presente.")
									outputChatBox(core:getServerPrefix("green-dark", "Presente", 3).."Você abriu com sucesso "..color..count.."#ffffff unidade(s) de "..color..getItemName(giftDrop[k][i].id).."#ffffff.", 255, 255, 255, true)
									gived = true;
								end
							end
						end
					end
				end
			end



			--[[for k,v in pairs(giftDrop) do
				if k == a and k ~= 75 then
					local droppedCache = math.random(1,#giftDrop[k]);
					for i = 1, #giftDrop[k] do
						if i == droppedCache then
							local count = 1;
							if giftDrop[k][i].maxcount then
								count = math.random(1,giftDrop[k][i].maxcount);
							end
							triggerServerEvent("giveItem", resourceRoot, localPlayer, giftDrop[k][i].id,1,count,0)
							outputChatBox("asd: "..k.." - "..a)
						end
					end
				else
					if randomTable[b] == k and k ~= a then
						local droppedCache = math.random(1,#giftDrop[k]);
						for i = 1, #giftDrop[k] do
							if i == droppedCache then
								local count = 1;
								if giftDrop[k][i].maxcount then
									count = math.random(1,giftDrop[k][i].maxcount);
								end
								triggerServerEvent("giveItem", resourceRoot, localPlayer, giftDrop[k][i].id,1,count,0)
								outputChatBox("asd2: "..k.." - "..a)
							end
						end
					end
				end
			end]]

		end
	elseif data.item == 205 then
		if not isTimer(usespam) then
			usespam = setTimer(function()
				killTimer(usespam)
			end,1500,1)

			func.setItemCount(slot,data.count-1)

			local percent = math.random(1,100);

			local a = 100 - percent;

			local b = math.random(1,#randomTable);
			local gived = false;

			for k,v in pairs(giftDrop) do
				if k == a and k ~= 75 then
					local droppedCache = math.random(1,#giftDrop[k]);
					for i = 1, #giftDrop[k] do
						if i == droppedCache then
							if not gived then
								local count = 1;
								if giftDrop[k][i].maxcount then
									count = math.random(1,giftDrop[k][i].maxcount);
								end
								triggerServerEvent("giveItem", resourceRoot, localPlayer, giftDrop[k][i].id,1,count,0)
								chat:sendLocalMeAction("abriu um ovo de Páscoa.")
								outputChatBox(core:getServerPrefix("green-dark", "Easter", 2).."Você abriu com sucesso "..color..count.."#ffffff unidade(s) de "..color..getItemName(giftDrop[k][i].id).."#ffffff.", 255, 255, 255, true)
								gived = true;
							end
						end
					end
				end
			end

			for k,v in pairs(giftDrop) do
				if k ~= a and k == 75 then
					if randomTable[b] == k and k ~= a then
						local droppedCache = math.random(1,#giftDrop[k]);
						for i = 1, #giftDrop[k] do
							if i == droppedCache then
								if not gived then
									local count = 1;
									if giftDrop[k][i].maxcount then
										count = math.random(1,giftDrop[k][i].maxcount);
									end
									triggerServerEvent("giveItem", resourceRoot, localPlayer, giftDrop[k][i].id,1,count,0)
									chat:sendLocalMeAction("abriu um ovo de Páscoa.")
									outputChatBox(core:getServerPrefix("green-dark", "Easter", 2).."Você abriu com sucesso "..color..count.."#ffffff unidade(s) de "..color..getItemName(giftDrop[k][i].id).."#ffffff.", 255, 255, 255, true)
									gived = true;
								end
							end
						end
					end
				end
			end
		end
	elseif data.item == 91 then
		if not getPedOccupiedVehicle(localPlayer) then return end

		if (((getElementData(localPlayer, "lastFixCardUse") or 0) + 120000) < getTickCount() )then
			if getPedOccupiedVehicleSeat(localPlayer) == 0 then
				func.setItemCount(slot,data.count-1)

				triggerServerEvent("inv > fuelVehicle", resourceRoot, getPedOccupiedVehicle(localPlayer))

				setElementData(localPlayer, "lastFixCardUse", getTickCount())
				chat:sendLocalMeAction("usou um cartão de abastecimento instantâneo.")
			else
				outputChatBox(core:getServerPrefix("red-dark", "Cartão Abastecimento Instantâneo", 2).."Esta operação só funciona no assento do motorista.", 255, 255, 255, true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Cartão Premium", 2).."Ainda não se passaram "..color.."2 #ffffffminutos desde o último uso.", 255, 255, 255, true)
		end
	elseif data.item >= 112 and data.item <= 114 then
		if data.count == 1 then 
			if lastCigaret + 1000 > getTickCount() then return end

			lastCigaret = getTickCount()

			func.setItemState(slot, data.state - 10)

			triggerServerEvent("giveItem", resourceRoot, localPlayer, 71, 1, 1, 0)

			chat:sendLocalMeAction("tirou um cigarro de uma caixa de "..getItemName(data.item)..".")
		else
			outputChatBox(core:getServerPrefix("red-dark", "Inventory", 3).."Só pode usar se houver apenas um no slot.",246,137,52,true)
		end
	elseif data.item == 115 then
		if not getPedOccupiedVehicle(localPlayer) then return end

		if getPedOccupiedVehicleSeat(localPlayer) == 0 then
			if getElementData(getPedOccupiedVehicle(localPlayer), "veh:protected") == 0 then
				func.setItemCount(slot,data.count-1)

				setElementData(getPedOccupiedVehicle(localPlayer), "veh:protected", 1)

				outputChatBox(core:getServerPrefix("green-dark", "Cartão Protect de Veículo Premium", 2).."Você protegeu o veículo com sucesso.", 255, 255, 255, true)
			else
				outputChatBox(core:getServerPrefix("red-dark", "Cartão Protect de Veículo Premium", 2).."Este veículo já está protegido.", 255, 255, 255, true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Cartão Protect de Veículo Premium", 2).."Esta operação só funciona no assento do motorista.", 255, 255, 255, true)
		end
	elseif data.item == 117 then
		if ( getPedStat ( localPlayer, 77 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 77, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 118 then
		if ( getPedStat ( localPlayer, 78 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 78, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 119 then
		if ( getPedStat ( localPlayer, 75 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 75, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 120 then
		if ( getPedStat ( localPlayer, 76 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 76, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 121 then
		if ( getPedStat ( localPlayer, 72 ) == 1000 ) and ( getPedStat ( localPlayer, 74 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 72, 1000)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 74, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 122 then
		if ( getPedStat ( localPlayer, 73 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 73, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 123 then
		if ( getPedStat ( localPlayer, 69 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 69, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 124 then
		if ( getPedStat ( localPlayer, 70 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 70, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 125 then
		if ( getPedStat ( localPlayer, 71 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 71, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 126 then
		if ( getPedStat ( localPlayer, 79 ) == 1000 ) then exports.oInfobox:outputInfoBox('Você já possui a estatística máxima no manuseio desta arma!','error') return end
		func.setItemCount(slot,data.count-1)
		triggerServerEvent("skillBook > updateSkill", resourceRoot, localPlayer, 79, 1000)
		outputChatBox(core:getServerPrefix("green-dark", "Livro Mestre", 2).."Você usou com sucesso um(a) "..getItemName(data.item)..".", 255, 255, 255, true)
	elseif data.item == 149 then
		exports.oJob_Newspaper:showNote()
	elseif data.item == 150 then
		if not isTimer(gyogyszer_timer) then
			if getElementHealth(localPlayer) < 95 then

				setElementHealth(localPlayer, getElementHealth(localPlayer) + 15)
				setElementData(localPlayer, "char:health", getElementHealth(localPlayer))
				chat:sendLocalMeAction("bevett egy vitamint.")

				func.setItemCount(slot,data.count-1)

				gyogyszer_timer = setTimer(function()
					if isTimer(gyogyszer_timer) then
						killTimer(gyogyszer_timer)
					end
				end, core:minToMilisec(5), 1)
			else
				outputChatBox(core:getServerPrefix("red-dark", "Vitamina", 3).."Você não precisa de vitamina.", 255, 255, 255, true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Vitamina", 3).."Você só pode usar vitamina a cada "..core:getServerColor().."5 #ffffffminutos.", 255, 255, 255, true)
		end
	elseif data.item == 151 then
		triggerServerEvent("inv > setPedArmor", resourceRoot, 100)

		chat:sendLocalMeAction("colocou um colete à prova de balas.")

		func.setItemCount(slot,data.count-1)
	elseif data.item == 171 then -- új drogrendszerhez ez már nem kell
		--[[if getElementDimension(localPlayer) > 0 then
			local potCount = 0

			for k, v in ipairs(getElementsByType("object")) do
				if getElementModel(v) == 2203 then
					if getElementDimension(v) == getElementDimension(localPlayer) then
						potCount = potCount + 1
					end
				end
			end

			if potCount < 40 then
				func.setItemCount(slot,data.count-1)

				triggerServerEvent("inv > createPot", resourceRoot, {{getElementPosition(localPlayer)}, getElementDimension(localPlayer), getElementInterior(localPlayer)})
				chat:sendLocalMeAction("lerakott egy cserepet.")
			else
				outputChatBox(core:getServerPrefix("red-dark", "Cserép", 3).."Egy interiorban maximum "..core:getServerColor().."40#ffffff darab cserép helyezhető le!", 255, 255, 255, true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "Cserép", 3).."Csak interiorban rakhatsz le cserepet!", 255, 255, 255, true)
		end
		return]]
	elseif data.item == 179 then
		if lastLuckyGame + 4000 < getTickCount() then
			lastLuckyGame = getTickCount()
			chat:sendLocalMeAction("jogou um dado. O resultado foi: "..math.random(1, 6)..".")
			triggerServerEvent("inv > playLuckGameSound", resourceRoot, "dice.mp3", getElementPosition(localPlayer))
		else
			outputChatBox(core:getServerPrefix("red-dark", "Dado", 3).."Você só pode jogar o dado a cada "..core:getServerColor().."4 #ffffffsegundos.", 255, 255, 255, true)
		end
	elseif data.item == 180 then
		if lastLuckyGame + 4000 < getTickCount() then
			lastLuckyGame = getTickCount()

			local cardValues = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "K", "Q"}
			chat:sendLocalMeAction("comprou uma carta de um baralho. A carta: "..cardValues[math.random(#cardValues)]..".")
			triggerServerEvent("inv > playLuckGameSound", resourceRoot, "card.mp3", getElementPosition(localPlayer))
		else
			outputChatBox(core:getServerPrefix("red-dark", "Dado", 3).."Você só pode comprar uma carta a cada "..core:getServerColor().."4 #ffffffsegundos.", 255, 255, 255, true)
		end
	elseif data.item == 181 then
		if lastLuckyGame + 4000 < getTickCount() then
			lastLuckyGame = getTickCount()

			local coinValues = {"cara", "coroa"}
			chat:sendLocalMeAction("jogou uma moeda: "..coinValues[math.random(#coinValues)]..".")
			triggerServerEvent("inv > playLuckGameSound", resourceRoot, "coin.wav", getElementPosition(localPlayer))
		else
			outputChatBox(core:getServerPrefix("red-dark", "Dado", 3).."Você só pode jogar a moeda a cada "..core:getServerColor().."4 #ffffffsegundos.", 255, 255, 255, true)
		end
	elseif data.item == 183 or data.item == 184 then
		if lastFuelCan + 1000 < getTickCount() then
			lastFuelCan = getTickCount()
			local fuelType = ""

			if data.item == 183 then
				fuelType = "D"
			else
				fuelType = "95"
			end

			triggerServerEvent("inv > takePetrolCan", resourceRoot)

			local petrolCan = getElementData(localPlayer, "activePetrolCan") or false
			if isElement(petrolCan) then
				exports.oFuel:destroyFuelMarker()
				cache.inventory.active.weapon = -1

				func.setItemState(slot, getElementData(localPlayer, "availableFuelInCan") * 10)

				chat:sendLocalMeAction("guardou um galão de combustível.")
			else
				exports.oFuel:createFuelMarker()
				setElementData(localPlayer, "petrolCanType", fuelType)
				setElementData(localPlayer, "availableFuelInCan", tonumber(data.state) / 10)
				cache.inventory.active.weapon = slot
				chat:sendLocalMeAction("pegou um galão de combustível.")
			end
		end
	elseif data.item == 199 then
		if isTimer(policeLight_timer) then return end
		if not getPedOccupiedVehicle(localPlayer) then return end
		if getPedOccupiedVehicleSeat(localPlayer) > 0 then return end
		if data.state == 2 then
			if exports.oFactionScripts:removeTaxiLightFromOccupiedVehicle() then
				chat:sendLocalMeAction("removeu do teto do veículo uma luz de táxi.")
				func.setItemState(slot, 1)
				policeLight_timer = setTimer(function()
					if isTimer(policeLight_timer) then killTimer(policeLight_timer) end
				end, 1000, 1)
			end
		else
			if exports.oFactionScripts:applyTaxiLightToOccupiedVehicle() then
				chat:sendLocalMeAction("colocou no teto do veículo uma luz de táxi.")
				func.setItemState(slot, 2)
				policeLight_timer = setTimer(function()
					if isTimer(policeLight_timer) then killTimer(policeLight_timer) end
				end, 1000, 1)
			end
		end
	elseif data.item == 206 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local state = exports.oLicenses:toggleCard(206, data.value, data.dbid)

			if not state then
				cache.inventory.active.identity = -1
				chat:sendLocalMeAction("guarda um documento de veículo.")
				setElementData(localPlayer, "active:itemValue", false)
			else
				cache.inventory.active.identity = slot
				chat:sendLocalMeAction("pega um documento de veículo.")
				setElementData(localPlayer, "active:itemValue", data.value)
			end
		end
	elseif data.item == 207 then
		if isElementWithinColShape(localPlayer, forgalmiCol) then
			local value = data.value
			func.setItemCount(slot,data.count-1)
			triggerServerEvent("giveItem", resourceRoot, localPlayer, 206, value, 1, 0)
			outputChatBox(core:getServerPrefix("green-dark", "Licença de Veículo", 2).."Você resgatou uma Licença de Veículo com sucesso!", 255, 255, 255, true)
			exports.oInfobox:outputInfoBox("Você resgatou uma Licença de Veículo!", "success")
		else
			outputChatBox(core:getServerPrefix("red-dark", "Licença de Veículo", 2).."A licença de veículo deve ser solicitada na prefeitura!", 255, 255, 255, true)
		end
	elseif data.item == 208 then
		local occupiedVeh = getPedOccupiedVehicle(localPlayer)

		if pdaInUse then return end
		if occupiedVeh then
			if getElementData(localPlayer, "char:money") >= 500 then
				if getElementData(occupiedVeh, "veh:isFactionVehice") == 1 then
					outputChatBox(core:getServerPrefix("red-dark", "OBD Scanner", 2).."Esta opção não está disponível para veículos de organização!", 255, 255, 255, true)
				else
					local ownerID = getElementData(occupiedVeh, "veh:owner")
					local ownerName, element = false

					for k, v in ipairs(getElementsByType("player")) do
						if getElementData(v, "char:id") == ownerID then
							ownerName = getElementData(v, "char:name")
							element = v
							break
						end
					end

					if ownerName and core:getDistance(element, localPlayer) <= 40 then
						if getElementHealth(occupiedVeh) >= 990 then
							setElementData(localPlayer, "char:money", getElementData(localPlayer, "char:money") - 500)
							pdaInUse = true

							playSound("files/sounds/pda.mp3")

							toggleControl("enter_exit", false)

							chat:sendLocalMeAction("conectou o OBD Scanner no veículo.")
							chat:sendLocalMeAction("ligou o OBD Scanner.")

							setTimer(function()
								chat:sendLocalDoAction("um programa iniciou no scanner.")
							end, 1500, 1)

							setTimer(function()
								chat:sendLocalDoAction("o programa está obtendo os dados do veículo.")
							end, 4000, 1)

							setTimer(function()
								chat:sendLocalDoAction("o programa terminou, o OBD Scanner desligou automaticamente.")
							end, 9000, 1)

							setTimer(function()
								chat:sendLocalMeAction("desconectou o OBD Scanner do veículo.")

								pdaInUse = false
								toggleControl("enter_exit", true)

								local vehType = getVehicleType(occupiedVeh)
								local vehTypeLenght = string.len(vehType)

								if string.len(vehTypeLenght) == 1 then
									vehTypeLenght = "0" .. vehTypeLenght
								end

								local vehName = exports.oVehicle:getModdedVehicleName(occupiedVeh)
								local vehNameLength = string.len(vehName)

								if string.len(vehNameLength) == 1 then
									vehNameLength = "0" .. vehNameLength
								end

								local plateText = getVehiclePlateText(occupiedVeh)
								local plateTextLength = string.len(plateText)

								local r1, g1, b1, r2, g2, b2 = getVehicleColor(occupiedVeh, true)

								local vehColor1, vehColor2 = RGBToHex(r1, g1, b1), RGBToHex(r2, g2, b2)

								local tunings = ""

								local carTunings = getElementData(occupiedVeh, "veh:engineTunings")

								local tuningList = {"engine", "gear", "brake", "turbo", "wheel", "ecu", "wloss"}

								local tuningVehList = {}
								for i = 1, 7 do
									if string.match(toJSON(carTunings), tuningList[i]) then
										for k, v in ipairs(carTunings) do
											if string.match(v, tuningList[i]) then
												local tuningCat = tostring(v:gsub(tuningList[i], ""):gsub("-", ""))
												tunings = tunings .. tuningCat
											end
										end
									else
										tunings = tunings .. "1"
									end
								end

								local otherTunings = {}

								if getElementData(occupiedVeh, "veh:neon:id") then
									table.insert(otherTunings, "NEON")
								end

								if getElementData(occupiedVeh, "veh:tuning:airride") then
									table.insert(otherTunings, "AIRRIDE")
								end

								if getElementData(occupiedVeh, "veh:sc") then
									table.insert(otherTunings, "SUPERCHARGER")
								end

								otherTunings = table.concat(otherTunings, ", ")

								local otherTuningsLength = string.len(otherTunings)

								if string.len(otherTuningsLength) == 1 then
									otherTuningsLength = "0" .. otherTuningsLength
								end

								local createDate = {core:getDate("year"), core:getDate("month"), core:getDate("monthday")}
								--[[if tonumber(createDate[2]) < 10 then
									createDate[2] = "0"..createDate[2]
								end

								if tonumber(createDate[3]) < 10 then
									createDate[3] = "0"..createDate[3]
								end ]]

								local endDate = {0, 0, 0}

								if createDate[2] == 12 then
									endDate[1] = createDate[1] + 1
									endDate[2] = 1
									endDate[3] = createDate[3]
								else
									endDate[1] = createDate[1]
									endDate[2] = createDate[2] + 1
									endDate[3] = createDate[3]
								end

								endDate[2] = tonumber(endDate[2])
								endDate[3] = tonumber(endDate[3])

								if monthDays[endDate[2]] < endDate[3] then
									endDate[3] = endDate[3] - monthDays[endDate[2]]
									endDate[2] = endDate[2] + 1
								end

								if endDate[2] < 10 then
									endDate[2] = "0"..endDate[2]
								end

								if endDate[3] < 10 then
									endDate[3] = "0"..endDate[3]
								end

								local expiry = endDate[1] .. endDate[2] .. endDate[3]

								local itemValue = vehTypeLenght .. vehNameLength .. plateTextLength .. otherTuningsLength .. vehType .. vehName .. plateText .. vehColor1 .. vehColor2 .. tunings .. otherTunings .. expiry .. ownerName

								outputChatBox(core:getServerPrefix("green-dark", "OBD Scanner", 2).."Você criou um formulário de requerimento!", 255, 255, 255, true)

								triggerServerEvent("giveItem", resourceRoot, localPlayer, 207, itemValue, 1, 0)
							end, 10000, 1)
						else
							outputChatBox(core:getServerPrefix("red-dark", "OBD Scanner", 2).."Estado do veículo inadequado!", 255, 255, 255, true)
						end
					else
						outputChatBox(core:getServerPrefix("red-dark", "OBD Scanner", 2).."O documento do veículo só pode ser emitido se o proprietário estiver próximo!", 255, 255, 255, true)
					end
				end
			else
				outputChatBox(core:getServerPrefix("red-dark", "OBD Scanner", 2).."Você não tem dinheiro suficiente! (500)", 255, 255, 255, true)
			end
		else
			outputChatBox(core:getServerPrefix("red-dark", "OBD Scanner", 2).."Você não está em um veículo!", 255, 255, 255, true)
		end
	elseif data.item == 67 then
		if cache.inventory.active.weapon == slot then
			cache.inventory.active.weapon = -1
			triggerServerEvent("flexInUse", localPlayer, localPlayer)
			setElementData(localPlayer, "char:flexInUse", false)
			chat:sendLocalMeAction("guarda um flex.")
		elseif cache.inventory.active.weapon == -1 then
			cache.inventory.active.weapon = slot
			triggerServerEvent("flexInUse", localPlayer, localPlayer)
			setElementData(localPlayer, "char:flexInUse", true)
			chat:sendLocalMeAction("pega um flex.")
		end
	elseif data.item == 209 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local state = exports.oPrinter:toggleCopyCard(209, data.value)
			if not state then
				cache.inventory.active.identity = -1
				chat:sendLocalMeAction("guarda uma cópia de documento.")
				setElementData(localPlayer, "active:itemValue", false)
			else
				cache.inventory.active.identity = slot
				chat:sendLocalMeAction("pega uma cópia de documento.")
				setElementData(localPlayer, "active:itemValue", data.value)
			end
		end
	elseif data.item == 210 then
		triggerServerEvent("attachPoliceShield", localPlayer, localPlayer)
	elseif isAlcoholDrink(data.item) then
		Block, Anim = getPedAnimation(localPlayer)
		if Block then return end
		if not isTimer(usespam) then
			chat:sendLocalMeAction("bebe um(a) "..getItemName(data.item)..".")
			triggerServerEvent("eatingAnimation",localPlayer,localPlayer,"drink",data.item)
			func.setItemCount(slot,data.count-1)
			local level = getElementData(localPlayer, "char:alcoholLevel") or 0
			if level + alcoholItemDiff[data.item] > 100 then
				setElementData(localPlayer, "char:alcoholLevel", 100)
				--addDrunkenLevel(3)
			else
				setElementData(localPlayer, "char:alcoholLevel", level+alcoholItemDiff[data.item])
				--addDrunkenLevel(3)
			end

			usespam = setTimer(function()
				killTimer(usespam)
			end,1700,1)
		else
			outputChatBox(core:getServerPrefix("red-dark", "Inventory", 3).."Aguarde alguns segundos.",246,137,52,true)
		end
	elseif data.item == 218 then
		--outputChatBox("as")
		triggerServerEvent("placeApiary", localPlayer, localPlayer)
		func.setItemCount(slot,data.count-1)
	elseif data.item == 226 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			if getElementData(thePlayer, "char:duty:faction") > 0 then
				if exports.oDashboard:getFactionType(getElementData(thePlayer, "char:duty:faction")) == 1 then 
					local state = exports.oTicket:toggleTicket("orfk")

					if not state then
						cache.inventory.active.identity = -1
						chat:sendLocalMeAction("guarda um talão de cheques.")
						setElementData(localPlayer, "active:itemValue", false)
					else
						if not (cache.inventory.active.identity == slot) then
							cache.inventory.active.identity = slot
							cache.inventory.active.csekkfuzet = data
							chat:sendLocalMeAction("pega um talão de cheques.")
							setElementData(localPlayer, "active:itemValue", data.value)
						end
					end
				else
					outputChatBox(core:getServerPrefix("red-dark", "Ticket", 3).."Você só pode usar este item em serviço!", 255, 255, 255, true)
				end
			else
				outputChatBox(core:getServerPrefix("red-dark", "Ticket", 3).."Você só pode usar este item em serviço!", 255, 255, 255, true)
			end
		end
	elseif data.item == 227 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			if getElementData(localPlayer, "char:duty:faction") == 19 then
				local state = exports.oTicket:toggleTicket("omsz")

				if not state then
					cache.inventory.active.identity = -1
					chat:sendLocalMeAction("guarda um talão de cheques.")
					setElementData(localPlayer, "active:itemValue", false)
				else
					if not (cache.inventory.active.identity == slot) then
						cache.inventory.active.identity = slot
						cache.inventory.active.csekkfuzet = data
						chat:sendLocalMeAction("pega um talão de cheques.")
						setElementData(localPlayer, "active:itemValue", data.value)
					end
				end
			else
				outputChatBox(core:getServerPrefix("red-dark", "Ticket", 3).."Você só pode usar este item em serviço!", 255, 255, 255, true)
			end
		end
	elseif data.item == 228 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local state = exports.oTicket:toggleTicket("orfk", fromJSON(data.value))

			if not state then
				cache.inventory.active.identity = -1
				chat:sendLocalMeAction("guarda uma multa.")
				setElementData(localPlayer, "active:itemValue", false)
			else
				cache.inventory.active.identity = slot
				chat:sendLocalMeAction("pega uma multa.")
				setElementData(localPlayer, "active:itemValue", data.value)
			end
		end
	elseif data.item == 229 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local state = exports.oTicket:toggleTicket("omsz", fromJSON(data.value))

			if not state then
				cache.inventory.active.identity = -1
				chat:sendLocalMeAction("guarda um cheque de taxa de atendimento.")
				setElementData(localPlayer, "active:itemValue", false)
			else
				cache.inventory.active.identity = slot
				chat:sendLocalMeAction("guarda um cheque de taxa de atendimento.")
				setElementData(localPlayer, "active:itemValue", data.value)
			end
		end
	elseif data.item == 236 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			local vehicle = getPedOccupiedVehicle (localPlayer)
			local playerID = getElementData(localPlayer, "char:id")
			if vehicle then
				if getElementData(vehicle, "veh:owner") == playerID then
					func.setItemCount(slot,data.count-1)
					outputChatBox(core:getServerPrefix("green-dark", "Inventário", 2).."Você trocou a fechadura do seu veículo! (Todas as cópias e chaves originais em outros jogadores foram removidas; você ficou com a única chave.)", 255, 255, 255, true)
					triggerServerEvent("deleteAllExisitingItemWithValue",localPlayer,51,getElementData(vehicle,("veh:id")))
					triggerServerEvent("deleteAllExisitingItemWithValue",localPlayer,234,getElementData(vehicle,("veh:id")))
					triggerServerEvent("giveItem", resourceRoot, localPlayer, 51, getElementData(vehicle,("veh:id")), 1, 0)
				else
					outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Este veículo não é seu (dono IC).",220,20,60,true)
				end
			else
				outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Não estás dentro de um veículo.",220,20,60,true)
			end
		end
	elseif data.item == 237 then
		if cache.inventory.active.identity == -1 or cache.inventory.active.identity == slot then
			if getPedOccupiedVehicle(localPlayer) then return end
				for k, v in ipairs(getElementsByType("marker")) do
					if getElementData(v,"isIntMarker") then
						if getElementData(v, "owner") == getElementData(localPlayer, "char:id") then
							intimarker = v
						end
					end
				end

				local isInMarker = isElementWithinMarker(localPlayer, intimarker)

				if isInMarker then
					func.setItemCount(slot,data.count-1)
					outputChatBox(core:getServerPrefix("green-dark", "Inventário", 2).."Você trocou a fechadura do seu imóvel! (Todas as cópias e chaves originais em outros jogadores foram removidas; você ficou com a única chave.)", 255, 255, 255, true)
					triggerServerEvent("deleteAllExisitingItemWithValue",localPlayer,52,getElementData(intimarker,("dbid")))
					triggerServerEvent("deleteAllExisitingItemWithValue",localPlayer,235,getElementData(intimarker,("dbid")))
					triggerServerEvent("giveItem", resourceRoot, localPlayer, 52, getElementData(intimarker,("dbid")), 1, 0)
				end
		end
	elseif data.item == 239 then
		if getElementData(localPlayer,"inRefuelCol") then
			col = getElementData(localPlayer,"player:oilCol")
			veh = getElementData(col,"col:oilVeh")

			if getElementData(veh,"veh:distanceToOilChange") == 0 then
				outputChatBox(color.."[Óleo]#ffffff Você abasteceu o nível de óleo do veículo ao máximo.",255,255,255,true)
				takeItem(data.item)
				setElementData(veh,"veh:distanceToOilChange",15000)
				setElementData(veh,"oilLamp",false)
				setElementData(localPlayer,"inRefuelCol",false)
			end
		end
	elseif data.item == 240 then
		if not getElementData(localPlayer,"char:goggleUser") then
			exports.oGoggle:getUpGoggle(localPlayer)
			chat:sendLocalMeAction("coloca um óculos tático.")
			setElementData(localPlayer, "active:itemValue", data.value)
			cache.inventory.active.goggle = slot
		else
			exports.oGoggle:takeDownGoggle(localPlayer)
			chat:sendLocalMeAction("tira um óculos tático.")
			setElementData(localPlayer, "active:itemValue", false)
			cache.inventory.active.goggle = -1

		end
	elseif data.item == 223 then 
		if getElementData(localPlayer,"isInWaterMarker") then 
				takeItem(data.item)
				triggerServerEvent("giveItem", resourceRoot, localPlayer, 172, 100, 1, 0)
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Você recarregou seu regador com sucesso!",220,20,60,true)
		end 
	elseif data.item == 243 then 
		if not getPedOccupiedVehicle(localPlayer) then
			if not fireworkSpam then
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Este item de evento não está disponível no momento!",220,20,60,true)

				fireworkSpam = true 
				--[[takeItem(data.item)
				makeFireWork(localPlayer,1)
				chat:sendLocalMeAction("lerakott egy tűzijátékot. ("..getItemName(data.item)..")")]]
				setTimer(function()
					fireworkSpam = false
				end,5000,1)
			else 
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Aguarde alguns segundos!",220,20,60,true)
			end 
		end
	elseif data.item == 244 then 
		if not getPedOccupiedVehicle(localPlayer) then
			if not fireworkSpam then
				fireworkSpam = true
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Este item de evento não está disponível no momento!",220,20,60,true)

				--[[takeItem(data.item) 
				makeFireWork(localPlayer,2)
				chat:sendLocalMeAction("lerakott egy tűzijátékot. ("..getItemName(data.item)..")")]]
				setTimer(function()
					fireworkSpam = false
				end,5000,1)
			else 
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Aguarde alguns segundos!",220,20,60,true)
			end 
		end
	elseif data.item == 245 then 
		if not getPedOccupiedVehicle(localPlayer) then
			if not fireworkSpam then
				fireworkSpam = true
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Este item de evento não está disponível no momento!",220,20,60,true)

				--[[takeItem(data.item) 
				makeFireWork(localPlayer,3)
				chat:sendLocalMeAction("lerakott egy tűzijátékot. ("..getItemName(data.item)..")")]]
				setTimer(function()
					fireworkSpam = false
				end,5000,1)
			else 
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Aguarde alguns segundos!",220,20,60,true)
			end 
		end
	elseif data.item == 246 then 
		if not getPedOccupiedVehicle(localPlayer) then
			if not fireworkSpam then
				fireworkSpam = true
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Este item de evento não está disponível no momento!",220,20,60,true)

				--[[takeItem(data.item) 
				makeFireWork(localPlayer,4)
				chat:sendLocalMeAction("lerakott egy tűzijátékot. ("..getItemName(data.item)..")")]]
				setTimer(function()
					fireworkSpam = false
				end,5000,1)
			else 
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Aguarde alguns segundos!",220,20,60,true)
			end 
		end
	elseif data.item == 247 then 
		if not getPedOccupiedVehicle(localPlayer) then
			if not fireworkSpam then
				fireworkSpam = true
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Este item de evento não está disponível no momento!",220,20,60,true)

				--[[takeItem(data.item) 
				setElementFrozen(localPlayer,true)
				makeFireWork(localPlayer,1)
				setTimer(function()
					makeFireWork(localPlayer,2)
					setTimer(function()
						makeFireWork(localPlayer,3)
						setTimer(function()
							makeFireWork(localPlayer,4)
							setElementFrozen(localPlayer,false)
						end,500,1)
					end,500,1)
				end,500,1)
				chat:sendLocalMeAction("lerakott egy tűzijátékot. ("..getItemName(data.item)..")")]]
				setTimer(function()
					fireworkSpam = false
				end,5000,1)
			else 
				outputChatBox(core:getServerPrefix("server", "Inventory", 3).."Aguarde alguns segundos!",220,20,60,true)
			end 
		end
	elseif weaponCache[data.item] then
		--outputChatBox("nem használhatod a fegyvert mert a kurva anyád")
		if data.state <= 0 then
			outputChatBox(core:getServerPrefix("red-dark", "Inventory", 3).."A arma selecionada está inutilizável.",220,20,60,true)
		else
			if cache.inventory.active.weapon == slot then
				cache.inventory.active.weapon = -1
				cache.inventory.active.ammo = -1
				cache.inventory.active.dbid = -1
				cache.inventory.active.weaponState = -1
				cache.inventory.active.weaponID = -1
				triggerServerEvent("takeWeaponServer",localPlayer,localPlayer,data.item,data.id,data.value)
				setElementData(localPlayer, "playerNoAmmo", false)
			elseif cache.inventory.active.weapon == -1 then
				local currentslot = false
				if weaponCache[data.item].ammo == data.item then
					currentslot = slot
				end
				local state,ammoData = hasItem(weaponCache[data.item].ammo,false,currentslot)
				if state then
					Block, Anim = getPedAnimation(localPlayer)
					if Block then return end
					cache.inventory.active.weapon = slot
					cache.inventory.active.weaponID = data.item
					cache.inventory.active.weaponState = data.state
					cache.inventory.active.dbid = data.id
					if not weaponProgress[cache.inventory.active.weapon] then weaponProgress[cache.inventory.active.weapon] = 0 end
					if weaponProgress[cache.inventory.active.weapon] > 15 and toggleControlSlot[cache.inventory.active.weapon] then
						toggleControl("fire",false)
						toggleControl("action",false)
					end
					--iprint(ammoData)
					cache.inventory.active.ammo = ammoData.slot
					triggerServerEvent("giveWeaponServer",localPlayer,localPlayer,weaponCache[data.item].weapon,ammoData.count,data.item,data.id,data.value)
				else
					cache.inventory.active.weapon = slot
					cache.inventory.active.weaponID = data.item
					cache.inventory.active.weaponState = data.state
					cache.inventory.active.dbid = data.id
					if not weaponProgress[cache.inventory.active.weapon] then weaponProgress[cache.inventory.active.weapon] = 0 end
					if weaponCache[data.item].hotTable then
						weaponProgress[cache.inventory.active.weapon] = 0
						toggleControl("fire",false)
						toggleControl("action",false)
						setElementData(localPlayer, "playerNoAmmo", true)
						--outputChatBox("noAmmo")
					end

					local defaultammo = 1;
					if data.item == 162 or data.item == 152 or data.item == 161 or data.item == 41 then
						defaultammo = 9999;
					end
					--outputChatBox(cache.inventory.active.ammo)
					triggerServerEvent("giveWeaponServer",localPlayer,localPlayer,weaponCache[data.item].weapon,defaultammo,data.item,data.id,data.value)
				end
			end
		end
	end
end

function ticketSignCompleted()
	if tonumber(cache.inventory.active.csekkfuzet.value) <= 1 then
		func.deleteItem(cache.inventory.active.identity)
	else
		func.setItemValue(cache.inventory.active.identity, cache.inventory.active.csekkfuzet.value - 1)
	end

	cache.inventory.active.csekkfuzet = nil
	cache.inventory.active.identity = -1
end

-- Old Item functions
addEvent("inv > playLuckGameSoundInClient", true)
addEventHandler("inv > playLuckGameSoundInClient", root, function(sound, x, y, z)
	playSound3D("files/sounds/"..sound, x, y, z)
end)

local protectedHzS = {
	[911] = 1, -- police
	[811] = 21, -- sheriff
	[711] = 19, -- mentő
	[611] = 4, -- tűzoltóság
	[999] = 11, -- gov
	[555] = 3, -- szerelő
}

local lastRadioInteraction = getTickCount()
addCommandHandler("tuneradio", function(cmd, station)
	if hasItem(154) then
		if tonumber(station) then
			if getElementData(localPlayer, "playerInDead") then return end
			station = tonumber(station)
			if lastRadioInteraction + 500 < getTickCount() then
				if protectedHzS[station] then
					if not exports.oDashboard:isPlayerFactionMember(protectedHzS[station]) then
						outputChatBox(core:getServerPrefix("red-dark", "Rádio", 2).."Esta é uma frequência protegida que você não tem permissão para usar! "..color.."("..station..")", 255, 255, 255, true)
						return
					end
				end

				exports.oChat:sendLocalMeAction("ajusta a frequência do seu rádio.")
				setElementData(localPlayer, "char:radioStation", station)
				lastRadioInteraction = getTickCount()
				outputChatBox(core:getServerPrefix("green-dark", "Rádio", 2).."Você configurou a frequência do seu rádio com sucesso. "..color.."("..station..")", 255, 255, 255, true)
			end
		else
			outputChatBox(core:getServerPrefix("server", "Uso", 3).."/"..cmd.." [Frequência]", 255, 255, 255, true)
		end
	else
		outputChatBox(core:getServerPrefix("red-dark", "Rádio", 2).."Você não tem um rádio!", 255, 255, 255, true)
	end
end)

function removeHex(msg)
    return msg:gsub("#" .. (6 and string.rep("%x", 6) or "%x+"), "")
end

function getNearestPlayers(thePlayer, dist)
	if not dist then dist = 20 end
	local tempTable = {}
	local x1, y1, z1 = getElementPosition(thePlayer)
	local int = getElementInterior(thePlayer)
	local dim = getElementDimension(thePlayer)

	for _, player in pairs(getElementsByType("player")) do
		if int == getElementInterior(player) and dim == getElementDimension(player) then
			local x2, y2, z2 = getElementPosition(player)
			if getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2) < dist then
                table.insert(tempTable, player)
			end
		end
	end
	return tempTable
end

local protectedCols = {}
function createProtectedPlaces()
	for k, v in ipairs(protectedPlaces) do
		local col = createColCuboid(v.pos.x, v.pos.y, v.pos.z, v.w, v.d, v.h)
		table.insert(protectedCols, #protectedCols+1, col)
	end
end
addEventHandler("onClientResourceStart", resourceRoot, createProtectedPlaces)

function elementInProtectedPlace(element)
	local inPlace = false
	for k, v in pairs(protectedCols) do
		if isElementWithinColShape(element, v) then
			inPlace = true
			break
		end
	end

	return inPlace
end

local maxAmmoInClips = {
	[22] = 17,
	[24] = 7,
	[25] = 1,
	[26] = 2,
	[27] = 7,
	[28] = 50,
	[29] = 30,
	[32] = 50,
	[30] = 30,
	[31] = 50,
	[33] = 1,
	[34] = 1,
	[35] = 1,
	[36] = 1,
	[37] = 50,
	[38] = 500,
}

bindKey("R", "up", function()
	if cache.inventory.active.weapon > 0 and cache.inventory.active.ammo > 0 then
		--print(getPedTotalAmmo(localPlayer))
		if getPedTotalAmmo(localPlayer) < maxAmmoInClips[getPedWeapon(localPlayer)] then return end
		if getPedAmmoInClip(localPlayer) < maxAmmoInClips[getPedWeapon(localPlayer)] then
			triggerServerEvent("inventory > reloadWeaponAmmo", resourceRoot, localPlayer)
		end
	end
end)
-- / fegyver melegedés / --
melegedes = {}
local hotTimer = false

function weaponHot(weaponID)
	if source == localPlayer then
		if getElementData(localPlayer, "inWeaponSkilling") then return end
		if weaponCache[cache.inventory.active.weaponID].hotTable then

			item = cache.inventory.active.weapon

			if not melegedes[item] then
				table.insert(melegedes, item, 0)
			end

			melegedes[item] = melegedes[item] + weaponCache[cache.inventory.active.weaponID].hotTable

			if melegedes[item] > 100 then
				melegedes[item] = 100

				setElementHealth(localPlayer, getElementHealth(localPlayer) - 3)
				setElementData(localPlayer, "char:health", getElementHealth(localPlayer))
				outputChatBox(core:getServerPrefix("red-dark", "Arma", 3).."A arma superaqueceu e você se queimou.", 255, 255, 255, true)

				local newValue = math.random(1, 10)

				if newValue < 0 then
					newValue = 0
				end

				func.setItemState(cache.inventory.active.weapon, cache.inventory.active.weaponState - newValue)

				triggerServerEvent("takeWeaponServer",localPlayer,localPlayer,cache.inventory.active.weaponID,cache.inventory.active.dbid,cache.inventory.active.value)
				cache.inventory.active.weapon = -1
				cache.inventory.active.ammo = -1
				cache.inventory.active.dbid = -1
				cache.inventory.active.weaponID = -1
			end

			if not isTimer(hotTimer) then
				hotTimer = setTimer(function()
					if isTimer(hotTimer) then
						melegedes[item] = melegedes[item] - 1

						if melegedes[item] < 0 then
							melegedes[item] = 0
						end

						if melegedes[item] <= 0 then
							killTimer(hotTimer)
						end

						setElementData(localPlayer, "weapon:hot", melegedes[item])
					end
				end, 75, 0)
			end

			setElementData(localPlayer, "weapon:hot", melegedes[item])
		end
	end
end
addEventHandler("onClientPlayerWeaponFire", root, weaponHot)

function RGBToHex(red, green, blue, alpha)

	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("%.2X%.2X%.2X", red, green, blue)
	end

end

addEventHandler("onClientPlayerDamage", getRootElement(), function(attacker, damageType, bodyPart)
	if (getElementData(localPlayer, "activePoliceShield")) then
		if bodyPart == 7 or bodyPart == 8 or bodyPart == 9 then
			return
		end

		local tx,ty,tz = getElementPosition(attacker)
		local px,py,pz = getElementPosition(localPlayer)
		if getDistanceBetweenPoints3D(px,py,pz,tx,ty,tz) <= 5 then return end
		cancelEvent()
	end
end)

function rotateAround(angle, x, y, x2, y2)
	local targetX = x2 or 0
	local targetY = y2 or 0
	local centerX = x
	local centerY = y

	local radiant = math.rad(angle)
	local rotatedX = targetX + (centerX - targetX) * math.cos(radiant) - (centerY - targetY) * math.sin(radiant)
	local rotatedY = targetY + (centerX - targetX) * math.sin(radiant) + (centerY - targetY) * math.cos(radiant)

	return rotatedX, rotatedY
end

addEventHandler("onClientPlayerStealthKill", getRootElement(), function(tp)
	if getElementData(tp, "user:aduty") then
		--print("fasz")
		cancelEvent()
	end
end)

addEventHandler("onClientKey", getRootElement(), function(button,state)
	--if  then
		if button == "c" and state and getElementData(localPlayer, "activePoliceShield") then
			outputChatBox(core:getServerPrefix("red-dark", "Shield", 3).."Você não pode se agachar com o escudo policial!", 255, 255, 255, true)
			cancelEvent()

		end
	--end
end)
