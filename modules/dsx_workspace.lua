local gpu = require("component").gpu
local Buttons = require("dsx_buttons")
local Area = require("dsx_area")
local Polygon = require("dsx_polygon")
local Text = require("dsx_text")

local Workspace = {}

function Workspace:new(width, height)
	local obj = {}
	obj.buttons = Buttons:new()
	obj.elements = {}
	obj.width = width
	obj.height = height


	function obj:bind(x, y, width, height, background, callback)
		table.insert(self.elements, Polygon:new(x, y, width, height, background))

		if callback then
			self.buttons:register(
				Area:new(
					x, 
					y,
					width,
					height
				),
				callback
			)
		end
	end

	function obj:text(x,y,text, background, foreground)
		table.insert(self.elements, Text:new(x,y,text, background, foreground))
	end

	function obj:draw()
		if width and height then
			gpu.setResolution(self.width, self.height)
		end
		for _, element in pairs(obj.elements) do
			element:draw()
		end
	end
	


	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Workspace