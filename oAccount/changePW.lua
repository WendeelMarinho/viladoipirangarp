-------------------
-- JELSZÓ VÁLTÁS --
-------------------

local panelW,panelH = 300/myX*sx, 135/myY*sy
local panelX, panelY = sx/2 - panelW/2, sy/2 - panelH/2
local selectedTab = 1

buttons = {}
activeButton = false

local inputLineGetStart = {}
local inputLineGetInverse = {}
local inputCursorState = false
local lastChangeCursorState = 0
local repeatTimer = false
local repeatStartTimer = false
fakeInputs = {} -- ezek a jelszóvisszaállításhoz készített inputok
selectedInput = false


function drawForgotPassword()
	buttons = {}
	
	dxDrawText("Use o botão Voltar para retornar!\nInsira apenas o e-mail cadastrado por você!\nNunca compartilhe sua senha com ninguém!\nEm caso de problemas, contate um desenvolvedor.\n©Ipiranga Roleplay", 10/myX*sx, 10/myX*sx, _, _, tocolor(255, 255, 255, 150), 1, fontscript:getFont("p_m", 13/myX*sx))
	if selectedTab == 1 then
		core:drawWindow(panelX, panelY, panelW, panelH, "Recuperar Senha", 1)

		drawInput("emailInput|50", "Endereço de e-mail", panelX + 4/myX*sx, panelY+25/myY*sy , panelW - 8/myX*sx, 32/myY*sy, fonts["condensed-10"],1, tocolor(30, 30, 30, 255), 1)

		core:dxDrawButton(panelX + 4/myX*sx, panelY + panelH - 73/myY*sy, panelW - 8/myX*sx, 32/myY*sy, r, g, b, 200, "Avançar", tocolor(255, 255, 255, 255), 1, fonts["condensed-10"], true, tocolor(0, 0, 0, 50))
		buttons["nextRemember"] = {panelX + 4/myX*sx, panelY + panelH - 73/myY*sy, panelW - 8/myX*sx, 32/myY*sy}

		core:dxDrawButton(panelX + 4/myX*sx, panelY + panelH - 37/myY*sy, panelW - 8/myX*sx, 32/myY*sy, 255, 25, 36, 200, "Voltar", tocolor(255, 255, 255, 255), 1, fonts["condensed-10"], true, tocolor(0, 0, 0, 50))
		buttons["backwardPanel"] = {panelX + 4/myX*sx, panelY + panelH - 37/myY*sy, panelW - 8/myX*sx, 32/myY*sy}

	elseif selectedTab == 2 then
        core:drawWindow(panelX, panelY, panelW, panelH, "Insira o código de verificação", 1)

        drawInput("recoveryCode|10", "Código de verificação", panelX + 4/myX*sx, panelY+25/myY*sy , panelW - 8/myX*sx, 32/myY*sy, fonts["condensed-10"],1, tocolor(30, 30, 30, 255), 1)

		core:dxDrawButton(panelX + 4/myX*sx, panelY + panelH - 73/myY*sy, panelW - 8/myX*sx, 32/myY*sy, r, g, b, 200, "Avançar", tocolor(255, 255, 255, 255), 1, fonts["condensed-10"], true, tocolor(0, 0, 0, 50))
		buttons["nextRemember2"] = {panelX + 4/myX*sx, panelY + panelH - 73/myY*sy, panelW - 8/myX*sx, 32/myY*sy}

		core:dxDrawButton(panelX + 4/myX*sx, panelY + panelH - 37/myY*sy, panelW - 8/myX*sx, 32/myY*sy, 255, 25, 36, 200, "Voltar", tocolor(255, 255, 255, 255), 1, fonts["condensed-10"], true, tocolor(0, 0, 0, 50))
        buttons["backwardPanel2"] = {panelX + 4/myX*sx, panelY + panelH - 37/myY*sy, panelW - 8/myX*sx, 32/myY*sy}
	elseif selectedTab == 3 then
        core:drawWindow(panelX, panelY, panelW, panelH, "Insira sua nova senha", 1)

		drawInput("password1|20", "Nova senha", panelX + 4/myX*sx, panelY+25/myY*sy , panelW - 8/myX*sx, 32/myY*sy, fonts["condensed-10"], 1, tocolor(30, 30, 30, 255), 1, true)
		drawInput("password2|20", "Confirmar nova senha", panelX + 4/myX*sx, panelY+25/myY*sy + 35/myY*sy, panelW - 8/myX*sx, 32/myY*sy, fonts["condensed-10"], 1, tocolor(30, 30, 30, 255), 1, true)

		core:dxDrawButton(panelX + 4/myX*sx, panelY + panelH - 37/myY*sy, panelW - 8/myX*sx, 32/myY*sy, r, g, b, 200, "Confirmar", tocolor(255, 255, 255, 255), 1, fonts["condensed-10"], true, tocolor(0, 0, 0, 50))
		buttons["nextRemember3"] = {panelX + 4/myX*sx, panelY + panelH - 37/myY*sy, panelW - 8/myX*sx, 32/myY*sy}
	end

	local relX, relY = getCursorPosition()

	activeButton = false

	if relX and relY then
		relX = relX * sx
		relY = relY * sy

		for k, v in pairs(buttons) do
			if relX >= v[1] and relX <= v[1] + v[3] and relY >= v[2] and relY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end

