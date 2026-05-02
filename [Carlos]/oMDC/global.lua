core = exports.oCore 
color, r, g, b = core:getServerColor()
font = exports.oFont
infobox = exports.oInfobox
dashboard = exports.oDashboard
vehicle = exports.oVehicle 

accessTypes = {
    "Geral",
    "Admin",
    "Admin de sistema",
}

factions = {
    ["pd"] = "Polícia Civil - 17ª DP (Ipiranga)",
    ["sd"] = "Polícia Militar - PMESP",
    ["orp"] = "Administrador",
}

mdcEditboxs = {
    [1] = { -- Login
        {x = 0.002, y = 0.065, w = 0.146, h = 0.035, name = "user", text = "Nome de usuário", type = "text", maxFontScale = 0.4},
        {x = 0.002, y = 0.105, w = 0.146, h = 0.035, name = "pass", text = "Senha", type = "password", maxFontScale = 0.1},
    },

    [2] = { -- Visão geral
        {x = 0.006, y = 0.067, w = 0.3, h = 0.035, name = "enumber", text = "Identificação da unidade", type = "text", maxFontScale = 0.4, openType = "veh"},
    },

    [3] = { -- Pessoas procuradas
        {x = 0.006, y = 0.474, w = 0.245, h = 0.035, name = "kname", text = "Nome da pessoa procurada", type = "text", maxFontScale = 0.4},
        {x = 0.006, y = 0.51, w = 0.245, h = 0.035, name = "kdesc", text = "Motivo da procuração", type = "text", maxFontScale = 0.4},

        {x = 0.155, y = 0.023, w = 0.195, h = 0.035, name = "search2", text = "Buscar", type = "text", maxFontScale = 0.4},
    },

    [4] = { -- Veículos procurados
        {x = 0.006, y = 0.474, w = 0.12, h = 0.035, name = "kjplate", text = "Placa do veículo", type = "text", maxFontScale = 0.4},
        {x = 0.160, y = 0.474, w = 0.18, h = 0.035, name = "kjtype", text = "Tipo do veículo", type = "text", maxFontScale = 0.4},
        {x = 0.220, y = 0.51, w = 0.12, h = 0.035, name = "kjcolor", text = "Cor do veículo", type = "text", maxFontScale = 0.4},
        {x = 0.006, y = 0.51, w = 0.18, h = 0.035, name = "kjdesc", text = "Motivo da procuração", type = "text", maxFontScale = 0.4},

        {x = 0.155, y = 0.023, w = 0.195, h = 0.035, name = "search3", text = "Buscar", type = "text", maxFontScale = 0.4},
    },

    [5] = { -- Infrações / multas
        {x = 0.13, y = 0.023, w = 0.22, h = 0.035, name = "search", text = "Buscar", type = "text", maxFontScale = 0.4},

        {x = 0.006, y = 0.474, w = 0.28, h = 0.035, name = "pname", text = "Nome da infração", type = "text", maxFontScale = 0.4},
        {x = 0.006, y = 0.51, w = 0.28, h = 0.035, name = "pdesc", text = "Descrição da infração", type = "text", maxFontScale = 0.4},
        {x = 0.006, y = 0.547, w = 0.28, h = 0.035, name = "pprice", text = "Valor da multa ($)", type = "text", maxFontScale = 0.4},
    },

    [6] = { -- Contas de usuário
        {x = 0.006, y = 0.474, w = 0.365, h = 0.035, name = "u_name", text = "Nome de usuário da conta", type = "text", maxFontScale = 0.4},
        {x = 0.006, y = 0.51, w = 0.365, h = 0.035, name = "u_pass", text = "Senha da conta", type = "password", maxFontScale = 0.1},
    },

    [7] = { -- Busca no banco
        {x = 0.006, y = 0.07, w = 0.15, h = 0.035, name = "search_value", text = "Nome / placa", type = "text", maxFontScale = 0.4},
    },
}

displaySearchDatas = {
    ["veh"] = {
        {"Placa", "plateText"},
        {"Modelo", "model"},
        {"Dono", "owner"},
        {"Cor", "color"},
        {"Apreendido", "isBooked"},
        {"Procura"},
    },

    ["char"] = {
        {"Nome", "charname"},
        {"Aparência", "skin"},
        {"Emprego", "job"},
        {"Idade", "age"},
        {"Altura", "height"},
        {"Peso", "weight"},
        {"Prisão", "pdJailDatas"},
        {"Procura"},
    },
}

searchTypes = {
    ["veh"] = "Veículo",
    ["char"] = "Pessoa",
}

mdcPageDatas = {
    [1] = {posX = 0.425, posY = 0.37, width = 0.15, height = 0.195},
    [2] = {posX = 0.3, posY = 0.2, width = 0.4, height = 0.6},
    [3] = {posX = 0.3, posY = 0.2, width = 0.4, height = 0.6},
    [4] = {posX = 0.3, posY = 0.2, width = 0.4, height = 0.6},
    [5] = {posX = 0.3, posY = 0.2, width = 0.4, height = 0.6},
    [6] = {posX = 0.3, posY = 0.2, width = 0.4, height = 0.6},
    [7] = {posX = 0.3, posY = 0.2, width = 0.4, height = 0.6},
}

mdcPageNames = {
    [1] = "Login",
    [2] = "Painel",
    [3] = "Pessoas procuradas",
    [4] = "Veículos procurados",
    [5] = "Infrações",
    [6] = "Usuários",
    [7] = "Consulta",
}

penaltieFactions = {
    {"pd", "Polícia Civil do Estado de São Paulo", 14, 163, 237},
    --{"sd", "Los Santos County Shreffi's Department", 186, 158, 82},
}

penaltieLimits = {
    ["name"] = 50,
    ["desc"] = 75,
    ["kname"] = 45,
    ["kdesc"] = 120,
    ["kjtype"] = 35,
    ["kjplate"] = 7,
    ["kjcolor"] = 20,
    ["kjdesc"] = 50,
}

policePCs = {
    -- x, y, z, rot, dim, int
    {1565.9004, -1674.2, 16.24, 179.747, 0, 0},
    {1562.1, -1673.2, 16.24, 89.747, 0, 0},
    {1569.5, -1682.8, 21.4, 120, 0, 0},
    {1563, -1684.6, 21.2, 40, 0, 0},
    {1562.2, -1683.8, 21.2,239.996, 0, 0},
    {1562.3, -1685.1, 21.2, -70, 0, 0},
    {1557.8, -1683.6, 21.2, 119.988, 0, 0},
    {1557.1, -1684.7, 21.2, 319.987, 0, 0},

    {1570.7, -1670.5, 21.33, 160, 0, 0},
    {1570.4, -1672.2, 21.33, 272, 0, 0},
    {1571.9, -1675.4, 21.33, 131, 0, 0},
    
}

function comma_value(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

realSkins = getValidPedModels()

function numberToBoolean(number)
    if number == 0 then 
        return false 
    elseif number >= 1 then
        return true 
    end
end

function rgbToHex(red, green, blue, alpha)
	
	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end