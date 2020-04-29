local component = require("component")

local Turret = {}
function Turret:new( id, x, y, z )
	local obj = {
		id = id,
		proxy = component.proxy(id),
		x = x,
		y = y,
		z = z
	}

	function obj:attack( x, y, z )
		local target = {
			x = x - self.x,
			y = y - self.y,
			z = z - self.z
		}
		
		local deg = -math.deg(math.atan(x/z))
		if z >= 0 then
			deg = deg + 180
		end
		local dist = math.sqrt(x*x+z*z)
    	local degv = math.deg(math.atan(y/dist))
		self.proxy.moveTo( deg, degv )
		self.proxy.fire()
	end

	function obj:turnOn()
		self.proxy.powerOn()
		self.proxy.setArmed(true)
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Turret