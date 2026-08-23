row = 5;
column = 9;
margin = 2;
itemSize = 40;
actionSlots = 6;
actionMargin = 3;
craftSlots = 5;

core = exports.oCore
color, r, g, b = core:getServerColor()
font = exports.oFont
chat = exports.oChat
admin = exports.oAdmin

pages = {
    {
        name = "Itens";
        img = "/files/images/icons/backpack.png";
        miniImg = "/files/images/miniicons/backpack.png";
        page = "bag";
    };
    {
        name = "Chaves";
        img = "/files/images/icons/key.png";
        miniImg = "/files/images/icons/key.png";
        page = "key";
    };
    {
        name = "Documentos";
        img = "/files/images/icons/licens.png";
        miniImg = "/files/images/icons/licens.png";
        page = "licens";
    };

	{
        name = "Cofre";
        img = "/files/images/icons/safe.png";
        miniImg = "/files/images/miniicons/safe.png";
        page = "object";
	};
	{
        name = "Porta-malas";
        img = "/files/images/icons/car.png";
        miniImg = "/files/images/miniicons/car.png";
        page = "vehicle";
    };
};

availableItems = {

	{name = "iPhone 12", weight = 0.3, description = "Telefone Apple.", stacking = false, category="bag", }, -- 1

	-- Comida
	{name = "Batata frita", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 50, objectId = 2663}, -- 2
	{name = "Sanduíche", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 35, objectId = 2663}, -- 3
	{name = "Taco", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 35, objectId = 2663}, -- 4
	{name = "Fatia de pizza", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 30, objectId = 2663}, -- 5
	{name = "Hot-dog", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 35, objectId = 2663}, -- 6
	{name = "Hamburger", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 20, objectId = 2663}, -- 7
	{name = "Maçã", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 50, objectId = 2663}, -- 8
	{name = "Maçã verde", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 50, objectId = 2663}, -- 9
	{name = "Muffin", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 35, objectId = 2663}, -- 10
	{name = "Banana", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 50, objectId = 2663}, -- 11
	{name = "Uva", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 50, objectId = 2663}, -- 12
	{name = "Melancia", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 50, objectId = 2663}, -- 12
	{name = "Chocolate", weight = 0.01, stacking = true, category="bag", eat = true, eatPercent = 50, objectId = 2663}, -- 14
	{name = "Chips", weight = 0.05, stacking = true, category="bag", eat = true, eatPercent = 50, objectId = 2663}, -- 15
	{name = "Salada", weight = 0.06, stacking = true, category="bag", eat = true, eatPercent = 20, objectId = 2663}, -- 16
	{name = "Durum", weight = 0.04, stacking = true, category="bag", eat = true, eatPercent = 25, objectId = 2663}, -- 17
	{name = "Gyro", weight = 0.05, stacking = true, category="bag", eat = true, eatPercent = 20, objectId = 2663}, -- 18

	-- Bebidas
	{name = "Sprite", weight = 0.02, stacking = true, category="bag", drinkPercent = 25, drink = true}, -- 19
	{name = "Fanta", weight = 0.02, stacking = true, category="bag", drinkPercent = 25, drink = true}, -- 20
	{name = "Coca Cola", weight = 0.02, stacking = true, category="bag", drinkPercent = 25, drink = true}, -- 21
	{name = "Água sem gás", weight = 0.04, stacking = true, category="bag", drinkPercent = 20, drink = true}, -- 22
	{name = "Mountain Dew", weight = 0.025, stacking = true, category="bag", drinkPercent = 25, drink = true}, -- 23
	{name = "Cerveja", weight = 0.04, stacking = true, category="bag", alcohol = true}, -- 24
	{name = "Vinho", weight = 0.04, stacking = true, category="bag", alcohol = true}, -- 25
	{name = "Café", weight = 0.03, stacking = true, category="bag", drinkPercent = 50, drink = true}, -- 26

	-- Armas
	{name = "AK-47", weight = 4.8,  isWeapon = true, ammo = 45, stacking = false, category="bag"}, -- 27
	{name = "M4", weight = 3.13,  isWeapon = true, ammo = 45, stacking = false, category="bag"}, -- 28
	{name = "Katana", weight = 6,  isWeapon = true, stacking = false, category="bag"}, -- 29
	{name = "Desert Eagle", weight = 1.99,  isWeapon = true, ammo = 47, stacking = false, category="bag"}, -- 30
	{name = "Taco de baseball", weight = 2,  isWeapon = true, stacking = false, category="bag"}, -- 31
	{name = "Faca", weight = 1,  isWeapon = true, stacking = false, category="bag"}, -- 32
	{name = "Cacetete", weight = 1,  isWeapon = true, stacking = false, category="bag"}, -- 33
	{name = "Espingarda", weight = 5,  isWeapon = true, ammo = 46, stacking = false, category="bag"}, -- 34
	{name = "Espingarda de cano serrado", weight = 4.5,  isWeapon = true, ammo = 46, stacking = false, category="bag"}, -- 35
	{name = "Spray", weight = 0.001,  isWeapon = true, ammo = 50, stacking = false, category="bag"}, -- 36
	{name = "Colt-45", weight = 1.13,  isWeapon = true, ammo = 47, stacking = false, category="bag"}, -- 37
	{name = "Rifle de precisão", weight = 8,  isWeapon = true, ammo = 49, stacking = false, category="bag"}, -- 38
	{name = "P90", weight = 3,  isWeapon = true, ammo = 48, stacking = false, category="bag"}, -- 39
	{name = "UZI", weight = 3.5,  isWeapon = true, ammo = 48, stacking = false, category="bag"}, -- 40
	{name = "Tazer", weight = 1.6,  isWeapon = true, stacking = false, category="bag"}, -- 41
	{name = "Tec 9", weight = 3.5,  isWeapon = true, ammo = 48, stacking = false, category="bag"}, -- 42
	{name = "Boxer", weight = 3.5,  isWeapon = true, stacking = false, category="bag"}, -- 43

	{name = "Maleta de dinheiro", weight = 4, stacking = false, category="bag"}, -- 44

	-- Munições
	{name = "Munição grosso calibre", weight = 0.002, stacking = true, category="bag"}, -- 45
	{name = "Munição de espingarda", weight = 0.003, stacking = true, category="bag"}, -- 46
	{name = "Munição pequeno calibre", weight = 0.002, stacking = true, category="bag"}, -- 47
	{name = "Munição 5x9 mm", weight = 0.001, stacking = true, category="bag"}, -- 48
	{name = "Munição de rifle de caça", weight = 0.005, stacking = true, category="bag"}, -- 49
	{name = "Cartucho de spray", weight = 0.003, stacking = true, category="bag"}, -- 50

	-- Chaves
	{name = "Chave do veículo", weight = 0, stacking = false, category="key"}, -- 51
	{name = "Chave de imóvel", weight = 0, stacking = false, category="key"}, -- 52
	{name = "Controle remoto de portão", weight = 0, stacking = false, category="key"}, -- 53
	{name = "Chave de cofre", weight = 0, stacking = false, category="key"}, -- 54

	-- Drogas (uso sujeito a regras RP / staff)
	{name = "Baseado", weight = 0.001, stacking = true, category="bag"}, -- 55
	{name = "Seringa de heroína", weight = 0.004, stacking = true, category="bag"}, -- 56
	{name = "Cocaína", weight = 0.001, stacking = true, category="bag"}, -- 57
	{name = "Maconha seca", weight = 0.001, stacking = true, category="bag"}, -- 58
	{name = "Semente de maconha", weight = 0.001, stacking = true, category="bag"}, -- 59
	{name = "Semente de cocaína", weight = 0.001, stacking = true, category="bag"}, -- 60
	{name = "Papoula", weight = 0.001, stacking = true, category="bag"}, -- 61
	{name = "Folha de coca", weight = 0.001, stacking = true, category="bag"}, -- 62
	{name = "Folha de maconha", weight = 0.001, stacking = true, category="bag"}, -- 63
	{name = "Heroína em pó", weight = 0.001, stacking = true, category="bag"}, -- 64

	-- Iratok
	{name = "RG (identidade)", weight = 0, stacking = false, category="licens"}, -- 65
	{name = "CNH", weight = 0, stacking = false, category="licens"}, -- 66
	{name = "Esmerilhadeira", weight = 2, stacking = false, category="bag"}, -- 67
	{name = "Porte de arma", weight = 0, stacking = false, category="licens"}, -- 68
	{name = "Distintivo", weight = 0, stacking = false, category="licens"}, -- 69

	{name = "Furadeira", weight = 7, description = "Para furar cofres...", stacking = false, category="bag"}, -- 70

	-- Egyéb
	{name = "Cigarro", weight = 0.001, stacking = false, category="bag"}, -- 71
	{name = "Isqueiro", weight = 0.008, stacking = false, category="bag"}, -- 72
	{name = "Hifi", weight = 2.3, stacking = false, category="bag"}, -- 73
	{name = "Vara de pesca", weight = 1.6, stacking = false, category="bag"}, -- 74
	{name = "Cofre portátil", weight = 5, stacking = false, category="bag"}, -- 75
	{name = "Remédio", weight = 0.02, stacking = true, category="bag"}, -- 76
	{name = "Algemas", weight = 0.003, stacking = false, category="bag"}, -- 77
	{name = "Chave de algemas", weight = 0.001, stacking = false, category="bag"}, -- 78

	{name = "Licença de caça", weight = 0, stacking = false, category="licens"}, -- 79

	{name = "Triturador", weight = 0.06, stacking = true, category="bag"}, -- 80
	{name = "Kit de primeiros socorros", weight = 0.6, stacking = true, category="bag", object = 1240}, -- 81
	{name = "Cartão para desvirar veículo", weight = 0, stacking = true, category="bag"}, -- 82
	{name = "Giroflex policial", weight = 1, stacking = false, category="bag"}, -- 83
	{name = "Soprador térmico", weight = 0.5, stacking = false, category="bag"}, -- 84
	{name = "Caneta", weight = 0.1, stacking = false, category="bag"}, -- 85
	{name = "Seringa", weight = 0, stacking = true, category="bag"}, -- 86
	{name = "Bicarbonato de sódio", weight = 0.001, stacking = true, category="bag"}, -- 87
	{name = "Papel de seda para cigarro", weight = 0, stacking = true, category="bag"}, -- 88
	{name = "Cartão de cura instantânea", weight = 0, stacking = true, category="bag"}, -- 89
	{name = "Cartão de conserto instantâneo", weight = 0, stacking = true, category="bag"}, -- 90
	{name = "Cartão de abastecimento instantâneo", weight = 0, stacking = true, category="bag"}, -- 91

	--pet kellékek
	{name = "Kit veterinário para cão", weight = 0.8, stacking = true, category="bag"}, -- 92
	{name = "Bebedouro portátil", weight = 1, stacking = true, category="bag"}, -- 93
	{name = "Ração premium para cão", weight = 1, stacking = true, category="bag"}, -- 94
	{name = "Ração vegana para cão", weight = 0.6, stacking = true, category="bag"}, -- 95
	{name = "Ração com carne bovina para cão", weight = 0.3, stacking = true, category="bag"}, -- 96
	{name = "Ração com carne suína para cão", weight = 0.3, stacking = true, category="bag"}, -- 97
	{name = "Ração com frango para cão", weight = 0.8, stacking = true, category="bag"}, -- 98
	--

	--v2 drog
	{name = "Semente de papoula", weight = 0.001, stacking = true, category="bag"}, -- 99
	{name = "Semente de cogumelo mágico", weight = 0.001, stacking = true, category="bag"}, -- 100
	{name = "Cogumelo mágico", weight = 0.001, stacking = true, category="bag"}, -- 101
	{name = "Pá para plantio", weight = 1.2, stacking = true, category="bag"}, -- 102
	{name = "Terra vegetal", weight = 0.001, stacking = true, category="bag"}, -- 103
	{name = "Terra vegetal premium", weight = 0, stacking = true, category="bag"}, -- 104
	{name = "Tesoura de colheita", weight = 1.4, stacking = true, category="bag"}, -- 105
	{name = "LSD", weight = 0.001, stacking = true, category="bag"}, -- 106
	{name = "Cocaína embalada", weight = 0.001, stacking = true, category="bag"}, -- 107
	{name = "Seringa de heroína embalada", weight = 0.001, stacking = true, category="bag"}, -- 108
	{name = "Baseado embalado", weight = 0.001, stacking = true, category="bag"}, -- 109

	--Rendőrségi dolgok
	{name = "Escudo balístico (PM)", weight = 4.5, stacking = false, category="bag"}, -- 110
	{name = "Aríete (battering ram)", weight = 2, stacking = false, category="bag"}, -- 111

	-- Dobozos cigik
	{name = "Natural American Spirit", weight = 0.2, stacking = false, category="bag"}, -- 112
	{name = "Newport", weight = 0.2, stacking = false, category="bag"}, -- 113
	{name = "Pall Mall", weight = 0.2, stacking = false, category="bag"}, -- 114

	{name = "Cartão Protect veículo (premium)", weight = 0, description = "Item premium", stacking = true, category="bag"}, -- 115

	{name = "Pr", weight = 0, description = "Item premium", stacking = true, category="bag"}, -- 116

	-- Mesterkönyvek
	{name = "Manual AK-47",skillid = 77, weight = 0, stacking = false, category="bag"}, -- 116
	{name = "Manual M4",skillid = 78, weight = 0, stacking = false, category="bag"}, -- 117
	{name = "Manual UZI e Tec-9",skillid = 75, weight = 0, stacking = false, category="bag"}, -- 118
	{name = "Manual P90",skillid = 76, weight = 0, stacking = false, category="bag"}, -- 119
	{name = "Manual espingarda",skillid = 72, weight = 0, stacking = false, category="bag"}, -- 120
	{name = "Manual espingarda cano serrado",skillid = 73, weight = 0, stacking = false, category="bag"}, -- 121
	{name = "Manual Colt-45",skillid = 69, weight = 0, stacking = false, category="bag"}, -- 122
	{name = "Manual Colt-45 silenciado",skillid = 70, weight = 0, stacking = false, category="bag"}, -- 123
	{name = "Manual Desert Eagle",skillid = 71, weight = 0, stacking = false, category="bag"}, -- 124
	{name = "Manual rifle de precisão",skillid = 79, weight = 0, stacking = false, category="bag"}, -- 125

	-- Halak
	{name = "Carpa", weight = 1, stacking = true, category="bag"}, -- 127
	{name = "Bagre", weight = 1.2, stacking = true, category="bag"}, -- 128
	{name = "Perca", weight = 1, description = "Peixe de água doce.", stacking = true, category="bag"}, -- 129
	{name = "Salmão", weight = 1.5, description = "Peixe de água salgada.", stacking = true, category="bag"}, -- 130
	{name = "Amur", weight = 1.3, description = "Peixe de água doce.", stacking = true, category="bag"}, -- 131
	{name = "Enguia", weight = 2.1, description = "Peixe de água doce.", stacking = true, category="bag"}, -- 132
	{name = "Bagre-anão", weight = 0.75, description = "Peixe de água doce.", stacking = true, category="bag"}, -- 133
	{name = "Peixe-zebra", weight = 0.5, description = "Peixe de água doce.", stacking = true, category="bag"}, -- 134
	{name = "Sapo", weight = 0.25, description = "Animal.", stacking = true, category="bag"}, -- 135

	--Szemét
	{name = "Lata de conserve enferrujada", weight = 0.4, description = "Lixo pescado da água.", stacking = true, category="bag"}, -- 136
	{name = "Balde furado", weight = 1.3, description = "Lixo pescado da água.", stacking = true, category="bag"}, -- 137
	{name = "Madeira flutuante", weight = 0.8, description = "Lixo pescado da água.", stacking = true, category="bag"}, -- 138
	{name = "Lodo / aguape", weight = 0.2, description = "Lixo pescado da água.", stacking = true, category="bag"}, -- 139

	--Egyéb
	{name = "Terra esgotada", weight = 0.2, description = "Areia cinza-argilosa...", stacking = true, category="bag"}, -- 140
	{name = "Saco plástico", weight = 0.02, description = "Útil para... alguma coisa.", stacking = false, category="bag"}, -- 141

	{name = "Ametista", weight = 0, description = "Pedra preciosa", stacking = false, category="bag"}, -- 142
	{name = "Apatita", weight = 0, description = "Pedra preciosa", stacking = false, category="bag"}, -- 143
	{name = "Pano de limpeza", weight = 0, description = "Para quando estiver sujo!", stacking = false, category="bag"}, -- 144
	{name = "Produto de limpeza", weight = 0, description = "Spray de limpeza.", stacking = false, category="bag"}, -- 145

	{name = "Licença de pesca", weight = 0, description = "Documento obrigatório para pescar.", stacking = false, category="licens"}, -- 146
	{name = "Isca", weight = 0.025, description = "Isca.", stacking = true, category="bag"}, -- 147
	{name = "Isca especial", weight = 0.05, description = "Isca com outras propriedades.", stacking = true, category="bag"}, -- 148
	{name = "Bilhete / anotação", weight = 0, description = "Contém pedidos anotados.", stacking = false, category="licens"}, -- 149

	{name = "Vitamina", weight = 0.025, description = "Vitamina.", stacking = true, category="bag"}, -- 150
	{name = "Colete à prova de balas", weight = 4.5, description = "Útil para forças de segurança...", stacking = false, category="bag"}, -- 151
	{name = "Câmera", weight = 1, description = "Câmera fotográfica.", isWeapon = true, stacking = false, category="bag"}, -- 152
	{name = "Multa", weight = 0.001, description = "Você estava rápido demais.", stacking = false, category="licens"}, -- 153
	{name = "Rádio", weight = 0.25, description = "Equipamento eletrônico importante.", stacking = false, category="bag"}, -- 154
	{name = "Cartão bancário", weight = 0.001, description = "Cartão do banco.", stacking = false, category="licens"}, -- 155

	{name = "Cogumelo porcini", weight = 0.1, description = "Cogumelo.", stacking = true, category="bag"}, -- 156
	{name = "Cogumelo venenoso", weight = 0.2, description = "Cogumelo.", stacking = true, category="bag"}, -- 157
	{name = "Champignon", weight = 0.25, description = "Cogumelo.", stacking = true, category="bag"}, -- 158
	{name = "Puffball", weight = 0.15, description = "Cogumelo.", stacking = true, category="bag"}, -- 159
	{name = "Cogumelo pé-de-cordeiro", weight = 0.35, description = "Cogumelo.", stacking = true, category="bag"}, -- 160

	{name = "Motosserra", weight = 5, description = "Indispensável para cortar árvores.", isWeapon = true, stacking = false, category="bag"}, -- 161
	{name = "Extintor", weight = 3, description = "Indispensável para combater incêndios.", isWeapon = true, stacking = false, category="bag"}, -- 162

	{name = "Parafusadeira", weight = 2, description = "Ferramenta essencial para o DIY.", stacking = false, category="bag"}, -- 163
	{name = "Pé-de-cabra", weight = 3, description = "Serve para várias coisas...", stacking = false, category="bag"}, -- 164

	-- Vadászat
	{name = "Cabeça de urso", weight = 5, stacking = true, category = "bag"}, -- 165
	{name = "Cabeça de raposa", weight = 3.75, stacking = true, category = "bag"}, -- 166
	{name = "Pele de urso", weight = 1.25, stacking = true, category = "bag"}, -- 166
	{name = "Pele de raposa", weight = 1, stacking = true, category = "bag"}, -- 168

	-- Bankrablás
	{name = "Gazua", weight = 0.1, stacking = false, category = "bag"}, -- 169
	{name = "Serra", weight = 3.5, stacking = false, category = "bag"}, -- 170

	{name = "Vaso para plantas", weight = 2, stacking = false, category = "bag"}, -- 171
	{name = "Regador cheio", weight = 4, stacking = false, category = "bag"}, -- 172

	{name = "Matéria-prima droga — laranja", weight = 0.025, stacking = true, category = "bag"}, -- 173
	{name = "Matéria-prima droga — amarela", weight = 0.025, stacking = true, category = "bag"}, -- 174
	{name = "Matéria-prima droga — roxa", weight = 0.025, stacking = true, category = "bag"}, -- 175
	{name = "Matéria-prima droga — azul", weight = 0.025, stacking = true, category = "bag"}, -- 176
	{name = "Matéria-prima droga — verde", weight = 0.025, stacking = true, category = "bag"}, -- 177

	{name = "C4", weight = 3.25, stacking = false, category = "bag"}, -- 178

	-- Szerencsejáték
	{name = "Dado", weight = 0.02, stacking = false, category = "bag"}, -- 179
	{name = "Baralho", weight = 0.03, stacking = false, category = "bag"}, -- 180
	{name = "Moeda", weight = 0.01, stacking = false, category = "bag"}, -- 181

	--Bankrob
	{name = "Alicate", weight = 0.5, stacking = false, category = "bag"}, -- 182

	-- Üzemanyag
	{name = "Galão de diesel", weight = 4, stacking = false, category = "bag"}, -- 183
	{name = "Galão de gasolina", weight = 4, stacking = false, category = "bag"}, -- 184

	-- Kincskeresés
	{name = "Vaso antigo", weight = 1.2, stacking = false, category = "bag"}, -- 185
	{name = "Vaso antigo ornamental", weight = 1.5, stacking = false, category = "bag"}, -- 186
	{name = "Vaso quebrado", weight = 0.5, stacking = false, category = "bag"}, -- 187
	{name = "Castiçal antigo", weight = 0.7, stacking = false, category = "bag"}, -- 188
	{name = "Garrafa com mensagem: 'Preciso de ajuda...'", weight = 0.8, stacking = false, category = "bag"}, -- 189
	{name = "Garrafa com mensagem: 'A ilha perdida...'", weight = 0.8, stacking = false, category = "bag"}, -- 190
	{name = "Garrafa com mensagem: 'O tesouro de Los Santos...'", weight = 0.8, stacking = false, category = "bag"}, -- 191
	{name = "Mapa do tesouro", weight = 0.1, stacking = false, category = "bag"}, -- 192
	{name = "Areia", weight = 0.25, stacking = true, category = "bag"}, -- 193
	{name = "Cascalho", weight = 0.35, stacking = true, category = "bag"}, -- 194

	{name = "Rubin", weight = 0, stacking = false, category = "bag"}, -- 195
	{name = "Smaragd", weight = 0, stacking = false, category = "bag"}, -- 196
	{name = "Zafír", weight = 0, stacking = false, category = "bag"}, -- 197
	{name = "Âmbar (pedra)", weight = 0, stacking = false, category = "bag"}, -- 198

	{name = "Luminária de táxi", weight = 0.3, stacking = false, category = "bag"}, -- 199
	{name = "Baú do tesouro", weight = 0, description = "O que será que tem dentro?", stacking = false, category = "bag"}, -- 200

	--
	{name = "Plástico", weight = 0.25, stacking = true, category = "bag"}, -- 201
	{name = "Madeira (recurso)", weight = 0.35, stacking = true, category = "bag"}, -- 202
	{name = "Ferro (material)", weight = 0.5, stacking = true, category = "bag"}, -- 203

	{name = "Colônia", weight = 0.1, stacking = false, category = "bag"}, -- 204
	{name = "Ovo de Páscoa", weight = 0, stacking = false, category = "bag"}, -- 205

	{name = "Documento do veículo (CRLV)", weight = 0, stacking = false, category = "licens"}, -- 206
	{name = "CRLV — formulário de solicitação", weight = 0, stacking = false, category = "licens"}, -- 207
	{name = "OBD Scanner", weight = 0.4, stacking = false, category = "bag"}, -- 208

	{name = "Documento fotocopiado", weight = 0, stacking = false, category = "licens"}, -- 209
	{name = "Escudo balístico (PM)", weight = 5, stacking = false, category = "bag"}, -- 210
	{name = "Peça de arma", weight = 0.3, stacking = true, category = "bag"}, -- 211

	{name = "Whisky", weight = 0.3, stacking = true, category = "bag"}, -- 212
	{name = "Jim Beam", weight = 0.3, stacking = true, category = "bag"}, -- 213
	{name = "Absinth", weight = 0.3, stacking = true, category = "bag"}, -- 214
	{name = "Corona extra", weight = 0.3, stacking = true, category = "bag"}, -- 215
	{name = "Heineken", weight = 0.3, stacking = true, category = "bag"}, -- 216
	{name = "Bafômetro / tubo para teste", weight = 0.14, stacking = false, category = "bag"}, -- 217

	{name = "Chocolate (maconha)", weight = 0.001, stacking = true, category = "bag"}, -- 218
	{name = "Muffin (maconha)", weight = 0.001, stacking = true, category = "bag"}, -- 219
	{name = "Pacote de maconha", weight = 0.1, stacking = true, category = "bag"}, -- 220
	{name = "Óleo de maconha", weight = 0.1, stacking = true, category = "bag"}, -- 221
	{name = "Cola", weight = 0.14, stacking = false, category = "bag"}, -- 222

	{name = "Regador vazio", weight = 4, stacking = false, category = "bag"}, -- 223
	{name = "ITEM VAZIO", weight = 0.1, stacking = false, category = "licens"}, -- 224

	{name = "Guarda-chuva (azul)", weight = 0.1, stacking = false, category = "bag"}, -- 225

	{name = "Talão de multas (Polícia Civil SP)", weight = 0, stacking = false, category="licens"}, -- 226
	{name = "Talão guias hospitalares (SAMU 192)", weight = 0, stacking = false, category="licens"}, -- 227
	{name = "Multa aplicada na hora", weight = 0, stacking = false, category="licens"}, -- 228
	{name = "Atendimento médico (recibo)", weight = 0, stacking = false, category="licens"}, -- 229

	{name = "Camisa autografada (branco-vermelho)", weight = 0.1, stacking = false, category="bag"}, -- 230
	{name = "Camisa autografada (vermelha)", weight = 0.1, stacking = false, category="bag"}, -- 231
	{name = "Camisa autografada (branco-azul)", weight = 0.1, stacking = false, category="bag"}, -- 232
	{name = "Camisa autografada (laranja)", weight = 0.1, stacking = false, category="bag"}, -- 233

	{name = "Chave do veículo #808080(cópia)", weight = 0, stacking = false, category="key"}, -- 234
	{name = "Chave de imóvel #808080(cópia)", weight = 0, stacking = false, category="key"}, -- 235

	{name = "Troca de fechadura (veículo)", weight = 0.01, stacking = false, category="bag"}, -- 236
	{name = "Fechadura nova (imóvel)", weight = 0.01, stacking = false, category="bag"}, -- 237

	{name = "Bolsa de sangue", weight = 0.01, stacking = true, category="bag"}, -- 238
	{name = "Óleo", weight = 2, stacking = true, category="bag"}, -- 239
	{name = "Óculos táticos", weight = 0.5, stacking = false, category="bag"}, -- 240

	{name = "Bilhete de loteria", weight = 0, stacking = false, category="licens"}, -- 241
  	{name = "Flashbang", weight = 0.5,isWeapon = true, stacking = true, category="bag"}, -- 242

	{name = "Bengala", weight = 0.5, stacking = false, category="bag"}, -- 243
	{name = "Foguete demônio", weight = 0.5, stacking = false, category="bag"}, -- 244
	{name = "Meteoro (fogo de artifício)", weight = 0.5, stacking = false, category="bag"}, -- 245
	{name = "Roda de fogos", weight = 0.5, stacking = false, category="bag"}, -- 246
	{name = "Mesa de fogos / conjunto bomba", weight = 0.5, stacking = false, category="bag"}, -- 247

	{name = "Rastreador GPS (veículo)", weight = 0.15, description = "Instala no teu veículo para localização após furto.", stacking = true, category="bag"}, -- 248
	{name = "Detector de rastreador", weight = 0.12, description = "Remove um GPS instalado dentro de um carro roubado.", stacking = true, category="bag"}, -- 249

	{name = "Jornal IC (edição)", weight = 0.08, description = "Edição impressa com artigo IC (valor = JSON).", stacking = false, category="bag"}, -- 250
};


