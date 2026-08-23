--[[ oCarTheft — servidor ]]

local conn
local chopCols = {}
local lockpickFails = {}
local chopSessions = {}
local gpsTimers = {}
local ownerLastInsuranceClaim = {}

local function getTick()
	return getTickCount()
end

local function okPlayer(p)
	return isElement(p) and getElementType(p) == "player" and getElementData(p, "user:loggedin") == true
end

local function distToVeh(p, veh)
	local px, py, pz = getElementPosition(p)
	local vx, vy, vz = getElementPosition(veh)
	return getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
end

local function estimateVehicleValue(model)
	model = tonumber(model) or 400
	return math.min(320000, math.max(8000, model * 380))
end

local function insurancePayoutForModel(model)
	local base = math.floor(estimateVehicleValue(model) * INSURANCE_PORTION_BASE)
	return math.floor(base * INSURANCE_PAYOUT_MULT)
end

local function tryDetector(player)
	if not okPlayer(player) then return end
	local veh = getPedOccupiedVehicle(player)
	if not veh then
		exports.oInfobox:outputInfoBox("Entra num veículo para usar o detector.", "error", player)
		return
	end
	if not getElementData(veh, "veh:isStolen") then
		exports.oInfobox:outputInfoBox("Este carro não está marcado como roubado.", "error", player)
		return
	end
	if not getElementData(veh, "veh:gpsInstalled") then
		exports.oInfobox:outputInfoBox("Não há sinal de rastreador neste veículo.", "info", player)
		return
	end
	if not exports.oInventory:hasItem(player, ITEM_GPS_DETECTOR) then
		exports.oInfobox:outputInfoBox("Precisas do detector de rastreador.", "error", player)
		return
	end
	exports.oInventory:takeItem(player, ITEM_GPS_DETECTOR, 1)
	setElementData(veh, "veh:gpsInstalled", false)
	stopGpsForVehicle(veh)
	exports.oInfobox:outputInfoBox("Removeste o rastreador do veículo.", "success", player)
end

local function findOwnerPlayer(ownerCharId)
	ownerCharId = tonumber(ownerCharId)
	if not ownerCharId then return nil end
	for _, p in ipairs(getElementsByType("player")) do
		if getElementData(p, "char:id") == ownerCharId then
			return p
		end
	end
	return nil
end

local function notifyLawAlarm(msg)
	for _, p in ipairs(getElementsByType("player")) do
		if exports.oFactionScripts:isInLawEnforcementDuty(p) then
			exports.oInfobox:outputInfoBox(msg, "warning", p)
		end
	end
end

local function stopGpsForVehicle(veh)
	local t = gpsTimers[veh]
	if t and isTimer(t) then
		killTimer(t)
	end
	gpsTimers[veh] = nil
end

local function startGpsTracking(veh, ownerCharId)
	if not isElement(veh) then return end
	if not getElementData(veh, "veh:gpsInstalled") then return end
	stopGpsForVehicle(veh)
	ownerCharId = tonumber(ownerCharId)
	local pulses = math.floor(GPS_TRACK_DURATION_MS / GPS_PULSE_MS)
	local count = 0
	gpsTimers[veh] = setTimer(function()
		if not isElement(veh) then
			stopGpsForVehicle(veh)
			return
		end
		count = count + 1
		local ownerP = findOwnerPlayer(ownerCharId)
		if ownerP then
			local x, y, z = getElementPosition(veh)
			triggerClientEvent(ownerP, "oCarTheft > gpsPulse", ownerP, x, y, z, getElementDimension(veh))
			exports.oInfobox:outputInfoBox(
				("Rastreamento: veículo roubado em %.0f, %.0f (pulso %d/%d)"):format(x, y, count, pulses),
				"info", ownerP)
		end
		if count >= pulses then
			stopGpsForVehicle(veh)
		end
	end, GPS_PULSE_MS, pulses)
end

