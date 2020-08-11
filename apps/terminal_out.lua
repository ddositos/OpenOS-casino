local component = require("component")
local Workspace = require("dsx_workspace2")
local Element = require("dsx_element")
local sides = require("sides")

local WIDTH, HEIGHT = 50,25

local color = {
	background = 0x222222,
	foreground = 0xeeeeee,
	error = 0xdd0000
}


local me = component.me_controller
local redstone = component.redstone

for i = 0, 5 do 
	redstone.setOutput(i, 0)
end

local bus = { 
	export = {}
}

bus.export.turnOn = function()
	for i=2,5 do
		redstone.setOutput(i, 15)
	end
end
bus.export.turnOff = function()
	for i=2,5 do
		redstone.setOutput(i, 0)
	end
end

local chest = {}

chest.isEmpty = function()
	return redstone.getInput(sides.top) == 0
end


local function get_token()
	local token = ""
	local f = io.open( "/home/token" )
	token = f:read()
	f:close()
	return token
end
local db = require("dsx_db"):new( get_token() )

local currency = { name = "contenttweaker:money" }
local count_currency = function()
	local temp = me.getItemsInNetwork(currency)
	if temp.n == 0 then
		return 0
	end
	return temp[1].size
end


local action = {
	exit = 1,
	deposit = 2,
	withdraw = 3
}

local screen = {}

screen.message = function( message )
	local ws = Workspace:new(WIDTH, HEIGHT)
	ws:add(
		Element.block( 0, 0, Element.INHERIT, Element.INHERIT, color.background)
		:add(Element.text( Element.ALIGN_CENTER, Element.ALIGN_CENTER, message, color.foreground))
	)
	return ws
end

screen.loading = function()
	return screen.message("Загрузка...")
end

screen.error = function(reason)
	if reason == nil then
		reason = "Причина не указана"
	end
	local ws = Workspace:new(WIDTH, HEIGHT)
	ws:add(
		Element.block( 0, 0, Element.INHERIT, Element.INHERIT, color.background)
		:add(Element.text( Element.ALIGN_CENTER, math.floor(HEIGHT/2)-1, "Произошла ошибка", color.error))
		:add(Element.text( Element.ALIGN_CENTER, math.floor(HEIGHT/2)+1, reason, color.foreground))
	)
	return ws
end

screen.start = function()
	local ws = Workspace:new(WIDTH, HEIGHT)
	ws:add(
		Element.block( 0, 0, Element.INHERIT, Element.INHERIT, color.background,
		function(_,_,nickname)
			return nickname
		end)
		:add(Element.text(
			Element.ALIGN_CENTER, 
			Element.ALIGN_CENTER, 
			"Нажмите на экран, чтобы начать работу", 
			color.foreground
		))
	)
	return ws
end

screen.terminal = function()
	local ws = Workspace:new(WIDTH, HEIGHT)
	ws:add(
		Element.block( 0, 0, Element.INHERIT, Element.INHERIT, color.background)
		:add(Element.text( 3, 2, "Пользователь: " , color.foreground ))
		:add(Element.text( 3, 3, "Баланс: " , color.foreground))
		:add(Element.text( 3, 4, "Доступно на вывод: " , color.foreground))
		:add(
			Element.block( 3, 14, 46, 7, color.foreground, function( _, _, nickname, _, user )
				if nickname == user then
					return action.withdraw
				end
				return nil
			end)
			:add(Element.text(Element.ALIGN_CENTER, Element.ALIGN_CENTER, "Снять 16", color.background))
		)
		:add(
			Element.block(3,22, 46, 3, color.foreground, function() 
				return action.exit
			end)
			:add(Element.text(Element.ALIGN_CENTER, Element.ALIGN_CENTER, "Выйти", color.background))
		)
	)
	return ws
end

--[[
	required fields:
	- nickname
	- balance
]]--

screen.terminalOverlay = function( details )
	details.avaliable = math.floor( count_currency() / 16 ) * 16

	local ws = Workspace:new(WIDTH, HEIGHT)
	ws:add(
		Element.block( 0, 0, Element.INHERIT, Element.INHERIT, Element.TRANSPARENT)
		:add(Element.text(17, 2, details.nickname, color.foreground, color.background))
		:add(Element.text(11, 3, math.floor(details.balance), color.foreground, color.background))
		:add(Element.text(22, 4, math.floor(details.avaliable) , color.foreground, color.background))
	)
	return ws
end

------------- logic -------------

local screen__start = screen.start()
local screen__terminal = screen.terminal()
local screen__loading = screen.loading()
local screen__takeCurrency = screen.message("Заберите предметы из сундука")

while true do
	::continue::
	os.sleep(0)

	if not chest.isEmpty() then
		screen__takeCurrency:draw()
		while not chest.isEmpty() do
			os.sleep(0)
		end
		screen__terminal:draw()
	end
	
	screen__start:draw()
	local nickname = nil
	while nickname == nil do
		nickname = screen__start.buttons:pull()
	end
	screen__loading:draw()

	while true do
		os.sleep(0)
		
		if not chest.isEmpty() then
			screen__takeCurrency:draw()
			while not chest.isEmpty() do
				os.sleep(0)
			end
		end
		
		screen__terminal:draw()
		screen.terminalOverlay({
			nickname = nickname,
			balance = db:get(nickname)
		}):draw()

		local type = ws.buttons:pull(nickname)
		if type == action.exit then
			goto continue
		elseif type == action.withdraw then
			screen__loading:draw()
			os.sleep(0)
			local status = true, reason
			if not db:has(nickname, 16) then
				status = false
				reason = "У вас недостаточно средств"
			elseif count_currency() < 16 then
				status = false
				reason = "Недостаточно средств в терминале"
			end
			if status == false then
				screen.error(reason)
			else 
				bus.export.turnOn()
				os.sleep(0.4) --подогнать
				bus.export.turnOff()
				db:pay(nickname, -16)
			end
			goto continue
		end
	end
end