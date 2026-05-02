pages = {
    {"Visão geral","user.png"},
    {"Patrimônio","dollar.png"},
    {"Administradores","admins.png"},
    {"Configurações","options.png"},
    {"Organizações","factions.png"},
    {"Premium","pp.png"},
    {"Presente diário e Case Shop","daily.png"},
    --{"Kisállat","pet.png"},
}

charStats = {
    {"Nome do personagem", "char:name"},
    {"Gênero", "char:gender"},
    {"Idade", "char:age"},
    {"Peso", "char:weight"},
    {"Altura", "char:height"},
    {"ID de aparência", "nan"},
    {"Trabalho", "char:job"},
    {"Organização", "char:faction"},
    {"Tempo até o pagamento", "char:minToPayment"},
    {"Dinheiro (mão)", "char:money"},
    {"Veículos", "0"},
    {"Imóveis", "0"},
}

userStats = {
    {"Nome de usuário", "user:name"},
    {"ID da conta", "user:id"},
    {"ID do personagem / código de convite", "char:id"},
    {"Nível admin", "user:admin"},
    {"Nome admin", "user:adminnick"},
    {"Data de registro", "user:registerDate"},
    {"Ban(s)", "dashboard:banKickJailCount"},
    {"Kick(s)", "dashboard:banKickJailCount"},
    {"Jail(s)", "dashboard:banKickJailCount"},
    {"Tempo jogado", "char:playedTime"},
    {"E-mail", "user:email"},
    {"Serial", "user:serial"},
}

vagyonTargyak = {
    {"Dinheiro (mão)", "char:money"},
    {"Casino Coin", "char:cc"},
    {"Saldo bancário", "_bankmoney"},
 --   {"Prémium Pont", "char:pp"},
}

adminPrefix = {"AS","A1","A2","A3","FA","SA","</>","T"}

vehicleDatas = {
    {"Estado do veículo",10},
    {"Estado do motor",4},
    {"Estado das portas",3},
    {"Estado das luzes",11},
    {"Nível de combustível",15},
    {"Tipo de combustível",16},
    {"Posição",9},
    {"Motor", 12, "engine"},
    {"Câmbio", 12, "gear"},
    {"Freios", 12, "brake"},
    {"Turbo", 12, "turbo"},
    {"ECU", 12, "ecu"},
    {"Redução de peso", 12, "wloss"},
    {"Distância até a troca de óleo:", 19, "wloss"},
}

walkingStyles = {0, 54, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138}
talkinkingAnimations = {
    {"misc", "idle_chat_02"},
    {"ped", "idle_chat"},
    {"ghands", "gsign1"},
    {"ghands", "gsign2"},
    {"ghands", "gsign3"},
    {"ghands", "gsign4"},
    {"ghands", "gsign5"},
}

options = {
    ["graphics"] = {
        name = "Configurações gráficas",
        icon = "graphics.png",
        --- nome, tipo (1:on/off, 2:slider, 3:botão esq/dir), valor mín., valor máx., função, estado, disponível na beta
        {"Distância de visão", 2, 100, 4000, "setMaxShowDistance", 0, true},
        {"Paleta de cores", 3, 0, 17, "oShader_Palette", 0, true},
        {"Bloom", 1, 1, 1, "oShader_Bloom", false, true}, --dash > shader > toggleBloom
        {"Reflexo nos veículos", 1, 0, 0, "oShader_VehicleReflection", false, true},
        {"Desfoque de movimento", 1, 1, 1, "oShader_MotionBlur", false, true},
        {"Vignette", 1, 1, 1, "oShader_Vignette", false, true},
        {"Água detalhada", 1, 1, 1, "oShader_Water", false, true}, --dash > shader > toggleWater
        {"Texturas HD", 1, 1, 1, "oShader_HDTextures", false, true},
        {"Profundidade de campo", 1, 1, 1, "oShader_Depth", false, true},
        {"Anti-aliasing (FXAA)", 1, 1, 1, "oShader_FXAA", true, true}
        --{"Queda de neve", 1, 1, 1, "snow:state", false, true},
        --{"Grama detalhada", 1, 1, 1, "oShader_HDGrass", false},
    },

    ["char"] = {
        name = "Configurações do personagem",
        icon = "char.png",
        --- nome, tipo (1:on/off, 3:botão esq/dir), valor mín., valor máx., função, estado, disponível na beta
        {"Estilo de luta", 3, 1, 20, "", "char:fightStyle", true},
        {"Estilo de caminhada", 3, 1, 23, "", "char:walkStyle", true},
        {"Animação ao falar", 3, 0, 10, "", "char:talkAnimation", true},
        {"Avatar", 4, 0, 10, "", 1, true, ":oAccount/avatars/"},
    },

    ["other"] = {
        name = "Outras configurações",
        icon = "settings.png",
        {"Contorno do texto", 3, 1, 3, "", 1, true},
        {"Estilo do nametag", 3, 1, 3, "", 1, true},

        --v1.0.1 UPDATE
        {"Mostrar meu nome", 1, 1, 1, "", 0, true},
        {"Dicas", 1, 1, 1, "", 1, true},
    },

    ["crosshair"] = {
        name = "Mira",
        icon = "target.png",
        {"Aparência", 4, 0, 10, "", 1, true, ":oCrosshair/crosshairs/"},
        {"Cor", 5, 0, 10, "", 1, true},
    },

    ["xmas"] = {
        name = "Natal",
        icon = "xmas.png",
        {"Neve", 1, 1, 1, "oShader_Snow", false, true},
        {"Estilo da neve", 3, 1, 2, "oShader_Snow", 1, true},
        {"Intensidade da neve", 2, 500, 2000, "oShader_Snow", 2000, true},
        {"Neve ondulante", 1, 1, 1, "oShader_Snow", true, true},

    }
}

