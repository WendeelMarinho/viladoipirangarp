--[[
  Painel Admin Hub — ações validadas no servidor (mesmas regras que /givemoney, /giveitem, etc.)
]]

local core = exports.oCore
local color, r, g, b = core:getServerColor()

local function refreshColor()
	core = exports.oCore
	color, r, g, b = core:getServerColor()
end

local function adminGate(player)
	if not isPlayerInAdminDuty(player) then
		return false, "Entra em serviço admin (/aduty) para usar o painel."
	end
	if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(player) then
		return false, "Conta admin não verificada."
	end
	return true
end

local function resolveTarget(admin, partial)
	local t = core:getPlayerFromPartialName(admin, partial)
	if not t or not isElement(t) then
		return nil, "Jogador não encontrado."
	end
	if not getElementData(t, "user:loggedin") then
		return nil, "Jogador não está logado."
	end
	return t
end

addEvent("adminHub > snapshot", true)
addEventHandler("adminHub > snapshot", resourceRoot, function(partial)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > snapshotResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "showinv", true) then
		triggerClientEvent(admin, "adminHub > snapshotResult", resourceRoot, false, "Sem permissão para consultar jogadores (showinv).")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub > snapshotResult", resourceRoot, false, "Indica ID ou parte do nome.")
		return
	end
	local target, terr = resolveTarget(admin, partial)
	if not target then
		triggerClientEvent(admin, "adminHub > snapshotResult", resourceRoot, false, terr)
		return
	end
	local bankSerial, bankMoney, bankAccId = false, 0, false
	local ob = getResourceFromName("oBank")
	if ob and getResourceState(ob) == "running" and exports.oBank and exports.oBank.getMainBankAccountForChar then
		local cid = getElementData(target, "char:id")
		local ok, a, b, c = pcall(function()
			return exports.oBank:getMainBankAccountForChar(cid)
		end)
		if ok and a and a ~= false then
			bankSerial, bankMoney, bankAccId = a, tonumber(b) or 0, c
		end
	end

	triggerClientEvent(admin, "adminHub > snapshotResult", resourceRoot, true, {
		name = getElementData(target, "char:name") or getPlayerName(target),
		charId = getElementData(target, "char:id"),
		userId = getElementData(target, "user:id"),
		money = tonumber(getElementData(target, "char:money")) or 0,
		pp = tonumber(getElementData(target, "char:pp")) or 0,
		cc = tonumber(getElementData(target, "char:cc")) or 0,
		partial = tostring(getElementData(target, "playerid") or partial),
		bankSerial = bankSerial,
		bankMoney = bankMoney,
		bankAccId = bankAccId,
	})
end)

addEvent("adminHub > giveMoney", true)
addEventHandler("adminHub > giveMoney", resourceRoot, function(partial, mode, amount)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "givemoney", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (givemoney).")
		return
	end
	amount = tonumber(amount)
	mode = tonumber(mode)
	if not partial or not amount or not mode or (mode ~= 1 and mode ~= 2) or amount <= 0 then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Dados inválidos.")
		return
	end
	executeCommandHandler(admin, "givemoney", partial, tostring(mode), tostring(math.floor(amount)))
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Operação de dinheiro enviada.")
end)

addEvent("adminHub > setMoney", true)
addEventHandler("adminHub > setMoney", resourceRoot, function(partial, value)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "setmoney", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (setmoney).")
		return
	end
	value = tonumber(value)
	if not partial or value == nil or value < 0 then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Valor inválido.")
		return
	end
	executeCommandHandler(admin, "setmoney", partial, tostring(math.floor(value)))
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Dinheiro definido (comando executado).")
end)

addEvent("adminHub > givePP", true)
addEventHandler("adminHub > givePP", resourceRoot, function(partial, mode, amount)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "givepp", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (givepp).")
		return
	end
	amount = tonumber(amount)
	mode = tonumber(mode)
	if not partial or not amount or not mode or (mode ~= 1 and mode ~= 2) or amount <= 0 then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Dados inválidos.")
		return
	end
	executeCommandHandler(admin, "givepp", partial, tostring(mode), tostring(math.floor(amount)))
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "PP atualizado.")
end)

