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

local function trimPartial(s)
	return (tostring(s or ""):match("^%s*(.-)%s*$")) or ""
end

--- Usa nomsg=true para não duplicar lista no chat; retorna apenas o elemento jogador.
local function resolveTarget(admin, partial)
	local p = trimPartial(partial)
	if p == "" then
		return nil, "Indica o alvo."
	end
	local elem = select(1, core:getPlayerFromPartialName(admin, p, true))
	if not elem or not isElement(elem) then
		return nil, "Jogador não encontrado ou várias correspondências — usa nome mais específico ou playerid/char:id."
	end
	if not getElementData(elem, "user:loggedin") then
		return nil, "Jogador não está logado."
	end
	return elem
end

--- MTA: executeCommandHandler só aceita uma string de argumentos após o jogador (tokens separados por espaço).
local function execCmd(admin, cmd, ...)
	local n = select("#", ...)
	local parts = {}
	for i = 1, n do
		parts[i] = tostring(select(i, ...))
	end
	return executeCommandHandler(cmd, admin, table.concat(parts, " "))
end

--- Playerid (preferencial) ou char:id — evita nomes com espaços ao encadear comandos.
local function resolveExecTarget(admin, partial)
	local elem, err = resolveTarget(admin, partial)
	if not elem then
		return nil, err
	end
	local pid = tonumber(getElementData(elem, "playerid"))
	if pid then
		return tostring(math.floor(pid)), elem
	end
	local cid = tonumber(getElementData(elem, "char:id"))
	if cid then
		return tostring(math.floor(cid)), elem
	end
	return nil, "Alvo sem playerid/char:id."
end

addEvent("adminHub > snapshot", true)
addEventHandler("adminHub > snapshot", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub > snapshotResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "adminhub", true) then
		triggerClientEvent(admin, "adminHub > snapshotResult", resourceRoot, false, "Sem permissão para o painel (adminhub).")
		return
	end
	if trimPartial(partial) == "" then
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
	if not client or getElementType(client) ~= "player" then return end
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
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "givemoney", tid, mode, math.floor(amount))
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Operação de dinheiro enviada.")
end)

addEvent("adminHub > setMoney", true)
addEventHandler("adminHub > setMoney", resourceRoot, function(partial, value)
	if not client or getElementType(client) ~= "player" then return end
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
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "setmoney", tid, math.floor(value))
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Dinheiro definido (comando executado).")
end)

addEvent("adminHub > givePP", true)
addEventHandler("adminHub > givePP", resourceRoot, function(partial, mode, amount)
	if not client or getElementType(client) ~= "player" then return end
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
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "givepp", tid, mode, math.floor(amount))
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "PP atualizado.")
end)

addEvent("adminHub > setPP", true)
addEventHandler("adminHub > setPP", resourceRoot, function(partial, value)
	if not client or getElementType(client) ~= "player" then return end
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
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "setpp", tid, math.floor(value))
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "PP definido.")
end)

addEvent("adminHub > giveCC", true)
addEventHandler("adminHub > giveCC", resourceRoot, function(partial, mode, amount)
	if not client or getElementType(client) ~= "player" then return end
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
	if not client or getElementType(client) ~= "player" then return end
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
	if not client or getElementType(client) ~= "player" then return end
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
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "giveitem", tid, item, value, math.floor(count), duty)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Pedido de item enviado.")
end)

addEvent("adminHub > getCatalog", true)
addEventHandler("adminHub > getCatalog", resourceRoot, function()
	if not client or getElementType(client) ~= "player" then return end
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
	if not client or getElementType(client) ~= "player" then return end
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
	if not client or getElementType(client) ~= "player" then return end
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
	if not client or getElementType(client) ~= "player" then return end
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
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "ajail", tid, math.floor(minutes), reason)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Comando admin jail executado.")
end)

addEvent("adminHub > unjail", true)
addEventHandler("adminHub > unjail", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
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
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "unjail", tid)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Unjail executado.")
end)

addEvent("adminHub > fixveh", true)
addEventHandler("adminHub > fixveh", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
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
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "fixveh", tid)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Comando fixveh enviado.")
end)

addEvent("adminHub > unflip", true)
addEventHandler("adminHub > unflip", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
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
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "unflip", tid)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Comando unflip enviado.")
end)