giftDrop = {
	[75] = {
		{id = 2},
		{id = 3},
		{id = 5},
		{id = 8},
		{id = 9},
		{id = 13},
		{id = 15},
		{id = 17},
		{id = 23},
		{id = 25},
		{id = 76},
		{id = 150},
	},
	--töltények
	[15] = {
		{id = 45, maxcount = 120},
		{id = 46, maxcount = 120},
		{id = 47, maxcount = 120},
		{id = 48, maxcount = 120},
		{id = 49, maxcount = 120},
	},
	--fegyverek
	[1] = {
		{id = 27},
		{id = 28},
		{id = 29},
		{id = 30},
		{id = 31},
		{id = 34},
		{id = 35},
		{id = 37},
		{id = 38},
		{id = 39},
		{id = 40},
		{id = 42},
		{id = 31},
		{id = 34},
		{id = 35},
		{id = 37},
		{id = 38},
	},
	-- Mesterkönyvek
	[25] = {
		{id = 117},
		{id = 118},
		{id = 119},
		{id = 120},
		{id = 121},
		{id = 122},
		{id = 123},
		{id = 125},
	},
	--pps és egyéb
	[5] = {
		{id = 178},
		{id = 115},
		{id = 70},
		{id = 89},
		{id = 90},
		{id = 91},
		{id = 82},
		{id = 70},
		{id = 75},
	},
	--drokok
	[10] = {
		{id = 55},
		{id = 56},
		{id = 57},
	}
}

