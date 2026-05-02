--[[
  Ordem de arranque canónica (Original Roleplay / Vale do Ipiranga RP).

  Regras desta revisão:
  - Removidas duplicações inúteis (`oNewPD`, `oBillboards`).
  - Removidos `oPlant`, `oPlaneCrash`, `gtavbahama` (não existem como recurso nesta árvore).
  - Perfis opcionais abaixo; em dúvida use `original_rp` (lista completa abaixo).
]]

ORP_ORIGINAL_RP_START_ORDER = {
	"oMysql", "oCore", "oFont", "oCompiler", "oDebug", "oLogs", "oBlur", "oBone", "oJSON",
	"oPreview", "oPreviewNew", "oStreamer", "oModelLoader", "oAnticheat", "oAnticheat2",
	"oCustomMarker", "oHandling", "pmsp", "oChat", "oSkinProtect", "oLoading", "o3DElements", "oWL",

	"npc_hlc",

	"oDestroyer", "oWater", "oMapfix", "oNewDeliMap", "oNewCityhallMap", "oHospitalNewNewMap",
	"oSampModels", "oUjsag", "oKukaMap", "oFurnitures", "oBusMap", "oIdlewoodMarket",
	"oCarshop-main", "oWellStackedMap", "oCarrentMap", "oTuningMap", "oLezarasok", "oIdlewoodMap",
	"oNewPD",

	"oAlbanian-HQ", "oLosZetasMap", "oUjszerelo", "oPiruMap", "oPD_TrainingMap",
	"oCrips_HQMap", "oPDOutsideMap", "oPDLefoglaltMap", "oPDInteriorMap", "oHospitalTexture",
	"oHospitalInteriorMap",

	"oWahChing", "oHooverHQfix",

	"oInfobox", "oRadar", "oSpeedo", "oNametag", "oInventory", "oInterface", "oHud", "oCrosshair",

	"oNoblur", "oDeath", "oAccount", "oVehicle", "oCarshop", "oNewSkinshop", "oInteriors",
	"oAdmin", "oAnims", "oDashboard", "oScoreboard", "oTips", "oJob", "oLicenses", "oCVEH",
	"oLvl", "oBus", "oShop", "oElementEditor", "oGate", "oIndex", "oTraffipax",

	"oJob_Newspaper", "oJob_Cleaner", "oJob_PizzaMaker", "oJob_FurnitureTransport", "oPlacedo",
	"oHifi", "oCasino", "oTuning", "oQuitmessage", "oFactionScripts", "oInteraction",
	"oBoneDamage", "oFishing", "oPhone", "oMarket", "oBank", "oPayday", "oSiren", "oWeaponModels",

	"oPaintjobs", "oBetterRain", "oWeaponSkill", "oPayNSpray", "oJunkyard", "oDrugs", "oMinigames",
	"oBankrob", "oVehicleRadio",

	"oJob_Cashier", "oJob_Hacker", "oTempomat", "oForestAnimals",

	"oMDC", "oFuel", "oTBoards", "oTeslaCharger", "oWeaponShop", "oDriveschool",
	"oVehicleExtras", "oTreasureHunt", "oExtraCommands",

	"oGNIproperty", "oPremium",

	"oBag",

	"oVehicleFixMarker", "oJob_Gardener", "oTakaritoNew", "oWeaponSkins", "oTeslaDriveAssist",
	"oPlazaMap",

	"oDx", "oBusinessWarhouseMap", "oPrinter", "oRope", "oTicket", "oRoulette", "oMushrooms",
	"oBankMap", "oEszakiEpitkezes", "oWeaponCraft", "oUjsagos_map", "oBlueberryKikoto",
	"oKoltoztetoMap", "oGardenerMap", "oGarageBid_map", "oGarageBid", "oBillboards", "oPet",
	"oDevtools", "oHospitalNewMap", "oCharCreateMap", "oErtekbecsloMap", "oConstructionMap1",
	"oConstructionMap2", "oShark", "oBaysideMap", "oUC_map_blueberry", "oUC_map_eastls",
	"oSormaffiaMap", "oCluckinbellMap", "oNewSzereloMap", "oInteriorBuilding",
	"oPoliceCellsInterior_MAP", "oJob_Crane", "oDilimoreGasStationMap", "oGoggle", "oMexikoHQ",
	"oBeerMaffiaInterior", "oZacskosBirtok", "oDaruparkolo",

	"trailerDepoBuild", "oParkolo", "oLCMob",

	"cigy", "oGraffiti", "oVelvettFKMap", "oNAV", "oNAVSkins",

	"oShaders", "oShader_Water", "oShader_Bloom", "oShader_Depth", "oShader_HDTextures",
	"oShader_VehicleReflection", "oShader_Palette", "oShader_MotionBlur", "oShader_Vignette",
	"oShader_Snow", "oShader_FXAA",

	"dude_telep", "dude_map", "dude_billboard",

	"serialcheck",
}

--- Recursos “opcionais” removidos no perfil `streamlined` (mapas/eventos periféricos e verificações não críticas).
ORP_STREAMLINED_EXCLUDE = {
	dude_telep = true,
	dude_map = true,
	dude_billboard = true,
	cigy = true,
	oShark = true,
	serialcheck = true,
}

function orpFilterStarterProfile(profileName, orderedList)
	local name = profileName or "original_rp"
	if name == "streamlined" then
		local filtered = {}
		for _, rw in ipairs(orderedList) do
			if not ORP_STREAMLINED_EXCLUDE[rw] then
				filtered[#filtered + 1] = rw
			end
		end
		return filtered
	end
	return orderedList
end
