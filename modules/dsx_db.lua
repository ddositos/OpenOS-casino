local internet = require("internet")

Database = {}
function Database:new(token)

	local obj = {}
    obj.token = token
	obj.url = "https://mccasiondb.herokuapp.com/"

	local private = {}

	function private:API_request(type, params)
		params["token"] = self.token
		for temp in internet.request(self.url .. type, params ) do      
			return temp
		end
	end

	function obj:get(nickname)
		return tonumber(private:API_request("users/get", {
			nickname = nickname
		}))
	end

	function obj:pay(nickname, delta)
		return private::API_request("users/pay",{
			nickname = nickname,
			delta = delta
		})
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end