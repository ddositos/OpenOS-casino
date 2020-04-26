local Workspace = require("dsx_workspace2")
local Element = require("dsx_element")
local db = require("dsx_db"):new("pank228") --TODO: убрать


local WIDTH = 46
local HEIGHT = 7
local ws = Workspace:new(WIDTH,HEIGHT)

local back = Element.block( 1, 1, Element.INHERIT, Element.INHERIT, 0x222222 )
	:add(Element.text( Element.ALIGN_CENTER, Element.ALIGN_START, "Топ по деньгам:", 0xdddddd ))

ws:add(back)
ws:draw()

local places = {
	Element.text(Element.ALIGN_CENTER, 3, "", 0xffd700),
	Element.text(Element.ALIGN_CENTER, 4, "", 0xc0c0c0),
	Element.text(Element.ALIGN_CENTER, 5, "", 0xcd7f32),
	Element.text(Element.ALIGN_CENTER, 6, "", 0xdddddd),
	Element.text(Element.ALIGN_CENTER, 7, "", 0xdddddd)
}

local wrapper = Element.block( 1, 3, Element.INHERIT, 5)
back:add(wrapper)

wrapper:draw()

for _, element in pairs(places) do
	wrapper:add(element)
end


while true do
	
	local i = 1
	for token in db:top():gmatch("[^\n]+") do
		places[i].text = token
		places[i]:wrap()
		i = i + 1
	end
	wrapper:draw()
	
	os.sleep(300)
end



while true do
	os.sleep(0)
end