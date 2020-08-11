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
	import = {},
	export = {}
}

bus.import.turnOn = function()
	redstone.setOutput(sides.top, 15)
end
bus.import.turnOff = function()
	redstone.setOutput(sides.top, 0)
end

bus.export.turnOn = function()
	redstone.setOutput(sides.bottom, 15)
end
bus.export.turnOff = function()
	redstone.setOutput(sides.bottom, 0)
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
	deposit = 2
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
		:add(Element.text( 3, 4, "Внесено: " , color.foreground))
		:add(Element.text( 3, 5, "Пополнение: " , color.foreground))
		:add(Element.text( 3, 6, "Комиссия: " , color.foreground))
		:add(
			Element.block( 3, 14, 46, 7, color.foreground, function(_,_,nickname,_,user)
				if nickname == user then
					return action.deposit
				end
				return nil
			end)
			:add(Element.text(Element.ALIGN_CENTER, 17, "Пополнить", color.background))
			:add(Element.text(Element.ALIGN_CENTER, 18, "Комиссия 5%", color.background))
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
	- introduced
]]--

screen.terminalOverlay = function( details )
	details.comission = math.ceil(details.introduced * 0.05)
	details.replenishment = details.introduced - details.comission

	local ws = Workspace:new(WIDTH, HEIGHT)
	ws:add(
		Element.block( 0, 0, Element.INHERIT, Element.INHERIT, Element.TRANSPARENT)
		:add(Element.text(17, 2, details.nickname, color.foreground, color.background))
		:add(Element.text(11, 3, math.floor(details.balance), color.foreground, color.background))
		:add(Element.text(12, 4, math.floor(details.introduced), color.foreground, color.background))
		:add(Element.text(15, 5, math.floor(details.replenishment), color.foreground, color.background))
		:add(Element.text(13, 6, math.floor(details.comission), color.foreground, color.background))
	)
	return ws
end


------------- logic -------------

local screen__start = screen.start()
local screen__terminal = screen.terminal()
while true do
	::continue::
	bus.import.turnOff()
	screen__start:draw()
	local nickname = nil
	while nickname == nil do
		nickname = screen__start.buttons:pull()
	end
	
	screen__terminal:draw()
	bus.import.turnOn()

	local time = os.time()
	while true do
		local currency_amount = count_currency()
		screen.terminalOverlay({
			nickname = nickname,
			balance = db:get(nickname), 
			introduced = currency_amount
		}):draw()
		if os.time() - time > 1000 and currency_amount == 0 then
			goto continue
		end

		local type = screen__terminal.buttons:pull(nickname)
		if type == action.exit then
			goto continue
		elseif type == action.deposit then
			if currency_amount ~= 0 then
				screen.loading():draw()
				bus.import.turnOff()
				os.sleep(0)
				db:pay(nickname, math.floor(currency_amount*0.95))
				screen.message("Инкассаторы перевозят валюту..."):draw()
				bus.export.turnOn()
				while count_currency() ~= 0 do
					os.sleep(0)
				end
				bus.export.turnOff()
				goto continue
			end
		end
		os.sleep(0)
	end
	os.sleep(0)
end