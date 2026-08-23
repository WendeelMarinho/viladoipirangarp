--[[ oElections — cliente ]]

addCommandHandler("eleicaoajuda", function()
	local p = exports.oCore:getServerPrefix("server", "Eleições", 3)
	outputChatBox(p .. "/eleicao info — estado, candidatos e votos.", 255, 255, 255, true)
	outputChatBox(p .. "/eleicao candidatar | desistir — durante campanha.", 255, 255, 255, true)
	outputChatBox(p .. "/eleicao votar [char_id] — durante votação.", 255, 255, 255, true)
	outputChatBox(p .. "Admin: /eleicao iniciar [horasCampanha] [horasVoto]", 255, 255, 255, true)
end)
