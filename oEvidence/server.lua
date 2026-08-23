--[[ oEvidence — servidor ]]

local conn

local function okPlayer(p)
	return isElement(p) and getElementType(p) == "player" and getElementData(p, "user:loggedin") == true
end

local function lawInvestigator(p)
	return okPlayer(p) and exports.oFactionScripts:isInLawEnforcementDuty(p)
end

local function ensureTables()
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS forensic_evidence (
		id INT AUTO_INCREMENT PRIMARY KEY,
		kind VARCHAR(40) NOT NULL,
		pos VARCHAR(512) NOT NULL,
		interior_id INT DEFAULT 0,
		dimension_id INT DEFAULT 0,
		suspect_char_id INT NULL,
		reporter_char_id INT NULL,
		note VARCHAR(240),
		created_unix BIGINT NOT NULL,
		expires_unix BIGINT NOT NULL,
		INDEX idx_exp (expires_unix),
		INDEX idx_dim_int (dimension_id, interior_id)
	)]])
end

local function purgeExpired()
	local now = getRealTime().timestamp
	dbExec(conn, "DELETE FROM forensic_evidence WHERE expires_unix < ?", now)
end

function registerEvidence(kind, x, y, z, interiorId, dimensionId, suspectCharId, reporterCharId, note, ttlSec)
	if not conn then return false end
	kind = tostring(kind or "desconhecido"):sub(1, 40)
	note = tostring(note or ""):sub(1, 240)
	ttlSec = tonumber(ttlSec) or EVIDENCE_DEFAULT_TTL_S
	local now = getRealTime().timestamp
	local exp = now + math.max(120, ttlSec)
	x, y, z = tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0
	interiorId = tonumber(interiorId) or 0
	dimensionId = tonumber(dimensionId) or 0
	suspectCharId = suspectCharId and tonumber(suspectCharId) or nil
	reporterCharId = reporterCharId and tonumber(reporterCharId) or nil
	dbExec(conn, [[INSERT INTO forensic_evidence
		(kind, pos, interior_id, dimension_id, suspect_char_id, reporter_char_id, note, created_unix, expires_unix)
		VALUES (?,?,?,?,?,?,?,?,?)]],
		kind, toJSON({ x, y, z }), interiorId, dimensionId, suspectCharId, reporterCharId, note, now, exp)
	return true
end

local function nearestSuspectFromNick(observer, partial)
	if not partial or partial == "" then return nil end
	partial = string.lower(partial)
	local ox, oy, oz = getElementPosition(observer)
	local best, bestD
	for _, p in ipairs(getElementsByType("player")) do
		if okPlayer(p) and p ~= observer then
			local n = string.lower(getPlayerName(p):gsub("_", " "))
			if string.find(n, partial, 1, true) then
				local px, py, pz = getElementPosition(p)
				local d = getDistanceBetweenPoints3D(ox, oy, oz, px, py, pz)
				if d <= EVIDENCE_WITNESS_LINK_M and (not bestD or d < bestD) then
					best, bestD = p, d
				end
			end
		end
	end
	return best
end

addEventHandler("onResourceStart", resourceRoot, function()
	conn = exports.oMysql:getDBConnection()
	if not conn then
		outputDebugString("[oEvidence] Sem MySQL.", 1)
		return
	end
	ensureTables()
	setTimer(purgeExpired, 120000, 0)
end)

addCommandHandler("testemunho", function(player, _, ...)
	local tok = { ... }
	if #tok == 0 then
		outputChatBox(exports.oCore:getServerPrefix("server", "Evidência", 3) ..
			"Uso: /testemunho [nota...] ou /testemunho [nickSuspeito] [nota...]", player, 255, 255, 255, true)
		return
	end
	if not okPlayer(player) then return end
	local suspectId = nil
	local noteStart = 1
	if #tok >= 2 then
		local cand = nearestSuspectFromNick(player, tok[1])
		if cand then
			suspectId = getElementData(cand, "char:id")
			noteStart = 2
		end
	end
	local note = table.concat(tok, " ", noteStart):sub(1, 240)
	if note == "" then
		exports.oInfobox:outputInfoBox("Escreve uma descrição do que observaste.", "error", player)
		return
	end
	local x, y, z = getElementPosition(player)
	registerEvidence(
		"testemunho_ic",
		x, y, z,
		getElementInterior(player),
		getElementDimension(player),
		suspectId,
		getElementData(player, "char:id"),
		note,
		EVIDENCE_DEFAULT_TTL_S
	)
	exports.oInfobox:outputInfoBox("O teu relato foi registado para investigação.", "success", player)
end)

