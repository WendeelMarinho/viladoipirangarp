--[[ oIpirangaVIP — subscrições VIP / Sócio (DB + elementData + salário horário) ]]

local conn
local core = exports.oCore
local color = "#557ec9"

local function pref()
	return core:getServerPrefix("green-dark", "VIP", 3)
end

local function dbOk()
	return conn and conn ~= false
end

local function findTierInList(list, id)
	if type(list) ~= "table" or not id or id == "" then return nil end
	for _, t in ipairs(list) do
		if t.id == id then return t end
	end
	return nil
end

local function ensureSubscriptionsTable()
	if not dbOk() then return end
	dbExec(conn, [[
CREATE TABLE IF NOT EXISTS ipiranga_subscriptions (
	char_id INT UNSIGNED NOT NULL,
	line VARCHAR(8) NOT NULL,
	tier_id VARCHAR(32) NOT NULL DEFAULT '',
	expire_at INT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY (char_id, line)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
end

local function setVipElementData(pl, tierId, expireAt)
	tierId = tierId or ""
	expireAt = tonumber(expireAt) or 0
	setElementData(pl, "char:vip_tier", tierId == "" and false or tierId, true)
	setElementData(pl, "char:vip_expire", expireAt, true)
end

local function setSocioElementData(pl, tierId, expireAt)
	tierId = tierId or ""
	expireAt = tonumber(expireAt) or 0
	setElementData(pl, "char:socio_tier", tierId == "" and false or tierId, true)
	setElementData(pl, "char:socio_expire", expireAt, true)
end

local function clearLineElement(pl, line)
	if line == "vip" then
		setVipElementData(pl, "", 0)
	elseif line == "socio" then
		setSocioElementData(pl, "", 0)
	end
end

function isVipLineActive(pl, line)
	if not isElement(pl) or getElementType(pl) ~= "player" then return false end
	line = tostring(line or "")
	local now = os.time()
	if line == "vip" then
		local ex = tonumber(getElementData(pl, "char:vip_expire")) or 0
		local tid = getElementData(pl, "char:vip_tier")
		return ex > now and tid and tid ~= false and tid ~= ""
	end
	if line == "socio" then
		local ex = tonumber(getElementData(pl, "char:socio_expire")) or 0
		local tid = getElementData(pl, "char:socio_tier")
		return ex > now and tid and tid ~= false and tid ~= ""
	end
	return false
end

function getPlayerVipTierId(pl)
	if not isElement(pl) then return "" end
	local t = getElementData(pl, "char:vip_tier")
	if not t or t == false then return "" end
	return tostring(t)
end

function getPlayerSocioTierId(pl)
	if not isElement(pl) then return "" end
	local t = getElementData(pl, "char:socio_tier")
	if not t or t == false then return "" end
	return tostring(t)
end

local VIP_RANK = { vip_sigma = 1, vip_omega = 2, vip_ipiranga = 3 }
local SOC_RANK = { socio_semanal = 1, socio_mensal = 2, socio_patrocinador = 3 }

function getVipTierRank(pl)
	if not isVipLineActive(pl, "vip") then return 0 end
	return VIP_RANK[getPlayerVipTierId(pl)] or 0
end

function getSocioTierRank(pl)
	if not isVipLineActive(pl, "socio") then return 0 end
	return SOC_RANK[getPlayerSocioTierId(pl)] or 0
end

local function upsertSubscription(charId, line, tierId, expireAt)
	if not dbOk() then return false end
	charId = tonumber(charId)
	if not charId then return false end
	return dbExec(conn, [[
REPLACE INTO ipiranga_subscriptions (char_id, line, tier_id, expire_at) VALUES (?,?,?,?)
]], charId, line, tierId, expireAt)
end

--[[
	grantSubscription(player, "vip"|"socio", tierId, durationDays?)
	durationDays omitido → usa o do tier em vip_socio_config.
	Acrescenta tempo sobre a expiração atual (stack).
	Se tierId "" ou "off", remove a linha.
]]
function grantSubscription(pl, line, tierId, durationDays)
	if not isElement(pl) or getElementType(pl) ~= "player" then return false, "invalid_player" end
	line = tostring(line or "")
	if line ~= "vip" and line ~= "socio" then return false, "bad_line" end
	tierId = tostring(tierId or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local charId = tonumber(getElementData(pl, "char:id"))
	if not charId then return false, "no_char" end

	if tierId == "" or tierId == "off" or tierId == "none" then
		upsertSubscription(charId, line, "", 0)
		clearLineElement(pl, line)
		return true, "cleared"
	end

	local tier
	if line == "vip" then
		tier = findTierInList(IPiranga_VIP_TIERS, tierId)
	else
		tier = findTierInList(IPiranga_SOCIO_TIERS, tierId)
	end
	if not tier then return false, "unknown_tier" end

	local addDays = tonumber(durationDays) or tonumber(tier.durationDays) or 30
	local addSec = math.max(1, math.floor(addDays * 86400))
	local now = os.time()
	local curEx = 0
	if line == "vip" then
		curEx = tonumber(getElementData(pl, "char:vip_expire")) or 0
	else
		curEx = tonumber(getElementData(pl, "char:socio_expire")) or 0
	end
	local wasInactive = curEx < now
	local base = (curEx > now) and curEx or now
	local newEx = base + addSec

	upsertSubscription(charId, line, tierId, newEx)
	if line == "vip" then
		setVipElementData(pl, tierId, newEx)
	else
		setSocioElementData(pl, tierId, newEx)
	end

	local bonus = tonumber(tier.activationCash) or 0
	if bonus > 0 and wasInactive then
		local money = tonumber(getElementData(pl, "char:money")) or 0
		setElementData(pl, "char:money", money + bonus, true)
	end

	return true, "ok"
end

local function loadSubscriptionsForPlayer(pl)
	if not dbOk() or not isElement(pl) then return end
	local charId = tonumber(getElementData(pl, "char:id"))
	if not charId then return end
	dbQuery(function(qh)
		if not isElement(pl) then return end
		local rows = dbPoll(qh, 800) or {}
		local gotVip, gotSoc = false, false
		for _, row in ipairs(rows) do
			local line = tostring(row.line or "")
			local tid = tostring(row.tier_id or "")
			local ex = tonumber(row.expire_at) or 0
			if line == "vip" then
				setVipElementData(pl, tid, ex)
				gotVip = true
			elseif line == "socio" then
				setSocioElementData(pl, tid, ex)
				gotSoc = true
			end
		end
		if not gotVip then setVipElementData(pl, "", 0) end
		if not gotSoc then setSocioElementData(pl, "", 0) end
	end, conn, "SELECT line, tier_id, expire_at FROM ipiranga_subscriptions WHERE char_id = ?", charId)
end

local function hourlyPayout()
	if not dbOk() then return end
	for _, pl in ipairs(getElementsByType("player")) do
		if getElementData(pl, "user:loggedin") then
			local pay = 0
			if isVipLineActive(pl, "vip") then
				local t = findTierInList(IPiranga_VIP_TIERS, getPlayerVipTierId(pl))
				if t then pay = pay + (tonumber(t.hourlySalary) or 0) end
			end
			if isVipLineActive(pl, "socio") then
				local t = findTierInList(IPiranga_SOCIO_TIERS, getPlayerSocioTierId(pl))
				if t then pay = pay + (tonumber(t.hourlySalary) or 0) end
			end
			if pay > 0 then
				local money = tonumber(getElementData(pl, "char:money")) or 0
				setElementData(pl, "char:money", money + pay, true)
				outputChatBox(pref() .. "#ffffffSalário VIP/Sócio (1h online): " .. color .. "$" .. tostring(pay), pl, 255, 255, 255, true)
			end
		end
	end
end

local function resolveTarget(admin, partial)
	if not partial or partial == "" then return nil end
	return select(1, core:getPlayerFromPartialName(admin, tostring(partial):gsub("^%s+", ""):gsub("%s+$", ""), true))
end

local function adminCanSetVip(admin)
	return (tonumber(getElementData(admin, "user:admin")) or 0) >= 6
end

local function adminVerifiedOrMsg(pl)
	if not exports.oAnticheat or not exports.oAnticheat.checkPlayerVerifiedAdminStatus then
		return true
	end
	local ok, res = pcall(function()
		return exports.oAnticheat:checkPlayerVerifiedAdminStatus(pl)
	end)
	if ok and res then return true end
	outputChatBox(pref() .. "#ffffffConta admin não verificada (anti-cheat).", pl, 255, 255, 255, true)
	return false
end

local function cmdSetVip(admin, _, target, tierId, extraDays)
	if not adminCanSetVip(admin) then return end
	if not adminVerifiedOrMsg(admin) then return end
	if not getElementData(admin, "user:loggedin") then return end
	local tgt = resolveTarget(admin, target)
	if not tgt then
		outputChatBox(pref() .. "#ffffffUso: /setvip [jogador] [tier_id|off] [dias_extra_opcional]", admin, 255, 255, 255, true)
		outputChatBox("#aaaaaavip_sigma | vip_omega | vip_ipiranga", admin, 255, 255, 255, true)
		return
	end
	if tierId == nil or tierId == "" then
		outputChatBox(pref() .. "#ffffffIndica o tier ou #aaaaaaoff#ffffff para remover.", admin, 255, 255, 255, true)
		return
	end
	tierId = tostring(tierId)
	local days = tonumber(extraDays)
	local ok, reason = grantSubscription(tgt, "vip", tierId, days)
	if ok then
		outputChatBox(pref() .. "#ffffffVIP atualizado para " .. getPlayerName(tgt):gsub("_", " ") .. ".", admin, 255, 255, 255, true)
		outputChatBox(pref() .. "#ffffffA tua subscrição VIP foi atualizada por staff.", tgt, 255, 255, 255, true)
	else
		outputChatBox(pref() .. "#ffffffFalha: " .. tostring(reason), admin, 255, 255, 255, true)
	end
end

local function cmdSetSocio(admin, _, target, tierId, extraDays)
	if not adminCanSetVip(admin) then return end
	if not adminVerifiedOrMsg(admin) then return end
	if not getElementData(admin, "user:loggedin") then return end
	local tgt = resolveTarget(admin, target)
	if not tgt then
		outputChatBox(pref() .. "#ffffffUso: /setsocio [jogador] [tier_id|off] [dias_extra_opcional]", admin, 255, 255, 255, true)
		outputChatBox("#aaaaaasocio_semanal | socio_mensal | socio_patrocinador", admin, 255, 255, 255, true)
		return
	end
	if tierId == nil or tierId == "" then
		outputChatBox(pref() .. "#ffffffIndica o tier ou #aaaaaaoff#ffffff para remover.", admin, 255, 255, 255, true)
		return
	end
	tierId = tostring(tierId)
	local days = tonumber(extraDays)
	local ok, reason = grantSubscription(tgt, "socio", tierId, days)
	if ok then
		outputChatBox(pref() .. "#ffffffSócio atualizado para " .. getPlayerName(tgt):gsub("_", " ") .. ".", admin, 255, 255, 255, true)
		outputChatBox(pref() .. "#ffffffA tua subscrição Sócio foi atualizada por staff.", tgt, 255, 255, 255, true)
	else
		outputChatBox(pref() .. "#ffffffFalha: " .. tostring(reason), admin, 255, 255, 255, true)
	end
end

addEventHandler("onResourceStart", resourceRoot, function()
	conn = exports.oMysql:getDBConnection()
	local hex = select(1, core:getServerColor())
	if type(hex) == "string" then color = hex end
	ensureSubscriptionsTable()
	setTimer(hourlyPayout, 3600000, 0)
	outputDebugString("[oIpirangaVIP] Arranque — tabela ipiranga_subscriptions OK: " .. tostring(dbOk()), 3)
end)

addEventHandler("onElementDataChange", root, function(dataName, oldVal, newVal)
	if dataName ~= "user:loggedin" or newVal ~= true then return end
	local pl = source
	if not isElement(pl) or getElementType(pl) ~= "player" then return end
	setTimer(function(p)
		if isElement(p) and getElementData(p, "user:loggedin") and tonumber(getElementData(p, "char:id")) then
			loadSubscriptionsForPlayer(p)
		end
	end, 800, 1, pl)
end)

local function cmdMeuVip(pl)
	if not getElementData(pl, "user:loggedin") then return end
	local now = os.time()
	local vx = tonumber(getElementData(pl, "char:vip_expire")) or 0
	local sx = tonumber(getElementData(pl, "char:socio_expire")) or 0
	local vt = getPlayerVipTierId(pl)
	local st = getPlayerSocioTierId(pl)
	local function line(active, tier, exp)
		if not active then return "inativo" end
		local left = math.max(0, exp - now)
		local d = math.floor(left / 86400)
		local h = math.floor((left % 86400) / 3600)
		return tier .. " (" .. d .. "d " .. h .. "h)"
	end
	outputChatBox(pref() .. "#ffffffVIP: " .. color .. line(isVipLineActive(pl, "vip"), vt, vx), pl, 255, 255, 255, true)
	outputChatBox(pref() .. "#ffffffSócio: " .. color .. line(isVipLineActive(pl, "socio"), st, sx), pl, 255, 255, 255, true)
end

addCommandHandler("setvip", cmdSetVip)
addCommandHandler("setsocio", cmdSetSocio)
addCommandHandler("meuvip", cmdMeuVip)
addCommandHandler("statusvip", cmdMeuVip)