addEvent("adminHub > makeveh", true)
addEventHandler("adminHub > makeveh", resourceRoot, function(partial, modelId, isFaction, plate)
	if not client or getElementType(client) ~= "player" then return end
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
	plate = tostring(plate or ""):gsub("%s+", "")
	if plate == "" then plate = "HUB" .. tostring(math.random(100, 999)) end
	local targetTok = trimPartial(partial)
	if isFaction == 0 then
		local tid, terr = resolveExecTarget(admin, partial)
		if not tid then
			triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, false, terr)
			return
		end
		targetTok = tid
	end
	execCmd(admin, "makeveh", math.floor(modelId), targetTok, isFaction, 255, 255, 255, plate)
	triggerClientEvent(admin, "adminHub > actionResult", resourceRoot, true, "Comando makeveh enviado.")
end)

----------------------------------------------------------------
-- Admin Hub v2 — adminHub2 > *
----------------------------------------------------------------

local function pushWalletSnapshot(admin, target)
	if not isElement(target) then
		return
	end
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Operação concluída.", {
		money = tonumber(getElementData(target, "char:money")) or 0,
		pp = tonumber(getElementData(target, "char:pp")) or 0,
		cc = tonumber(getElementData(target, "char:cc")) or 0,
	})
end

local function parseRgbTriple(str)
	local r, g, b = 255, 255, 255
	local rs, gs, bs = tostring(str or ""):match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
	if rs then
		r = math.min(255, math.max(0, tonumber(rs) or r))
		g = math.min(255, math.max(0, tonumber(gs) or g))
		b = math.min(255, math.max(0, tonumber(bs) or b))
	end
	return r, g, b
end

addEvent("adminHub2 > snapshot", true)
addEventHandler("adminHub2 > snapshot", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "adminhub", true) then
		triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, false, "Sem permissão para o painel (adminhub).")
		return
	end
	if trimPartial(partial) == "" then
		triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, false, "Indica o alvo.")
		return
	end
	local target, terr = resolveTarget(admin, partial)
	if not target then
		triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, false, terr)
		return
	end

	local bankSerial, bankMoney = false, 0
	local ob = getResourceFromName("oBank")
	if ob and getResourceState(ob) == "running" and exports.oBank and exports.oBank.getMainBankAccountForChar then
		local cid = getElementData(target, "char:id")
		local okb, a, bv = pcall(function()
			return exports.oBank:getMainBankAccountForChar(cid)
		end)
		if okb and a and a ~= false then
			bankSerial, bankMoney = a, tonumber(bv) or 0
		end
	end

	local fid = tonumber(getElementData(target, "char:mainFaction")) or 0
	local factionName = fid > 0 and ("Facção #" .. tostring(fid)) or ""

	triggerClientEvent(admin, "adminHub2 > snapshotResult", resourceRoot, true, {
		name = getElementData(target, "char:name") or getPlayerName(target),
		charId = getElementData(target, "char:id"),
		userId = getElementData(target, "user:id"),
		money = tonumber(getElementData(target, "char:money")) or 0,
		pp = tonumber(getElementData(target, "char:pp")) or 0,
		cc = tonumber(getElementData(target, "char:cc")) or 0,
		bankSerial = bankSerial,
		bankMoney = bankMoney,
		online = true,
		ajailed = getElementData(target, "adminJail.IsAdminJail") == true,
		onDuty = (tonumber(getElementData(target, "char:duty:faction")) or 0) > 0,
		inVeh = isElement(getPedOccupiedVehicle(target)),
		faction = factionName,
		factionRank = "",
	})
end)

addEvent("adminHub2 > getCatalog", true)
addEventHandler("adminHub2 > getCatalog", resourceRoot, function()
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > catalogResult", resourceRoot, {})
		return
	end
	local inv = getResourceFromName("oInventory")
	if not inv or getResourceState(inv) ~= "running" or not exports.oInventory or not exports.oInventory.getItemCatalogMini then
		triggerClientEvent(admin, "adminHub2 > catalogResult", resourceRoot, {})
		return
	end
	triggerClientEvent(admin, "adminHub2 > catalogResult", resourceRoot, exports.oInventory:getItemCatalogMini() or {})
end)

