--[[ oTribunal — servidor (MVP) ]]

local conn

local function okPlayer(p)
	return isElement(p) and getElementType(p) == "player" and getElementData(p, "user:loggedin") == true
end

local function findOnline(cid)
	cid = tonumber(cid)
	if not cid then return nil end
	for _, p in ipairs(getElementsByType("player")) do
		if okPlayer(p) and getElementData(p, "char:id") == cid then
			return p
		end
	end
	return nil
end

local function ensureTables()
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS tribunal_case (
		id INT AUTO_INCREMENT PRIMARY KEY,
		prisoner_char_id INT NOT NULL,
		lawyer_char_id INT NOT NULL,
		status VARCHAR(20) DEFAULT 'open',
		opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		closed_at TIMESTAMP NULL,
		verdict VARCHAR(24) NULL,
		INDEX idx_open_prisoner (prisoner_char_id, status)
	)]])
end

local function countOpenForPrisoner(prisonerCid)
	local qh = dbQuery(conn, "SELECT COUNT(*) AS c FROM tribunal_case WHERE prisoner_char_id = ? AND status = 'open'", prisonerCid)
	local r = dbPoll(qh, -1)
	return r and r[1] and tonumber(r[1].c) or 0
end

addEventHandler("onResourceStart", resourceRoot, function()
	conn = exports.oMysql:getDBConnection()
	if not conn then
		outputDebugString("[oTribunal] Sem MySQL.", 1)
		return
	end
	ensureTables()
end)

addCommandHandler("tribunal", function(player, _, sub, arg1, ...)
	if not okPlayer(player) then return end
	sub = sub and string.lower(sub) or ""
	local prefix = exports.oCore:getServerPrefix("server", "Tribunal", 3)

	if sub == "pedir" or sub == "requerer" then
		local pid = tonumber(arg1)
		if not pid then
			outputChatBox(prefix .. "Uso: /tribunal pedir [char_id_recluso]", player, 255, 255, 255, true)
			return
		end
		if not exports.oDashboard:isPlayerInFaction(player, TRIBUNAL_FACTION_OAB) then
			exports.oInfobox:outputInfoBox("Apenas advogados da OAB podem requerer sessão.", "error", player)
			return
		end
		if countOpenForPrisoner(pid) > 0 then
			exports.oInfobox:outputInfoBox("Já existe pedido aberto para este recluso.", "warning", player)
			return
		end
		local prisoner = findOnline(pid)
		if not prisoner then
			exports.oInfobox:outputInfoBox("Recluso tem de estar online para MVP do tribunal.", "error", player)
			return
		end
		if not exports.oWanted:isWanted(prisoner) then
			exports.oInfobox:outputInfoBox("Este personagem não está marcado como procurado.", "error", player)
			return
		end
		local lid = getElementData(player, "char:id")
		dbExec(conn,
			"INSERT INTO tribunal_case (prisoner_char_id, lawyer_char_id, status) VALUES (?, ?, 'open')",
			pid, lid)
		exports.oInfobox:outputInfoBox(("Pedido de tribunal registado (recluso #%d). Aguarda juiz/admin."):format(pid), "success", player)
		local pch = findOnline(pid)
		if pch then
			exports.oInfobox:outputInfoBox("Um advogado requereu revisão judicial do teu caso.", "info", pch)
		end
		return
	end

	if sub == "lista" or sub == "sessoes" then
		if (getElementData(player, "user:admin") or 0) < TRIBUNAL_ADMIN_VEREDITO then
			return
		end
		dbQuery(function(qh)
			local rows = dbPoll(qh, 0) or {}
			outputChatBox(prefix .. ("Sessões abertas: %d"):format(#rows), player, 255, 255, 255, true)
			for _, row in ipairs(rows) do
				outputChatBox((" ID %d | recluso %d | advogado %d"):format(
					tonumber(row.id), tonumber(row.prisoner_char_id), tonumber(row.lawyer_char_id)), player, 230, 230, 255, true)
			end
		end, conn, "SELECT id, prisoner_char_id, lawyer_char_id FROM tribunal_case WHERE status = 'open' ORDER BY id DESC LIMIT 25")
		return
	end

	if sub == "absolver" or sub == "absolvido" then
		local caseId = tonumber(arg1)
		if not caseId then
			outputChatBox(prefix .. "Uso: /tribunal absolver [id_sessão]", player, 255, 255, 255, true)
			return
		end
		if (getElementData(player, "user:admin") or 0) < TRIBUNAL_ADMIN_VEREDITO then
			exports.oInfobox:outputInfoBox("Apenas administradores podem proferir veredito (MVP).", "error", player)
			return
		end
		dbQuery(function(qh)
			local rows = dbPoll(qh, 0)
			if not rows or not rows[1] then
				exports.oInfobox:outputInfoBox("Sessão não encontrada.", "error", player)
				return
			end
			local row = rows[1]
			if row.status ~= "open" then
				exports.oInfobox:outputInfoBox("Esta sessão já foi encerrada.", "warning", player)
				return
			end
			local pris = findOnline(tonumber(row.prisoner_char_id))
			if pris then
				exports.oWanted:clearWanted(pris, player, true)
				exports.oInfobox:outputInfoBox("Absolvido — wanted anulado.", "success", pris)
			end
			dbExec(conn, "UPDATE tribunal_case SET status='closed', verdict='absolved', closed_at=NOW() WHERE id=?", caseId)
			exports.oInfobox:outputInfoBox("Veredito: absolvição registada.", "success", player)
		end, conn, "SELECT * FROM tribunal_case WHERE id = ? LIMIT 1", caseId)
		return
	end

	if sub == "culpar" or sub == "culpado" then
		local caseId = tonumber(arg1)
		if not caseId then
			outputChatBox(prefix .. "Uso: /tribunal culpar [id_sessão]", player, 255, 255, 255, true)
			return
		end
		if (getElementData(player, "user:admin") or 0) < TRIBUNAL_ADMIN_VEREDITO then
			return
		end
		dbQuery(function(qh)
			local rows = dbPoll(qh, 0)
			if not rows or not rows[1] or rows[1].status ~= "open" then
				exports.oInfobox:outputInfoBox("Sessão inválida.", "error", player)
				return
			end
			dbExec(conn, "UPDATE tribunal_case SET status='closed', verdict='guilty', closed_at=NOW() WHERE id=?", caseId)
			local pris = findOnline(tonumber(rows[1].prisoner_char_id))
			if pris then
				exports.oInfobox:outputInfoBox("Tribunal: pena mantida ou agravada (RP).", "warning", pris)
			end
			exports.oInfobox:outputInfoBox("Veredito: culpa registada.", "success", player)
		end, conn, "SELECT * FROM tribunal_case WHERE id = ? LIMIT 1", caseId)
		return
	end

	outputChatBox(prefix .. "Comandos: /tribunal pedir [char_id] | admin: lista | absolver | culpar [id]", player, 255, 255, 255, true)
end)
