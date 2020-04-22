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
redstone.setOutput(sides.north, 0)

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


local action = {
	exit = 1,
	deposit = 2
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
	ws:text(3,4, "В системе: " , 0x222222, 0xeeeeee)
	ws:text(3,5, "Пополнение: " , 0x222222, 0xeeeeee)
	ws:text(3,6, "Комиссия: " , 0x222222, 0xeeeeee)
	ws:bind(3,14,46,7,0xeeeeee, function(x,y,nickname,user)
		if nickname == user then
			return action.deposit
		end
		return nil
	end)
	ws:text(21,17,"Пополнить", 0xeeeeee, 0x222222)
	ws:text(20,18,"Комиссия 5%", 0xeeeeee, 0x222222)
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
	ws:text(13, 12, reason, 0x222222, 0xeeeeee)
	return ws
end

local function drawCurrency()
	local amount = math.floor(getCurrencyAmount())
	local deposit = math.floor(amount * 0.95)
	local comission = amount - deposit
	local ws = Workspace:new()
	ws:bind(14,4, 30, 1, 0x222222)
	ws:bind(15,5, 30, 1, 0x222222)
	ws:bind(13,6, 30, 1, 0x222222)
	ws:text(14,4, amount .." коинов" , 0x222222, 0xeeeeee)
	ws:text(15,5, deposit .. " коинов" , 0x222222, 0xeeeeee)
	ws:text(13,6, comission .. " коинов" , 0x222222, 0xeeeeee)
	ws:draw()
end

local function loadingscreen()
	local ws = Workspace:new(50,25)
	ws:bind(1,1,50,25, 0x222222)
	ws:text(20, 12, "Загрузка...", 0x222222, 0xeeeeee)
	return ws
end

local function waitForTransfer()
	redstone.setOutput(sides.north, 13)
	while getCurrencyAmount() ~= 0 do
		os.sleep(0)
	end
	redstone.setOutput(sides.north, 0)
end

local function screenWait()
	local ws = Workspace:new()
	ws:bind(1,1,50,25, 0x222222)
	ws:text(16, 12, "Загрузка валюты...", 0x222222, 0xeeeeee)
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

		drawCurrency()
		local type = ws.buttons:pull(nickname)
		if type == action.exit then
			return true -- logic 1
		elseif type == action.deposit then
			ws_loading:draw()
			os.sleep(0)
			local currency = getCurrencyAmount()
			db:pay(nickname, currency)
			screenWait()
			waitForTransfer()
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


