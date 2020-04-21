local com = require("component")
local gpu = com.gpu
local term = require("term")
local internet = require("internet")
local Polygon = require("dsx_polygon")
local Text = require("dsx_text")
local Workspace = require("dsx_workspace")
local Area = require("dsx_area")

local WIDTH = 107
local HEIGHT = 23
gpu.setResolution(WIDTH, HEIGHT)

local ws1 = Workspace:new()
--задний фон
ws1:bind(1,1, WIDTH, HEIGHT, 0x005500)
--белая рамка
ws1:bind(3, 2, 103, 13, 0xeeeeee)
ws1:bind(10, 15, 86, 8, 0xeeeeee)
--зеленая кнопка 0
ws1:bind(5, 3, 5, 11, 0x00ee00)
ws1:text(7, 8, "0", 0x00ee00, 0xffffff)
--управляющие кнопки
ws1:bind(12, 15, 26, 3, 0x009900)
ws1:text(21, 16, "Первая 12", 0x009900, 0xffffff)
ws1:bind(40, 15, 26, 3, 0x009900)
ws1:text(49, 16, "Вторая 12", 0x009900, 0xffffff)
ws1:bind(68, 15, 26, 3, 0x009900)
ws1:text(76, 16, "Третья 12", 0x009900, 0xffffff)

ws1:bind(12, 19, 12, 3, 0x009900)
ws1:text(16, 20, "1-18", 0x009900, 0xffffff)
ws1:bind(26, 19, 12, 3, 0x009900)
ws1:text(30, 20, "Чет", 0x009900, 0xffffff)
ws1:bind(40, 19, 12, 3, 0xdd0000)
ws1:text(42, 20, "Красное", 0xdd0000, 0xffffff)
ws1:bind(54, 19, 12, 3, 0x000000)
ws1:text(57, 20, "Черное", 0x000000, 0xffffff)
ws1:bind(68, 19, 12, 3, 0x009900)
ws1:text(71, 20, "Нечет", 0x009900, 0xffffff)
ws1:bind(82, 19, 12, 3, 0x009900)
ws1:text(85, 20, "19-36", 0x009900, 0xffffff)

ws1:bind(96, 3, 8, 3, 0x009900)
ws1:text(98, 4, "2 к 1", 0x009900, 0xffffff)
ws1:bind(96, 7, 8, 3, 0x009900)
ws1:text(98, 8, "2 к 1", 0x009900, 0xffffff)
ws1:bind(96, 11, 8, 3, 0x009900)
ws1:text(98, 12, "2 к 1", 0x009900, 0xffffff)
--красные кнопки
ws1:bind(12, 3, 5, 3, 0xdd0000)
ws1:text(14, 4, "3", 0xdd0000, 0xffffff)
ws1:bind(26, 3, 5, 3, 0xdd0000)
ws1:text(28, 4, "9", 0xdd0000, 0xffffff)
ws1:bind(33, 3, 5, 3, 0xdd0000)
ws1:text(34, 4, "1 2", 0xdd0000, 0xffffff)
ws1:bind(47, 3, 5, 3, 0xdd0000)
ws1:text(49, 4, "1 8", 0xdd0000, 0xffffff)
ws1:bind(54, 3, 5, 3, 0xdd0000)
ws1:text(56, 4, "2 1", 0xdd0000, 0xffffff)
ws1:bind(68, 3, 5, 3, 0xdd0000)
ws1:text(70, 4, "2 7", 0xdd0000, 0xffffff)
ws1:bind(75, 3, 5, 3, 0xdd0000)
ws1:text(77, 4, "30", 0xdd0000, 0xffffff)
ws1:bind(89, 3, 5, 3, 0xdd0000)
ws1:text(91, 4, "36", 0xdd0000, 0xffffff)

ws1:bind(19, 7, 5, 3, 0xdd0000)
ws1:text(21, 8, "5", 0xdd0000, 0xffffff)
ws1:bind(40, 7, 5, 3, 0xdd0000)
ws1:bind(61, 7, 5, 3, 0xdd0000)
ws1:bind(82, 7, 5, 3, 0xdd0000)

ws1:bind(12, 11, 5, 3, 0xdd0000)
ws1:bind(26, 11, 5, 3, 0xdd0000)
ws1:bind(47, 11, 5, 3, 0xdd0000)
ws1:bind(54, 11, 5, 3, 0xdd0000)
ws1:bind(68, 11, 5, 3, 0xdd0000)
ws1:bind(89, 11, 5, 3, 0xdd0000)
--черные кнопки
ws1:bind(19, 3, 5, 3, 0x000000)
ws1:bind(40, 3, 5, 3, 0x000000)
ws1:bind(61, 3, 5, 3, 0x000000)
ws1:bind(82, 3, 5, 3, 0x000000)

ws1:bind(12, 7, 5, 3, 0x000000)
ws1:bind(26, 7, 5, 3, 0x000000)
ws1:bind(33, 7, 5, 3, 0x000000)
ws1:bind(47, 7, 5, 3, 0x000000)
ws1:bind(54, 7, 5, 3, 0x000000)
ws1:bind(68, 7, 5, 3, 0x000000)
ws1:bind(75, 7, 5, 3, 0x000000)
ws1:bind(89, 7, 5, 3, 0x000000)

ws1:bind(19, 11, 5, 3, 0x000000)
ws1:bind(33, 11, 5, 3, 0x000000)
ws1:bind(40, 11, 5, 3, 0x000000)
ws1:bind(61, 11, 5, 3, 0x000000)
ws1:bind(75, 11, 5, 3, 0x000000)
ws1:bind(82, 11, 5, 3, 0x000000)

ws1.buttons:register(Area:new(1,1,WIDTH, HEIGHT), function(x,y)
	local colorB, modeB = gpu.setBackground(0x000000)
	local colorF, modeF = gpu.setForeground(0xffffff)
	gpu.set(x,y, x .. ' ' .. y)
	gpu.setBackground(colorB, modeB)
	gpu.setForeground(colorF, modeF)
end)

ws1:draw()

while 1 do
	ws1.buttons:pull()
end

