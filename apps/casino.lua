local component = require("component")
local Workspace = require("dsx_workspace")
local gpu = require("component").gpu

local db = require("dsx_db"):new("pank228")

local mouse = {
	left = 0,
	right = 1
}

local chat = component.chat_box

chat.setName("§5Рулетка§7§o")
chat.setDistance(7)

local function say(str)
	str = "§e" .. str
	if not chat then
		gpu.fill(1,1,50,1, ' ')
		gpu.set(1,1, tostring(str))
		return 
	end
	chat.say(str)
end

local WIDTH = 107
local HEIGHT = 23

local colors = {'r','b','r','b','r','b','r','b','r','b','b','r','b','r','b','r','b','r','r','b','r','b','r','b','r','b','r','b','b','r','b','r','b','r','b','r'}
colors[0] = 'g'
local wheel = {34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26,0,32,15,19,4,21,2,25,17}
local wheel_index = {29,15,35,27,33,11,2,23,8,19,10,6,25,4,17,31,13,37,21,32,16,34,20,9,12,36,28,3,24,22,7,18,30,14,1,26,5}
local order = {3,6,9,12,15,18,21,24,27,30,33,36,2,5,8,11,14,17,20,23,26,29,32,35,1,4,7,10,13,16,19,22,25,28,31,34}

local function get_color(num)
	local color = colors[num]
	if color == 'g' then
		return 0x00ee00
	elseif color == 'r' then
		return 0xdd0000
	else
		return 0x000000
	end
end

local function label(id)
	id = math.floor( id )
	if id == 0 then
		return "§a0§e"
	end
	if  1 <= id and id <= 36 then
		return (colors[id] == 'r' and "§c" or "§0") .. id .. "§e"
	end
	return ({
	[37] = "1 ряд",
	[38] = "2 ряд",
	[39] = "3 ряд",
	[40] = "первая 12",
	[41] = "вторая 12" ,
	[42] = "третья 12",
	[43] = "1-18",
	[44] = "19-36",
	[45] = "чет",
	[46] = "нечет",
	[47] = "§cкрасное§e",
	[48] = "§0черное§e"
	})[id]
end

local loading = {
	start = function()
		local ws = Workspace:new()
		ws:text(1, HEIGHT, "Загрузка...", 0x005500, 0xffffff)
		ws:draw()
	end,
	finish = function()
		local ws = Workspace:new()
		ws:bind(1, HEIGHT, 11, 1, 0x005500)
		ws:draw()
	end
}


local bets = {}
local winners = {}
local outOfCoins
local firstBet
local sum
local tile_pixel = 4

