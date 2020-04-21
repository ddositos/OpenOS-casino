local gpu = require("component").gpu

local Polygon = {}
function Polygon:new(x, y, width, height, background)
	local obj = {}
	obj.x = x
	obj.y = y
	obj.width = width
	obj.height = height
	obj.background = background

	function obj:draw()
		local prev, flag = gpu.getBackground()
		if flag or prev ~= self.background then
			gpu.setBackground(background)
		end
		gpu.fill(self.x, self.y, self.width, self.height, " ")
		return 
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Polygon