local gpu = require("component").gpu
local Buttons = require("dsx_buttons")
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
			self.buttons:register(x,y,width,height,callback)
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

	function obj:debug()
		self.buttons:register(1, 1, self.width, self.height, function(x,y)
			local colorB, modeB = gpu.setBackground(0x000000)
			local colorF, modeF = gpu.setForeground(0xffffff)
			gpu.set(x,y,x .. " " .. y)
			gpu.setBackground(colorB, modeB)
			gpu.setForeground(colorF, modeF)
		end)
	end
	


	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Workspace