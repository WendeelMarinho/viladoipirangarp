--[[ oEvidence — cliente (ajuda rápida) ]]

addCommandHandler("evidencias", function()
	local core = exports.oCore
	local prefix = core:getServerPrefix("server", "Ajuda", 3)
	outputChatBox(prefix .. "/testemunho — relato IC no local (opcional nick de suspeito próximo).", 255, 255, 255, true)
	outputChatBox(prefix .. "/investigar — lista evidências (polícia em serviço).", 255, 255, 255, true)
	outputChatBox(prefix .. "/indiciar [char_id] — reforço wanted organizado (polícia em serviço).", 255, 255, 255, true)
end)
