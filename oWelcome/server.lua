--[[ oWelcome — servidor ]]

local conn
local core = exports.oCore
local infobox = exports.oInfobox

local function pref()
	return core:getServerPrefix("green-dark", "Boas-vindas", 3)
end

local function adminLvl(p)
	return tonumber(getElementData(p, "user:admin")) or 0
end

local function ensureWelcomeSeenColumn()
	if not conn then return end
	local qh = dbQuery(conn, "SHOW COLUMNS FROM accounts LIKE 'welcome_seen'")
	local rows = dbPoll(qh, 800)
	if type(rows) == "table" and #rows == 0 then
		dbExec(conn, "ALTER TABLE accounts ADD COLUMN welcome_seen TINYINT NOT NULL DEFAULT 0")
	end
end

local function ensureSchema()
	if not conn then
		outputDebugString("[oWelcome] MySQL indisponível — schema de boas-vindas não aplicado.", 2)
		return
	end
	ensureWelcomeSeenColumn()
	dbExec(conn, [[
CREATE TABLE IF NOT EXISTS welcome_news (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(120) NOT NULL,
	body VARCHAR(500) NOT NULL,
	created_by VARCHAR(60) NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	active TINYINT(1) NOT NULL DEFAULT 1,
	KEY idx_active_created (active, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
	dbExec(conn, [[
CREATE TABLE IF NOT EXISTS welcome_tips (
	id INT AUTO_INCREMENT PRIMARY KEY,
	tip VARCHAR(300) NOT NULL,
	active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
end

local function pickTipOfDay()
	local qh = dbQuery(conn, "SELECT id, tip FROM welcome_tips WHERE active = 1 ORDER BY id ASC")
	local rows = dbPoll(qh, 500) or {}
	if #rows == 0 then
		return "Explora o mapa com moderação e diverte-te em segurança."
	end
	local ts = getRealTime().timestamp or os.time()
	local day = math.floor(ts / 86400)
	local idx = (day % #rows) + 1
	return rows[idx].tip or rows[1].tip
end

local function fetchNews()
	local qh = dbQuery(conn, [[
SELECT id, title, body, created_at, created_by FROM welcome_news WHERE active = 1 ORDER BY created_at DESC LIMIT 15
]])
	return dbPoll(qh, 500) or {}
end

local function fetchTopRichName()
	local qh = dbQuery(conn, "SELECT charname FROM characters ORDER BY money DESC LIMIT 1")
	local r = dbPoll(qh, 500) or {}
	if r[1] and r[1].charname then
		return (tostring(r[1].charname)):gsub("_", " ")
	end
	return "—"
end

local function fetchTopFactionName()
	local qh = dbQuery(conn, [[
SELECT f.name AS n, COUNT(*) AS c
FROM territories t
INNER JOIN factions f ON f.id = t.owner_faction
WHERE t.owner_faction > 0
GROUP BY f.id, f.name
ORDER BY c DESC
LIMIT 1
]])
	local r = dbPoll(qh, 500) or {}
	if r[1] and r[1].n then return tostring(r[1].n) end
	local qh2 = dbQuery(conn, "SELECT name FROM factions ORDER BY id ASC LIMIT 1")
	local r2 = dbPoll(qh2, 300) or {}
	if r2[1] then return tostring(r2[1].name) end
	return "—"
end

local function buildPayload(player)
	return {
		news = fetchNews(),
		tip = pickTipOfDay(),
		topPlayer = fetchTopRichName(),
		topFaction = fetchTopFactionName(),
		serverName = core:getServerName() or "Ipiranga RP",
	}
end

function sendWelcomeToPlayer(player, forceShow)
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if not getElementData(player, "user:loggedin") then return end
	local accId = getElementData(player, "user:id")
	if not accId then return end

	dbQuery(function(qh)
		local rows = dbPoll(qh, 0)
		local seen = 0
		if rows and rows[1] then seen = tonumber(rows[1].welcome_seen) or 0 end
		if not forceShow and seen == 1 then return end
		local payload = buildPayload(player)
		triggerClientEvent(player, "oWelcome > open", resourceRoot, payload)
	end, conn, "SELECT welcome_seen FROM accounts WHERE id = ? LIMIT 1", accId)
end

addEventHandler("onResourceStart", resourceRoot, function()
	conn = exports.oMysql:getDBConnection()
	ensureSchema()
end)

addEventHandler("onElementDataChange", root, function(dataName)
	if dataName ~= "user:loggedin" then return end
	local pl = source
	if not isElement(pl) or getElementType(pl) ~= "player" then return end
	if getElementData(pl, "user:loggedin") ~= true then return end
	setTimer(function(p)
		if isElement(p) then sendWelcomeToPlayer(p, false) end
	end, 1200, 1, pl)
end)

addEvent("oWelcome > markSeen", true)
addEventHandler("oWelcome > markSeen", root, function(confirm)
	local player = source
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if confirm ~= true then return end
	local accId = getElementData(player, "user:id")
	if not accId then return end
	dbExec(conn, "UPDATE accounts SET welcome_seen = 1 WHERE id = ?", accId)
end)

addCommandHandler("welcome", function(pl)
	sendWelcomeToPlayer(pl, true)
end)

addCommandHandler("ajuda", function(pl)
	sendWelcomeToPlayer(pl, true)
end)

addCommandHandler("addnews", function(pl, _, title, ...)
	if adminLvl(pl) < 4 then return end
	local body = table.concat({ ... }, " ")
	if not title or body == "" then
		outputChatBox(pref() .. "#ffffffUso: /addnews <título> <corpo...>", pl, 255, 255, 255, true)
		return
	end
	local nick = getElementData(pl, "user:adminnick") or getPlayerName(pl)
	dbExec(conn, "INSERT INTO welcome_news (title, body, created_by) VALUES (?, ?, ?)", title, body, nick)
	infobox:outputInfoBox("Notícia adicionada.", "success", pl)
end)

addCommandHandler("delnews", function(pl, _, idStr)
	if adminLvl(pl) < 4 then return end
	idStr = tonumber(idStr)
	if not idStr then
		outputChatBox(pref() .. "#ffffffUso: /delnews <id>", pl, 255, 255, 255, true)
		return
	end
	dbExec(conn, "UPDATE welcome_news SET active = 0 WHERE id = ?", idStr)
	infobox:outputInfoBox("Notícia #" .. idStr .. " desativada.", "success", pl)
end)

addCommandHandler("addtip", function(pl, _, ...)
	if adminLvl(pl) < 4 then return end
	local tip = table.concat({ ... }, " ")
	if tip == "" then
		outputChatBox(pref() .. "#ffffffUso: /addtip <texto>", pl, 255, 255, 255, true)
		return
	end
	dbExec(conn, "INSERT INTO welcome_tips (tip, active) VALUES (?, 1)", tip)
	infobox:outputInfoBox("Dica adicionada.", "success", pl)
end)

local function listTierSummary(pl, tiers, title)
	outputChatBox(pref() .. "#ffffff" .. title, pl, 255, 255, 255, true)
	for _, t in ipairs(tiers or {}) do
		outputChatBox(
			"  #cccccc" .. tostring(t.name or "?")
				.. " #ffffff— "
				.. tostring(t.durationDays or 0)
				.. " dias · ativação $"
				.. tostring(t.activationCash or 0)
				.. " · salário $"
				.. tostring(t.hourlySalary or 0)
				.. "/h",
			pl,
			255,
			255,
			255,
			true
		)
	end
	outputChatBox("#aaaaaaDetalhe completo (benefícios, comandos): oWelcome/vip_socio_config.lua — integrar loja/Discord.", pl, 255, 255, 255, true)
end

addCommandHandler("planosvip", function(pl)
	if type(IPiranga_VIP_TIERS) ~= "table" then return end
	listTierSummary(pl, IPiranga_VIP_TIERS, "Planos VIP (referência):")
end)

addCommandHandler("planossocio", function(pl)
	if type(IPiranga_SOCIO_TIERS) ~= "table" then return end
	listTierSummary(pl, IPiranga_SOCIO_TIERS, "Planos Sócio (referência):")
end)
