local Workspace = require("dsx_workspace")

local Handler = {}
function Handler:new(app)
	local obj = {}
	obj.app = app

	function obj:render(reason)
		reason = tostring(reason)
		local ws = Workspace:new(160, 50)
		ws:bind(1,1,160,50, 0x0000ff)
		ws:text(77, 5, "пиздец ", 0x0000ff, 0xffffff )
		ws:text(5, 6, reason, 0x0000ff, 0xffffff )
		ws:draw()
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