local validationInput = false

emailTypes = {
	["hotmail.com"] = true,
	["gmail.com"] = true,
	["gmail.hu"] = true,
	["indamail.hu"] = true,
	["yahoo.com"] = true,
	["vipmail.hu"] = true,
	["citromail.hu"] = true,
	["freemail.hu"] = true,
}

function forgotPasswordClick(button,state)
	selectedInput = false
	guiSetInputMode("allow_binds")
	if activeButton then
		if button == "left" and state == "up" then 
			if string.find(activeButton, "input") then
				selectedInput = string.gsub(activeButton, "input:", "")
				validationInput = selectedInput
				--print(selectedInput)
				guiSetInputMode("no_binds")
			end
			local data = split(activeButton, ":")
			if data[1] == "nextRemember" and selectedTab == 1 then 
				if fakeInputs[validationInput] then 
					if utf8.len(fakeInputs[validationInput]) > 0 then
						if utf8.find(fakeInputs[validationInput], "@") and utf8.find(fakeInputs[validationInput], ".") then 
							triggerServerEvent("rememberCheck", localPlayer, localPlayer, fakeInputs[validationInput])
						else
							exports.oInfobox:outputInfoBox("Insira um endereço de e-mail válido.","error")
						end
					else
						exports.oInfobox:outputInfoBox("Este campo não pode estar vazio.","error")
					end
				else 
					exports.oInfobox:outputInfoBox("Este campo não pode estar vazio.","error")
				end
			elseif data[1] == "backwardPanel" then 
				if renderRememberPanel then 
					closeResetPasswordPanel()
				end 
			elseif data[1] == "nextRemember2" and selectedTab == 2 then
				if utf8.len(fakeInputs[validationInput]) > 0 then 
					triggerServerEvent("rememberCheck2", localPlayer, localPlayer, fakeInputs[validationInput])
				else 
					exports.oInfobox:outputInfoBox("Este campo não pode estar vazio.","error")
				end
			elseif data[1] == "backwardPanel2" and selectedTab == 2 then
				if renderRememberPanel then 
					closeResetPasswordPanel()
				end 
				exports.oInfobox:outputInfoBox("Como você voltou, o código não pode mais ser utilizado.","error")
				triggerServerEvent("destroyCode", localPlayer, localPlayer)
			elseif data[1] == "nextRemember3" and selectedTab == 3 then
				local pw1 = fakeInputs["password1|20"]
				local pw2 = fakeInputs["password2|20"]
				if pw1 ~= "" and pw2 ~= "" then
					if pw1 == pw2 then 
						triggerServerEvent("passwordChange", localPlayer, localPlayer, hash("sha256", "originalRoleplayAccount"..pw1.."2k20"))
                        closeResetPasswordPanel()
					else 
						exports.oInfobox:outputInfoBox("As senhas não coincidem.","error")
					end
				else 
					exports.oInfobox:outputInfoBox("Este campo não pode estar vazio.","error")
				end
			elseif data[1] == "confirmEmail" then 
				if fakeInputs[validationInput] then 
					if utf8.len(fakeInputs[validationInput]) > 0 then
						if utf8.find(fakeInputs[validationInput], "@") and utf8.find(fakeInputs[validationInput], ".") then 
							email = split(fakeInputs[validationInput],"@")
							if emailTypes[email[2]] then 
								triggerServerEvent("changeEmail", localPlayer,localPlayer,fakeInputs[validationInput])
                                removeEventHandler("onClientClick", getRootElement(), forgotPasswordClick)
							else 
								exports.oInfobox:outputInfoBox("Insira um endereço de e-mail válido.","error")
							end
						else
							exports.oInfobox:outputInfoBox("Insira um endereço de e-mail válido.","error")
						end
					else 
						exports.oInfobox:outputInfoBox("Este campo não pode estar vazio.","error")
					end
				else 
					exports.oInfobox:outputInfoBox("Este campo não pode estar vazio.","error")
				end
			end
		end
	end
