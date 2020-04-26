local component = require("component")
local Workspace = require("dsx_workspace")

local function get_token()
	local token = ""
	local f = io.open( "/home/token" )
	token = f:read()
	f:close()
	return token
end

local db = require("dsx_db"):new(get_token()) --TODO: убрать


local function screen1()
	local ws = Workspace:new(50,25)
	ws:bind(1,1,50,25, 0x222222, function(_,_,nickname)
		return nickname
	end)
	ws:text(7, 13, "Нажмите на экран, чтобы узнать баланс", 0x222222, 0xeeeeee)
	return ws
end

local function screen2(nickname, balance)
	local ws = Workspace:new(50,25)
	ws:bind(1,1,50,25, 0x222222, function()
		return true
	end)
	ws:text(6,12, "Пользователь: " .. nickname, 0x222222, 0xeeeeee)
	ws:text(6,13, "Баланс: " .. balance , 0x222222, 0xeeeeee)
	return ws
end

local function loadingscreen()
	local ws = Workspace:new(50,25)
	ws:bind(1,1,50,25, 0x222222)
	ws:text(20, 12, "Загрузка...", 0x222222, 0xeeeeee)
	return ws
end


local function logic2(nickname) --основное меню
	
	local ws_loading = loadingscreen()
	ws_loading:draw()
	os.sleep(0)
	local balance = db:get(nickname)
	local ws = screen2(nickname, balance)
	ws:draw()
	local time = os.time()
	while not ws.buttons:pull() do
		if os.time() - time  > 800 then
			break;
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
	logic2(nickname)
end



while true do
	logic1()
	os.sleep(0)
end


