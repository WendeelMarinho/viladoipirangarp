--[[ oElections — servidor ]]

local conn

local function okPlayer(p)
	return isElement(p) and getElementType(p) == "player" and getElementData(p, "user:loggedin") == true
end

local function nowTs()
	return getRealTime().timestamp
end

local function ensureTables()
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS election_round (
		id INT AUTO_INCREMENT PRIMARY KEY,
		phase VARCHAR(16) NOT NULL DEFAULT 'campaign',
		campaign_end_unix BIGINT NOT NULL,
		vote_end_unix BIGINT NOT NULL,
		winner_char_id INT NULL,
		created_unix BIGINT NOT NULL,
		INDEX idx_phase (phase)
	)]])
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS election_candidate (
		election_id INT NOT NULL,
		char_id INT NOT NULL,
		char_name VARCHAR(72) NOT NULL,
		PRIMARY KEY (election_id, char_id),
		INDEX idx_el (election_id)
	)]])
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS election_vote (
		election_id INT NOT NULL,
		voter_char_id INT NOT NULL,
		candidate_char_id INT NOT NULL,
		PRIMARY KEY (election_id, voter_char_id),
		INDEX idx_elc (election_id, candidate_char_id)
	)]])
end

local function getActiveElectionRow()
	local qh = dbQuery(conn, "SELECT * FROM election_round WHERE phase <> 'closed' ORDER BY id DESC LIMIT 1")
	local r = dbPoll(qh, -1)
	return r and r[1] or nil
end

local function announceAll(msg)
	local prefix = exports.oCore:getServerPrefix("server", "Eleições", 3)
	for _, p in ipairs(getElementsByType("player")) do
		if okPlayer(p) then
			outputChatBox(prefix .. msg, p, 255, 255, 255, true)
		end
	end
end

local function closeAndTally(electionId)
	dbQuery(function(qh)
		local tall = dbPoll(qh, 0)
		local winnerCid, best = nil, -1
		for _, row in ipairs(tall or {}) do
			local c = tonumber(row.c) or 0
			local cid = tonumber(row.candidate_char_id)
			if c > best then
				best = c
				winnerCid = cid
			end
		end
		if winnerCid and best > 0 then
			dbExec(conn, "UPDATE election_round SET phase='closed', winner_char_id=? WHERE id=?", winnerCid, electionId)
			local winP = nil
			for _, p in ipairs(getElementsByType("player")) do
				if okPlayer(p) and getElementData(p, "char:id") == winnerCid then
					winP = p
					break
				end
			end
			local wname = winP and (getElementData(winP, "char:name") or getPlayerName(winP)):gsub("_", " ") or ("#" .. tostring(winnerCid))
			announceAll(("Votação encerrada. Vencedor: %s (%d votos). Promover a Prefeito (fac. %d) pode ser feito manualmente pelo staff.")
				:format(wname, best, ELECTION_FACTION_PREFEITURA))
			if winP then
				exports.oInfobox:outputInfoBox("Ganhaste as eleições municipais!", "success", winP)
				pcall(function()
					exports.oRank:incrementStat(winnerCid, "eleicoes_vencidas", 1)
				end)
			end
		else
			dbExec(conn, "UPDATE election_round SET phase='closed' WHERE id=?", electionId)
			announceAll("Votação encerrada sem votos válidos.")
		end
	end, conn,
		"SELECT candidate_char_id, COUNT(*) AS c FROM election_vote WHERE election_id = ? GROUP BY candidate_char_id ORDER BY c DESC",
		electionId)
end

local function tickPhases()
	local row = getActiveElectionRow()
	if not row then return end
	local ts = nowTs()
	local id = tonumber(row.id)
	if row.phase == "campaign" and ts >= tonumber(row.campaign_end_unix) then
		dbExec(conn, "UPDATE election_round SET phase='voting' WHERE id=?", id)
		announceAll("Campanha encerrada. A votação está aberta até ao fim do período definido.")
	elseif row.phase == "voting" and ts >= tonumber(row.vote_end_unix) then
		closeAndTally(id)
	end
end

addEventHandler("onResourceStart", resourceRoot, function()
	conn = exports.oMysql:getDBConnection()
	if not conn then
		outputDebugString("[oElections] Sem MySQL.", 1)
		return
	end
	ensureTables()
	setTimer(tickPhases, 45000, 0)
end)