end

function closeResetPasswordPanel()
    removeEventHandler("onClientRender", getRootElement(), drawForgotPassword)
    removeEventHandler("onClientClick", getRootElement(), forgotPasswordClick)
    removeEventHandler("onClientKey", getRootElement(), rememberKey)
    removeEventHandler("onClientCharacter", getRootElement(), rememberMe)
    renderRememberPanel = false
    selectedTab = 1
    fakeInputs = {} 
end

function rememberKey(button, state)
	if button == "backspace" and state and selectedInput and isCursorShowing() then 
		cancelEvent()
		if utf8.len(fakeInputs[selectedInput]) >= 1 then
		  fakeInputs[selectedInput] = utf8.sub(fakeInputs[selectedInput], 1, -2)
		  playRandomKeySound()
		end
	elseif button == "enter" and state and selectedInput and isCursorShowing() then 
		if fakeInputs[selectedInput] then 
			if utf8.len(fakeInputs[selectedInput]) > 0 then
				if utf8.find(fakeInputs[selectedInput], "@") and utf8.find(fakeInputs[selectedInput], ".") then 
					validationInput = false
				else
					exports.oInfobox:outputInfoBox("Insira um endereço de e-mail válido.","error")
				end
			else
				exports.oInfobox:outputInfoBox("Este campo não pode estar vazio.","error")
			end
		else 
			exports.oInfobox:outputInfoBox("Este campo não pode estar vazio.","error")
		end
	end
end


addEvent("rememberMeSelectedTab", true)
addEventHandler("rememberMeSelectedTab", getRootElement(), function(tab)
	selectedTab = tab
	validationInput = false
end)

function rememberMe(character)
	if isCursorShowing() and selectedInput then 
		local selected = split(selectedInput, "|")

		if utf8.len(fakeInputs[selectedInput]) < tonumber(selected[2]) then
			fakeInputs[selectedInput] = fakeInputs[selectedInput] .. character
			playRandomKeySound()
		end
	end
end

------------------
-- EMAIL VÁLTÁS --
------------------

addEvent("emailForceChange", true)
addEventHandler("emailForceChange", getRootElement(), function(player)
	addEventHandler("onClientRender", getRootElement(), drawForceEmailChange)
	addEventHandler("onClientClick", getRootElement(), forgotPasswordClick)
	addEventHandler("onClientKey", getRootElement(), rememberKey)
	addEventHandler("onClientCharacter", getRootElement(), rememberMe)
    emailChangeShowing = true
end)

addEvent("closeEmailForce",true)
addEventHandler("closeEmailForce", getRootElement(), function()
	removeEventHandler("onClientRender", getRootElement(), drawForceEmailChange)
	removeEventHandler("onClientKey", getRootElement(), rememberKey)
	removeEventHandler("onClientCharacter", getRootElement(), rememberMe)
end)

local panelW2,panelH2 = 300/myX*sx, 200/myY*sy
local panelX2, panelY2 = sx/2 - panelW2/2, sy/2 - panelH2/2