randomTable = {75};


--Uzi,Tec,Vadászpuska,Molotov,Kés
availableCraft = {
	[21] = {--ak47 amit kapsz
		--{item,slot,darab}
		{55,7,1}; -- Cső és előágy
		{56,8,1}; -- Elsütő szerkezet
		{57,13,1}; -- Ravasz és markolat
		{58,18,1}; -- Tár
		{59,9,1}; -- Tus
	};
	--m4
	[23] = {
		{63,8,1}; -- felső rész
		{60,12,1}; -- cső
		{61,13,1}; -- előágy
		{62,14,1}; -- elsütő
		{67,15,1}; -- tus
		{66,18,1}; -- tár
		{65,19,1}; -- ravasz
		{64,24,1}; -- markolat
	};
	[26] = { --colt45
		{69,8,1}; -- felső rész
		{68,12,1}; -- alsó rész
		{71,13,1}; -- ravasz
		{70,14,1}; -- markolat
		{72,19,1}; -- tár
	};
	[28] = { --shoti
		{73,11,1}; -- Tus
		{74,12,1}; -- Markolat
		{75,13,1}; -- Elsütő
		{77,14,1}; -- Pumpáló
		{78,15,1}; -- Cső
		{76,18,1}; -- Ravasz
	};
	[30] = { --sawed off
		{82,9,1}; -- Cső
		{79,12,1}; -- Markolat
		{81,13,1}; -- Elsütő
		{80,18,1}; -- Ravasz
		{83,19,1}; -- Tok
	};
	[49] = { --kés
		{84,7,1}; -- Penge
		{85,13,1}; -- Markolat
	};
	[40] = { --molotov
		{86,8,1}; -- Rongy
		{87,13,1}; -- Whiskey
	};
	[36] = { --vadász
		{88,12,1}; -- Tus
		{89,13,1}; -- Elsütő
		{90,18,1}; -- Ravasz
		{91,14,1}; -- Tok
		{92,15,1}; -- Cső
	};
	[33] = { --tec9
		{94,9,1}; -- Elsütő
		{93,11,1}; -- cső
		{96,12,1}; -- előágy
		{95,13,1}; -- alsó rész
		{98,14,1}; -- markolat és ravasz
		{97,18,1}; -- tár
	};
	[32] = { --tec9
		{101,7,1}; -- Felső rész
		{100,8,1}; -- Elsütő
		{99,9,1}; -- cső
		{102,12,1}; -- markolat
		{103,13,1}; -- ravasz
		{104,17,1}; -- tár
	};
}

