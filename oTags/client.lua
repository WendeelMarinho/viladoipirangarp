--[[ oTags — cliente (nametag sobre a cabeça) ]]

local sx, sy = guiGetScreenSize()
local myX, myY = 1768, 992

local fonts = exports.oFont
local tagFont
local rankFont

RANK_BADGE_KEY = "player:rankBadge"

local function hexToRgb(hex)
	if not hex or type(hex) ~= "string" then return 255, 255, 255 end
	local h = hex:gsub("#", ""):lower()
	if #h < 6 then return 255, 255, 255 end
	local r = tonumber(h:sub(1, 2), 16)
	local g = tonumber(h:sub(3, 4), 16)
	local b = tonumber(h:sub(5, 6), 16)
	if not r or not g or not b then return 255, 255, 255 end
	return r, g, b
end

local function parseTag(raw)
	if not raw or raw == "" then return shallowCopyTag(TAG_DEFAULT_CIVIL) end
	local ok, t = pcall(fromJSON, raw)
	if ok and type(t) == "table" and t.text then return t end
	return shallowCopyTag(TAG_DEFAULT_CIVIL)
end

local function parseRankBadge(raw)
	if not raw or raw == "" then return nil end
	local ok, t = pcall(fromJSON, raw)
	if ok and type(t) == "table" and t.text then return t end
	return nil
end

local function ensureFont()
	if not tagFont then
		tagFont = fonts:getFont("condensed", math.max(10, math.floor(sy * (14 / myY))))
	end
	if not rankFont then
		rankFont = fonts:getFont("condensed", math.max(9, math.floor(sy * (11 / myY))))
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	ensureFont()
end)

addEventHandler("onClientResourceStart", root, function(res)
	if getResourceName(res) == "oFont" then
		fonts = exports.oFont
		tagFont = nil
		rankFont = nil
		ensureFont()
	end
end)

addEventHandler("onClientRender", root, function()
	ensureFont()
	if not tagFont then return end

	local scale = sy / myY
	local pad = 4 * scale
	local lift = 18 * scale

	local lx, ly, lz = getElementPosition(localPlayer)
	for _, player in ipairs(getElementsByType("player")) do
		if isElement(player) and isElementStreamedIn(player) then
			local headX, headY, headZ = getPedBonePosition(player, 5)
			if headX then
				headZ = headZ + 0.92
				if getDistanceBetweenPoints3D(lx, ly, lz, headX, headY, headZ) <= 38 then
					local bx, by = getScreenFromWorldPosition(headX, headY, headZ)
					if bx and by then
						local gap = math.max(2, math.floor(scale * 2))
						local stackBottom = by - lift
						local rankB = parseRankBadge(getElementData(player, RANK_BADGE_KEY))

						local function drawOneTag(tbl, fnt)
							if not tbl or not tbl.text or tbl.text == "" then return end
							local text = tostring(tbl.text)
							local tr, tg, tb = hexToRgb(tbl.color or "#ffffff")
							local bgR, bgG, bgB = hexToRgb(tbl.bg_color or "#222222")
							local borR, borG, borB = hexToRgb(tbl.border_color or "#444444")
							local alpha = 235
							if tbl.animated then
								alpha = math.floor(155 + 90 * math.sin(getTickCount() / 280))
							end
							local tw = dxGetTextWidth(text, 1, fnt)
							local fh = dxGetFontHeight(1, fnt)
							local bw = tw + pad * 2
							local bh = fh + pad * 0.65
							local top = stackBottom - bh
							local bx1 = bx - bw / 2
							local border = math.max(1, math.floor(scale))
							dxDrawRectangle(bx1 - border, top - border, bw + border * 2, bh + border * 2, tocolor(borR, borG, borB, alpha))
							dxDrawRectangle(bx1, top, bw, bh, tocolor(bgR, bgG, bgB, alpha))
							dxDrawText(text, bx1, top, bx1 + bw, top + bh, tocolor(tr, tg, tb, alpha), 1, fnt, "center", "center", false, false, false)
							stackBottom = top - gap
						end

						if rankB then
							drawOneTag(rankB, rankFont or tagFont)
						end

						local raw = getElementData(player, TAG_ELEMENT_KEY)
						local tag = parseTag(raw)
						if tag.text and tag.text ~= "" then
							drawOneTag(tag, tagFont)
						end
					end
				end
			end
		end
	end
end)
