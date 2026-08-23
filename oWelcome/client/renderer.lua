--[[ oWelcome — composição do painel principal ]]

WelcomeRenderer = WelcomeRenderer or {}

function WelcomeRenderer.panelGeom(Welcome)
	local pw = math.min(Welcome.sx * 0.72, 920)
	local ph = Welcome.sy * 0.78
	local px = (Welcome.sx - pw) / 2
	local py = (Welcome.sy - ph) / 2
	return px, py, pw, ph
end

function WelcomeRenderer.headerH()
	return WelcomeUi.scale(52)
end

function WelcomeRenderer.tabBarH()
	return WelcomeUi.scale(44)
end

function WelcomeRenderer.footerH()
	return WelcomeUi.scale(124)
end

function WelcomeRenderer.draw(Welcome)
	if not Welcome.show or not Welcome.payload then return end
	WelcomeUi.beginFrame({
		sx = Welcome.sx,
		sy = Welcome.sy,
		fontTitle = Welcome.fontTitle,
		fontHeader = Welcome.fontHeader,
		fontSmall = Welcome.fontSmall,
		fontMain = Welcome.fontMain,
	})
	local t = W_THEME
	local px, py, pw, ph = WelcomeRenderer.panelGeom(Welcome)
	local now = getTickCount()
	local openT = math.min(1, (now - (Welcome.openTick or now)) / 240)
	local ease = WelcomeAnim.easeOutCubic(openT)
	local alpha = math.floor(255 * ease)
	local scaleK = WelcomeAnim.lerp(0.94, 1, ease)
	local cx, cy = px + pw / 2, py + ph / 2
	local pwS, phS = pw * scaleK, ph * scaleK
	px, py = cx - pwS / 2, cy - phS / 2
	pw, ph = pwS, phS

	dxDrawRectangle(0, 0, Welcome.sx, Welcome.sy, tocolor(t.bgDeep[1], t.bgDeep[2], t.bgDeep[3], math.floor(200 * ease)))

	WelcomeUi.drawGlassPanel(px, py, pw, ph, alpha)

	local hh = WelcomeRenderer.headerH()
	WelcomeUi.drawGlassPanel(px, py, pw, hh, math.floor(alpha * 0.98))
	dxDrawText(
		"Ipiranga Roleplay",
		px + WelcomeUi.scale(20),
		py + WelcomeUi.scale(8),
		px + pw - WelcomeUi.scale(56),
		py + WelcomeUi.scale(30),
		wTocolor(t.text, alpha),
		1,
		Welcome.fontHeader,
		"left",
		"top",
		false,
		false,
		false,
		true
	)
	local sub = "Guia do jogador · notícias · comandos"
	dxDrawText(
		sub,
		px + WelcomeUi.scale(20),
		py + WelcomeUi.scale(32),
		px + pw - WelcomeUi.scale(56),
		py + hh - WelcomeUi.scale(6),
		wTocolor(t.textMuted, math.floor(0.85 * alpha)),
		0.82,
		Welcome.fontSmall,
		"left",
		"top",
		false,
		true,
		false,
		true
	)

	local closeS = WelcomeUi.scale(40)
	local hx = px + pw - closeS - WelcomeUi.scale(12)
	local hy = py + WelcomeUi.scale(6)
	WelcomeUi.drawIconClose(hx, hy, closeS, function()
		WelcomeMain.close()
	end)
	Welcome.headerCloseHit = { x = hx, y = hy, w = closeS, h = closeS }

	local tabY = py + hh + WelcomeUi.scale(4)
	local labels = { "Início", "Notícias", "Novidades", "Ajuda" }
	local tw = pw / 4
	local targetUx = px + (Welcome.activeTab - 1) * tw + tw * 0.2
	local targetUw = tw * 0.6
	if not Welcome.tabUnderlineX then
		Welcome.tabUnderlineX = targetUx
	end
	if not Welcome.tabUnderlineW then
		Welcome.tabUnderlineW = targetUw
	end
	Welcome.tabUnderlineX = WelcomeAnim.smoothToward(Welcome.tabUnderlineX, targetUx, Welcome.lastDt or 0.016, 18)
	Welcome.tabUnderlineW = WelcomeAnim.smoothToward(Welcome.tabUnderlineW, targetUw, Welcome.lastDt or 0.016, 18)
	WelcomeUi.drawTabBar(px, tabY, pw, labels, Welcome.activeTab, function(i)
		Welcome.activeTab = i
		Welcome.scrollOffsets[i] = Welcome.scrollOffsets[i] or 0
	end, Welcome.tabUnderlineX, Welcome.tabUnderlineW)

	local cty = tabY + WelcomeRenderer.tabBarH() + WelcomeUi.scale(12)
	local maxY = py + ph - WelcomeRenderer.footerH() - WelcomeUi.scale(4)
	if Welcome.skeletonUntil and now < Welcome.skeletonUntil then
		local gy = cty
		for i = 1, 5 do
			WelcomeUi.drawGhostBar(px + WelcomeUi.scale(16), gy, pw - WelcomeUi.scale(32), WelcomeUi.scale(16), alpha, i * 40)
			gy = gy + WelcomeUi.scale(28)
		end
	else
		WelcomeTabs.draw(Welcome, px, py, pw, ph, cty, maxY)
	end

	local fy = py + ph - WelcomeRenderer.footerH() + WelcomeUi.scale(8)
	WelcomeUi.drawGlassPanel(px + WelcomeUi.scale(14), fy, pw - WelcomeUi.scale(28), WelcomeUi.scale(46), math.floor(alpha * 0.95))
	local tipFooter = tostring(Welcome.payload.tip or "")
	dxDrawText(
		"Dica: " .. tipFooter,
		px + WelcomeUi.scale(26),
		fy + WelcomeUi.scale(8),
		px + pw - WelcomeUi.scale(26),
		fy + WelcomeUi.scale(42),
		wTocolor(t.text, math.floor(0.9 * alpha)),
		0.84,
		Welcome.fontSmall,
		"left",
		"center",
		false,
		true,
		false,
		true
	)

	local footY = fy + WelcomeUi.scale(52)
	local cbS = WelcomeUi.scale(18)
	local cbx = px + WelcomeUi.scale(20)
	WelcomeUi.drawGlassPanel(cbx, footY, cbS, cbS, 240)
	if Welcome.dontShowAgain then
		dxDrawRectangle(cbx + 4, footY + 4, cbS - 8, cbS - 8, wTocolor(t.success, 230))
	end
	dxDrawText("Não mostrar novamente", cbx + cbS + WelcomeUi.scale(10), footY, px + pw * 0.55, footY + cbS + 4, wTocolor(t.textMuted, alpha), 0.82, Welcome.fontSmall, "left", "center", false, true, false, true)
	WelcomeUi.addHit(cbx, footY, cbS + WelcomeUi.scale(200), cbS + 4, function()
		Welcome.dontShowAgain = not Welcome.dontShowAgain
	end)

	local bw, bh = WelcomeUi.scale(168), WelcomeUi.scale(40)
	local bx = px + pw - bw - WelcomeUi.scale(20)
	WelcomeUi.drawButton(bx, footY, bw, bh, "Começar agora", {
		primary = true,
		font = Welcome.fontMain,
		fontScale = 0.9,
		onClick = function()
			WelcomeMain.close()
		end,
	})

	dxDrawText(
		"Fora do painel · ✕ · Esc · Backspace",
		px + WelcomeUi.scale(20),
		py + ph - WelcomeUi.scale(22),
		px + pw - WelcomeUi.scale(20),
		py + ph - WelcomeUi.scale(6),
		wTocolor(t.textMuted, math.floor(140 * ease)),
		0.72,
		Welcome.fontSmall,
		"center",
		"bottom",
		false,
		true,
		false,
		true
	)

	Welcome.panelHit = { x = px, y = py, w = pw, h = ph }
end
