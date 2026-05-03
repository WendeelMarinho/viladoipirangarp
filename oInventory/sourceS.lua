func = {};
connection = exports.oMysql:getDBConnection()
func.actionbar = {};
func.trash = {};
func.frisk = {};
func.safe = {};
itemCache = {};
actionBarCache = {};
weapons = {};
trashCache = {};
safeCache = {};
ThreadClass = {
	name = "thread";
	perElements = 5000;
	perElementsTick = 50;
	threadCount = 1;
	threadElements = {};
	callback = nil;
	funcArgs = {};
	state = false;
}

function ThreadClass:new(o)
	o = o or {};
	o.threadCount = 1;
	o.threadElements = {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end

function ThreadClass:setMaxElement(m)
	self.perElements = m;
end

function ThreadClass:foreach(elements, func, callback, ...)
	if self.state and #elements > 0 then
		outputDebugString("New thread for " .. self.name);
		return ThreadClass:new({name = self.name, perElements = self.perElements, perElementsTick = self.perElementsTick}):foreach(elements, func, callback, ...);
	end
	self.state = true;
	self.callback = callback;
	self.funcArgs = {...};
	for i, v in ipairs(elements) do
		if not self.threadElements[self.threadCount] then
			self.threadElements[self.threadCount] = {};
		end
		table.insert(self.threadElements[self.threadCount], function()
			if(#self.funcArgs > 0)then
				func(v, unpack(self.funcArgs));
			else
				func(v);
			end
		end);

		if (#self.threadElements[self.threadCount] >= self.perElements or i == #elements) then
			self.threadCount = self.threadCount + 1;
		end
	end

	return self:resume();
end

function ThreadClass:resume()
	if(self.threadCount>0) then
		local state, result = coroutine.resume(coroutine.create(function()
			if self.threadElements[self.threadCount] then
				for j, k in ipairs(self.threadElements[self.threadCount]) do
					k();
				end
			end
		end));
		self.threadCount = self.threadCount - 1;
		if not state then
			outputDebugString("[Thread - " .. self.name .. "] Error: " .. result, 0, 255, 0, 0);
		end
		if self.perElementsTick >= 50 then
			setTimer(function()
				self:resume();
			end, self.perElementsTick, 1);
		else
			self:resume();
		end
	else
		if(self.callback)then
			if(#self.funcArgs > 0)then
				self.callback(v, unpack(self.funcArgs));
			else
				self.callback(v);
			end
		end
		self.state = false;
	end

	return self;
end

function newThread(n, per, tick)
	return ThreadClass:new({name = n or "threading", perElements = per or 5000, perElementsTick = tick or 50});
end

func.getElementID = function(element)
	local elementType = getElementType(element)

	if elementType == "player" then
		return getElementData(element,"user:id");
	elseif elementType == "object" then
		return getElementData(element,"object:dbid");
	elseif elementType == "vehicle" then
		return getElementData(element,"veh:id");
	end
end


func.start = function()
	removeWorldModel ( 1370, 99999999,1367.0924072266, 469.03143310547, 19.68865776062 )
	--[[setWeaponProperty("deagle", "pro", "maximum_clip_ammo", 17)
	setWeaponProperty("deagle", "std", "maximum_clip_ammo", 17)
	setWeaponProperty("deagle", "poor", "maximum_clip_ammo", 17)

	setWeaponProperty("deagle", "pro", "accuracy", 2)
	setWeaponProperty("deagle", "std", "accuracy", 2)
	setWeaponProperty("deagle", "poor", "accuracy", 2)]]

	takeAllWeapons(getRootElement())

	local Thread = newThread("items", 3000, 50);
    dbQuery(function(qh)
        local loadedItems = 0
		local res, rows, err = dbPoll(qh, 0);
        if rows > 0 then
            local tick = getTickCount();
            Thread:foreach(res, function(row)
				--dbExec(connection,"DELETE FROM `items` WHERE `id` = ?",row['id'])
                local owner = tonumber(row["owner"]);
                if not itemCache[owner] then
                    itemCache[owner] = {
						["bag"] = {},
						["key"] = {},
						["licens"] = {},
						["vehicle"] = {},
						["object"] = {},
					};
                end
                itemCache[owner][tostring(row["type"])][tonumber(row["slot"])] = {
                    ["id"] = tonumber(row["id"]),
					["slot"] = tonumber(row["slot"]),
                    ["item"] = tonumber(row["itemid"]),
                    ["value"] = tostring(row["value"]),
                    ["count"] = tonumber(row["count"]),
					["duty"] = tonumber(row["dutyitem"]),
					["pp"] = tonumber(row["pp"]),
					["warn"] = tonumber(row["warn"]),
                    ["state"] = tonumber(row["itemState"]),
					["weaponserial"] = tostring(row["weaponserial"]),
				}

				if itemCache[owner][tostring(row["type"])][tonumber(row["slot"])] then
					local player = func.getPlayerElementById(owner);
					if player then
						if weaponCache[itemCache[owner][tostring(row["type"])][tonumber(row["slot"])]["item"]] and weaponCache[itemCache[owner][tostring(row["type"])][tonumber(row["slot"])]["item"]].isBack then
							attachWeapon(player,itemCache[owner][tostring(row["type"])][tonumber(row["slot"])]["item"],itemCache[owner][tostring(row["type"])][tonumber(row["slot"])]["id"],itemCache[owner][tostring(row["type"])][tonumber(row["slot"])]["value"])
						end
						triggerClientEvent(player,"refreshItem",player,player,itemCache[owner][tostring(row["type"])][tonumber(row["slot"])],"create")
					end
					loadedItems = loadedItems+1
				end
            end, function()
                if rows > 0 then
					outputDebugString("[ITEMS] "..loadedItems.." item in "..(getTickCount()-tick).."ms!");

					for k,safe in ipairs(getElementsByType("object")) do
						if getElementData(safe,"object:dbid") then
							setElementData(safe,"inventory:items",func.getItems(safe));
						end
					end

					for k,vehicle in ipairs(getElementsByType("vehicle")) do
						if getElementData(vehicle,"veh:id") then
							setElementData(vehicle,"inventory:items",func.getItems(vehicle));
						end
					end

                end
            end)
        end
    end,connection, "SELECT * FROM `items`");

	dbQuery(function(qh)
		local result, rows = dbPoll(qh, 0)
		if rows > 0 then
			for k,v in pairs(result) do
				loadedWorldItems(v)
			end
		end
	end, connection, "SELECT * FROM worlditems")

end
addEventHandler("onResourceStart",resourceRoot,func.start)

function loadedWorldItems(data)
	--iprint(data)
	-- id, itemCount, itemId, itemState, itemValue, objectId, owner, ownerName, position(x,y,z,rx,ry,rz,int,dim)
	--triggerClientEvent()
	local position = fromJSON(data["position"])
	local worldItemObject = createObject(data["objectId"], position[1], position[2], position[3]+0.2, position[4], position[5], position[6])
	if isElement(worldItemObject) then
		setElementVisibleTo(worldItemObject, root, true)
		setElementInterior(worldItemObject,position[7])
		setElementDimension(worldItemObject,position[8])
		setElementData(worldItemObject, "isWorldItem", true)
		setElementData(worldItemObject, "worldItem:id", data["id"])
		setElementData(worldItemObject, "worldItem:itemId", data["itemId"])
		setElementData(worldItemObject, "worldItem:itemValue", data["itemValue"])
		setElementData(worldItemObject, "worldItem:itemState", data["itemState"])
		setElementData(worldItemObject, "worldItem:itemCount", data["itemCount"])
		setElementData(worldItemObject, "worldItem:owner", data["owner"])
		setElementData(worldItemObject, "worldItem:ownerName", data["ownerName"])
	--	triggerClientEvent(root,"setModelLod", root, worldItemObject,data["objectId"])
		return true
	end
	return false
end

addEvent("deleteWorldItem", true)
addEventHandler("deleteWorldItem", getRootElement(), function(player, worldItemElement)
	if isElement(worldItemElement) then
		local id = getElementData(worldItemElement, "worldItem:id")
		local itemId = getElementData(worldItemElement, "worldItem:itemId")
		local itemValue = getElementData(worldItemElement, "worldItem:itemValue")
		local itemState = getElementData(worldItemElement, "worldItem:itemState")
		local itemCount = getElementData(worldItemElement, "worldItem:itemCount")
		local state = checkPlayerInventory(player,itemId, itemCount)
		if state then
			giveItem(player, itemId, itemValue, itemCount, 0, itemState)
			setPedAnimation(player, "CARRY", "liftup", 1500, false, false, false, false)
			chat:sendLocalMeAction(player, "apanha um item do chão.")
			dbExec(connection, "DELETE FROM worlditems WHERE id = ?", id)
			for k,v in ipairs(getElementsByType("object")) do
				if getElementData(v, "isWorldItem") then
					if getElementData(v, "worldItem:id") == id then
						destroyElement(v)
						return
					end
				end
			end
		end
	end
end)

addEvent("placeWorldItem", true)
addEventHandler("placeWorldItem", getRootElement(), function(player, itemData, worldX, worldY, worldZ)
	if itemData then
		local itemId = itemData["item"]
		local itemValue = itemData["value"]
		local itemCount = itemData["count"]
		local itemState = itemData["state"]
		local objectId = 2969
		local rotation = {0, 0, 0}
		local pDim = getElementDimension(player)
		local pInt = getElementInterior(player)
		local owner = getElementData(player, "char:id")
		local ownerName = getElementData(player, "char:name"):gsub("_", " ")
		if availableItems[itemId].rotation then
			rotation = {availableItems[itemId].rotation[1], availableItems[itemId].rotation[2], availableItems[itemId].rotation[3]}
		end
		if availableItems[itemId].objectId then
			objectId = availableItems[itemId].objectId
		end
		local position = toJSON({worldX, worldY, worldZ, rotation[1], rotation[2], rotation[3], pInt, pDim})
		takeItemFromSlot(player, itemId, itemCount, itemData["slot"])
		-- id, itemCount, itemId, itemState, itemValue, objectId, owner, ownerName, position(x,y,z,rx,ry,rz,int,dim)
		dbQuery(function(qh)
			local result = dbPoll(qh, 0, true)[2][1][1]
			if result then
				if loadedWorldItems(result) then
					if isElement(player) then
						setPedAnimation(player, "CARRY", "putdwn", 1500, false, false, false, false)
						chat:sendLocalMeAction(player, "larga um item no chão.")
					end
				else
					outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Erro interno — avise um desenvolvedor @275(loadedWorldItems nil id: ".. result.id..")!", player, 220,20,60,true)
				end
			elseif result == nil then
				outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Erro interno — avise um desenvolvedor @282(result nil)!", player, 220,20,60,true)
			end
		end,connection, "INSERT INTO worlditems (itemId, itemState, itemValue, itemCount, owner, ownerName, position, objectId) VALUES(?, ?, ?, ?, ?, ?, ?, ?); SELECT * FROM worlditems ORDER BY id DESC LIMIT 1", itemId, itemState, itemValue, itemCount, owner, ownerName, position, objectId)
	else
		outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Erro interno — avise um desenvolvedor @251(ItemData nil)!", player, 220,20,60,true)
	end
end)

function loadVehicleInventory(veh)
	setElementData(veh,"inventory:items",func.getItems(veh));
end

func.getPlayerElementById = function(dbid)
	for k,v in pairs(getElementsByType("player")) do
		local id = func.getElementID(v);
		if id and id == dbid then
			return v;
		end
	end
	return nil;
end

func.getElementById = function(element,dbid)
	for k,v in pairs(getElementsByType(element)) do
		local id = func.getElementID(v);
		if id and id == dbid then
			return v;
		end
	end
	return nil;
end

function syncItems(element)
	if getElementData(element,"veh:id") or (getElementData(element,"object:dbid") and getElementModel(element) == 2332) then
		local id = func.getElementID(element);
		setElementData(element,"inventory:items",itemCache[id]);
	end
end

func.generateDate = function()
	local realTime = getRealTime()

    local date = {(realTime.year)+1900,(realTime.month)+1,realTime.monthday,realTime.hour,realTime.minute,realTime.second}

	if date[2] < 10 then
		date[2] = "0"..date[2]
	end
	if date[3] < 10 then
		date[3] = "0"..date[3]
	end

	return date[1].."."..date[2].."."..date[3].."."
end

local monthDays = {
	[1] = 31, -- jan
	[2] = 28, -- feb
	[3] = 31, -- márc
	[4] = 30, -- ápr
	[5] = 31, -- máj
	[6] = 30, -- jún
	[7] = 31, -- júl
	[8] = 31, -- aug
	[9] = 30, -- szept
	[10] = 31, -- okt
	[11] = 30, -- nov
	[12] = 31, -- dec
}

func.generateLastday = function()
	local realTime = getRealTime()
	local year, month, day = realTime.year + 1900, realTime.month + 1, realTime.monthday
	if day+28 > monthDays[month] then
		if month+1 > 12 then
			year = year + 1
			month = month - 11
		else
			month = month + 1
		end
	else
		day = day + 28
	end
	if day > monthDays[month] then
		day = monthDays[month]
	elseif month > 12 then
		month = 12
	end
	if month < 10 then
		month = "0"..month
	end
	if day < 10 then
		day = "0"..day
	end
	return year.."."..month.."."..day.."."
end

func.checkBuggedItems = function(playerSource)
	local owner = func.getElementID(playerSource);
	dbQuery(function(qh,playerSource)
		local res, rows, err = dbPoll(qh, 0)
		if rows > 0 then
			local bugged = 0;
			local fixed = 0;
			for k, row in pairs(res) do
				if row.type == "vehicle" or row.type == "object" then
					-- ide majd valami extra megoldás kell
				else
					if (not itemCache[owner][row.type][row.slot]) or (itemCache[owner][row.type][row.slot] and itemCache[owner][row.type][row.slot].item ~= row.itemid) then
						bugged = bugged+1
						local _,newSlot = getFreeSlot(playerSource,tonumber(row.itemid))
						itemCache[owner][row.type][newSlot] = {
							["id"] = tonumber(row.id),
							["slot"] = newSlot,
							["item"] = tonumber(row.itemid),
							["value"] = tostring(row.value),
							["count"] = tonumber(row.count),
							["duty"] = tonumber(row.dutyitem),
							["pp"] = tonumber(row.pp),
							["warn"] = tonumber(row.warn),
							["state"] = tonumber(row.itemState),
							["weaponserial"] = tostring(row.weaponserial),
						}
						if itemCache[owner][row.type][newSlot] then
							fixed = fixed+1;
						end
						dbExec(connection,"UPDATE `items` SET `slot` = ? WHERE `id` = ?",newSlot,tonumber(row.id))
						if weaponCache[tonumber(row.itemid)] and weaponCache[tonumber(row.itemid)].isBack then
							attachWeapon(playerSource,tonumber(row.itemid),tonumber(row.id),tonumber(row.value))
						end
						triggerClientEvent(playerSource,"refreshItem",playerSource,playerSource,itemCache[owner][row.type][newSlot],"create")
					else
						if row.slot == -1 or row.slot > 50 then
							bugged = bugged+1;
							if getElementType(playerSource) == "player" and weaponCache[row.itemid] and weaponCache[row.itemid].isBack then
								detachWeapon(playerSource,row.itemid,row.id)
							end
							itemCache[owner][row.type][row.slot] = nil;
							local _,newSlot = getFreeSlot(playerSource,tonumber(row.itemid))
							itemCache[owner][row.type][newSlot] = {
								["id"] = tonumber(row.id),
								["slot"] = newSlot,
								["item"] = tonumber(row.itemid),
								["value"] = tostring(row.value),
								["count"] = tonumber(row.count),
								["duty"] = tonumber(row.dutyitem),
								["pp"] = tonumber(row.pp),
								["warn"] = tonumber(row.warn),
								["state"] = tonumber(row.itemState),
								["weaponserial"] = tostring(row.weaponserial),
							}
							if itemCache[owner][row.type][newSlot] then
								fixed = fixed+1;
							end
							dbExec(connection,"UPDATE `items` SET `slot` = ? WHERE `id` = ?",newSlot,tonumber(row.id))
							if weaponCache[tonumber(row.itemid)] and weaponCache[tonumber(row.itemid)].isBack then
								attachWeapon(playerSource,tonumber(row.itemid),tonumber(row.id))
							end

							triggerClientEvent(playerSource,"refreshItem",playerSource,playerSource,itemCache[owner][row.type][newSlot],"create")
						end
					end
				end
			end
			if bugged > 0 then
				--outputChatBox(core:getServerPrefix("server", "Inventário", 3).."Neked "..color..bugged.."#ffffff hibás tárgyad volt. Ebből "..color..fixed.."#ffffff lett visszaállítva.",playerSource,220,20,60,true);
				triggerClientEvent(playerSource,"setItems",playerSource,playerSource,1,itemCache[owner])
			end
		end
	end,{playerSource},connection, "SELECT * FROM `items` WHERE `owner` = ?",owner);
end
addEvent("checkBuggedItems",true)
addEventHandler("checkBuggedItems",getRootElement(),func.checkBuggedItems)

func.checkPlayerInventory = function(playerSource,cmd,target)
	if exports["oAdmin"]:hasPermission(playerSource,"debuginventory") then
		if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(playerSource) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

		if target then
			local targetPlayer,targetPlayerName = core:getPlayerFromPartialName(playerSource,target);
			if targetPlayer then
				if getElementData(targetPlayer,"user:loggedin") then
					outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Verificação concluída (itens travados/corrompidos) de "..color..getElementData(targetPlayer,"char:name").."#ffffff.",playerSource,220,20,60,true)
					func.checkBuggedItems(targetPlayer);
				end
			end
		else
			outputChatBox("Uso:#ffffff /"..cmd.." [ID/nome]",playerSource,r,g,b,true)
		end
	end
end
addCommandHandler("debuginventory",func.checkPlayerInventory)

func.stop = function()
	for k,v in ipairs(getElementsByType("vehicle")) do
		if getElementData(v,"veh:use") then
			setElementData(v,"veh:use",false)
			setElementData(v,"veh:player",nil)
			func.doorState(v,0)
		end
	end
end
addEventHandler("onResourceStop",resourceRoot,func.stop)

func.getItems = function(element,value)
	local owner = func.getElementID(element);
	if value == 1 or value == 2 then
		triggerClientEvent(source,"setItems",source,element,value,itemCache[owner])
	else
		return itemCache[owner]
	end
end
addEvent("getItems",true)
addEventHandler("getItems",getRootElement(),func.getItems)

func.setItemCache = function(playerSource)
	local owner = func.getElementID(playerSource);
	if not getElementData(playerSource,"show:inv") then
		triggerClientEvent(playerSource,"setItems",playerSource,playerSource,2,itemCache[owner])
	end
end

func.updateSlot = function(element,oldSlot,newSlot,data)
	local owner = func.getElementID(element);
	--print(itemCache[owner][getTypeElement(element,data["item"])[1]][oldSlot])
	if itemCache[owner][getTypeElement(element,data["item"])[1]][oldSlot] then
	--	print(newSlot)
		dbExec(connection,"UPDATE `items` SET `slot` = ? WHERE `id` = ?",newSlot,data["id"])
		itemCache[owner][getTypeElement(element,data["item"])[1]][newSlot] = {
			["id"] = data["id"],
			["slot"] = newSlot,
			["item"] = data["item"],
			["value"] = data["value"],
			["count"] = data["count"],
			["duty"] = data["duty"],
			["pp"] = data["pp"],
			["warn"] = data["warn"],
			["state"] = data["state"],
			["weaponserial"] = data["weaponserial"],
		}
		itemCache[owner][getTypeElement(element,data["item"])[1]][oldSlot] = nil
		syncItems(element);
	end
end
addEvent("updateSlot",true)
addEventHandler("updateSlot",getRootElement(),func.updateSlot)

function setItemCount(element,data,count,state,playerSource)
	local owner = func.getElementID(element);
	if itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]] then
		dbExec(connection,"UPDATE `items` SET `count` = ? WHERE `id` = ?",count,data["id"]);
		itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]]["count"] = count;
		if state then
			if playerSource then
				triggerClientEvent(playerSource,"refreshItem",playerSource,element,itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]],"create")
			else
				triggerClientEvent(element,"refreshItem",element,element,itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]],"create")
			end
		end
		syncItems(element);
	end