local function triggerAlarm(veh, thief)
	if not isElement(veh) then return end
	local x, y, z = getElementPosition(veh)
	triggerClientEvent(root, "oCarTheft > alarmBlip", resourceRoot, x, y, z, ALARM_DURATION_MS / 1000)
	local blip = createBlipAttachedTo(veh, 0, 2, 255, 0, 0, 255)
	if isElement(blip) then
		setTimer(function()
			if isElement(blip) then destroyElement(blip) end
		end, ALARM_DURATION_MS, 1)
	end
	local thiefName = thief and (getElementData(thief, "char:name") or getPlayerName(thief)):gsub("_", " ") or "Desconhecido"
	notifyLawAlarm(("Alarme de veículo: possível furto (%s)."):format(thiefName))
	local ownerP = findOwnerPlayer(getElementData(veh, "veh:owner"))
	if ownerP then
		exports.oInfobox:outputInfoBox("O alarme do teu veículo disparou!", "error", ownerP)
	end
	pcall(function()
		if exports.oEvidence and exports.oEvidence.registerEvidence then
			local tcid = thief and getElementData(thief, "char:id") or nil
			exports.oEvidence:registerEvidence(
				"alarme_veiculo",
				x, y, z,
				getElementInterior(veh),
				getElementDimension(veh),
				tcid,
				nil,
				"Alarme anti-furto activado",
				2700
			)
		end
	end)
end

local function canAttemptLockpick(veh, thief)
	if not isElement(veh) or getElementType(veh) ~= "vehicle" then return false, "Veículo inválido." end
	if getElementData(veh, "vehicle:tempVeh:isTempVeh") then return false, "Este veículo não pode ser roubado." end
	if tonumber(getElementData(veh, "veh:isFactionVehice") or 0) == 1 then return false, "Veículos de facção não são alvo de furto." end
	if tonumber(getElementData(veh, "veh:protected") or 0) == 1 then return false, "Veículo protegido." end
	if getElementData(veh, "veh:isStolen") then return false, "Este carro já está marcado como roubado." end
	local cid = getElementData(thief, "char:id")
	if tonumber(getElementData(veh, "veh:owner")) == tonumber(cid) then return false, "Este veículo é teu." end
	local secureUntil = tonumber(getElementData(veh, "theft:secureUntil")) or 0
	if secureUntil > getRealTime().timestamp then return false, "Este veículo está em modo seguro temporário." end
	return true
end

local function rebuildChopCols()
	for _, c in ipairs(chopCols) do
		if isElement(c.col) then destroyElement(c.col) end
	end
	chopCols = {}
	dbQuery(function(qh)
		local rows = dbPoll(qh, 0)
		if not rows then return end
		for _, row in ipairs(rows) do
			if tonumber(row.active) == 1 then
				local pos = fromJSON(row.pos or "[0,0,0]")
				if type(pos) == "table" and pos[1] then
					local col = createColSphere(pos[1], pos[2], pos[3], 5)
					setElementInterior(col, tonumber(row.interior_id) or 0)
					setElementDimension(col, tonumber(row.dimension_id) or 0)
					table.insert(chopCols, {
						id = tonumber(row.id),
						org_id = tonumber(row.org_id),
						name = row.name or "Chop shop",
						rate = tonumber(row.rate) or DEFAULT_ORG_RATE,
						col = col,
					})
				end
			end
		end
	end, conn, "SELECT * FROM chop_shops WHERE active = 1")
end

local function pickChopShopForPlayer(player)
	local px, py, pz = getElementPosition(player)
	local pint = getElementInterior(player)
	local pdim = getElementDimension(player)
	for _, shop in ipairs(chopCols) do
		if isElement(shop.col) and pint == getElementInterior(shop.col) and pdim == getElementDimension(shop.col) then
			local cx, cy, cz = getElementPosition(shop.col)
			if getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz) <= 8 then
				return shop
			end
		end
	end
	return nil
