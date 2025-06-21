local tilemap = {}
local zones = require("zones")

local TILE_SIZE = 32

local tileImages = {
	["s"] = love.graphics.newImage("Assets/Tiles/s.png"),
	["e"] = love.graphics.newImage("Assets/Tiles/e.png"),
	["c"] = love.graphics.newImage("Assets/Tiles/c.png"),
	["0"] = love.graphics.newImage("Assets/Tiles/0.png"),
	["1"] = love.graphics.newImage("Assets/Tiles/1.png"),
	["2"] = love.graphics.newImage("Assets/Tiles/2.png"),
	["3"] = love.graphics.newImage("Assets/Tiles/3.png"),
	["4"] = love.graphics.newImage("Assets/Tiles/4.png"),
	["5"] = love.graphics.newImage("Assets/Tiles/5.png"),
	["6"] = love.graphics.newImage("Assets/Tiles/6.png"),
	["7"] = love.graphics.newImage("Assets/Tiles/7.png"),
	["8"] = love.graphics.newImage("Assets/Tiles/8.png"),
	["9"] = love.graphics.newImage("Assets/Tiles/0.png"),
	["10"] = love.graphics.newImage("Assets/Tiles/10.png"),
	["11"] = love.graphics.newImage("Assets/Tiles/11.png"),
   
	["q"] = love.graphics.newImage("Assets/Tiles/q.png"),
	["w"] = love.graphics.newImage("Assets/Tiles/w.png"),
	["r"] = love.graphics.newImage("Assets/Tiles/r.png"),
	["t"] = love.graphics.newImage("Assets/Tiles/t.png"),
	["y"] = love.graphics.newImage("Assets/Tiles/y.png"),
	["u"] = love.graphics.newImage("Assets/Tiles/u.png"),
	["i"] = love.graphics.newImage("Assets/Tiles/i.png"),
	["o"] = love.graphics.newImage("Assets/Tiles/o.png"),
   
	["a"] = love.graphics.newImage("Assets/Tiles/a.png"),
	["d"] = love.graphics.newImage("Assets/Tiles/d.png"),
	["f"] = love.graphics.newImage("Assets/Tiles/f.png"),
	["g"] = love.graphics.newImage("Assets/Tiles/g.png"),
	["h"] = love.graphics.newImage("Assets/Tiles/h.png"),
	["j"] = love.graphics.newImage("Assets/Tiles/j.png"),
	["k"] = love.graphics.newImage("Assets/Tiles/k.png"),
	["l"] = love.graphics.newImage("Assets/Tiles/l.png"),
   
	["p1"] = love.graphics.newImage("Assets/Tiles/p1.png"),
	["p2"] = love.graphics.newImage("Assets/Tiles/p2.png"),
	["p3"] = love.graphics.newImage("Assets/Tiles/p3.png"),
	["p4"] = love.graphics.newImage("Assets/Tiles/p4.png"),
	["p5"] = love.graphics.newImage("Assets/Tiles/p5.png"),
	["p6"] = love.graphics.newImage("Assets/Tiles/p6.png"),
	["p7"] = love.graphics.newImage("Assets/Tiles/p7.png"),
	["p8"] = love.graphics.newImage("Assets/Tiles/p8.png"),
	["p9"] = love.graphics.newImage("Assets/Tiles/p9.png"),
}

function tilemap.draw()
	local map = zones.getTileMap()
	if not map then return end

	for y = 1, #map do
		for x = 1, #map[y] do
			local tileType = map[y][x]
			local tileImage = tileImages[tileType]
			if tileImage then
				love.graphics.draw(tileImage, (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE)
			end
		end
	end
end

return tilemap