end
addEvent("setItemCount",true)
addEventHandler("setItemCount",getRootElement(),setItemCount)

function setItemValue(element,data,value,state,playerSource)
	local owner = func.getElementID(element);
	if itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]] then
		dbExec(connection,"UPDATE `items` SET `value` = ? WHERE `id` = ?",value,data["id"]);
		itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]]["value"] = value;
		if state then
			if playerSource then
				triggerClientEvent(playerSource,"refreshItem",playerSource,element,itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]],"create")
			else
				triggerClientEvent(element,"refreshItem",element,element,itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]],"create")
			end
		end
		syncItems(element);
	end
end
addEvent("setItemValue",true)
addEventHandler("setItemValue",getRootElement(),setItemValue)

function setItemState(element,data,state)
	local owner = func.getElementID(element);
	if itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]] then
		dbExec(connection,"UPDATE `items` SET `itemState` = ? WHERE `id` = ?",state,data["id"]);
		itemCache[owner][getTypeElement(element, data["item"])[1]][data["slot"]]["state"] = state;
		syncItems(element);
	end
end
addEvent("setItemState",true)
addEventHandler("setItemState",getRootElement(),setItemState)

function createStackedItem(element, slot, data, count)
    giveItem(source, tonumber(data["item"]),tostring(data["value"]),tonumber(count),tonumber(data["duty"]),tonumber(data["state"]),slot,tostring(data["weaponserial"]),element,tonumber(data["pp"]),tonumber(data["warn"]));