end

local function ensureTables()
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS stolen_vehicles (
		id INT AUTO_INCREMENT PRIMARY KEY,
		veh_db_id INT NOT NULL,
		vehicle_model INT NOT NULL DEFAULT 0,
		owner_char_id INT NOT NULL,
		stolen_by INT NOT NULL,
		stolen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		chopped_at TIMESTAMP NULL DEFAULT NULL,
		recovered_at TIMESTAMP NULL DEFAULT NULL,
		insurance_claimed_at TIMESTAMP NULL DEFAULT NULL,
		insurance_ready_unix INT NULL DEFAULT NULL,
		reward_paid INT DEFAULT 0,
		INDEX idx_owner_claim (owner_char_id),
		INDEX idx_veh (veh_db_id)
	)]])
	dbExec(conn, [[CREATE TABLE IF NOT EXISTS chop_shops (
		id INT AUTO_INCREMENT PRIMARY KEY,
		org_id INT NOT NULL,
		name VARCHAR(60),
		pos VARCHAR(512) NOT NULL,
		interior_id INT DEFAULT 0,
		dimension_id INT DEFAULT 0,
		rate FLOAT DEFAULT 0.3,
		active TINYINT DEFAULT 1
	)]])
end

addEventHandler("onResourceStart", resourceRoot, function()
	conn = exports.oMysql:getDBConnection()
	if not conn then
		outputDebugString("[oCarTheft] Sem conexão MySQL.", 1)
		return
	end
	ensureTables()
	rebuildChopCols()
end)

addEventHandler("onElementDestroy", root, function()
	if getElementType(source) ~= "vehicle" then return end
	lockpickFails[source] = nil
	stopGpsForVehicle(source)
end)

addEvent("oCarTheft > requestLockpick", true)
addEventHandler("oCarTheft > requestLockpick", root, function(veh)
	local thief = client
	if not okPlayer(thief) then return end
	if not isElement(veh) or getElementType(veh) ~= "vehicle" then return end
	if distToVeh(thief, veh) > DIST_LOCKPICK_M + 1 then
		exports.oInfobox:outputInfoBox("Aproxima-te mais do veículo.", "error", thief)
		return
	end
	if not exports.oInventory:hasItem(thief, ITEM_LOCKPICK) then
		exports.oInfobox:outputInfoBox("Precisas de uma gazua para tentar arrombar.", "error", thief)
		return
	end
	local ok, why = canAttemptLockpick(veh, thief)
	if not ok then
		exports.oInfobox:outputInfoBox(why, "error", thief)
		return
	end
	triggerClientEvent(thief, "oCarTheft > lockpickAllowed", thief, veh)
end)

