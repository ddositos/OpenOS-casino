local internet = require("internet")

local dsx_request = {}

function dsx_request:full_request(url, data, headers, method)
	--checkArg(1, url, "string")
	checkArg(2, data, "string", "table", "nil")
	checkArg(3, headers, "table", "nil")
	checkArg(4, method, "string", "nil")
	
	local response = internet.request(url, data, headers, method)
	local data = ""
	for chunk in response do
		data = data .. chunk
	end
	return data
end

return dsx_request
