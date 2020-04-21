local fs = require("filesystem")
local gpu = require("component").gpu

local apps = {}
local apps_assoc = {}
local i = 1;
io.write("Доступные приложения:\n")
for file in fs.list('/home/apps') do
	table.insert(apps, file)
	local assoc = file:gsub(".lua", "")
	apps_assoc[assoc] = i
	local color, mode = gpu.setForeground(0x00ff00)
	io.write(string.format(" [%i] ", i))
	gpu.setForeground(color, mode)
	io.write(assoc .. "\n")
	i = i+1 
end

local id = 0
while 1 do
	io.write("Выберите приложение для установки: ")
	id = io.read()
	if(apps_assoc[id] ~= nil) then
		id = apps_assoc[id]
		break
	end
	id = tonumber(id)
	if id ~= nil and 1 <= id and id <= #apps then
		break
	end
	io.write(string.format("Приложение не найдено. Введите число от 1 до %i или название приложения\n", #apps))
end

--io.write(string.format("Выбрано приложение %s.\nНажмите enter для запуска.", apps[id]:gsub(".lua", "")))
--io.read()




