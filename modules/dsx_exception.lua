local Workspace = require("dsx_workspace")
local term = require("term")
local gpu = require("component").gpu
local constants = require("dsx_constants")

local Handler = {}
function Handler:new(app)
	local obj = {}
	obj.app = app

	function obj:render(reason)
		term.clear()
		reason = tostring(reason)
		local ws = Workspace:new(160, 50)
		ws:bind(1,1,160,50, 0x222222)
		ws:text(70, 5, "Лучше позовите админа", 0x222222, 0xffffff)
		ws:bind(1, 44, 160, 7, 0xeeeeee, function(x,y,nickname)
			for _, admin in pairs(constants.admins) do
				if nickname == admin then
					return true
				end
			end
			return false
		end)
		ws:text(75, 47, "Перезапустить", 0xeeeeee, 0x222222)
		ws:draw()
		
		gpu.setBackground(0x222222)
		gpu.setForeground(0xffffff)
		term.setCursor(3,8)
		term.write(reason, true)

		while not ws.buttons:pull() do
			--do nothing
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