addCommandHandler("eleicao", function(player, _, sub, a1, a2)
	if not okPlayer(player) then return end
	sub = sub and string.lower(sub) or ""
	local prefix = exports.oCore:getServerPrefix("server", "Eleições", 3)

	if sub == "iniciar" then
		if (getElementData(player, "user:admin") or 0) < 7 then return end
		if getActiveElectionRow() then
			exports.oInfobox:outputInfoBox("Já existe uma eleição activa.", "error", player)
			return
		end
		local hc = tonumber(a1) or 72
		local hv = tonumber(a2) or 24
		local t0 = nowTs()
		local ce = t0 + hc * 3600
		local ve = ce + hv * 3600
		dbExec(conn,
			"INSERT INTO election_round (phase, campaign_end_unix, vote_end_unix, created_unix) VALUES ('campaign', ?, ?, ?)",
			ce, ve, t0)
		announceAll(("Nova eleição municipal: campanha %d h, depois votação %d h. Usa /candidatar durante a campanha."):format(hc, hv))
		exports.oInfobox:outputInfoBox("Eleição criada.", "success", player)
		return
	end

	if sub == "info" or sub == "" then
		local row = getActiveElectionRow()
		if not row then
			outputChatBox(prefix .. "Nenhuma eleição activa.", player, 200, 200, 220, true)
			return
		end
		local ts = nowTs()
		local phase = row.phase
		outputChatBox(prefix .. ("Fase: %s | campanha até %s | votação até %s"):format(
			phase,
			os.date("!%Y-%m-%d %H:%M UTC", tonumber(row.campaign_end_unix) or 0),
			os.date("!%Y-%m-%d %H:%M UTC", tonumber(row.vote_end_unix) or 0)
		), player, 230, 230, 250, true)

		dbQuery(function(qh)
			local cands = dbPoll(qh, 0) or {}
			if #cands == 0 then
				outputChatBox(prefix .. "Sem candidatos.", player, 200, 200, 220, true)
				return
			end
			local id = tonumber(row.id)
			dbQuery(function(qh2)
				local votes = dbPoll(qh2, 0) or {}
				local vc = {}
				for _, v in ipairs(votes) do
					vc[tonumber(v.candidate_char_id)] = tonumber(v.c) or 0
				end
				for _, c in ipairs(cands) do
					local cid = tonumber(c.char_id)
					outputChatBox((" Candidato #%d %s — votos: %d"):format(cid, tostring(c.char_name), vc[cid] or 0), player, 220, 230, 255, true)
				end
			end, conn,
				"SELECT candidate_char_id, COUNT(*) AS c FROM election_vote WHERE election_id = ? GROUP BY candidate_char_id",
				id)
		end, conn, "SELECT char_id, char_name FROM election_candidate WHERE election_id = ?", tonumber(row.id))
		return
	end

	if sub == "candidatar" then
		local row = getActiveElectionRow()
		if not row or row.phase ~= "campaign" then
			exports.oInfobox:outputInfoBox("Não há campanha activa.", "error", player)
			return
		end
		if nowTs() >= tonumber(row.campaign_end_unix) then
			exports.oInfobox:outputInfoBox("A campanha já terminou.", "warning", player)
			return
		end
		local cid = getElementData(player, "char:id")
		local cname = (getElementData(player, "char:name") or getPlayerName(player)):gsub("_", " ")
		local eid = tonumber(row.id)
		dbExec(conn,
			"INSERT IGNORE INTO election_candidate (election_id, char_id, char_name) VALUES (?,?,?)",
			eid, cid, cname:sub(1, 72))
		exports.oInfobox:outputInfoBox("Candidatura registada.", "success", player)
		return
	end

	if sub == "desistir" then
		local row = getActiveElectionRow()
		if not row or row.phase ~= "campaign" then return end
		local cid = getElementData(player, "char:id")
		dbExec(conn, "DELETE FROM election_candidate WHERE election_id=? AND char_id=?", tonumber(row.id), cid)
		exports.oInfobox:outputInfoBox("Retiraste a candidatura.", "info", player)
		return
	end

	if sub == "votar" then
		local row = getActiveElectionRow()
		if not row or row.phase ~= "voting" then
			exports.oInfobox:outputInfoBox("Não há votação activa.", "error", player)
			return
		end
		local cand = tonumber(a1)
		if not cand then
			outputChatBox(prefix .. "Uso: /eleicao votar [char_id_candidato]", player, 255, 255, 255, true)
			return
		end
		local voter = getElementData(player, "char:id")
		local eid = tonumber(row.id)
		local qh = dbQuery(conn, "SELECT 1 FROM election_candidate WHERE election_id=? AND char_id=? LIMIT 1", eid, cand)
		local ok = dbPoll(qh, -1)
		if not ok or not ok[1] then
			exports.oInfobox:outputInfoBox("Esse ID não é candidato nesta eleição.", "error", player)
			return
		end
		local q2 = dbQuery(conn, "SELECT 1 FROM election_vote WHERE election_id=? AND voter_char_id=? LIMIT 1", eid, voter)
		local dup = dbPoll(q2, -1)
		if dup and dup[1] then
			exports.oInfobox:outputInfoBox("Já votaste nesta eleição.", "error", player)
			return
		end
		dbExec(conn, "INSERT INTO election_vote (election_id, voter_char_id, candidate_char_id) VALUES (?,?,?)", eid, voter, cand)
		exports.oInfobox:outputInfoBox("Voto registado.", "success", player)
		return
	end

	outputChatBox(prefix .. "Usa /eleicao info | /eleicao candidatar | /eleicao votar [id] | admin: /eleicao iniciar [hCamp] [hVote]", player, 255, 255, 255, true)
end)