end
addEvent("createStackedItem",true)
addEventHandler("createStackedItem",getRootElement(),createStackedItem)

func.itemTransfer = function(element,movedElement,data,weaponProgress)
	local playerOwner = func.getElementID(source);
	local elementOwner = func.getElementID(element);
	local movedOwner = func.getElementID(movedElement);
	if source ~= element and source ~= movedElement then
		return
	end
	if itemCache[elementOwner][getTypeElement(element,tonumber(data.item))[1]][tonumber(data["slot"])] then
		local weight = getElementItemsWeight(movedElement)
		if weight + (getItemWeight(data.item) * data.count) > getTypeElement(movedElement,data.item)[3] then
			outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."O elemento selecionado não suporta mais peso no inventário.", source,220,20,60, true)
			return
		end

		local state,slot = getFreeSlot(movedElement,data.item);
		if state then
			dbExec(connection,"UPDATE `items` SET `slot` = ?, `type` = ?, `owner` = ? WHERE `id` = ?",tonumber(slot),getTypeElement(movedElement,tonumber(data.item))[1],movedOwner,tonumber(data["id"]));
			itemCache[movedOwner][getTypeElement(movedElement,tonumber(data.item))[1]][tonumber(slot)] = {
				["id"] = tonumber(data["id"]),
				["slot"] = tonumber(slot),
				["item"] = tonumber(data.item),
				["value"] = tostring(data["value"]),
				["count"] = tonumber(data["count"]),
				["duty"] = tonumber(data["duty"]),
				["pp"] = tonumber(data["pp"]),
				["warn"] = tonumber(data["warn"]),
				["state"] = tonumber(data["state"]),
				["weaponserial"] = tostring(data["weaponserial"]),
			};
			itemCache[elementOwner][getTypeElement(element,tonumber(data.item))[1]][tonumber(data["slot"])] = nil;
			if getElementType(movedElement) == "player" and movedElement ~= source then
				if weaponCache[data.item] and weaponCache[data.item].isBack then
					detachWeapon(source,data.item,data.id)
					attachWeapon(movedElement,data.item,data.id,data.value)
				end

				chat:sendLocalMeAction(source, "entrega um item a "..getElementData(movedElement,"char:name"):gsub("_", " ").." ("..getItemName(data.item, data.value)..")")
				setPedAnimation(source,"DEALER","DEALER_DEAL",3000,false,false,false,false)
				setPedAnimation(movedElement,"DEALER","DEALER_DEAL",3000,false,false,false,false)
				triggerClientEvent(movedElement,"refreshItem",movedElement,movedElement,itemCache[movedOwner][getTypeElement(movedElement,tonumber(data.item))[1]][tonumber(slot)],"create",weaponProgress)
			elseif getElementType(movedElement) == "vehicle" and movedElement ~= source then
				chat:sendLocalMeAction(source, "coloca um item no porta-malas do veículo. ("..getItemName(data.item)..")")
				if weaponCache[data.item] and weaponCache[data.item].isBack then
					detachWeapon(source,data.item,data.id)
				end
				setElementData(movedElement,"inventory:items",itemCache[movedOwner]);
			elseif getElementType(element) == "vehicle" and movedElement == source then
				chat:sendLocalMeAction(source, "retira um item do porta-malas do veículo. ("..getItemName(data.item)..")")
				triggerClientEvent(source,"refreshItem",source,source,itemCache[movedOwner][getTypeElement(source,tonumber(data.item))[1]][tonumber(slot)],"create")
				if weaponCache[data.item] and weaponCache[data.item].isBack then
					attachWeapon(movedElement,data.item,data.id,data.value)
				end
				setElementData(element,"inventory:items",itemCache[elementOwner]);
			elseif getElementType(movedElement) == "object" and movedElement ~= source then
				chat:sendLocalMeAction(source, "coloca um item no cofre. ("..getItemName(data.item)..")")
				if weaponCache[data.item] and weaponCache[data.item].isBack then
					detachWeapon(source,data.item,data.id)
				end
				setElementData(movedElement,"inventory:items",itemCache[movedOwner]);
			elseif getElementType(element) == "object" and movedElement == source then
				chat:sendLocalMeAction(source, "retira um item do cofre. ("..getItemName(data.item)..")")
				triggerClientEvent(source,"refreshItem",source,source,itemCache[movedOwner][getTypeElement(source,tonumber(data.item))[1]][tonumber(slot)],"create")
				if weaponCache[data.item] and weaponCache[data.item].isBack then
					attachWeapon(movedElement,data.item,data.id,data.value)
				end
				setElementData(element,"inventory:items",itemCache[elementOwner]);
			end
			triggerClientEvent(source,"refreshItem",source,element,data,"delete",data["id"])
		else
			outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Não há mais slots livres neste inventário.",source,220,20,60,true);
		end
	end
end
addEvent("itemTransfer",true)
addEventHandler("itemTransfer",getRootElement(),func.itemTransfer)

function deleteItem(element,data,state,playerSource)
	--if (availableItems[data["item"]].category or "bag"):lower() ~= ("key"):lower() then  
		local owner = func.getElementID(element);
		dbExec(connection,"DELETE FROM `items` WHERE `id` = ?",data["id"])
		if getElementType(element) == "player" and weaponCache[data.item] and weaponCache[data.item].isBack then
			detachWeapon(element,data.item,data.id)
		end

		itemCache[owner][getTypeElement(element,tonumber(data["item"]))[1]][tonumber(data["slot"])] = nil;
		syncItems(element);
		if state then
			if playerSource then
				triggerClientEvent(playerSource,"refreshItem",playerSource,element,data,"delete")
			else
				triggerClientEvent(element,"refreshItem",element,element,data,"delete")
			end
		end
	--end
end
addEvent("deleteItem",true)
addEventHandler("deleteItem",getRootElement(),deleteItem)

function hasItem(element,item,value)
	local owner = func.getElementID(element);
	if not itemCache[owner] then
		itemCache[owner] = {
			["bag"] = {},
			["key"] = {},
			["licens"] = {},
			["vehicle"] = {},
			["object"] = {},
		}
	end

	for i=1, row*column do
		if itemCache[owner][getTypeElement(element,item)[1]][i] then
			if not value then
				if itemCache[owner][getTypeElement(element,item)[1]][i]["item"] == item then
					return true,i,itemCache[owner][getTypeElement(element,item)[1]][i];
				end
			else
				if itemCache[owner][getTypeElement(element,item)[1]][i]["item"] == item and tonumber(itemCache[owner][getTypeElement(element,item)[1]][i]["value"]) == tonumber(value) then
					return true,i,itemCache[owner][getTypeElement(element,item)[1]][i];
				end
			end
		end
	end
	return false,-1,nil
end

function takeItemFromSlot(element, item, takeCount, slot)
	local owner = func.getElementID(element);
	local showElement = getElementData(element,"veh:player") or getElementData(element,"safe:player")
	if not itemCache[owner] then
		itemCache[owner] = {
			["bag"] = {},
			["key"] = {},
			["licens"] = {},
			["vehicle"] = {},
			["object"] = {},
		}
	end
	local count = 0

	if not takeCount then
		takeCount = 1
	end
	if itemCache[owner][getTypeElement(element,item)[1]] then
		--for i = 1, row * column do
			if itemCache[owner][getTypeElement(element,item)[1]][slot] then
				if itemCache[owner][getTypeElement(element,item)[1]][slot]["item"] == item then
				--	count = count+1
				--	if count == 1 then
						if itemCache[owner][getTypeElement(element,item)[1]][slot]["count"] > takeCount then
							setItemCount(element,itemCache[owner][getTypeElement(element,item)[1]][slot],itemCache[owner][getTypeElement(element,item)[1]][slot]["count"]-takeCount,true,showElement);
						else
							deleteItem(element,itemCache[owner][getTypeElement(element,item)[1]][slot],true,showElement);
						end
				--	end
				end
			end
		--end
		syncItems(element);
	end