rareVehicles = {
    [451] = true,
    [409] = true,
    [411] = true,
    [429] = true,
    [525] = true,
}

function getTalkingAnimation(id)
    if id > 0 then 
        return talkinkingAnimations[id]
    else
        return {"", ""}
    end
end

vignetteSetup = {
    {"Opacidade", 3, 0.1, 1, "", 0.5, true},
    {"Extensão", 3, 1, 10, "", 5, true},
}

crosshairColors = {
    {255, 255, 255},
    {252, 186, 3},
    {251, 82, 3},
    {250, 3, 3},
    {41, 194, 43},
    {48, 150, 240},
    {207, 64, 195},
}

core = exports.oCore
preview = exports.oPreview
infobox = exports.oInfobox
mysql = exports.oMysql
admin = exports.oAdmin
inventory = exports.oInventory
interface = exports.oInterface
font = exports.oFont
cMarker = exports.oCustomMarker
job = exports.oJob
blur = exports.oBlur
vehicle = exports.oVehicle
color, r, g, b = core:getServerColor()
serverColor, r, g, b = core:getServerColor()
moneyColor = "#7cc576"

--- FACÇÕES
factionPages = {
    --{"nome", "ícone"},
    {"Visão geral", "home"},
    {"Membros", "team"},
    {"Veículos", "vehicle"},
    {"Patentes", "ranks"},
    {"Serviços (duty)", "dutys"},
    --{"Armazém", "inventory"},
}

factionHomepageInfos = {
    --{"Descrição", "nome na tabela", fundoR, fundoG, fundoB, textoR, textoG, textoB}
    {"Membros", 0, r, g, b, 220, 220, 220},
    {"Veículos", 6, r, g, b, 220, 220, 220},
    {"Patentes", 7, r, g, b, 220, 220, 220},
    {"Serviços (duty)", 8, r, g, b, 220, 220, 220},
}

factionMemberInformations = {
    {"Nome", 4},
    {"Patente", 2},
    {"Líder", 3},
    {"Em serviço", 5},
    {"Último início de serviço", 8},
    {"Último login", 7},
    {"Tempo em serviço", 9, "min"},
}

factionLeaderOptions = {
    {"Promover"},
    {"Rebaixar"},
    {"Conceder líder"},
    {"Expulsar"},
    {"Zerar tempo de serviço"},
    {"Dar distintivo"},
}

factionRankInformations = {
    {"Nome", 1},
    {"Salário", 2},
    {"ID do duty vinculado", 3},
    {"Membros nesta patente", 0},
}

vehicleTypes = {
    ["Automobile"] = "Carro",
    ["Plane"] = "Avião",
    ["Bike"] = "Moto",
    ["Helicopter"] = "Helicóptero",
    ["Boat"] = "Barco",
    ["Train"] = "Trem",
    ["Trailer"] = "Reboque",
    ["BMX"] = "BMX",
    ["Monster Truck"] = "Monster Truck",
    ["Quad"] = "Quadriciclo",
}

