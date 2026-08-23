--[[ Comandos VIP/Sócio — integração com veículo, kits e pedidos IC ]]

local core = exports.oCore

local function pref(tag)
	return core:getServerPrefix("green-dark", tag or "VIP", 3)
end

local cooldowns = {}
local pendingTpp = {}
local pendingPull = {}
local pendingSpectate = {}

--[[ Limite diário de /cv por personagem (resets por yearday do servidor) ]]
local CV_DAILY_MAX = 5
local cvDailyByChar = {}

local function cvDailyBucket(charId)
	local rt = getRealTime()
	local yd = rt.yearday
	cvDailyByChar[charId] = cvDailyByChar[charId] or { d = -1, n = 0 }
	local e = cvDailyByChar[charId]
	if e.d ~= yd then
		e.d = yd
		e.n = 0
	end
	return e
end

local function cvDailyCanUse(charId)
	local e = cvDailyBucket(charId)
	return e.n < CV_DAILY_MAX
end

local function cvDailyRegisterUse(charId)
	local e = cvDailyBucket(charId)
	e.n = e.n + 1
end

local function vipLogAdminCmd(srcName, tgtName, cmd)
	local rt = getRealTime()
	local dateStr = string.format(
		"%04d-%02d-%02d %02d:%02d:%02d",
		rt.year + 1900,
		rt.month + 1,
		rt.monthday,
		rt.hour,
		rt.minute,
		rt.second
	)
	triggerEvent("sendPlayerLogs", root, "admincmd", { srcName, tgtName or "-", cmd, dateStr })
end

--[[ Espectador VIP — mesma mecânica base do /recon (oAdmin), chaves vip:* e alvo aceita IC ]]
local function vipReconEnd(watcher, quiet)
	if not isElement(watcher) or getElementType(watcher) ~= "player" then
		return
	end
	local target = getElementData(watcher, "vip:reconTarget")
	local startpos = getElementData(watcher, "vip:reconStartpos")
	local dimInt = getElementData(watcher, "vip:reconStartDimInt")

	if isElement(target) and getElementData(target, "vip:watchedBy") == watcher then
		setElementData(target, "vip:watchedBy", false)
	end

	detachElements(watcher)

	if startpos and startpos[1] and startpos[2] and startpos[3] then
		setElementPosition(watcher, startpos[1], startpos[2], startpos[3])
	end
	if dimInt and dimInt[1] ~= nil and dimInt[2] ~= nil then
		setElementDimension(watcher, dimInt[1])
		setElementInterior(watcher, dimInt[2])
	end

	setElementData(watcher, "vip:reconTarget", false)
	setElementData(watcher, "vip:reconStartpos", false)
	setElementData(watcher, "vip:reconStartDimInt", false)

	setElementAlpha(watcher, 255)
	setElementCollisionsEnabled(watcher, true)
	setCameraTarget(watcher, watcher)
	if not quiet then
		outputChatBox(pref("Spectate") .. "#ffffffModo espectador desligado.", watcher, 255, 255, 255, true)
	end
end

local function vipReconStart(watcher, target)
	if not isElement(watcher) or not isElement(target) then
		return
	end
	if getElementData(watcher, "recon:reconedPlayer") then
		outputChatBox(pref("Spectate") .. "#ffffffTermina o recon de staff antes de usar espectador VIP.", watcher, 255, 255, 255, true)
		return
	end
	if getElementData(watcher, "vip:reconTarget") then
		vipReconEnd(watcher, true)
	end
	if getElementData(target, "vip:watchedBy") then
		outputChatBox(pref("Spectate") .. "#ffffffEsse jogador já está a ser observado.", watcher, 255, 255, 255, true)
		return
	end

	local sx, sy, sz = getElementPosition(watcher)
	setElementAlpha(watcher, 0)
	setElementCollisionsEnabled(watcher, false)
	setElementData(watcher, "vip:reconStartpos", { sx, sy, sz })
	setElementData(watcher, "vip:reconStartDimInt", { getElementDimension(watcher), getElementInterior(watcher) })
	setElementData(watcher, "vip:reconTarget", target)
	setElementData(target, "vip:watchedBy", watcher)

	local px, py, pz = getElementPosition(target)
	setElementPosition(watcher, px, py, -100)
	attachElements(watcher, target, 0, 0, -100)
	setCameraTarget(watcher, target)
	setElementInterior(watcher, getElementInterior(target))
	setElementDimension(watcher, getElementDimension(target))

	outputChatBox(
		pref("Spectate") .. "#ffffffEstás a observar " .. getPlayerName(target):gsub("_", " ") .. ". /parspectar para sair.",
		watcher,
		255,
		255,
		255,
		true
	)