addEvent("oCarTheft > lockpickAttempt", true)
addEventHandler("oCarTheft > lockpickAttempt", root, function(veh)
	local thief = client
	if not okPlayer(thief) then return end
	if not isElement(veh) or getElementType(veh) ~= "vehicle" then return end
	if distToVeh(thief, veh) > DIST_LOCKPICK_M + 2 then
		exports.oInfobox:outputInfoBox("Estás demasiado longe.", "error", thief)
		return
	end
	local ok, why = canAttemptLockpick(veh, thief)
	if not ok then
		if why then exports.oInfobox:outputInfoBox(why, "error", thief) end
		return
	end
	if not exports.oInventory:hasItem(thief, ITEM_LOCKPICK) then
		exports.oInfobox:outputInfoBox("Não tens gazua.", "error", thief)
		return
	end
	exports.oInventory:takeItem(thief, ITEM_LOCKPICK, 1)

	local roll = math.random()
	local success = roll <= LOCKPICK_BASE_SUCCESS
	if success then
		lockpickFails[veh] = 0
		local ownerChar = tonumber(getElementData(veh, "veh:owner"))
		local vehDbId = tonumber(getElementData(veh, "veh:id"))
		local model = getElementModel(veh)
		local thiefChar = tonumber(getElementData(thief, "char:id"))
		setElementData(veh, "veh:isStolen", true)
		setElementData(veh, "veh:stolenBy", thiefChar)
		setVehicleLocked(veh, false)
		setElementData(veh, "veh:locked", false)
		local iq = dbQuery(conn,
			"INSERT INTO stolen_vehicles (veh_db_id, vehicle_model, owner_char_id, stolen_by) VALUES (?,?,?,?)",
			vehDbId, model, ownerChar, thiefChar)
		dbPoll(iq, -1)
		local iq2 = dbQuery(conn, "SELECT LAST_INSERT_ID() AS i")
		local ins = dbPoll(iq2, -1)
		local insertId = ins and ins[1] and tonumber(ins[1].i)
		if insertId then
			setElementData(veh, "theft:stolenRowId", insertId)
		end
		exports.oWanted:addCrime(thief, "roubo")
		pcall(function()
			exports.oRank:incrementStat(thiefChar, "arrombamentos", 1)
		end)
		exports.oInfobox:outputInfoBox("Arrombastes o veículo. Leva-o a um desmantelamento.", "success", thief)
		local ownerP = findOwnerPlayer(ownerChar)
		if ownerP then
			exports.oInfobox:outputInfoBox("O teu veículo foi roubado!", "error", ownerP)
		end
		startGpsTracking(veh, ownerChar)
		triggerClientEvent(thief, "oCarTheft > lockpickResult", thief, true, exports.oInventory:hasItem(thief, ITEM_LOCKPICK))
		return
	end

	lockpickFails[veh] = (lockpickFails[veh] or 0) + 1
	if math.random() <= ALARM_ON_FAIL_CHANCE then
		triggerAlarm(veh, thief)
	end
	if lockpickFails[veh] >= LOCKPICK_FAILS_SECURE then
		setElementData(veh, "theft:secureUntil", getRealTime().timestamp + math.floor(SECURE_MODE_MS / 1000))
		lockpickFails[veh] = 0
		exports.oInfobox:outputInfoBox("Demasiadas falhas — o veículo bloqueou fechaduras electrónicas por alguns minutos.", "warning", thief)
	end
	exports.oInfobox:outputInfoBox("Falhaste o arrombamento.", "error", thief)
	triggerClientEvent(thief, "oCarTheft > lockpickResult", thief, false, exports.oInventory:hasItem(thief, ITEM_LOCKPICK))
end)

addEvent("oCarTheft > installGps", true)
addEventHandler("oCarTheft > installGps", root, function(veh)
	local player = client
	if not okPlayer(player) then return end
	if not isElement(veh) or getElementType(veh) ~= "vehicle" then return end
	if tonumber(getElementData(veh, "veh:owner")) ~= tonumber(getElementData(player, "char:id")) then
		exports.oInfobox:outputInfoBox("Só podes instalar no teu veículo.", "error", player)
		return
	end
	if distToVeh(player, veh) > DIST_GPS_INSTALL_M then
		exports.oInfobox:outputInfoBox("Aproxima-te do veículo.", "error", player)
		return
	end
	if getElementData(veh, "veh:gpsInstalled") then
		exports.oInfobox:outputInfoBox("Este veículo já tem rastreador.", "error", player)
		return
	end
	if not exports.oInventory:hasItem(player, ITEM_GPS_TRACKER) then
		exports.oInfobox:outputInfoBox("Precisas de um rastreador GPS.", "error", player)
		return
	end
	exports.oInventory:takeItem(player, ITEM_GPS_TRACKER, 1)
	setElementData(veh, "veh:gpsInstalled", true)
	exports.oInfobox:outputInfoBox("Rastreador instalado.", "success", player)
end)

addEvent("oCarTheft > useDetector", true)
addEventHandler("oCarTheft > useDetector", root, function()
	tryDetector(client)
end)

