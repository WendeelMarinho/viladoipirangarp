local hints = {
    {"Gostando do servidor? Chame seus amigos para jogar também!"},
    {"Procurando emprego? Visite a prefeitura e veja as vagas disponíveis."},
    {"Atenção: com a vida muito baixa (abaixo de ~10 HP) você pode entrar em animação de ferido."},
    {"Encontrou um bug? Avise pela equipe no Discord ou pelo painel de denúncias do servidor."},
    {"Denúncias sobre outros jogadores podem ser feitas pelo fórum ou Discord oficiais do Vale do Ipiranga RP."},
    {"Novidades e avisos também aparecem no Discord do servidor."},
    {"Leia as regras no fórum e jogue com respeito ao RP."},
    {"Use /id ou /lvl para informações rápidas sobre jogadores próximos."},
}

function printTip()
    if (exports.oDashboard:getDashboardSettingsValue("other", 4) or true) == true then
        outputChatBox(exports.oCore:getServerPrefix("server", "Dica", 3)..hints[math.random(#hints)][1],255,255,255,true)
    end
end
setTimer(printTip, exports.oCore:minToMilisec(15), 0)