end

local function cdOk(pl, key, ms)
	local t = getTickCount()
	cooldowns[pl] = cooldowns[pl] or {}
	if (cooldowns[pl][key] or 0) + ms > t then
		return false, math.ceil(((cooldowns[pl][key] or 0) + ms - t) / 1000)
	end
	cooldowns[pl][key] = t
	return true
end

local function needLogged(pl)
	if not isElement(pl) or getElementType(pl) ~= "player" then return false end
	if not getElementData(pl, "user:loggedin") then
		outputChatBox(pref() .. "#ffffffPrecisas de personagem ativo.", pl, 255, 255, 255, true)
		return false
	end
	return true
end

local function randomPlate()
	local s = ""
	for _ = 1, 8 do
		s = s .. string.char(math.random(65, 90))
	end
	return s
end

local function canUsePremiumVehicle(pl)
	return getVipTierRank(pl) >= 3 or getSocioTierRank(pl) >= 3
end

local function canUseHeli(pl)
	return getVipTierRank(pl) >= 3
end

local function canPskin(pl)
	return getVipTierRank(pl) >= 2 or getSocioTierRank(pl) >= 2
end

local function canKits(pl)
	return getVipTierRank(pl) >= 1 or getSocioTierRank(pl) >= 1
end

local function canRepair(pl)
	return getVipTierRank(pl) >= 2 or getSocioTierRank(pl) >= 2
end

local function canRequestStaffTp(pl)
	return getVipTierRank(pl) >= 3 or getSocioTierRank(pl) >= 3
end

addEventHandler("onPlayerQuit", root, function()
	local quitter = source
	cooldowns[quitter] = nil
	pendingTpp[quitter] = nil
	pendingPull[quitter] = nil
	pendingSpectate[quitter] = nil
	for tEl, pend in pairs(pendingSpectate) do
		if pend and pend.from == quitter then
			pendingSpectate[tEl] = nil
		end
	end

	local tgt = getElementData(quitter, "vip:reconTarget")
	if isElement(tgt) and getElementData(tgt, "vip:watchedBy") == quitter then
		setElementData(tgt, "vip:watchedBy", false)
	end

	local watcher = getElementData(quitter, "vip:watchedBy")
	if isElement(watcher) and getElementData(watcher, "vip:reconTarget") == quitter then
		vipReconEnd(watcher, true)
		outputChatBox(pref("Spectate") .. "#ffffffO alvo desconectou — espectador encerrado.", watcher, 255, 255, 255, true)
	end
end)

addEventHandler("onElementDataChange", root, function(dataName, _oldVal, newVal)
	if dataName ~= "user:loggedin" or newVal ~= false then
		return
	end
	local el = source
	if not isElement(el) or getElementType(el) ~= "player" then
		return
	end
	local watcher = getElementData(el, "vip:watchedBy")
	if isElement(watcher) and getElementData(watcher, "vip:reconTarget") == el then
		vipReconEnd(watcher, true)
		outputChatBox(pref("Spectate") .. "#ffffffPersonagem desativado — espectador encerrado.", watcher, 255, 255, 255, true)
	end
end)

