local component = require("component")
local event = require("event")
local modem = component.modem
local serialization = require("serialization")
local fs = require("filesystem")

function file_read( path )
	local file = io.open( path, "r" )
	local data = file:read()
	file:close()
	return data
end

function file_write( path, data )
	local file, reason = io.open( path, "w" )
	if file == nil then
		error(reason)
	end
	file:write( data )
	file:close()
end

local index = "/home/db/"
if not fs.exists( index ) then
	fs.makeDirectory( index )
end

local port = 6204
local server_port = 6205
local wakemessage = "server_wake"
local token = file_read("/home/token")
modem.open( port )
modem.open( server_port )

local Server = {}
function Server:new( )
	local obj = {}

	function obj:query( type, params )
		if params.token ~= token then
			return "error"
		elseif type == "users/get" then
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
		local delta = tonumber(params.delta)
		local path = index .. nickname
		if fs.exists( path ) then
			delta = delta + tonumber(file_read( path ))
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
			local pair = { balance, nickname }
			local inserted = false
			for i, value in ipairs( top ) do
				if value[1] <= pair[1] then
					table.insert( top, i, pair )
					inserted = true
					break
				end
			end
			if not inserted then
				table.insert( top, pair )
			end
			
			if #top >= 6 then
				table.remove( top )
			end
		end
		local _return = ""
		for i, pair in ipairs(top) do
			_return = _return .. string.format( "%s %i коинов\n", pair[2], pair[1] )
		end
		return _return
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

local server = Server:new()

while true do 
	modem.broadcast( server_port, wakemessage )
	local _, _, from, port, _, type, params = event.pullFiltered(function( name, _, _, _port )
		return name == "modem_message" and ( _port == port or _port == server_port )
	end)
	if port == server_port then
		io.write(string.format( "from %s: connection request\n\n", from ))
		modem.send( from, server_port, "server_connect" )
	else 
		unserialized = serialization.unserialize( params )
		io.write(string.format( "from %s: %s\nparams: %s\n", from, type, params ))
		local response = server:query( type, unserialized )
		io.write(string.format( "response: %s\n\n", response ))
		modem.send( from, port, tostring(response))
	end
end