addEvent("adminHub > setPP", true)
addEventHandler("adminHub > setPP", resourceRoot, function(partial, value)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "setpp", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (setpp).")
		return
	end
	value = tonumber(value)
	if not partial or value == nil or value < 0 then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Valor inválido.")
		return
	end
	executeCommandHandler(admin, "setpp", partial, tostring(math.floor(value)))
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "PP definido.")
end)

addEvent("adminHub > giveCC", true)
addEventHandler("adminHub > giveCC", resourceRoot, function(partial, mode, amount)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "givemoney", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Casino Coin: usa o mesmo nível que givemoney.")
		return
	end
	local target, terr = resolveTarget(admin, partial)
	if not target then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	amount = tonumber(amount)
	mode = tonumber(mode)
	if not amount or not mode or (mode ~= 1 and mode ~= 2) or amount <= 0 then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Dados inválidos.")
		return
	end
	local cur = tonumber(getElementData(target, "char:cc")) or 0
	local newv = mode == 1 and (cur + math.floor(amount)) or (cur - math.floor(amount))
	if newv < 0 then newv = 0 end
	setElementData(target, "char:cc", newv)
	outputChatBox(core:getServerPrefix("server", "Admin", 1) .. color .. getElementData(admin, "user:adminnick") .. " #ffffffajustou os teus Casino Coins.", target, 255, 255, 255, true)
	sendMessageToAdmins(admin, "ajustou CC de " .. (getElementData(target, "char:name") or "?") .. " para " .. newv .. ".", 7)
	setElementData(admin, "log:admincmd", { getElementData(target, "char:id"), "adminhub_cc" })
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "CC definido: " .. newv)
end)

addEvent("adminHub > setCC", true)
addEventHandler("adminHub > setCC", resourceRoot, function(partial, value)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "givemoney", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Casino Coin: usa o mesmo nível que givemoney.")
		return
	end
	local target, terr = resolveTarget(admin, partial)
	if not target then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	value = tonumber(value)
	if value == nil or value < 0 then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Valor inválido.")
		return
	end
	local newv = math.floor(value)
	setElementData(target, "char:cc", newv)
	outputChatBox(core:getServerPrefix("server", "Admin", 1) .. color .. getElementData(admin, "user:adminnick") .. " #ffffffdefiniu os teus Casino Coins para " .. newv .. ".", target, 255, 255, 255, true)
	sendMessageToAdmins(admin, "definiu CC de " .. (getElementData(target, "char:name") or "?") .. " para " .. newv .. ".", 7)
	setElementData(admin, "log:admincmd", { getElementData(target, "char:id"), "adminhub_setcc" })
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "CC definido: " .. newv)
end)

addEvent("adminHub > giveItem", true)
addEventHandler("adminHub > giveItem", resourceRoot, function(partial, item, value, count, duty)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "giveitem", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (giveitem).")
		return
	end
	item = tonumber(item)
	count = tonumber(count)
	duty = tonumber(duty)
	if not partial or not item or not count or count < 1 then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Item / quantidade inválidos.")
		return
	end
	value = tostring(value or "1")
	if duty ~= 0 and duty ~= 1 then duty = 0 end
	executeCommandHandler(admin, "giveitem", partial, tostring(item), value, tostring(math.floor(count)), tostring(duty))
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Pedido de item enviado.")
end)

addEvent("adminHub > getCatalog", true)
addEventHandler("adminHub > getCatalog", resourceRoot, function()
	if client ~= source then return end
	local admin = client
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > catalogResult", resourceRoot, false)
		return
	end
	local inv = getResourceFromName("oInventory")
	if not inv or getResourceState(inv) ~= "running" or not exports.oInventory or not exports.oInventory.getItemCatalogMini then
		triggerClientEvent(admin, "adminHub > catalogResult", resourceRoot, {})
		return
	end
	local list = exports.oInventory:getItemCatalogMini() or {}
	triggerClientEvent(admin, "adminHub > catalogResult", resourceRoot, list)
end)

