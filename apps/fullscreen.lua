local gpu = require("component").gpu

gpu.setBackground(0x0000ff)
local x,y = gpu.getResolution()
gpu.fill(0,0,x,y, ' ')