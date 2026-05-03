adminCMD = {
    {command = 'fixcharger', permission = 2, shortDescription = 'Atualizar/colocar Tesla em estado correto'},
    {command = 'jailed', permission = 2, shortDescription = 'Listar jogadores na prisão (jail)'},
    {command = 'warn', permission = 2, shortDescription = 'Distribuir alerta de arma premium'},
    {command = 'fixveh', permission = 2, shortDescription = 'Reparar veículo'},
    {command = 'unflip', permission = 2, shortDescription = 'Desvirar veículo'},
    {command = 'setskin', permission = 2, shortDescription = 'Alterar skin do jogador'},
    {command = 'setarmor', permission = 2, shortDescription = 'Alterar colete do jogador'},
    {command = 'sethp', permission = 2, shortDescription = 'Alterar vida do jogador'},
    {command = 'setdrunken', permission = 2, shortDescription = 'Alterar nível de álcool do jogador'},
    {command = 'sethunger', permission = 2, shortDescription = 'Alterar fome do jogador'},
    {command = 'setthirst', permission = 2, shortDescription = 'Alterar sede do jogador'},
    {command = 'givemoney', permission = 7, shortDescription = 'Dar dinheiro a um jogador'},
    {command = 'setmoney', permission = 7, shortDescription = 'Definir dinheiro do jogador'},
    {command = 'setpp', permission = 8, shortDescription = 'Definir pontos premium do jogador'},
    {command = 'givepp', permission = 8, shortDescription = 'Dar pontos premium a um jogador'},
    {command = 'goto', permission = 2, shortDescription = 'Teleportar até um jogador'},
    {command = 'vhspawn', permission = 2, shortDescription = 'Teleportar jogador para spawn da prefeitura'},
    {command = 'gethere', permission = 2, shortDescription = 'Trazer jogador até ti'},
    {command = 'setadminnick', permission = 7, shortDescription = 'Alterar apelido de admin'},
    {command = 'aduty', permission = 2, shortDescription = 'Entrar/sair de serviço admin'},
    {command = 'adminhub', permission = 2, shortDescription = 'Abrir painel Admin Hub (economia, CC, PP, itens)'},
    {command = 'setadminlevel', permission = 7, shortDescription = 'Definir nível de administrador'},

    {command = 'findchar', permission = 2, shortDescription = 'Procurar nome do personagem pelo Char ID'},
    {command = 'findid', permission = 2, shortDescription = 'Procurar Char ID pelo nome do personagem'},
    {command = 'vanish', permission = 2, shortDescription = 'Modo invisível'},
    {command = 'kick', permission = 2, shortDescription = 'Expulsar jogador'},
    {command = 'freeze', permission = 2, shortDescription = 'Congelar jogador'},
    {command = 'unfreeze', permission = 2, shortDescription = 'Descongelar jogador'},
    {command = 'recon', permission = 1, shortDescription = 'Observar jogador'},
    {command = 'slap', permission = 2, shortDescription = 'Dar tapa/jogar jogador para cima'},
    {command = 'showpms', permission = 6, shortDescription = 'Ver PMs'},
    {command = 'ajail', permission = 2, shortDescription = 'Prender jogador (admin jail)'},
    {command = 'unjail', permission = 2, shortDescription = 'Soltar jogador da prisão'},
    {command = 'aban', permission = 3, shortDescription = 'Banir jogador'},
    {command = 'oban', permission = 4, shortDescription = 'Banir jogador (offline)'},
    {command = 'aunban', permission = 3, shortDescription = 'Remover ban de jogador'},
    {command = 'setint', permission = 5, shortDescription = 'Definir interior do jogador'},
    {command = 'setdim', permission = 5, shortDescription = 'Definir dimensão do jogador'},

    {command = 'removefactionmoney', permission = 7, shortDescription = 'Retirar dinheiro da facção'},
    {command = 'givefactionmoney', permission = 7, shortDescription = 'Dar dinheiro à facção'},
    {command = 'setfactionleader', permission = 7, shortDescription = 'Dar cargo de líder na facção'},
    {command = 'listfactionids', permission = 7, shortDescription = 'Listar IDs e nomes das facções no chat'},
    {command = 'removeplayerfromallfaction', permission = 6, shortDescription = 'Remover jogador de todas as facções'},
    {command = 'removeplayerfromfaction', permission = 6, shortDescription = 'Remover jogador de uma facção'},
    {command = 'getplayerfactions', permission = 4, shortDescription = 'Ver facções do jogador'},
    {command = 'setplayerfaction', permission = 6, shortDescription = 'Colocar jogador numa facção'},

    {command = 'fixbones', permission = 2, shortDescription = 'Curar ossos/lesões do jogador'},
    
    {command = 'ojail', permission = 3, shortDescription = 'Prender jogador (offline jail)'},
    {command = 'showmydatas', permission = 2, shortDescription = 'Ver tuas próprias estatísticas de admin'},
    {command = 'showadminstats', permission = 8, shortDescription = 'Ver estatísticas de todos os admins'},
    {command = 'clearadminstats', permission = 8, shortDescription = 'Limpar estatísticas de admins'},
    {command = 'showplayers', permission = 2, shortDescription = 'Ver jogadores no mapa'},
    {command = 'togalogs', permission = 2, shortDescription = 'Ligar/desligar logs admin no chat'},
    {command = 'setplayername', permission = 4, shortDescription = 'Alterar nome do personagem'},
    {command = 'setaccountstate', permission = 7, shortDescription = 'Alterar estado da conta do jogador'},

    {command = 'gotopoint', permission = 2, shortDescription = 'Teleportar para checkpoint'},
    {command = 'mypoints', permission = 2, shortDescription = 'Listar os teus checkpoints'},
    {command = 'delpoint', permission = 2, shortDescription = 'Apagar um checkpoint teu'},
    {command = 'addpoint', permission = 2, shortDescription = 'Criar checkpoint'},

    {command = 'fly', permission = 2, shortDescription = 'Ativar/desativar voo admin'},

    {command = 'playerlogs', permission = 8, shortDescription = 'Logs dos jogadores'},
    {command = 'bugreports', permission = 8, shortDescription = 'Relatórios de bugs'},
    {command = 'debuginventory', permission = 8, shortDescription = 'Verificar itens bugados no inventário'},
    {command = 'takeitem', permission = 5, shortDescription = 'Retirar item de um jogador'},
    {command = 'giveitem', permission = 7, shortDescription = 'Dar item a um jogador'},
    {command = 'givelicense', permission = 5, shortDescription = 'Dar documento/licença'},
    {command = 'changelock', permission = 7, shortDescription = 'Trocar tranca/fechadura'},
    {command = 'warn', permission = 7, shortDescription = 'Alerta relacionado a armas'},
    {command = 'playerstats', permission = 2, shortDescription = 'Ver estatísticas do jogador'},

    {command = 'sgoto', permission = 8, shortDescription = 'Goto stealth (não aparece nos logs habituais)'},
    {command = 'srecon', permission = 8, shortDescription = 'Recon stealth (não aparece nos logs habituais)'},

    {command = 'delroulette', permission = 9, shortDescription = 'Apagar mesa de roleta'},
    {command = 'createroulette', permission = 9, shortDescription = 'Criar mesa de roleta'},
    {command = 'nearbyroulette', permission = 9, shortDescription = 'Roletas perto de ti'},

    {command = 'givelincese', permission = 7, shortDescription = 'Dar licença/documento ao jogador (var.)'},
    {command = 'hideadmin', permission = 7, shortDescription = 'Admin oculto'},
    {command = 'sethelper', permission = 6, shortDescription = 'Dar helper/admin auxiliar temporário'},

    {command = 'setvehoil', permission = 2, shortDescription = 'Definir nível de óleo do veículo'},

    {command = 'resetbank', permission = 7, shortDescription = 'Reset ao banco (sirene, cofre fechado)'},
    {command = 'nearbygates', permission = 7, shortDescription = 'Listar portões perto'},
    {command = 'nearbysafe', permission = 3, shortDescription = 'Listar cofres perto'},
    {command = 'nearbyvehicles', permission = 3, shortDescription = 'Listar veículos perto'},
    {command = 'asay', permission = 2, shortDescription = 'Anúncio/mensagem de admin'},
    {command = 'showinv', permission = 2, shortDescription = 'Ver inventário e dinheiro do jogador'},
    {command = 'createinterior', permission = 7, shortDescription = 'Criar interior'},
    {command = 'makeveh', permission = 7, shortDescription = 'Criar veículo'},
    {command = 'anames', permission = 2, shortDescription = 'Mostrar nomes, vida e colete sobre jogadores'},

    {command = 'addcarshopmarker', permission = 7, shortDescription = 'Adicionar marker de stand de carros usados'},
    {command = 'deletecarshopmarker', permission = 7, shortDescription = 'Remover marker de stand de carros'},
    {command = 'setplayercarshop', permission = 7, shortDescription = 'Associar jogador ao stand de usados'},
    {command = 'createcarshop', permission = 9, shortDescription = 'Criar stand de carros usados'},
    {command = 'createlottofive', permission = 9, shortDescription = 'Criar ponto/evento Lotto Five'},
    {command = 'addweaponship', permission = 7, shortDescription = 'Iniciar evento/navio de armas'},
    {command = 'makepet', permission = 7, shortDescription = 'Criar animal de estimação'},
    {command = 'delpet', permission = 7, shortDescription = 'Apagar pet'},
    {command = 'changepetname', permission = 6, shortDescription = 'Renomear pet'},
    {command = 'rehealpet', permission = 6, shortDescription = 'Reviver/curar pet'},
    
    {command = 'setcontainerplantstate', permission = 7, shortDescription = 'Estado das plantas no contentor'},
    {command = 'setcontainerplantgrow', permission = 7, shortDescription = 'Crescimento das plantas no contentor'},
    {command = 'weedplantcontainer', permission = 10, shortDescription = 'Plantar no contentor (weed)'},
    {command = 'setcontainerfanstate', permission = 7, shortDescription = 'Estado dos ventiladores no contentor'},
    {command = 'verifyplayer', permission = 7, shortDescription = 'Marcar jogador como verificado (admin confiável)'},
    {command = 'removeplayerverify', permission = 7, shortDescription = 'Remover verificação do jogador'},
    {command = 'getplayerserial', permission = 7, shortDescription = 'Obter serial MTA do jogador'},
}

