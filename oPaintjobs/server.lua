function sendMessageToAdmins(player, msg)
	triggerClientEvent("sendMessageToAdmins", getRootElement(), player, msg, 8)
end

addEvent("paintjob > sendAdminLog", true)
addEventHandler("paintjob > sendAdminLog", resourceRoot, function(veh)

    if getElementData(veh, "veh:isFactionVehice") == 1 then
        sendMessageToAdmins(client, "alterou o paintjob do veículo #db3535"..getElementData(veh, "veh:id").."#557ec9. #eba134[Veículo de organização!]")
    elseif getElementData(client, "char:id") == getElementData(veh, "veh:owner") then
        sendMessageToAdmins(client, "alterou o paintjob do veículo #db3535"..getElementData(veh, "veh:id").."#557ec9. #db3535[Veículo próprio!]")
    else
        sendMessageToAdmins(client, "alterou o paintjob do veículo #db3535"..getElementData(veh, "veh:id").."#557ec9.")
    end
end)