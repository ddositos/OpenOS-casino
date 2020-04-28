local internet = require("internet")
local component = require("component")
local serialization = require("serialization")
local event = require("event")
local modem

local port = 6204
local server_port = 6205
local use_modem = false
local server = ""

function connect()
	modem.broadcast( server_port )
	_, _, server, _, _ = event.pullFiltered( function( name, _, _, _port, _, message)
		return name == "modem_message" and _port == server_port and message == "server_connect"
	end)
end

if component.isAvailable("modem") then
	modem = component.modem
	modem.open( port )
	modem.open( server_port )
	modem.setWakeMessage( "server_wake" )
	use_modem = true;
	connect()
end

Database = {}
function Database:new(token)

	local obj = {
		token = token,
		url = "https://mccasiondb.herokuapp.com/"
	}

	function obj:API_request(type, params)
		if params == nil then
			params = {}
		end
		params.token = self.token
		local data = ""
		if use_modem then
			--io.write(type, " ", serialization.serialize(params), "\n")
			modem.send(server, port, type, serialization.serialize(params))
			_, _, _, _, _, data = event.pull("modem_message", _, server, port)
			if data == "error" then
				error("error: wrong request")
			end
		else 
			for temp in internet.request(self.url .. type .. "/", params ) do      
				data = data ..  temp
			end
		end
		return data
	end

	function obj:get(nickname)
		return tonumber(self:API_request("users/get", {
			nickname = nickname
		}))
	end

	function obj:pay(nickname, delta)
		self:API_request("users/pay",{
			nickname = nickname,
			delta = delta
		})
		return 
	end

	function obj:set(nickname, balance)
		self:API_request("users/set",{
			nickname = nickname,
			balance = balance
		})
		return 
	end

	function obj:delete(nickname)
		self:API_request("users/delete",{
			nickname = nickname
		})
		return 
	end

	function obj:has(nickname, balance)
		return self:get(nickname) >= balance
	end

	function obj:top()
		return (self:API_request("users/top", {}))
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Database