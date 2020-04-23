local gpu = require("component").gpu
local Buttons = require("dsx_buttons")

local Workspace = {}

function Workspace:new(width, height)
	local obj = {}
	obj.buttons = Buttons:new()
	obj.elements = {}
	obj.width = width
	obj.height = height

	function obj:add(element) 
		table.insert(self.elements, element)
		if element.callback ~= nil and element.x ~= nil and element.y ~= nil and
	 		element.width ~= nil and element.height ~= nil then
			self.buttons:register(element.x, element.y, element.width, element.height, callback)
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

	function obj:draw()
		if width and height then
			gpu.setResolution(self.width, self.height)
		end
		for _, element in pairs(obj.elements) do
			element:draw()
		end
	end

	function obj:pull(...)
		return self.buttons:pull(...)
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Workspace