weaponCache = {

	[33] = {
		isBack = true,
		hotTable = false,
		model = 334,
		position = {13, -0.05, -0.07, 0.2, 0, 0, 90},
		weapon = 3,
		ammo = -1,
	}, -- Gumibot
	[32] = {
		isBack = true,
		hotTable = false,
		model = 335,
		position = {14, 0.1, -0.07, 0.1, 0, 0, 90},
		weapon = 4,
		ammo = -1,
	}, -- Kés

	[31] = {
		isBack = true,
		model = 336,
		position = {6, -0.1, -0.1, 0.2, 10, 260, 95},
		hotTable = false,
		weapon = 5,
		ammo = -1,
	}, -- Basketball

	[161] = {
		isBack = false,
		hotTable = false,
		weapon = 9,
		ammo = -1,
	}, -- Láncfűrész

	[27] = {
		isBack = true,
		hotTable = 8,
		model = 355,
		position = {6, -0.09, -0.1, 0.2, 10, 155, 95},
		weapon = 30,
		ammo = 45,
	}, -- AK-47

	[28] = {
		isBack = true,
		hotTable = 6,
		model = 356,
		position = {5, 0.15, -0.1, 0.2, -10, 155, 90},
		weapon = 31,
		ammo = 45,
	}, -- M4

	[37] = {
		isBack = false,
		hotTable = 16,
		weapon = 22,
		ammo = 47,
	}, -- Colt-45

	[30] = {
		isBack = true,
		hotTable = 16,
		weapon = 24,
		model = 348,
		position = {14, 0.08, 0, 0.1, 0, 270, 90},
		ammo = 47,
	}, -- Desert Eagle

	[41] = {
		isBack = true,
		hotTable = false,

		model = 347,
		position = {13, -0.06, 0, 0.1, 0, 270, 90},

		weapon = 23,
		ammo = -1,
	}, -- Sokkoló

	[34] = {
		isBack = true,
		hotTable = 40,
		model = 349,
		position = {5, 0.15, -0.1, 0.2, 0, 155, 90},
		weapon = 25,
		ammo = 46,
	}, -- Sörétes puska

	[35] = {
		isBack = true,
		hotTable = 38,
		model = 350,
		position = {5, 0.15, 0.06, 0.2, 0, 172, 90},
		weapon = 26,
		ammo = 46,
	}, -- Rövid csövű sörétes puska

	[29] = { -- ?
		isBack = true,
		hotTable = false,
		model = 339,
		position = {6, -0.1, 0.1, 0.05, 10, -110, 95},
		weapon = 8,
		ammo = -1,
	}, -- Katana

	[40] = {
		isBack = false,
		hotTable = 7,
		weapon = 28,
		ammo = 48,
	}, -- Uzi

	[39] = {
		isBack = true,
		hotTable = 6,
		model = 353,
		position = {13, -0.07, 0.04, 0.06, 0, -90, 95},
		weapon = 29,
		ammo = 48,
	}, -- p90

	[42] = {
		isBack = false,
		hotTable = 6,
		weapon = 32,
		ammo = 48,
	}, -- TEC-9

	[36] = { -- ?
		isBack = false,
		hotTable = false,
		weapon = 41,
		ammo = 50,
	}, -- Spray

	[38] = {
		isBack = true,
		hotTable = 42,
		model = 358,
		position = {5, 0.15, -0.1, 0.2, -10, 155, 90},
		weapon = 34,
		ammo = 49,
	}, -- Mesterlövész
	[162] = {
		isBack = false,
		notAnim = true,
		hotTable = false,
		weapon = 42,
		ammo = -1,
	}, -- Poroltó
	[152] = {
		isBack = false,
		notAnim = true,
		hotTable = false,
		weapon = 43,
		ammo = -1,
	}, -- Kamera
	[43] = {
		isBack = false,
		notAnim = true,
		hotTable = false,
		weapon = 1,
		ammo = -1,
	}, -- Boxer
  [242] = {
    isBack = false,
    notAnim = true,
    hotTable = false,
    weapon = 16,
    ammo = -1,
  }, -- Flashbang (ALAPJÁRATON GRENADE)
};
identityItems = {};

