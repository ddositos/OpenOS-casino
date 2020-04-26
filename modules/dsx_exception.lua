local Workspace = require("dsx_workspace2")
local Element = require("dsx_element")
local gpu = require("component").gpu
local constants = require("dsx_constants")

local Handler = {}
function Handler:new(app)
	local obj = {}
	obj.app = app

	function obj:render(reason)
		reason = tostring(reason)
		local ws = Workspace:new()
		ws:add( 
			Element.block( 1, 1, Element.INHERIT, Element.INHERIT, 0x222222 )
			:add( Element.text( Element.ALIGN_CENTER, 4, "Лучше позовите админа", 0xdddddd ))
			:add( 
				Element.block(1 , Element.ALIGN_END, Element.INHERIT, 7, 0xdddddd,function(x,y,nickname)
					for _, admin in pairs(constants.admins) do
						if nickname == admin then
							return true
						end
					end
					return false
				end)
				:add(Element.text( Element.ALIGN_CENTER, Element.ALIGN_CENTER, "Перезагрузить", 0x222222))
			)
			:add(Element.text( 3, 7, reason, 0xdddddd))
		)
			
		ws:draw()
		

		while not ws:pull() do
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