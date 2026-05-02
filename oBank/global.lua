core = exports.oCore
font = exports.oFont
infobox = exports.oInfobox
chat = exports.oChat
color, r, g, b = core:getServerColor()

mainPageTexts = {
    {title = "Bem-vindo!", texts = {
        "Bem-vindo ao banco Vale do Ipiranga RP!",
    }},
}

points = {
    --{"Áttekintés", "bank.png", hasKeyboard?},
    {"Gerenciar contas", "creditcard.png", true, "PIN"},
    {"Transações", "logs.png", true, "VALOR"},
    {"Transferência", "transaction.png", true, "VALOR"},
}

controlPoints = {
    {"Alterar código PIN", ""}, 
    {"Solicitar cartão #72b368(250$)", ""}, 
    {"Definir como conta principal", ""}, 
    {"Encerrar conta", ""},
}

transactionPoints = {
    {"Saque", ""}, 
    {"Depósito", ""},
    {"Limpar \nhistórico", ""},
}
transferPoints = {
    {"Transferir", ""}, 
    {"Limpar \nhistórico", ""},
}

bankPeds = {
    {skin = 147, pos = Vector3(1677.5118408203, -1189.515625, 23.837814331055), rot = 270, name = "Joss Jarvis"}, -- LS
    --{skin = 147, pos = Vector3(1308.7027587891, -1331.2517089844, 13.800000190735), rot = 180, name = "River Patterson"},

    {skin = 187, pos = Vector3(2306.66015625, -1.638267993927, 26.7421875), rot = 280, name = "Hubert Murray"}, -- Palomino

    
}