customItemNamesByValue = {
	[27] = { -- AK
		[2] = "Winter AK-47",
		[3] = "Camo AK-47",
		[4] = "Digit AK-47",
		[5] = "Gold AK-47",
		[6] = "Gilded AK-47",
		[7] = "Hello Kitty AK-47",
		[8] = "Silver AK-47",
	},

	[28] = { -- M4
		[2] = "Camo M4",
		[3] = "Winter M4",
		[4] = "Bloody M4",
		[5] = "Gold M4",
		[6] = "Winter Light M4",
		[7] = "Hello Kitty M4",
		[8] = "Bronze M4",
		[9] = "Silver M4",
	},

	[30] = { -- Deagle
		[2] = "Camo Desert Eagle",
		[3] = "Gold Desert Eagle",
		[4] = "Hello Kitty Desert Eagle",
	},

	[32] = { -- Kés
		[2] = "Camo Knife",
		[3] = "Rust Knife",
		[4] = "Carbon Knife",
		[5] = "Tiger Knife",
		[6] = "Digit Knife",
		[7] = "Spider Knife",
	},

	[38] = { -- Sniper
		[2] = "Winter Camo Sniper",
		[3] = "Camo Sniper",
	},

	[39] = { -- P90
		[2] = "Camo P90",
		[3] = "Winter Camo P90",
		[4] = "Black P90",
		[5] = "Gold Flow P90",
		[6] = "No Limit P90",
		[7] = "Oni P90",
		[8] = "Carbon P90",
		[9] = "Wood P90",
		[10] = "Halloween P90",
	},

	[40] = { -- UZI
		[2] = "Bronze UZI",
		[3] = "Camo UZI",
		[4] = "Gold UZI",
		[5] = "Winter UZI",
	},

	[42] = { -- TEC 9
		[2] = "Bronze TEC 9",
		[3] = "Camo TEC 9",
		[4] = "Gold TEC 9",
		[5] = "Winter TEC 9",
	},

	[209] = { -- Fénymásolt irat
		[1] = "RG (fotocópia)",
		[2] = "CNH (fotocópia)",
		[3] = "Porte de arma (fotocópia)",
		[4] = "Licença de caça (fotocópia)",
		[5] = "CRLV (fotocópia)",
		[6] = "Licença de pesca (fotocópia)",
	},

	[225] = {
		[2] = "Guarda-chuva (laranja)",
		[3] = "Guarda-chuva (vermelho)",
		[4] = "Guarda-chuva (preto)",
		[5] = "Guarda-chuva (verde)",
		[6] = "Guarda-chuva (branco)",
		[7] = "Guarda-chuva (roxo)",
	}
}

