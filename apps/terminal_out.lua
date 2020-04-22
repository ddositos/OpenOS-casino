local component = require("component")
local Workspace = require("dsx_workspace")
local db = require("dsx_db"):new("pank228") --TODO: убрать

local sides = {
    bottom = 0,
    top = 1,
    back = 2,
    front =3,
    right = 4,
	left = 5,
	down = 0,
	up = 1,
	north = 2,
	south = 3,
	west = 4,
	east = 5
}

local me = component.me_interface

local redstone = component.redstone

local currency = {
	name = "minecraft:iron_ingot"
}

local function getCurrencyAmount()
	local temp = me.getItemsInNetwork(currency)
	if temp.n == 0 then
		return 0
	end
	return temp[1].size
end

local function withdraw(nickname)

	redstone.setOutput(sides.south, 13)
	os.sleep(0.4) --подогнать
	redstone.setOutput(sides.south, 0)

	db:pay(nickname, -64)
end

local function withdraw_wrapper(nickname)
	local currency = getCurrencyAmount()
	if currency < 64 then
		return false, "Недостаточно средств в банке"
	end
	if not db:has(nickname, 64) then
		return false, "У вас недостаточно средств"
	end
	withdraw(nickname)
	return true, currency
end


local action = {
	exit = 1,
	deposit = 2,
	withdraw = 3
}

local function screen1()
	local ws = Workspace:new(50,25)
	ws:bind(1,1,50,25, 0x222222, function(_,_,nickname)
		return nickname
	end)
	ws:text(7, 13, "Нажмите на экран, чтобы начать работу", 0x222222, 0xeeeeee)
	return ws
end

local function screen2(nickname)
	local ws = Workspace:new(50,25)
	ws:bind(1,1,50,25, 0x222222)
	ws:text(3,2, "Пользователь: " .. nickname, 0x222222, 0xeeeeee)
	ws:text(3,3, "Баланс: " , 0x222222, 0xeeeeee)
	ws:text(3,4, "Доступно на вывод: " , 0x222222, 0xeeeeee)
	ws:bind(3,14,46,7,0xeeeeee, function(x,y,nickname,user)
		if nickname == user then
			return action.withdraw
		end
		return nil
	end)
	ws:text(21,17,"Снять 64", 0xeeeeee, 0x222222)
	ws:bind(3,22, 46, 3, 0xeeeeee, function() 
		return action.exit
	end)
	ws:text(23,23,"Выйти", 0xeeeeee, 0x222222)
	return ws
end

local function screenError(reason)
	local ws = Workspace:new(50,25)
	ws:bind(1,1,50,25, 0x222222, function(x,y,nickname, user)
		return true
	end)
	ws:text(15, 12, reason, 0x222222, 0xeeeeee)
	return ws
end

local function drawCurrency()
	local amount = getCurrencyAmount()
	local ws = Workspace:new()
	ws:bind(22,4, 20, 1, 0x222222)
	ws:text(22,4, tostring(math.floor(amount)) .. " слитков" , 0x222222, 0xeeeeee)
	ws:draw()
end

local function loadingscreen()
	local ws = Workspace:new(50,25)
	ws:bind(1,1,50,25, 0x222222)
	ws:text(20, 12, "Загрузка...", 0x222222, 0xeeeeee)
	return ws
end

local function screenTakeIron()
	local ws = Workspace:new(50,25)
	ws:bind(1,1,50,25, 0x222222)
	ws:text(18, 12, "Заберите железо", 0x222222, 0xeeeeee)
	ws:draw()
end


local function logic3(status, reason, nickname) --ошибка
	if status == false then --ошибка
		local ws = screenError(reason)
		ws:draw()
		while not ws.buttons:pull(nickname) do
			os.sleep(0)
		end
	end
end

local function checkIron()
	if redstone.getInput(sides.west) ~= 0 then
		screenTakeIron()
		while redstone.getInput(sides.west) ~= 0 do
			os.sleep(0)
		end
	end
end

local function logic2(nickname) --основное меню
	local ws = screen2(nickname)
	local ws_loading = loadingscreen()
	ws_loading:draw()
	os.sleep(0)
	local balance = db:get(nickname)
	ws:text(11,3, tostring(balance), 0x222222, 0xeeeeee)
	ws:draw()
	while 1 do
		checkIron()
		drawCurrency()
		local type = ws.buttons:pull(nickname)
		if type == action.exit then
			return true -- logic 1
		elseif type == action.withdraw then
			ws_loading:draw()
			os.sleep(0)
			local status, reason = withdraw_wrapper(nickname)
			logic3(status, reason, nickname)
			return false
		end
		
	end
end

local function logic1() --экран "начать"
	local ws = screen1()
	ws:draw()
	local nickname = nil
	while nickname == nil do
		nickname = ws.buttons:pull()
	end
	while not logic2(nickname) do
		os.sleep(0)
	end
end



while true do
	logic1()
	os.sleep(0)
end


