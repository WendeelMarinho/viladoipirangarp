--[[ oReputation — cliente ]]

local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992
local font = exports.oFont
local core = exports.oCore

local rows = {}
local uiOpen = false
local hooks = false

local function closeUi()
	if not hooks then return end
	hooks = false
	uiOpen = false
	showCursor(false)
	removeEventHandler("onClientRender", root, drawUi)
	removeEventHandler("onClientKey", root, onKey)
end

function onKey(btn, press)
	if not uiOpen then return end
	if btn == "backspace" and press then
		closeUi()
	end
end

local function repColor(sc)
	sc = tonumber(sc) or 0
	if sc >= 40 then return tocolor(90, 200, 120, 255) end
	if sc <= -40 then return tocolor(220, 80, 80, 255) end
	return tocolor(220, 200, 120, 255)
end

function drawUi()
	if not uiOpen then return end
	local w, h = sx * 0.48, sy * 0.62
	local x, y = (sx - w) / 2, (sy - h) / 2
	dxDrawRectangle(x, y, w, h, tocolor(16, 16, 20, 245))
	local color, r, g, b = core:getServerColor()
	dxDrawRectangle(x, y, w, sy * 0.055, tocolor(r, g, b, 100))
	dxDrawText("Reputação com facções", x + 14, y, x + w, y + sy * 0.055, tocolor(255, 255, 255), 1,
		font:getFont("bebasneue", 17 / myX * sx), "left", "center")
	dxDrawText("Backspace — fechar", x + w - 14, y, x + w - 10, y + sy * 0.055, tocolor(210, 210, 210), 0.95,
		font:getFont("condensed", 11 / myX * sx), "right", "center")

	local ly = y + sy * 0.075
	if #rows == 0 then
		dxDrawText("Ainda não há entradas — a reputação surge com as tuas acções IC.", x + 18, ly, x + w - 18, ly + h,
			tocolor(200, 200, 200), 1, font:getFont("condensed", 12 / myX * sx), "left", "top", false, true)
		return
	end

	for i, row in ipairs(rows) do
		local ry = ly + (i - 1) * sy * 0.072
		dxDrawRectangle(x + 12, ry, w - 24, sy * 0.065, tocolor(34, 34, 40, 230))
		dxDrawText(row.name or ("#" .. tostring(row.faction_id)), x + 22, ry + 6, x + w * 0.72, ry + sy * 0.05,
			tocolor(240, 240, 240), 1, font:getFont("condensed", 12 / myX * sx), "left", "top", true)
		local sc = tonumber(row.score) or 0
		dxDrawText(tostring(sc), x + w * 0.72, ry + 6, x + w - 22, ry + sy * 0.06,
			repColor(sc), 1, font:getFont("bebasneue", 16 / myX * sx), "right", "center")
	end

	dxDrawText("Valores entre " .. REP_MIN .. " e " .. REP_MAX .. ". Prisão por PM ajusta reputação com essa facção.",
		x + 14, y + h - sy * 0.048, x + w - 14, y + h - 8,
		tocolor(160, 160, 170), 1, font:getFont("condensed", 10 / myX * sx), "left", "bottom", false, true)
end

local function openUi()
	if hooks then return end
	hooks = true
	uiOpen = true
	showCursor(true)
	addEventHandler("onClientRender", root, drawUi)
	addEventHandler("onClientKey", root, onKey)
	triggerServerEvent("oReputation > requestSync", resourceRoot)
end

addEvent("oReputation > fullSync", true)
addEventHandler("oReputation > fullSync", resourceRoot, function(pack)
	rows = pack or {}
end)

addEvent("oReputation > patch", true)
addEventHandler("oReputation > patch", resourceRoot, function(factionId, newScore)
	factionId = tonumber(factionId)
	newScore = tonumber(newScore)
	if not factionId then return end
	local found = false
	for i, row in ipairs(rows) do
		if row.faction_id == factionId then
			row.score = newScore
			found = true
			break
		end
	end
	if not found then
		local name = exports.oDashboard:getFactionName(factionId) or ("Facção #" .. tostring(factionId))
		rows[#rows + 1] = { faction_id = factionId, score = newScore, name = name }
		table.sort(rows, function(a, b) return (a.name or "") < (b.name or "") end)
	end
end)

addEvent("oReputation > openUi", true)
addEventHandler("oReputation > openUi", resourceRoot, openUi)

addCommandHandler("reputacao", function()
	openUi()
end)
