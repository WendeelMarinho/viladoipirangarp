-- adminSerialsCache: populated at runtime from the `adminserials` DB table (server-side only).
-- On client, this table is always empty; client-side functions use element data instead.
adminSerialsCache = {}

adminPrefixs = {
	[0] = "Játékos",
	[1] = "AdminSegéd",
	[2] = "Admin 1",
	[3] = "Admin 2",
	[4] = "Admin 3",
	[5] = "Admin 4",
	[6] = "Admin 5",
	[7] = "FőAdmin",
	[8] = "AdminController",
	[9] = "Server Manager",
	[10] = "Fejlesztő",
	[11] = "Tulajdonos",
}

adminColors = {
    [0] = "#f7931e",
    [1] = "#f7931e",
    [2] = "#f7931e",
    [3] = "#f7931e",
    [4] = "#f7931e",
    [5] = "#f7931e",
    [6] = "#f7931e",
    [7] = "#ae61e8",
    [8] = "#72b55e",
    [9] = "#ffbb5b",
    [10] = "#5db2f7",
    [11] = "#f44141",
}

function isPlayerDeveloper(player)
	if localPlayer then
		return getElementData(player, "aclLogin") == true
	end
	return adminSerialsCache[getPlayerSerial(player)] ~= nil
end

function isSerialDeveloper(serial)
	return adminSerialsCache[serial] ~= nil
end

function getAdminPrefix(rankNum)
	return adminPrefixs[rankNum]
end

function getAdminColor(rankNum)
	return adminColors[rankNum]
end

function getPlayerAdminLevel(player)
	if localPlayer then
		if getElementData(player, "aclLogin") then return 10 end
	else
		if adminSerialsCache[getPlayerSerial(player)] then return 10 end
	end
	return getElementData(player, "user:admin") or 0
end

function isPlayerInAdminDuty(player)
	if getPlayerAdminLevel(player) > 6 then
		return true
	end
	return getElementData(player, "user:aduty") or false
end

function playerHasPermission(player, level, needHighLevel)
	if not player then return end
	if not needHighLevel then needHighLevel = false end
	if not level then level = 2 end

	if needHighLevel then
		if localPlayer then
			return getElementData(player, "aclLogin") == true
		end
		return adminSerialsCache[getPlayerSerial(player)] ~= nil
	else
		if getPlayerAdminLevel(player) >= 8 then
			return true
		elseif isPlayerInAdminDuty(player) then
			return true
		else
			return false
		end
	end
end

function getAdminNick(player)
	return getElementData(player, "user:adminnick")
end

nameColor = "#db3535"
adminMessageColor = "#557ec9"
adminMessagePrefixColor = "#276ce3"
core = exports.oCore
serverName = core:getServerName() or "Szerver"
color, r, g, b = core:getServerColor()
serverColor = core:getServerColor()