addEvent("adminHub2 > economy", true)
addEventHandler("adminHub2 > economy", resourceRoot, function(partial, econType, econMode, value)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	value = tonumber(value)
	econType = tonumber(econType)
	econMode = tonumber(econMode)
	if not value or value < 0 or not econType or not econMode then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Dados inválidos.")
		return
	end

	if econType == 1 then
		local tid, trec = resolveExecTarget(admin, partial)
		if not tid then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, trec)
			return
		end
		if econMode == 3 then
			if not exports.oAdmin:hasPermission(admin, "setmoney", true) then
				triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (setmoney).")
				return
			end
			execCmd(admin, "setmoney", tid, math.floor(value))
		else
			if not exports.oAdmin:hasPermission(admin, "givemoney", true) then
				triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (givemoney).")
				return
			end
			execCmd(admin, "givemoney", tid, econMode, math.floor(value))
		end
		if trec then pushWalletSnapshot(admin, trec) end

	elseif econType == 2 then
		if not exports.oAdmin:hasPermission(admin, "givemoney", true) then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Casino Coin: requer givemoney.")
			return
		end
		local target, terr = resolveTarget(admin, partial)
		if not target then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
			return
		end
		local cur = tonumber(getElementData(target, "char:cc")) or 0
		local newv
		if econMode == 1 then newv = cur + math.floor(value)
		elseif econMode == 2 then newv = math.max(0, cur - math.floor(value))
		else newv = math.floor(value) end
		setElementData(target, "char:cc", newv)
		outputChatBox(core:getServerPrefix("server", "Admin", 1) .. color .. getElementData(admin, "user:adminnick") .. " #ffffffajustou os teus Casino Coins.", target, 255, 255, 255, true)
		sendMessageToAdmins(admin, "ajustou CC de " .. (getElementData(target, "char:name") or "?") .. " para " .. newv .. ".", 7)
		setElementData(admin, "log:admincmd", { getElementData(target, "char:id"), "adminhub2_cc" })
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "CC: " .. newv, { cc = newv })

	elseif econType == 3 then
		local tid, trec = resolveExecTarget(admin, partial)
		if not tid then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, trec)
			return
		end
		if econMode == 3 then
			if not exports.oAdmin:hasPermission(admin, "setpp", true) then
				triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (setpp).")
				return
			end
			execCmd(admin, "setpp", tid, math.floor(value))
		else
			if not exports.oAdmin:hasPermission(admin, "givepp", true) then
				triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (givepp).")
				return
			end
			execCmd(admin, "givepp", tid, econMode, math.floor(value))
		end
		if trec then pushWalletSnapshot(admin, trec) end

	elseif econType == 4 then
		if not exports.oAdmin:hasPermission(admin, "givemoney", true) then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Banco: requer givemoney.")
			return
		end
		local target, terr = resolveTarget(admin, partial)
		if not target then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
			return
		end
		local ob = getResourceFromName("oBank")
		if not ob or getResourceState(ob) ~= "running" or not exports.oBank then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "oBank indisponível.")
			return
		end
		local cid = getElementData(target, "char:id")
		local okb, serial, bal = pcall(function()
			return exports.oBank:getMainBankAccountForChar(cid)
		end)
		if not okb or not serial or serial == false then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Jogador sem conta principal.")
			return
		end
		local flo = math.floor(value)
		local ok2, newb
		if econMode == 3 then
			ok2, newb = exports.oBank:adminHubSetBankBalance(tostring(serial), flo)
		elseif econMode == 2 then
			ok2, newb = exports.oBank:adminHubAdjustBankBalance(tostring(serial), -flo)
		else
			ok2, newb = exports.oBank:adminHubAdjustBankBalance(tostring(serial), flo)
		end
		if not ok2 then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, tostring(newb or "Erro banco."))
			return
		end
		sendMessageToAdmins(admin, "ajustou saldo bancário (conta " .. tostring(serial) .. "). Novo: $" .. tostring(newb), 7)
		setElementData(admin, "log:admincmd", { 0, "adminhub2_bank" })
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Banco: $" .. tostring(newb), { bankMoney = tonumber(newb) or newb, bankSerial = serial })
	else
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Tipo económico inválido.")
	end
end)