vehicleTunings = {
    ["engine-1"] = "Motor básico",
    ["engine-2"] = "Motor esportivo",
    ["engine-3"] = "Motor profissional",
    ["engine-4"] = "Motor premium",
    ["gear-1"] = "Câmbio básico",
    ["gear-2"] = "Câmbio esportivo",
    ["gear-3"] = "Câmbio profissional",
    ["gear-4"] = "Câmbio premium",
    ["brake-1"] = "Freios básicos",
    ["brake-2"] = "Freios esportivos",
    ["brake-3"] = "Freios profissionais",
    ["brake-4"] = "Freios premium",
    ["turbo-1"] = "Turbo básico",
    ["turbo-2"] = "Turbo esportivo",
    ["turbo-3"] = "Turbo profissional",
    ["turbo-4"] = "Turbo premium",
    ["ecu-1"] = "ECU básica",
    ["ecu-2"] = "ECU esportiva",
    ["ecu-3"] = "ECU profissional",
    ["ecu-4"] = "ECU premium",
}

factionLogMessageColor = "#fc7b03"
factionLogNameColor = "#0d73e0"
factionLogPrefix = "#fc5a03[Organização - LOG]: "..factionLogMessageColor

-- Teclas bloqueadas no painel (nome legado: tiltott_keys)
tiltott_keys = {
    ["backspace"] = true,
    ["enter"] = true,
	["tab"] = true,
	["-"] = true,
	["."] = true,
	[","] = true,
	["lctrl"] = true,
	["rctrl"] = true,
	["lalt"] = true,
	["mouse1"] = true,
	["mouse2"] = true,
	["mouse3"] = true,
	["F1"] = true,
	["F2"] = true,
	["F3"] = true,
	["F4"] = true,
	["F5"] = true,
	["F6"] = true,
	["F7"] = true,
	["F8"] = true,
	["F9"] = true,
	["F10"] = true,
	["F11"] = true,
	["F12"] = true,
	["lshift"] = true, 
	["rshift"] = true,
	["space"] = true,
	["pgdn"] = true,
	["num_div"] = true,
	["num_mul"] = true,
	["num_sub"] = true,
	["num_add"] = true,
	["num_enter"] = true,
	["num_sub"] = true,
	["escape"] = true,
	["insert"] = true,
	["home"] = true,
	["delete"] = true,
	["end"] = true,
	["pgup"] = true,
	["scroll"] = true,
	["pause"] = true,
	["ralt"] = true,
    ["enter"] = true,
    ["mouse_wheel_down"] = true,
    ["mouse_wheel_up"] = true,
    ["capslock"] = true,
    ["arrow_u"] = true,
    ["arrow_d"] = true,
    ["arrow_l"] = true,
    ["arrow_r"] = true,
}