function getItemName(item, value)
	if not value then value = 1 end

	if not (item == 209) then
		value = tonumber(value)
	end
	--print(value)
	if availableItems[item] then
		if item == 209 then
			if value == 1 then
				return availableItems[item].name;
			else
				value = fromJSON(value)[1][1] or false

				if customItemNamesByValue[item] then
					if (customItemNamesByValue[item][value] or false) then
						return customItemNamesByValue[item][value];
					else
						return availableItems[item].name;
					end
				else
					return availableItems[item].name;
				end
			end
		else
			if (value or 1) > 1 then
				if customItemNamesByValue[item] then
					if (customItemNamesByValue[item][value] or false) then
						return customItemNamesByValue[item][value];
					else
						return availableItems[item].name;
					end
				else
					return availableItems[item].name;
				end
			else
				return availableItems[item].name;
			end
		end
	end
end

function getItemImage(item, value)
	if availableItems[item] then

		if (fileExists(":oInventory/files/items/" .. item .. ".png")) then
			if item == 83 then
				if value == 2 then
					return ":oInventory/files/items/" .. item .. "_"..value..".png";
				else
					return ":oInventory/files/items/" .. item .. ".png";
				end
			elseif item == 209 then
				if value then
					value = fromJSON(value)[1][1] or false
					if fileExists(":oInventory/files/items/" .. item .. "_"..value..".png") then
						return ":oInventory/files/items/" .. item .. "_"..value..".png";
					else
						return ":oInventory/files/items/" .. item .. ".png";
					end
				else
					return ":oInventory/files/items/" .. item .. ".png";
				end
			else
				if not value then value = 0 end

				if (tonumber(value) or 0) > 0 then
					if fileExists(":oInventory/files/items/" .. item .. "_"..value..".png") then
						return ":oInventory/files/items/" .. item .. "_"..value..".png";
					else
						return ":oInventory/files/items/" .. item .. ".png";
					end
				else
					return ":oInventory/files/items/" .. item .. ".png";
				end
			end
		end
		return ":oInventory/files/items/0.png";
	end
	return ":oInventory/files/items/0.png";
