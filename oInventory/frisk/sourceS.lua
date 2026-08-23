func.frisk.requestItems = function(target)
	local items = func.getItems(target,3);
	local targetDatas = {
		money = getElementData(target,"char:money");
		name = getPlayerName(target):gsub("_", " ");
		element = target;
	};
	triggerClientEvent(source,"setFriskItems",source,items,targetDatas)
end
addEvent("requestFriskItems",true)
addEventHandler("requestFriskItems",getRootElement(),func.frisk.requestItems)


func.frisk.deleteItem = function(element,data,state,playerSource)
	admin:sendMessageToAdmins(playerSource, "removeu #db3535"..tonumber(data.count).."x "..getItemName(tonumber(data.item),tostring(data.value)).." #557ec9de #db3535"..string.gsub(getPlayerName(element), "_", " ").."#557ec9.")
	deleteItem(element,data,state)
end
addEvent("deleteItemfrisk",true)
addEventHandler("deleteItemfrisk",getRootElement(),func.frisk.deleteItem)