--[[ /cv [modelo] — VIP Ipiranga ou Sócio Patrocinador (veículos terrestres; heli só VIP Ipiranga) ]]
local function cmdVipCv(pl, _, modelId)
	if not needLogged(pl) then return end
	if tonumber(getElementData(pl, "user:admin") or 0) >= 7 then
		outputChatBox(pref("Veículo") .. "#ffffffComo admin usa #aaaaaa/makeveh#ffffff.", pl, 255, 255, 255, true)
		return
	end
	if not canUsePremiumVehicle(pl) then
		outputChatBox(pref("Veículo") .. "#ffffffPrecisas de VIP Ipiranga ou Sócio Patrocinador ativo.", pl, 255, 255, 255, true)
		return
	end
	modelId = tonumber(modelId)
	if not modelId or modelId < 400 or modelId > 611 then
		outputChatBox(pref("Veículo") .. "#ffffffUso: /cv [id_modelo]", pl, 255, 255, 255, true)
		return
	end
	local charId = tonumber(getElementData(pl, "char:id") or 0) or 0
	if charId <= 0 then
		outputChatBox(pref("Veículo") .. "#ffffffPersonagem inválido para criar veículo.", pl, 255, 255, 255, true)
		return
	end
	if not cvDailyCanUse(charId) then
		outputChatBox(
			pref("Veículo") .. "#ffffffLimite diário de /cv atingido (" .. tostring(CV_DAILY_MAX) .. " criações por personagem).",
			pl,
			255,
			255,
			255,
			true
		)
		return
	end
	local okCd, sec = cdOk(pl, "vipcv", 300000)
	if not okCd then
		outputChatBox(pref("Veículo") .. "#ffffffAguarda " .. tostring(sec) .. " s antes de criar outro veículo VIP.", pl, 255, 255, 255, true)
		return
	end
	local vType = getVehicleType(modelId)
	if vType == "Plane" then
		outputChatBox(pref("Veículo") .. "#ffffffAviões não estão disponíveis neste comando.", pl, 255, 255, 255, true)
		return
	end
	if vType == "Helicopter" and not canUseHeli(pl) then
		outputChatBox(pref("Veículo") .. "#ffffffHelicópteros: apenas com VIP Ipiranga ativo.", pl, 255, 255, 255, true)
		return
	end
	if not exports.oVehicle:getModdedVehName(modelId) then
		outputChatBox(pref("Veículo") .. "#ffffffModelo inválido ou bloqueado no servidor.", pl, 255, 255, 255, true)
		return
	end
	local x, y, z = getElementPosition(pl)
	local _, _, rz = getElementRotation(pl)
	local veh = exports.oVehicle:createNewVehicle(modelId, pl, { x + 2.5, y, z }, { 0, 0, rz }, { 255, 255, 255 }, randomPlate())
	if isElement(veh) then
		cvDailyRegisterUse(charId)
		vipLogAdminCmd(getPlayerName(pl):gsub("_", " "), "-", "/cv " .. tostring(modelId))
		outputChatBox(pref("Veículo") .. "#ffffffVeículo criado. ID #" .. tostring(getElementData(veh, "veh:id") or "?") .. ".", pl, 255, 255, 255, true)
	else
		outputChatBox(pref("Veículo") .. "#ffffffFalha ao criar veículo.", pl, 255, 255, 255, true)
	end
end

--[[ /pskin [id] — VIP Omega+ ou Sócio Ouro+ ]]
local function cmdVipPskin(pl, _, skinId)
	if not needLogged(pl) then return end
	if tonumber(getElementData(pl, "user:admin") or 0) >= 7 then
		outputChatBox(pref("Aparência") .. "#ffffffComo admin usa o painel/comandos de aparência.", pl, 255, 255, 255, true)
		return
	end
	if not canPskin(pl) then
		outputChatBox(pref("Aparência") .. "#ffffffPrecisas de VIP Omega (ou acima) ou Sócio Ouro/Patrocinador.", pl, 255, 255, 255, true)
		return
	end
	skinId = tonumber(skinId)
	if not skinId or skinId < 0 or skinId > 312 then
		outputChatBox(pref("Aparência") .. "#ffffffUso: /pskin [0–312]", pl, 255, 255, 255, true)
		return
	end
	local okP, waitP = cdOk(pl, "pskin", 15000)
	if not okP then
		outputChatBox(pref("Aparência") .. "#ffffffAguarda " .. tostring(waitP or 0) .. " s entre alterações.", pl, 255, 255, 255, true)
		return
	end
	setElementModel(pl, skinId)
	outputChatBox(pref("Aparência") .. "#ffffffSkin aplicada: " .. tostring(skinId) .. ".", pl, 255, 255, 255, true)