premiumCategories = {
    {name = "Comida e bebida", items = {
        {id = 76, price = 30, count = 1, value = 1}, 
    
    
        {id = 2, price = 5, count = 1, value = 1},    
        {id = 6, price = 5, count = 1, value = 1},    
        {id = 8, price = 2, count = 1, value = 1},    
        {id = 12, price = 2, count = 1, value = 1},    
        {id = 22, price = 1, count = 1, value = 1},    
    }},
    {name = "Armas", items = {
        -- Munições
        {id = 45, price = 200, count = 50, value = 1},    
        {id = 46, price = 100, count = 5, value = 1},    
        {id = 47, price = 100, count = 25, value = 1},    
        {id = 48, price = 100, count = 25, value = 1},    
        {id = 49, price = 100, count = 5, value = 1},    

        {id = 27, price = 5000, count = 1, value = 100},
        {id = 28, price = 6000, count = 1, value = 100},
        {id = 29, price = 4500, count = 1, value = 1},    
        {id = 30, price = 4000, count = 1, value = 100},
        {id = 32, price = 3000, count = 1, value = 1},    
        {id = 34, price = 5000, count = 1, value = 100},    
        {id = 35, price = 6000, count = 1, value = 100},
        --{id = 37, price = 7000, count = 1, value = 100},    
        {id = 38, price = 8000, count = 1, value = 100},    
        {id = 39, price = 6000, count = 1, value = 100},    
        {id = 40, price = 5000, count = 1, value = 100},    
        {id = 42, price = 5500, count = 1, value = 100},  

        -- Armas com skin
        {id = 27, price = 9000, count = 1, value = 2}, 
        {id = 27, price = 9500, count = 1, value = 3}, 
        {id = 27, price = 9500, count = 1, value = 4}, 
        {id = 27, price = 10000, count = 1, value = 5}, 
        {id = 27, price = 11000, count = 1, value = 6}, 
        {id = 27, price = 9500, count = 1, value = 7}, 
        {id = 27, price = 8000, count = 1, value = 8}, 
        
        {id = 28, price = 9700, count = 1, value = 2}, 
        {id = 28, price = 9500, count = 1, value = 3}, 
        {id = 28, price = 9900, count = 1, value = 4}, 
        {id = 28, price = 10000, count = 1, value = 5}, 
        {id = 28, price = 9500, count = 1, value = 6}, 
        {id = 28, price = 11000, count = 1, value = 7}, 
        {id = 28, price = 8700, count = 1, value = 8}, 
        {id = 28, price = 8000, count = 1, value = 9}, 
    
        {id = 30, price = 6000, count = 1, value = 2}, 
        {id = 30, price = 8000, count = 1, value = 3}, 
        {id = 30, price = 7000, count = 1, value = 4}, 
    
        {id = 32, price = 4700, count = 1, value = 2}, 
        {id = 32, price = 4500, count = 1, value = 3}, 
        {id = 32, price = 4000, count = 1, value = 4}, 
        {id = 32, price = 5000, count = 1, value = 5}, 
        {id = 32, price = 4900, count = 1, value = 6}, 
        {id = 32, price = 5500, count = 1, value = 7}, 
    
        {id = 38, price = 12000, count = 1, value = 2}, 
        {id = 38, price = 11000, count = 1, value = 3}, 
    
        {id = 39, price = 6500, count = 1, value = 2}, 
        {id = 39, price = 6700, count = 1, value = 3}, 
        {id = 39, price = 6400, count = 1, value = 4}, 
        {id = 39, price = 7500, count = 1, value = 5}, 
        {id = 39, price = 8000, count = 1, value = 6}, 
        {id = 39, price = 7900, count = 1, value = 7}, 
        {id = 39, price = 7500, count = 1, value = 8}, 
        {id = 39, price = 6500, count = 1, value = 9}, 
        {id = 39, price = 8200, count = 1, value = 10}, 
    
        {id = 40, price = 6400, count = 1, value = 2}, 
        {id = 40, price = 6500, count = 1, value = 3}, 
        {id = 40, price = 7300, count = 1, value = 4}, 
        {id = 40, price = 7500, count = 1, value = 5}, 
    
        {id = 42, price = 6300, count = 1, value = 2}, 
        {id = 42, price = 6200, count = 1, value = 3}, 
        {id = 42, price = 7300, count = 1, value = 4}, 
        {id = 42, price = 7000, count = 1, value = 5}, 
    }},
    {name = "Outros itens", items = { -- 94, 104, 101, 
        -- Prémium kártyák
        {id = 82, price = 500, count = 1, value = 1},    
        {id = 89, price = 500, count = 1, value = 1},    
        {id = 90, price = 750, count = 1, value = 1},    
        {id = 91, price = 500, count = 1, value = 1}, 
        {id = 115, price = 1500, count = 1, value = 1}, 

        -- Mesyterkönyvek
        {id = 117, price = 4500, count = 1, value = 1}, 
        {id = 118, price = 5000, count = 1, value = 1}, 
        {id = 119, price = 3500, count = 1, value = 1}, 
        {id = 120, price = 4000, count = 1, value = 1}, 
        {id = 121, price = 3000, count = 1, value = 1}, 
        {id = 122, price = 3200, count = 1, value = 1}, 
        {id = 123, price = 3500, count = 1, value = 1}, 
        {id = 125, price = 4000, count = 1, value = 1}, 
        {id = 126, price = 5000, count = 1, value = 1}, 

        -- drogok
        {id = 55, price = 200, count = 1, value = 1},    
        {id = 56, price = 200, count = 1, value = 1},    
        {id = 57, price = 200, count = 1, value = 1},    
        {id = 58, price = 150, count = 1, value = 1},   

        -- egyebek
        {id = 94, price = 500, count = 1, value = 1},
        {id = 101, price = 700, count = 1, value = 1},
        {id = 104, price = 750, count = 1, value = 1},
    }},
    {name = "Dinheiro", items = {
        -- icon (png), price (pp) count ($)
        {icon = "4", price = 1000, count = 32000},    
        {icon = "5", price = 2500, count = 80000},    
        {icon = "6", price = 5000, count = 160000},    
        {icon = "2", price = 10000, count = 320000},    
        {icon = "3", price = 20000, count = 640000},    
        {icon = "1", price = 30000, count = 1000000},    
    }},
    {name = "Pacotes", items = {

    }},
}