addCommandHandler("investigar", function(player)
	if not lawInvestigator(player) then
		exports.oInfobox:outputInfoBox("Apenas agentes em serviço podem usar isto.", "error", player)
		return
	end
	local px, py, pz = getElementPosition(player)
	local pint = getElementInterior(player)
	local pdim = getElementDimension(player)
	local now = getRealTime().timestamp
	dbQuery(function(qh)
		local rows = dbPoll(qh, 0) or {}
		local hits = {}
		for _, row in ipairs(rows) do
			if tonumber(row.dimension_id) == pdim and tonumber(row.interior_id) == pint then
				local pos = fromJSON(row.pos or "[0,0,0]")
				if type(pos) == "table" and pos[1] then
					local d = getDistanceBetweenPoints3D(px, py, pz, pos[1], pos[2], pos[3])
					if d <= EVIDENCE_INV_RADIUS_M then
						row._dist = d
						hits[#hits + 1] = row
					end
				end
			end
		end
		table.sort(hits, function(a, b) return (a._dist or 0) < (b._dist or 0) end)
		local prefix = exports.oCore:getServerPrefix("blue-dark", "Forense", 3)
		if #hits == 0 then
			outputChatBox(prefix .. "Nenhuma evidência activa neste perímetro.", player, 255, 255, 255, true)
			return
		end
		outputChatBox(prefix .. ("~%d registo(s) nas últimas horas:"):format(#hits), player, 255, 255, 255, true)
		for i = 1, math.min(18, #hits) do
			local e = hits[i]
			outputChatBox(("#%d [%s] dist %.1fm | suspeito:%s | repórter:%s | %s"):format(
				tonumber(e.id),
				tostring(e.kind),
				e._dist or 0,
				tostring(e.suspect_char_id or "—"),
				tostring(e.reporter_char_id or "—"),
				tostring(e.note or ""):sub(1, 120)
			), player, 220, 220, 240, true)
		end
	end, conn,
		"SELECT id, kind, pos, suspect_char_id, reporter_char_id, note FROM forensic_evidence WHERE expires_unix > ?",
		now)
end)

addCommandHandler("indiciar", function(player, _, charIdArg)
	if not lawInvestigator(player) then
		exports.oInfobox:outputInfoBox("Apenas investigadores em serviço.", "error", player)
		return
	end
	local cid = tonumber(charIdArg)
	if not cid then
		outputChatBox(exports.oCore:getServerPrefix("red-dark", "Evidência", 3) ..
			"Uso: /indiciar [char_id] — aplicável com suspeito online.", player, 255, 255, 255, true)
		return
	end
	local suspect = nil
	for _, p in ipairs(getElementsByType("player")) do
		if okPlayer(p) and getElementData(p, "char:id") == cid then
			suspect = p
			break
		end
	end
	if not suspect then
		exports.oInfobox:outputInfoBox("Suspeito não está online — mandado IC continua por outros meios.", "warning", player)
		return
	end
	exports.oWanted:addCrime(suspect, "crime_org")
	exports.oInfobox:outputInfoBox(("Indiciamento registado contra ID %d (crime organizado)."):format(cid), "success", player)
	local px, py, pz = getElementPosition(player)
	registerEvidence(
		"mandado_indiciamento",
		px, py, pz,
		getElementInterior(player),
		getElementDimension(player),
		cid,
		getElementData(player, "char:id"),
		"Indiciamento formal em campo",
		EVIDENCE_DEFAULT_TTL_S * 6
	)
end)