end

local function cmdVipHeal(pl)
	if not needLogged(pl) then return end
	if not canKits(pl) then
		outputChatBox(pref("Kit") .. "#ffffffPrecisas de subscrição VIP ou Sócio ativa.", pl, 255, 255, 255, true)
		return
	end
	local okCd, sec = cdOk(pl, "vipheal", 60000)
	if not okCd then
		outputChatBox(pref("Kit") .. "#ffffffKit de vida disponível em " .. tostring(sec) .. " s.", pl, 255, 255, 255, true)
		return
	end
	setElementHealth(pl, 100)
	outputChatBox(pref("Kit") .. "#ffffffVida restaurada.", pl, 255, 255, 255, true)
end

local function cmdVipArmor(pl)
	if not needLogged(pl) then return end
	if not canKits(pl) then
		outputChatBox(pref("Kit") .. "#ffffffPrecisas de subscrição VIP ou Sócio ativa.", pl, 255, 255, 255, true)
		return
	end
	local okCd, sec = cdOk(pl, "viparmor", 60000)
	if not okCd then
		outputChatBox(pref("Kit") .. "#ffffffKit de colete disponível em " .. tostring(sec) .. " s.", pl, 255, 255, 255, true)
		return
	end
	setPedArmor(pl, 100)
	outputChatBox(pref("Kit") .. "#ffffffColete aplicado.", pl, 255, 255, 255, true)
end

local function cmdVipRepair(pl)
	if not needLogged(pl) then return end
	if not canRepair(pl) then
		outputChatBox(pref("Veículo") .. "#ffffffPrecisas de VIP Omega+ ou Sócio Ouro+.", pl, 255, 255, 255, true)
		return
	end
	local okCd, sec = cdOk(pl, "viprepair", 60000)
	if not okCd then
		outputChatBox(pref("Veículo") .. "#ffffffReparo VIP disponível em " .. tostring(sec) .. " s.", pl, 255, 255, 255, true)
		return
	end
	local veh = getPedOccupiedVehicle(pl)
	if not veh then
		outputChatBox(pref("Veículo") .. "#ffffffEntra num veículo como condutor.", pl, 255, 255, 255, true)
		return
	end
	fixVehicle(veh)
	setElementHealth(veh, 1000)
	outputChatBox(pref("Veículo") .. "#ffffffVeículo reparado.", pl, 255, 255, 255, true)
end

