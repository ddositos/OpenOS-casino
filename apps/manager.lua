local function get_token()
	local token = ""
	local f = io.open( "/home/token" )
	token = f:read()
	f:close()
	return token
end

local db = require("dsx_db"):new(get_token())
local com = require("component")
local gpu = com.gpu
local term = require("term")
local Workspace = require("dsx_workspace")

local function clear()
	local ws = Workspace:new(160,50)
	ws:bind(1,1,160,50, 0x222222)
	ws:draw()
end

clear()

local comands = {}

local function register_comand(alias, argc, help, callback)
	comands[alias] = {
		argc = argc,
		help = help,
		callback = callback
	}
end

local function invoke_comand(alias, args)
	local comand = comands[alias]
	if comand == nil then
		return string.format("Команда %s не найдена. Напишите help для справки", alias)
	end
	if #args < comand.argc then
		return string.format("Команда %s требует %i аргумента. Напишите help %s для справки", alias, comand.argc, alias)
	end
	return comand.callback(table.unpack(args))
end

register_comand("help", 0, 
	"Выводит справку о команде\nhelp <comand:string>", 
	function(comand)
		if comand == nil then
			for alias, value in pairs(comands) do
				io.write(string.format("%s %s\n", alias, value.help))
			end
			return ""
		end
		if comands[comand] == nil then
			return string.format("Команда %s не найдена", comand)
		end
		return comands[comand].help
	end)

register_comand("top", 0,
	"Выводит 5 игроков с наибольшим балансом",
	function()
		return db:top()
	end)

register_comand("close", 0, 
	"Закрывает программу",
	function()
		os.exit()
		return ""
	end)

register_comand("get", 1,
	"Получить баланс игрока\nget <nickname:string>",
	function(nickname)
		return tostring(db:get(nickname)) .. " эм"
	end)

register_comand("pay", 2, 
	"Изменить баланс игрока на определенную сумму\npay <nickname:string> <delta:int>",
	function(nickname, delta)
		db:pay(nickname, delta)
		return "установлено"
	end)

register_comand("set", 2,
	"Установить баланс игрока\nset <nickname:string> <balance:int>",
	function(nickname, balance)
		db:set(nickname, balance)
		return "установлено"
	end)

register_comand("delete", 1,
	"Удалить игрока из базы данных\ndelete <nickname:string>", 
	function(nickname)
		db:delete(nickname)
		return "удалено"
	end)

register_comand("has", 2,
	"Проверяет, есть ли заданная сумма на балансе игрока\nhas <nickname:string> <balance:int>",
	function(nickname, balance)
		return tostring(db:has(nickname, tonumber(balance)))
	end)

while true do
	gpu.setForeground(0x00ff00)
	io.write("> ")
	gpu.setForeground(0xffffff)
	local line = tostring(io.read())
	
	local q = nil
	local args = {}

	for word in string.gmatch(line, "[^%s]+") do
		if q == nil then
			q = word
		else 
			table.insert(args, word)
		end
	end
	
	if q ~= nil then
		io.write( " " .. invoke_comand( q, args ) .. "\n" )
	end
end