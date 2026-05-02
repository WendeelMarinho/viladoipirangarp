local resources = {}
local lastResource = 0

function SetCacheSettingsResource(res)
    local xmlPatch = ":"..res.."/meta.xml"
    local xmlFile = xmlLoadFile(xmlPatch)
    if xmlFile then
        outputDebugString("RESOURCE: "..res,0,55,167,220)
        local index = 0
		local scriptNode = xmlFindChild(xmlFile,'script',index)
        if scriptNode then
            repeat
            local scriptPath = xmlNodeGetAttribute(scriptNode,'src') or false
            local scriptType = xmlNodeGetAttribute(scriptNode,'type') or "server"
            local serverEncypt = xmlNodeGetAttribute(scriptNode,'cache') or "true"
            if scriptPath and (scriptType:lower() == "client" or serverEncypt:lower() == "false" or scriptType:lower() == "shared") then
                if string.find(serverEncypt:lower(), "false") then
                    local FROM=":"..res.."/"..scriptPath
                    outputDebugString("[Cache] Script já está ofuscado (".. FROM ..")",3,0,255,0)
                else
                    xmlNodeSetAttribute(scriptNode, "cache", "false")
                    local FROM=":"..res.."/"..scriptPath
                    outputDebugString("[Cache] Ofuscação concluída (".. FROM ..")",3,0,255,0)
                end

            end
            index = index + 1
			scriptNode = xmlFindChild(xmlFile,'script',index)
            until not scriptNode
        end
        xmlSaveFile(xmlFile)
		xmlUnloadFile(xmlFile)
    else
		outputDebugString("[Cache] Ofuscar: meta.xml ilegível ou ausente.",3,220,20,20)
		return false
    end
end

addCommandHandler("cachesetall", function(player,cmd,res)
    if getElementData(player, "user:admin") >= 10 then
        resources = getResources()
        lastResource = 0
        SetCacheSettingsNextResource()
    end
end)

addCommandHandler("cacheset", function(player,cmd,res)
    if getElementData(player, "user:admin") >= 10 then
        if not res then 
            outputChatBox(exports["oCore"]:getServerPrefix("red-dark", "Vale do Ipiranga RP", 3) .. " Uso: /"..cmd.." [NomeDoResource]",player, 255, 255, 255, true)
        else
            local resource = getResourceFromName(res)
            if resource then
                SetCacheSettingsResource(getResourceName(resource))
            end
        end
    end
end)

function SetCacheSettingsNextResource()
	if lastResource < #resources then
		lastResource = lastResource + 1
		SetCacheSettingsResource(getResourceName(resources[lastResource]))
		setTimer(SetCacheSettingsNextResource, 1000, 1)
	end
end