end

function getItemImageTexture(item)
	return itemImageTextures[item]
end

function getItemWeight(item)
	if availableItems[item] then
		return availableItems[item].weight;
	end
end

function getItemStackable(item)
	if availableItems[item] then
		return availableItems[item].stacking;
	end
end

function getItemObject(item)
	if availableItems[item] then
		return availableItems[item].object;
	end
end

function getCache(item)
	return availableItems
end

alcoholItemDiff = {
	[24] = 10,
	[25] = 10,
	[212] = 20,
	[213] = 30,
	[214] = 10,
	[215] = 10,
	[216] = 10,
}

function isAlcoholDrink(item)
	return (item >= 212 and item <= 216) or item == 24 or item == 25
end

function getTypeElement(element,item)
	if isElement(element) then
		if getElementType(element) == "player" then
			if not item then
				item = 1
			end
			category = availableItems[item].category or "bag"
			return {category, "user:id", 20}
		elseif getElementType(element) == "vehicle" then
			return {"vehicle", "veh:id", exports.oVehicle:getVehicleTrunkMaxSize(getElementModel(element))}
		else
			return {"object", getElementType(element)..":dbid", 65}
		end
	else
		return false
	end
end

function getItemTooltipWorldItem(item,value,count,state)
	local name = getItemName(item,value);
	local drawName = color..name.."#ffffff";
	local drawWeight = "Peso: #3D7ABC"..getItemWeight(item)*count.."#ffffff kg.";
	if state >= 75 and state <= 100 then
		stateHtml = "#7cc576";
	elseif state >= 50 and state < 75 then
		stateHtml = "#eda828";
	elseif state < 50 then
		stateHtml = "#D23131";
	else
		stateHtml = color;
	end
	local drawState = "Estado: "..stateHtml..(state or 0).."#ffffff %";
	local countText = "#7cc576"..count .. "#ffffff un."

	if weaponCache[item] and weaponCache[item].hotTable then
		tooltip = {drawName,drawState,"#ffffff",drawWeight,countText}
	elseif availableItems[item].eat or availableItems[item].drink then
		tooltip = {drawName,drawState,drawWeight,countText}
	elseif item == 51 or item == 52 or item == 54 or item == 53 or item == 69 then
		tooltip = {drawName}
	--elseif item == 127 then
	--	tooltip = {drawName,"#f68934["..tostring(weaponSerial):gsub("_", " ").."] "..value.."#ffffff"};
	--elseif item == 129 then
	--	tooltip = {drawName,drawState};
	elseif item == 1 then
		tooltip = {drawName,drawWeight,countText};
	elseif item == 68 then
		tooltip = {drawName,countText};
	elseif item == 65 then
		tooltip = {drawName,countText};
	elseif item == 66 then
		tooltip = {drawName,countText};
	elseif item == 79 then
		tooltip = {drawName,countText};
	elseif item == 112 or item == 113 or item == 114 then
		tooltip = {drawName,"#f68934"..(state/10).." #ffffffun.",drawWeight,countText};
	elseif item == 154 then
		tooltip = {drawName,countText};
	elseif item == 155 then
		tooltip = {drawName,countText};
	elseif item == 163 or item == 164 then
		tooltip = {drawName,"#f68934"..(state).." #ffffff%",drawWeight,countText};
	elseif item == 183 or item == 184 then
		tooltip = {drawName,"#f68934"..(state/10).." #ffffffL",drawWeight,countText};
	elseif item == 204 then
		tooltip = {drawName,"#f68934"..(state).." #ffffffuso(s)",drawWeight,countText};
	elseif item == 209 then
		local data = fromJSON(value)[1]
		valueText = "N/A"
		if data[1] == 1 then
			valueText = "#3D7ABCCópia de RG#ffffff"
		elseif data[1] == 2 then
			valueText = "#3D7ABCCópia de CNH#ffffff"
		elseif data[1] == 3 then
			valueText = "#3D7ABCCópia de porte de arma#ffffff"
		elseif data[1] == 4 then
			valueText = "#3D7ABCCópia de licença de caça#ffffff"
		elseif data[1] == 6 then
			valueText = "#3D7ABCCópia de licença de pesca#ffffff"
		end
		tooltip = {drawName, valueText, drawWeight,countText}
	else
		tooltip = {drawName,drawWeight,countText};
	end

	return tooltip or "";
end



