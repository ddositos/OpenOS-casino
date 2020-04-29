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

	function obj:attack( _x, _y, _z )
		local x = math.floor(_x) + self.x*-1
		local y = math.floor(_y) + self.y*-1
		local z = math.floor(_z) + self.z*-1
	
	
		if z >= 0 then
			deg = math.deg(math.atan(x/z))*-1+180
		else
			deg = math.deg(math.atan(x/z))*-1
		end
	
		local dist=math.sqrt(x*x+z*z)
		local degv=math.deg(math.atan(y/dist))
		--[[
		local target = {
			x = x - self.x,
			y = y - self.y+1,
			z = z - self.z
		}
		
		local yaw = -math.deg(math.atan2(-target.x,-target.z))
		local dist = math.sqrt(target.x*target.x+target.z*target.z)
		local pitch = math.deg(math.atan(target.y/dist))
		pitch = math.min(pitch, 90)
		pitch = math.max(pitch, -45)
		]]--
		self.proxy.moveTo( dist, degv)
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