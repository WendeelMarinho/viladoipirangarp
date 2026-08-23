local db = exports.oMysql:getLogsDBConnection()

local function ensureLogTables()
	if not db or db == false then
		outputDebugString("[oLogs] Base de logs indisponível — tabelas não criadas.", 2)
		return
	end
	--[[ Colunas alinhadas com os INSERT deste recurso (DB de logs, ex. orp_logs). ]]
	dbExec(db, [[
CREATE TABLE IF NOT EXISTS admincmd (
	id INT AUTO_INCREMENT PRIMARY KEY,
	source VARCHAR(64) NOT NULL DEFAULT '',
	player VARCHAR(64) NOT NULL DEFAULT '',
	cmd VARCHAR(255) NOT NULL DEFAULT '',
	date VARCHAR(32) NOT NULL DEFAULT '',
	KEY idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
	dbExec(db, [[
CREATE TABLE IF NOT EXISTS money (
	id INT AUTO_INCREMENT PRIMARY KEY,
	source VARCHAR(64) NOT NULL DEFAULT '',
	destination VARCHAR(64) NOT NULL DEFAULT '',
	amount INT NOT NULL DEFAULT 0,
	date VARCHAR(32) NOT NULL DEFAULT '',
	KEY idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
	dbExec(db, [[
CREATE TABLE IF NOT EXISTS bank (
	id INT AUTO_INCREMENT PRIMARY KEY,
	source VARCHAR(64) NOT NULL DEFAULT '',
	amount INT NOT NULL DEFAULT 0,
	type VARCHAR(32) NOT NULL DEFAULT '',
	date VARCHAR(32) NOT NULL DEFAULT '',
	KEY idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
	dbExec(db, [[
CREATE TABLE IF NOT EXISTS vehicle (
	id INT AUTO_INCREMENT PRIMARY KEY,
	source VARCHAR(64) NOT NULL DEFAULT '',
	destination VARCHAR(64) NOT NULL DEFAULT '',
	vehid INT NOT NULL DEFAULT 0,
	price INT NOT NULL DEFAULT 0,
	date VARCHAR(32) NOT NULL DEFAULT '',
	KEY idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
	dbExec(db, [[
CREATE TABLE IF NOT EXISTS carshop (
	id INT AUTO_INCREMENT PRIMARY KEY,
	source VARCHAR(64) NOT NULL DEFAULT '',
	vehid INT NOT NULL DEFAULT 0,
	date VARCHAR(32) NOT NULL DEFAULT '',
	KEY idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
end

addEventHandler("onResourceStart", resourceRoot, function()
	ensureLogTables()
end)

addEvent("sendPlayerLogs", true)
addEventHandler("sendPlayerLogs", getRootElement(), function(type, data)
	if not db or db == false then return end
	if type == "money" then
		dbExec(db, "INSERT INTO money (source, destination, amount, date) VALUES (?,?,?,?)", data[1], data[2], data[3], data[4])
	elseif type == "bank" then
		dbExec(db, "INSERT INTO bank (source, amount, type, date) VALUES (?,?,?,?)", data[1], data[2], data[3], data[4])
	elseif type == "vehicle" then
		dbExec(db, "INSERT INTO vehicle (source, destination, vehid, price, date) VALUES (?,?,?,?,?)", data[1], data[2], data[3], data[4], data[5])
	elseif type == "carshop" then
		dbExec(db, "INSERT INTO carshop (source, vehid, date) VALUES (?,?,?)", data[1], data[2], data[3])
	elseif type == "admincmd" then
		dbExec(db, "INSERT INTO admincmd (source, player, cmd, date) VALUES (?,?,?,?)", data[1], data[2], data[3], data[4])
	end
end)
