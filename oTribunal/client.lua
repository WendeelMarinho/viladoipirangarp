--[[ oTribunal — cliente ]]

addCommandHandler("tribunalajuda", function()
	local p = exports.oCore:getServerPrefix("server", "Tribunal", 3)
	outputChatBox(p .. "/tribunal pedir [char_id] — OAB, recluso online e procurado.", 255, 255, 255, true)
	outputChatBox(p .. "Admin: /tribunal lista | /tribunal absolver [id] | /tribunal culpar [id]", 255, 255, 255, true)
end)
