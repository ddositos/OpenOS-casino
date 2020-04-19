local component = require("component")
if not component.isAvailable("internet") then
    io.stderr:write("An internet card is required!")
    return
end
local computer = require("computer")
local shell = require("shell")

local CONFIG = {
	name = "dsx-casino"
}

local modules = {
	"db", "request"
}

local github = "https://raw.githubusercontent.com/ddositos/OpenOS-casino/"


local function writeToFile(path, content)
    local file = io.open(path, "w")
    file:write(content)
    file:close()
end

local function save_modules()
	print("Загрузка модулей")
	for module in modules do 
		print("Загрузка модуля " .. module)
		shell.execute(string.format(
			"wget -fq %s/modules/dsx_%s.lua /lib/dsx_%s.lua",
			github,
			module,
			module
		))
	end
    print("Модули загружены")
end


local function deploy()
    print(string.format("Установка \"%s\"", CONFIG.name))
    save_modules()
    print('Application successfully deployed.')
end

print("dsx-casino Deployer 0.1\n")
deploy()
print("Press ENTER to restart...")
io.read()
shell.execute("reboot")