end

function takeItem(element,item,takeCount)
	local owner = func.getElementID(element);
	local showElement = getElementData(element,"veh:player") or getElementData(element,"safe:player")
	if not itemCache[owner] then
		itemCache[owner] = {
			["bag"] = {},
			["key"] = {},
			["licens"] = {},
			["vehicle"] = {},
			["object"] = {},
		}
	end
	local count = 0

	if not takeCount then
		takeCount = 1
	end

	if getTypeElement(element,item)[1]:lower() ~= ("key"):lower() then 
		if itemCache[owner][getTypeElement(element,item)[1]] then
			for i = 1, row * column do
				if itemCache[owner][getTypeElement(element,item)[1]][i] then
					if itemCache[owner][getTypeElement(element,item)[1]][i]["item"] == item then
						count = count+1
						if count == 1 then
							if itemCache[owner][getTypeElement(element,item)[1]][i]["count"] > takeCount then
								setItemCount(element,itemCache[owner][getTypeElement(element,item)[1]][i],itemCache[owner][getTypeElement(element,item)[1]][i]["count"]-takeCount,true,showElement);
							else
								deleteItem(element,itemCache[owner][getTypeElement(element,item)[1]][i],true,showElement);
							end
						end
					end
				end
			end
			syncItems(element);
		end
	end
end
addEvent("takeItem", true)
addEventHandler("takeItem", root, takeItem)

function takeAllItem(item,value)
	value = tonumber(value)

	for owner,k in pairs(itemCache) do
		for category,k2 in pairs(itemCache[owner]) do
			for slot,itemData in pairs(itemCache[owner][category]) do
				if category:lower() ~= ("key"):lower() then 
					if itemData.item == item and tonumber(itemData.value) == value then
						if itemCache[owner][category][slot] then
							dbExec(connection,"DELETE FROM `items` WHERE `id` = ?",itemData.id)
							local selectedtype = category;
							if category == "bag" or category == "key" or category == "licens" then
								selectedtype = "player";
							end
							local founded,element = func.getTypeByOwner(selectedtype,owner);
							if founded then
								local selectedElement = element;
								if selectedtype == "vehicle" or selectedtype == "object" then
									selectedElement = getElementData(element,"veh:player") or getElementData(element,"safe:player");
									if not selectedElement then selectedElement = element end
								end
								triggerClientEvent(selectedElement,"refreshItem",selectedElement,element,itemCache[owner][category][slot],"delete")
								itemCache[owner][category][slot] = nil;
								syncItems(element);
							else
								itemCache[owner][category][slot] = nil;
							end
						end
					end
				end
			end
		end
	end
end

func.getTypeByOwner = function(typ,dbid)
	for k,v in ipairs(getElementsByType(typ)) do
		if func.getElementID(v) == dbid then
			return true,v;
		end
	end
	return false,nil;
end

func.findElementByDbid = function(dbid)
	for k,v in ipairs(getElementsByType("player")) do
		if func.getElementID(v) == dbid then
			return v;
		end
	end
	return nil;
end

func.takePlayerItem = function(playerSource,cmd,target,item)
	if exports["oAdmin"]:hasPermission(playerSource,"takeitem") then
		if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(playerSource) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

		item = tonumber(item);
		if type(item) == "number" and target then
			if getElementData(playerSource,"user:loggedin") then
				local targetPlayer,targetPlayerName = core:getPlayerFromPartialName(playerSource,target)
				if targetPlayer then
					if hasItem(targetPlayer,tonumber(item)) then
						takeItem(targetPlayer,tonumber(item))
						outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Removeu com sucesso de "..color..getElementData(targetPlayer,"char:name").."#ffffff um(a) "..color..getItemName(item).."#ffffff.",playerSource,220,20,60,true)
						outputChatBox(core:getServerPrefix("server", "Inventário", 3)..color..getElementData(playerSource,"user:anick").."#ffffff removeu de você: "..color..getItemName(item).."#ffffff.",targetPlayer,220,20,60,true)

						admin:sendMessageToAdmins(playerSource, "removeu #db3535"..getItemName(item).." #557ec9 de #db3535"..string.gsub(getPlayerName(targetPlayer), "_", " ").."#557ec9.")
					else
						outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."O jogador selecionado não tem esse item.",playerSource,220,20,60,true)
					end
				end
			end
		else
			outputChatBox("Uso:#ffffff /"..cmd.." [ID/nome] [item]",playerSource,r, g, b,true)
		end
	end
end
addCommandHandler("takeitem",func.takePlayerItem)
addCommandHandler("retiraritem", func.takePlayerItem)
addCommandHandler("removeritem", func.takePlayerItem)


--[[addCommandHandler("asdasd2",function(playerSource)
	for k,v in ipairs(getElementsByType("vehicle")) do
		if func.getElementID(v)and func.getElementID(v) == 1 then
			takeItem(v,32)
		end
	end
end)]]

function getFreeSlot(element,item)
    local owner = func.getElementID(element);
	if not itemCache[owner] then
		itemCache[owner] = {
			["bag"] = {},
			["key"] = {},
			["licens"] = {},
			["vehicle"] = {},
			["object"] = {},
		}
	end

	for i=1, row*column do
		if(not itemCache[owner][getTypeElement(element,item)[1]][i])then
			return true, i
		end
	end
	return false, -1
end

function getElementItemsWeight(element)
	local owner = func.getElementID(element);
	if not itemCache[owner] then
		itemCache[owner] = {
			["bag"] = {},
			["key"] = {},
			["licens"] = {},
			["vehicle"] = {},
			["object"] = {},
		}
	end
	local bagWeight = 0
	local keyWeight = 0
	local licensWeight = 0
	local vehWeight = 0
	local objectWeight = 0
	if getElementType(element) == "player" then
		for i = 1, row * column do
			if (itemCache[owner]["bag"][i]) then
				bagWeight = bagWeight + (getItemWeight(itemCache[owner]["bag"][i]["item"]) * itemCache[owner]["bag"][i]["count"])
			end
		end
		for i = 1, row * column do
			if (itemCache[owner]["key"][i]) then
				keyWeight = keyWeight + (getItemWeight(itemCache[owner]["key"][i]["item"]) * itemCache[owner]["key"][i]["count"])
			end
		end
		for i = 1, row * column do
			if (itemCache[owner]["licens"][i]) then
				licensWeight = licensWeight + (getItemWeight(itemCache[owner]["licens"][i]["item"]) * itemCache[owner]["licens"][i]["count"])
			end
		end
	end
	if getElementType(element) == "vehicle" then
		for i = 1, row * column do
			if (itemCache[owner]["vehicle"][i]) then
				vehWeight = vehWeight + (getItemWeight(itemCache[owner]["vehicle"][i]["item"]) * itemCache[owner]["vehicle"][i]["count"])
			end
		end
	end
	if getElementType(element) == "object" then
		for i = 1, row * column do
			if (itemCache[owner]["object"][i]) then
				objectWeight = objectWeight + (getItemWeight(itemCache[owner]["object"][i]["item"]) * itemCache[owner]["object"][i]["count"])
			end
		end
	end
	return math.ceil(bagWeight + licensWeight + keyWeight + vehWeight + objectWeight)
end

local giveItemCounter = {}
setTimer(function()
 for k, v in pairs(giveItemCounter) do 
	giveItemCounter[k] = 0
 end 
end, 1000, 0)
function giveItem(playerSource,item,value,count,dutyitem,state,slot,weaponserial,element,ppitem,warn)
	if giveItemCounter[playerSource] then
		giveItemCounter[playerSource] = giveItemCounter[playerSource] + 1

		if giveItemCounter[playerSource] > 15 then 
			print("[INVENTÁRIO] Spam de giveItem / possível exploit — serial: ", getPlayerSerial(playerSource))
			kickPlayer(playerSource, "inventory")
		end
	else 
		giveItemCounter[playerSource] = 1
	end


	if not dutyitem then
		dutyitem = 0;
	end

	if not ppitem then
		ppitem = 0;
	end

	if not warn then
		warn = 0;
	end

	local newSlot = -1;
	if weaponCache[item] then
		weaponserial = weaponserial or generateSerial();
	else
		weaponserial = "";
	end

	element = element or playerSource

	if not state then
		state = 100;
	end

	if not slot then
		_,newSlot = getFreeSlot(element,item)
	else
		newSlot = slot
	end

	if count <= 0 then
		count = 1
	end

	local owner = func.getElementID(element);
	if not itemCache[owner] then
		itemCache[owner] = {
			["bag"] = {},
			["key"] = {},
			["licens"] = {},
			["vehicle"] = {},
			["object"] = {},
		}
	end

	dbExec(connection, "INSERT INTO `items` SET `itemid` = ?, `slot` = ?, `value` = ?, `count` = ?, `dutyitem` = ?, `type` = ?, `itemState` = ?, `weaponserial` = ?, `owner` = ?, `pp` = ?, `warn` = ?",item,newSlot,value,count,dutyitem,getTypeElement(element,item)[1],state,weaponserial,func.getElementID(element),ppitem,warn)

	dbQuery(function(query,playerSource,element)
        local _, _, id = dbPoll(query, 0);
        if id > 0 then
			if item == 1 then
				local value_phonenumber = "2812"..tostring(id*2)

				value = value_phonenumber
			elseif item == 204 then
				state = 20
			elseif item == 223 then
				value = 30
			elseif item == 84 then
				value = 30
			elseif item == 226 then
				value = 30
			elseif item == 227 then
				value = 30
			end

            local owner = func.getElementID(element);
			if not itemCache[owner] then
				itemCache[owner] = {
					["bag"] = {},
					["key"] = {},
					["licens"] = {},
					["vehicle"] = {},
					["object"] = {},
				}
			end

			if not slot then
				_,newSlot = getFreeSlot(element,item)
			else
				newSlot = slot
			end


			value = value;

			itemCache[owner][getTypeElement(element,item)[1]][newSlot] = {
				["id"] = id,
				["slot"] = newSlot,
				["item"] = item,
				["value"] = value,
				["count"] = count,
				["duty"] = dutyitem,
				["pp"] = ppitem,
				["warn"] = warn,
				["state"] = state,
				["weaponserial"] = weaponserial,
			}

			setTimer(syncItems, 250, 1, element);

			dbExec(connection,"UPDATE `items` SET `slot` = ?, `value` = ? WHERE `id` = ?",newSlot,value,id)
			if playerSource == element then
				if weaponCache[item] and weaponCache[item].isBack then
					attachWeapon(element,item,id,value)
				end
			end
			triggerClientEvent(playerSource,"refreshItem",playerSource,element,itemCache[owner][getTypeElement(element,item)[1]][newSlot],"create")
		end
    end,{playerSource,element},connection, "SELECT * FROM `items` WHERE `id` = LAST_INSERT_ID() AND `owner` = ?", owner);

