local internet = require("internet")
local component = require("component")
local serialization = require("serialization")
local modem

local port
local use_modem = false
local server = ""

if component.isAvailable("modem") then
	modem = component.modem
	port = 6204
	modem.open(port)
	modem.setWakeMessage("server_wake")
	use_modem = true;
end

Database = {}
function Database:new(token)

	local obj = {
		token = token,
		url = "https://mccasiondb.herokuapp.com/"
	}

	function obj:API_request(type, params)
		params.token = self.token
		local data = ""
		if use_modem then
			modem.send(server, port, type, serialization.serialize(params))
			_, _, _, _, _, data = event.pull("modem_message", _, _, server, port)
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
		return (self:API_request("users/top",{ }))
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Database