addEvent("oCarTheft > chopStart", true)
addEventHandler("oCarTheft > chopStart", root, function()
	local player = client
	if not okPlayer(player) then return end
	local shop = pickChopShopForPlayer(player)
	if not shop then
		exports.oInfobox:outputInfoBox("Não estás num desmantelamento autorizado.", "error", player)
		return
	end
	local veh = getPedOccupiedVehicle(player)
	if not veh or getVehicleOccupant(veh, 0) ~= player then
		exports.oInfobox:outputInfoBox("Tens de ser o condutor do veículo roubado.", "error", player)
		return
	end
	if not getElementData(veh, "veh:isStolen") then
		exports.oInfobox:outputInfoBox("Só desmantelas veículos roubados.", "error", player)
		return
	end
	if tonumber(getElementData(veh, "veh:stolenBy")) ~= tonumber(getElementData(player, "char:id")) then
		exports.oInfobox:outputInfoBox("Só quem roubou pode negociar este carro aqui.", "error", player)
		return
	end
	chopSessions[player] = { veh = veh, shop = shop, tick = getTick() }
	triggerClientEvent(player, "oCarTheft > chopBeginUi", player, CHOP_MINIGAME_MS / 1000)
end)

addEvent("oCarTheft > chopFinish", true)
addEventHandler("oCarTheft > chopFinish", root, function(ok)
	local player = client
	if not okPlayer(player) then return end
	local sess = chopSessions[player]
	if not sess then return end
	if not ok then
		chopSessions[player] = nil
		return
	end
	if not isElement(sess.veh) then
		chopSessions[player] = nil
		return
	end
	local veh = sess.veh
	if getPedOccupiedVehicle(player) ~= veh then
		chopSessions[player] = nil
		return
	end
	if getTickCount() - sess.tick < CHOP_MINIGAME_MS - 750 then
		chopSessions[player] = nil
		return
	end
	if not pickChopShopForPlayer(player) then
		chopSessions[player] = nil
		return
	end

	chopSessions[player] = nil

	local shop = sess.shop
	local thiefChar = tonumber(getElementData(player, "char:id"))
	local rowId = tonumber(getElementData(veh, "theft:stolenRowId"))
	if not rowId then
		exports.oInfobox:outputInfoBox("Registo de furto inválido. Impossível desmantelar.", "error", player)
		return
	end

	local base = math.random(CHOP_PAYOUT_MIN, CHOP_PAYOUT_MAX)
	local thiefPay = math.floor(base * CHOP_THIEF_SHARE)
	local orgPay = math.floor(base * (shop.rate or DEFAULT_ORG_RATE))
	local rt = getRealTime().timestamp
	local ready = rt + INSURANCE_READY_DELAY_S

	dbExec(conn,
		"UPDATE stolen_vehicles SET chopped_at = CURRENT_TIMESTAMP, insurance_ready_unix = ? WHERE id = ? AND chopped_at IS NULL",
		ready, rowId)

	setElementData(player, "char:money", (getElementData(player, "char:money") or 0) + thiefPay)
	pcall(function()
		exports.oDashboard:setFactionBankMoney(shop.org_id, orgPay, "add")
	end)
	pcall(function()
		exports.oRank:incrementStat(thiefChar, "carros_roubados", 1)
	end)
	exports.oInfobox:outputInfoBox(("Recebeste R$%d pelo desmantelamento."):format(thiefPay), "success", player)
	stopGpsForVehicle(veh)
	pcall(function()
		exports.oVehicle:deleteVehicle(veh)
	end)
end)

