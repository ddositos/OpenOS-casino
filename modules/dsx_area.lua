local Area = {}
function Area:new(x, y, width, height)
	local obj = {}
	obj.x = x
	obj.y = y
	obj.width = width
	obj.height = height
	
	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Area