--[[ oTags — servidor ]]

local conn = exports.oMysql:getDBConnection()
local core = exports.oCore
local infobox = exports.oInfobox

local function prefix()
	return core:getServerPrefix("green-dark", "Tags", 3)
end

local function ensureTables()
	dbExec(conn, [[
CREATE TABLE IF NOT EXISTS tags (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(64) NOT NULL,
	text VARCHAR(16) NOT NULL,
	color VARCHAR(16) NOT NULL DEFAULT '#ffffff',
	bg_color VARCHAR(16) NOT NULL DEFAULT '#222222',
	border_color VARCHAR(16) NOT NULL DEFAULT '#444444',
	animated TINYINT(1) NOT NULL DEFAULT 0,
	rarity ENUM('common','rare','legendary') NOT NULL DEFAULT 'common',
	source ENUM('faction','admin','achievement','rank','event') NOT NULL DEFAULT 'admin',
	faction_id INT NULL DEFAULT NULL,
	created_by INT NULL DEFAULT NULL,
	expires_at BIGINT NOT NULL DEFAULT 0,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UNIQUE KEY uniq_source_faction (source, faction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
	dbExec(conn, [[
CREATE TABLE IF NOT EXISTS player_tags (
	id INT AUTO_INCREMENT PRIMARY KEY,
	char_id INT NOT NULL,
	tag_id INT NOT NULL,
	is_active TINYINT(1) NOT NULL DEFAULT 0,
	assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	expires_at BIGINT NOT NULL DEFAULT 0,
	UNIQUE KEY uniq_char_tag (char_id, tag_id),
	KEY idx_char_active (char_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
end

local function rowToTag(row)
	if not row then return nil end
	return {
		id = tonumber(row.id) or 0,
		name = row.name,
		text = row.text,
		color = row.color,
		bg_color = row.bg_color,
		border_color = row.border_color,
		animated = (tonumber(row.animated) or 0) == 1,
		rarity = row.rarity,
		source = row.source,
		faction_id = row.faction_id ~= nil and tonumber(row.faction_id) or nil,
	}
end

local function isTagExpired(row)
	if not row then return true end
	local now = getRealTime().timestamp
	local te = tonumber(row.expires_at) or 0
	if te > 0 and te <= now then return true end
	return false
end

function pushTagElementData(player, tagTbl)
	if not isElement(player) or getElementType(player) ~= "player" then return end
	local t = tagTbl or shallowCopyTag(TAG_DEFAULT_CIVIL)
	setElementData(player, TAG_ELEMENT_KEY, toJSON(t), true)
end

local function syncFactionTagsFromDB()
	local qh = dbQuery(conn, "SELECT id, name, color FROM factions ORDER BY id ASC")
	local rows = dbPoll(qh, 500) or {}
	local n = 0
	for _, fac in ipairs(rows) do
		local fid = tonumber(fac.id)
		local def = FACTION_TAG_DEFAULTS[fid]
		local fname = fac.name or ("Faction " .. tostring(fid))
		local facColor = fac.color or "#ffffff"
		if def then
			dbExec(conn, [[
INSERT INTO tags (name, text, color, bg_color, border_color, animated, rarity, source, faction_id)
VALUES (?, ?, ?, ?, ?, 0, 'common', 'faction', ?)
ON DUPLICATE KEY UPDATE
	name = VALUES(name),
	text = VALUES(text),
	color = VALUES(color),
	bg_color = VALUES(bg_color),
	border_color = VALUES(border_color)
]], fname, def.text, def.color, def.bg_color, def.border_color, fid)
			n = n + 1
		elseif fid then
			dbExec(conn, [[
INSERT INTO tags (name, text, color, bg_color, border_color, animated, rarity, source, faction_id)
VALUES (?, ?, ?, ?, ?, 0, 'common', 'faction', ?)
ON DUPLICATE KEY UPDATE
	name = VALUES(name),
	color = VALUES(color)
]], fname, string.upper(string.sub(fname or "FAC", 1, 4)), facColor, "#222222", "#444444", fid)
			n = n + 1
		end
	end
	outputDebugString("[oTags] Tags de facção sincronizadas (" .. tostring(n) .. " linhas processadas).", 3)
end

local function deactivateAllCharTags(charId)
	dbExec(conn, "UPDATE player_tags SET is_active = 0 WHERE char_id = ?", charId)
end

local function getFactionTagId(factionId)
	if not factionId or factionId <= 0 then return nil end
	local qh = dbQuery(conn, "SELECT id FROM tags WHERE source = 'faction' AND faction_id = ? LIMIT 1", factionId)
	local rows = dbPoll(qh, 500) or {}
	if rows[1] then return tonumber(rows[1].id) end
	return nil
end

local function fetchTagRowById(tagId)
	local qh = dbQuery(conn, "SELECT * FROM tags WHERE id = ? LIMIT 1", tagId)
	local rows = dbPoll(qh, 500) or {}
	return rows[1]
end

local function fetchActiveTagForChar(charId)
	local qh = dbQuery(conn, [[
SELECT t.*, pt.expires_at AS pt_expires
FROM player_tags pt
INNER JOIN tags t ON t.id = pt.tag_id
WHERE pt.char_id = ? AND pt.is_active = 1
LIMIT 1
]], charId)
	local rows = dbPoll(qh, 500) or {}
	local row = rows[1]
	if not row then return nil end
	local pte = tonumber(row.pt_expires) or 0
	local now = getRealTime().timestamp
	if pte > 0 and pte <= now then return nil end
	row.pt_expires = nil
	if isTagExpired(row) then return nil end
	return row
end

function refreshPlayerTagDisplay(player)
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if not getElementData(player, "user:loggedin") then return end
	local charId = getElementData(player, "char:id")
	if not charId then return end

	local row = fetchActiveTagForChar(charId)
	if row and not isTagExpired(row) then
		pushTagElementData(player, rowToTag(row))
		return
	end

	local fid = tonumber(getElementData(player, "char:mainFaction")) or 0
	if fid > 0 then
		local tid = getFactionTagId(fid)
		if tid then
			deactivateAllCharTags(charId)
			dbExec(conn, [[
INSERT INTO player_tags (char_id, tag_id, is_active, expires_at) VALUES (?, ?, 1, 0)
ON DUPLICATE KEY UPDATE is_active = 1, expires_at = 0
]], charId, tid)
			local tr = fetchTagRowById(tid)
			if tr and not isTagExpired(tr) then
				pushTagElementData(player, rowToTag(tr))
				return
			end
		end
	end

	pushTagElementData(player, shallowCopyTag(TAG_DEFAULT_CIVIL))
end

local function applyFactionChange(player, newFactionId)
	local charId = getElementData(player, "char:id")
	if not charId then return end
	newFactionId = tonumber(newFactionId) or 0

	if newFactionId > 0 then
		deactivateAllCharTags(charId)
		local tid = getFactionTagId(newFactionId)
		if tid then
			dbExec(conn, [[
INSERT INTO player_tags (char_id, tag_id, is_active, expires_at) VALUES (?, ?, 1, 0)
ON DUPLICATE KEY UPDATE is_active = 1, expires_at = 0
]], charId, tid)
		end
	else
		dbExec(conn, [[
UPDATE player_tags pt
INNER JOIN tags t ON t.id = pt.tag_id
SET pt.is_active = 0
WHERE pt.char_id = ? AND t.source = 'faction'
]], charId)
	end

	refreshPlayerTagDisplay(player)
end

function getPlayerTag(player)
	if not isElement(player) or getElementType(player) ~= "player" then
		return shallowCopyTag(TAG_DEFAULT_CIVIL)
	end
	local raw = getElementData(player, TAG_ELEMENT_KEY)
	if raw and raw ~= "" then
		local ok, data = pcall(fromJSON, raw)
		if ok and type(data) == "table" and data.text then
			return data
		end
	end
	return shallowCopyTag(TAG_DEFAULT_CIVIL)
end

function setPlayerTag(player, tagId)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	local charId = getElementData(player, "char:id")
	if not charId then return false end
	tagId = tonumber(tagId)
	if not tagId then return false end
	local row = fetchTagRowById(tagId)
	if not row or isTagExpired(row) then return false end

	deactivateAllCharTags(charId)
	dbExec(conn, [[
INSERT INTO player_tags (char_id, tag_id, is_active, expires_at) VALUES (?, ?, 1, 0)
ON DUPLICATE KEY UPDATE is_active = 1, expires_at = 0
]], charId, tagId)
	refreshPlayerTagDisplay(player)
	return true
end

function removePlayerTag(player, tagId)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	local charId = getElementData(player, "char:id")
	if not charId then return false end
	tagId = tonumber(tagId)
	if not tagId then return false end

	dbExec(conn, "UPDATE player_tags SET is_active = 0 WHERE char_id = ? AND tag_id = ?", charId, tagId)
	refreshPlayerTagDisplay(player)
	return true
end

local function adminLevel(p)
	return tonumber(getElementData(p, "user:admin")) or 0
end

addCommandHandler("createtag", function(player, cmd, ...)
	local lvl = adminLevel(player)
	if lvl < 7 then return end
	local argv = { ... }
	local argc = #argv
	if argc < 4 then
		outputChatBox(prefix() .. "#ffffffUso: /createtag <nome> <texto> <#cor_texto> <#cor_fundo>", player, 255, 255, 255, true)
		return
	end
	local nome = argv[1]
	local fg = argv[argc - 1]
	local bg = argv[argc]
	local texto = table.concat(argv, " ", 2, argc - 2)
	local tlen = (utf8 and utf8.len and utf8.len(texto)) or string.len(texto)
	if texto == "" or tlen > 16 then
		infobox:outputInfoBox("Texto da tag inválido (máx. 16 caracteres).", "error", player)
		return
	end
	local admId = getElementData(player, "user:id")
	dbExec(conn, [[
INSERT INTO tags (name, text, color, bg_color, border_color, animated, rarity, source, faction_id, created_by)
VALUES (?, ?, ?, ?, '#444444', 0, 'common', 'admin', NULL, ?)
]], nome, texto, fg, bg, admId)
	local qh = dbQuery(conn, "SELECT LAST_INSERT_ID() AS lid")
	local r = dbPoll(qh, 500) or {}
	local nid = r[1] and tonumber(r[1].lid)
	infobox:outputInfoBox(nid and ("Tag criada (ID " .. tostring(nid) .. ").") or "Tag criada.", "success", player)
end)

addCommandHandler("givetag", function(player, cmd, target, tagIdStr)
	local lvl = adminLevel(player)
	if lvl < 6 then return end
	if not target or not tagIdStr then
		outputChatBox(prefix() .. "#ffffffUso: /givetag <jogador> <tag_id>", player, 255, 255, 255, true)
		return
	end
	local tid = tonumber(tagIdStr)
	if not tid then
		infobox:outputInfoBox("ID da tag inválido.", "error", player)
		return
	end
	local targetPl = exports.oCore:getPlayerFromPartialName(player, target)
	if not targetPl then return end
	if setPlayerTag(targetPl, tid) then
		infobox:outputInfoBox("Tag atribuída.", "success", player)
		infobox:outputInfoBox("Recebeste uma nova tag ativa.", "info", targetPl)
	else
		infobox:outputInfoBox("Não foi possível atribuir a tag.", "error", player)
	end
end)

addCommandHandler("removetag", function(player, cmd, target, tagIdStr)
	local lvl = adminLevel(player)
	if lvl < 6 then return end
	if not target or not tagIdStr then
		outputChatBox(prefix() .. "#ffffffUso: /removetag <jogador> <tag_id>", player, 255, 255, 255, true)
		return
	end
	local tid = tonumber(tagIdStr)
	if not tid then
		infobox:outputInfoBox("ID da tag inválido.", "error", player)
		return
	end
	local targetPl = exports.oCore:getPlayerFromPartialName(player, target)
	if not targetPl then return end
	if removePlayerTag(targetPl, tid) then
		infobox:outputInfoBox("Tag removida do jogador.", "success", player)
	else
		infobox:outputInfoBox("Não foi possível remover a tag.", "error", player)
	end
end)

addCommandHandler("listtags", function(player)
	local lvl = adminLevel(player)
	if lvl < 4 then return end
	local qh = dbQuery(conn, "SELECT id, name, text, source, faction_id FROM tags ORDER BY id DESC LIMIT 50")
	local rows = dbPoll(qh, 500) or {}
	outputChatBox(prefix() .. "#ffffffÚltimas tags (máx. 50):", player, 255, 255, 255, true)
	for _, row in ipairs(rows) do
		local fid = row.faction_id and tostring(row.faction_id) or "-"
		outputChatBox(string.format("#ccccccID %d #ffffff| %s | [%s] | %s | fac:%s", tonumber(row.id), tostring(row.name), tostring(row.text), tostring(row.source), fid), player, 255, 255, 255, true)
	end
end)

addEventHandler("onResourceStart", resourceRoot, function()
	ensureTables()
	syncFactionTagsFromDB()
	for _, p in ipairs(getElementsByType("player")) do
		if getElementData(p, "user:loggedin") then
			refreshPlayerTagDisplay(p)
		end
	end
end)

addEventHandler("onElementDataChange", root, function(dataName, oldValue)
	if dataName ~= "user:loggedin" then return end
	local player = source
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if getElementData(player, "user:loggedin") == true then
		setTimer(function(pl)
			if isElement(pl) then refreshPlayerTagDisplay(pl) end
		end, 500, 1, player)
	end
end)

addEventHandler("onElementDataChange", root, function(dataName, oldValue)
	if dataName ~= "char:mainFaction" then return end
	local player = source
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if not getElementData(player, "user:loggedin") then return end
	applyFactionChange(player, getElementData(player, "char:mainFaction"))
end)