local current_pos = math.random( 1, #wheel );

local gpu = require("component").gpu

local function bet(nickname, button_id, value)
	loading.start()
	os.sleep(0)
	if not db:has(nickname, value) then
		if outOfCoins.nickname == nil then
			say( "У " .. nickname .. " недостаточно коинов. Пополните баланс в терминале")
			outOfCoins.nickname = true
		end
		loading.finish()
		return
	end
	
	db:pay(nickname, -value)
	if bets[button_id][nickname] ~= nil then
		bets[button_id][nickname]  = bets[button_id][nickname] + value
	else 
		bets[button_id][nickname] = value
	end
	sum = sum + value
	say( nickname .. " поставил " .. value .. " на " .. label(button_id))
	
	os.sleep(0.4)
	if firstBet == 0 then
		firstBet = os.time()
		say("Ставки закроются через 15 секунд")
	end
	loading.finish()
end

local function addWinner(nickname, amount)
	if winners[nickname] == nil then
		winners[nickname] = amount
	else 
		winners[nickname] = winners[nickname] + amount
	end
end

local function withdraw(number)
	for nickname, _bet in pairs(bets[number]) do
		addWinner(nickname, _bet*35)
	end
	if number ~= 0 then
		if number%2 == 0 then -- четное
			for nickname, _bet in pairs(bets[45]) do
				addWinner(nickname, _bet*2)
			end
		else  -- нечетное
			for nickname, _bet in pairs(bets[46]) do
				addWinner(nickname, _bet*2)
			end
		end

		if colors[number] == 'r' then --красное
			for nickname, _bet in pairs(bets[47]) do
				addWinner(nickname, _bet*2)
			end
		else --черное
			for nickname, _bet in pairs(bets[48]) do
				addWinner(nickname, _bet*2)
			end
		end

		if number <= 18 then -- 1-18
			for nickname, _bet in pairs(bets[43]) do
				addWinner(nickname, _bet*2)
			end
		else -- 19-36
			for nickname, _bet in pairs(bets[44]) do
				addWinner(nickname, _bet*2)
			end
		end

		if number <= 12 then -- 1-12
			for nickname, _bet in pairs(bets[40]) do
				addWinner(nickname, _bet*3)
			end
		elseif number <= 24 then -- 13-24
			for nickname, _bet in pairs(bets[41]) do
				addWinner(nickname, _bet*3)
			end
		else --25-36
			for nickname, _bet in pairs(bets[42]) do
				addWinner(nickname, _bet*3)
			end
		end

		if number % 3 == 0 then
			for nickname, _bet in pairs(bets[37]) do
				addWinner(nickname, _bet*3)
			end
		elseif number % 3 == 2 then
			for nickname, _bet in pairs(bets[38]) do
				addWinner(nickname, _bet*3)
			end
		else
			for nickname, _bet in pairs(bets[39]) do
				addWinner(nickname, _bet*3)
			end
		end
	end

	for nickname, value in pairs(winners) do
		say(string.format( "%s выиграл %i коинов", nickname, value ))
	end
end


local function render()
	local ws1 = Workspace:new(WIDTH, HEIGHT)

	--задний фон
	ws1:bind(1, 1, WIDTH, HEIGHT, 0x005500)
	ws1:text(98, 16, "Ставки:", 0x005500, 0xffffff)
	ws1:text(98, 17, "ЛКМ 10", 0x005500, 0xffffff)
	ws1:text(98, 18, "ПКМ 60", 0x005500, 0xffffff)
	--белая рамка
	ws1:bind(3, 2, 103, 13, 0xeeeeee)
	ws1:bind(10, 15, 86, 8, 0xeeeeee)

	--зеленая кнопка 0
	ws1:bind(5, 3, 5, 11, 0x00ee00, function(_,_,nickname, button)
		return bet(nickname, 0, button == mouse.left and 10 or 60)
	end)
	ws1:text(7, 8, "0", 0x00ee00, 0xffffff)

	--управляющие кнопки
	ws1:bind(12, 15, 26, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 40, button == mouse.left and 10 or 60)
	end)
	ws1:text(21, 16, "Первая 12", 0x009900, 0xffffff)
	ws1:bind(40, 15, 26, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 41, button == mouse.left and 10 or 60)
	end)
	ws1:text(49, 16, "Вторая 12", 0x009900, 0xffffff)
	ws1:bind(68, 15, 26, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 42, button == mouse.left and 10 or 60)
	end)
	ws1:text(76, 16, "Третья 12", 0x009900, 0xffffff)
	
	ws1:bind(12, 19, 12, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 43, button == mouse.left and 10 or 60)
	end)
	ws1:text(16, 20, "1-18", 0x009900, 0xffffff)
	ws1:bind(26, 19, 12, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 45, button == mouse.left and 10 or 60)
	end)
	ws1:text(30, 20, "Чет", 0x009900, 0xffffff)
	ws1:bind(40, 19, 12, 3, 0xdd0000, function(_,_,nickname, button)
		return bet(nickname, 47, button == mouse.left and 10 or 60)
	end)
	ws1:text(42, 20, "Красное", 0xdd0000, 0xffffff)
	ws1:bind(54, 19, 12, 3, 0x000000, function(_,_,nickname, button)
		return bet(nickname, 48, button == mouse.left and 10 or 60)
	end)
	ws1:text(57, 20, "Черное", 0x000000, 0xffffff)
	ws1:bind(68, 19, 12, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 46, button == mouse.left and 10 or 60)
	end)
	ws1:text(71, 20, "Нечет", 0x009900, 0xffffff)
	ws1:bind(82, 19, 12, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 44, button == mouse.left and 10 or 60)
	end)
	ws1:text(85, 20, "19-36", 0x009900, 0xffffff)
	
	ws1:bind(96, 3, 8, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 37, button == mouse.left and 10 or 60)
	end)
	ws1:text(98, 4, "1 ряд", 0x009900, 0xffffff)
	ws1:bind(96, 7, 8, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 38, button == mouse.left and 10 or 60)
	end)
	ws1:text(98, 8, "2 ряд", 0x009900, 0xffffff)
	ws1:bind(96, 11, 8, 3, 0x009900, function(_,_,nickname, button)
		return bet(nickname, 39, button == mouse.left and 10 or 60)
	end)
	ws1:text(98, 12, "3 ряд", 0x009900, 0xffffff)

	for j=0,35 do
		local i = order[j+1]
		local color = colors[i]
		if color == 'r' then
			color = 0xdd0000
		else 
			color = 0x000000
		end
		local x = 12 + (j%12)*7
		local y = 3 +  math.floor(j/12)*4
		ws1:bind(x,y,5,3,color, function(_,_,nickname, button)
			return bet(nickname, i, button == mouse.left and 10 or 60)
		end)
		ws1:text(x+2, y+1, tostring(i), color, 0xffffff)
	end
	return ws1