premiumItemPackages = { 
-- állatos csomag: prémium kutyatáp 25 db 90%
-- földes csomag: prémium föld 25db 90%
    {name = "Pacote Colt-45", price = 6100, items = {
        {id = 37, count = 1, value = 100},
        {id = 47, count = 75},
        {id = 123, count = 1, value = 1},

    }},

    {name = "Pacote Desert Eagle", price = 7400, items = {
        {id = 30, count = 1, value = 100},
        {id = 47, count = 75},
        {id = 125, count = 1, value = 1},
    }},

    {name = "Pacote Shotgun", price = 8500, items = {
        {id = 34, count = 1, value = 100},
        {id = 46, count = 75},
        {id = 121, count = 1, value = 1},

    }},

    {name = "Pacote espingarda serrada", price = 9600, items = {
        {id = 35, count = 1, value = 100},
        {id = 46, count = 75},
        {id = 122, count = 1, value = 1},

    }},

    {name = "Pacote UZI", price = 7900, items = {
        {id = 40, count = 1, value = 100},
        {id = 48, count = 75},
        {id = 119, count = 1, value = 1},
    }},

    {name = "Pacote TEC9", price = 8100, items = {
        {id = 42, count = 1, value = 100},
        {id = 48, count = 75},
        {id = 119, count = 1, value = 1},
    }},

    {name = "Pacote P90", price = 9200, items = {
        {id = 39, count = 1, value = 100},
        {id = 48, count = 75},
        {id = 120, count = 1, value = 1},
    }},

    {name = "Pacote AK-47", price = 8800, items = {
        {id = 27, count = 1, value = 100},
        {id = 45, count = 75},
        {id = 117, count = 1, value = 1},
    }},

    {name = "Pacote M4", price = 10100, items = {
        {id = 28, count = 1, value = 100},
        {id = 45, count = 75},
        {id = 118, count = 1, value = 1},
    }},

    {name = "Pacote franco-atirador", price = 11900, items = {
        {id = 38, count = 1, value = 100},
        {id = 49, count = 75},
        {id = 126, count = 1, value = 1},
    }},

    {name = "Pacote bichinho de estimação", price = 11000, items = {
        {id = 94, count = 25},
    }},

    {name = "Pacote jardineiro", price = 16500, items = {
        {id = 104, count = 25},
    }},
}

premiumInfos = {
    {title = "Como adquirir pontos premium", texts = {
        serverColor.."PayPal: #ffffffVocê pode apoiar o servidor via PayPal (consulte o fórum do Ipiranga Roleplay para dados oficiais).",
    }},

    {title = "O que dá para comprar com pontos premium?", texts = {
        serverColor.."Itens premium: #ffffffNa loja premium você compra itens e pacotes.",
        serverColor.."Dinheiro in-game: #ffffffPacotes de dinheiro na loja premium.",
        serverColor.."Slots: #ffffffNa aba "..serverColor.."'Patrimônio' #ffffffdá para comprar slot de imóvel ou veículo.",
        serverColor.."Concessionária: #ffffffVeículos por pontos premium; alguns ignoram o limite da loja.",
        "Há veículos exclusivos por pontos premium na concessionária.",
        serverColor.."Portões: #ffffffCompra de portão conforme regras do servidor; valores no fórum do Ipiranga Roleplay.",
        serverColor.."Instalação: #ffffffA colocação de portões é feita por "..serverColor.."SuperAdmin#ffffff ou "..serverColor.."ServerManager#ffffff.",
        serverColor.."Não achou o que quer? #ffffffFale com a equipe no Discord ou fórum oficial.",
    }},

    {title = "Pacotes de pontos premium (referência)", texts = {
        serverColor.."1000 PP #ffffff— valores em BRL conforme anúncio oficial",
        serverColor.."3500 PP #ffffff— valores em BRL conforme anúncio oficial",
        serverColor.."6000 PP #ffffff— valores em BRL conforme anúncio oficial",
        serverColor.."12.000 PP #ffffff— valores em BRL conforme anúncio oficial",
        serverColor.."24.000 PP #ffffff— valores em BRL conforme anúncio oficial",
    }},

    {title = "Documentação de pontos premium", texts = {
        serverColor.."Consulte o fórum ou Discord do Ipiranga Roleplay para PDFs e tabelas atualizadas.",

    }},
}

