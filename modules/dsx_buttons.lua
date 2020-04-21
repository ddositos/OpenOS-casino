local com = require("component")
local gpu = com.gpu
local event = require("event")

local Buttons = {}

function Buttons:new()
	local obj = {}
	obj.list = {}

	function obj:register(area, callback)
		area.callback = callback
		table.insert(self.list, area)
		return
	end

	function obj:pull()
		local _,_,x,y,_,nickname = event.pull("touch")
		--only for virtual machine
		if nickname == nil then
			nickname = "doritosxxx"
		end
		for i = #self.list, 1,-1 do
			local button = self.list[i]
			if  button.x <= x and x < button.x+button.width and
				button.y <= y and y < button.y+button.height then
				return button.callback(x,y,nickname)
			end
		end
		return nil
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Buttons