--- silentIfDenied: true = não enviar outputChatBox (ex.: hub que já devolve mensagem ao cliente)
function hasPermission(element, permission, silentIfDenied)
    if silentIfDenied == nil then silentIfDenied = false end

    local function notify(msg)
        if silentIfDenied then return end
        if not isElement(element) or getElementType(element) ~= "player" then return end
        local ok, prefix = pcall(function()
            return exports.oCore:getServerPrefix("red-dark", "Admin", 3)
        end)
        if ok and prefix then
            outputChatBox(prefix .. msg, element, 255, 255, 255, true)
        end
    end

    local function isDev()
        if localPlayer then
            return getElementData(element, "aclLogin") == true
        end
        return adminSerialsCache[getPlayerSerial(element)] ~= nil
    end

    local level = getElementData(element, "user:admin") or 0

    if level > 1 then
        for _, o in ipairs(adminCMD) do
            if o.command == permission then
                if o.permission <= level then
                    return true
                elseif isDev() then
                    return true
                else
                    notify("Comando /" .. tostring(permission) .. ": requer nível admin " .. o.permission .. " (o teu nível: " .. level .. ").")
                    return false
                end
            end
        end
        notify("Permissão '" .. tostring(permission) .. "' não está registada no oAdmin (adminCMD).")
        return false
    elseif isDev() then
        return true
    else
        notify("Sem acesso a comandos admin (nível " .. level .. "). Contas developer (ACL) mantêm acesso.")
        return false
    end
end
