--[[
  Perfil alterável antes do arranque (sem variável ambiente):

  `"original_rp"` — lista oficial Original RP / Vale do Ipiranga (produção).
  `"streamlined"` — menos recursos opcionais (eventos paul/dude, shark, cigarro); usar só após QA.
]]
local ORP_STARTER_PROFILE = "original_rp"

local function shallowCopy(tbl)
	local t = {}
	for i = 1, #tbl do
		t[i] = tbl[i]
	end
	return t
end

local baseFiltered = orpFilterStarterProfile(ORP_STARTER_PROFILE, ORP_ORIGINAL_RP_START_ORDER)
local resources = shallowCopy(baseFiltered)

-- FK skins (comportamento idêntico ao release original ORP)
for _, resourceValue in ipairs(getResources()) do
	local name = getResourceName(resourceValue)
	if string.match(name, "oFKSkins_") then
		table.insert(resources, name)
	end
end

print(("[STARTER] Perfil='%s' | manifests=%d antes de FK (total fila incl. FK=%d)")
	:format(tostring(ORP_STARTER_PROFILE), #baseFiltered, #resources))

for k, v in ipairs(resources) do
	local res = getResourceFromName(v)
	if not res then
		print("[STARTER]: AVISO — resource '" .. v .. "' não encontrado, ignorando.")
	elseif startResource(res) then
		print("[STARTER]: '" .. v .. "' iniciado.")
	else
		print("[STARTER]: FALHA — resource '" .. v .. "' não iniciou.")
	end

	if k == #resources then
		print("[STARTER]: Ciclo de start inicial concluído.")
	end
end

setTimer(function()
	for _, rn in ipairs({ "oInventory", "oSpeedo", "oBillboards" }) do
		local r = getResourceFromName(rn)
		if r and getResourceState(r) == "running" then
			restartResource(r)
		end
	end
end, 10000, 1)
