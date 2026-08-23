local whitelistEnabled = true
local playerIDs = {}
local pendingSerials = {}

local blacklistSerials = {
	["4ED87BD186DED0CF1A7BEFBDF56E48A2"] = true, --Ted
	["AAC7994A6E7E92FC9BD08397FD0BFDB2"] = true, --Ted haverja
}

function setWhiteListEnable()
	whitelistEnabled = true
end 
addEvent("setWhiteListEnable",true)
addEventHandler("setWhiteListEnable",root,setWhiteListEnable)

setFPSLimit(60)
setGameType("Vale do Ipiranga RP")
setMapName("Vale do Ipiranga RP")

addEventHandler("onResourceStart", resourceRoot, function()
	--outputChatBox("#e0361f[Vale do Ipiranga RP - Whitelist]: #ffffff"..serverColor.."bela".." #fffffftentou conectar. (/pendingserials, /acceptserial)", root, 255, 255, 255, true)
	local players = getElementsByType("player")
	for i = 1, #players do
		playerIDs[i] = players[i]
		setElementData(players[i], "playerid", i)
	end
end)

addEventHandler("onPlayerConnect", getRootElement(), function(playerName, _, _, playerSerial)
	if blacklistSerials[playerSerial] then 
		cancelEvent(true)
	end

	if not whitelistEnabled then return end
	local ok, isDev = pcall(function() return exports.oAdmin:isSerialDeveloper(playerSerial) end)
	if not (ok and isDev) then
		cancelEvent(true, "Em desenvolvimento...")

		for k, v in ipairs(getElementsByType("player")) do 
			if exports.oAdmin:isPlayerDeveloper(v) then 
				outputChatBox("#e0361f[Vale do Ipiranga RP - Whitelist]: #ffffff"..serverColor..playerName.." #fffffftentou conectar. (/pendingserials, /acceptserial)", v, 255, 255, 255, true)
			end 
		end

		for k, v in pairs(pendingSerials) do
			if v[2] == playerSerial then
				return
			end
		end
		table.insert(pendingSerials, {playerName, playerSerial})
    end
end)

addEventHandler("onPlayerJoin", getRootElement(), function()
	for i = 1, getMaxPlayers() do
		if not playerIDs[i] then
			playerIDs[i] = source
			setElementData(source, "playerid", i)
			break
		end
	end
end)

addEventHandler("onPlayerQuit", getRootElement(), function()
	for i = 1, getMaxPlayers() do
		if playerIDs[i] == source then
			playerIDs[i] = nil
			break
		end
	end
end)

addEventHandler("onPlayerChangeNick", getRootElement(), function()
	cancelEvent()
end)

addEventHandler("onPlayerSpawn", getRootElement(), function()
	setPedHeadless(source, false)
	setElementData(source, "char:health", 100)
	setElementData(source, "char:hunger", 100)
	setElementData(source, "char:thirst", 100)
end)

local deathTypes = {
	[19] = "explosão",
	[37] = "queimadura",
	[49] = "acidente de veículo",
	[50] = "acidente de veículo",
	[51] = "explosão",
	[52] = "atropelamento",
	[53] = "afogamento",
	[54] = "queda",
	[55] = "desconhecido",
	[56] = "briga",
	[57] = "arma",
	[59] = "tanque",
	[63] = "explosão",
	[0] = "briga"
}

addEventHandler("onPlayerWasted", getRootElement(), function(_, killer, weapon, bodypart, stealth)
	if not getElementData(source, "customDeath") then
		local deathReason = "desconhecido"
		if tonumber(weapon) then
			deathReason = deathTypes[weapon]

			if not deathReason then
				local weaponName = getWeaponNameFromID(weapon)
				--if weaponNames[weaponName] then
					--weaponName = weaponNames[weaponName]

					if deathReason == "acidente de veículo" then
						deathReason = "acidente de veículo"
					else
						deathReason = "arma (" .. weaponName .. ")"
					end
				--else
				--	deathReason = "fegyver (" .. weaponName .. ")"
				--end
			elseif deathReason == "unknown" then
				deathReason = "desconhecido"
			end
		end
		if bodyPart == 9 then
			deathReason = deathReason .. " [tiro na cabeça]"
		end
        setElementData(source, "customDeath", deathReason)
    end
	triggerClientEvent(getRootElement(), "sendKillLog", getRootElement(), source, killer, weapon, bodypart)
end)

addEvent("killPlayer", true)
addEventHandler("killPlayer", getRootElement(), function(atk, wpn, bdp)
	setPedHeadless(client, true)
	killPed(client, atk, wpn, bdp)
end)

addCommandHandler("pendingserials", function(thePlayer)
	if exports.oAdmin:isPlayerDeveloper(thePlayer) then
		if #pendingSerials == 0 then
			outputChatBox("Não há seriais pendentes para aceitar.", thePlayer, 255, 255, 255)
			return
		end
			
		for k, v in pairs(pendingSerials) do
			outputChatBox("["..k.."] - "..v[1], thePlayer, 255, 255, 255)
		end
	end
end)

addCommandHandler("acceptserial", function(thePlayer, cmd, id)
	if exports.oAdmin:isPlayerDeveloper(thePlayer) then
		if tonumber(id) then
			local entry = pendingSerials[tonumber(id)]
			if entry then
				exports.oAdmin:addWhitelistedSerial(entry[2], entry[1])
				table.remove(pendingSerials, tonumber(id))
				outputChatBox("Serial adicionado à whitelist!", thePlayer, 255, 255, 255)
			else
				outputChatBox("Não existe pedido de serial com esse número.", thePlayer, 255, 255, 255)
			end
		else
			outputChatBox("/acceptserial [id]", thePlayer, 255, 255, 255)
		end
	end
end)