addEvent("adminHub > bankDelta", true)
addEventHandler("adminHub > bankDelta", resourceRoot, function(serial, delta)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "givemoney", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Banco: requer permissão givemoney (nível 7).")
		return
	end
	local ob = getResourceFromName("oBank")
	if not ob or getResourceState(ob) ~= "running" or not exports.oBank then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Recurso oBank indisponível.")
		return
	end
	local ok2, newb = exports.oBank:adminHubAdjustBankBalance(tostring(serial), tonumber(delta))
	if not ok2 then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, tostring(newb or "Erro banco."))
		return
	end
	sendMessageToAdmins(admin, "ajustou saldo bancário (conta " .. tostring(serial) .. ") em " .. tostring(delta) .. "$. Novo saldo: " .. tostring(newb) .. ".", 7)
	setElementData(admin, "log:admincmd", { 0, "adminhub_bank" })
	triggerClientEvent(admin, "adminHub > snapshotBank", resourceRoot, tostring(serial), tonumber(newb) or newb)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Saldo bancário: $" .. tostring(newb))
end)

addEvent("adminHub > bankSet", true)
addEventHandler("adminHub > bankSet", resourceRoot, function(serial, value)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "givemoney", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Banco: requer permissão givemoney.")
		return
	end
	if not getResourceFromName("oBank") or getResourceState(getResourceFromName("oBank")) ~= "running" or not exports.oBank then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Recurso oBank indisponível.")
		return
	end
	local ok2, newb = exports.oBank:adminHubSetBankBalance(tostring(serial), tonumber(value))
	if not ok2 then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, tostring(newb or "Erro."))
		return
	end
	sendMessageToAdmins(admin, "definiu saldo bancário (conta " .. tostring(serial) .. ") para $" .. tostring(newb) .. ".", 7)
	setElementData(admin, "log:admincmd", { 0, "adminhub_bankset" })
	triggerClientEvent(admin, "adminHub > snapshotBank", resourceRoot, tostring(serial), tonumber(newb) or newb)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Saldo bancário definido: $" .. tostring(newb))
end)

addEvent("adminHub > ajail", true)
addEventHandler("adminHub > ajail", resourceRoot, function(partial, minutes, reason)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "ajail", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (ajail).")
		return
	end
	minutes = tonumber(minutes)
	reason = tostring(reason or "Admin Hub")
	if not partial or not minutes or minutes < 1 or reason == "" then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Indica jogador, minutos (>0) e motivo.")
		return
	end
	executeCommandHandler(admin, "ajail", partial, tostring(math.floor(minutes)), reason)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Comando admin jail executado.")
end)

addEvent("adminHub > unjail", true)
addEventHandler("adminHub > unjail", resourceRoot, function(partial)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "unjail", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (unjail).")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	executeCommandHandler(admin, "unjail", partial)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Unjail executado.")
end)

addEvent("adminHub > fixveh", true)
addEventHandler("adminHub > fixveh", resourceRoot, function(partial)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "fixveh", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (fixveh).")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	executeCommandHandler(admin, "fixveh", partial)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Comando fixveh enviado.")
end)

addEvent("adminHub > unflip", true)
addEventHandler("adminHub > unflip", resourceRoot, function(partial)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "unflip", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (unflip).")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	executeCommandHandler(admin, "unflip", partial)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Comando unflip enviado.")
end)

addEvent("adminHub > makeveh", true)
addEventHandler("adminHub > makeveh", resourceRoot, function(partial, modelId, isFaction, plate)
	if client ~= source then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "makeveh", true) then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Sem permissão (makeveh).")
		return
	end
	modelId = tonumber(modelId)
	isFaction = tonumber(isFaction) or 0
	if isFaction > 1 then isFaction = 0 end
	if not partial or not modelId then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, "Modelo e jogador/facção obrigatórios.")
		return
	end
	plate = tostring(plate or "")
	if plate == "" then plate = "HUB" .. tostring(math.random(100, 999)) end
	executeCommandHandler(admin, "makeveh", tostring(modelId), partial, tostring(isFaction), "255", "255", "255", plate)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Comando makeveh enviado.")
end)
