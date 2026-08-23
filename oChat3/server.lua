--[[ oChat3 — servidor ]]

local conn
local core = exports.oCore
local infobox = exports.oInfobox

local function refreshConn()
	conn = exports.oMysql:getDBConnection()
	return conn
end

local function dbOk()
	return conn ~= nil and conn ~= false
end

local twitterCache = {}
local deepWebSeed = math.random(100001, 999983)
local deepListeners = {}
local tweetLikedByPlayer = {}

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function parseBounty(msg)
	local bounty = tonumber(msg:match("%[[Rr][Ee][Cc][Oo][Mm][Pp][Ee][Nn][Ss][Aa]:%s*%$(%d+)%]"))
	local stripped = msg
	if bounty then
		stripped = stripped:gsub("%[[Rr][Ee][Cc][Oo][Mm][Pp][Ee][Nn][Ss][Aa]:%s*%$%d+%]", "")
	end
	stripped = trim(stripped)
	local nick = stripped:match("^(%S+)")
	return bounty, nick, stripped
end

local function pref()
	return core:getServerPrefix("green-dark", "Chat3", 3)
end

local function adminLvl(p)
	return tonumber(getElementData(p, "user:admin")) or 0
end

local function ensureTwitterTable()
	if not dbOk() then return false end
	dbExec(conn, [[
CREATE TABLE IF NOT EXISTS twitter_posts (
	id INT AUTO_INCREMENT PRIMARY KEY,
	char_id INT NOT NULL,
	char_name VARCHAR(60) NOT NULL,
	faction_tag VARCHAR(20) NOT NULL DEFAULT '',
	faction_color VARCHAR(16) NOT NULL DEFAULT '#ffffff',
	content VARCHAR(240) NOT NULL,
	likes INT NOT NULL DEFAULT 0,
	is_pinned TINYINT(1) NOT NULL DEFAULT 0,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	KEY idx_pin_created (is_pinned, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
	return true
end

local function reloadTwitterCache()
	if not dbOk() then twitterCache = {} return twitterCache end
	local qh = dbQuery(conn, [[
SELECT id, char_id, char_name, faction_tag, faction_color, content, likes, is_pinned, UNIX_TIMESTAMP(created_at) AS ts
FROM twitter_posts
ORDER BY is_pinned DESC, created_at DESC
LIMIT ]] .. tostring(math.floor(tonumber(TWITTER_CACHE_MAX) or 50)))
	local rows = dbPoll(qh, 800) or {}
	twitterCache = rows
	return twitterCache
end

local function pushTwitterFeedToPlayer(pl)
	if not isElement(pl) then return end
	triggerClientEvent(pl, "oChat3 > twitterSetFeed", resourceRoot, twitterCache)
end

local function broadcastTwitterFeed()
	triggerClientEvent(root, "oChat3 > twitterSetFeed", resourceRoot, twitterCache)
end

local function deepWebHandle(charId)
	local cid = tonumber(charId) or 0
	local v = (cid * 7919 + deepWebSeed) % 65536
	return string.format("[usr_%04x]", v)
end

local function playerInDeepZone(pl)
	local x, y, z = getElementPosition(pl)
	for _, zt in ipairs(DEEP_WEB_ZONES) do
		if getDistanceBetweenPoints3D(x, y, z, zt.x, zt.y, zt.z) <= (zt.r or 10) then
			return true
		end
	end
	return false
end

-- Deep Web IC: sessão anónima para qualquer jogador com personagem ativo (item 98 / DEEP_WEB_ZONES reservados para regras extra no futuro).
local function canUseDeepWeb(pl)
	if not isElement(pl) or getElementType(pl) ~= "player" then return false end
	return getElementData(pl, "user:loggedin") == true
end

addEventHandler("onResourceStart", resourceRoot, function()
	refreshConn()
	if dbOk() then
		pcall(ensureTwitterTable)
		pcall(reloadTwitterCache)
	else
		outputDebugString("[oChat3] MySQL indisponível ao iniciar — Twitter em DB desativado (recarrega oChat3 após oMysql).", 1)
	end
	outputDebugString("[oChat3] Deep Web session seed: " .. tostring(deepWebSeed), 3)
end)

addEventHandler("onPlayerQuit", root, function()
	deepListeners[source] = nil
	tweetLikedByPlayer[source] = nil
end)

addEventHandler("onElementDataChange", root, function(dataName)
	if dataName ~= "user:loggedin" then return end
	local pl = source
	if not isElement(pl) or getElementType(pl) ~= "player" then return end
	if getElementData(pl, "user:loggedin") ~= true then return end
	setTimer(function(p)
		if isElement(p) then pushTwitterFeedToPlayer(p) end
	end, 800, 1, pl)
end)

addEvent("oChat3 > twitterPost", true)
addEventHandler("oChat3 > twitterPost", resourceRoot, function(content)
	local player = client
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if not getElementData(player, "user:loggedin") then return end
	if type(content) ~= "string" then return end
	if not dbOk() then
		refreshConn()
	end
	if not dbOk() then
		infobox:outputInfoBox("Twitter indisponível (base de dados). Contacta staff técnico.", "error", player)
		return
	end
	content = content:gsub("^%s+", ""):gsub("%s+$", "")
	local len = (utf8 and utf8.len(content)) or string.len(content)
	if len < 1 or len > TWITTER_MAX_CHARS then
		infobox:outputInfoBox("Publicação inválida (1–" .. TWITTER_MAX_CHARS .. " caracteres).", "error", player)
		return
	end

	local charId = getElementData(player, "char:id")
	local charName = (getElementData(player, "char:name") or getPlayerName(player)):gsub("_", " ")
	local ftag, fcol = "?", "#ffffff"
	local okTag, tag = pcall(function()
		return exports.oTags:getPlayerTag(player)
	end)
	if okTag and tag and tag.text then
		ftag = tostring(tag.text)
		fcol = tag.color and tostring(tag.color) or "#ffffff"
	end

	dbExec(conn, [[
INSERT INTO twitter_posts (char_id, char_name, faction_tag, faction_color, content, likes, is_pinned)
VALUES (?, ?, ?, ?, ?, 0, 0)
]], charId, charName, ftag, fcol, content)

	local qh = dbQuery(conn, "SELECT LAST_INSERT_ID() AS lid")
	local r = dbPoll(qh, 500) or {}
	local nid = r[1] and tonumber(r[1].lid)

	reloadTwitterCache()
	broadcastTwitterFeed()

	if nid then
		infobox:outputInfoBox("Tweet publicado (#" .. tostring(nid) .. ").", "success", player)
	else
		infobox:outputInfoBox("Tweet publicado.", "success", player)
	end
end)

addEvent("oChat3 > twitterLike", true)
addEventHandler("oChat3 > twitterLike", resourceRoot, function(postId)
	local player = client
	if not isElement(player) or getElementType(player) ~= "player" then return end
	postId = tonumber(postId)
	if not postId then return end
	if not dbOk() then return end

	if not tweetLikedByPlayer[player] then tweetLikedByPlayer[player] = {} end
	if tweetLikedByPlayer[player][postId] then
		infobox:outputInfoBox("Já curtiu este post.", "warning", player)
		return
	end

	dbExec(conn, "UPDATE twitter_posts SET likes = likes + 1 WHERE id = ?", postId)
	tweetLikedByPlayer[player][postId] = true

	local qh = dbQuery(conn, "SELECT likes FROM twitter_posts WHERE id = ? LIMIT 1", postId)
	local rows = dbPoll(qh, 500) or {}
	local likes = rows[1] and tonumber(rows[1].likes) or 0

	for _, row in ipairs(twitterCache) do
		if tonumber(row.id) == postId then row.likes = likes break end
	end

	triggerClientEvent(root, "oChat3 > twitterLikeResult", resourceRoot, postId, likes)
end)

addEvent("oChat3 > deepWebJoin", true)
addEventHandler("oChat3 > deepWebJoin", resourceRoot, function()
	local player = client
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if not getElementData(player, "user:loggedin") then return end
	if not canUseDeepWeb(player) then
		local msg = "Precisas do item «dispositivo criptografado» (ID "..tostring(ITEM_ENCRYPTED_DEVICE)..") ou estar num ponto Deep Web no mapa."
		infobox:outputInfoBox(msg, "error", player)
		outputChatBox(pref().."#ffffff"..msg, player, 255, 255, 255, true)
		return
	end
	deepListeners[player] = true
	local cid = getElementData(player, "char:id") or 0
	triggerClientEvent(player, "oChat3 > deepWebOpen", resourceRoot, deepWebHandle(cid))
end)

addEvent("oChat3 > deepWebLeave", true)
addEventHandler("oChat3 > deepWebLeave", resourceRoot, function()
	local player = client
	if not isElement(player) then return end
	deepListeners[player] = nil
end)

addEvent("oChat3 > deepWebSay", true)
addEventHandler("oChat3 > deepWebSay", resourceRoot, function(text)
	local player = client
	if not isElement(player) or getElementType(player) ~= "player" then return end
	if not getElementData(player, "user:loggedin") then return end
	if not deepListeners[player] then return end
	if not canUseDeepWeb(player) then
		deepListeners[player] = nil
		triggerClientEvent(player, "oChat3 > deepWebForceClose", resourceRoot)
		return
	end
	if type(text) ~= "string" then return end
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	local tlen = (utf8 and utf8.len(text)) or string.len(text)
	if tlen < 1 or tlen > 280 then return end

	local realName = getPlayerName(player):gsub("_", " ")
	local cid = getElementData(player, "char:id") or 0
	local handle = deepWebHandle(cid)

	local bountyAmt, bountyNick, broadcastText = parseBounty(text)

	outputDebugString("[oChat3][DeepWeb] " .. realName .. " (" .. tostring(cid) .. "): " .. text, 3)

	if bountyAmt then
		bountyAmt = math.min(bountyAmt, 500000)
		local target = bountyNick and select(1, exports.oCore:getPlayerFromPartialName(player, bountyNick, true))
		if target and isElement(target) then
			if exports.oWanted:addBounty(target, bountyAmt) then
				infobox:outputInfoBox("Recompensa registada no sistema de procurados.", "success", player)
			end
		elseif bountyNick then
			infobox:outputInfoBox("Jogador alvo da bounty não encontrado ou offline.", "warning", player)
		else
			infobox:outputInfoBox("Para bounty usa: [RECOMPENSA: $valor] Nome_Parcial (jogador online).", "warning", player)
		end
	end

	if broadcastText ~= "" then
		for pl in pairs(deepListeners) do
			if isElement(pl) and deepListeners[pl] then
				triggerClientEvent(pl, "oChat3 > deepWebLine", resourceRoot, handle, broadcastText, getTickCount())
			end
		end
	end
end)

addCommandHandler("tweetpin", function(pl, _, idStr)
	if adminLvl(pl) < 4 then return end
	idStr = tonumber(idStr)
	if not idStr then
		outputChatBox(pref() .. "#ffffffUso: /tweetpin <id>", pl, 255, 255, 255, true)
		return
	end
	if not dbOk() then refreshConn() end
	if not dbOk() then outputChatBox(pref() .. "#ffffffTwitter DB offline.", pl, 255, 255, 255, true) return end
	dbExec(conn, "UPDATE twitter_posts SET is_pinned = 1 WHERE id = ?", idStr)
	reloadTwitterCache()
	broadcastTwitterFeed()
	infobox:outputInfoBox("Post #" .. idStr .. " fixado.", "success", pl)
end)

addCommandHandler("tweetdel", function(pl, _, idStr)
	if adminLvl(pl) < 4 then return end
	idStr = tonumber(idStr)
	if not idStr then
		outputChatBox(pref() .. "#ffffffUso: /tweetdel <id>", pl, 255, 255, 255, true)
		return
	end
	if not dbOk() then refreshConn() end
	if not dbOk() then outputChatBox(pref() .. "#ffffffTwitter DB offline.", pl, 255, 255, 255, true) return end
	dbExec(conn, "DELETE FROM twitter_posts WHERE id = ?", idStr)
	reloadTwitterCache()
	broadcastTwitterFeed()
	infobox:outputInfoBox("Post #" .. idStr .. " removido.", "success", pl)
end)

addCommandHandler("twitter", function(pl)
	if not getElementData(pl, "user:loggedin") then return end
	triggerClientEvent(pl, "oChat3 > twitterToggleFeed", resourceRoot)
end)