addCommandHandler("togwhitelist", function(thePlayer)
	if exports.oAdmin:isPlayerDeveloper(thePlayer) then
		if whitelistEnabled then
			outputChatBox("Whitelist desativada!", thePlayer, 255, 255, 255)
		else
			outputChatBox("Whitelist ativada!", thePlayer, 255, 255, 255)
		end
		whitelistEnabled = not whitelistEnabled
	end
end)

addCommandHandler("elemdata", function(thePlayer)
	if exports.oAdmin:isPlayerDeveloper(thePlayer) then
		local veh = getPedOccupiedVehicle(thePlayer)
		if veh then
			data = getAllElementData(veh)
		else
			data = getAllElementData(thePlayer)
		end
		for k, v in pairs(data) do
			outputConsole(k..": "..tostring(v), thePlayer)
		end
	end
end)

addEvent("sendMoney", true)
addEventHandler("sendMoney", getRootElement(), function(target, amount)
	setElementData(client, "char:money", getElementData(client, "char:money") - amount)
	setElementData(target, "char:money", getElementData(target, "char:money") + amount)
end)

--[[ /resfrente: não enviar elemento do cliente (triggerServerEvent rejeita muitos hits).
    Dados primitivos + correspondência no servidor; getElementResource com pcall + fallback por árvore. ]]
local function staffResfrenteResourceNameForElement(el)
	if not isElement(el) then
		return "(sem recurso)"
	end
	if type(getElementResource) == "function" then
		local ok, res = pcall(getElementResource, el)
		if ok and res then
			local ok2, n = pcall(getResourceName, res)
			if ok2 and n and n ~= "" then
				return n
			end
		end
	end
	if type(getResources) ~= "function" then
		return "(recurso desconhecido — getResources indisponível)"
	end
	local chain = {}
	local cur = el
	for _ = 1, 80 do
		if not isElement(cur) then
			break
		end
		chain[cur] = true
		local p = getElementParent(cur)
		if not isElement(p) then
			break
		end
		cur = p
	end
	for _, res in ipairs(getResources()) do
		if getResourceState(res) == "running" then
			local rr = getResourceRootElement(res)
			if rr and chain[rr] then
				return getResourceName(res) or "?"
			end
			local okm, mr = pcall(getResourceMapRootElement, res)
			if okm and mr and chain[mr] then
				return (getResourceName(res) or "?") .. " [map]"
			end
			local okd, dr = pcall(getResourceDynamicElementRoot, res)
			if okd and dr and chain[dr] then
				return (getResourceName(res) or "?") .. " [dyn]"
			end
		end
	end
	return "(recurso desconhecido)"
end

local function staffResfrenteFindServerElement(elType, mid, int, dim, ox, oy, oz, hx, hy, hz, strictInterior, maxDist)
	elType = tostring(elType or "object")
	mid = tonumber(mid) or 0
	int = tonumber(int) or 0
	dim = tonumber(dim) or 0
	ox, oy, oz = tonumber(ox) or 0, tonumber(oy) or 0, tonumber(oz) or 0
	hx, hy, hz = tonumber(hx) or 0, tonumber(hy) or 0, tonumber(hz) or 0
	maxDist = tonumber(maxDist) or 24
	local best, bestD = nil, 999999
	for _, el in ipairs(getElementsByType(elType, root, true)) do
		if getElementDimension(el) == dim then
			if not strictInterior or getElementInterior(el) == int then
				if mid == 0 or tonumber(getElementModel(el)) == mid then
					local ex, ey, ez = getElementPosition(el)
					local da = getDistanceBetweenPoints3D(ex, ey, ez, ox, oy, oz)
					local db = getDistanceBetweenPoints3D(ex, ey, ez, hx, hy, hz)
					local d = math.min(da, db)
					if d < bestD then
						bestD = d
						best = el
					end
				end
			end
		end
	end
	if best and bestD <= maxDist then
		return best
	end
	return nil
end

addEvent("oCore>staffResfrenteResolve", true)
addEventHandler("oCore>staffResfrenteResolve", resourceRoot, function(elType, mid, int, dim, ox, oy, oz, hx, hy, hz)
	local pl = client
	if not pl or not isElement(pl) or getElementType(pl) ~= "player" then
		return
	end
	if not ((getElementData(pl, "user:admin") or 0) > 1) then
		return
	end
	local hitEl = staffResfrenteFindServerElement(elType, mid, int, dim, ox, oy, oz, hx, hy, hz, true, 22)
	if not hitEl then
		hitEl = staffResfrenteFindServerElement(elType, mid, int, dim, ox, oy, oz, hx, hy, hz, false, 38)
	end
	if not hitEl then
		triggerClientEvent(
			pl,
			"oCore>staffResfrenteResult",
			pl,
			false,
			"Não encontrei o elemento no servidor (sincronização/modelo). Tenta outra vez ou aproxima-te.",
			tostring(elType or "?"),
			tonumber(mid) or 0,
			tonumber(hx) or 0,
			tonumber(hy) or 0,
			tonumber(hz) or 0
		)
		return
	end
	local et = getElementType(hitEl)
	local modelId = tonumber(getElementModel(hitEl)) or 0
	local resName = staffResfrenteResourceNameForElement(hitEl)
	triggerClientEvent(
		pl,
		"oCore>staffResfrenteResult",
		pl,
		true,
		resName,
		tostring(et or "?"),
		modelId,
		tonumber(hx) or 0,
		tonumber(hy) or 0,
		tonumber(hz) or 0
	)
end)