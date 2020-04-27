local component = require("component")
local event = require("event")
local modem = component.modem
local serialization = require("serialization")
local fs = require("filesystem")

local index = "/home/db/"
if not fs.exists( index ) then
	fs.makeDirectory( "index" )
end

local port = 6204
local wakemessage = "server_wake"
modem.open(port)
modem.broadcast(port, wakemessage)

function file_read( path )
	local file = io.open( path, "r" )
	local data = file:read()
	file:close()
	return data
end

function file_write( path, data )
	local file = io.open( path, "w" )
	file:write( data )
	file:close()
end

local Server = {}
function Server:new( )
	local obj = {}

	function obj:query( type, params  )
		if type == "users/get" then
			return self:get( params )
		elseif type == "users/pay" then
			return self:pay( params )
		elseif type == "users/set" then
			return self:set( params )
		elseif type == "users/delete" then
			return self:delete( params )
		elseif type == "users/top" then
			return self:top()
		end

		return "error"
	end

	function obj:get( params )
		local nickname = params.nickname
		local path = index .. nickname
		if not fs.exists( path ) then
			return "0"
		end
		return file_read( path )
	end

	function obj:pay( params )
		local nickname = params.nickname
		local delta = params.delta
		local path = index .. nickname
		if fs.exists( path ) then
			delta = delta + tonumber(file_read( params ))
		end
		file_write( path, delta )
	end

	function obj:set( params )
		local nickname = params.nickname
		local balance = params.balance
		local path = index .. nickname
		file_write( path, tostring( balance ) )
	end

	function obj:delete( params )
		local nickname = params.nickname
		local path = index .. nickname
		fs.remove( path )
	end

	function obj:top()
		local top = {}
		for nickname in fs.list( index ) do
			local path = index .. nickname
			local balance = tonumber(file_read( path ))
			for i, value in ipairs( top ) do
				if value <= balance then
					table.insert( top, i, balance )
					break
				end
			end
			if #top >= 6 then
				table.remove( top )
			end
		end
		local _return = ""
		for i, elem in ipairs(top) do
			_return = _return .. elem .. "\n"
		end
		return _return
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

local server = Server:new()

while true do 
	local _, _, from, _, _, type, params = event.pull( "modem_message", _, _, _, port )
	params = serialization.unserialize( params )
	local response = server:query( type, params )
	io.write(string.format( "from %s: %s\n response: %s\n----------------\n", from, type, response ))
	modem.send( from, port, response )
end