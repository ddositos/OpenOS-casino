local gpu = require("component").gpu
local Buttons = require("dsx_buttons")
local Element = require("dsx_element")

local Workspace = {}

function Workspace:new(width, height)
	if width == nil or height == nil then
		width, height = gpu.getResolution()
	end
	local obj = Element.block( 1, 1, width, height)
	obj.buttons = Buttons:new()
	obj.root = obj
	obj.background = Element.TRANSPARENT
	local values_to_copy = {'x', 'y', 'width', 'height'}
	for _,property in ipairs(values_to_copy) do
		obj.computed[property] = obj[property]
	end
	obj.computed.background = 0x000000

	function obj:debug()
		self.debug_enabled = true
		self.buttons:register(1, 1, self.width, self.height, function(x,y)
			local colorB, modeB = gpu.setBackground(0x000000)
			local colorF, modeF = gpu.setForeground(0xffffff)
			gpu.set(x,y,x .. " " .. y)
			gpu.setBackground(colorB, modeB)
			gpu.setForeground(colorF, modeF)
		end)
	end


	function obj:draw()
		gpu.setResolution(self.width, self.height)
 
		for _, element in pairs(self.elements) do
			element:draw()
		end

		if self.debug_enabled then
			while true do
				self:pull()
			end
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