end
addEvent("giveItem",true)
addEventHandler("giveItem",getRootElement(),giveItem)

function setCardMoney(playerSource,slot,newMoney)
	local owner = func.getElementID(playerSource);
	if itemCache[owner]["licens"][slot] then
		local jsonData = fromJSON(itemCache[owner]["licens"][slot].value);
		if jsonData.money ~= newMoney then
			jsonData.money = newMoney;
			local newValue = toJSON(jsonData);
			setItemValue(playerSource,itemCache[owner]["licens"][slot],newValue,true);
		end
	end
end
addEvent("setCardMoneyS",true)
addEventHandler("setCardMoneyS",getRootElement(),setCardMoney)

function transferCardMoney(owner,slot,amount)
	if itemCache[owner]["licens"][slot] then
		local jsonData = fromJSON(itemCache[owner]["licens"][slot].value);
		jsonData.money = jsonData.money + amount;
		local newValue = toJSON(jsonData);
		itemCache[owner]["licens"][slot].value = newValue;
		dbExec(connection,"UPDATE `items` SET `value` = ? WHERE `id` = ?",newValue,itemCache[owner]["licens"][slot].id)
		local element = func.findElementByDbid(owner);
		if element then
			triggerClientEvent(element,"refreshItem",element,element,itemCache[owner]["licens"][slot],"create")
		end
	end
end

function setCardPinCode(playerSource,slot,newPin)
	local owner = func.getElementID(playerSource);
	if itemCache[owner]["licens"][slot] then
		local jsonData = fromJSON(itemCache[owner]["licens"][slot].value);
		if jsonData.pincode ~= newPin then
			jsonData.pincode = newPin;
			local newValue = toJSON(jsonData);
			setItemValue(playerSource,itemCache[owner]["licens"][slot],newValue,true);
		end
	end
end

function findCard(cardnumber)
	for owner,k in pairs(itemCache) do
		for category,k2 in pairs(itemCache[owner]) do
			for slot,itemData in pairs(itemCache[owner]["licens"]) do
				if itemData.item == 120 and itemCache[owner]["licens"][slot] then
					local cardData = fromJSON(itemCache[owner]["licens"][slot].value);
					local number = cardData.num1.."-"..cardData.num2;
					if number == cardnumber then
						return true,cardData,slot,owner;
					end
				end
			end
		end
	end
	return false,nil,owner;
end

function findPlayerCardsByDbid(dbid)
	local count = 0;
	for owner,k in pairs(itemCache) do
		for slot,itemData in pairs(itemCache[owner]["licens"]) do
			if itemData.item == 120 and itemCache[owner]["licens"][slot] then
				local cardData = fromJSON(itemData.value);
				if cardData.charid == dbid then
					count = count + 1;
				end
			end
		end
	end
	return count;
end

func.setIdentityNewDate = function(playerSource,type,price,itemData)
	local newDate = func.generateLastday();
	setElementData(playerSource,"money",getElementData(playerSource,"money")-price);
	local jsonData = fromJSON(itemData.value)
	if itemData.item == 71 or itemData.item == 262 or itemData.item == 261 then
		jsonData[1] = getElementData(playerSource,"player:charname");
	end
	jsonData[6] = newDate;
	local newValue = toJSON(jsonData)
	setItemValue(playerSource,itemData,newValue,true);
end
addEvent("setIdentityNewDate",true)
addEventHandler("setIdentityNewDate",getRootElement(),func.setIdentityNewDate)

func.givePlayerItem = function(playerSource,cmd,target,item,value,count,dutyitem,itemstate,wserial,ppitem)
	if exports["oAdmin"]:hasPermission(playerSource,"giveitem") then
		if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(playerSource) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

		if target and item and value and count and dutyitem then
			item = tonumber(item);
			value = tostring(value);
			count = tonumber(count);
			dutyitem = tonumber(dutyitem);
			itemstate = tonumber(itemstate);

			if count <= 0 then
				count = 1
			end

			if not itemstate then itemstate = 100 end
			if not wserial then wserial = "Unknown" end
			if not ppitem then ppitem = 0 end
			local targetPlayer,targetPlayerName = core:getPlayerFromPartialName(playerSource,target)
			if targetPlayer then
				if getElementData(targetPlayer,"user:loggedin") then
					if availableItems[item] then
						local state,slot = getFreeSlot(targetPlayer,item)
						if state then
							local weight = getElementItemsWeight(targetPlayer)
							if weight + (getItemWeight(item) * count) > getTypeElement(targetPlayer,item)[3] then
								outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."O jogador selecionado não aguenta mais itens.", playerSource,220,20,60, true)
								return
							end

							giveItem(targetPlayer,item,value,count,dutyitem,itemstate,slot,wserial,targetPlayer,ppitem);
							admin:sendMessageToAdmins(playerSource, "deu #db3535"..getItemName(tonumber(item),tostring(value)).." #557ec9 (#db3535"..tonumber(count).."#557ec9×) para #db3535"..string.gsub(getPlayerName(targetPlayer), "_", " ").."#557ec9.")

							outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Deu "..color..count.."#ffffff× "..color..getItemName(item,value).."#ffffff para "..color..getElementData(targetPlayer,"char:name").."#ffffff.",playerSource,220,20,60,true)
							outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Recebeu "..color..count.."#ffffff× "..color..getItemName(item,value).."#ffffff de "..color..getElementData(playerSource,"user:adminnick").."#ffffff.",targetPlayer,220,20,60,true)
						else
							outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).." O jogador selecionado não tem mais slots livres.",playerSource,220,20,60,true)
						end
					else
						outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."ID de item inválido.",playerSource,220,20,60,true)
					end
				end
			end
		else
			outputChatBox("Uso: #ffffff /"..cmd.." [ID/nome] [item] [valor] [quantidade] [duty: 0=não, 1=sim]",playerSource,r, g, b,true)
		end
	end
end
addCommandHandler("giveitem",func.givePlayerItem)
addCommandHandler("daritem", func.givePlayerItem)

func.givePlayerGun = function(playerSource,cmd,target,item,ammo)
	if exports["oAdmin"]:hasPermission(playerSource,"giveitem") then
		if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(playerSource) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

		if target and item and ammo then
			local targetPlayer,targetPlayerName = core:getPlayerFromPartialName(playerSource,target)
			if targetPlayer then
				if getElementData(targetPlayer,"user:loggedin") then
					ammo = tonumber(ammo)
					if type(tonumber(item)) == "number" then
						local wid = tonumber(item)
						if weaponCache[wid] and weaponCache[wid].ammo > 0 then
							giveItem(targetPlayer,wid,1,1,0);
							if ammo > 0 then
								giveItem(targetPlayer,weaponCache[wid].ammo,1,ammo,0);
							end
							local wshowname = getItemName(wid, 1)
							outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Deu "..color..wshowname.."#ffffff + "..color..ammo.."#ffffff munição para "..color..getElementData(targetPlayer,"char:name").."#ffffff.",playerSource,220,20,60,true)
							outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Recebeu "..color..wshowname.."#ffffff + "..color..ammo.."#ffffff munição de "..color..getElementData(playerSource,"user:adminnick").."#ffffff.",targetPlayer,220,20,60,true)
						end
					else
						for k,v in pairs(availableItems) do
							if weaponCache[k] then
								item = item:gsub("_", " ")
								if v.name == tostring(item) then
									giveItem(targetPlayer,k,1,1,0);
									if ammo > 0 then
										giveItem(targetPlayer,weaponCache[k].ammo,1,ammo,0);
									end

									outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Deu "..color..availableItems[k].name.."#ffffff + "..color..ammo.."#ffffff munição para "..color..getElementData(targetPlayer,"char:name").."#ffffff.",playerSource,220,20,60,true)
									outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Recebeu "..color..availableItems[k].name.."#ffffff + "..color..ammo.."#ffffff munição de "..color..getElementData(playerSource,"user:adminnick").."#ffffff.",targetPlayer,220,20,60,true)

								end
							end
						end
					end
				end
			end
		else
			outputChatBox("Uso: #ffffff /"..cmd.." [ID/nome] [arma (item ou nome)] [munição]",playerSource,r, g, b,true)
		end
	end
end
addCommandHandler("givegun",func.givePlayerGun)
addCommandHandler("dararma", func.givePlayerGun)

