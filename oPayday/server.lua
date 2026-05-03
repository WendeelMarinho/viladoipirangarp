local dashboard = exports.oDashboard
local core = exports.oCore
local color, r, g, b = core:getServerColor()

addEvent("payday > getPaymentOnServer", true)
addEventHandler("payday > getPaymentOnServer", resourceRoot, function(factions, tax)
    local allPayment = 0
    for k, v in ipairs(factions) do 
        local payment = dashboard:getPlayerPaymentInFaction(v, client)

        if (dashboard:getFactionBankMoney(v) - payment > 0) then 
            dashboard:setFactionBankMoney(v, payment, "remove")
            allPayment = allPayment+payment
        end
    end

    outputChatBox(core:getServerPrefix("server", "Salário", 3)..""..allPayment..color.."$", client, 255, 255, 255, true)
    setElementData(client, "char:money", getElementData(client, "char:money")+allPayment)
    setElementData(client, "char:money", getElementData(client, "char:money")-tax)
end)

addEvent("payday > reportActivity", true)
addEventHandler("payday > reportActivity", resourceRoot, function(score)
    local player = client
    local mult = 1.0
    if score >= 20 then mult = 2.0
    elseif score >= 10 then mult = 1.5
    elseif score >= 5  then mult = 1.2
    end
    if mult > 1.0 then
        local bonus = math.floor(getElementData(player, "char:money") * (mult - 1) * 0.05)
        if bonus > 0 then
            setElementData(player, "char:money", (getElementData(player, "char:money") or 0) + bonus)
            outputChatBox(core:getServerPrefix("server", "Bônus RP", 3) .. color .. "+" .. bonus ..
                "$ #ffffff(bônus de atividade ×" .. mult .. " — " .. score .. " ações)", player, 255, 255, 255, true)
        end
    end
end)