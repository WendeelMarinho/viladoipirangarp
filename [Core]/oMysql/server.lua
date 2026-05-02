local serverDatabase
local logsDatabase 

addEventHandler("onResourceStart", getResourceRootElement(),
	function ()
		serverDatabase = dbConnect("mysql", "dbname=orp_main;host=127.0.0.1;charset=utf8", "ipirangaroleplay", "Singularity123@", "multi_statements=1")
		logsDatabase = dbConnect("mysql", "dbname=orp_main;host=127.0.0.1;charset=utf8", "ipirangaroleplay", "Singularity123@", "multi_statements=1")
		
		if not serverDatabase then
			outputServerLog("[MySQL]: Failed to connect the database.")
			outputDebugString("[MySQL]: Falha ao conectar ao banco de dados principal.", 1)
			cancelEvent()
		else
			dbExec(serverDatabase, "SET NAMES utf8")
			outputDebugString("[MySQL]: Conexão com o banco principal OK.")
		end

		if not logsDatabase then
			outputServerLog("[MySQL]: Failed to connect the LOGS database.")
			outputDebugString("[MySQL]: Falha ao conectar ao banco de LOGS.", 1)
		else
			dbExec(logsDatabase, "SET NAMES utf8")
			outputDebugString("[MySQL]: Conexão com o banco de LOGS OK.")
		end
	end
)

function getDBConnection()
	return serverDatabase
end

function getLogsDBConnection()
	return logsDatabase
end
