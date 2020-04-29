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
			y = y - self.y+1,
			z = z - self.z
		}
		
		local yaw = -math.deg(math.atan2(-x,-z))
		local dist = math.sqrt(x*x+z*z)
		local pitch = math.deg(math.atan(y/dist))
		pitch = math.min(pitch, 90)
		pitch = math.max(pitch, -45)
		self.proxy.moveTo( math.floor(yaw), math.floor(pitch))
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