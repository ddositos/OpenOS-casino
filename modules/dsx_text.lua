local gpu = require("component").gpu

local Text = {}
function Text:new(x,y,text, background, foreground)
	local obj = {}
	obj.x = x
	obj.y = y
	obj.text = text
	obj.background = background
	obj.foreground = foreground

	function obj:draw()
		local prev, flag = gpu.getBackground()
		if flag or prev ~= self.background then
			gpu.setBackground(background)
		end
		prev, flag = gpu.getForeground()
		if flag or prev ~= self.foreground then
			gpu.getForeground(foreground)
		end
		gpu.set(self.x, self.y, self.text)
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Text