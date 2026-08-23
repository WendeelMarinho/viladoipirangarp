--[[ oMedia — servidor ]]

local lastPublish = {}

local function okPlayer(p)
	return isElement(p) and getElementType(p) == "player" and getElementData(p, "user:loggedin") == true
end

local function broadcastNews(title, authorName)
	local pref = exports.oCore:getServerPrefix("green-dark", "Mídia IC", 3)
	for _, p in ipairs(getElementsByType("player")) do
		if okPlayer(p) then
			outputChatBox(pref .. "Nova edição: «" .. title .. "» por " .. authorName, p, 255, 255, 255, true)
		end
	end
end

addCommandHandler("publicarnoticia", function(player, _, ...)
	if not okPlayer(player) then return end
	local full = table.concat({ ... }, " ")
	local tit, body = full:match("^(.-)%s%-%-%s(.+)$")
	if not tit or not body then
		outputChatBox(exports.oCore:getServerPrefix("red-dark", "Mídia", 3) ..
			"Uso: /publicarnoticia Título -- corpo da notícia (separador: espaço dois hífens espaço)", player, 255, 255, 255, true)
		return
	end
	tit = tit:match("^%s*(.-)%s*$") or ""
	body = body:match("^%s*(.-)%s*$") or ""
	if #tit < 4 or #body < 12 then
		exports.oInfobox:outputInfoBox("Título ou corpo demasiado curtos.", "error", player)
		return
	end
	if #tit > 90 or #body > 1800 then
		exports.oInfobox:outputInfoBox("Texto demasiado longo.", "error", player)
		return
	end
	local tick = getTickCount()
	if lastPublish[player] and tick - lastPublish[player] < MEDIA_PUBLISH_COOLDOWN_MS then
		exports.oInfobox:outputInfoBox("Aguarda antes de publicares outra notícia.", "warning", player)
		return
	end
	lastPublish[player] = tick

	local authorName = (getElementData(player, "char:name") or getPlayerName(player)):gsub("_", " ")
	local ts = getRealTime().timestamp
	local payload = toJSON({
		title = tit,
		body = body,
		author = authorName,
		char_id = getElementData(player, "char:id"),
		ts = ts,
	})

	exports.oInventory:giveItem(player, MEDIA_ITEM_NEWSPAPER, payload, 1, 0)
	broadcastNews(tit, authorName)
	exports.oInfobox:outputInfoBox("Recebeste um exemplar impresso no inventário.", "success", player)
	pcall(function()
		exports.oRank:incrementStat(getElementData(player, "char:id"), "noticias_publicadas", 1)
	end)
end)

addEventHandler("onPlayerQuit", root, function()
	lastPublish[source] = nil
end)
