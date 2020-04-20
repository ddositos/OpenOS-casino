local com = require("component")
local gpu = com.gpu

io.write(string.format("Текущее разрешение: %ix%i\n", table.unpack(gpu.getResolution)))
io.write(string.format("Максимальное разрешение: %ix%i\n", table.unpack(gpu.maxResolution)))