function drawForceEmailChange()
    core:drawWindow(panelX2, panelY2, panelW2, panelH2, "Alterar endereço de e-mail", 1)


	buttons = {}

	dxDrawText("Altere o seu endereço de e-mail atual!\n\n#eb5146Importante: insira um e-mail válido.\nVocê precisará dele no futuro!", sx/2, panelY2 + 80/myY*sy, sx/2, panelY2 + 63/myY*sy, tocolor(255,255,255,150), 1, fonts["condensed-10"], "center", "center",false,false,false,true)
	drawInput("emailInput|50", "Endereço de e-mail", panelX2 + 4/myX*sx, panelY2+125/myY*sy , panelW2 - 8/myX*sx, 32/myY*sy, fonts["condensed-10"],1, tocolor(30, 30, 30, 255), 1)
	core:dxDrawButton(panelX2 + 4/myX*sx, panelY2 + panelH2 - 37/myY*sy, panelW2 - 8/myX*sx, 32/myY*sy, r, g, b, 200, "Alterar", tocolor(255, 255, 255, 255), 1, fonts["condensed-10"], true, tocolor(0, 0, 0, 50))
	buttons["confirmEmail"] = {panelX2 + 4/myX*sx, panelY2 + panelH2 - 37/myY*sy, panelW2 - 8/myX*sx, 32/myY*sy}



	local relX, relY = getCursorPosition()

	activeButton = false

	if relX and relY then
		relX = relX * sx
		relY = relY * sy

		for k, v in pairs(buttons) do
			if relX >= v[1] and relX <= v[1] + v[3] and relY >= v[2] and relY <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	end
end

----------------------------
-- DEXTER FÉLE DRAW INPUT --
----------------------------

function drawInput(key, label, x, y, sx, sy, font, fontScale, color, a, isPW)
 -- a = a or 1

  if not fakeInputs[key] then
    fakeInputs[key] = ""
  end

  dxDrawRectangle(x, y, sx, sy, color)

  if selectedInput == key then
    if not inputLineGetStart[key] then
      inputLineGetInverse[key] = false
      inputLineGetStart[key] = getTickCount()
    end
  elseif inputLineGetStart[key] then
    inputLineGetInverse[key] = getTickCount()
    inputLineGetStart[key] = false
  end

  local lineProgress = 0

  if inputLineGetStart[key] then
    local elapsedTime = getTickCount() - inputLineGetStart[key]
    local progress = elapsedTime / 300

    lineProgress = interpolateBetween(
      0, 0, 0,
      1, 0, 0,
      progress, "Linear")
  elseif inputLineGetInverse[key] then
    local elapsedTime = getTickCount() - inputLineGetInverse[key]
    local progress = elapsedTime / 300

    lineProgress = interpolateBetween(
      1, 0, 0,
      0, 0, 0,
      progress, "Linear")
  end

  sy = sy - 2

  if utf8.len(fakeInputs[key]) > 0 then
    if isPW then 
        dxDrawText(string.rep("*", string.len(fakeInputs[key])), x + 3, y, x + sx - 3, y + sy, tocolor(255, 255, 255, 230 * a), fontScale, font, "left", "center", true)
    else
        dxDrawText(fakeInputs[key], x + 3, y, x + sx - 3, y + sy, tocolor(255, 255, 255, 230 * a), fontScale, font, "left", "center", true)
    end
  elseif label then
    dxDrawText(label, x, y, x+sx, y + sy, tocolor(255, 255, 255, 150 * a), fontScale, font, "center", "center", true)
  end

  if selectedInput == key then
    if inputCursorState then
      --outputChatBox("asd")
      local contentSizeX = dxGetTextWidth(fakeInputs[key], fontScale, font)

      dxDrawLine(x + 3 + contentSizeX, y + 5, x + 3 + contentSizeX, y + sy - 5, tocolor(230, 230, 230, 255 * a))
    end
    if getTickCount() - lastChangeCursorState >= 500 then
      inputCursorState = not inputCursorState
      lastChangeCursorState = getTickCount()
    end
  end

  buttons["input:" .. key] = {x, y, sx, sy}
end