function getItemTooltip(id,item,value,count,state,weaponSerial,pp,warn)
	local name = getItemName(item,value);

	if not pp then
		pp = 0;
	end

	if not warn then
		warn = 0;
	end

	local drawName = color..name.."#ffffff";
	if pp == 1 then
		drawName = "#FFD700[Premium] "..color..name.."#ffffff";
	end
	local drawWeight = "Peso: #3D7ABC"..getItemWeight(item)*count.."#ffffff kg.";

	if state >= 75 and state <= 100 then
		stateHtml = "#7cc576";
	elseif state >= 50 and state < 75 then
		stateHtml = "#eda828";
	elseif state < 50 then
		stateHtml = "#D23131";
	else
		stateHtml = color;
	end
	local drawState = "Estado: "..stateHtml..(state or 0).."#ffffff %";

	if weaponCache[item] and weaponCache[item].hotTable then
		tooltip = {drawName.." #787878["..weaponSerial.."]#ffffff",drawState,"Alertas: "..color..warn.."#ffffff",drawWeight}
	elseif availableItems[item].eat or availableItems[item].drink then
		tooltip = {drawName,drawState,drawWeight}
	elseif item == 51 or item == 52 or item == 54 or item == 53 or item == 69 or item == 234 or item == 235 then
		tooltip = {drawName,"Identificador: #f68934"..value.."#ffffff"}
	--elseif item == 127 then
	--	tooltip = {drawName,"#f68934["..tostring(weaponSerial):gsub("_", " ").."] "..value.."#ffffff"};
	--elseif item == 129 then
	--	tooltip = {drawName,drawState};
	elseif item == 1 then
		tooltip = {drawName,"Telefone: #f68934"..value.."#ffffff",drawWeight};
	elseif item == 68 then
		tooltip = {drawName,"Nome: #f68934"..string.sub(value,20):gsub("_", " ").."#ffffff", "Validade: #3D7ABC"..string.sub(value,9,12).."."..string.sub(value,13,14).."."..string.sub(value,15,16).."."};
	elseif item == 65 then
		tooltip = {drawName,"Nome: #f68934"..string.sub(value,23):gsub("_", " ").."#ffffff", "Validade: #3D7ABC"..string.sub(value,9,12).."."..string.sub(value,13,14).."."..string.sub(value,15,16).."."};
	elseif item == 146 then
		tooltip = {drawName,"Nome: #f68934"..string.sub(value,23):gsub("_", " ").."#ffffff", "Validade: #3D7ABC"..string.sub(value,9,12).."."..string.sub(value,13,14).."."..string.sub(value,15,16).."."};
	elseif item == 66 then
		tooltip = {drawName,"Nome: #f68934"..string.sub(value,22):gsub("_", " ").."#ffffff", "Validade: #3D7ABC"..string.sub(value,9,12).."."..string.sub(value,13,14).."."..string.sub(value,15,16).."."};
	elseif item == 79 then
		tooltip = {drawName,"Nome: #f68934"..string.sub(value,20):gsub("_", " ").."#ffffff", "Validade: #3D7ABC"..string.sub(value,9,12).."."..string.sub(value,13,14).."."..string.sub(value,15,16).."."};
	elseif item == 112 or item == 113 or item == 114 then
		tooltip = {drawName,"#f68934"..(state/10).." #ffffffun.",drawWeight};
	elseif item == 154 then
		tooltip = {drawName,"Frequência: #f68934"..getElementData(localPlayer, "char:radioStation").."#ffffff Hz"};
	elseif item == 155 then
		tooltip = {drawName,"Conta bancária: #f68934"..value};
	elseif item == 163 or item == 164 then
		tooltip = {drawName,"#f68934"..(state).." #ffffff%",drawWeight};
	elseif item == 183 or item == 184 then
		tooltip = {drawName,"#f68934"..(state/10).." #ffffffL",drawWeight};
	elseif item == 142 or item == 143 or item == 195 or item == 196 or item == 197 or item == 198 then
		value = tonumber(value)
		if value == 1 then
			tooltip = {drawName,"#f68934? #ffffffg"};
		elseif value == 101 then
			tooltip = {drawName,"#f689341 #ffffffg"};
		elseif value == 102 then
			tooltip = {drawName,"#f689342 #ffffffg"};
		elseif value == 103 then
			tooltip = {drawName,"#f689343 #ffffffg"};
		elseif value == 104 then
			tooltip = {drawName,"#f689344 #ffffffg"};
		elseif value == 105 then
			tooltip = {drawName,"#f689345 #ffffffg"};
		end
	elseif item == 204 then
		tooltip = {drawName,"#f68934"..(state).." #ffffffuso(s)",drawWeight};
	elseif item == 209 then
		local data = fromJSON(value)[1]
		valueText = "N/A"
		if data[1] == 1 then
			valueText = "#3D7ABCCópia de RG#ffffff"
		elseif data[1] == 2 then
			valueText = "#3D7ABCCópia de CNH#ffffff"
		elseif data[1] == 3 then
			valueText = "#3D7ABCCópia de porte de arma#ffffff"
		elseif data[1] == 4 then
			valueText = "#3D7ABCCópia de licença de caça#ffffff"
    elseif data[1] == 6 then
      valueText = "#3D7ABCCópia de licença de pesca#ffffff"
		end
		tooltip = {drawName, valueText, drawWeight}
	elseif item == 84 then
		tooltip = {drawName,"#f68934"..(value).." #fffffffolha(s) restante(s)",drawWeight};
	elseif item == 226 or item == 227 then
		tooltip = {drawName,"#f68934"..(value).." #fffffffolha(s) restante(s)"};
	elseif item == 228 or item == 229 then
		value = fromJSON(value)
		tooltip = {drawName,"#f68934"..(value["minutes"] or 0).." #ffffffmin até o fim do prazo."};
	elseif item == 241 then
		tooltip = {drawName,"Nº do bilhete: #f68934"..tonumber(value).."#ffffff"};
	else
		tooltip = {drawName,drawWeight};
	end

	return tooltip or "";
end

function generateSerial()
	return string.char(math.random(65,90)) .. math.random(0, 9) .. math.random(0, 9) .. math.random(0, 9)..string.char(math.random(65,90))..string.char(math.random(65,90))
end

function formatMoney(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if (k==0) then
            break
        end
    end
    return formatted
end

protectedPlaces = {
	{pos = Vector3(1426.5222167969, -1828.3203125, 12.421875), w = 133, d = 86, h = 25}, -- Városháza
	{pos = Vector3(1672.8151855469, -1200.0639648438, 23.000004331055), w = 37, d = 30, h = 10}, -- Bank
	{pos = Vector3(1138.9544677734, -1388.8897705078, 12.803576469421), w = 60, d = 100, h = 25}, -- Korház
	{pos = Vector3(2097.501953125, -1823.7355957031, 12.000002229004), w = 30, d = 35, h = 10}, -- Pizza hut, déli mellett
	{pos = Vector3(2404.0458984375, -1514.1313476562, 22.006782531738), w = 20, d = 25, h = 10}, -- étterem, east los santos
}

printerItems = {
	[65] = 1,
	[66] = 2,
	--[67] = 5,
	[68] = 3,
	[79] = 4,
	[209] = 209,
}

notDropItems = {
	[1] = true,
	[44] = true,
	[51] = true,
	[52] = true,
	[53] = true,
	[54] = true,
	[65] = true,
	[66] = true,
	[67] = true,
	[68] = true,
	[69] = true,
	[77] = true,
	[78] = true,
	[79] = true,
	[82] = true,
	[83] = true,
	[84] = true,
	[85] = true,
	[86] = true,
	[87] = true,
	[88] = true,
	[89] = true,
	[90] = true,
	[91] = true,
	[109] = true,
	[115] = true,
	[117] = true,
	[118] = true,
	[119] = true,
	[120] = true,
	[121] = true,
	[122] = true,
	[123] = true,
	[124] = true,
	[125] = true,
	[126] = true,
	[127] = true,
	[128] = true,
	[129] = true,
	[130] = true,
	[131] = true,
	[132] = true,
	[133] = true,
	[134] = true,
	[135] = true,
	[136] = true,
	[137] = true,
	[138] = true,
	[139] = true,
	[140] = true,
	[141] = true,
	[146] = true,
	[147] = true,
	[148] = true,
	[149] = true,
	[155] = true,
	[200] = true,
	[205] = true,
	[206] = true,
	[207] = true,
	[209] = true,
	[224] = true,
}
