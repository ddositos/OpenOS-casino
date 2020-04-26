local Workspace = require("dsx_workspace2")
local Element = require("dsx_element")
local db = require("dsx_db"):new("pank228") --TODO: убрать


local WIDTH = 80
local HEIGHT = 40
local ws = Workspace:new(WIDTH,HEIGHT)

local block = Element.block(1,1, Element.INHERTI, Element.INHERTI, 0x222222)



ws:add(block)
error(block:get_computed())
		--[[:add(
			Element.block(Element.ALIGN_CENTER, Element.ALIGN_CENTER, 20, 10, 0xffffff )
				:add(Element.block(Element.ALIGN_END, Element.ALIGN_END, 6, 3, 0x00ffff))
				:add(Element.block(Element.ALIGN_START, Element.ALIGN_START, 6, 3, 0x00ff00))
		)]]--

ws:draw()



while true do
	os.sleep(0)
end