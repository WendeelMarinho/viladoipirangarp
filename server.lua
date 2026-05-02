outputServerLog("[Vila RP] Iniciando servidor...")

addEventHandler("onResourceStart", resourceRoot, function()
    outputServerLog("[Vila RP] Resource iniciado com sucesso")

    local starter = getResourceFromName("oStarter")
    if starter then
        if startResource(starter) then
            outputServerLog("[Vila RP] oStarter iniciado com sucesso.")
        else
            outputServerLog("[Vila RP] ERRO CRITICO: oStarter falhou ao iniciar!")
        end
    else
        outputServerLog("[Vila RP] ERRO CRITICO: oStarter nao encontrado! Verifique a pasta [Core]/oStarter/")
    end
end)