--[[ /tunning — VIP Omega+ / Sócio Ouro+; delega para /tuning do dude_scripts se o recurso existir ]]
local function cmdVipTuning(pl)
	if not needLogged(pl) then
		return
	end
	if tonumber(getElementData(pl, "user:admin") or 0) >= 7 then
		outputChatBox(pref("Tuning") .. "#ffffffComo admin usa as ferramentas de staff.", pl, 255, 255, 255, true)
		return
	end
	if not canRepair(pl) then
		outputChatBox(pref("Tuning") .. "#ffffffPrecisas de VIP Omega+ ou Sócio Ouro+.", pl, 255, 255, 255, true)
		return
	end
	local res = getResourceFromName("dude_scripts")
	if not res or getResourceState(res) ~= "running" then
		outputChatBox(pref("Tuning") .. "#ffffffTuning indisponível (recurso dude_scripts inativo).", pl, 255, 255, 255, true)
		return
	end
	local veh = getPedOccupiedVehicle(pl)
	if not veh then
		outputChatBox(pref("Tuning") .. "#ffffffEntra num veículo como condutor.", pl, 255, 255, 255, true)
		return
	end
	if getVehicleController(veh) ~= pl then
		outputChatBox(pref("Tuning") .. "#ffffffSó o condutor pode usar tuning.", pl, 255, 255, 255, true)
		return
	end
	local okCd, sec = cdOk(pl, "viptunning", 120000)
	if not okCd then
		outputChatBox(pref("Tuning") .. "#ffffffAguarda " .. tostring(sec) .. " s entre tunings.", pl, 255, 255, 255, true)
		return
	end
	local okT, errT = exports.dude_scripts:applySafeVehicleTuning(pl)
	if not okT then
		if cooldowns[pl] then
			cooldowns[pl]["viptunning"] = nil
		end
		outputChatBox(pref("Tuning") .. "#ffffff" .. tostring(errT or "Falha ao aplicar tuning."), pl, 255, 255, 255, true)
		return
	end
	vipLogAdminCmd(getPlayerName(pl):gsub("_", " "), "-", "/tunning")
	outputChatBox(pref("Tuning") .. "#ffffffTuning cosmético aplicado (upgrades compatíveis).", pl, 255, 255, 255, true)
end

--[[ /spectar [jogador] — pedido IC; alvo /aceitarspectar; /parspectar ou /spectar sem args para sair ]]
local function cmdSpectar(pl, _, partial)
	if not needLogged(pl) then
		return
	end
	if tonumber(getElementData(pl, "user:admin") or 0) >= 7 then
		outputChatBox(pref("Spectate") .. "#ffffffStaff: usa /recon e ferramentas de admin.", pl, 255, 255, 255, true)
		return
	end
	if not canRequestStaffTp(pl) then
		outputChatBox(pref("Spectate") .. "#ffffffDisponível para VIP Ipiranga ou Sócio Patrocinador.", pl, 255, 255, 255, true)
		return
	end
	partial = partial and tostring(partial):gsub("^%s+", ""):gsub("%s+$", "") or ""
	if partial == "" then
		if getElementData(pl, "vip:reconTarget") then
			vipReconEnd(pl)
			return
		end
		outputChatBox(
			pref("Spectate") .. "#ffffffUso: /spectar [jogador] — o alvo aceita com /aceitarspectar. /parspectar para sair.",
			pl,
			255,
			255,
			255,
			true
		)
		return
	end
	local tgt = select(1, core:getPlayerFromPartialName(pl, partial, true))
	if not tgt then
		outputChatBox(pref("Spectate") .. "#ffffffJogador não encontrado.", pl, 255, 255, 255, true)
		return
	end
	if tgt == pl then
		return
	end
	if getElementData(pl, "vip:reconTarget") then
		outputChatBox(pref("Spectate") .. "#ffffffSai primeiro com /parspectar.", pl, 255, 255, 255, true)
		return
	end
	if getElementData(tgt, "vip:watchedBy") or getElementData(tgt, "recon:reconerPlayer") then
		outputChatBox(pref("Spectate") .. "#ffffffEsse jogador já está a ser observado.", pl, 255, 255, 255, true)
		return
	end
	for tEl, pend in pairs(pendingSpectate) do
		if pend and pend.from == pl then
			pendingSpectate[tEl] = nil
		end
	end
	pendingSpectate[tgt] = { from = pl, expires = getTickCount() + 60000 }
	outputChatBox(
		pref("Spectate") .. "#ffffffPediste observar " .. getPlayerName(tgt):gsub("_", " ") .. ". Aguarda /aceitarspectar.",
		pl,
		255,
		255,
		255,
		true
	)
	outputChatBox(
		pref("Spectate")
			.. "#ffffff"
			.. getPlayerName(pl):gsub("_", " ")
			.. " pede espectador IC (VIP). /aceitarspectar ou ignora.",
		tgt,
		255,
		255,
		255,
		true
	)
end

