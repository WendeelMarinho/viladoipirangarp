--[[ oReputation — servidor ]]

local conn
local cache = {}

local function okPlayer(p)
	return isElement(p) and getElementType(p) == "player" and getElementData(p, "user:loggedin") == true
end

local function clampScore(v)
	v = math.floor(tonumber(v) or 0)
	return math.max(REP_MIN, math.min(REP_MAX, v))
end

local function ensureTables()
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS faction_reputation (
		char_id INT NOT NULL,
		faction_id INT NOT NULL,
		score INT NOT NULL DEFAULT 0,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		PRIMARY KEY (char_id, faction_id),
		INDEX idx_char (char_id)
	)]])
end

local function findOnlineChar(charId)
	charId = tonumber(charId)
	if not charId then return nil end
	for _, p in ipairs(getElementsByType("player")) do
		if okPlayer(p) and getElementData(p, "char:id") == charId then
			return p
		end
	end
	return nil
end

local function broadcastPatch(charId, factionId, newScore)
	local p = findOnlineChar(charId)
	if p then
		triggerClientEvent(p, "oReputation > patch", p, factionId, newScore)
	end
end

function pushFullSync(player)
	if not okPlayer(player) then return end
	local cid = tonumber(getElementData(player, "char:id"))
	if not cid then return end
	dbQuery(function(qh)
		local rows = dbPoll(qh, 0)
		cache[cid] = cache[cid] or {}
		local pack = {}
		for _, row in ipairs(rows or {}) do
			local fid = tonumber(row.faction_id)
			local sc = clampScore(row.score)
			cache[cid][fid] = sc
			pack[#pack + 1] = {
				faction_id = fid,
				score = sc,
				name = exports.oDashboard:getFactionName(fid) or ("Facção #" .. tostring(fid)),
			}
		end
		table.sort(pack, function(a, b) return (a.name or "") < (b.name or "") end)
		triggerClientEvent(player, "oReputation > fullSync", player, pack)
	end, conn, "SELECT faction_id, score FROM faction_reputation WHERE char_id = ?", cid)
end

function getReputation(charId, factionId)
	charId, factionId = tonumber(charId), tonumber(factionId)
	if not charId or not factionId then return 0 end
	if cache[charId] and cache[charId][factionId] ~= nil then
		return cache[charId][factionId]
	end
	local qh = dbQuery(conn, "SELECT score FROM faction_reputation WHERE char_id = ? AND faction_id = ?", charId, factionId)
	local r = dbPoll(qh, -1)
	local sc = 0
	if r and r[1] then
		sc = clampScore(r[1].score)
	end
	cache[charId] = cache[charId] or {}
	cache[charId][factionId] = sc
	return sc
end

function setReputation(charId, factionId, value)
	charId, factionId = tonumber(charId), tonumber(factionId)
	if not charId or not factionId then return false end
	local neu = clampScore(value)
	dbExec(conn, [[INSERT INTO faction_reputation (char_id, faction_id, score) VALUES (?, ?, ?)
		ON DUPLICATE KEY UPDATE score = VALUES(score)]], charId, factionId, neu)
	cache[charId] = cache[charId] or {}
	cache[charId][factionId] = neu
	broadcastPatch(charId, factionId, neu)
	return true
end

function applyArrestReputation(criminalCharId, officerPlayer)
	criminalCharId = tonumber(criminalCharId)
	if not criminalCharId or not isElement(officerPlayer) or getElementType(officerPlayer) ~= "player" then return end
	local lawFid = tonumber(getElementData(officerPlayer, "char:duty:faction")) or 0
	local offCid = tonumber(getElementData(officerPlayer, "char:id"))
	if lawFid <= 0 or not offCid then return end
	addReputation(criminalCharId, lawFid, REP_DELTA_ARREST_CRIMINAL)
	addReputation(offCid, lawFid, REP_DELTA_ARREST_OFFICER)
end

function addReputation(charId, factionId, delta)
	charId, factionId = tonumber(charId), tonumber(factionId)
	delta = math.floor(tonumber(delta) or 0)
	if not charId or not factionId or delta == 0 then return nil end
	local cur = getReputation(charId, factionId)
	local neu = clampScore(cur + delta)
	dbExec(conn, [[INSERT INTO faction_reputation (char_id, faction_id, score) VALUES (?, ?, ?)
		ON DUPLICATE KEY UPDATE score = VALUES(score)]], charId, factionId, neu)
	cache[charId][factionId] = neu
	broadcastPatch(charId, factionId, neu)
	return neu
end

addEventHandler("onResourceStart", resourceRoot, function()
	conn = exports.oMysql:getDBConnection()
	if not conn then
		outputDebugString("[oReputation] Sem MySQL.", 1)
		return
	end
	ensureTables()
end)

addEventHandler("onElementDataChange", root, function(dataName, _, newVal)
	if dataName ~= "user:loggedin" or newVal ~= true then return end
	local player = source
	if getElementType(player) ~= "player" then return end
	setTimer(function()
		if okPlayer(player) then
			pushFullSync(player)
		end
	end, 800, 1)
end)

addEvent("oReputation > requestSync", true)
addEventHandler("oReputation > requestSync", resourceRoot, function()
	local player = client
	if not okPlayer(player) then return end
	pushFullSync(player)
end)

addCommandHandler("repadmin", function(player, _, mode, targetPartial, factionId, amount)
	if not okPlayer(player) then return end
	if (getElementData(player, "user:admin") or 0) < 7 then return end
	mode = mode and string.lower(mode) or ""
	factionId = tonumber(factionId)
	amount = tonumber(amount)
	if not targetPartial or not factionId or amount == nil then
		outputChatBox(exports.oCore:getServerPrefix("red-dark", "oReputation", 3) ..
			"Uso: /repadmin [add|set] [id_jogador_nick] [faction_id] [valor_delta_ou_absoluto]", player, 255, 255, 255, true)
		return
	end
	local target = nil
	local pid = tonumber(targetPartial)
	if pid then
		for _, p in ipairs(getElementsByType("player")) do
			if okPlayer(p) and getElementData(p, "char:id") == pid then
				target = p
				break
			end
		end
	end
	if not target then
		local partial = string.lower(targetPartial)
		for _, p in ipairs(getElementsByType("player")) do
			if okPlayer(p) and string.find(string.lower(getPlayerName(p)), partial, 1, true) then
				target = p
				break
			end
		end
	end
	if not target then
		exports.oInfobox:outputInfoBox("Jogador não encontrado.", "error", player)
		return
	end
	local cid = getElementData(target, "char:id")
	if mode == "set" then
		setReputation(cid, factionId, amount)
		exports.oInfobox:outputInfoBox(("Rep facção %d definida para %d."):format(factionId, clampScore(amount)), "success", player)
	elseif mode == "add" then
		local neu = addReputation(cid, factionId, amount)
		exports.oInfobox:outputInfoBox(("Rep facção %d agora: %s"):format(factionId, tostring(neu)), "success", player)
	else
		exports.oInfobox:outputInfoBox("Modo inválido (add ou set).", "error", player)
	end
	pushFullSync(target)
end)
