--[[ oRank — servidor ]]

local conn = exports.oMysql:getDBConnection()
local core = exports.oCore

local currentSeason = 1
local leaderboardCache = {}

local function ensureTables()
	dbExec(conn, [[
CREATE TABLE IF NOT EXISTS rank_stats (
	id INT AUTO_INCREMENT PRIMARY KEY,
	char_id INT NOT NULL,
	stat_key VARCHAR(64) NOT NULL,
	value BIGINT NOT NULL DEFAULT 0,
	season INT NOT NULL DEFAULT 1,
	last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	UNIQUE KEY uniq_char_stat_season (char_id, stat_key, season),
	KEY idx_leader (stat_key, season, value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
	dbExec(conn, [[
CREATE TABLE IF NOT EXISTS rank_seasons (
	id INT AUTO_INCREMENT PRIMARY KEY,
	season_number INT NOT NULL,
	start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	end_date TIMESTAMP NULL DEFAULT NULL,
	status ENUM('active','closed') NOT NULL DEFAULT 'active',
	UNIQUE KEY uniq_season (season_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
	dbExec(conn, [[
CREATE TABLE IF NOT EXISTS rank_hall_of_fame (
	id INT AUTO_INCREMENT PRIMARY KEY,
	season_id INT NOT NULL,
	category VARCHAR(64) NOT NULL,
	char_id INT NOT NULL,
	char_name VARCHAR(64) NOT NULL,
	value BIGINT NOT NULL,
	recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	KEY idx_season_cat (season_id, category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
end

local function loadActiveSeason()
	local qh = dbQuery(conn, "SELECT season_number FROM rank_seasons WHERE status = 'active' ORDER BY season_number DESC LIMIT 1")
	local r = dbPoll(qh, 500) or {}
	if r[1] and r[1].season_number then
		return tonumber(r[1].season_number) or 1
	end
	dbExec(conn, "INSERT IGNORE INTO rank_seasons (season_number, status) VALUES (1, 'active')")
	return 1
end

local function queryStatLeaderboard(statKey, season)
	local lim = math.floor(tonumber(RANK_TOP_N) or 10)
	local qh = dbQuery(conn, [[
SELECT r.char_id AS char_id, c.charname AS charname, r.value AS value
FROM rank_stats r
INNER JOIN characters c ON c.id = r.char_id
WHERE r.stat_key = ? AND r.season = ?
ORDER BY r.value DESC
LIMIT ]] .. lim, statKey, season)
	return dbPoll(qh, 800) or {}
end

local function queryTerritoryCounts()
	local lim = math.floor(tonumber(RANK_TOP_N) or 10)
	local qh = dbQuery(conn, [[
SELECT f.id AS faction_id, f.name AS charname, COUNT(t.id) AS value
FROM territories t
INNER JOIN factions f ON f.id = t.owner_faction
WHERE t.owner_faction > 0
GROUP BY f.id, f.name
ORDER BY value DESC
LIMIT ]] .. lim)
	local rows = dbPoll(qh, 800) or {}
	for _, row in ipairs(rows) do
		row.char_id = 0
		row.isFaction = true
		row.value = tonumber(row.value) or 0
	end
	return rows
end

local function queryFactionIncome()
	local lim = math.floor(tonumber(RANK_TOP_N) or 10)
	local qh = dbQuery(conn, [[
SELECT f.id AS faction_id, f.name AS charname, SUM(t.income_payday) AS value
FROM territories t
INNER JOIN factions f ON f.id = t.owner_faction
WHERE t.owner_faction > 0
GROUP BY f.id, f.name
ORDER BY value DESC
LIMIT ]] .. lim)
	local rows = dbPoll(qh, 800) or {}
	for _, row in ipairs(rows) do
		row.char_id = 0
		row.isFaction = true
		row.value = tonumber(row.value) or 0
	end
	return rows
end

function rebuildLeaderboardCache()
	currentSeason = loadActiveSeason()
	leaderboardCache = {}

	for _, cat in ipairs(RANK_CATEGORIES) do
		local rows = {}
		if cat.type == "stat" then
			rows = queryStatLeaderboard(cat.statKey, currentSeason)
		elseif cat.type == "terr_count" then
			rows = queryTerritoryCounts()
		elseif cat.type == "faction_income" then
			rows = queryFactionIncome()
		end
		leaderboardCache[cat.id] = {
			label = cat.label,
			abbrev = cat.abbrev,
			type = cat.type,
			statKey = cat.statKey,
			rows = rows,
		}
	end

	syncRankBadgesToPlayers()
	outputDebugString("[oRank] Cache de leaderboards atualizado (época " .. tostring(currentSeason) .. ").", 3)
end

function syncRankBadgesToPlayers()
	for _, pl in ipairs(getElementsByType("player")) do
		removeElementData(pl, RANK_BADGE_KEY)
	end

	local best = {}

	for _, cat in ipairs(RANK_CATEGORIES) do
		if cat.badge then
			local block = leaderboardCache[cat.id]
			if block and block.rows then
				local n = math.min(3, #block.rows)
				for pos = 1, n do
					local row = block.rows[pos]
					local cid = tonumber(row.char_id)
					if cid and cid > 0 then
						local cur = best[cid]
						if not cur or pos < cur.pos then
							best[cid] = { pos = pos, abbrev = cat.abbrev }
						end
					end
				end
			end
		end
	end

	local tiers = { RANK_COLORS_GOLD, RANK_COLORS_SILVER, RANK_COLORS_BRONZE }

	for cid, inf in pairs(best) do
		local cols = tiers[inf.pos]
		if cols then
			local badge = {
				tier = inf.pos,
				text = "[#" .. inf.pos .. " " .. inf.abbrev .. "]",
				color = cols.color,
				bg_color = cols.bg_color,
				border_color = cols.border_color,
				animated = (inf.pos == 1),
			}
			for _, pl in ipairs(getElementsByType("player")) do
				if tonumber(getElementData(pl, "char:id")) == cid then
					setElementData(pl, RANK_BADGE_KEY, toJSON(badge), true)
					break
				end
			end
		end
	end
end

function incrementStat(charId, statKey, amount)
	charId = tonumber(charId)
	amount = math.floor(tonumber(amount) or 0)
	if not charId or charId <= 0 then return false end
	if type(statKey) ~= "string" or statKey == "" then return false end
	if amount == 0 then return false end

	local season = loadActiveSeason()
	currentSeason = season

	dbExec(conn, [[
INSERT INTO rank_stats (char_id, stat_key, value, season) VALUES (?, ?, ?, ?)
ON DUPLICATE KEY UPDATE value = value + ?, last_updated = CURRENT_TIMESTAMP
]], charId, statKey, amount, season, amount)

	return true
end

addEventHandler("onResourceStart", resourceRoot, function()
	ensureTables()
	currentSeason = loadActiveSeason()
	rebuildLeaderboardCache()
	setTimer(rebuildLeaderboardCache, RANK_CACHE_INTERVAL_MS, 0)
end)

addEventHandler("onElementDataChange", root, function(dataName)
	if dataName ~= "user:loggedin" then return end
	local pl = source
	if not isElement(pl) or getElementType(pl) ~= "player" then return end
	if getElementData(pl, "user:loggedin") ~= true then return end
	setTimer(function(p)
		if isElement(p) then syncRankBadgesToPlayers() end
	end, 800, 1, pl)
end)

addCommandHandler("rank", function(player)
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if not getElementData(player, "user:loggedin") then return end
	triggerClientEvent(player, "oRank > open", resourceRoot, leaderboardCache, currentSeason)
end)

addEvent("oRank > refreshMyStats", true)
addEventHandler("oRank > refreshMyStats", root, function()
	local player = source
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if not getElementData(player, "user:loggedin") then return end

	local cid = getElementData(player, "char:id")
	if not cid then return end

	local season = currentSeason
	local out = {}

	for _, cat in ipairs(RANK_CATEGORIES) do
		if cat.type == "stat" then
			local qh = dbQuery(conn, "SELECT value FROM rank_stats WHERE char_id = ? AND stat_key = ? AND season = ? LIMIT 1", cid, cat.statKey, season)
			local vr = dbPoll(qh, 500) or {}
			local val = vr[1] and tonumber(vr[1].value) or 0

			local qh2 = dbQuery(conn, "SELECT COUNT(*) AS c FROM rank_stats WHERE stat_key = ? AND season = ? AND value > ?", cat.statKey, season, val)
			local r2 = dbPoll(qh2, 500) or {}
			local higher = r2[1] and tonumber(r2[1].c) or 0
			local pos = higher + 1

			table.insert(out, {
				category = cat.label,
				statKey = cat.statKey,
				value = val,
				rank = pos,
				type = "stat",
			})
		else
			table.insert(out, {
				category = cat.label,
				statKey = "",
				value = 0,
				rank = 0,
				type = cat.type,
				note = "Ranking por facção — não aplica ao teu personagem.",
			})
		end
	end

	triggerClientEvent(player, "oRank > myStatsResult", resourceRoot, out)
end)