function checkPlayerInventory(targetPlayer, item, count)
	local state,slot = getFreeSlot(targetPlayer,item)
	if state then
		local weight = getElementItemsWeight(targetPlayer)
		if weight + (getItemWeight(item) * count) > getTypeElement(targetPlayer,item)[3] then
			outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."O jogador selecionado não aguenta mais itens.", playerSource,220,20,60, true)
			return false
		end
		return true
	else
		outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).." O jogador selecionado não tem mais slots livres.",playerSource,220,20,60,true)
		return false
	end
end

func.setItemWarn = function(playerSource,cmd,target,itemdbid)
	if exports["oAdmin"]:hasPermission(playerSource,"warn") then
		if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(playerSource) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

		itemdbid = tonumber(itemdbid);
		if type(itemdbid) == "number" and target then
			if getElementData(playerSource,"user:loggedin") then
				local targetPlayer,targetPlayerName = core:getPlayerFromPartialName(playerSource,target)
				if targetPlayer then
					local owner = func.getElementID(targetPlayer);

					local a = 0;
					for i=1, row*column do
						if itemCache[owner]["bag"][i] then
							if itemCache[owner]["bag"][i]["id"] == itemdbid then
								if itemCache[owner]["bag"][i]["pp"] == 1 then
									itemCache[owner]["bag"][i]["warn"] = itemCache[owner]["bag"][i]["warn"] + 1;

									outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).." Advertência registada na arma DBID "..color..itemdbid.."#ffffff. "..color.."("..itemCache[owner]["bag"][i]["warn"].."/3)",playerSource,0,0,0,true)
									outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).." Aviso na sua arma DBID "..color..itemdbid.."#ffffff: "..color.."("..itemCache[owner]["bag"][i]["warn"].."/3)",targetPlayer,0,0,0,true)

									if itemCache[owner]["bag"][i]["warn"] >= 3 then
										deleteItem(targetPlayer,itemCache[owner]["bag"][i],true,targetPlayer)
									else
										dbExec(connection,"UPDATE `items` SET `warn` = ? WHERE `id` = ?",itemCache[owner]["bag"][i]["warn"],itemdbid);
										triggerClientEvent(targetPlayer,"refreshItem",targetPlayer,targetPlayer,itemCache[owner]["bag"][i],"create")
									end
								else
									outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).." Só pode advertir arma premium.",playerSource,0,0,0,true)
								end

								a = a + 1;

							end
						end
					end

					if a == 0 then
						outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).." Não há arma premium com esse ID no inventário.",playerSource,0,0,0,true)
					end
				end
			end
		else
			outputChatBox("Uso:#ffffff /"..cmd.." [ID/nome] [itemDBID]",playerSource,r, g, b,true)
		end
	end
end
addCommandHandler("warn",func.setItemWarn)

-- Licenses --
function createLicense(player, type)
	local createDate = {tonumber(core:getDate("year")), tonumber(core:getDate("month")), tonumber(core:getDate("monthday"))}

	if createDate[2] < 10 then
		createDate[2] = "0"..createDate[2]
	end

	if createDate[3] < 10 then
		createDate[3] = "0"..createDate[3]
	end

	local endDate = {0, 0, 0}

	if type == 1 then
		if createDate[2] == 12 then
			endDate[1] = createDate[1] + 1
			endDate[2] = 1
			endDate[3] = createDate[3]
		else
			endDate[1] = createDate[1]
			endDate[2] = createDate[2] + 1
			endDate[3] = createDate[3]
		end

		endDate[2] = tonumber(endDate[2])
		endDate[3] = tonumber(endDate[3])

		if monthDays[endDate[2]] < endDate[3] then
			endDate[3] = endDate[3] - monthDays[endDate[2]]
			endDate[2] = endDate[2] + 1
		end

		if endDate[2] < 10 then
			endDate[2] = "0"..endDate[2]
		end

		if endDate[3] < 10 then
			endDate[3] = "0"..endDate[3]
		end

		local skin = getElementModel(player)

		if skin < 10 then
			skin = "00"..skin
		elseif skin < 100 then
			skin = "0"..skin
		end

		local createDateText = createDate[1]..createDate[2]..createDate[3] -- 8
		local endDateText = endDate[1]..endDate[2]..endDate[3] --8
		local skinText = tostring(skin)
		local genderText = tostring(getElementData(player, "char:gender"))
		local ageText = tostring(getElementData(player, "char:age"))
		local nameText = getElementData(player, "char:name")

		giveItem(player, 65, createDateText..endDateText..skinText..genderText..ageText..nameText, 1, 0)
	elseif type == 2 then
		if createDate[2] == 12 then
			endDate[1] = createDate[1] + 1
			endDate[2] = 1
			endDate[3] = createDate[3]
		else
			endDate[1] = createDate[1]
			endDate[2] = createDate[2] + 1
			endDate[3] = createDate[3]
		end

		endDate[2] = tonumber(endDate[2])
		endDate[3] = tonumber(endDate[3])

		if monthDays[endDate[2]] < endDate[3] then
			endDate[3] = endDate[3] - monthDays[endDate[2]]
			endDate[2] = endDate[2] + 1
		end

		if endDate[2] < 10 then
			endDate[2] = "0"..endDate[2]
		end

		if endDate[3] < 10 then
			endDate[3] = "0"..endDate[3]
		end

		local skin = getElementModel(player)

		if skin < 10 then
			skin = "00"..skin
		elseif skin < 100 then
			skin = "0"..skin
		end

		local createDateText = createDate[1]..createDate[2]..createDate[3] -- 8
		local endDateText = endDate[1]..endDate[2]..endDate[3] --8
		local skinText = tostring(skin)
		local ageText = tostring(getElementData(player, "char:age"))
		local nameText = getElementData(player, "char:name")

		giveItem(player, 66, createDateText..endDateText..skinText..ageText..nameText, 1, 0)
	elseif type == 3 then
		if createDate[2] + 2 > 12 then
			endDate[1] = createDate[1] + 1
			endDate[2] = (createDate[2] + 2) - 12
			endDate[3] = createDate[3]
		else
			endDate[1] = createDate[1]
			endDate[2] = createDate[2] + 2
			endDate[3] = createDate[3]
		end

		endDate[2] = tonumber(endDate[2])
		endDate[3] = tonumber(endDate[3])

		if monthDays[endDate[2]] < endDate[3] then
			endDate[3] = endDate[3] - monthDays[endDate[2]]
			endDate[2] = endDate[2] + 1
		end

		if endDate[2] < 10 then
			endDate[2] = "0"..endDate[2]
		end

		if endDate[3] < 10 then
			endDate[3] = "0"..endDate[3]
		end

		local skin = getElementModel(player)

		if skin < 10 then
			skin = "00"..skin
		elseif skin < 100 then
			skin = "0"..skin
		end

		local createDateText = createDate[1]..createDate[2]..createDate[3] -- 8
		local endDateText = endDate[1]..endDate[2]..endDate[3] --8
		local skinText = tostring(skin)
		local genderText = tostring(getElementData(player, "char:gender"))
		local ageText = tostring(getElementData(player, "char:age"))
		local nameText = getElementData(player, "char:name")

		giveItem(player, 68, createDateText..endDateText..skinText..nameText, 1, 0)
	elseif type == 4 then
		if createDate[2] + 1 > 12 then
			endDate[1] = createDate[1] + 1
			endDate[2] = (createDate[2] + 1) - 12
			endDate[3] = createDate[3]
		else
			endDate[1] = createDate[1]
			endDate[2] = createDate[2] + 1
			endDate[3] = createDate[3]
		end

		endDate[2] = tonumber(endDate[2])
		endDate[3] = tonumber(endDate[3])

		if monthDays[endDate[2]] < endDate[3] then
			endDate[3] = endDate[3] - monthDays[endDate[2]]
			endDate[2] = endDate[2] + 1
		end

		if endDate[2] < 10 then
			endDate[2] = "0"..endDate[2]
		end

		if endDate[3] < 10 then
			endDate[3] = "0"..endDate[3]
		end

		local skin = getElementModel(player)

		if skin < 10 then
			skin = "00"..skin
		elseif skin < 100 then
			skin = "0"..skin
		end

		local createDateText = createDate[1]..createDate[2]..createDate[3] -- 8
		local endDateText = endDate[1]..endDate[2]..endDate[3] --8
		local skinText = tostring(skin)
		local genderText = tostring(getElementData(player, "char:gender"))
		local ageText = tostring(getElementData(player, "char:age"))
		local nameText = getElementData(player, "char:name")

		giveItem(player, 79, createDateText..endDateText..skinText..nameText, 1, 0)
	elseif type == 6 then
		if createDate[2] == 12 then
			endDate[1] = createDate[1] + 1
			endDate[2] = 1
			endDate[3] = createDate[3]
		else
			endDate[1] = createDate[1]
			endDate[2] = createDate[2]
			endDate[3] = createDate[3] + 14
		end

		endDate[2] = tonumber(endDate[2])
		endDate[3] = tonumber(endDate[3])

		if monthDays[endDate[2]] < endDate[3] then
			endDate[3] = endDate[3] - monthDays[endDate[2]]
			endDate[2] = endDate[2] + 1
		end

		if endDate[2] < 10 then
			endDate[2] = "0"..endDate[2]
		end

		if endDate[3] < 10 then
			endDate[3] = "0"..endDate[3]
		end

		local skin = getElementModel(player)

		if skin < 10 then
			skin = "00"..skin
		elseif skin < 100 then
			skin = "0"..skin
		end

		local createDateText = createDate[1]..createDate[2]..createDate[3] -- 8
		local endDateText = endDate[1]..endDate[2]..endDate[3] --8
		local skinText = tostring(skin)
		local genderText = tostring(getElementData(player, "char:gender"))
		local ageText = tostring(getElementData(player, "char:age"))
		local nameText = getElementData(player, "char:name")

		giveItem(player, 146, createDateText..endDateText..skinText..genderText..ageText..nameText, 1, 0)
	end
