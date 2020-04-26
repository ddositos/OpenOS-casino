local gpu = require("component").gpu
local unicode = require("unicode")

local Element = {
	INHERIT = nil,
	ALIGN_START = -2,
	ALIGN_CENTER = -3,
	ALIGN_END = -4,
	TRANSPARENT = -5
}


local Block = {}
function Block:new( x, y, width, height, background, callback )
	-- assuming x and y are offsetx and offsety
	local obj = {
		x = x,
		y = y,
		width = width,
		height = height,
		background = background,
		callback = callback,
		elements = {},
		computed = {},
		computers = {}
	}

	function obj:add(element)
		element.parent = self
		table.insert(self.elements, element)
		if self.root ~= nil then
			element:connect()
		end
		return self
	end
	
	
	function obj:connect()
		self.root = self.parent.root
		self.parent = self.parent.computed
		self:compute()
	
		for _, element in ipairs(self.elements) do
			element.parent = self
			element:connect()
		end
	end

	function obj:set( key, newvalue )
		self[key] = newvalue
		self.computers[key]( self )
	end

	function obj:compute()
		local computed = self.computed
		local computers = self.computers

		for property, _function in ipairs(computers) do
			_function( self )
			io.write(property, " ")
		end

		--TODO: что-то сделать с колбэками
		if self.callback ~= nil and computed.x ~= nil and computed.y ~= nil and
			computed.width ~= nil and computed.height ~= nil then
			self.root.buttons:register(computed.x, computed.y, computed.width, computed.height, self.callback)
		end
	end

	function obj:set_computers()
		local computed = self.computed
		local computers = self.computers

		--width
		computers.width = function( target )
			if target.width == Element.INHERIT then
				target.computed.width = target.parent.width
			else 
				target.computed.width = target.width
			end
		end

		--height
		computers.height = function( target )
			if target.height == Element.INHERIT then
				target.computed.height = target.parent.height
			else 
				target.computed.height = target.height
			end
		end
		
		--background
		computers.background = function( target )
			if target.background == Element.INHERIT or target.background == Element.TRANSPARENT then
				target.computed.background = target.parent.background
			else 
				target.computed.background = target.background
			end
		end

		--horizontal alignment
		computers.x = function( target )
			if target.x == Element.ALIGN_START or target.width == Element.INHERIT then
				target.computed.x = target.parent.x
			elseif target.x == Element.ALIGN_CENTER then
				target.computed.x = target.parent.x + math.floor((target.parent.width - target.computed.width + 1)/2)
			elseif target.x == Element.ALIGN_END then
				target.computed.x = target.parent.x + target.parent.width - target.computed.width
			else 
				target.computed.x = target.x + target.parent.x
			end
		end

		--vertical alignment
		computers.y = function( target )
			if target.y == Element.ALIGN_START or target.height == Element.INHERIT then
				target.computed.y = target.parent.y
			elseif target.y == Element.ALIGN_CENTER then
				target.computed.y = target.parent.y + math.floor((target.parent.height - target.computed.height + 1)/2)
			elseif target.y == Element.ALIGN_END then
				target.computed.y = target.parent.y + target.parent.height - target.computed.height
			else 
				target.computed.y = target.y + target.parent.y
			end
		end

	end
	
	obj:set_computers()

	function obj:get_computed()
		local _return = ""
		local properties = {'x', 'y', 'width', 'height', 'background'}
		for _,key in ipairs(properties) do
			_return = _return .. key .. ": " .. tostring(self.computed[key]) .. ", "
		end
		return _return
	end

	function obj:draw()
		local computed = self.computed
		local parent = self.parent

		if computed.x == nil or computed.y == nil or computed.width == nil or computed.height == nil then
			local err = ""
			if computed.x == nil then
				err = err .. "x: " .. tostring(computed.x) .. ", "
			end
			if computed.y == nil then
				err = err .. "y: " .. tostring(computed.y) .. ", "
			end
			if computed.width == nil then
				err = err .. "width: " .. tostring(computed.width) .. ", "
			end
			if computed.height == nil then
				err = err .. "height: " .. tostring(computed.height) .. ", "
			end
			error(err)
			return 
		end

		if parent == nil then
			error("Element must be connected to workspace")
		end

		if self.background ~= Element.TRANSPARENT then
			gpu.setBackground( computed.background )
			gpu.fill( computed.x, computed.y, computed.width, computed.height, " " )
		end

		for _, element in pairs(self.elements) do
			element:draw()
		end
	end

	

	setmetatable(obj, self)
	self.__index = self
	return obj
end


local Text = {}
function Text:new( offsetx, offsety, text, foreground, background )
	local obj = {
		offsetx = offsetx,
		offsety = offsety,
		text = text,
		background = background,
		foreground = foreground,
		computed = {}
	}

	function obj:wrap()
		if #self.text > 8000 then
			error( "String is too long" )
		end
		local chunks = {}
		local chunk = ""
		for token in self.text:gmatch("[^%s]+") do
			if #chunk + 1 + #token <= self.parent.width then
				if chunk ~= "" then
					chunk = chunk .. " "
				end
				chunk = chunk .. token
			else 
				table.insert( chunks, chunk )
				chunk = token
			end
		end
		if chunk ~= "" then
			table.insert( chunks, chunk )
		end
		self.computed.chunks = chunks
	end

	function obj:compute()

		local computed = self.computed
		self.parent = self.parent.computed
		local parent = self.parent

		if self.background == Element.INHERIT then
			computed.background = parent.background
		else 
			computed.background = self.background
		end

		if self.foreground == Element.INHERIT then
			computed.foreground = parent.foreground
		else 
			computed.foreground = self.foreground
		end

		--vertical alignment
		if self.offsety == Element.ALIGN_START then
			computed.y = parent.y
		elseif self.offsety == Element.ALIGN_CENTER then
			computed.y = parent.y + math.floor((parent.height - #computed.chunks + 1)/2)
		elseif self.offsety == Element.ALIGN_END then
			computed.y = parent.y + parent.height - #computed.chunks
		else 
			computed.y = self.offsety
		end	

		self:wrap()
		
	end

	function obj:draw()

		local computed = self.computed
		local parent = self.parent

		local y = computed.y
		for _, chunk in ipairs(computed.chunks) do
			local length = unicode.len(chunk)
			--horizontal alignment
			local x 
			if self.offsetx == Element.ALIGN_CENTER then
				x = parent.x + math.floor((parent.width - length + 1)/2)
			elseif self.offsetx == Element.ALIGN_END then
				x = parent.x + parent.width - length
			elseif self.offsetx == Element.ALIGN_START then
				x = parent.x
			else 
				x = self.offsetx
			end

			gpu.setBackground( computed.background )
			gpu.setForeground( computed.foreground )
			gpu.set( x, y, chunk)

			y = y + 1
		end
		
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

function Element.block( ... )
	return Block:new( ... )
end

function Element.text( ... )
	return Text:new( ... )
end

return Element