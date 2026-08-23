--[[ oMedia — cliente ]]

addCommandHandler("midiaajuda", function()
	local p = exports.oCore:getServerPrefix("server", "Mídia", 3)
	outputChatBox(p .. "/publicarnoticia Título -- texto (recebes item Jornal no inventário).", 255, 255, 255, true)
end)