-- Tecla física → caractere layout húngaro (entrada; não alterar valores)
custom_keys = {
    ["["] = "ő",
    ["]"] = "ú",
    ["="] = "ó",
    ["/"] = "ü",
    ["'"] = "ö",
    ["#"] = "á",
    [";"] = "é",
    ["\\"] = "ű",
}

adminTags = {"Ajudante", "Administrador 1", "Administrador 2", "Administrador 3", "Administrador 4", "Administrador 5", "Admin principal", "AdminController", "Server Manager", "Desenvolvedor", "Dono"}

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function tableContains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  end


tuning_categories = {"Básico", "Esportivo", "Profissional", "Premium"}

fightingStyles = {4, 5, 6, 15, 16}
walkingStyles = {0, 54, 55, 56, 118, 119, 120, 121, 122, 123, 124, 126, 128, 129, 130, 131, 132, 133, 134, 135, 137}

fuelTypes = {
    ["95"] = "Gasolina",
    ["D"] = "Diesel",
    ["electric"] = "Elétrico",
}

dailyGifts = {
    ["small"] = {
        {"PP", 10, "Pontos premium", "files/daily/pp.png"},
        {"$", 2500, "Dinheiro (mão)", "files/daily/dollar.png"},
        {"CC", 2000, "CasinoCoin", "files/daily/cc.png"},
        {"PP", 25, "Pontos premium", "files/daily/pp.png"},
        {"$", 4000, "Dinheiro (mão)", "files/daily/dollar.png"},
        {"CC", 1000, "CasinoCoin", "files/daily/cc.png"},
        {"PP", 5, "Pontos premium", "files/daily/pp.png"},
        {"$", 5000, "Dinheiro (mão)", "files/daily/dollar.png"},
        {"CC", 500, "CasinoCoin", "files/daily/cc.png"},

        {"item", 1, "Remédio", exports.oInventory:getItemImage(76), item = 76},
        {"item", 1, "Vitamina", exports.oInventory:getItemImage(150), item = 150},
        {"item", 1, "Item", exports.oInventory:getItemImage(135), item = 135},
        {"item", 1, "Item", exports.oInventory:getItemImage(2), item = 2},
        {"item", 1, "Item", exports.oInventory:getItemImage(3), item = 3},
        {"item", 1, "Item", exports.oInventory:getItemImage(4), item = 4},
        {"item", 1, "Item", exports.oInventory:getItemImage(5), item = 5},
        {"item", 1, "Item", exports.oInventory:getItemImage(6), item = 6},
        {"item", 1, "Item", exports.oInventory:getItemImage(7), item = 7},
        {"item", 1, "Item", exports.oInventory:getItemImage(8), item = 8},
        {"item", 1, "Item", exports.oInventory:getItemImage(9), item = 9},
        {"item", 1, "Item", exports.oInventory:getItemImage(10), item = 10},
        {"item", 1, "Item", exports.oInventory:getItemImage(11), item = 11},
        {"item", 1, "Item", exports.oInventory:getItemImage(12), item = 12},
        {"item", 1, "Item", exports.oInventory:getItemImage(13), item = 13},
        {"item", 1, "Item", exports.oInventory:getItemImage(14), item = 14},
        {"item", 1, "Item", exports.oInventory:getItemImage(15), item = 15},
        {"item", 1, "Item", exports.oInventory:getItemImage(16), item = 16},
        {"item", 1, "Item", exports.oInventory:getItemImage(17), item = 17},
        {"item", 1, "Item", exports.oInventory:getItemImage(18), item = 18},
        {"item", 1, "Item", exports.oInventory:getItemImage(19), item = 19},
        {"item", 1, "Item", exports.oInventory:getItemImage(20), item = 20},
        {"item", 1, "Item", exports.oInventory:getItemImage(21), item = 21},
        {"item", 1, "Item", exports.oInventory:getItemImage(22), item = 22},
        {"item", 1, "Item", exports.oInventory:getItemImage(23), item = 23},
        {"item", 1, "Item", exports.oInventory:getItemImage(24), item = 24},
        {"item", 1, "Item", exports.oInventory:getItemImage(25), item = 25},
        {"item", 1, "Item", exports.oInventory:getItemImage(26), item = 26},
    },

    ["big"] = {
        {"vehicleSlot", 1, "Slot de veículo", "files/daily/car.png"},
        {"interiorSlot", 1, "Slot de imóvel", "files/daily/house.png"},
        {"item", 1, "Cartão de reparo", exports.oInventory:getItemImage(90), item = 90},
        {"item", 1, "Cartão de abastecimento instantâneo", exports.oInventory:getItemImage(91), item = 91},
        {"item", 1, "Cartão de cura instantânea", exports.oInventory:getItemImage(89), item = 89},
        {"item", 1, "Cartão desvirar veículo", exports.oInventory:getItemImage(82), item = 82},
        {"item", 1, "Vaso decorativo", exports.oInventory:getItemImage(186), item = 186},
        {"item", 1, "Rubi", exports.oInventory:getItemImage(195), item = 195},
        {"item", 1, "Esmeralda", exports.oInventory:getItemImage(196), item = 196},
        {"item", 1, "Safira", exports.oInventory:getItemImage(197), item = 197},
        {"item", 1, "Âmbar", exports.oInventory:getItemImage(198), item = 198},
    },
}

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end

