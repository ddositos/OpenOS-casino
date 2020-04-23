local Workspace = require("dsx_workspace2")
local Element = require("dsx_element")
local db = require("dsx_db"):new("pank228") --TODO: убрать


local WIDTH = 46
local HEIGHT = 7
local ws = Workspace:new(WIDTH,HEIGHT)

ws:add(Element.block( 1, 1, WIDTH, HEIGHT, 0x222222 ))
ws:add(Element.centered_text( 1, WIDTH, 1, "Топ по деньгам: ", 0xdddddd ))
ws:draw()

while true do
	local ws2 = Workspace:new()
	ws2:add(Element.block( 1, 2, WIDTH, HEIGHT-1, 0x222222 ))
	local i = 1
	for token in db:top():gmatch("[^\n]+") do
		local color = 0xdddddd
		if i == 1 then
			color = 0xffd700
		elseif i == 2 then
			color = 0xc0c0c0
		elseif i == 3 then
			color = 0xcd7f32
		end
		ws2:add(Element.centered_text(1,WIDTH, i+2, token, color))
		i = i + 1 
	end
	ws2:draw()

	os.sleep(300)
end