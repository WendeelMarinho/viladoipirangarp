--[[ oHeist — servidor ]]

local conn
local locationCache = {}
local cooldownUntil = {}
local pending = {}

local function okPlayer(p)
	return isElement(p) and getElementType(p) == "player" and getElementData(p, "user:loggedin") == true
end

local function lawCount()
	local n = 0
	for _, p in ipairs(getElementsByType("player")) do
		if okPlayer(p) and exports.oFactionScripts:isInLawEnforcementDuty(p) then
			n = n + 1
		end
	end
	return n
end

local function crewNear(loc)
	local px, py, pz = loc.pos[1], loc.pos[2], loc.pos[3]
	local crew = {}
	for _, p in ipairs(getElementsByType("player")) do
		if okPlayer(p) and not exports.oFactionScripts:isInLawEnforcementDuty(p) then
			local x, y, z = getElementPosition(p)
			if getDistanceBetweenPoints3D(x, y, z, px, py, pz) <= HEIST_CREW_RADIUS_M then
				crew[#crew + 1] = p
			end
		end
	end
	return crew
end

local function distLoc(player, loc)
	local x, y, z = getElementPosition(player)
	return getDistanceBetweenPoints3D(x, y, z, loc.pos[1], loc.pos[2], loc.pos[3])
end

local function randomToken()
	return tostring(math.random(100000, 999999)) .. "_" .. tostring(getTickCount())
end

local function notifyPolice(loc, alertLevel, msgExtra)
	local x, y, z = loc.pos[1], loc.pos[2], loc.pos[3]
	local stars = string.rep("★", math.min(5, math.max(1, alertLevel)))
	local core = exports.oCore
	local prefix = core:getServerPrefix("blue-light-2", "Assalto", 3)
	local txt = prefix ..
		((" Alerta %s em %s (aprox. %.0f, %.0f). %s"):format(
			stars, loc.name or "local", x, y, msgExtra or ""))
	for _, p in ipairs(getElementsByType("player")) do
		if okPlayer(p) and exports.oFactionScripts:isInLawEnforcementDuty(p) then
			outputChatBox(txt, p, 255, 255, 255, true)
			exports.oInfobox:outputInfoBox(("Coordenadas indicativas: %.0f, %.0f"):format(x, y), "warning", p)
		end
	end
end

local function broadcastLocs()
	local pack = {}
	for _, row in ipairs(locationCache) do
		pack[#pack + 1] = {
			id = row.id,
			type = row.type,
			name = row.name,
			pos = row.pos,
			interior_id = row.interior_id,
			dimension_id = row.dimension_id,
		}
	end
	triggerClientEvent(root, "oHeist > syncLocs", resourceRoot, pack)
end

local function reloadLocations()
	locationCache = {}
	dbQuery(function(qh)
		local rows = dbPoll(qh, 0)
		if not rows then
			broadcastLocs()
			return
		end
		for _, r in ipairs(rows) do
			local pos = fromJSON(r.pos or "[0,0,0]")
			if type(pos) == "table" and pos[1] then
				locationCache[#locationCache + 1] = {
					id = tonumber(r.id),
					type = r.type,
					name = r.name,
					pos = pos,
					interior_id = tonumber(r.interior_id) or 0,
					dimension_id = tonumber(r.dimension_id) or 0,
					cooldown_minutes = tonumber(r.cooldown_minutes) or 30,
					reward_min = tonumber(r.reward_min) or 500,
					reward_max = tonumber(r.reward_max) or 2000,
					min_players = tonumber(r.min_players) or 1,
					police_alert_level = tonumber(r.police_alert_level) or 2,
				}
			end
		end
		table.sort(locationCache, function(a, b) return a.id < b.id end)
		broadcastLocs()
	end, conn, "SELECT * FROM heist_locations WHERE is_active = 1 ORDER BY id ASC")
end

local function seedDefaultsIfEmpty()
	dbQuery(function(qh)
		local r = dbPoll(qh, 0)
		local c = r and r[1] and tonumber(r[1].c) or 0
		if c > 0 then
			reloadLocations()
			return
		end
		for _, row in ipairs(DEFAULT_HEIST_LOCATIONS) do
			dbExec(conn, [[INSERT INTO heist_locations
				(type, name, pos, interior_id, dimension_id, cooldown_minutes, reward_min, reward_max, min_players, police_alert_level, is_active)
				VALUES (?,?,?,?,?,?,?,?,?,?,1)]],
				row.type,
				row.name,
				toJSON(row.pos),
				row.interior_id,
				row.dimension_id,
				row.cooldown_minutes,
				row.reward_min,
				row.reward_max,
				row.min_players,
				row.police_alert_level)
		end
		reloadLocations()
	end, conn, "SELECT COUNT(*) AS c FROM heist_locations")
end

local function ensureTables()
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS heist_locations (
		id INT AUTO_INCREMENT PRIMARY KEY,
		type VARCHAR(30) NOT NULL,
		name VARCHAR(80) NOT NULL,
		pos VARCHAR(512) NOT NULL,
		interior_id INT DEFAULT 0,
		dimension_id INT DEFAULT 0,
		is_active TINYINT DEFAULT 1,
		last_robbed_unix INT NULL DEFAULT NULL,
		cooldown_minutes INT DEFAULT 30,
		reward_min INT DEFAULT 1000,
		reward_max INT DEFAULT 5000,
		min_players INT DEFAULT 1,
		police_alert_level INT DEFAULT 2
	)]])
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS heist_log (
		id INT AUTO_INCREMENT PRIMARY KEY,
		location_id INT NOT NULL,
		participants VARCHAR(1024) NOT NULL,
		reward_total INT DEFAULT 0,
		success TINYINT DEFAULT 0,
		started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		ended_at TIMESTAMP NULL DEFAULT NULL
	)]])