addEvent("adminHub2 > bank", true)
addEventHandler("adminHub2 > bank", resourceRoot, function(partial, modeNum, value)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	value = tonumber(value)
	modeNum = tonumber(modeNum)
	if not partial or not value or value < 0 or not modeNum or modeNum < 1 or modeNum > 3 then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Dados inválidos.")
		return
	end
	if not exports.oAdmin:hasPermission(admin, "givemoney", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Banco: requer givemoney.")
		return
	end
	local target, terr = resolveTarget(admin, partial)
	if not target then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	local ob = getResourceFromName("oBank")
	if not ob or getResourceState(ob) ~= "running" or not exports.oBank then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "oBank indisponível.")
		return
	end
	local cid = getElementData(target, "char:id")
	local okb, serial, bal = pcall(function()
		return exports.oBank:getMainBankAccountForChar(cid)
	end)
	if not okb or not serial or serial == false then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Jogador sem conta principal.")
		return
	end
	local flo = math.floor(value)
	local ok2, newb
	if modeNum == 3 then
		ok2, newb = exports.oBank:adminHubSetBankBalance(tostring(serial), flo)
	elseif modeNum == 2 then
		ok2, newb = exports.oBank:adminHubAdjustBankBalance(tostring(serial), -flo)
	else
		ok2, newb = exports.oBank:adminHubAdjustBankBalance(tostring(serial), flo)
	end
	if not ok2 then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, tostring(newb or "Erro banco."))
		return
	end
	sendMessageToAdmins(admin, "ajustou saldo bancário (conta " .. tostring(serial) .. "). Novo: $" .. tostring(newb), 7)
	setElementData(admin, "log:admincmd", { 0, "adminhub2_bank" })
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Banco: $" .. tostring(newb), { bankMoney = tonumber(newb) or newb, bankSerial = serial })
end)

addEvent("adminHub2 > kick", true)
addEventHandler("adminHub2 > kick", resourceRoot, function(partial, reason)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "kick", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (kick).")
		return
	end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	reason = tostring(reason or "Kick administrativo")
	execCmd(admin, "akick", tid, reason)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Kick enviado.")
end)

addEvent("adminHub2 > warn", true)
addEventHandler("adminHub2 > warn", resourceRoot, function(partial, reason)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "kick", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão.")
		return
	end
	local target, terr = resolveTarget(admin, partial)
	if not target then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	reason = tostring(reason or "Aviso administrativo")
	outputChatBox(exports.oCore:getServerPrefix("server", "Admin", 1) .. "#ff6666Aviso admin: #ffffff" .. reason, target, 255, 255, 255, true)
	sendMessageToAdmins(admin, "avisou " .. (getElementData(target, "char:name") or "?") .. ": " .. reason, 2)
	setElementData(admin, "log:admincmd", { getElementData(target, "char:id"), "adminhub2_warn" })
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Aviso enviado.")
end)

addEvent("adminHub2 > mute", true)
addEventHandler("adminHub2 > mute", resourceRoot, function(partial, minutes, reason)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "kick", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão.")
		return
	end
	minutes = tonumber(minutes)
	if not minutes or minutes < 1 then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Minutos inválidos.")
		return
	end
	local target, terr = resolveTarget(admin, partial)
	if not target then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	reason = tostring(reason or "Mute administrativo")
	local ts = getRealTime().timestamp + math.floor(minutes * 60)
	setElementData(target, "adminChatMuteUntil", ts, true)
	outputChatBox(exports.oCore:getServerPrefix("red-dark", "Admin", 3) .. "Foste silenciado no chat por ~" .. math.floor(minutes) .. " min. Motivo: " .. reason, target, 255, 255, 255, true)
	sendMessageToAdmins(admin, "silenciou chat de " .. (getElementData(target, "char:name") or "?") .. " (" .. minutes .. " min).", 3)
	setElementData(admin, "log:admincmd", { getElementData(target, "char:id"), "adminhub2_mute" })
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Mute aplicado.")
end)

addEvent("adminHub2 > ban", true)
addEventHandler("adminHub2 > ban", resourceRoot, function(partial, durationHours, reason)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "aban", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (aban).")
		return
	end
	durationHours = tonumber(durationHours) or 0
	reason = tostring(reason or "")
	if reason == "" then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Motivo obrigatório.")
		return
	end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "aban", tid, durationHours, reason)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Ban processado (comando).")