local function cmdAcceptSpectar(pl)
	if not needLogged(pl) then
		return
	end
	local p = pendingSpectate[pl]
	if not p or not isElement(p.from) then
		outputChatBox(pref("Spectate") .. "#ffffffNão tens pedido de espectador pendente.", pl, 255, 255, 255, true)
		return
	end
	if getTickCount() > p.expires then
		pendingSpectate[pl] = nil
		outputChatBox(pref("Spectate") .. "#ffffffO pedido expirou.", pl, 255, 255, 255, true)
		return
	end
	local watcher = p.from
	pendingSpectate[pl] = nil
	vipLogAdminCmd(
		getPlayerName(watcher):gsub("_", " "),
		getPlayerName(pl):gsub("_", " "),
		"SPECTAR_IC"
	)
	vipReconStart(watcher, pl)
	outputChatBox(pref("Spectate") .. "#ffffff" .. getPlayerName(pl):gsub("_", " ") .. " aceitou o espectador.", watcher, 255, 255, 255, true)
	outputChatBox(pref("Spectate") .. "#ffffffPedido aceite.", pl, 255, 255, 255, true)
end

local function cmdParSpectar(pl)
	if not needLogged(pl) then
		return
	end
	if not getElementData(pl, "vip:reconTarget") then
		outputChatBox(pref("Spectate") .. "#ffffffNão estás em modo espectador VIP.", pl, 255, 255, 255, true)
		return
	end
	vipReconEnd(pl)
end

--[[ /tpp [jogador] — pedido IC: alvo tem de aceitar com /aceitartpp ]]
local function cmdVipTpp(pl, _, partial)
	if not needLogged(pl) then return end
	if not canRequestStaffTp(pl) then
		outputChatBox(pref("TP") .. "#ffffffDisponível para VIP Ipiranga ou Sócio Patrocinador.", pl, 255, 255, 255, true)
		return
	end
	local tgt = select(1, core:getPlayerFromPartialName(pl, tostring(partial or ""):gsub("^%s+", ""):gsub("%s+$", ""), true))
	if not tgt then
		outputChatBox(pref("TP") .. "#ffffffUso: /tpp [jogador] — o alvo deve aceitar com /aceitartpp", pl, 255, 255, 255, true)
		return
	end
	if tgt == pl then return end
	pendingTpp[tgt] = { from = pl, expires = getTickCount() + 60000 }
	outputChatBox(pref("TP") .. "#ffffffPediste teleporte até " .. getPlayerName(tgt):gsub("_", " ") .. ". Aguarda aceitação.", pl, 255, 255, 255, true)
	outputChatBox(pref("TP") .. "#ffffff" .. getPlayerName(pl):gsub("_", " ") .. " pede teleporte até ti (VIP). /aceitartpp ou ignora.", tgt, 255, 255, 255, true)
end

local function cmdAcceptTpp(pl)
	if not needLogged(pl) then return end
	local p = pendingTpp[pl]
	if not p or not isElement(p.from) then
		outputChatBox(pref("TP") .. "#ffffffNão tens nenhum pedido pendente.", pl, 255, 255, 255, true)
		return
	end
	if getTickCount() > p.expires then
		pendingTpp[pl] = nil
		outputChatBox(pref("TP") .. "#ffffffO pedido expirou.", pl, 255, 255, 255, true)
		return
	end
	local from = p.from
	pendingTpp[pl] = nil
	local x, y, z = getElementPosition(pl)
	local int, dim = getElementInterior(pl), getElementDimension(pl)
	setElementPosition(from, x + 1.2, y, z)
	setElementInterior(from, int)
	setElementDimension(from, dim)
	outputChatBox(pref("TP") .. "#ffffff" .. getPlayerName(pl):gsub("_", " ") .. " aceitou o teu teleporte.", from, 255, 255, 255, true)
	outputChatBox(pref("TP") .. "#ffffffTeleporte concluído.", pl, 255, 255, 255, true)
end