function isLeapYear(year)
    if year then year = math.floor(year)
    else year = getRealTime().year + 1900 end
    return ((year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0)
end


-- CREATE
-- Estrutura do item de presente
-- {item = (id do item/0), rarity = (1:COMMON, 2:RARE, 3:EPIC, 4:LEGENDARY), money = (dinheiro/pp/slot imóvel/slot veículo), type = (1:item, 2:dólar, 3:pp, 4:slot imóvel, 5:slot veículo), itemvalue = (ex.: skin em arma com skin)}


-- Do mais barato ao um pouco mais caro, exceto livros mestres
creates = {
    {name = "REBOOT BOX", price = 0, money_type = "$", icon = "reboot", specialtag = "REBOOT", tagcolor = {247, 60, 47}, expire = 1673218740, gifts = {
        {item = 89, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 90, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 91, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 32, rarity = 4, money = 0, type = 1, itemvalue = 2},
        {item = 115, rarity = 4, money = 0, type = 1, itemvalue = 1},
        {item = 119, rarity = 4, money = 0, type = 1, itemvalue = 1},
        {item = 122, rarity = 4, money = 0, type = 1, itemvalue = 1},
        {item = 135, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 81, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 43, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 200, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 150, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 157, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 104, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 94, rarity = 2, money = 0, type = 1, itemvalue = 1},

        {item = 243, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 244, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 245, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 246, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 247, rarity = 2, money = 0, type = 1, itemvalue = 1},

        {item = 0, rarity = 1, money = 6000, type = 2, itemvalue = 1},
        {item = 0, rarity = 2, money = 12000, type = 2, itemvalue = 1},
        {item = 0, rarity = 3, money = 24000, type = 2, itemvalue = 1},
        {item = 0, rarity = 4, money = 40000, type = 2, itemvalue = 1},

        {item = 0, rarity = 1, money = 100, type = 3, itemvalue = 1},
        {item = 0, rarity = 2, money = 500, type = 3, itemvalue = 1},
        {item = 0, rarity = 3, money = 1000, type = 3, itemvalue = 1},
        {item = 0, rarity = 4, money = 2500, type = 3, itemvalue = 1},
    }},

    {name = "GOLDEN CASE", price = 9000, money_type = "$", icon = "gold", specialtag = "", tagcolor = {247, 60, 47}, gifts = {
        {item = 27, rarity = 3, money = 0, type = 1, itemvalue = 6},
        {item = 27, rarity = 3, money = 0, type = 1, itemvalue = 5},
        {item = 28, rarity = 4, money = 0, type = 1, itemvalue = 5},
        {item = 30, rarity = 2, money = 0, type = 1, itemvalue = 3},
        {item = 40, rarity = 1, money = 0, type = 1, itemvalue = 4},
        {item = 42, rarity = 1, money = 0, type = 1, itemvalue = 4},
    }},

    {name = "WINTER CASE", price = 9500, money_type = "$", icon = "winter", specialtag = "", tagcolor = {247, 60, 47}, gifts = {
        {item = 27, rarity = 3, money = 0, type = 1, itemvalue = 2},
        {item = 28, rarity = 3, money = 0, type = 1, itemvalue = 3},
        {item = 28, rarity = 2, money = 0, type = 1, itemvalue = 6},
        {item = 39, rarity = 3, money = 0, type = 1, itemvalue = 3},
        {item = 40, rarity = 1, money = 0, type = 1, itemvalue = 5},
        {item = 42, rarity = 1, money = 0, type = 1, itemvalue = 5},
        {item = 38, rarity = 4, money = 0, type = 1, itemvalue = 2},
    }},

    {name = "PINK CASE", price = 7500, money_type = "$", icon = "pink", specialtag = "", tagcolor = {247, 60, 47}, gifts = {
        {item = 27, rarity = 3, money = 0, type = 1, itemvalue = 7},
        {item = 28, rarity = 4, money = 0, type = 1, itemvalue = 7},
        {item = 30, rarity = 2, money = 0, type = 1, itemvalue = 4},
        {item = 119, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 123, rarity = 1, money = 0, type = 1, itemvalue = 1},
    }},

    {name = "LIVROS MESTRES", price = 4500, money_type = "$", icon = "mesterkonyvek", specialtag = "", tagcolor = {247, 60, 47}, gifts = {
        {item = 117, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 118, rarity = 4, money = 0, type = 1, itemvalue = 1},
        {item = 119, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 120, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 121, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 122, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 123, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 125, rarity = 4, money = 0, type = 1, itemvalue = 1},
        {item = 126, rarity = 4, money = 0, type = 1, itemvalue = 1},
    }},

    {name = "KNIFE CASE", price = 5000, money_type = "$", icon = "knives", specialtag = "", tagcolor = {247, 60, 47}, gifts = {
        {item = 32, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 32, rarity = 2, money = 0, type = 1, itemvalue = 2},
        {item = 32, rarity = 2, money = 0, type = 1, itemvalue = 3},
        {item = 32, rarity = 2, money = 0, type = 1, itemvalue = 4},
        {item = 32, rarity = 4, money = 0, type = 1, itemvalue = 5},
        {item = 32, rarity = 3, money = 0, type = 1, itemvalue = 6},
        {item = 32, rarity = 3, money = 0, type = 1, itemvalue = 7},
    }},

}

dailyBoxRewards = {
    ["normal"] = {
        {item = 2, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 88, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 13, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 18, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 22, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 212, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 214, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 159, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 76, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 135, rarity = 4, money = 0, type = 1, itemvalue = 1},
        {item = 195, rarity = 4, money = 0, type = 1, itemvalue = 1},
        {item = 0, rarity = 2, money = 3000, type = 2, itemvalue = 1},
        {item = 0, rarity = 3, money = 5000, type = 2, itemvalue = 1},
        {item = 0, rarity = 4, money = 7500, type = 2, itemvalue = 1},
        {item = 0, rarity = 3, money = 70, type = 3, itemvalue = 1},
        {item = 0, rarity = 4, money = 120, type = 3, itemvalue = 1},
        {item = 95, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 97, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 103, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 236, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 237, rarity = 3, money = 0, type = 1, itemvalue = 1},
    },

    ["super"] = {
        {item = 188, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 186, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 196, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 31, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 89, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 90, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 82, rarity = 3, money = 0, type = 1, itemvalue = 1},
        {item = 91, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 0, rarity = 1, money = 4000, type = 2, itemvalue = 1},
        {item = 0, rarity = 2, money = 7500, type = 2, itemvalue = 1},
        {item = 0, rarity = 3, money = 15000, type = 2, itemvalue = 1},
        {item = 0, rarity = 4, money = 30000, type = 2, itemvalue = 1},
        {item = 0, rarity = 1, money = 70, type = 3, itemvalue = 1},
        {item = 0, rarity = 2, money = 120, type = 3, itemvalue = 1},
        {item = 0, rarity = 3, money = 200, type = 3, itemvalue = 1},
        {item = 0, rarity = 4, money = 800, type = 3, itemvalue = 1},
        {item = 0, rarity = 4, money = 1, type = 4, itemvalue = 1}, -- slot de imóvel
        {item = 0, rarity = 4, money = 1, type = 5, itemvalue = 1}, -- slot de veículo
        {item = 94, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 104, rarity = 1, money = 0, type = 1, itemvalue = 1},
        {item = 236, rarity = 2, money = 0, type = 1, itemvalue = 1},
        {item = 237, rarity = 2, money = 0, type = 1, itemvalue = 1},
    },
}

function getTimestamp(year, month, day, hour, minute, second)
    -- initiate variables
    local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
    local timestamp = 0
    local datetime = getRealTime()
    year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
    hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second
    
    -- calculate timestamp
    for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
    for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
    timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second
    
    timestamp = timestamp - 3600 --GMT+1 compensation
    if datetime.isdst then timestamp = timestamp - 3600 end
    
    return timestamp
end