end)

addEvent("adminHub2 > ajail", true)
addEventHandler("adminHub2 > ajail", resourceRoot, function(partial, minutes, reason)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "ajail", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (ajail).")
		return
	end
	minutes = tonumber(minutes)
	reason = tostring(reason or "")
	if not partial or not minutes or minutes < 1 or reason == "" then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Indica jogador, minutos (>0) e motivo.")
		return
	end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "ajail", tid, math.floor(minutes), reason)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "AJail executado.")
end)

addEvent("adminHub2 > unjail", true)
addEventHandler("adminHub2 > unjail", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "unjail", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (unjail).")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "unjail", tid)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Unjail executado.")
end)

addEvent("adminHub2 > giveItem", true)
addEventHandler("adminHub2 > giveItem", resourceRoot, function(partial, item, val, count, duty)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "giveitem", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (giveitem).")
		return
	end
	item = tonumber(item)
	count = tonumber(count)
	duty = tonumber(duty)
	if not partial or not item or not count or count < 1 then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Item / quantidade inválidos.")
		return
	end
	val = tostring(val or "1")
	if duty ~= 0 and duty ~= 1 then duty = 0 end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "giveitem", tid, item, val, math.floor(count), duty)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Item enviado.")
end)

addEvent("adminHub2 > makeveh", true)
addEventHandler("adminHub2 > makeveh", resourceRoot, function(partial, modelId, isFaction, plate, colorStr)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "makeveh", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (makeveh).")
		return
	end
	modelId = tonumber(modelId)
	isFaction = tonumber(isFaction) or 0
	if isFaction > 1 then isFaction = 0 end
	if not partial or not modelId then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Modelo e alvo obrigatórios.")
		return
	end
	plate = tostring(plate or ""):gsub("%s+", "")
	if plate == "" then plate = "HUB" .. tostring(math.random(100, 999)) end
	local r, g, b = parseRgbTriple(colorStr)
	local targetTok = trimPartial(partial)
	if isFaction == 0 then
		local tid, terr = resolveExecTarget(admin, partial)
		if not tid then
			triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
			return
		end
		targetTok = tid
	end
	execCmd(admin, "makeveh", math.floor(modelId), targetTok, isFaction, r, g, b, plate)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Makeveh enviado.")
end)

addEvent("adminHub2 > fixveh", true)
addEventHandler("adminHub2 > fixveh", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "fixveh", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão.")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "fixveh", tid)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Fixveh enviado.")
end)

addEvent("adminHub2 > unflip", true)
addEventHandler("adminHub2 > unflip", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "unflip", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão.")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "unflip", tid)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Unflip enviado.")
end)

addEvent("adminHub2 > teleport", true)
addEventHandler("adminHub2 > teleport", resourceRoot, function(partial, mode)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	mode = tonumber(mode) or 1
	local cmd = (mode == 2) and "gethere" or "goto"
	if not exports.oAdmin:hasPermission(admin, cmd, true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (" .. cmd .. ").")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, cmd, tid)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Teleporte enviado.")
end)

addEvent("adminHub2 > heal", true)
addEventHandler("adminHub2 > heal", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "sethp", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão (sethp).")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "sethp", tid, "100")
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "HP definido.")
end)

addEvent("adminHub2 > freeze", true)
addEventHandler("adminHub2 > freeze", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "freeze", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão.")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	local tid, terr = resolveExecTarget(admin, partial)
	if not tid then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, terr)
		return
	end
	execCmd(admin, "freeze", tid)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Freeze enviado.")
end)

addEvent("adminHub2 > showinv", true)
addEventHandler("adminHub2 > showinv", resourceRoot, function(partial)
	if not client or getElementType(client) ~= "player" then return end
	local admin = client
	refreshColor()
	local ok, err = adminGate(admin)
	if not ok then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, err)
		return
	end
	if not exports.oAdmin:hasPermission(admin, "showinv", true) then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Sem permissão.")
		return
	end
	if not partial or partial == "" then
		triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, false, "Indica o jogador.")
		return
	end
	triggerClientEvent(admin, "adminHub2 > openShowinv", resourceRoot, partial)
	triggerClientEvent(admin, "adminHub2 > actionResult", resourceRoot, true, "Abrindo inventário (cliente).")
end)