end

local function findLocation(id)
	id = tonumber(id)
	for _, L in ipairs(locationCache) do
		if L.id == id then return L end
	end
	return nil
end

local function payAndLog(loc, participants, totalReward, success)
	local ids = {}
	for _, p in ipairs(participants) do
		if okPlayer(p) then
			ids[#ids + 1] = tonumber(getElementData(p, "char:id"))
		end
	end
	local each = math.floor(totalReward / math.max(1, #participants))
	for _, p in ipairs(participants) do
		if okPlayer(p) then
			setElementData(p, "char:money", (getElementData(p, "char:money") or 0) + each)
			if success then
				pcall(function()
					exports.oRank:incrementStat(getElementData(p, "char:id"), "roubos_realizados", 1)
				end)
				exports.oInfobox:outputInfoBox(("Parte do roubo: R$%d"):format(each), "success", p)
			end
		end
	end
	dbExec(conn,
		"INSERT INTO heist_log (location_id, participants, reward_total, success, ended_at) VALUES (?,?,?,?,NOW())",
		loc.id,
		toJSON(ids),
		totalReward,
		success and 1 or 0)
end

local function clearPending(player)
	local P = pending[player]
	if P and isTimer(P.failTimer) then
		killTimer(P.failTimer)
	end
	pending[player] = nil
end

local function failHeist(player, reason)
	local P = pending[player]
	if not P then return end
	for _, p in ipairs(P.participants) do
		if okPlayer(p) then
			exports.oInfobox:outputInfoBox(reason or "Assalto falhou.", "error", p)
		end
	end
	payAndLog(P.loc, P.participants, 0, false)
	clearPending(player)
end

local function advancePhase(player)
	local P = pending[player]
	if not P then return end
	local phases = HEIST_TYPE_PHASES[P.loc.type]
	if not phases then
		failHeist(player, "Tipo de assalto inválido.")
		return
	end
	P.phaseIndex = (P.phaseIndex or 0) + 1
	local ph = phases[P.phaseIndex]
	if not ph then
		local cops = lawCount()
		local mult = (cops == 0) and 1.15 or 1.0
		local base = math.random(P.loc.reward_min, P.loc.reward_max)
		local total = math.floor(base * mult)
		payAndLog(P.loc, P.participants, total, true)
		dbExec(conn, "UPDATE heist_locations SET last_robbed_unix=? WHERE id=?", getRealTime().timestamp, P.loc.id)
		cooldownUntil[P.loc.id] = getRealTime().timestamp + (P.loc.cooldown_minutes * 60)
		clearPending(player)
		return
	end

	P.token = randomToken()
	P.phaseStarted = getTickCount()
	P.phaseName = ph
	local dur = (ph == "hacking") and 45000 or 65000
	triggerClientEvent(player, "oHeist > beginPhase", player, ph, dur, P.token)
	for _, p in ipairs(P.participants) do
		if p ~= player and okPlayer(p) then
			exports.oInfobox:outputInfoBox(("Fase: %s — aguarda o líder concluir o minijogo."):format(ph == "hacking" and "hacker" or "furadeira"), "info", p)
		end
	end
end

addEventHandler("onResourceStart", resourceRoot, function()
	conn = exports.oMysql:getDBConnection()
	if not conn then
		outputDebugString("[oHeist] Sem MySQL.", 1)
		return
	end
	ensureTables()
	seedDefaultsIfEmpty()
end)

addEventHandler("onPlayerQuit", root, function()
	local p = source
	if pending[p] then
		failHeist(p, "A operação foi abortada (líder ausente).")
	end
end)

addEvent("oHeist > pullLocs", true)
addEventHandler("oHeist > pullLocs", root, function()
	local player = client
	if not okPlayer(player) then return end
	local pack = {}
	for _, row in ipairs(locationCache) do
		pack[#pack + 1] = {
			id = row.id,
			type = row.type,
			name = row.name,
			pos = row.pos,
			interior_id = row.interior_id,
			dimension_id = row.dimension_id,
		}
	end
	triggerClientEvent(player, "oHeist > syncLocs", resourceRoot, pack)
end)

addEvent("oHeist > requestStart", true)
addEventHandler("oHeist > requestStart", root, function(locationId)
	local player = client
	if not okPlayer(player) then return end
	if exports.oFactionScripts:isInLawEnforcementDuty(player) then
		exports.oInfobox:outputInfoBox("Estás em serviço policial.", "error", player)
		return
	end
	if pending[player] then
		exports.oInfobox:outputInfoBox("Já tens um assalto em curso.", "error", player)
		return
	end
	local loc = findLocation(locationId)
	if not loc then
		exports.oInfobox:outputInfoBox("Local inválido.", "error", player)
		return
	end
	if distLoc(player, loc) > HEIST_INTERACT_M + 1.5 then
		exports.oInfobox:outputInfoBox("Aproxima-te do alvo.", "error", player)
		return
	end
	if getElementInterior(player) ~= loc.interior_id or getElementDimension(player) ~= loc.dimension_id then
		exports.oInfobox:outputInfoBox("Dimensão/interior incorrectos.", "error", player)
		return
	end
	local now = getRealTime().timestamp
	if cooldownUntil[loc.id] and now < cooldownUntil[loc.id] then
		local left = cooldownUntil[loc.id] - now
		exports.oInfobox:outputInfoBox(("Cooldown activo (~%d s)."):format(left), "warning", player)
		return
	end
	local crew = crewNear(loc)
	if #crew < loc.min_players then
		exports.oInfobox:outputInfoBox(
			("São necessários pelo menos %d assaltantes por perto (fora polícia em serviço)."):format(loc.min_players),
			"error", player)
		return
	end

	pending[player] = {
		loc = loc,
		participants = crew,
		leader = player,
		phaseIndex = 0,
		sessionEnds = getTickCount() + 520000,
		token = nil,
		disguise = exports.oInventory:hasItem(player, ITEM_DISGUISE),
	}

	exports.oWanted:addCrime(player, "roubo")
	notifyPolice(loc, loc.police_alert_level, pending[player].disguise and "(suspeito mascarado)" or "")
	pcall(function()
		if exports.oEvidence and exports.oEvidence.registerEvidence then
			exports.oEvidence:registerEvidence(
				"assalto_heist",
				loc.pos[1], loc.pos[2], loc.pos[3],
				loc.interior_id or 0,
				loc.dimension_id or 0,
				getElementData(player, "char:id"),
				nil,
				loc.name or "Assalto estratégico",
				2700
			)
		end
	end)

	local timerRef = setTimer(function()
		if pending[player] then
			failHeist(player, "O tempo do assalto esgotou-se.")
		end
	end, 520000, 1)
	pending[player].failTimer = timerRef

	advancePhase(player)
end)

addEvent("oHeist > phaseComplete", true)
addEventHandler("oHeist > phaseComplete", root, function(token, ok)
	local player = client
	if not okPlayer(player) then return end
	local P = pending[player]
	if not P then return end
	if P.leader ~= player then return end
	if not ok then
		failHeist(player, "Cancelaste ou falhaste o minijogo.")
		return
	end
	if token ~= P.token then return end
	local minMs = HEIST_PHASE_MIN_MS[P.phaseName] or 8000
	if getTickCount() - P.phaseStarted < minMs then return end
	advancePhase(player)
end)

addCommandHandler("addheistspot", function(player, _, htype, minR, maxR, cooldownM, minP, alertL, ...)
	if not okPlayer(player) then return end
	if (getElementData(player, "user:admin") or 0) < 7 then return end
	local name = table.concat({ ... }, " ")
	if not htype or name == "" then
		outputChatBox(exports.oCore:getServerPrefix("red-dark", "oHeist", 3) ..
			"Uso: /addheistspot [tipo atm|store|jewelry] [reward_min] [reward_max] [cooldown_min] [min_players] [alerta 1-5] [nome...]",
			player, 255, 255, 255, true)
		return
	end
	if not HEIST_TYPE_PHASES[htype] then
		exports.oInfobox:outputInfoBox("Tipo inválido (atm, store, jewelry).", "error", player)
		return
	end
	minR = tonumber(minR) or 1000
	maxR = tonumber(maxR) or 3000
	cooldownM = tonumber(cooldownM) or 45
	minP = tonumber(minP) or 1
	alertL = tonumber(alertL) or 3
	local x, y, z = getElementPosition(player)
	dbExec(conn, [[INSERT INTO heist_locations
		(type, name, pos, interior_id, dimension_id, cooldown_minutes, reward_min, reward_max, min_players, police_alert_level, is_active)
		VALUES (?,?,?,?,?,?,?,?,?,?,1)]],
		htype, string.sub(name, 1, 80), toJSON({ x, y, z }),
		getElementInterior(player), getElementDimension(player),
		cooldownM, minR, maxR, minP, alertL)
	reloadLocations()
	exports.oInfobox:outputInfoBox("Ponto de assalto registado.", "success", player)
end)
