--[[
	Tuning cosmético seguro: só veículo do condutor, personagem logado,
	sem peds fictícios. Usa upgrades compatíveis por slot (GTA SA / MTA).
]]

local UPGRADE_SLOT_MAX = 16

--- IDs conhecidos por causar combinações estranhas em alguns modelos (legado do script antigo).
local SKIP_UPGRADE_IDS = {
	[1131] = true,
}

--- @return boolean ok, string|nil errMessage
function applySafeVehicleTuning(thePlayer)
	if not isElement(thePlayer) or getElementType(thePlayer) ~= "player" then
		return false, "Jogador inválido."
	end
	if not getElementData(thePlayer, "user:loggedin") then
		return false, "Precisas de personagem ativo."
	end
	local veh = getPedOccupiedVehicle(thePlayer)
	if not veh or getElementType(veh) ~= "vehicle" then
		return false, "Precisas de estar num veículo."
	end
	if getVehicleController(veh) ~= thePlayer then
		return false, "Só o condutor pode aplicar tuning."
	end

	for slot = 0, UPGRADE_SLOT_MAX do
		local ups = getVehicleCompatibleUpgrades(veh, slot)
		if type(ups) == "table" and #ups > 0 then
			table.sort(ups)
			local pick = ups[#ups]
			if pick and not SKIP_UPGRADE_IDS[pick] then
				addVehicleUpgrade(veh, pick)
			end
		end
	end

	return true
end

addCommandHandler("tuning", function(thePlayer)
	local ok, err = applySafeVehicleTuning(thePlayer)
	if ok then
		outputChatBox("#88cc88[Tuning]#ffffff Upgrades compatíveis aplicados.", thePlayer, 255, 255, 255, true)
	else
		outputChatBox("#cc8888[Tuning]#ffffff " .. tostring(err or "Não foi possível aplicar."), thePlayer, 255, 255, 255, true)
	end
end)
