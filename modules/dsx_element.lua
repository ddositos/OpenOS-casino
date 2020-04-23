local gpu = require("component").gpu
local unicode = require("unicode")

local Block = {}
function Block:new( x, y, width, height, background, callback )
	local obj = {
		x = x,
		y = y,
		width = width,
		height = height,
		background = background,
		callback = callback
	}
	function obj:draw()
		if self.background ~= nil then
			gpu.setBackground( self.background )
			gpu.fill( self.x, self.y, self.width, self.height, " " )
		end
	end
	setmetatable(obj, self)
	self.__index = self
	return obj
end

local Text = {}
function Text:new( x, y, text, foreground, background )
	local obj = {
		x = x,
		y = y,
		text = text,
		background = background,
		foreground = foreground
	}
	function obj:draw()
		if self.background then
			gpu.setBackground( self.background )
		else 
			local _, _, bg, _, index = gpu.get( self.x, self.y )
			if type ~= nil then
				gpu.setBackground( index, true )
			else 
				gpu.setBackground( bg )
			end
		end
		
		if self.foreground then
			gpu.setForeground( self.foreground )
		end
		gpu.set( self.x, self.y, self.text )
	end
	setmetatable(obj, self)
	self.__index = self
	return obj
end

local CenteredText = {}

function CenteredText:new(x1, x2, y, text, foreground, background )
	local obj = {
		x = x1 + math.floor( ( 1 + x2 - x1 - unicode.len(text))/2 ),
		y = y,
		text = text,
		background = background,
		foreground = foreground
	}
	function obj:draw()
		if self.background then
			gpu.setBackground( self.background )
		else 
			local _, _, bg, _, index = gpu.get( self.x, self.y )
			if type ~= nil then
				gpu.setBackground( index, true )
			else 
				gpu.setBackground( bg )
			end
		end
		
		if self.foreground then
			gpu.setForeground( self.foreground )
		end
		gpu.set( self.x, self.y, self.text )
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

local Element = {}

function Element.block( ... )
	return Block:new( ... )
end

function Element.text( ... )
	return Text:new( ... )
end

function Element.centered_text( ... )
	return CenteredText:new( ... )
end

return Element