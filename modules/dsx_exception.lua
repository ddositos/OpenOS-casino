local Workspace = require("dsx_workspace")
local term = require("term")
local gpu = require("component").gpu

local Handler = {}
function Handler:new(app)
	local obj = {}
	obj.app = app

	function obj:render(reason)
		term.clear()
		reason = tostring(reason)
		local ws = Workspace:new(160, 50)
		ws:bind(1,1,160,50, 0x222222)
		ws:text(77, 5, "пиздец", 0x222222, 0xffffff)
		ws:bind(1, 45, 160, 5, 0xeeeeee, function(x,y,nickname)
			io.write(string.format("%i %i %s", x,y,nickname))
		end)
		ws:text(75, 47, "Перезапустить", 0xeeeeee, 0x222222)
		ws:draw()
		
		gpu.setBackground(0x222222)
		gpu.setForeground(0xffffff)
		term.setCursor(3,7)
		term.write(reason, true)

		while 1 do
			ws.buttons:pull()
		end
	end

	function obj:run()
		local status, reason = pcall(app)

		if status == false then
			self:render(reason)
		end

		return status
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Handler