end
local ws_main = render()
ws_main:draw()

--[[
	0-36 цифры
	37 2к1 верхний ряд
	38 2к1 центральный ряд
	39 2к1 нижний ряд
	40 первая 12 
	41 вторая 12 
	42 третья 12 
	43 1-18
	44 19-36
	45 чет
	46 нечет
	47 красное
	48 черное
]]--

local function tick()
	gpu.copy(2,9,106,7,-1,0)
	if tile_pixel <= 7 then
		local index = (current_pos + 5) % #wheel + 1
		local color = get_color( wheel[index] )
		gpu.setBackground(color)
		gpu.fill(107, 10, 1, 5, ' ')
		if tile_pixel == 4 then
			gpu.set( 107, 12, tostring( wheel[index]))
		end
		if tile_pixel == 5 and wheel[index]/10 >=1 then
			gpu.set( 107, 12, tostring( wheel[index] %10))
		end
	else
		gpu.setBackground(0xeeeeee)
		gpu.fill(107, 9, 1, 7, ' ')
	end
	tile_pixel = tile_pixel + 1
	if tile_pixel == 10 then
		tile_pixel = 1
		current_pos = current_pos % #wheel + 1
	end
end

local function roll()
	local rolled = math.random( 0, 36 )
	

	ws = Workspace:new(107, 23)
	ws:bind( 1, 1, 107, 23, 0x005500 )
	ws:bind( 1, 9, 107, 7, 0xeeeeee )
	ws:bind( 54, 2, 1, 6, 0x8b4513 )
	ws:bind( 54, 17, 1, 6, 0x8b4513 )

	for i = -6, 6 do
		local index = (current_pos + i + #wheel - 1) % #wheel + 1
		local num = wheel[index]
		local color = get_color(num)
		
		ws:bind( 51 + i*9, 10, 7, 5, color )
		ws:text( 54 + i*9, 12, tostring(num), color, 0xeeeeee )
	end

	local diff = wheel_index[rolled+1] - current_pos + #wheel
	
	ws:draw()

	local iterations = diff*9
	local delayStart = 0.01
	local delayEnd = 0.08
	local delta = (delayEnd - delayStart)/iterations
	for i = 1,iterations do
		tick()
		os.sleep(delayStart)
		delayStart  = delayStart + delta
	end
	current_pos = wheel_index[rolled+1]
	return rolled
end

local function loop()
	ws_main:draw()
	for i=0, 48 do
		bets[i] = {} --pair(nickname, amount)
	end
	winners = {}
	outOfCoins = {}
	firstBet = 0
	sum = 0
	while firstBet == 0 or os.time() - firstBet < 1000 do
		ws_main.buttons:pull()
	end
	say("Ставки приняты. Общая сумма ставок " .. sum .. " коинов")
	os.sleep(2)
	say("Рулетка крутится...")
	local number = roll()
	os.sleep(4)
	say("Выпало число " .. label(number))

	withdraw(number)

	loading.start()
	for nickname, value in pairs(winners) do
		db:pay(nickname, value)
	end

	loading.finish()
	
end

while true do
	loop()--main game loop
	os.sleep(0)
end