addCommandHandler("cv", cmdVipCv)
addCommandHandler("vipcv", cmdVipCv)
addCommandHandler("pskin", cmdVipPskin)
addCommandHandler("vippskin", cmdVipPskin)
addCommandHandler("vipheal", cmdVipHeal)
addCommandHandler("viparmor", cmdVipArmor)
addCommandHandler("viprepair", cmdVipRepair)
addCommandHandler("tpp", cmdVipTpp)
addCommandHandler("viptpp", cmdVipTpp)
addCommandHandler("aceitartpp", cmdAcceptTpp)

--[[ /tppa [jogador] — pedir que o jogador venha até ti (aceita com /aceitarpull) ]]
local function cmdVipTppa(pl, _, partial)
	if not needLogged(pl) then return end
	if not canRequestStaffTp(pl) then
		outputChatBox(pref("TP") .. "#ffffffDisponível para VIP Ipiranga ou Sócio Patrocinador.", pl, 255, 255, 255, true)
		return
	end
	local tgt = select(1, core:getPlayerFromPartialName(pl, tostring(partial or ""):gsub("^%s+", ""):gsub("%s+$", ""), true))
	if not tgt then
		outputChatBox(pref("TP") .. "#ffffffUso: /tppa [jogador] — o alvo usa /aceitarpull", pl, 255, 255, 255, true)
		return
	end
	if tgt == pl then return end
	pendingPull[tgt] = { to = pl, expires = getTickCount() + 60000 }
	outputChatBox(pref("TP") .. "#ffffffPediste que " .. getPlayerName(tgt):gsub("_", " ") .. " venha até ti.", pl, 255, 255, 255, true)
	outputChatBox(pref("TP") .. "#ffffff" .. getPlayerName(pl):gsub("_", " ") .. " pede que vás até ele (VIP). /aceitarpull", tgt, 255, 255, 255, true)
end

local function cmdAcceptPull(pl)
	if not needLogged(pl) then return end
	local p = pendingPull[pl]
	if not p or not isElement(p.to) then
		outputChatBox(pref("TP") .. "#ffffffNão tens pedido de pull pendente.", pl, 255, 255, 255, true)
		return
	end
	if getTickCount() > p.expires then
		pendingPull[pl] = nil
		outputChatBox(pref("TP") .. "#ffffffO pedido expirou.", pl, 255, 255, 255, true)
		return
	end
	local dest = p.to
	pendingPull[pl] = nil
	local x, y, z = getElementPosition(dest)
	local int, dim = getElementInterior(dest), getElementDimension(dest)
	setElementPosition(pl, x + 1.2, y, z)
	setElementInterior(pl, int)
	setElementDimension(pl, dim)
	outputChatBox(pref("TP") .. "#ffffff" .. getPlayerName(pl):gsub("_", " ") .. " aceitou ir até ti.", dest, 255, 255, 255, true)
	outputChatBox(pref("TP") .. "#ffffffFoste teleportado.", pl, 255, 255, 255, true)
end

addCommandHandler("tppa", cmdVipTppa)
addCommandHandler("viptppa", cmdVipTppa)
addCommandHandler("aceitarpull", cmdAcceptPull)

addCommandHandler("spectar", cmdSpectar)
addCommandHandler("vipspectar", cmdSpectar)
addCommandHandler("aceitarspectar", cmdAcceptSpectar)
addCommandHandler("parspectar", cmdParSpectar)
addCommandHandler("stopvipspectar", cmdParSpectar)
addCommandHandler("tunning", cmdVipTuning)
addCommandHandler("viptunning", cmdVipTuning)

addCommandHandler("eventovip", function(pl)
	if not needLogged(pl) then return end
	if getVipTierRank(pl) < 2 and getSocioTierRank(pl) < 2 then
		outputChatBox(pref("Evento") .. "#ffffffPrecisas de VIP Omega ou Sócio Ouro+.", pl, 255, 255, 255, true)
		return
	end
	outputChatBox(pref("Evento") .. "#ffffffPara eventos oficiais abre ticket staff ou usa mecânicas de facção. (Comando reservado — integração futura.)", pl, 255, 255, 255, true)
end)