end

local function adminGiveLicense(playerSource, cmd, id, type)
	if exports["oAdmin"]:hasPermission(playerSource,"givelincese") then
		if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(playerSource) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

		if id and type then
			local targetPlayer, targetPlayerName = core:getPlayerFromPartialName(playerSource, id)
			if targetPlayer then
				if getElementData(targetPlayer,"user:loggedin") then
					local pSlotState, pSlotID = getFreeSlot(targetPlayer, 68)
					if pSlotState then
						local licenseType = tonumber(type)
						local licensename = "Documento"

						if licenseType == 1 then
							licensename = "RG"
						elseif licenseType == 2 then
							licensename = "CNH"
						elseif licenseType == 3 then
							licensename = "Porte de arma"
						elseif licenseType == 4 then
							licensename = "Licença de caça"
						elseif licenseType == 6 then
							licensename = "Licença de pesca"
						end

						createLicense(targetPlayer, licenseType)
						outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Entregou "..licensename.." para "..string.gsub(getPlayerName(targetPlayer), "_", " ").."#ffffff.",playerSource,61,122,188,true)
						outputChatBox(core:getServerPrefix("red-dark", "Inventário", 1).."Recebeu "..licensename.." de "..getElementData(playerSource,"user:adminnick").."#ffffff.",targetPlayer,61,122,188,true)

						admin:sendMessageToAdmins(playerSource, "entregou #db3535"..licensename.." #557ec9 para #db3535"..string.gsub(getPlayerName(targetPlayer), "_", " ").."#557ec9.")

						setElementData(playerSource, "log:admincmd", {getElementData(targetPlayer, "char:id"), cmd})
					end
				else
					outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."O jogador alvo não está logado.", playerSource,61,122,188,true)
				end
			end
		else
			outputChatBox(core:getServerPrefix("server", "Uso", 3).." /"..cmd.." [ID] [tipo: 1=RG, 2=CNH, 3=porte, 4=caça, 6=pesca]", playerSource,61,122,188,true)
		end
	end
end

addCommandHandler("givelicense", adminGiveLicense)
addCommandHandler("darlicenca", adminGiveLicense)


func.achangeLock = function(playerSource,cmd,typ,arg)
	if exports["oAdmin"]:hasPermission(playerSource,"changelock") then
		if not exports.oAnticheat:checkPlayerVerifiedAdminStatus(playerSource) then return end -- ellenőrzi, hogy a játékos szerepel e a verified admin listában és ha nem akkor kickeli visszaélés miatt

		local rawTyp = typ and string.lower((tostring(typ):gsub("^%s+", ""):gsub("%s+$", ""))) or ""
		local typAliases =
		{
			["vehicle"] = "vehicle", ["interior"] = "interior",
			["veiculo"] = "vehicle", ["carro"] = "vehicle",
			["imovel"] = "interior",
		}
		typ = typAliases[rawTyp] or rawTyp

		arg = arg and string.lower((tostring(arg):gsub("^%s+", ""):gsub("%s+$", ""))) or ""
		local revokeAllOthers = (arg == "all" or arg == "todos")

		if typ == "vehicle" or typ == "interior" then
			local item = -1
			local value = -1
			if typ == "vehicle" then
				local vehicle = getPedOccupiedVehicle(playerSource);
				if vehicle then
					local dbid = func.getElementID(vehicle)
					if dbid and dbid > 0 then
						item = 51;
						value = tonumber(dbid);
						outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Troca de fechadura (veículo) OK "..color.."("..dbid..")",playerSource,220,20,60,true)
						admin:sendMessageToAdmins(playerSource, "troca de fechadura em veículo. #db3535("..dbid..")")

					else
						outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Não é possível trocar a fechadura: o veículo não tem ID na base (ex.: spawn temporário). Use um veículo persistido (com ID na DB). Comandos: /changelock ou /trocarfechadura.",playerSource,220,20,60,true)
					end
				else
					outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Você não está em um veículo.",playerSource,220,20,60,true)
				end
			elseif typ == "interior" then
				if getElementData(playerSource, "isInIntMarker") then
					local interior = getElementData(playerSource,"int:Marker")
					if getElementData(interior,"isIntMarker") then
						item = 52;
						value = tonumber(getElementData(interior,'dbid'));
						outputChatBox(core:getServerPrefix("green-dark", "Inventário", 3).."Troca de fechadura (interior) OK "..color.."("..value..")", playerSource,220,20,60, true)
						admin:sendMessageToAdmins(playerSource, "troca de fechadura em interior. #db3535("..value..")")

					end
				else
					outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Você não está no marcador de interior.",playerSource,220,20,60,true)
				end
			end
			if item > 0 then
				if revokeAllOthers then
					takeAllItem(item,value)
				end
				giveItem(playerSource,item,value,1,0)
			end
		else
			outputChatBox("Uso:#ffffff /"..cmd.." [tipo: "..color.."vehicle#ffffff | "..color.."veiculo#ffffff | "..color.."interior#ffffff | "..color.."imovel#ffffff] ["..color.."opcional:#ffffff "..color.."all#ffffff | "..color.."todos#ffffff — remover chaves iguais de todos]",playerSource,r, g, b,true)
		end
	else
		if getElementData(playerSource, "user:loggedin") then
			outputChatBox(core:getServerPrefix("red-dark", "Inventário", 3).."Você precisa de nível de administrador ≥ 7 (/changelock ou /trocarfechadura) e serial verificado na tabela adminserials.", playerSource, 220, 20, 60, true)
		end
	end
end
addCommandHandler("changelock",func.achangeLock)
addCommandHandler("trocarfechadura", func.achangeLock)
addCommandHandler("mudarfechadura", func.achangeLock)

function takeDutyItems(playerSource)
	local categories = {
		["bag"] = true,
		["key"] = true,
		["licens"] = true,
	}

	for k,v in pairs(categories) do
		local owner = func.getElementID(playerSource);
		if (itemCache[owner][k]) then
			for i = 1, row * column do
				if itemCache[owner][k][i] and itemCache[owner][k][i].duty == 1 then
					deleteItem(playerSource,itemCache[owner][k][i],true,playerSource);
				elseif itemCache[owner][k][i] and itemCache[owner][k][i].item == 44 then -- pénzkazetták elvétele lelépéskor
					deleteItem(playerSource,itemCache[owner][k][i],true,playerSource);
				end
			end
		end
	end
end

function onLoginDataChange(player)
	local owner = func.getElementID(player);
	triggerClientEvent(player,"setItems",player,player,2,itemCache[owner])
	func.checkBuggedItems(player)
	func.actionbar.getActionbarItems(player,1)

	if itemCache[owner] and (itemCache[owner]["bag"]) then
		for i = 1, row * column do
			if itemCache[owner]["bag"][i] then
				if weaponCache[itemCache[owner]["bag"][i]["item"]] and weaponCache[itemCache[owner]["bag"][i]["item"]].isBack then
					attachWeapon(player,itemCache[owner]["bag"][i]["item"],itemCache[owner]["bag"][i]["id"],itemCache[owner]["bag"][i]["value"])
				end
			end
		end
	end
end 
addEvent("onLoginDataChange", true)
addEventHandler("onLoginDataChange", root, onLoginDataChange)

function attachWeapon(playerSource,item,dbid, value)
	if getElementData(playerSource, "user:aduty") then return end
	if not weapons[playerSource] then
		weapons[playerSource] = {}
	end

	if not value then value = 1 end

	value = value - 1

	if not isElement(weapons[playerSource][dbid]) or not weapons[playerSource][dbid] then
		local x,y,z = getElementPosition(playerSource)
		if weaponCache[item] and weaponCache[item].isBack then
			weapons[playerSource][dbid] = createObject(weaponCache[item].model,x,y,z)
			setElementData(weapons[playerSource][dbid], "weapon:skinid", value)
			setElementAlpha(weapons[playerSource][dbid],getElementAlpha(playerSource))
			setElementInterior(weapons[playerSource][dbid],getElementInterior(playerSource))
			setElementDimension(weapons[playerSource][dbid],getElementDimension(playerSource))
			setElementData(weapons[playerSource][dbid],"attachedObject",true)
			exports.oBone:attachElementToBone(weapons[playerSource][dbid],playerSource,weaponCache[item].position[1],weaponCache[item].position[2],weaponCache[item].position[3],weaponCache[item].position[4],weaponCache[item].position[5],weaponCache[item].position[6],weaponCache[item].position[7])
		end
	end
end
addEvent("attachWeapon",true)
addEventHandler("attachWeapon",getRootElement(),attachWeapon)

function detachWeapon(playerSource,item,dbid)
	if weapons[playerSource] then
		if isElement(weapons[playerSource][dbid]) then
			exports.oBone:detachElementFromBone(weapons[playerSource][dbid])
			destroyElement(weapons[playerSource][dbid])
			weapons[playerSource][dbid] = {}
		end
	end
end
addEvent("detachWeapon",true)
addEventHandler("detachWeapon",getRootElement(), detachWeapon)

--getElementData(thePlayer, "user:aduty")

--[[function checkChange(playerSource, oldValue)
	for k, v in pairs(weapons[playerSource]) do
		detachWeapon(playerSource,item,dbid)
		outputChatBox(k)
    end
end
addCommandHandler ( "checkChange", checkChange )]]

func.quitPlayer = function()
	if getElementData(source,"user:loggedin") then
		takeDutyItems(source)

		local showElement = getElementData(source,"show:inv")
		if isElement(showElement) then
			if getElementType(showElement) == "vehicle" then
				if getElementData(showElement, "veh:use") then
					if getElementData(showElement, "veh:player") == source then
						setElementData(showElement, "veh:player", nil)
						setElementData(showElement, "veh:use", false)
						func.doorState(showElement,0)
					end
				end
			end
			if getElementType(showElement) == "object" then
				if getElementModel(showElement) == 2332 then
					if getElementData(showElement, "safe:use") then
						if getElementData(showElement, "safe:player") == source then
							setElementData(showElement, "safe:player", nil)
							setElementData(showElement, "safe:use", false)
						end
					end
				end
			end
		end

		

	end
