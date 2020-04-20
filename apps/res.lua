local com = require("component")
local gpu = com.gpu

io.write(string.format("Текущее разрешение: %ix%i\n", gpu.getResolution()))
io.write(string.format("Максимальное разрешение: %ix%i\n", gpu.maxResolution()))