local fs = require("filesystem")
local gpu = require("component").gpu
local term = require("term")
local ExceptionHandler = require("dsx_exception")
local event = require("event")


function run( app )
	local path = "/home/apps/" .. app .. ".lua"
	local app = ExceptionHandler:new(loadfile(path))

	while 1 do
		app:run()
		os.sleep(0)
	end
end

---------------

local tokenpath = "/home/token"
local autorunpath = "/home/autorun"
local token = ""

if not fs.exists(tokenpath) then
	io.write( "Введите токен: " )
	token = io.read()
	term.clear()
	f = io.open( tokenpath, "w" )
	f:write(token)
	f:close()
else 
	f = io.open( tokenpath, "r" )
	token = f:read()
	f:close()
end

if fs.exists(autorunpath) then
	f = io.open( autorunpath, "r" )
	local autorun = f:read()
	f:close()
	run(autorun)
	return 
end 

---------------

local apps = {}
local apps_assoc = {}

term.clear()
io.write("Доступные приложения:\n")
for file in fs.list('/home/apps') do
	local name = file:gsub(".lua", "")
	table.insert(apps, name)
end

table.sort(apps)

local i = 1
for j, name in pairs(apps) do
	apps_assoc[name] = j
	local color, mode = gpu.setForeground(0x00ff00)
	io.write(string.format(" [%i] ", i))
	gpu.setForeground(color, mode)
	io.write(name .. "\n")
	i = i+1
end

local color, mode = gpu.setForeground(0x00ff00)
io.write(string.format(" [%i] ", i))
gpu.setForeground(color, mode)
io.write("Перейти в терминал\n")

local id, flag = 0, nil
while 1 do
	io.write("Выберите приложение для установки: ")
	line = io.read()
	local i = 1
	for token in line:gmatch("[^%s]+") do
		if i == 1 then
			id = token
		elseif i == 2 then
			flag = token
		else 
			break
		end
		i = i + 1
	end
	
	if(apps_assoc[id] ~= nil) then
		id = apps_assoc[id]
		break
	end
	id = tonumber(id)
	if id ~= nil and 1 <= id and id <= 1+#apps then
		break
	end
	io.write(string.format("Приложение не найдено. Введите число от 1 до %i или название приложения\n", 1+#apps))
end

if id == 1+#apps then
	return 
end

if flag == "-a" then
	f = io.open( autorunpath, "w" )
	f:write(tostring(apps[id]))
	f:close()
end

run(apps[id])