end
addEventHandler("onPlayerQuit",getRootElement(), func.quitPlayer)

function quitCheck(theKey, oldValue, newValue)
    if (getElementType(source) == "player") then 
		if theKey == "user:loggedin" then 
			if newValue == false and oldValue == true then 
				sourceSafe = getElementData(source,"player:safe") or false
				if sourceSafe then 
					setElementData(sourceSafe,"safe:use",false)
					setElementData(sourceSafe,"safe:player",nil)
					setElementData(source,"player:safe",false)
				end 

				local owner = func.getElementID(source);
				if not itemCache[owner] then
					itemCache[owner] = {
						["bag"] = {},
						["key"] = {},
						["licens"] = {},
						["vehicle"] = {},
						["object"] = {},
					}
				end
			
				for i = 1, row * column do
					if itemCache[owner]["bag"][i] then
			
						if weapons[source] then
							if isElement(weapons[source][itemCache[owner]["bag"][i]["id"]]) then
								exports.oBone:detachElementFromBone(weapons[source][itemCache[owner]["bag"][i]["id"]])
								destroyElement(weapons[source][itemCache[owner]["bag"][i]["id"]])
							end
						end
			
					end
				end
				weapons[source] = nil;
				
			end 
		end 
    end
end
addEventHandler("onElementDataChange", root, quitCheck)

func.doorState = function(vehicle,typ)
	if typ == 1 then
		setVehicleDoorOpenRatio(vehicle,1,1,1200)
	else
		setVehicleDoorOpenRatio(vehicle,1,0,1200)
	end
end
addEvent("doorState", true)
addEventHandler("doorState", getRootElement(), func.doorState)

func.itemmsgtoadmins = function(playerSource,item,value,count)
	admin:sendMessageToAdmins(playerSource, "deu #db3535"..getItemName(tonumber(item),tostring(value)).." #557ec9 (#db3535"..tonumber(count).."#557ec9×) para #db3535"..string.gsub(getPlayerName(playerSource), "_", " ").."#557ec9.")
end
addEvent("itemmsgtoadmins", true)
addEventHandler("itemmsgtoadmins", getRootElement(), func.itemmsgtoadmins)

addEvent("printerAnim",true)
addEventHandler("printerAnim",getRootElement(),function(player, type, object)
	if type then
		setPedAnimation(player, "shop", "shp_serve_loop", 6000, true, false, false, false)
		triggerClientEvent(getRootElement(), "printerSound",getRootElement(), object)
	else
		setPedAnimation(player)
	end

end)

function deleteAllExisitingItemWithValue(item, value)
	if (availableItems[item].category or "bag"):lower() ~= ("key"):lower() then  
		for k, v in pairs(itemCache) do
			for k2, v2 in pairs(v) do
				for k3, v3 in pairs(v2) do
					if v3.item == item then
						local itemOwner = false
						for key, value in ipairs(getElementsByType("player")) do
							if getElementData(value, "user:id") == k then
								itemOwner = value
								break
							end
						end

						if itemOwner then
							deleteItem(itemOwner, v3, true)
						end
					end
				end
			end
		end

		dbQuery(function(qh)
			local res, rows, err = dbPoll(qh, 0);

			if rows > 0 then
				for k, v in ipairs(res) do
					dbExec(connection, "DELETE FROM `items` WHERE `id` = ?",v["id"])
				end
			end
		end,connection, "SELECT * FROM `items` WHERE itemid='"..item.."' AND value='"..value.."'");
	end
end
addEvent("deleteAllExisitingItemWithValue",true)
addEventHandler("deleteAllExisitingItemWithValue",getRootElement(),deleteAllExisitingItemWithValue)


addCommandHandler("elkoboz", function(thePlayer, cmd, target, seizureType)
	if getElementData(thePlayer, "char:duty:faction") == 1 then 
		if target and seizureType then 
			local t = string.lower(seizureType)
			local target = exports.oCore:getPlayerFromPartialName(thePlayer, target)
			if target then
				local px, py, pz = getElementPosition(thePlayer)
				local tx, ty, tz = getElementPosition(target)
				local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)
				if distance < 1 then
					if t == "fegyver" or t == "arma" then 	
						if hasItem(target, 27) or hasItem(target, 28) or hasItem(target, 29) or hasItem(target, 30) or hasItem(target, 31) or hasItem(target, 32) or hasItem(target, 33) or hasItem(target, 34) or hasItem(target, 35) or hasItem(target, 36) or hasItem(target, 37) or hasItem(target, 38) or hasItem(target, 39) or hasItem(target, 40) or hasItem(target, 41) or hasItem(target, 42) or hasItem(target, 43) then 
							local categories = {
								["bag"] = true,
							}

							local elkobzottszam = 0
							for k,v in pairs(categories) do
								local owner = func.getElementID(target);
								if (itemCache[owner][k]) then
									for i = 1, row * column do
										for ii = 27, 43 do 
											if itemCache[owner][k][i] and itemCache[owner][k][i].item == ii then
												deleteItem(target,itemCache[owner][k][i],true,target);
												elkobzottszam = elkobzottszam+1
											end
										end
									end
								end
							end
							local tgt = getPlayerName(target):gsub("_", " ")
							if elkobzottszam == 1 then 
								exports.oChat:sendLocalMeAction(thePlayer, "apreende um item classificado como arma de "..tgt..".")
							elseif elkobzottszam > 1 then 
								exports.oChat:sendLocalMeAction(thePlayer, "apreende itens classificados como arma de "..tgt..".")
							end
							local qtyLabel = elkobzottszam == 1 and "item classificado como arma" or "itens classificados como arma"
							outputChatBox(core:getServerPrefix("blue-light-2", "Apreensão", 3).."Você apreendeu com sucesso "..color..""..elkobzottszam.." #ffffff"..qtyLabel.." de "..color..tgt.."#ffffff.", thePlayer, 255, 255, 255, true)
							outputChatBox(core:getServerPrefix("blue-light-2", "Apreensão", 3).."Foram apreendidos de você "..color..""..elkobzottszam.." #ffffff"..qtyLabel.." por "..color..getPlayerName(thePlayer):gsub("_", " ").."#ffffff (forças da ordem).", target, 255, 255, 255, true)
						else
							outputChatBox(core:getServerPrefix("red-dark", "Apreensão", 3).."O alvo não possui itens classificados como arma!", thePlayer, 255, 255, 255, true)
						end
					elseif t == "drog" or t == "droga" or t == "drogas" then 
						if hasItem(target, 55) or hasItem(target, 56) or hasItem(target, 57) or hasItem(target, 58) or hasItem(target, 59) or hasItem(target, 60) or hasItem(target, 61) or hasItem(target, 62) or hasItem(target, 63) or hasItem(target, 64) then
							local categories = {
								["bag"] = true,
							}

							local elkobzottszam = 0
							for k,v in pairs(categories) do
								local owner = func.getElementID(target);
								if (itemCache[owner][k]) then
									for i = 1, row * column do
										for ii = 55, 64 do 
											if itemCache[owner][k][i] and itemCache[owner][k][i].item == ii then
												deleteItem(target,itemCache[owner][k][i],true,target);
												elkobzottszam = elkobzottszam+1
											end
										end
									end
								end
							end
							local tgt2 = getPlayerName(target):gsub("_", " ")
							if elkobzottszam == 1 then 
								exports.oChat:sendLocalMeAction(thePlayer, "apreende um produto suspeito de droga de "..tgt2..".")
							elseif elkobzottszam > 1 then 
								exports.oChat:sendLocalMeAction(thePlayer, "apreende produtos suspeitos de droga de "..tgt2..".")
							end
							local qtyLabel2 = elkobzottszam == 1 and "produto suspeito de droga" or "produtos suspeitos de droga"
							outputChatBox(core:getServerPrefix("blue-light-2", "Apreensão", 3).."Você apreendeu com sucesso "..color..""..elkobzottszam.." #ffffff"..qtyLabel2.." de "..color..tgt2.."#ffffff.", thePlayer, 255, 255, 255, true)
							outputChatBox(core:getServerPrefix("blue-light-2", "Apreensão", 3).."Foram apreendidos de você "..color..""..elkobzottszam.." #ffffff"..qtyLabel2.." por "..color..getPlayerName(thePlayer):gsub("_", " ").."#ffffff (forças da ordem).", target, 255, 255, 255, true)
						else
							outputChatBox(core:getServerPrefix("red-dark", "Apreensão", 3).."O alvo não possui itens suspeitos relacionados a drogas!", thePlayer, 255, 255, 255, true)
						end
					end
				else
					outputChatBox(core:getServerPrefix("red-dark", "Apreensão", 3).."Você está longe demais de: "..color..getPlayerName(target):gsub("_", " "), thePlayer, 255, 255, 255, true)
				end
			end
		else 
			outputChatBox(core:getServerPrefix("red-dark", "Apreensão", 3).."Uso: #ffffff/elkoboz [ID] #ffffff[Tipo:#ffffff arma ou droga#ffffff — válido também:#ffffff fegyver, drog]", thePlayer, 255, 255, 255, true)
		end
	end
end)

--- Lista compacta { { id, name }, ... } para painéis admin (ex.: Admin Hub).
function getItemCatalogMini()
	local o = {}
	for id, def in pairs(availableItems) do
		local nid = tonumber(id)
		if nid and def and def.name then
			o[#o + 1] = { nid, def.name }
		end
	end
	table.sort(o, function(a, b) return a[1] < b[1] end)
	return o
end