addEvent("oCarTheft > insurancePull", true)
addEventHandler("oCarTheft > insurancePull", root, function()
	local player = client
	if not okPlayer(player) then return end
	local cid = tonumber(getElementData(player, "char:id"))
	dbQuery(function(qh)
		local rows = dbPoll(qh, 0)
		triggerClientEvent(player, "oCarTheft > insuranceData", player, rows or {})
	end, conn,
		[[SELECT id, veh_db_id, vehicle_model, chopped_at, insurance_claimed_at, insurance_ready_unix
		  FROM stolen_vehicles
		  WHERE owner_char_id = ? AND chopped_at IS NOT NULL AND insurance_claimed_at IS NULL
		  ORDER BY id DESC]], cid)
end)

addEvent("oCarTheft > insuranceClaim", true)
addEventHandler("oCarTheft > insuranceClaim", root, function(rowId)
	local player = client
	if not okPlayer(player) then return end
	rowId = tonumber(rowId)
	local cid = tonumber(getElementData(player, "char:id"))
	local now = getRealTime().timestamp
	local last = ownerLastInsuranceClaim[cid] or 0
	if now - last < CLAIM_COOLDOWN_OWNER_S then
		exports.oInfobox:outputInfoBox("Ainda não podes reclamar outro seguro (cooldown 24h).", "error", player)
		return
	end
	dbQuery(function(qh)
		local rows = dbPoll(qh, 0)
		if not rows or not rows[1] then
			exports.oInfobox:outputInfoBox("Registo inválido.", "error", player)
			return
		end
		local row = rows[1]
		if tonumber(row.owner_char_id) ~= cid then return end
		if row.insurance_claimed_at then return end
		local ready = tonumber(row.insurance_ready_unix) or 0
		if now < ready then
			exports.oInfobox:outputInfoBox("O seguro ainda está a processar. Aguarda o tempo indicado.", "warning", player)
			return
		end
		local pay = insurancePayoutForModel(tonumber(row.vehicle_model) or 400)
		dbExec(conn, "UPDATE stolen_vehicles SET insurance_claimed_at = CURRENT_TIMESTAMP WHERE id = ?", rowId)
		ownerLastInsuranceClaim[cid] = now
		setElementData(player, "char:money", (getElementData(player, "char:money") or 0) + pay)
		exports.oInfobox:outputInfoBox(("Seguro pago: R$%d transferidos para ti."):format(pay), "success", player)
		triggerClientEvent(player, "oCarTheft > insuranceDataRefresh", player)
	end, conn,
		"SELECT id, owner_char_id, vehicle_model, insurance_ready_unix, insurance_claimed_at FROM stolen_vehicles WHERE id = ? AND owner_char_id = ? LIMIT 1",
		rowId, cid)
end)

addCommandHandler("addchopshop", function(player, _, orgId, ...)
	if not okPlayer(player) then return end
	if (getElementData(player, "user:admin") or 0) < 7 then return end
	orgId = tonumber(orgId)
	local name = table.concat({ ... }, " ")
	if not orgId or name == "" then
		outputChatBox(exports.oCore:getServerPrefix("red-dark", "oCarTheft", 3) .. "Uso: /addchopshop [org_id] [nome]", player, 255, 255, 255, true)
		return
	end
	local x, y, z = getElementPosition(player)
	local pos = toJSON({ x, y, z })
	dbExec(conn,
		"INSERT INTO chop_shops (org_id, name, pos, interior_id, dimension_id, rate, active) VALUES (?,?,?,?,?,?,1)",
		orgId, string.sub(name, 1, 60), pos, getElementInterior(player), getElementDimension(player), DEFAULT_ORG_RATE)
	rebuildChopCols()
	exports.oInfobox:outputInfoBox("Chop shop registado neste interior/dimensão.", "success", player)
end)

addCommandHandler("seguro", function(player)
	if not okPlayer(player) then return end
	triggerClientEvent(player, "oCarTheft > openInsuranceUi", player)
end)

addCommandHandler("instalarrastreador", function(player)
	if not okPlayer(player) then return end
	triggerClientEvent(player, "oCarTheft > promptNearestOwnedVehicle", player, "gps")
end)

addCommandHandler("detectorrastreador", function(player)
	tryDetector(player)
end)
